import 'dart:convert';
import 'dart:io';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';

class UpdateService {
  final _logger = AppLogger();

  Future<String?> fetchLatestVersion() async {
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

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body);
      if (data is! Map) return null;

      final tag = (data['tag_name'] as String?) ?? (data['name'] as String?);
      final version = tag?.replaceFirst(RegExp(r'^[vV]'), '').trim();
      
      _logger.info('Latest version fetched: $version');
      return version;
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
