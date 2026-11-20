import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/network_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUpdateInfo {
  final String version;
  final String tagName;
  final String body;
  final DateTime? date;
  final bool isSecurity;
  final bool isImportant;
  final String type;

  AppUpdateInfo({
    required this.version,
    required this.tagName,
    required this.body,
    this.date,
    required this.isSecurity,
    required this.isImportant,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'tagName': tagName,
    'body': body,
    'date': date?.toIso8601String(),
    'isSecurity': isSecurity,
    'isImportant': isImportant,
    'type': type,
  };

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) => AppUpdateInfo(
    version: json['version'] as String,
    tagName: json['tagName'] as String? ?? 'v${json['version']}',
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

  HttpClient _createHttpClient({
    Duration timeout = const Duration(seconds: 10),
  }) {
    return HttpClient()..connectionTimeout = timeout;
  }

  Future<Map<String, dynamic>?> fetchCurrentVirusTotalInfo({
    bool trackBeta = false,
  }) async {
    final client = _createHttpClient(timeout: const Duration(seconds: 10));
    try {
      final trackSuffix = trackBeta ? '-beta' : '';
      final url =
          'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/refs/tags/v$appVersion$trackSuffix/build/app/outputs/flutter-apk/version.json';

      final request = await client.getUrl(Uri.parse(url));
      request.maxRedirects = 10;
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');
      final response = await request.close();

      // Log the main request
      await NetworkLogger.log(
        url: url,
        method: 'GET',
        statusCode: response.statusCode,
        purpose: 'VirusTotal Info Sync',
        size: response.contentLength > 0
            ? '${(response.contentLength / 1024).toStringAsFixed(2)} KB'
            : 'Unknown',
      );

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

        // Log the fallback request
        await NetworkLogger.log(
          url: releaseUrl,
          method: 'GET',
          statusCode: relResponse.statusCode,
          purpose: 'VirusTotal Info Sync (Fallback)',
          size: relResponse.contentLength > 0
              ? '${(relResponse.contentLength / 1024).toStringAsFixed(2)} KB'
              : 'Unknown',
        );

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

  Future<AppUpdateInfo?> fetchLatestVersion({
    bool trackBeta = false,
    String? channel,
  }) async {
    final effectiveChannel = channel ?? (trackBeta ? 'beta' : 'stable');
    final client = _createHttpClient(timeout: const Duration(seconds: 10));
    try {
      final request = await client.getUrl(
        Uri.parse(
          'https://api.github.com/repos/dheeraz101/Notekar-Android/releases?per_page=10',
        ),
      );
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');

      final response = await request.close();
      await NetworkLogger.log(
        url:
            'https://api.github.com/repos/dheeraz101/Notekar-Android/releases?per_page=10',
        method: 'GET',
        statusCode: response.statusCode,
        purpose: 'Check For App Updates',
        size: response.contentLength > 0
            ? '${(response.contentLength / 1024).toStringAsFixed(2)} KB'
            : 'Unknown',
      );

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

      Map<dynamic, dynamic>? targetRelease;
      for (final item in data) {
        if (item is! Map) continue;
        final isPrerelease = item['prerelease'] as bool? ?? false;
        final tagName =
            ((item['tag_name'] as String?) ?? (item['name'] as String?) ?? '')
                .toLowerCase();
        final isExp =
            tagName.contains(RegExp(r'e\d+')) || tagName.contains('experiment');

        final bool isEligible;
        if (effectiveChannel == 'experiment') {
          // Experiment channel receives ALL updates across all tracks: Stable, Priority, Beta, and Experiment!
          isEligible = true;
        } else if (effectiveChannel == 'beta') {
          // Beta accepts beta, priority, or stable releases, but skips unvetted experiment-only builds
          isEligible = !isExp;
        } else {
          // Stable / Priority: skips all prereleases and experimental builds
          isEligible = !isPrerelease && !isExp && !tagName.contains('beta');
        }

        if (!isEligible) continue;

        if (targetRelease == null) {
          targetRelease = item;
        } else {
          // If multiple eligible releases exist in feed, select the highest version
          final itemTag =
              (item['tag_name'] as String?) ?? (item['name'] as String?) ?? '';
          final targetTag =
              (targetRelease['tag_name'] as String?) ??
              (targetRelease['name'] as String?) ??
              '';
          final itemVer = itemTag.replaceFirst(RegExp(r'^[vV]'), '').trim();
          final targetVer = targetTag.replaceFirst(RegExp(r'^[vV]'), '').trim();
          if (isNewerVersion(itemVer, targetVer)) {
            targetRelease = item;
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
      final isExperimentUpdate =
          version.contains(RegExp(r'E\d+')) ||
          (tag?.toLowerCase().contains('experiment') ?? false);
      final isBetaUpdate =
          !isExperimentUpdate &&
          (version.toLowerCase().contains('beta') ||
              (tag?.toLowerCase().contains('beta') ?? false));

      if (!isBetaUpdate && !isExperimentUpdate && versionParts.length >= 3) {
        final minor = versionParts[1];
        final patch = versionParts[2];
        if (minor == 0 && patch == 0) {
          isFeatureUpdate = true;
        } else if (minor > 0 && patch == 0) {
          isSecurityUpdate = true;
        } else if (patch > 0) {
          isFeatureUpdate = true;
        }
      }

      final isSecurity =
          !isBetaUpdate &&
          !isExperimentUpdate &&
          (isSecurityUpdate ||
              body.toLowerCase().contains('critical security') ||
              body.toLowerCase().contains('cve-'));
      final isImportant = isSecurity || isFeatureUpdate;

      final type = isExperimentUpdate
          ? 'ER (Experimental Release)'
          : (isBetaUpdate
                ? 'BR (Beta Release)'
                : (isSecurity ? 'SR (Security Release)' : 'SB (Stable Build)'));

      _logger.info(
        'Latest version fetched (Channel: $effectiveChannel): $version ($type)',
      );
      return AppUpdateInfo(
        version: version,
        tagName: tag ?? 'v$version',
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
    final client = _createHttpClient(timeout: const Duration(seconds: 10));
    try {
      final request = await client.getUrl(
        Uri.parse(
          'https://api.github.com/repos/dheeraz101/Notekar-Android/commits?per_page=100',
        ),
      );
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');

      final response = await request.close();
      await NetworkLogger.log(
        url:
            'https://api.github.com/repos/dheeraz101/Notekar-Android/commits?per_page=100',
        method: 'GET',
        statusCode: response.statusCode,
        purpose: 'Fetch Recent Commit Logs',
        size: response.contentLength > 0
            ? '${(response.contentLength / 1024).toStringAsFixed(2)} KB'
            : 'Unknown',
      );

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

  static String resolveDeviceSuffix(List<String> abis) {
    if (abis.isEmpty) return 'universal';
    final lowerAbis = abis.map((a) => a.toLowerCase()).toList();
    if (lowerAbis.any((a) => a.contains('arm64') || a.contains('aarch64'))) {
      return 'arm64-v8a';
    } else if (lowerAbis.any(
      (a) => a.contains('armeabi') || a.contains('armv7') || a.contains('arm'),
    )) {
      return 'armeabi-v7a';
    } else if (lowerAbis.any((a) => a.contains('x86_64'))) {
      return 'x86_64';
    } else if (lowerAbis.any((a) => a.contains('x86'))) {
      return 'x86';
    }
    return 'universal';
  }

  Future<String> _getDeviceSuffix() async {
    List<String> abis = AdaptiveEngine().supportedAbis;
    if (abis.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        abis = prefs.getStringList('device_supported_abis') ?? [];
      } catch (_) {}
    }
    if (abis.isEmpty && Platform.isAndroid) {
      try {
        final info = await DeviceInfoPlugin().androidInfo;
        abis = info.supportedAbis;
      } catch (_) {}
    }
    return resolveDeviceSuffix(abis);
  }

  /// Generates ordered candidate APK asset filenames for a version and architecture suffix.
  /// Checks both the full release version (e.g. 7.5.10-E1) and clean version (7.5.10),
  /// prioritizing the ABI-specific APK followed by the universal APK fallback.
  List<String> getCandidateApkFilenames(String version, String suffix) {
    final cleanVersion = version.split('-').first;
    final candidates = <String>[];
    void add(String name) {
      if (!candidates.contains(name)) candidates.add(name);
    }

    add('notekar-$version-$suffix.apk');
    add('notekar-$cleanVersion-$suffix.apk');
    if (suffix != 'universal') {
      add('notekar-$version-universal.apk');
      add('notekar-$cleanVersion-universal.apk');
    }
    return candidates;
  }

  Future<String?> downloadApk(
    AppUpdateInfo info,
    void Function(double progress) onProgress,
  ) async {
    final cacheDir = await _channel.invokeMethod<String>('appCacheDir');
    if (cacheDir == null) return null;

    final suffix = await _getDeviceSuffix();
    final candidates = getCandidateApkFilenames(info.version, suffix);
    final client = _createHttpClient(timeout: const Duration(seconds: 20));

    try {
      HttpClientResponse? activeResponse;
      String? activeUrl;
      String? activeSavePath;

      for (final candidate in candidates) {
        final candidateUrl =
            'https://github.com/dheeraz101/Notekar-Android/releases/download/${info.tagName}/$candidate';
        final candidateSavePath = '$cacheDir/$candidate';

        try {
          final testRequest = await client.getUrl(Uri.parse(candidateUrl));
          testRequest.maxRedirects = 10;
          testRequest.headers.set(
            HttpHeaders.userAgentHeader,
            'NoteKar/$appVersion',
          );
          final response = await testRequest.close();
          if (response.statusCode == 200 || response.statusCode == 206) {
            activeResponse = response;
            activeUrl = candidateUrl;
            activeSavePath = candidateSavePath;
            break;
          }
          await response.drain();
        } catch (_) {}
      }

      if (activeResponse == null ||
          activeUrl == null ||
          activeSavePath == null) {
        _logger.warn(
          'No accessible APK release asset found for tag ${info.tagName} (version ${info.version})',
        );
        return null;
      }

      await NetworkLogger.log(
        url: activeUrl,
        method: 'GET',
        statusCode: activeResponse.statusCode,
        purpose: 'APK Package Download',
        size: activeResponse.contentLength > 0
            ? '${(activeResponse.contentLength / (1024 * 1024)).toStringAsFixed(2)} MB'
            : 'Unknown',
      );

      final downloadedPath = await _saveResponseStream(
        response: activeResponse,
        savePath: activeSavePath,
        onProgress: onProgress,
      );

      if (downloadedPath != null) {
        _logger.info('APK downloaded successfully to: $downloadedPath');
        return downloadedPath;
      }

      return await _downloadStandard(
        client,
        activeUrl,
        activeSavePath,
        onProgress,
      );
    } catch (e, stack) {
      _logger.error('Failed to download APK file', e, stack);
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<String?> _saveResponseStream({
    required HttpClientResponse response,
    required String savePath,
    required void Function(double progress) onProgress,
  }) async {
    final tempPath = '$savePath.tmp';
    try {
      final contentLength = response.contentLength;
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final sink = tempFile.openWrite();
      var downloadedBytes = 0;

      await for (final chunk in response) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        if (contentLength > 0) {
          onProgress((downloadedBytes / contentLength).clamp(0.0, 1.0));
        } else {
          final estimatedRatio = (downloadedBytes / (20 * 1024 * 1024)).clamp(
            0.0,
            0.95,
          );
          onProgress(estimatedRatio);
        }
      }
      await sink.flush();
      await sink.close();

      final fileLen = await tempFile.length();
      if (fileLen < 1024 * 1024) {
        _logger.warn('Downloaded APK is too small: $fileLen bytes');
        if (await tempFile.exists()) await tempFile.delete();
        return null;
      }

      final finalFile = File(savePath);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await tempFile.rename(savePath);
      onProgress(1.0);
      return savePath;
    } catch (e, stack) {
      _logger.error('Failed saving APK response stream', e, stack);
      try {
        final tf = File(tempPath);
        if (await tf.exists()) await tf.delete();
      } catch (_) {}
      return null;
    }
  }

  Future<String?> _downloadStandard(
    HttpClient client,
    String url,
    String savePath,
    void Function(double progress) onProgress,
  ) async {
    final tempPath = '$savePath.tmp';
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.maxRedirects = 10;
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');

      final response = await request.close();
      if (response.statusCode != 200 && response.statusCode != 206) {
        _logger.warn(
          'Standard download APK failed: HTTP ${response.statusCode}',
        );
        return null;
      }

      return await _saveResponseStream(
        response: response,
        savePath: savePath,
        onProgress: onProgress,
      );
    } catch (e, stack) {
      _logger.error('Standard download failed', e, stack);
      try {
        final tf = File(tempPath);
        if (await tf.exists()) await tf.delete();
      } catch (_) {}
      return null;
    }
  }

  Future<bool> verifyApkHash(AppUpdateInfo info, String apkFilePath) async {
    final client = _createHttpClient(timeout: const Duration(seconds: 12));
    try {
      final localHash = await _channel.invokeMethod<String>('getFileSha256', {
        'filePath': apkFilePath,
      });
      if (localHash == null || localHash.isEmpty) return false;

      final localFilename = apkFilePath
          .split('/')
          .last
          .split('\\')
          .last
          .toLowerCase();
      final cleanVersion = info.version.split('-').first.toLowerCase();
      final fullVersion = info.version.toLowerCase();

      final acceptableNames = <String>{localFilename};
      if (cleanVersion != fullVersion) {
        acceptableNames.add(
          localFilename.replaceAll('-$cleanVersion-', '-$fullVersion-'),
        );
        acceptableNames.add(
          localFilename.replaceAll('-$fullVersion-', '-$cleanVersion-'),
        );
      }

      bool manifestFound = false;

      // 1. Try sha256.txt from release download
      try {
        final url =
            'https://github.com/dheeraz101/Notekar-Android/releases/download/${info.tagName}/sha256.txt';
        final request = await client.getUrl(Uri.parse(url));
        request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');

        final response = await request.close();
        await NetworkLogger.log(
          url: url,
          method: 'GET',
          statusCode: response.statusCode,
          purpose: 'Verify Release Checksum',
          size: response.contentLength > 0
              ? '${(response.contentLength / 1024).toStringAsFixed(2)} KB'
              : 'Unknown',
        );

        if (response.statusCode == 200 || response.statusCode == 206) {
          final manifestText = await response.transform(utf8.decoder).join();
          final lines = manifestText.split('\n');
          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.isEmpty) continue;
            final parts = trimmed.split(RegExp(r'\s+'));
            if (parts.length >= 2) {
              manifestFound = true;
              final hash = parts[0].trim().toLowerCase();
              final filename = parts[1].trim().toLowerCase();
              if (acceptableNames.contains(filename) &&
                  hash == localHash.toLowerCase()) {
                _logger.info('Checksum matches target: $hash for $filename');
                return true;
              }
            }
          }
        }
      } catch (_) {}

      // 2. Fallback to version.json (raw repo or release download)
      for (final versionJsonUrl in [
        'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/refs/tags/${info.tagName}/build/app/outputs/flutter-apk/version.json',
        'https://github.com/dheeraz101/Notekar-Android/releases/download/${info.tagName}/version.json',
      ]) {
        try {
          final req = await client.getUrl(Uri.parse(versionJsonUrl));
          req.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');
          final resp = await req.close();
          if (resp.statusCode == 200 || resp.statusCode == 206) {
            final body = await resp.transform(utf8.decoder).join();
            final json = jsonDecode(body);
            final apks = json is Map ? json['apks'] : null;
            if (apks is List && apks.isNotEmpty) {
              manifestFound = true;
              for (final apk in apks) {
                if (apk is Map) {
                  final file = (apk['file'] as String? ?? '').toLowerCase();
                  final sha256 = (apk['sha256'] as String? ?? '').toLowerCase();
                  if (acceptableNames.contains(file) &&
                      sha256 == localHash.toLowerCase()) {
                    _logger.info(
                      'Checksum matches version.json target: $sha256 for $file',
                    );
                    return true;
                  }
                }
              }
            }
          }
        } catch (_) {}
      }

      if (!manifestFound) {
        // If no cryptographic checksum manifest was published for this release on GitHub,
        // verify the APK binary structure (ZIP magic bytes PK\x03\x04 and minimum size)
        final file = File(apkFilePath);
        if (await file.exists() && await file.length() >= 1024 * 1024) {
          try {
            final header = await file.openRead(0, 4).first;
            if (header.length >= 4 &&
                header[0] == 0x50 &&
                header[1] == 0x4B &&
                header[2] == 0x03 &&
                header[3] == 0x04) {
              _logger.info(
                'No remote checksum manifest found for tag ${info.tagName}, but APK binary structure is valid. Proceeding with install.',
              );
              return true;
            }
          } catch (_) {}
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
      final suffix = await _getDeviceSuffix();
      final candidates = getCandidateApkFilenames(version, suffix);
      for (final candidate in candidates) {
        final file = File('$cacheDir/$candidate');
        if (file.existsSync()) {
          return file.path;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Returns the total cumulative size of all downloaded installer files (.apk, .part, .tmp) in MB.
  Future<double> getTotalCacheSizeMb() async {
    try {
      final cacheDir = await _channel.invokeMethod<String>('appCacheDir');
      if (cacheDir == null) return 0.0;
      final dir = Directory(cacheDir);
      if (!dir.existsSync()) return 0.0;

      int totalBytes = 0;
      final files = dir.listSync();
      for (final entity in files) {
        if (entity is File) {
          final p = entity.path.toLowerCase();
          if (p.endsWith('.apk') ||
              p.contains('.apk.part') ||
              p.endsWith('.apk.tmp')) {
            totalBytes += entity.lengthSync();
          }
        }
      }
      return totalBytes / (1024 * 1024);
    } catch (e, stack) {
      _logger.error('Failed to compute total cache size', e, stack);
      return 0.0;
    }
  }

  Future<int> clearCachedBuilds() async {
    int deletedCount = 0;
    try {
      final cacheDir = await _channel.invokeMethod<String>('appCacheDir');
      if (cacheDir == null) return 0;
      final dir = Directory(cacheDir);
      if (dir.existsSync()) {
        final files = dir.listSync();
        for (final entity in files) {
          if (entity is File) {
            final p = entity.path.toLowerCase();
            if (p.endsWith('.apk') ||
                p.contains('.apk.part') ||
                p.endsWith('.apk.tmp')) {
              try {
                entity.deleteSync();
              } catch (_) {
                await entity.delete();
              }
              deletedCount++;
              _logger.info('Deleted cached APK/installer file: ${entity.path}');
            }
          }
        }
      }
    } catch (e, stack) {
      _logger.error('Failed to clear cached builds', e, stack);
    }
    return deletedCount;
  }

  bool isUpdateAvailable(String latest, String current) {
    return isNewerVersion(latest, current);
  }

  Future<double?> getApkSizeMb(AppUpdateInfo info) async {
    final client = _createHttpClient(timeout: const Duration(seconds: 5));
    try {
      final suffix = await _getDeviceSuffix();
      final candidates = getCandidateApkFilenames(info.version, suffix);

      for (final candidate in candidates) {
        final url =
            'https://github.com/dheeraz101/Notekar-Android/releases/download/${info.tagName}/$candidate';
        try {
          final request = await client.getUrl(Uri.parse(url));
          request.headers.set(
            HttpHeaders.userAgentHeader,
            'NoteKar/$appVersion',
          );
          request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');
          final response = await request.close();
          final statusCode = response.statusCode;
          final contentRange = response.headers.value(
            HttpHeaders.contentRangeHeader,
          );
          final contentLength = response.contentLength;
          await response.drain();

          if (statusCode == 404) continue;

          await NetworkLogger.log(
            url: url,
            method: 'HEAD',
            statusCode: statusCode,
            purpose: 'Query Update Package Size',
            size: '0.1 KB',
          );

          if (contentRange != null && contentRange.contains('/')) {
            final parts = contentRange.split('/');
            if (parts.length == 2) {
              final bytes = int.tryParse(parts[1]);
              if (bytes != null) {
                return bytes / (1024 * 1024);
              }
            }
          }
          if (contentLength > 0) {
            return contentLength / (1024 * 1024);
          }
        } catch (_) {}
      }
    } catch (_) {
    } finally {
      client.close(force: true);
    }
    return null;
  }
}
