import 'package:flutter/material.dart';
import 'package:notekar/l10n/app_localizations.dart';

class AppNotice {
  const AppNotice({
    required this.id,
    required this.enabled,
    required this.title,
    this.titleEs,
    this.titleHi,
    required this.body,
    this.bodyEs,
    this.bodyHi,
    this.url,
    this.action,
    this.priority = 'normal', // 'high' | 'normal' | 'low'
    this.channels = const ['stable', 'beta'],
    this.platforms = const ['android'],
    this.minVersion,
    this.maxVersion,
    this.maxShows,
    this.cooldownHours,
    this.receivedAt,
  });

  final String id;
  final bool enabled;
  final String title;
  final String? titleEs;
  final String? titleHi;
  final String body;
  final String? bodyEs;
  final String? bodyHi;
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

  bool get isCritical =>
      priority.toLowerCase() == 'high' || priority.toLowerCase() == 'critical';

  bool get isReleaseBulletin =>
      priority.toLowerCase() == 'normal' ||
      priority.toLowerCase() == 'release' ||
      priority.toLowerCase() == 'medium';

  bool get isCuratedTip =>
      priority.toLowerCase() == 'low' || priority.toLowerCase() == 'tip';

  String localizedTitle(BuildContext context) {
    final locale = AppLocalizations.of(context)?.localeName ?? 'en';
    if (locale == 'hi' && titleHi != null && titleHi!.isNotEmpty) {
      return titleHi!;
    }
    if (locale == 'es' && titleEs != null && titleEs!.isNotEmpty) {
      return titleEs!;
    }
    return title;
  }

  String localizedBody(BuildContext context) {
    final locale = AppLocalizations.of(context)?.localeName ?? 'en';
    if (locale == 'hi' && bodyHi != null && bodyHi!.isNotEmpty) {
      return bodyHi!;
    }
    if (locale == 'es' && bodyEs != null && bodyEs!.isNotEmpty) {
      return bodyEs!;
    }
    return body;
  }

  factory AppNotice.fromJson(Map<String, dynamic> json) {
    return AppNotice(
      id: json['id'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      title: json['title'] as String? ?? 'Notice',
      titleEs: json['title_es'] as String?,
      titleHi: json['title_hi'] as String?,
      body: json['body'] as String? ?? '',
      bodyEs: json['body_es'] as String?,
      bodyHi: json['body_hi'] as String?,
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
      receivedAt: json['receivedAt'] != null
          ? DateTime.tryParse(json['receivedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enabled': enabled,
      'title': title,
      if (titleEs != null) 'title_es': titleEs,
      if (titleHi != null) 'title_hi': titleHi,
      'body': body,
      if (bodyEs != null) 'body_es': bodyEs,
      if (bodyHi != null) 'body_hi': bodyHi,
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
    };
  }
}
