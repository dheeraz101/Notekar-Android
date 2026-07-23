import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';

const appVersion = '4.0.9';
const appBuildNumber = '18';
const appBuildDate = '2026-07-23';

// 8pt Grid Constants
const double spacing4 = 4.0;
const double spacing8 = 8.0;
const double spacing12 = 12.0;
const double spacing16 = 16.0;
const double spacing20 = 20.0;
const double spacing24 = 24.0;
const double spacing32 = 32.0;
const double spacing48 = 48.0;
const double spacing64 = 64.0;

const int maxNoteLength = 500;

const officialSite = 'https://notekarapp.vercel.app';
const yabpSite = 'https://yabp.netlify.app/';
const privacyPolicyUrl = 'https://notekarapp.vercel.app/privacy.html';
const termsUrl = 'https://notekarapp.vercel.app/terms.html';
const githubRepo = 'https://github.com/dheeraz101/Notekar-Android';
const githubIssues = 'https://github.com/dheeraz101/Notekar-Android/issues';
const coffeeLink = 'https://buymeacoffee.com/dheeraz';
const githubReleases = 'https://github.com/dheeraz101/Notekar-Android/releases';
const supportEmail = 'mailto:yabp.support@gmail.com';
const notificationFeed =
    'https://raw.githubusercontent.com/dheeraz101/NotekarN/refs/heads/main/notification.json';

const delayValues = [0, 5, 10, 15, 20, 30, 60];
const accentOptions = [
  'blue',
  'green',
  'purple',
  'pink',
  'orange',
  'graphite',
  'teal',
  'mint',
  'cyan',
  'indigo',
  'violet',
  'lavender',
  'rose',
  'coral',
  'amber',
  'sand',
  'sage',
  'olive',
  'slate',
  'brown',
];

bool isAppIconStyle(String? value) {
  return const {
    'default',
    'black',
    'blue',
    'gold',
    'green',
    'orange',
    'red',
  }.contains(value);
}

String dateKey(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

DateTime dateFromKey(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

String compactDateLabel(String value) {
  final date = dateFromKey(value);
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${(date.year % 100).toString().padLeft(2, '0')}';
}

String monthLabel(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[value.month - 1]} ${value.year}';
}

String timeOnly(int timestamp) {
  final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}:'
      '${d.second.toString().padLeft(2, '0')}';
}

String datePretty(int timestamp) {
  final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

String historySectionLabel(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final today = DateTime.now();
  final key = dateKey(date);
  if (key == dateKey(today)) return 'Today';
  if (key == dateKey(today.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }
  return 'Earlier';
}

String durationLabel(Duration d, {bool extended = false}) {
  if (extended) {
    if (d.inDays >= 365) {
      final years = (d.inDays / 365).floor();
      final months = ((d.inDays % 365) / 30).floor();
      if (months == 0) return '${years}y';
      return '${years}y ${months}m';
    }
    if (d.inDays >= 30) {
      final months = (d.inDays / 30).floor();
      final days = d.inDays % 30;
      if (days == 0) return '${months}mo';
      return '${months}m ${days}d';
    }
    if (d.inDays >= 1) {
      final days = d.inDays;
      final hours = d.inHours % 24;
      if (hours == 0) return '${days}d';
      return '${days}d ${hours}h';
    }
  }

  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m ${s}s';
  return '${s}s';
}

String delayLabel(int value) => value == 60 ? '1m' : '${value}s';

String privacyLockDelayLabel(int value) {
  return switch (value) {
    0 => 'Immediately',
    1 => 'After 1 Min',
    5 => 'After 5 Min',
    10 => 'After 10 Min',
    _ => 'Immediately',
  };
}

String relativeAge(int timestamp) {
  final elapsed = DateTime.now().difference(
    DateTime.fromMillisecondsSinceEpoch(timestamp),
  );
  if (elapsed.inSeconds < 45) return 'Just now';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
  return '${elapsed.inDays}d ago';
}

String exportDateStamp() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}-'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';
}

String filterLabel(String value) {
  return switch (value) {
    'all' => 'All',
    'today' => 'Today',
    'week' => 'This Week',
    'in' => 'IN',
    'out' => 'OUT',
    'single' => 'Single',
    'notes' => 'Notes',
    _ => value,
  };
}

bool isNewerVersion(String candidate, String current) {
  List<int> parts(String value) => value
      .split('+')
      .first
      .split(RegExp(r'[^0-9]+'))
      .where((part) => part.isNotEmpty)
      .map(int.parse)
      .toList();
  final a = parts(candidate);
  final b = parts(current);
  final length = math.max(a.length, b.length);
  for (var i = 0; i < length; i++) {
    final av = i < a.length ? a[i] : 0;
    final bv = i < b.length ? b[i] : 0;
    if (av != bv) return av > bv;
  }
  return false;
}

List<BoxShadow> selectedGlow(Color color) {
  return const [];
}

Color momentColor(Palette p, String type) {
  if (type == 'in') return p.green;
  if (type == 'out') return p.orange;
  return p.blue;
}

IconData momentIcon(String type) {
  if (type == 'in') return Icons.south_west_rounded;
  if (type == 'out') return Icons.north_east_rounded;
  return Icons.arrow_upward_rounded;
}

class NotekarHaptics {
  static void light(String style) {
    if (style == 'off') return;
    HapticFeedback.selectionClick();
  }

  static void selection(String style) {
    if (style == 'off') return;
    HapticFeedback.selectionClick();
  }

  static void success(String style) {
    if (style == 'off') return;
    if (style == 'light') {
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  static void save(String style, String type) {
    if (style == 'off') return;
    if (style == 'light') {
      HapticFeedback.selectionClick();
      return;
    }

    if (type == 'out') {
      HapticFeedback.mediumImpact().then((_) {
        Future.delayed(const Duration(milliseconds: 70), () {
          HapticFeedback.lightImpact();
        });
      });
    } else if (type == 'in') {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  static void warning(String style) {
    if (style == 'off') return;
    HapticFeedback.vibrate();
  }
}

MediaQueryData largerTextQuery(BuildContext context) {
  final media = MediaQuery.of(context);
  final current = media.textScaler.scale(1);
  final target = math.max(current, math.min(current * 1.12, 1.6));
  return media.copyWith(textScaler: TextScaler.linear(target));
}
