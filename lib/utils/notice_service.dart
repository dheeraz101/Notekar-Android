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

  static const List<Map<String, dynamic>> defaultNotices = [
    {
      'enabled': true,
      'id': 'life-ledger-calibration-advisory',
      'title': 'Advisory: Life Ledger History Calibration',
      'title_es': 'Aviso: Calibración del historial de Life Ledger',
      'title_hi': 'सलाह: लाइफ लेजर इतिहास अंशांकन',
      'title_de': 'Hinweis: Life Ledger Historien-Kalibrierung',
      'title_fr': 'Avis : Étalonnage de l\'historique Life Ledger',
      'title_ja': 'お知らせ：Life Ledger 履歴計算の調整',
      'title_ru': 'Уведомление: Калибровка истории Life Ledger',
      'body':
          'We identified an edge-case calculation anomaly in the Life Ledger where accounts with newly started or variable tracking history could display uncalibrated void hours (such as 71h+ phantom loss) instead of reflecting verified history bounds. A comprehensive engine patch bounding all existential metrics strictly to recorded days is completed and will roll out immediately in the upcoming Priority Update.',
      'body_es':
          'Identificamos una anomalía en el cálculo del Life Ledger en la que las cuentas con historial reciente o variable podían mostrar horas de vacío no calibradas (como más de 71 horas de pérdida ficticia). Un parche del motor que limita todas las métricas estrictamente a los días registrados se lanzará de inmediato en la próxima Actualización Prioritaria.',
      'body_hi':
          'हमने लाइफ लेजर में एक गणना विसंगति की पहचान की है जहां नए या परिवर्तनशील इतिहास वाले खातों के लिए अवास्तविक समय हानि (जैसे 71h+ अवास्तविक नुकसान) प्रदर्शित हो सकती थी। सभी मेट्रिक्स को केवल दर्ज किए गए दिनों तक सख्ती से सीमित करने वाला इंजन सुधार आगामी प्राथमिकता अपडेट में तुरंत जारी किया जा रहा है।',
      'body_de':
          'Wir haben eine Berechnungsanomalie im Life Ledger festgestellt, bei der Konten mit wenig Historie unkalibrierte Verluststunden anzeigen konnten. Ein Engine-Patch zur strikten Begrenzung aller Metriken auf erfasste Tage wird im kommenden Prioritäts-Update bereitgestellt.',
      'body_fr':
          'Nous avons identifié une anomalie de calcul dans le Life Ledger où les comptes avec un historique récent pouvaient afficher des heures perdues non étalonnées. Un correctif limitant strictement les métriques aux jours enregistrés sera déployé dans la prochaine mise à jour prioritaire.',
      'body_ja':
          'Life Ledgerにおいて、利用履歴が少ない場合に未調整の損失時間が表示される計算異常が確認されました。記録された日数に厳密に限定する修正パッチは完了しており、次回の優先アップデートにて直ちに配信されます。',
      'body_ru':
          'Обнаружена аномалия вычислений в Life Ledger, из-за которой аккаунты с недавней историей могли отображать некорректные часы потерь. Исправление, ограничивающее все метрики только записанными днями, будет выпущено в ближайшем приоритетном обновлении.',
      'url': 'https://github.com/dheeraz101/Notekar-Android/releases',
      'action': 'releases',
      'priority': 'normal',
      'channels': ['stable', 'beta'],
      'platforms': ['android'],
      'minVersion': '7.0.0',
      'maxVersion': '7.5.0',
      'maxShows': 5,
      'cooldownHours': 12,
    },
  ];

  HttpClient _createHttpClient({
    Duration timeout = const Duration(seconds: 6),
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
      final response = await request.close().timeout(
        const Duration(seconds: 6),
      );

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

          final existingIds = notices.map((n) => n.id).toSet();
          for (final def in defaultNotices) {
            if (!existingIds.contains(def['id'])) {
              notices.add(AppNotice.fromJson(def));
            }
          }

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
      if (cachedStr == null || cachedStr.trim().isEmpty) {
        return _filterApplicableNotices(
          defaultNotices.map((map) => AppNotice.fromJson(map)).toList(),
        );
      }

      final dynamic rawJson = jsonDecode(cachedStr);
      if (rawJson is List) {
        final notices = rawJson
            .whereType<Map<String, dynamic>>()
            .map((map) => AppNotice.fromJson(map))
            .toList();

        final existingIds = notices.map((n) => n.id).toSet();
        for (final def in defaultNotices) {
          if (!existingIds.contains(def['id'])) {
            notices.add(AppNotice.fromJson(def));
          }
        }

        return _filterApplicableNotices(notices);
      } else {
        // Corrupted cache format - wipe
        await prefs.remove(_cachedNoticesKey);
      }
    } catch (e, stack) {
      _logger.warn(
        'Failed to read cached notices, purging corrupted key',
        e,
        stack,
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cachedNoticesKey);
      } catch (_) {}
    }
    return _filterApplicableNotices(
      defaultNotices.map((map) => AppNotice.fromJson(map)).toList(),
    );
  }

  /// Performs a silent background check if notices haven't been checked in [maxAge].
  /// Never blocks or throws, safely falls back to cached notices.
  Future<List<AppNotice>> syncIfStale({
    Duration maxAge = const Duration(hours: 4),
  }) async {
    try {
      final lastCheck = await getLastCheckTime();
      final now = DateTime.now();
      if (lastCheck == null || now.difference(lastCheck) >= maxAge) {
        return await fetchNotices();
      }
    } catch (_) {}
    return getCachedNotices();
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
    final cleanVer = appVersion.toLowerCase();
    final isBeta = cleanVer.contains('beta') || cleanVer.contains('br');

    return notices.where((n) {
      if (!n.enabled) return false;
      if (n.isExpired) return false;
      if (!n.isScheduledToStart) return false;

      // Platform check
      if (n.platforms.isNotEmpty && !n.platforms.contains('android')) {
        return false;
      }

      // Channel check: beta users receive beta + stable notices; stable users receive only stable
      if (n.channels.isNotEmpty) {
        if (isBeta) {
          if (!n.channels.contains('beta') && !n.channels.contains('stable')) {
            return false;
          }
        } else {
          if (!n.channels.contains('stable')) {
            return false;
          }
        }
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
      // Clean semver components: extract up to 3 numbers (major.minor.patch)
      List<int> parseParts(String v) {
        final semverPrefix = v.split('+').first.split('-').first;
        final clean = semverPrefix.replaceAll(RegExp(r'[^0-9.]'), '');
        return clean.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      }

      final parts1 = parseParts(v1);
      final parts2 = parseParts(v2);

      for (int i = 0; i < 3; i++) {
        final p1 = i < parts1.length ? parts1[i] : 0;
        final p2 = i < parts2.length ? parts2[i] : 0;
        if (p1 != p2) return p1.compareTo(p2);
      }
    } catch (_) {}
    return 0;
  }
}
