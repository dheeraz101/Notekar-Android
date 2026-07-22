import 'dart:convert';
import 'dart:io';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';

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
        date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
        isSecurity: json['isSecurity'] as bool? ?? false,
        isImportant: json['isImportant'] as bool? ?? false,
        type: json['type'] as String? ?? 'Regular Update',
      );
}

class UpdateService {
  final _logger = AppLogger();

  Future<AppUpdateInfo?> fetchLatestVersion() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(
        Uri.parse(
          'https://api.github.com/repos/dheeraz101/Notekar-Android/releases/latest',
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
      if (data is! Map) return null;

      final tag = (data['tag_name'] as String?) ?? (data['name'] as String?);
      final version = tag?.replaceFirst(RegExp(r'^[vV]'), '').trim();
      if (version == null) return null;

      final body = (data['body'] as String?) ?? '';
      final publishedAtStr = data['published_at'] as String?;
      final date = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

      final lowerBody = body.toLowerCase();
      final lowerName = ((data['name'] as String?) ?? '').toLowerCase();
      
      final isSecurity = lowerBody.contains('security') || lowerBody.contains('cve') || lowerName.contains('security');
      final isImportant = isSecurity || lowerBody.contains('critical') || lowerBody.contains('important') || lowerName.contains('critical') || lowerName.contains('important');
      
      final type = isSecurity 
          ? 'Security Update' 
          : (isImportant ? 'Critical Update' : 'Regular Update');

      _logger.info('Latest version fetched: $version ($type)');
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

  bool isUpdateAvailable(String latest, String current) {
    return isNewerVersion(latest, current);
  }
}
