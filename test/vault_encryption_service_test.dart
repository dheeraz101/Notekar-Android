import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/services/vault_encryption_service.dart';

void main() {
  group('VaultEncryptionService (PBKDF2 + AES-GCM)', () {
    test('Round-trip encryption and decryption preserves exact plaintext', () {
      final service = VaultEncryptionService.instance;
      const originalText =
          'Hello NoteKar Sovereign Vault! Confidential Moments #deepwork';
      const password = 'SuperSecretMasterPassword123!';

      // Use fast iterations for test speed (e.g. 500)
      final encryptedVault = service.encryptVault(
        plaintext: originalText,
        password: password,
        iterations: 500,
      );

      expect(service.isVaultContent(encryptedVault), isTrue);

      final decrypted = service.decryptVault(
        vaultContent: encryptedVault,
        password: password,
      );

      expect(decrypted, equals(originalText));
    });

    test('Complex JSON backup round-trip matches original data', () {
      final service = VaultEncryptionService.instance;
      final sampleBackup = {
        'version': 1,
        'app': 'NoteKar',
        'entries': [
          {
            'id': 1,
            'note': 'First encrypted thought',
            'timestamp': 1729814400000,
          },
          {
            'id': 2,
            'note': 'Second thought with tags #zen #focus',
            'timestamp': 1729818000000,
          },
        ],
        'settings': {'theme': 'dark', 'accentColor': 'sapphire'},
      };
      final jsonString = jsonEncode(sampleBackup);
      const password = 'VaultPassword!987';

      final encrypted = service.encryptVault(
        plaintext: jsonString,
        password: password,
        iterations: 500,
      );

      final decrypted = service.decryptVault(
        vaultContent: encrypted,
        password: password,
      );

      expect(jsonDecode(decrypted), equals(sampleBackup));
    });

    test('Incorrect password throws VaultAuthException', () {
      final service = VaultEncryptionService.instance;
      const text = 'Top secret journal entry';
      const correctPass = 'CorrectPassword';
      const wrongPass = 'WrongPassword';

      final encrypted = service.encryptVault(
        plaintext: text,
        password: correctPass,
        iterations: 500,
      );

      expect(
        () =>
            service.decryptVault(vaultContent: encrypted, password: wrongPass),
        throwsA(isA<VaultAuthException>()),
      );
    });

    test(
      'Tampered ciphertext fails authentication with VaultAuthException',
      () {
        final service = VaultEncryptionService.instance;
        const text = 'Sovereign private financial note';
        const password = 'P@sswordValid123';

        final encrypted = service.encryptVault(
          plaintext: text,
          password: password,
          iterations: 500,
        );

        final parsed = jsonDecode(encrypted) as Map<String, dynamic>;
        final rawCipherBytes = base64Decode(parsed['ciphertext'] as String);
        // Flip a bit in ciphertext
        rawCipherBytes[0] ^= 0x01;
        parsed['ciphertext'] = base64Encode(rawCipherBytes);
        final tamperedVault = jsonEncode(parsed);

        expect(
          () => service.decryptVault(
            vaultContent: tamperedVault,
            password: password,
          ),
          throwsA(isA<VaultAuthException>()),
        );
      },
    );

    test('Tampered auth tag fails authentication with VaultAuthException', () {
      final service = VaultEncryptionService.instance;
      const text = 'Secret message';
      const password = 'MyPassword';

      final encrypted = service.encryptVault(
        plaintext: text,
        password: password,
        iterations: 500,
      );

      final parsed = jsonDecode(encrypted) as Map<String, dynamic>;
      final cipherMeta = parsed['cipher'] as Map<String, dynamic>;
      final tagBytes = base64Decode(cipherMeta['tag'] as String);
      tagBytes[0] ^= 0xFF;
      cipherMeta['tag'] = base64Encode(tagBytes);
      final tamperedVault = jsonEncode(parsed);

      expect(
        () => service.decryptVault(
          vaultContent: tamperedVault,
          password: password,
        ),
        throwsA(isA<VaultAuthException>()),
      );
    });

    test('PBKDF2 derives deterministic keys for same salt and password', () {
      final service = VaultEncryptionService.instance;
      final salt = Uint8List.fromList(List.generate(16, (i) => i));
      const password = 'ConsistentPassword';

      final key1 = service.deriveKey(
        password: password,
        salt: salt,
        iterations: 200,
      );
      final key2 = service.deriveKey(
        password: password,
        salt: salt,
        iterations: 200,
      );

      expect(key1, equals(key2));
      expect(key1.length, equals(32));
    });

    test('Empty plaintext encrypts and decrypts correctly', () {
      final service = VaultEncryptionService.instance;
      const emptyText = '';
      const password = 'NonEmptyPassword123';

      final encrypted = service.encryptVault(
        plaintext: emptyText,
        password: password,
        iterations: 100,
      );

      final decrypted = service.decryptVault(
        vaultContent: encrypted,
        password: password,
      );

      expect(decrypted, equals(emptyText));
    });

    test(
      'Unicode, multi-byte characters and emoji passwords round-trip cleanly',
      () {
        final service = VaultEncryptionService.instance;
        const unicodeText = 'नोटकार सुरक्षित वॉल्ट 🚀 🔒 🌟 日本語テキスト';
        const unicodePass = 'वॉल्ट-पासवर्ड-🔐-1234';

        final encrypted = service.encryptVault(
          plaintext: unicodeText,
          password: unicodePass,
          iterations: 100,
        );

        final decrypted = service.decryptVault(
          vaultContent: encrypted,
          password: unicodePass,
        );

        expect(decrypted, equals(unicodeText));
      },
    );

    test('Empty password in encryptVault throws ArgumentError', () {
      final service = VaultEncryptionService.instance;
      expect(
        () => service.encryptVault(plaintext: 'Secret', password: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Empty password in decryptVault throws VaultAuthException', () {
      final service = VaultEncryptionService.instance;
      expect(
        () => service.decryptVault(vaultContent: '{}', password: ''),
        throwsA(isA<VaultAuthException>()),
      );
    });

    test('Corrupted base64 metadata throws VaultAuthException', () {
      final service = VaultEncryptionService.instance;
      final encrypted = service.encryptVault(
        plaintext: 'Valid secret',
        password: 'Password123',
        iterations: 100,
      );

      final parsed = jsonDecode(encrypted) as Map<String, dynamic>;
      parsed['ciphertext'] = '!!!NOT_VALID_BASE64@@@';
      final invalidB64Vault = jsonEncode(parsed);

      expect(
        () => service.decryptVault(
          vaultContent: invalidB64Vault,
          password: 'Password123',
        ),
        throwsA(isA<VaultAuthException>()),
      );
    });

    test('Iterations < 1 in vault metadata throws VaultAuthException', () {
      final service = VaultEncryptionService.instance;
      final encrypted = service.encryptVault(
        plaintext: 'Valid secret',
        password: 'Password123',
        iterations: 100,
      );

      final parsed = jsonDecode(encrypted) as Map<String, dynamic>;
      final kdf = parsed['kdf'] as Map<String, dynamic>;
      kdf['iterations'] = 0;
      final zeroIterVault = jsonEncode(parsed);

      expect(
        () => service.decryptVault(
          vaultContent: zeroIterVault,
          password: 'Password123',
        ),
        throwsA(isA<VaultAuthException>()),
      );
    });

    test('Malformed JSON throws VaultAuthException', () {
      final service = VaultEncryptionService.instance;
      expect(
        () => service.decryptVault(
          vaultContent: 'NOT_A_JSON_FILE',
          password: 'Password123',
        ),
        throwsA(isA<VaultAuthException>()),
      );
    });
  });
}
