import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';

/// Time horizons supported by the Life Audit & Time Wastage engine.
enum LifeAuditTimeframe {
  today,
  week,
  month,
  halfQuarter,
  halfYear,
  year;

  String get label => switch (this) {
    LifeAuditTimeframe.today => 'Today',
    LifeAuditTimeframe.week => 'Week',
    LifeAuditTimeframe.month => 'Month',
    LifeAuditTimeframe.halfQuarter => '6 Weeks',
    LifeAuditTimeframe.halfYear => '6 Months',
    LifeAuditTimeframe.year => 'Year',
  };

  int get daysCount => switch (this) {
    LifeAuditTimeframe.today => 1,
    LifeAuditTimeframe.week => 7,
    LifeAuditTimeframe.month => 30,
    LifeAuditTimeframe.halfQuarter => 45,
    LifeAuditTimeframe.halfYear => 180,
    LifeAuditTimeframe.year => 365,
  };
}

/// The intentionality status of a single day's conscious window.
enum DayAuditStatus {
  transcendent,
  substantial,
  partial,
  severeVoid,
  totalLoss,
  noData;

  String get label => switch (this) {
    DayAuditStatus.transcendent => 'Transcendent (Over-Accounted)',
    DayAuditStatus.substantial => 'Substantial Focus',
    DayAuditStatus.partial => 'Partially Accounted',
    DayAuditStatus.severeVoid => 'Severe Void',
    DayAuditStatus.totalLoss => 'Total Void Loss',
    DayAuditStatus.noData => 'No Data Logged',
  };

  Color color({
    required Color accent,
    required Color green,
    required Color orange,
    required Color red,
  }) {
    return switch (this) {
      DayAuditStatus.transcendent => accent,
      DayAuditStatus.substantial => green,
      DayAuditStatus.partial => orange,
      DayAuditStatus.severeVoid => red.withValues(alpha: 0.8),
      DayAuditStatus.totalLoss => red,
      DayAuditStatus.noData => Colors.grey,
    };
  }
}

/// A day-by-day record of conscious time utilization and wasted void.
class DayAuditRecord {
  const DayAuditRecord({
    required this.dateKey,
    required this.date,
    required this.displayLabel,
    required this.trackedDuration,
    required this.consciousWindow,
    required this.wastedDuration,
    required this.overtimeDuration,
    required this.intentionalityPercentage,
    required this.isToday,
    required this.status,
  });

  final String dateKey;
  final DateTime date;
  final String displayLabel;
  final Duration trackedDuration;
  final Duration consciousWindow;
  final Duration wastedDuration;
  final Duration overtimeDuration;
  final double intentionalityPercentage;
  final bool isToday;
  final DayAuditStatus status;

  String get formattedTracked => _formatDuration(trackedDuration);

  String get formattedWasted => _formatDuration(wastedDuration);

  String get formattedConscious => _formatDuration(consciousWindow);

  static String _formatDuration(Duration d) {
    final totalMins = d.inMinutes;
    if (totalMins <= 0) return '0m';
    final hours = totalMins ~/ 60;
    final mins = totalMins % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }
}

/// The aggregate mathematical summary of a Life Audit period.
class LifeAuditSummary {
  const LifeAuditSummary({
    required this.timeframe,
    required this.daysCount,
    required this.sleepHours,
    required this.essentialsHours,
    required this.consciousHoursPerDay,
    required this.totalConsciousWindow,
    required this.totalTrackedDuration,
    required this.totalWastedDuration,
    required this.totalWakingDaysLost,
    required this.totalCelestialDaysLost,
    required this.intentionalityRatio,
    required this.voidRatio,
    required this.dailyRecords,
    this.hasData = true,
    this.availableHistoryDays = 0,
    this.requiredDays = 1,
    this.firstLogDate,
  });

  final LifeAuditTimeframe timeframe;
  final int daysCount;
  final double sleepHours;
  final double essentialsHours;
  final double consciousHoursPerDay;
  final Duration totalConsciousWindow;
  final Duration totalTrackedDuration;
  final Duration totalWastedDuration;
  final double totalWakingDaysLost;
  final double totalCelestialDaysLost;
  final double intentionalityRatio;
  final double voidRatio;
  final List<DayAuditRecord> dailyRecords;
  final bool hasData;
  final int availableHistoryDays;
  final int requiredDays;
  final DateTime? firstLogDate;

  String get formattedTotalTracked =>
      DayAuditRecord._formatDuration(totalTrackedDuration);

  String get formattedTotalWasted =>
      DayAuditRecord._formatDuration(totalWastedDuration);

  String get formattedTotalConscious =>
      DayAuditRecord._formatDuration(totalConsciousWindow);

  String get wakingDaysLostText {
    if (totalWakingDaysLost < 0.1) return '0 days';
    return '${totalWakingDaysLost.toStringAsFixed(1)} days';
  }

  String get celestialDaysLostText {
    if (totalCelestialDaysLost < 0.1) return '0 days';
    return '${totalCelestialDaysLost.toStringAsFixed(1)} days';
  }
}

/// High-performance calculation engine for the 24-Hour Life Audit.
class LifeAuditService {
  static const double defaultSleepHours = 10.0;
  static const double defaultEssentialsHours = 4.0;

  /// Computes the conscious window given sleep and essential logistics hours.
  static double computeConsciousHours({
    required double sleepHours,
    required double essentialsHours,
  }) {
    final conscious = 24.0 - sleepHours - essentialsHours;
    return conscious.clamp(1.0, 20.0);
  }

  /// Calculates the complete Life Audit summary across all moments for the specified timeframe.
  static LifeAuditSummary calculate({
    required List<Moment> entries,
    required LifeAuditTimeframe timeframe,
    double sleepHours = defaultSleepHours,
    double essentialsHours = defaultEssentialsHours,
    DateTime? referenceNow,
  }) {
    final now = referenceNow ?? DateTime.now();
    final consciousHours = computeConsciousHours(
      sleepHours: sleepHours,
      essentialsHours: essentialsHours,
    );

    final consciousWindowPerDay = Duration(
      milliseconds: (consciousHours * 3600 * 1000).round(),
    );

    final requiredDays = timeframe.daysCount;

    // If there are no entries, the user has 0 recorded history.
    // Return 0 data available instead of fabricating false lost hours.
    if (entries.isEmpty) {
      return LifeAuditSummary(
        timeframe: timeframe,
        daysCount: requiredDays,
        sleepHours: sleepHours,
        essentialsHours: essentialsHours,
        consciousHoursPerDay: consciousHours,
        totalConsciousWindow: Duration.zero,
        totalTrackedDuration: Duration.zero,
        totalWastedDuration: Duration.zero,
        totalWakingDaysLost: 0.0,
        totalCelestialDaysLost: 0.0,
        intentionalityRatio: 0.0,
        voidRatio: 0.0,
        dailyRecords: const [],
        hasData: false,
        availableHistoryDays: 0,
        requiredDays: requiredDays,
      );
    }

    final todayStart = DateTime(now.year, now.month, now.day);

    // Determine earliest moment in the user's recorded history
    int minTs = entries.first.timestamp;
    for (final e in entries) {
      if (e.timestamp < minTs) minTs = e.timestamp;
    }
    final firstLogDate = DateTime.fromMillisecondsSinceEpoch(minTs);
    final firstLogDay = DateTime(
      firstLogDate.year,
      firstLogDate.month,
      firstLogDate.day,
    );

    final availableHistoryDays = math.max(
      1,
      todayStart.difference(firstLogDay).inDays + 1,
    );

    // Build timeline sections to accurately capture session durations per day
    final daySections = buildTimelineDaySections(entries);
    final Map<String, Duration> trackedByDateKey = {};
    for (final section in daySections) {
      trackedByDateKey[section.dateKey] = section.totalTrackedDuration;
    }

    // Determine if user has sufficient history for this macro horizon.
    // For today: since entries is not empty, availableHistoryDays >= 1 is always true.
    // For week, month, halfQuarter, halfYear, year: require availableHistoryDays >= requiredDays.
    final bool hasSufficientHistory = availableHistoryDays >= requiredDays;

    if (!hasSufficientHistory) {
      // Build daily records for the days that actually exist in the user's history path
      final int daysToBuild = math.min(requiredDays, availableHistoryDays);
      final List<DayAuditRecord> partialRecords = [];

      for (int i = 0; i < daysToBuild; i++) {
        final dayDate = todayStart.subtract(Duration(days: i));
        final k = dateKey(dayDate);
        final isToday = i == 0;

        final tracked = trackedByDateKey[k] ?? Duration.zero;
        final trackedMs = tracked.inMilliseconds;
        final consciousMs = consciousWindowPerDay.inMilliseconds;

        final wastedMs = math.max(0, consciousMs - trackedMs);
        final overtimeMs = math.max(0, trackedMs - consciousMs);

        final double intentionalityPct = consciousMs > 0
            ? ((trackedMs / consciousMs) * 100.0).clamp(0.0, 100.0)
            : 0.0;

        final status = _evaluateStatus(
          trackedMs: trackedMs,
          consciousMs: consciousMs,
        );

        final displayLabel = _formatDayDisplay(dayDate, isToday);

        partialRecords.add(
          DayAuditRecord(
            dateKey: k,
            date: dayDate,
            displayLabel: displayLabel,
            trackedDuration: tracked,
            consciousWindow: consciousWindowPerDay,
            wastedDuration: Duration(milliseconds: wastedMs),
            overtimeDuration: Duration(milliseconds: overtimeMs),
            intentionalityPercentage: intentionalityPct,
            isToday: isToday,
            status: status,
          ),
        );
      }

      return LifeAuditSummary(
        timeframe: timeframe,
        daysCount: requiredDays,
        sleepHours: sleepHours,
        essentialsHours: essentialsHours,
        consciousHoursPerDay: consciousHours,
        totalConsciousWindow: Duration.zero,
        totalTrackedDuration: Duration.zero,
        totalWastedDuration: Duration.zero,
        totalWakingDaysLost: 0.0,
        totalCelestialDaysLost: 0.0,
        intentionalityRatio: 0.0,
        voidRatio: 0.0,
        dailyRecords: partialRecords,
        hasData: false,
        availableHistoryDays: availableHistoryDays,
        requiredDays: requiredDays,
        firstLogDate: firstLogDate,
      );
    }

    // User has accumulated sufficient history for this timeframe: compute full audit
    final List<DayAuditRecord> records = [];
    int totalTrackedMs = 0;
    int totalWastedMs = 0;

    for (int i = 0; i < requiredDays; i++) {
      final dayDate = todayStart.subtract(Duration(days: i));
      final k = dateKey(dayDate);
      final isToday = i == 0;

      final tracked = trackedByDateKey[k] ?? Duration.zero;
      final trackedMs = tracked.inMilliseconds;
      final consciousMs = consciousWindowPerDay.inMilliseconds;

      final wastedMs = math.max(0, consciousMs - trackedMs);
      final overtimeMs = math.max(0, trackedMs - consciousMs);

      totalTrackedMs += trackedMs;
      totalWastedMs += wastedMs;

      final double intentionalityPct = consciousMs > 0
          ? ((trackedMs / consciousMs) * 100.0).clamp(0.0, 100.0)
          : 0.0;

      final status = _evaluateStatus(
        trackedMs: trackedMs,
        consciousMs: consciousMs,
      );

      final displayLabel = _formatDayDisplay(dayDate, isToday);

      records.add(
        DayAuditRecord(
          dateKey: k,
          date: dayDate,
          displayLabel: displayLabel,
          trackedDuration: tracked,
          consciousWindow: consciousWindowPerDay,
          wastedDuration: Duration(milliseconds: wastedMs),
          overtimeDuration: Duration(milliseconds: overtimeMs),
          intentionalityPercentage: intentionalityPct,
          isToday: isToday,
          status: status,
        ),
      );
    }

    final totalConsciousWindow = Duration(
      milliseconds: consciousWindowPerDay.inMilliseconds * requiredDays,
    );
    final totalTrackedDuration = Duration(milliseconds: totalTrackedMs);
    final totalWastedDuration = Duration(milliseconds: totalWastedMs);

    final totalWastedHours = totalWastedMs / (3600.0 * 1000.0);
    final totalWakingDaysLost = consciousHours > 0
        ? totalWastedHours / consciousHours
        : 0.0;
    final totalCelestialDaysLost = totalWastedHours / 24.0;

    final double aggregateIntentionality =
        totalConsciousWindow.inMilliseconds > 0
        ? ((totalTrackedMs / totalConsciousWindow.inMilliseconds) * 100.0)
              .clamp(0.0, 100.0)
        : 0.0;
    final double aggregateVoid = (100.0 - aggregateIntentionality).clamp(
      0.0,
      100.0,
    );

    return LifeAuditSummary(
      timeframe: timeframe,
      daysCount: requiredDays,
      sleepHours: sleepHours,
      essentialsHours: essentialsHours,
      consciousHoursPerDay: consciousHours,
      totalConsciousWindow: totalConsciousWindow,
      totalTrackedDuration: totalTrackedDuration,
      totalWastedDuration: totalWastedDuration,
      totalWakingDaysLost: totalWakingDaysLost,
      totalCelestialDaysLost: totalCelestialDaysLost,
      intentionalityRatio: aggregateIntentionality,
      voidRatio: aggregateVoid,
      dailyRecords: records,
      hasData: true,
      availableHistoryDays: availableHistoryDays,
      requiredDays: requiredDays,
      firstLogDate: firstLogDate,
    );
  }

  static DayAuditStatus _evaluateStatus({
    required int trackedMs,
    required int consciousMs,
  }) {
    if (trackedMs == 0) return DayAuditStatus.totalLoss;
    if (trackedMs >= consciousMs) return DayAuditStatus.transcendent;

    final ratio = trackedMs / consciousMs;
    if (ratio >= 0.70) return DayAuditStatus.substantial;
    if (ratio >= 0.30) return DayAuditStatus.partial;
    return DayAuditStatus.severeVoid;
  }

  static String _formatDayDisplay(DateTime date, bool isToday) {
    if (isToday) return 'Today';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final wd = weekdayNames[date.weekday - 1];
    final m = monthNames[date.month - 1];
    return '$wd, $m ${date.day}';
  }
}
