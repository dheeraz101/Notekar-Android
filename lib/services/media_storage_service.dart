import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_logger.dart';

/// Centralized media asset management service for NoteKar.
///
/// Stores images and voice notes in the sandboxed `notekar_media` directory.
/// Keeps database records invariant across Android sandbox path shifts by
/// storing relative paths (`images/...`, `voice/...`) and resolving them dynamically.
class MediaStorageService {
  static final MediaStorageService _instance = MediaStorageService._internal();
  factory MediaStorageService() => _instance;
  static MediaStorageService get instance => _instance;
  MediaStorageService._internal();

  final _logger = AppLogger();
  static const MethodChannel _fileChannel = MethodChannel('notekar/files');
  String? _cachedRootPath;

  /// Custom root override primarily used for test mocking.
  String? testRootPath;

  /// Retrieves the root media directory (`<appDataDir>/notekar_media`).
  Future<Directory> getMediaDirectory() async {
    final root = await _getRootPath();
    final dir = Directory('$root/notekar_media');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> getImagesDirectory() async {
    final mediaDir = await getMediaDirectory();
    final imagesDir = Directory('${mediaDir.path}/images');
    if (!imagesDir.existsSync()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  Future<Directory> getVoiceDirectory() async {
    final mediaDir = await getMediaDirectory();
    final voiceDir = Directory('${mediaDir.path}/voice');
    if (!voiceDir.existsSync()) {
      await voiceDir.create(recursive: true);
    }
    return voiceDir;
  }

  /// Eagerly initializes persistent storage paths on app launch.
  Future<void> initialize() async {
    try {
      final appData = await _fileChannel.invokeMethod<String>('appDataDir');
      if (appData != null && appData.isNotEmpty) {
        _cachedRootPath = appData;
      }
    } catch (e) {
      _logger.warn('Early appDataDir lookup encountered fallback: $e');
    }
  }

  Future<String> _getRootPath() async {
    if (testRootPath != null) return testRootPath!;
    if (_cachedRootPath != null) return _cachedRootPath!;

    try {
      final appData = await _fileChannel.invokeMethod<String>('appDataDir');
      if (appData != null && appData.isNotEmpty) {
        _cachedRootPath = appData;
        return appData;
      }
    } catch (_) {}

    // Notice: Do NOT cache systemTemp permanently into _cachedRootPath so future
    // calls can retrieve the genuine persistent files directory once channels bind.
    return Directory.systemTemp.path;
  }

  /// Resolves a stored relative or absolute path to a concrete [File].
  ///
  /// Searches primary persistent storage first, then fallback directories
  /// (temporary cache, legacy sandbox shifts, and filename matches).
  /// If a valid asset is found in an alternate or temporary location, it is
  /// automatically migrated (copied) to the persistent storage directory.
  Future<File> resolveFile(String? relativeOrAbsolutePath) async {
    if (relativeOrAbsolutePath == null || relativeOrAbsolutePath.isEmpty) {
      return File('');
    }

    final originalFile = File(relativeOrAbsolutePath);
    final mediaDir = await getMediaDirectory();

    // 1. If absolute path exists
    if (originalFile.isAbsolute && originalFile.existsSync()) {
      // If residing in a volatile temp/cache directory, auto-migrate to persistent
      final isTemp =
          originalFile.path.contains('/cache/') ||
          originalFile.path.contains('\\cache\\') ||
          originalFile.path.startsWith(Directory.systemTemp.path);
      if (isTemp) {
        try {
          final fileName = originalFile.path.split(RegExp(r'[/\\]')).last;
          final target = File('${mediaDir.path}/images/$fileName');
          if (!target.existsSync()) {
            await target.parent.create(recursive: true);
            await originalFile.copy(target.path);
            _logger.info(
              'Auto-migrated temp image to persistent: ${target.path}',
            );
            return target;
          }
        } catch (e) {
          _logger.warn('Failed auto-migrating absolute temp file: $e');
        }
      }
      return originalFile;
    }

    // Normalize path separators and remove redundant prefixes
    var clean = relativeOrAbsolutePath.replaceAll('\\', '/');
    if (clean.startsWith('notekar_media/')) {
      clean = clean.substring('notekar_media/'.length);
    }
    if (clean.startsWith('/')) {
      clean = clean.substring(1);
    }

    // 2. Primary target file in persistent media directory
    final primaryFile = File('${mediaDir.path}/$clean');
    if (primaryFile.existsSync()) {
      return primaryFile;
    }

    // 3. Fallback: Search alternative directories & self-heal
    final fileName = clean.split('/').last;
    final candidates = <File>[
      File('${Directory.systemTemp.path}/notekar_media/$clean'),
      File('${Directory.systemTemp.path}/notekar_media/images/$fileName'),
      File('${Directory.systemTemp.path}/$fileName'),
      File('${Directory.systemTemp.path}/images/$fileName'),
      File('/data/user/0/app.notekar.notekar/cache/notekar_media/$clean'),
      File('/data/user/0/app.notekar.notekar/files/notekar_media/$clean'),
      File('/data/data/app.notekar.notekar/cache/notekar_media/$clean'),
      File('/data/data/app.notekar.notekar/files/notekar_media/$clean'),
      // Also check if stored with 'images/' prefix in media root
      File('${mediaDir.path}/images/$fileName'),
    ];

    for (final candidate in candidates) {
      if (candidate.existsSync()) {
        try {
          // Auto-migrate to the expected primary location for permanent durability
          await primaryFile.parent.create(recursive: true);
          await candidate.copy(primaryFile.path);
          _logger.info(
            'Self-healed & auto-migrated media asset from ${candidate.path} to ${primaryFile.path}',
          );
          return primaryFile;
        } catch (e) {
          _logger.warn('Auto-migration copy failed for ${candidate.path}: $e');
          return candidate;
        }
      }
    }

    return primaryFile;
  }

  /// Synchronously resolve if root path has already been cached.
  /// Includes multi-path existence fallback.
  File resolveFileSync(String? relativeOrAbsolutePath) {
    if (relativeOrAbsolutePath == null || relativeOrAbsolutePath.isEmpty) {
      return File('');
    }
    final originalFile = File(relativeOrAbsolutePath);
    if (originalFile.isAbsolute && originalFile.existsSync()) {
      return originalFile;
    }
    final root = testRootPath ?? _cachedRootPath ?? Directory.systemTemp.path;
    var clean = relativeOrAbsolutePath.replaceAll('\\', '/');
    if (clean.startsWith('notekar_media/')) {
      clean = clean.substring('notekar_media/'.length);
    }
    if (clean.startsWith('/')) {
      clean = clean.substring(1);
    }

    final primary = File('$root/notekar_media/$clean');
    if (primary.existsSync()) {
      return primary;
    }

    final fileName = clean.split('/').last;
    final fallbackCandidates = [
      File('${Directory.systemTemp.path}/notekar_media/$clean'),
      File('${Directory.systemTemp.path}/notekar_media/images/$fileName'),
      File('${Directory.systemTemp.path}/$fileName'),
      File('$root/notekar_media/images/$fileName'),
    ];

    for (final fallback in fallbackCandidates) {
      if (fallback.existsSync()) {
        return fallback;
      }
    }

    return primary;
  }

  /// Copies an image file/XFile/bytes to internal storage and returns the relative path.
  Future<String> saveImage({
    XFile? xFile,
    File? file,
    Uint8List? bytes,
    String extension = 'jpg',
  }) async {
    try {
      final imagesDir = await getImagesDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;
      final rand = math.Random().nextInt(999999).toString().padLeft(6, '0');
      final fileName = 'img_${now}_$rand.$extension';
      final targetFile = File('${imagesDir.path}/$fileName');

      if (bytes != null) {
        await targetFile.writeAsBytes(bytes);
      } else if (xFile != null) {
        final data = await xFile.readAsBytes();
        await targetFile.writeAsBytes(data);
      } else if (file != null) {
        await file.copy(targetFile.path);
      } else {
        throw ArgumentError('One of xFile, file, or bytes must be provided.');
      }

      _logger.info('Saved image to ${targetFile.path}');
      return 'images/$fileName';
    } catch (e, stack) {
      _logger.error('Failed to save image asset', e, stack);
      rethrow;
    }
  }

  /// Saves a recorded audio file to internal storage and returns the relative path.
  Future<String> saveVoiceNote({
    File? sourceFile,
    Uint8List? bytes,
    String? sourcePath,
    String extension = 'm4a',
  }) async {
    try {
      final voiceDir = await getVoiceDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;
      final rand = math.Random().nextInt(999999).toString().padLeft(6, '0');
      final fileName = 'voice_${now}_$rand.$extension';
      final targetFile = File('${voiceDir.path}/$fileName');

      if (bytes != null) {
        await targetFile.writeAsBytes(bytes);
      } else if (sourceFile != null) {
        await sourceFile.copy(targetFile.path);
      } else if (sourcePath != null && sourcePath.isNotEmpty) {
        final src = File(sourcePath);
        if (src.existsSync()) {
          await src.copy(targetFile.path);
        } else {
          throw FileNotFoundException(
            'Source audio file not found: $sourcePath',
          );
        }
      } else {
        throw ArgumentError(
          'One of sourceFile, sourcePath, or bytes must be provided.',
        );
      }

      _logger.info('Saved voice note to ${targetFile.path}');
      return 'voice/$fileName';
    } catch (e, stack) {
      _logger.error('Failed to save voice note asset', e, stack);
      rethrow;
    }
  }

  /// Deletes associated media files when a moment is permanently purged.
  Future<void> deleteMediaForMoment(Moment moment) async {
    for (final img in moment.imagePaths) {
      await deleteMediaFile(img);
    }
    for (final voice in moment.voicePaths) {
      await deleteMediaFile(voice);
    }
  }

  /// Unlinks and deletes a media file from disk.
  Future<bool> deleteMediaFile(String? relativeOrAbsolutePath) async {
    if (relativeOrAbsolutePath == null || relativeOrAbsolutePath.isEmpty) {
      return false;
    }
    try {
      final file = await resolveFile(relativeOrAbsolutePath);
      if (file.existsSync()) {
        await file.delete();
        _logger.info('Deleted media file: ${file.path}');
        return true;
      }
    } catch (e, stack) {
      _logger.warn(
        'Failed to delete media file $relativeOrAbsolutePath',
        e,
        stack,
      );
    }
    return false;
  }

  /// Computes the total disk space consumed by user media attachments.
  Future<int> getMediaSizeInBytes() async {
    try {
      final mediaDir = await getMediaDirectory();
      if (!mediaDir.existsSync()) return 0;
      int total = 0;
      await for (final file in mediaDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (file is File) {
          total += await file.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Formats byte count into human-readable metric string.
  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (math.log(bytes) / math.log(1024)).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    final num = bytes / math.pow(1024, i);
    return '${num.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  /// Deletes all media files on factory reset.
  Future<void> clearAllMedia() async {
    try {
      final mediaDir = await getMediaDirectory();
      if (mediaDir.existsSync()) {
        await mediaDir.delete(recursive: true);
        await mediaDir.create(recursive: true);
        _logger.info('Cleared all media storage');
      }
    } catch (e, stack) {
      _logger.error('Failed to clear media storage', e, stack);
    }
  }
}

class FileNotFoundException implements Exception {
  final String message;
  const FileNotFoundException(this.message);
  @override
  String toString() => 'FileNotFoundException: $message';
}
