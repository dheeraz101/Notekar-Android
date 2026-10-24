import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Exception thrown when vault decryption or authentication fails.
class VaultAuthException implements Exception {
  final String message;
  const VaultAuthException(this.message);

  @override
  String toString() => 'VaultAuthException: $message';
}

/// Zero-Knowledge Vault Encryption Service using PBKDF2-HMAC-SHA256 and AES-256-GCM.
///
/// Complies with NIST SP 800-38D (AES-GCM) and RFC 8018 (PBKDF2).
/// Produces password-protected `.notekar-vault` backup files.
class VaultEncryptionService {
  VaultEncryptionService._();
  static final VaultEncryptionService instance = VaultEncryptionService._();

  static const int defaultPbkdf2Iterations = 10000;
  static const int saltLength = 16;
  static const int nonceLength = 12;
  static const int keyLength = 32; // 256-bit AES
  static const int tagLength = 16; // 128-bit GCM tag

  /// Derives a 256-bit key from a password and salt using PBKDF2-HMAC-SHA256.
  Uint8List deriveKey({
    required String password,
    required Uint8List salt,
    int iterations = defaultPbkdf2Iterations,
    int derivedKeyLength = keyLength,
  }) {
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);
    final numBlocks = (derivedKeyLength + 31) ~/ 32;
    final derivedKey = Uint8List(derivedKeyLength);
    var offset = 0;

    for (int blockIndex = 1; blockIndex <= numBlocks; blockIndex++) {
      // U_1 = HMAC(password, salt || INT_32_BE(blockIndex))
      final saltAndIndex = Uint8List(salt.length + 4);
      saltAndIndex.setRange(0, salt.length, salt);
      final bdata = ByteData.sublistView(
        saltAndIndex,
        salt.length,
        salt.length + 4,
      );
      bdata.setUint32(0, blockIndex, Endian.big);

      var u = Uint8List.fromList(hmac.convert(saltAndIndex).bytes);
      final blockResult = Uint8List.fromList(u);

      // U_2 ... U_c
      for (int iter = 1; iter < iterations; iter++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (int k = 0; k < blockResult.length; k++) {
          blockResult[k] ^= u[k];
        }
      }

      final copyLen = min(32, derivedKeyLength - offset);
      derivedKey.setRange(
        offset,
        offset + copyLen,
        blockResult.sublist(0, copyLen),
      );
      offset += copyLen;
    }

    return derivedKey;
  }

  /// Encrypts plaintext JSON or text using AES-256-GCM with a user password.
  /// Returns the complete `.notekar-vault` JSON string.
  String encryptVault({
    required String plaintext,
    required String password,
    int iterations = defaultPbkdf2Iterations,
    Uint8List? customSalt,
    Uint8List? customNonce,
  }) {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty.');
    }

    final secureRandom = Random.secure();
    final salt = customSalt ?? Uint8List(saltLength);
    if (customSalt == null) {
      for (int i = 0; i < salt.length; i++) {
        salt[i] = secureRandom.nextInt(256);
      }
    }

    final nonce = customNonce ?? Uint8List(nonceLength);
    if (customNonce == null) {
      for (int i = 0; i < nonce.length; i++) {
        nonce[i] = secureRandom.nextInt(256);
      }
    }

    final key = deriveKey(
      password: password,
      salt: salt,
      iterations: iterations,
    );
    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));

    final gcmCipher = _AesGcmCipher(key: key);
    final encrypted = gcmCipher.encrypt(
      plaintext: plaintextBytes,
      nonce: nonce,
    );

    final vaultPayload = {
      'notekar_vault_version': 1,
      'kdf': {
        'algorithm': 'PBKDF2-HMAC-SHA256',
        'salt': base64Encode(salt),
        'iterations': iterations,
      },
      'cipher': {
        'algorithm': 'AES-256-GCM',
        'nonce': base64Encode(nonce),
        'tag': base64Encode(encrypted.tag),
      },
      'ciphertext': base64Encode(encrypted.ciphertext),
      'created_at': DateTime.now().toIso8601String(),
    };

    return const JsonEncoder.withIndent('  ').convert(vaultPayload);
  }

  /// Decrypts a `.notekar-vault` JSON string using the provided password.
  /// Throws [VaultAuthException] if the password is wrong or ciphertext has been altered.
  String decryptVault({
    required String vaultContent,
    required String password,
  }) {
    if (password.isEmpty) {
      throw const VaultAuthException('Password cannot be empty.');
    }

    dynamic parsed;
    try {
      parsed = jsonDecode(vaultContent);
    } catch (_) {
      throw const VaultAuthException(
        'File is not a valid NoteKar vault format.',
      );
    }

    if (parsed is! Map<String, dynamic> ||
        parsed['notekar_vault_version'] == null) {
      throw const VaultAuthException('Unrecognized or corrupted vault header.');
    }

    final kdf = parsed['kdf'] as Map<String, dynamic>?;
    final cipher = parsed['cipher'] as Map<String, dynamic>?;
    final ciphertextB64 = parsed['ciphertext'] as String?;

    if (kdf == null || cipher == null || ciphertextB64 == null) {
      throw const VaultAuthException(
        'Vault package is missing required security metadata.',
      );
    }

    final saltB64 = kdf['salt'] as String?;
    final iterations =
        (kdf['iterations'] as num?)?.toInt() ?? defaultPbkdf2Iterations;
    final nonceB64 = cipher['nonce'] as String?;
    final tagB64 = cipher['tag'] as String?;

    if (saltB64 == null || nonceB64 == null || tagB64 == null) {
      throw const VaultAuthException(
        'Vault contains incomplete cryptographic parameters.',
      );
    }

    if (iterations < 1) {
      throw const VaultAuthException(
        'Invalid PBKDF2 iterations parameter: must be >= 1.',
      );
    }

    final Uint8List salt;
    final Uint8List nonce;
    final Uint8List tag;
    final Uint8List ciphertext;
    try {
      salt = base64Decode(saltB64);
      nonce = base64Decode(nonceB64);
      tag = base64Decode(tagB64);
      ciphertext = base64Decode(ciphertextB64);
    } catch (e) {
      throw VaultAuthException('Invalid Base64 cryptographic encoding: $e');
    }

    final key = deriveKey(
      password: password,
      salt: salt,
      iterations: iterations,
    );
    final gcmCipher = _AesGcmCipher(key: key);

    final plaintextBytes = gcmCipher.decrypt(
      ciphertext: ciphertext,
      nonce: nonce,
      tag: tag,
    );

    try {
      return utf8.decode(plaintextBytes);
    } catch (e) {
      throw VaultAuthException('Decrypted data is not valid UTF-8 text: $e');
    }
  }

  /// Helper to check if a content string represents an encrypted `.notekar-vault` file.
  bool isVaultContent(String content) {
    try {
      final parsed = jsonDecode(content);
      return parsed is Map<String, dynamic> &&
          parsed['notekar_vault_version'] != null;
    } catch (_) {
      return false;
    }
  }
}

class _AesGcmResult {
  final Uint8List ciphertext;
  final Uint8List tag;
  const _AesGcmResult({required this.ciphertext, required this.tag});
}

/// AES-256 Galois/Counter Mode (GCM) implementation in pure Dart.
class _AesGcmCipher {
  final Uint8List key;
  late final _AesEngine _aes;
  late final Uint8List _h;

  _AesGcmCipher({required this.key}) {
    if (key.length != 32) {
      throw ArgumentError('AES-256 requires a 32-byte key.');
    }
    _aes = _AesEngine(key);
    // H = AES_K(0^128)
    _h = Uint8List(16);
    _aes.encryptBlock(Uint8List(16), _h);
  }

  _AesGcmResult encrypt({
    required Uint8List plaintext,
    required Uint8List nonce,
    Uint8List? aad,
  }) {
    final effectiveAad = aad ?? Uint8List(0);
    final j0 = _computeJ0(nonce);

    // 1. AES-CTR encrypt plaintext starting at counter = j0 + 1
    final ciphertext = _ctrCrypt(plaintext, j0, 1);

    // 2. GHASH calculation
    final tag = _computeTag(effectiveAad, ciphertext, j0);

    return _AesGcmResult(ciphertext: ciphertext, tag: tag);
  }

  Uint8List decrypt({
    required Uint8List ciphertext,
    required Uint8List nonce,
    required Uint8List tag,
    Uint8List? aad,
  }) {
    final effectiveAad = aad ?? Uint8List(0);
    final j0 = _computeJ0(nonce);

    // 1. Verify authentication tag FIRST before decrypting
    final expectedTag = _computeTag(effectiveAad, ciphertext, j0);
    if (!_constantTimeCompare(tag, expectedTag)) {
      throw const VaultAuthException(
        'Authentication tag mismatch. Invalid password or corrupted file.',
      );
    }

    // 2. AES-CTR decrypt ciphertext
    return _ctrCrypt(ciphertext, j0, 1);
  }

  Uint8List _computeJ0(Uint8List nonce) {
    final j0 = Uint8List(16);
    if (nonce.length == 12) {
      j0.setRange(0, 12, nonce);
      j0[15] = 1; // 96-bit nonce followed by 31 zero bits and 1
    } else {
      // General nonce GHASH
      final lenBlock = Uint8List(16);
      final bdata = ByteData.sublistView(lenBlock);
      bdata.setUint64(8, nonce.length * 8, Endian.big);
      final ghash = _ghash(Uint8List(0), nonce, lenBlock);
      j0.setAll(0, ghash);
    }
    return j0;
  }

  Uint8List _computeTag(Uint8List aad, Uint8List ciphertext, Uint8List j0) {
    final lenBlock = Uint8List(16);
    final bdata = ByteData.sublistView(lenBlock);
    bdata.setUint64(0, aad.length * 8, Endian.big);
    bdata.setUint64(8, ciphertext.length * 8, Endian.big);

    final s = _ghash(aad, ciphertext, lenBlock);

    // Tag = S ^ AES_K(J_0)
    final ej0 = Uint8List(16);
    _aes.encryptBlock(j0, ej0);

    final tag = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      tag[i] = s[i] ^ ej0[i];
    }
    return tag;
  }

  Uint8List _ctrCrypt(Uint8List input, Uint8List j0, int initialCounter) {
    final output = Uint8List(input.length);
    final counterBlock = Uint8List.fromList(j0);
    final keystream = Uint8List(16);
    final counterView = ByteData.sublistView(counterBlock);

    var currentCounter = counterView.getUint32(12, Endian.big) + initialCounter;
    var inOffset = 0;

    while (inOffset < input.length) {
      counterView.setUint32(12, currentCounter, Endian.big);
      _aes.encryptBlock(counterBlock, keystream);

      final blockSize = min(16, input.length - inOffset);
      for (int i = 0; i < blockSize; i++) {
        output[inOffset + i] = input[inOffset + i] ^ keystream[i];
      }
      inOffset += blockSize;
      currentCounter++;
    }
    return output;
  }

  Uint8List _ghash(Uint8List aad, Uint8List ciphertext, Uint8List lenBlock) {
    final x = Uint8List(16);

    void processData(Uint8List data) {
      var offset = 0;
      while (offset < data.length) {
        final block = Uint8List(16);
        final copyLen = min(16, data.length - offset);
        block.setRange(0, copyLen, data.sublist(offset, offset + copyLen));
        for (int i = 0; i < 16; i++) {
          x[i] ^= block[i];
        }
        _gfMultiply(x, _h);
        offset += copyLen;
      }
    }

    if (aad.isNotEmpty) processData(aad);
    if (ciphertext.isNotEmpty) processData(ciphertext);
    processData(lenBlock);

    return x;
  }

  /// Constant-time memory comparison to prevent timing attacks.
  bool _constantTimeCompare(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Multiplication in GF(2^128) modulo x^128 + x^7 + x^2 + x + 1.
  void _gfMultiply(Uint8List x, Uint8List y) {
    var v0 = 0;
    var v1 = 0;
    var v2 = 0;
    var v3 = 0;

    final yData = ByteData.sublistView(y);
    v0 = yData.getUint32(0, Endian.big);
    v1 = yData.getUint32(4, Endian.big);
    v2 = yData.getUint32(8, Endian.big);
    v3 = yData.getUint32(12, Endian.big);

    var z0 = 0;
    var z1 = 0;
    var z2 = 0;
    var z3 = 0;

    for (int i = 0; i < 16; i++) {
      final b = x[i];
      for (int j = 7; j >= 0; j--) {
        if ((b & (1 << j)) != 0) {
          z0 ^= v0;
          z1 ^= v1;
          z2 ^= v2;
          z3 ^= v3;
        }

        final lsb = (v3 & 1) != 0;
        v3 = ((v3 >>> 1) | ((v2 & 1) << 31)) & 0xFFFFFFFF;
        v2 = ((v2 >>> 1) | ((v1 & 1) << 31)) & 0xFFFFFFFF;
        v1 = ((v1 >>> 1) | ((v0 & 1) << 31)) & 0xFFFFFFFF;
        v0 = (v0 >>> 1) & 0xFFFFFFFF;

        if (lsb) {
          v0 ^= 0xE1000000;
        }
      }
    }

    final xData = ByteData.sublistView(x);
    xData.setUint32(0, z0, Endian.big);
    xData.setUint32(4, z1, Endian.big);
    xData.setUint32(8, z2, Endian.big);
    xData.setUint32(12, z3, Endian.big);
  }
}

/// Pure Dart AES-256 block cipher engine according to FIPS 197.
class _AesEngine {
  static const int _numRounds = 14;
  late final Uint32List _expandedKey;

  _AesEngine(Uint8List key) {
    _expandedKey = _expandKey(key);
  }

  void encryptBlock(Uint8List input, Uint8List output) {
    var s0 = (input[0] << 24) | (input[1] << 16) | (input[2] << 8) | input[3];
    var s1 = (input[4] << 24) | (input[5] << 16) | (input[6] << 8) | input[7];
    var s2 = (input[8] << 24) | (input[9] << 16) | (input[10] << 8) | input[11];
    var s3 =
        (input[12] << 24) | (input[13] << 16) | (input[14] << 8) | input[15];

    s0 ^= _expandedKey[0];
    s1 ^= _expandedKey[1];
    s2 ^= _expandedKey[2];
    s3 ^= _expandedKey[3];

    var kOffset = 4;
    for (int r = 1; r < _numRounds; r++) {
      final t0 =
          _t0(s0) ^ _t1(s1) ^ _t2(s2) ^ _t3(s3) ^ _expandedKey[kOffset++];
      final t1 =
          _t0(s1) ^ _t1(s2) ^ _t2(s3) ^ _t3(s0) ^ _expandedKey[kOffset++];
      final t2 =
          _t0(s2) ^ _t1(s3) ^ _t2(s0) ^ _t3(s1) ^ _expandedKey[kOffset++];
      final t3 =
          _t0(s3) ^ _t1(s0) ^ _t2(s1) ^ _t3(s2) ^ _expandedKey[kOffset++];
      s0 = t0;
      s1 = t1;
      s2 = t2;
      s3 = t3;
    }

    // Final round: SubBytes + ShiftRows + AddRoundKey without MixColumns
    s0 =
        _subWord(s0, 0) ^
        _subWord(s1, 1) ^
        _subWord(s2, 2) ^
        _subWord(s3, 3) ^
        _expandedKey[kOffset++];
    s1 =
        _subWord(s1, 0) ^
        _subWord(s2, 1) ^
        _subWord(s3, 2) ^
        _subWord(s0, 3) ^
        _expandedKey[kOffset++];
    s2 =
        _subWord(s2, 0) ^
        _subWord(s3, 1) ^
        _subWord(s0, 2) ^
        _subWord(s1, 3) ^
        _expandedKey[kOffset++];
    s3 =
        _subWord(s3, 0) ^
        _subWord(s0, 1) ^
        _subWord(s1, 2) ^
        _subWord(s2, 3) ^
        _expandedKey[kOffset++];

    output[0] = (s0 >>> 24) & 0xFF;
    output[1] = (s0 >>> 16) & 0xFF;
    output[2] = (s0 >>> 8) & 0xFF;
    output[3] = s0 & 0xFF;

    output[4] = (s1 >>> 24) & 0xFF;
    output[5] = (s1 >>> 16) & 0xFF;
    output[6] = (s1 >>> 8) & 0xFF;
    output[7] = s1 & 0xFF;

    output[8] = (s2 >>> 24) & 0xFF;
    output[9] = (s2 >>> 16) & 0xFF;
    output[10] = (s2 >>> 8) & 0xFF;
    output[11] = s2 & 0xFF;

    output[12] = (s3 >>> 24) & 0xFF;
    output[13] = (s3 >>> 16) & 0xFF;
    output[14] = (s3 >>> 8) & 0xFF;
    output[15] = s3 & 0xFF;
  }

  static Uint32List _expandKey(Uint8List key) {
    const totalWords = 4 * (_numRounds + 1); // 60 words for 256-bit AES
    final w = Uint32List(totalWords);

    for (int i = 0; i < 8; i++) {
      w[i] =
          (key[4 * i] << 24) |
          (key[4 * i + 1] << 16) |
          (key[4 * i + 2] << 8) |
          key[4 * i + 3];
    }

    const rcon = [
      0x01000000,
      0x02000000,
      0x04000000,
      0x08000000,
      0x10000000,
      0x20000000,
      0x40000000,
      0x80000000,
      0x1b000000,
      0x36000000,
    ];

    for (int i = 8; i < totalWords; i++) {
      var temp = w[i - 1];
      if (i % 8 == 0) {
        // RotWord + SubWord + Rcon
        temp = ((temp << 8) | (temp >>> 24)) & 0xFFFFFFFF;
        temp = _subBytesWord(temp) ^ rcon[(i ~/ 8) - 1];
      } else if (i % 8 == 4) {
        temp = _subBytesWord(temp);
      }
      w[i] = w[i - 8] ^ temp;
    }
    return w;
  }

  static int _subBytesWord(int w) {
    return (_sbox[(w >>> 24) & 0xFF] << 24) |
        (_sbox[(w >>> 16) & 0xFF] << 16) |
        (_sbox[(w >>> 8) & 0xFF] << 8) |
        _sbox[w & 0xFF];
  }

  static int _subWord(int word, int bytePos) {
    final b = (word >>> (24 - 8 * bytePos)) & 0xFF;
    return _sbox[b] << (24 - 8 * bytePos);
  }

  static int _t0(int s) {
    final b = (s >>> 24) & 0xFF;
    final sb = _sbox[b];
    return (_mul2(sb) << 24) | (_mul3(sb) << 16) | (sb << 8) | sb;
  }

  static int _t1(int s) {
    final b = (s >>> 16) & 0xFF;
    final sb = _sbox[b];
    return (sb << 24) | (_mul2(sb) << 16) | (_mul3(sb) << 8) | sb;
  }

  static int _t2(int s) {
    final b = (s >>> 8) & 0xFF;
    final sb = _sbox[b];
    return (sb << 24) | (sb << 16) | (_mul2(sb) << 8) | _mul3(sb);
  }

  static int _t3(int s) {
    final b = s & 0xFF;
    final sb = _sbox[b];
    return (_mul3(sb) << 24) | (sb << 16) | (sb << 8) | _mul2(sb);
  }

  static int _mul2(int b) => ((b << 1) ^ ((b & 0x80) != 0 ? 0x1B : 0)) & 0xFF;
  static int _mul3(int b) => _mul2(b) ^ b;

  static const List<int> _sbox = [
    0x63,
    0x7c,
    0x77,
    0x7b,
    0xf2,
    0x6b,
    0x6f,
    0xc5,
    0x30,
    0x01,
    0x67,
    0x2b,
    0xfe,
    0xd7,
    0xab,
    0x76,
    0xca,
    0x82,
    0xc9,
    0x7d,
    0xfa,
    0x59,
    0x47,
    0xf0,
    0xad,
    0xd4,
    0xa2,
    0xaf,
    0x9c,
    0xa4,
    0x72,
    0xc0,
    0xb7,
    0xfd,
    0x93,
    0x26,
    0x36,
    0x3f,
    0xf7,
    0xcc,
    0x34,
    0xa5,
    0xe5,
    0xf1,
    0x71,
    0xd8,
    0x31,
    0x15,
    0x04,
    0xc7,
    0x23,
    0xc3,
    0x18,
    0x96,
    0x05,
    0x9a,
    0x07,
    0x12,
    0x80,
    0xe2,
    0xeb,
    0x27,
    0xb2,
    0x75,
    0x09,
    0x83,
    0x2c,
    0x1a,
    0x1b,
    0x6e,
    0x5a,
    0xa0,
    0x52,
    0x3b,
    0xd6,
    0xb3,
    0x29,
    0xe3,
    0x2f,
    0x84,
    0x53,
    0xd1,
    0x00,
    0xed,
    0x20,
    0xfc,
    0xb1,
    0x5b,
    0x6a,
    0xcb,
    0xbe,
    0x39,
    0x4a,
    0x4c,
    0x58,
    0xcf,
    0xd0,
    0xef,
    0xaa,
    0xfb,
    0x43,
    0x4d,
    0x33,
    0x85,
    0x45,
    0xf9,
    0x02,
    0x7f,
    0x50,
    0x3c,
    0x9f,
    0xa8,
    0x51,
    0xa3,
    0x40,
    0x8f,
    0x92,
    0x9d,
    0x38,
    0xf5,
    0xbc,
    0xb6,
    0xda,
    0x21,
    0x10,
    0xff,
    0xf3,
    0xd2,
    0xcd,
    0x0c,
    0x13,
    0xec,
    0x5f,
    0x97,
    0x44,
    0x17,
    0xc4,
    0xa7,
    0x7e,
    0x3d,
    0x64,
    0x5d,
    0x19,
    0x73,
    0x60,
    0x81,
    0x4f,
    0xdc,
    0x22,
    0x2a,
    0x90,
    0x88,
    0x46,
    0xee,
    0xb8,
    0x14,
    0xde,
    0x5e,
    0x0b,
    0xdb,
    0xe0,
    0x32,
    0x3a,
    0x0a,
    0x49,
    0x06,
    0x24,
    0x5e,
    0xc2,
    0xd3,
    0xac,
    0x62,
    0x91,
    0x95,
    0xe4,
    0x79,
    0xe7,
    0xc8,
    0x37,
    0x6d,
    0x8d,
    0xd5,
    0x4e,
    0xa9,
    0x6c,
    0x56,
    0xf4,
    0xea,
    0x65,
    0x7a,
    0xae,
    0x08,
    0xba,
    0x78,
    0x25,
    0x2e,
    0x1c,
    0xa6,
    0xb4,
    0xc6,
    0xe8,
    0xdd,
    0x74,
    0x1f,
    0x4b,
    0xbd,
    0x8b,
    0x8a,
    0x70,
    0x3e,
    0xb5,
    0x66,
    0x48,
    0x03,
    0xf6,
    0x0e,
    0x61,
    0x35,
    0x57,
    0xb9,
    0x86,
    0xc1,
    0x1d,
    0x9e,
    0xe1,
    0xf8,
    0x98,
    0x11,
    0x69,
    0xd9,
    0x8e,
    0x94,
    0x9b,
    0x1e,
    0x87,
    0xe9,
    0xce,
    0x55,
    0x28,
    0xdf,
    0x8c,
    0xa1,
    0x89,
    0x0d,
    0xbf,
    0xe6,
    0x42,
    0x68,
    0x41,
    0x99,
    0x2d,
    0x0f,
    0xb0,
    0x54,
    0xbb,
    0x16,
  ];
}
