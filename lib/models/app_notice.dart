import 'package:flutter/material.dart';
import 'package:notekar/l10n/app_localizations.dart';

class AppNotice {
  const AppNotice({
    required this.id,
    required this.enabled,
    required this.title,
    this.titleEs,
    this.titleHi,
    this.titleDe,
    this.titleFr,
    this.titleJa,
    this.titleRu,
    required this.body,
    this.bodyEs,
    this.bodyHi,
    this.bodyDe,
    this.bodyFr,
    this.bodyJa,
    this.bodyRu,
    this.url,
    this.action,
    this.priority =
        'normal', // 'high'/'critical' | 'security' | 'normal'/'release' | 'low'/'tip'
    this.channels = const ['stable', 'beta'],
    this.platforms = const ['android'],
    this.minVersion,
    this.maxVersion,
    this.maxShows,
    this.cooldownHours,
    this.receivedAt,
    this.startsAt,
    this.expiresAt,
  });

  final String id;
  final bool enabled;
  final String title;
  final String? titleEs;
  final String? titleHi;
  final String? titleDe;
  final String? titleFr;
  final String? titleJa;
  final String? titleRu;
  final String body;
  final String? bodyEs;
  final String? bodyHi;
  final String? bodyDe;
  final String? bodyFr;
  final String? bodyJa;
  final String? bodyRu;
  final String? url;
  final String? action;
  final String priority;
  final List<String> channels;
  final List<String> platforms;
  final String? minVersion;
  final String? maxVersion;
  final int? maxShows;
  final int? cooldownHours;
  final DateTime? receivedAt;
  final DateTime? startsAt;
  final DateTime? expiresAt;

  bool get isCritical {
    final p = priority.toLowerCase().trim();
    return p == 'high' ||
        p == 'critical' ||
        p == 'urgent' ||
        p == 'alert' ||
        p == 'blocker';
  }

  bool get isSecurity {
    final p = priority.toLowerCase().trim();
    return p == 'security' || p == 'cve' || p == 'patch';
  }

  bool get isCuratedTip {
    final p = priority.toLowerCase().trim();
    return p == 'low' ||
        p == 'tip' ||
        p == 'guide' ||
        p == 'info' ||
        p == 'recommendation';
  }

  bool get isReleaseBulletin {
    if (isCritical || isSecurity || isCuratedTip) return false;
    return true;
  }

  String get badgeLabel {
    if (isCritical) return 'CRITICAL';
    if (isSecurity) return 'SECURITY';
    if (isCuratedTip) return 'TIP';
    return 'BULLETIN';
  }

  bool get isExpired {
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return true;
    }
    return false;
  }

  bool get isScheduledToStart {
    if (startsAt != null && DateTime.now().isBefore(startsAt!)) {
      return false;
    }
    return true;
  }

  String localizedTitle(BuildContext context) {
    final rawLocale = AppLocalizations.of(context)?.localeName ?? 'en';
    final lang = rawLocale.split('_').first.toLowerCase();
    switch (lang) {
      case 'hi':
        if (titleHi != null && titleHi!.trim().isNotEmpty) return titleHi!;
        break;
      case 'es':
        if (titleEs != null && titleEs!.trim().isNotEmpty) return titleEs!;
        break;
      case 'de':
        if (titleDe != null && titleDe!.trim().isNotEmpty) return titleDe!;
        break;
      case 'fr':
        if (titleFr != null && titleFr!.trim().isNotEmpty) return titleFr!;
        break;
      case 'ja':
        if (titleJa != null && titleJa!.trim().isNotEmpty) return titleJa!;
        break;
      case 'ru':
        if (titleRu != null && titleRu!.trim().isNotEmpty) return titleRu!;
        break;
    }
    return title;
  }

  String localizedBody(BuildContext context) {
    final rawLocale = AppLocalizations.of(context)?.localeName ?? 'en';
    final lang = rawLocale.split('_').first.toLowerCase();
    switch (lang) {
      case 'hi':
        if (bodyHi != null && bodyHi!.trim().isNotEmpty) return bodyHi!;
        break;
      case 'es':
        if (bodyEs != null && bodyEs!.trim().isNotEmpty) return bodyEs!;
        break;
      case 'de':
        if (bodyDe != null && bodyDe!.trim().isNotEmpty) return bodyDe!;
        break;
      case 'fr':
        if (bodyFr != null && bodyFr!.trim().isNotEmpty) return bodyFr!;
        break;
      case 'ja':
        if (bodyJa != null && bodyJa!.trim().isNotEmpty) return bodyJa!;
        break;
      case 'ru':
        if (bodyRu != null && bodyRu!.trim().isNotEmpty) return bodyRu!;
        break;
    }
    return body;
  }

  String actionLabel(BuildContext context) {
    final rawLocale = AppLocalizations.of(context)?.localeName ?? 'en';
    final lang = rawLocale.split('_').first.toLowerCase();
    final act = (action ?? '').toLowerCase().trim();
    final u = (url ?? '').toLowerCase().trim();

    if (act == 'releases' ||
        act == 'update' ||
        u.contains('/releases') ||
        u.contains('action=releases')) {
      return switch (lang) {
        'hi' => 'रिलीज़ देखें',
        'es' => 'Ver versión',
        'de' => 'Release ansehen',
        'fr' => 'Voir la version',
        'ja' => 'リリースを見る',
        'ru' => 'Открыть релиз',
        _ => 'View Release',
      };
    }

    if (act == 'settings' || u.contains('action=settings')) {
      return switch (lang) {
        'hi' => 'सेटिंग्स पर जाएं',
        'es' => 'Ir a ajustes',
        'de' => 'Zu Einstellungen',
        'fr' => 'Aller aux paramètres',
        'ja' => '設定へ移動',
        'ru' => 'В настройки',
        _ => 'Go to Settings',
      };
    }

    if (act == 'audit' || act == 'life_audit' || u.contains('action=audit')) {
      return switch (lang) {
        'hi' => 'लाइफ ऑडिट खोलें',
        'es' => 'Abrir Life Audit',
        'de' => 'Life Audit öffnen',
        'fr' => 'Ouvrir Life Audit',
        'ja' => 'Life Auditを開く',
        'ru' => 'Открыть Life Audit',
        _ => 'Open Life Audit',
      };
    }

    if (act == 'history' || u.contains('action=history')) {
      return switch (lang) {
        'hi' => 'इतिहास खोलें',
        'es' => 'Abrir historial',
        'de' => 'Verlauf öffnen',
        'fr' => 'Ouvrir l\'historique',
        'ja' => '履歴を開く',
        'ru' => 'Открыть историю',
        _ => 'Open History',
      };
    }

    return switch (lang) {
      'hi' => 'विवरण देखें',
      'es' => 'Ver detalles',
      'de' => 'Details anzeigen',
      'fr' => 'Voir les détails',
      'ja' => '詳細を見る',
      'ru' => 'Подробнее',
      _ => 'View Details',
    };
  }

  factory AppNotice.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String && val.trim().isNotEmpty) {
        return DateTime.tryParse(val.trim());
      }
      return null;
    }

    return AppNotice(
      id: json['id'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      title: json['title'] as String? ?? 'Notice',
      titleEs: (json['title_es'] ?? json['titleEs']) as String?,
      titleHi: (json['title_hi'] ?? json['titleHi']) as String?,
      titleDe: (json['title_de'] ?? json['titleDe']) as String?,
      titleFr: (json['title_fr'] ?? json['titleFr']) as String?,
      titleJa: (json['title_ja'] ?? json['titleJa']) as String?,
      titleRu: (json['title_ru'] ?? json['titleRu']) as String?,
      body: json['body'] as String? ?? '',
      bodyEs: (json['body_es'] ?? json['bodyEs']) as String?,
      bodyHi: (json['body_hi'] ?? json['bodyHi']) as String?,
      bodyDe: (json['body_de'] ?? json['bodyDe']) as String?,
      bodyFr: (json['body_fr'] ?? json['bodyFr']) as String?,
      bodyJa: (json['body_ja'] ?? json['bodyJa']) as String?,
      bodyRu: (json['body_ru'] ?? json['bodyRu']) as String?,
      url: json['url'] as String?,
      action: json['action'] as String?,
      priority: json['priority'] as String? ?? 'normal',
      channels:
          (json['channels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['stable', 'beta'],
      platforms:
          (json['platforms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['android'],
      minVersion: json['minVersion'] as String?,
      maxVersion: json['maxVersion'] as String?,
      maxShows: json['maxShows'] as int?,
      cooldownHours: json['cooldownHours'] as int?,
      receivedAt: parseDate(json['receivedAt']),
      startsAt: parseDate(json['startsAt'] ?? json['showAfter']),
      expiresAt: parseDate(json['expiresAt'] ?? json['showUntil']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enabled': enabled,
      'title': title,
      if (titleEs != null) 'title_es': titleEs,
      if (titleHi != null) 'title_hi': titleHi,
      if (titleDe != null) 'title_de': titleDe,
      if (titleFr != null) 'title_fr': titleFr,
      if (titleJa != null) 'title_ja': titleJa,
      if (titleRu != null) 'title_ru': titleRu,
      'body': body,
      if (bodyEs != null) 'body_es': bodyEs,
      if (bodyHi != null) 'body_hi': bodyHi,
      if (bodyDe != null) 'body_de': bodyDe,
      if (bodyFr != null) 'body_fr': bodyFr,
      if (bodyJa != null) 'body_ja': bodyJa,
      if (bodyRu != null) 'body_ru': bodyRu,
      if (url != null) 'url': url,
      if (action != null) 'action': action,
      'priority': priority,
      'channels': channels,
      'platforms': platforms,
      if (minVersion != null) 'minVersion': minVersion,
      if (maxVersion != null) 'maxVersion': maxVersion,
      if (maxShows != null) 'maxShows': maxShows,
      if (cooldownHours != null) 'cooldownHours': cooldownHours,
      if (receivedAt != null) 'receivedAt': receivedAt!.toIso8601String(),
      if (startsAt != null) 'startsAt': startsAt!.toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }
}
