import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:notekar/services/circuit_breaker_service.dart';

/// Represents usage metrics for a specific app within a timeframe.
class AppUsageEntry {
  const AppUsageEntry({
    required this.packageName,
    required this.name,
    required this.category,
    required this.duration,
  });

  final String packageName;
  final String name;
  final String category;
  final Duration duration;

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  factory AppUsageEntry.fromMap(Map<dynamic, dynamic> map) {
    final durationMs = (map['durationMs'] as num?)?.toInt() ?? 0;
    return AppUsageEntry(
      packageName: map['packageName'] as String? ?? '',
      name: map['name'] as String? ?? 'App',
      category: map['category'] as String? ?? 'System',
      duration: Duration(milliseconds: durationMs),
    );
  }
}

/// Immutable snapshot of daily screen time, pickups, and category buckets.
class DigitalWellbeingSnapshot {
  const DigitalWellbeingSnapshot({
    required this.hasPermission,
    required this.totalScreenTime,
    required this.unlockCount,
    required this.categoryBreakdown,
    required this.topApps,
    required this.queriedAt,
  });

  final bool hasPermission;
  final Duration totalScreenTime;
  final int unlockCount;
  final Map<String, Duration> categoryBreakdown;
  final List<AppUsageEntry> topApps;
  final DateTime queriedAt;

  static final DigitalWellbeingSnapshot empty = DigitalWellbeingSnapshot(
    hasPermission: false,
    totalScreenTime: Duration.zero,
    unlockCount: 0,
    categoryBreakdown: const {
      'Productivity': Duration.zero,
      'Social': Duration.zero,
      'Entertainment': Duration.zero,
      'System': Duration.zero,
    },
    topApps: const [],
    queriedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  String get formattedTotalScreenTime {
    final hours = totalScreenTime.inHours;
    final minutes = totalScreenTime.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Calculates the ratio (0.0 to 1.0) of a category compared to total screen time.
  double getCategoryRatio(String category) {
    final catMs = categoryBreakdown[category]?.inMilliseconds ?? 0;
    final totalMs = totalScreenTime.inMilliseconds;
    if (totalMs <= 0) return 0.0;
    return (catMs / totalMs).clamp(0.0, 1.0);
  }

  /// Calculates the true Intentionality Ratio by contrasting conscious NoteKar
  /// tracked duration against total device exposure.
  double computeIntentionalityRatio(Duration trackedIntentionalDuration) {
    final trackedMs = trackedIntentionalDuration.inMilliseconds;
    final screenMs = totalScreenTime.inMilliseconds;
    if (screenMs <= 0) {
      return trackedMs > 0 ? 1.0 : 0.0;
    }
    return (trackedMs / screenMs).clamp(0.0, 1.0);
  }

  /// Computes the ratio of intentional logs per phone pickup/unlock.
  double computeMindfulPickupRatio(int intentionalMomentsCount) {
    if (unlockCount <= 0) {
      return intentionalMomentsCount > 0 ? 1.0 : 0.0;
    }
    return (intentionalMomentsCount / unlockCount).clamp(0.0, 1.0);
  }

  factory DigitalWellbeingSnapshot.fromMap(Map<dynamic, dynamic> map) {
    final hasPerm = map['hasPermission'] as bool? ?? false;
    final totalMs = (map['totalScreenTimeMs'] as num?)?.toInt() ?? 0;
    final unlocks = (map['unlockCount'] as num?)?.toInt() ?? 0;

    final rawCategories = map['categories'] as Map<dynamic, dynamic>? ?? {};
    final categoryBreakdown = <String, Duration>{
      'Productivity': Duration(
        milliseconds: (rawCategories['Productivity'] as num?)?.toInt() ?? 0,
      ),
      'Social': Duration(
        milliseconds: (rawCategories['Social'] as num?)?.toInt() ?? 0,
      ),
      'Entertainment': Duration(
        milliseconds: (rawCategories['Entertainment'] as num?)?.toInt() ?? 0,
      ),
      'System': Duration(
        milliseconds: (rawCategories['System'] as num?)?.toInt() ?? 0,
      ),
    };

    final rawTopApps = map['topApps'] as List<dynamic>? ?? [];
    final topApps = rawTopApps
        .whereType<Map<dynamic, dynamic>>()
        .map(AppUsageEntry.fromMap)
        .toList();

    return DigitalWellbeingSnapshot(
      hasPermission: hasPerm,
      totalScreenTime: Duration(milliseconds: totalMs),
      unlockCount: unlocks,
      categoryBreakdown: categoryBreakdown,
      topApps: topApps,
      queriedAt: DateTime.now(),
    );
  }
}

/// Service managing on-device Android Digital Wellbeing queries, permission state,
/// and reactive state caching.
class DigitalWellbeingService {
  DigitalWellbeingService._internal();

  static final DigitalWellbeingService _instance =
      DigitalWellbeingService._internal();

  factory DigitalWellbeingService() => _instance;
  static DigitalWellbeingService get instance => _instance;

  static const MethodChannel _channel = MethodChannel('notekar/files');

  final ValueNotifier<DigitalWellbeingSnapshot> snapshotNotifier =
      ValueNotifier<DigitalWellbeingSnapshot>(DigitalWellbeingSnapshot.empty);

  final ValueNotifier<bool> permissionNotifier = ValueNotifier<bool>(false);

  DigitalWellbeingSnapshot? _cachedSnapshot;
  DateTime? _lastFetchTime;
  static const Duration _cacheTtl = Duration(minutes: 3);

  bool get isSupported => Platform.isAndroid;

  /// Checks if PACKAGE_USAGE_STATS is granted.
  Future<bool> checkPermission() async {
    if (!isSupported) {
      permissionNotifier.value = false;
      return false;
    }
    try {
      final granted =
          await _channel.invokeMethod<bool>('hasUsagePermission') ?? false;
      permissionNotifier.value = granted;
      return granted;
    } catch (_) {
      permissionNotifier.value = false;
      return false;
    }
  }

  /// Deep-links the user to Android's "Apps with Usage Access" settings screen.
  Future<void> openUsageSettings() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('openUsageAccessSettings');
    } catch (_) {}
  }

  /// Fetches today's screen time, pickups, and Smart Bucket categorization.
  Future<DigitalWellbeingSnapshot> fetchTodayStats({
    bool forceRefresh = false,
  }) async {
    if (!isSupported) {
      return DigitalWellbeingSnapshot.empty;
    }

    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedSnapshot != null &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < _cacheTtl) {
      return _cachedSnapshot!;
    }

    final fallback = _cachedSnapshot ?? DigitalWellbeingSnapshot.empty;
    return await CircuitBreakerService.instance.run(
          serviceId: 'digital_wellbeing_stats',
          action: () async {
            final nowMs = now.millisecondsSinceEpoch;
            final startOfDay = DateTime(now.year, now.month, now.day);
            final startMs = startOfDay.millisecondsSinceEpoch;

            final res = await _channel.invokeMapMethod<dynamic, dynamic>(
              'getDailyUsageStats',
              {'startTimeMs': startMs, 'endTimeMs': nowMs},
            );

            if (res == null) {
              return fallback;
            }

            final snapshot = DigitalWellbeingSnapshot.fromMap(res);
            _cachedSnapshot = snapshot;
            _lastFetchTime = now;
            permissionNotifier.value = snapshot.hasPermission;
            snapshotNotifier.value = snapshot;
            return snapshot;
          },
          fallback: fallback,
        ) ??
        fallback;
  }
}
