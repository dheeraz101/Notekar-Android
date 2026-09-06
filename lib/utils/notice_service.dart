import 'dart:convert';
import 'dart:io';

import 'package:notekar/models/app_notice.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/network_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeService {
  NoticeService._();

  static final NoticeService instance = NoticeService._();

  final _logger = AppLogger();

  static const _cachedNoticesKey = 'cached_app_notices';
  static const _lastCheckTsKey = 'last_notice_check_ts';
  static const _dismissedNoticesKey = 'dismissed_notice_ids';

  HttpClient _createHttpClient({
    Duration timeout = const Duration(seconds: 8),
  }) {
    return HttpClient()
      ..connectionTimeout = timeout
      ..badCertificateCallback = (cert, host, port) => true;
  }

  /// Fetches latest notices from notificationFeed, caches them locally, and returns the filtered list.
  Future<List<AppNotice>> fetchNotices({bool force = false}) async {
    final client = _createHttpClient();
    try {
      final request = await client.getUrl(Uri.parse(notificationFeed));
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');
      final response = await request.close();

      await NetworkLogger.log(
        url: notificationFeed,
        method: 'GET',
        statusCode: response.statusCode,
        purpose: 'App Bulletins & Advisories Sync',
        size: response.contentLength > 0
            ? '${(response.contentLength / 1024).toStringAsFixed(2)} KB'
            : 'Unknown',
      );

      if (response.statusCode == 200) {
        final bodyStr = await response.transform(utf8.decoder).join();
        final dynamic rawJson = jsonDecode(bodyStr);

        if (rawJson is List) {
          final now = DateTime.now();
          final notices = rawJson.whereType<Map<String, dynamic>>().map((map) {
            final copy = Map<String, dynamic>.from(map);
            copy['receivedAt'] ??= now.toIso8601String();
            return AppNotice.fromJson(copy);
          }).toList();

          // Save to local cache
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cachedNoticesKey, bodyStr);
          await prefs.setInt(_lastCheckTsKey, now.millisecondsSinceEpoch);

          return _filterApplicableNotices(notices);
        }
      }
    } catch (e, stack) {
      _logger.warn('Failed to fetch remote notices', e, stack);
    } finally {
      client.close();
    }

    // Fallback to local cache if network call fails or is offline
    return getCachedNotices();
  }

  /// Reads cached notices directly from local disk storage with zero latency.
  Future<List<AppNotice>> getCachedNotices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_cachedNoticesKey);
      if (cachedStr == null || cachedStr.isEmpty) {
        return const [];
      }

      final dynamic rawJson = jsonDecode(cachedStr);
      if (rawJson is List) {
        final notices = rawJson
            .whereType<Map<String, dynamic>>()
            .map((map) => AppNotice.fromJson(map))
            .toList();

        return _filterApplicableNotices(notices);
      }
    } catch (e, stack) {
      _logger.warn('Failed to read cached notices', e, stack);
    }
    return const [];
  }

  /// Returns the timestamp when notices were last checked.
  Future<DateTime?> getLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_lastCheckTsKey);
      if (ts != null && ts > 0) {
        return DateTime.fromMillisecondsSinceEpoch(ts);
      }
    } catch (_) {}
    return null;
  }

  /// Finds if an active critical advisory (high priority) exists for current version.
  Future<AppNotice?> getActiveCriticalAdvisory() async {
    final notices = await getCachedNotices();
    final dismissed = await getDismissedNoticeIds();

    for (final notice in notices) {
      if (notice.isCritical &&
          notice.enabled &&
          !dismissed.contains(notice.id)) {
        return notice;
      }
    }
    return null;
  }

  Future<Set<String>> getDismissedNoticeIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_dismissedNoticesKey) ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> dismissNotice(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final set = (prefs.getStringList(_dismissedNoticesKey) ?? []).toSet();
      set.add(id);
      await prefs.setStringList(_dismissedNoticesKey, set.toList());
    } catch (_) {}
  }

  List<AppNotice> _filterApplicableNotices(List<AppNotice> notices) {
    return notices.where((n) {
      if (!n.enabled) return false;

      // Platform check
      if (n.platforms.isNotEmpty && !n.platforms.contains('android')) {
        return false;
      }

      // Version bounds check
      if (n.minVersion != null &&
          _compareVersion(appVersion, n.minVersion!) < 0) {
        return false;
      }
      if (n.maxVersion != null &&
          _compareVersion(appVersion, n.maxVersion!) > 0) {
        return false;
      }

      return true;
    }).toList();
  }

  int _compareVersion(String v1, String v2) {
    try {
      final clean1 = v1.replaceAll(RegExp(r'[^0-9.]'), '');
      final clean2 = v2.replaceAll(RegExp(r'[^0-9.]'), '');
      final parts1 = clean1
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final parts2 = clean2
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      for (int i = 0; i < 3; i++) {
        final p1 = i < parts1.length ? parts1[i] : 0;
        final p2 = i < parts2.length ? parts2[i] : 0;
        if (p1 != p2) return p1.compareTo(p2);
      }
    } catch (_) {}
    return 0;
  }
}
