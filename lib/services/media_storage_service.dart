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

    _cachedRootPath = Directory.systemTemp.path;
    return _cachedRootPath!;
  }

  /// Resolves a stored relative or absolute path to a concrete [File].
  Future<File> resolveFile(String? relativeOrAbsolutePath) async {
    if (relativeOrAbsolutePath == null || relativeOrAbsolutePath.isEmpty) {
      return File('');
    }

    final file = File(relativeOrAbsolutePath);
    if (file.isAbsolute && file.existsSync()) {
      return file;
    }

    final mediaDir = await getMediaDirectory();
    // Normalize path separators and remove redundant prefix
    var clean = relativeOrAbsolutePath.replaceAll('\\', '/');
    if (clean.startsWith('notekar_media/')) {
      clean = clean.substring('notekar_media/'.length);
    }
    if (clean.startsWith('/')) {
      clean = clean.substring(1);
    }

    return File('${mediaDir.path}/$clean');
  }

  /// Synchronously resolve if root path has already been cached.
  File resolveFileSync(String? relativeOrAbsolutePath) {
    if (relativeOrAbsolutePath == null || relativeOrAbsolutePath.isEmpty) {
      return File('');
    }
    final file = File(relativeOrAbsolutePath);
    if (file.isAbsolute && file.existsSync()) {
      return file;
    }
    final root = testRootPath ?? _cachedRootPath ?? Directory.systemTemp.path;
    var clean = relativeOrAbsolutePath.replaceAll('\\', '/');
    if (clean.startsWith('notekar_media/')) {
      clean = clean.substring('notekar_media/'.length);
    }
    if (clean.startsWith('/')) {
      clean = clean.substring(1);
    }
    return File('$root/notekar_media/$clean');
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
    if (moment.imagePath != null && moment.imagePath!.isNotEmpty) {
      await deleteMediaFile(moment.imagePath);
    }
    if (moment.voicePath != null && moment.voicePath!.isNotEmpty) {
      await deleteMediaFile(moment.voicePath);
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
