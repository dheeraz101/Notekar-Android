import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUpdateInfo {
  final String version;
  final String body;
  final DateTime? date;
  final bool isSecurity;
  final bool isImportant;
  final String type;

  AppUpdateInfo({
    required this.version,
    required this.body,
    this.date,
    required this.isSecurity,
    required this.isImportant,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'body': body,
    'date': date?.toIso8601String(),
    'isSecurity': isSecurity,
    'isImportant': isImportant,
    'type': type,
  };

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) => AppUpdateInfo(
    version: json['version'] as String,
    body: json['body'] as String? ?? '',
    date: json['date'] != null
        ? DateTime.tryParse(json['date'] as String)
        : null,
    isSecurity: json['isSecurity'] as bool? ?? false,
    isImportant: json['isImportant'] as bool? ?? false,
    type: json['type'] as String? ?? 'Regular Update',
  );
}

class UpdateService {
  final _logger = AppLogger();
  static const _channel = MethodChannel('notekar/files');

  Future<Map<String, dynamic>?> fetchCurrentVirusTotalInfo({
    bool trackBeta = false,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final trackSuffix = trackBeta ? '-beta' : '';
      final url =
          'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/refs/tags/v$appVersion$trackSuffix/build/app/outputs/flutter-apk/version.json';

      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');
      final response = await request.close();
      if (response.statusCode != 200) {
        // Fallback to release download URL if raw asset is not available
        final releaseUrl =
            'https://github.com/dheeraz101/Notekar-Android/releases/download/v$appVersion$trackSuffix/version.json';
        final relRequest = await client.getUrl(Uri.parse(releaseUrl));
        relRequest.headers.set(
          HttpHeaders.userAgentHeader,
          'NoteKar/$appVersion',
        );
        final relResponse = await relRequest.close();
        if (relResponse.statusCode != 200) {
          return null;
        }
        final bodyText = await relResponse.transform(utf8.decoder).join();
        final data = jsonDecode(bodyText);
        if (data is Map && data.containsKey('virustotal')) {
          final vt = data['virustotal'];
          if (vt is Map) {
            return Map<String, dynamic>.from(vt);
          }
        }
        return null;
      }
      final bodyText = await response.transform(utf8.decoder).join();
      final data = jsonDecode(bodyText);
      if (data is Map && data.containsKey('virustotal')) {
        final vt = data['virustotal'];
        if (vt is Map) {
          return Map<String, dynamic>.from(vt);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<AppUpdateInfo?> fetchLatestVersion({bool trackBeta = false}) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(
        Uri.parse(
          'https://api.github.com/repos/dheeraz101/Notekar-Android/releases?per_page=10',
        ),
      );
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');

      final response = await request.close();
      if (response.statusCode != 200) {
        _logger.warn('Update check failed with status: ${response.statusCode}');
        return null;
      }

      final bodyText = await response.transform(utf8.decoder).join();
      final data = jsonDecode(bodyText);
      if (data is! List || data.isEmpty) return null;

      try {
        final prefs = await SharedPreferences.getInstance();
        for (final item in data) {
          if (item is! Map) continue;
          final tagName = item['tag_name'] as String? ?? '';
          if (tagName.contains(appVersion)) {
            final body = item['body'] as String? ?? '';
            final match = RegExp(
              r'https://www.virustotal.com/gui/file/[0-9a-fA-F]{32,}',
            ).firstMatch(body);
            if (match != null) {
              final vtUrl = match.group(0);
              if (vtUrl != null) {
                await prefs.setString('notekar.current_virustotal_url', vtUrl);
              }
            }
          }
        }
      } catch (_) {}

      Map? targetRelease;
      for (final item in data) {
        if (item is! Map) continue;
        final isPrerelease = item['prerelease'] as bool? ?? false;
        if (trackBeta) {
          targetRelease = item;
          break;
        } else {
          if (!isPrerelease) {
            targetRelease = item;
            break;
          }
        }
      }

      if (targetRelease == null) return null;

      final tag =
          (targetRelease['tag_name'] as String?) ??
          (targetRelease['name'] as String?);
      final version = tag?.replaceFirst(RegExp(r'^[vV]'), '').trim();
      if (version == null) return null;

      final body = (targetRelease['body'] as String?) ?? '';
      final publishedAtStr = targetRelease['published_at'] as String?;
      final date = publishedAtStr != null
          ? DateTime.tryParse(publishedAtStr)
          : null;

      // Parse version parts to classify update type dynamically
      final versionParts = version
          .split(RegExp(r'[^0-9]+'))
          .where((p) => p.isNotEmpty)
          .map(int.parse)
          .toList();

      bool isSecurityUpdate = false;
      bool isFeatureUpdate = false;
      bool isBetaUpdate =
          version.toLowerCase().contains('beta') ||
          (tag?.toLowerCase().contains('beta') ?? false);

      if (!isBetaUpdate && versionParts.length >= 3) {
        final minor = versionParts[1];
        final patch = versionParts[2];
        if (minor == 0 && patch == 0) {
          isFeatureUpdate = true;
        } else if (minor > 0 && patch == 0) {
          isSecurityUpdate = true;
        } else if (patch > 0) {
          isBetaUpdate = true;
        }
      }

      final isSecurity =
          isSecurityUpdate ||
          body.toLowerCase().contains('security') ||
          body.toLowerCase().contains('cve');
      final isImportant = isSecurity || isFeatureUpdate;

      final type = isSecurity
          ? 'Security Update'
          : (isBetaUpdate ? 'Beta Update' : 'Feature Update');

      _logger.info(
        'Latest version fetched (${trackBeta ? "Beta" : "Stable"}): $version ($type)',
      );
      return AppUpdateInfo(
        version: version,
        body: body,
        date: date,
        isSecurity: isSecurity,
        isImportant: isImportant,
        type: type,
      );
    } catch (e, stack) {
      _logger.error('Failed to fetch latest release', e, stack);
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<List<Map<String, dynamic>>?> fetchRecentCommits() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(
        Uri.parse(
          'https://api.github.com/repos/dheeraz101/Notekar-Android/commits?per_page=10',
        ),
      );
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');

      final response = await request.close();
      if (response.statusCode != 200) {
        _logger.warn('Failed to fetch commits: ${response.statusCode}');
        return null;
      }

      final bodyText = await response.transform(utf8.decoder).join();
      final data = jsonDecode(bodyText);
      if (data is! List) return null;

      final List<Map<String, dynamic>> commits = [];
      for (final item in data) {
        if (item is! Map) continue;
        final commit = item['commit'] as Map?;
        if (commit == null) continue;
        final message = commit['message'] as String? ?? '';
        final author = commit['author'] as Map?;
        final dateStr = author?['date'] as String?;
        final authorName = author?['name'] as String? ?? 'Anonymous';
        final sha = item['sha'] as String? ?? '';

        commits.add({
          'sha': sha,
          'message': message,
          'author': authorName,
          'date': dateStr != null ? DateTime.tryParse(dateStr) : null,
        });
      }
      return commits;
    } catch (e, stack) {
      _logger.error('Failed to fetch commits', e, stack);
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<String?> downloadApk(
    String version,
    void Function(double progress) onProgress,
  ) async {
    final cacheDir = await _channel.invokeMethod<String>('appCacheDir');
    if (cacheDir == null) return null;

    final url =
        'https://github.com/dheeraz101/Notekar-Android/releases/download/v$version/notekar-$version-universal.apk';
    final savePath = '$cacheDir/notekar-$version-universal.apk';

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');

      final response = await request.close();
      if (response.statusCode != 200) {
        _logger.warn('Download APK failed: HTTP ${response.statusCode}');
        return null;
      }

      final contentLength = response.contentLength;
      if (contentLength <= 0) {
        _logger.warn('Download APK failed: Invalid content length');
        return null;
      }

      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      final sink = file.openWrite();
      var downloadedBytes = 0;

      await for (final chunk in response) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        final progress = downloadedBytes / contentLength;
        onProgress(progress);
      }
      await sink.close();
      _logger.info('APK downloaded successfully to: $savePath');
      return savePath;
    } catch (e, stack) {
      _logger.error('Failed to download APK file', e, stack);
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<bool> verifyApkHash(String version, String apkFilePath) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final url =
          'https://github.com/dheeraz101/Notekar-Android/releases/download/v$version/sha256.txt';
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');

      final response = await request.close();
      if (response.statusCode != 200) return false;

      final manifestText = await response.transform(utf8.decoder).join();
      final localHash = await _channel.invokeMethod<String>('getFileSha256', {
        'filePath': apkFilePath,
      });
      if (localHash == null || localHash.isEmpty) return false;

      // Extract hash of universal apk from manifest text
      final lines = manifestText.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          final hash = parts[0].trim().toLowerCase();
          final filename = parts[1].trim();
          if (filename.contains('universal') &&
              hash == localHash.toLowerCase()) {
            _logger.info('Checksum matches target: $hash');
            return true;
          }
        }
      }
      _logger.warn('Checksum mismatch: Local $localHash');
      return false;
    } catch (e, stack) {
      _logger.error('Failed to verify APK hash', e, stack);
      return false;
    } finally {
      client.close(force: true);
    }
  }

  Future<String?> getCachedApkPath(String version) async {
    try {
      final cacheDir = await _channel.invokeMethod<String>('appCacheDir');
      if (cacheDir == null) return null;
      final file = File('$cacheDir/notekar-$version-universal.apk');
      if (await file.exists()) {
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearCachedBuilds() async {
    try {
      final cacheDir = await _channel.invokeMethod<String>('appCacheDir');
      if (cacheDir == null) return;
      final dir = Directory(cacheDir);
      if (await dir.exists()) {
        final files = dir.listSync();
        for (final entity in files) {
          if (entity is File && entity.path.endsWith('.apk')) {
            await entity.delete();
            _logger.info('Deleted cached APK: ${entity.path}');
          }
        }
      }
    } catch (e, stack) {
      _logger.error('Failed to clear cached builds', e, stack);
    }
  }

  bool isUpdateAvailable(String latest, String current) {
    return isNewerVersion(latest, current);
  }
}
