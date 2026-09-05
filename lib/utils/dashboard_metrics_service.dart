import 'package:flutter/material.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

enum DashboardTimeframe {
  today,
  week,
  month,
  all;

  String get label => switch (this) {
    DashboardTimeframe.today => 'Today',
    DashboardTimeframe.week => 'Week',
    DashboardTimeframe.month => 'Month',
    DashboardTimeframe.all => 'All',
  };
}

class TimeSlotStat {
  const TimeSlotStat({
    required this.name,
    required this.rangeLabel,
    required this.count,
    required this.percentage,
    required this.isPeak,
  });

  final String name;
  final String rangeLabel;
  final int count;
  final int percentage;
  final bool isPeak;
}

class TimeSlotBiasData {
  const TimeSlotBiasData({
    required this.headline,
    required this.peakSlotName,
    required this.slots,
  });

  final String headline;
  final String peakSlotName;
  final List<TimeSlotStat> slots;
}

class DayRhythmStat {
  const DayRhythmStat({
    required this.dayLabel,
    required this.trackedDuration,
    required this.count,
    required this.isToday,
  });

  final String dayLabel;
  final Duration trackedDuration;
  final int count;
  final bool isToday;
}

class DailyRhythmData {
  const DailyRhythmData({required this.days, required this.comparisonText});

  final List<DayRhythmStat> days;
  final String comparisonText;
}

class FocusCategoryStat {
  const FocusCategoryStat({
    required this.name,
    required this.color,
    required this.duration,
    required this.percentage,
    required this.count,
  });

  final String name;
  final Color color;
  final Duration duration;
  final int percentage;
  final int count;
}

class FocusBreakdownData {
  const FocusBreakdownData({required this.categories});

  final List<FocusCategoryStat> categories;
}

class ActivityGridStats {
  const ActivityGridStats({
    required this.longestStreak,
    required this.currentStreak,
    required this.activeDaysCount,
    required this.totalDaysCount,
    required this.dayIntensities,
  });

  final int longestStreak;
  final int currentStreak;
  final int activeDaysCount;
  final int totalDaysCount;
  final Map<String, int> dayIntensities;
}

class ExecutiveDashboardData {
  const ExecutiveDashboardData({
    required this.timeframe,
    required this.totalTracked,
    required this.totalMoments,
    required this.paceText,
    required this.paceIsPositive,
    required this.activityRingRatio,
    required this.timeSlotBias,
    required this.dailyRhythm,
    required this.focusBreakdown,
    required this.gridStats,
  });

  final DashboardTimeframe timeframe;
  final Duration totalTracked;
  final int totalMoments;
  final String paceText;
  final bool paceIsPositive;
  final double activityRingRatio;
  final TimeSlotBiasData timeSlotBias;
  final DailyRhythmData dailyRhythm;
  final FocusBreakdownData focusBreakdown;
  final ActivityGridStats gridStats;

  String get formattedTotalTracked {
    final totalMinutes = totalTracked.inMinutes;
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
}

class DashboardMetricsService {
  static ExecutiveDashboardData calculate({
    required List<Moment> entries,
    required DashboardTimeframe timeframe,
    required Palette p,
  }) {
    final now = DateTime.now();

    // 1. Filter entries into current and previous comparison periods
    final (currentEntries, previousEntries, prevPeriodLabel) =
        _filterTimeframes(entries, timeframe, now);

    // 2. Build TimelineDaySections to pair sessions & calculate accurate tracked durations
    final currentSections = buildTimelineDaySections(currentEntries);

    int currentTrackedMs = 0;
    for (final s in currentSections) {
      currentTrackedMs += s.totalTrackedDuration.inMilliseconds;
    }
    final totalTracked = Duration(milliseconds: currentTrackedMs);

    final totalMoments = currentEntries.length;
    final prevMoments = previousEntries.length;

    // 3. Compute Pace vs previous period
    final (paceText, paceIsPositive) = _computePace(
      currentCount: totalMoments,
      prevCount: prevMoments,
      periodLabel: prevPeriodLabel,
    );

    // 4. Compute Activity Ring Ratio (based on typical target for timeframe)
    final ringRatio = _computeRingRatio(
      timeframe: timeframe,
      trackedMinutes: totalTracked.inMinutes,
      momentCount: totalMoments,
    );

    // 5. Intelligent Time-Slot Bias
    final timeSlotBias = _computeTimeSlotBias(
      currentEntries.isNotEmpty ? currentEntries : entries,
    );

    // 6. 7-Day Consistency Rhythm (Mon - Sun)
    final dailyRhythm = _computeDailyRhythm(entries, now);

    // 7. Focus Category Breakdown
    final focusBreakdown = _computeFocusBreakdown(currentEntries, p);

    // 8. 90-Day Activity Grid & Streaks
    final gridStats = _computeGridStats(entries, now);

    return ExecutiveDashboardData(
      timeframe: timeframe,
      totalTracked: totalTracked,
      totalMoments: totalMoments,
      paceText: paceText,
      paceIsPositive: paceIsPositive,
      activityRingRatio: ringRatio,
      timeSlotBias: timeSlotBias,
      dailyRhythm: dailyRhythm,
      focusBreakdown: focusBreakdown,
      gridStats: gridStats,
    );
  }

  static (List<Moment>, List<Moment>, String) _filterTimeframes(
    List<Moment> allEntries,
    DashboardTimeframe timeframe,
    DateTime now,
  ) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    switch (timeframe) {
      case DashboardTimeframe.today:
        final current = allEntries.where((e) {
          final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
          return dt.isAfter(todayStart);
        }).toList();
        final prev = allEntries.where((e) {
          final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
          return dt.isAfter(yesterdayStart) && dt.isBefore(todayStart);
        }).toList();
        return (current, prev, 'yesterday');

      case DashboardTimeframe.week:
        final weekStart = todayStart.subtract(const Duration(days: 7));
        final prevWeekStart = weekStart.subtract(const Duration(days: 7));
        final current = allEntries.where((e) {
          final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
          return dt.isAfter(weekStart);
        }).toList();
        final prev = allEntries.where((e) {
          final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
          return dt.isAfter(prevWeekStart) && dt.isBefore(weekStart);
        }).toList();
        return (current, prev, 'last week');

      case DashboardTimeframe.month:
        final monthStart = todayStart.subtract(const Duration(days: 30));
        final prevMonthStart = monthStart.subtract(const Duration(days: 30));
        final current = allEntries.where((e) {
          final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
          return dt.isAfter(monthStart);
        }).toList();
        final prev = allEntries.where((e) {
          final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
          return dt.isAfter(prevMonthStart) && dt.isBefore(monthStart);
        }).toList();
        return (current, prev, 'last month');

      case DashboardTimeframe.all:
        return (allEntries, [], 'previous');
    }
  }

  static (String, bool) _computePace({
    required int currentCount,
    required int prevCount,
    required String periodLabel,
  }) {
    if (prevCount == 0) {
      if (currentCount > 0) {
        return ('Active tracking ($currentCount logs)', true);
      }
      return ('No activity yet', false);
    }
    final diff = currentCount - prevCount;
    final pct = ((diff / prevCount) * 100).round();
    if (pct > 0) {
      return ('+$pct% vs $periodLabel', true);
    } else if (pct < 0) {
      return ('$pct% vs $periodLabel', false);
    } else {
      return ('Same pace as $periodLabel', true);
    }
  }

  static double _computeRingRatio({
    required DashboardTimeframe timeframe,
    required int trackedMinutes,
    required int momentCount,
  }) {
    // Healthy expected target per timeframe
    final targetMinutes = switch (timeframe) {
      DashboardTimeframe.today => 240, // 4 hours
      DashboardTimeframe.week => 1200, // 20 hours
      DashboardTimeframe.month => 4800, // 80 hours
      DashboardTimeframe.all => 6000,
    };

    if (trackedMinutes > 0) {
      final ratio = trackedMinutes / targetMinutes;
      return ratio.clamp(0.05, 1.0);
    }
    // Fallback based on moment count
    final targetMoments = switch (timeframe) {
      DashboardTimeframe.today => 8,
      DashboardTimeframe.week => 40,
      DashboardTimeframe.month => 150,
      DashboardTimeframe.all => 200,
    };
    final countRatio = momentCount / targetMoments;
    return countRatio.clamp(0.0, 1.0);
  }

  static TimeSlotBiasData _computeTimeSlotBias(List<Moment> entries) {
    if (entries.isEmpty) {
      return const TimeSlotBiasData(
        headline: 'Log moments to reveal your productivity time slot rhythm.',
        peakSlotName: 'None',
        slots: [
          TimeSlotStat(
            name: 'Morning',
            rangeLabel: '6 AM – 12 PM',
            count: 0,
            percentage: 0,
            isPeak: false,
          ),
          TimeSlotStat(
            name: 'Afternoon',
            rangeLabel: '12 PM – 5 PM',
            count: 0,
            percentage: 0,
            isPeak: false,
          ),
          TimeSlotStat(
            name: 'Evening',
            rangeLabel: '5 PM – 10 PM',
            count: 0,
            percentage: 0,
            isPeak: false,
          ),
          TimeSlotStat(
            name: 'Night',
            rangeLabel: '10 PM – 6 AM',
            count: 0,
            percentage: 0,
            isPeak: false,
          ),
        ],
      );
    }

    int morning = 0;
    int afternoon = 0;
    int evening = 0;
    int night = 0;

    for (final e in entries) {
      final hour = DateTime.fromMillisecondsSinceEpoch(e.timestamp).hour;
      if (hour >= 6 && hour < 12) {
        morning++;
      } else if (hour >= 12 && hour < 17) {
        afternoon++;
      } else if (hour >= 17 && hour < 22) {
        evening++;
      } else {
        night++;
      }
    }

    final total = entries.length;
    final mPct = (morning / total * 100).round();
    final aPct = (afternoon / total * 100).round();
    final ePct = (evening / total * 100).round();
    final nPct = (night / total * 100).round();

    int maxCount = morning;
    String peak = 'Morning';
    if (afternoon > maxCount) {
      maxCount = afternoon;
      peak = 'Afternoon';
    }
    if (evening > maxCount) {
      maxCount = evening;
      peak = 'Evening';
    }
    if (night > maxCount) {
      maxCount = night;
      peak = 'Night';
    }

    final peakPct = (maxCount / total * 100).round();
    final peakRange = switch (peak) {
      'Morning' => '6 AM – 12 PM',
      'Afternoon' => '12 PM – 5 PM',
      'Evening' => '5 PM – 10 PM',
      _ => '10 PM – 6 AM',
    };

    final headline = 'You are $peakPct% more active during $peak ($peakRange)';

    final slots = [
      TimeSlotStat(
        name: 'Morning',
        rangeLabel: '6 AM – 12 PM',
        count: morning,
        percentage: mPct,
        isPeak: peak == 'Morning',
      ),
      TimeSlotStat(
        name: 'Afternoon',
        rangeLabel: '12 PM – 5 PM',
        count: afternoon,
        percentage: aPct,
        isPeak: peak == 'Afternoon',
      ),
      TimeSlotStat(
        name: 'Evening',
        rangeLabel: '5 PM – 10 PM',
        count: evening,
        percentage: ePct,
        isPeak: peak == 'Evening',
      ),
      TimeSlotStat(
        name: 'Night',
        rangeLabel: '10 PM – 6 AM',
        count: night,
        percentage: nPct,
        isPeak: peak == 'Night',
      ),
    ];

    return TimeSlotBiasData(
      headline: headline,
      peakSlotName: peak,
      slots: slots,
    );
  }

  static DailyRhythmData _computeDailyRhythm(
    List<Moment> entries,
    DateTime now,
  ) {
    final Map<int, int> weekdayCount = {for (int i = 1; i <= 7; i++) i: 0};
    final Map<int, int> weekdayTrackedMs = {for (int i = 1; i <= 7; i++) i: 0};

    // Calculate over last 7 days
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final k = dateKey(d);
      final dayEntries = entries.where((e) => e.date == k).toList();
      weekdayCount[d.weekday] = dayEntries.length;

      final sections = buildTimelineDaySections(dayEntries);
      int dayMs = 0;
      for (final s in sections) {
        dayMs += s.totalTrackedDuration.inMilliseconds;
      }
      weekdayTrackedMs[d.weekday] = dayMs;
    }

    final days = <DayRhythmStat>[];
    const weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    for (int w = 1; w <= 7; w++) {
      days.add(
        DayRhythmStat(
          dayLabel: weekdayLabels[w - 1],
          trackedDuration: Duration(milliseconds: weekdayTrackedMs[w] ?? 0),
          count: weekdayCount[w] ?? 0,
          isToday: w == now.weekday,
        ),
      );
    }

    int weekdaysTotal = 0;
    for (int w = 1; w <= 5; w++) {
      weekdaysTotal += weekdayCount[w] ?? 0;
    }
    int weekendsTotal = (weekdayCount[6] ?? 0) + (weekdayCount[7] ?? 0);

    final double weekdayAvg = weekdaysTotal / 5.0;
    final double weekendAvg = weekendsTotal / 2.0;

    String compText = 'Balanced rhythm across weekdays and weekends.';
    if (weekdayAvg > weekendAvg && weekendAvg > 0) {
      final pct = (((weekdayAvg - weekendAvg) / weekendAvg) * 100).round();
      compText = 'Weekday vs Weekend: You log $pct% more on weekdays.';
    } else if (weekendAvg > weekdayAvg && weekdayAvg > 0) {
      final pct = (((weekendAvg - weekdayAvg) / weekdayAvg) * 100).round();
      compText = 'Weekday vs Weekend: You log $pct% more on weekends.';
    }

    return DailyRhythmData(days: days, comparisonText: compText);
  }

  static FocusBreakdownData _computeFocusBreakdown(
    List<Moment> entries,
    Palette p,
  ) {
    final Map<String, int> catMs = {};
    final Map<String, int> catCounts = {};

    final sections = buildTimelineDaySections(entries);

    // Group session durations by note tags
    for (final sec in sections) {
      for (final it in sec.items) {
        if (it is TimelineSessionItem) {
          final cat = _extractCategory(it.note);
          catMs[cat] = (catMs[cat] ?? 0) + it.duration.inMilliseconds;
          catCounts[cat] = (catCounts[cat] ?? 0) + 1;
        } else if (it is TimelineSingleItem) {
          final cat = _extractCategory(it.moment.note);
          catCounts[cat] = (catCounts[cat] ?? 0) + 1;
          // Approximate 15m for standalone singles if no duration
          catMs[cat] =
              (catMs[cat] ?? 0) + const Duration(minutes: 15).inMilliseconds;
        }
      }
    }

    if (catMs.isEmpty) {
      return const FocusBreakdownData(categories: []);
    }

    final totalMs = catMs.values.fold<int>(0, (a, b) => a + b);
    final sortedKeys = catMs.keys.toList()
      ..sort((a, b) => (catMs[b] ?? 0).compareTo(catMs[a] ?? 0));

    final colors = [
      p.accent,
      p.green,
      p.orange,
      const Color(0xFF00E5FF),
      p.red,
      const Color(0xFF9C27B0),
    ];

    final result = <FocusCategoryStat>[];
    for (int i = 0; i < sortedKeys.length; i++) {
      final cat = sortedKeys[i];
      final ms = catMs[cat] ?? 0;
      final pct = totalMs > 0 ? ((ms / totalMs) * 100).round() : 0;
      result.add(
        FocusCategoryStat(
          name: cat,
          color: colors[i % colors.length],
          duration: Duration(milliseconds: ms),
          percentage: pct,
          count: catCounts[cat] ?? 0,
        ),
      );
    }

    return FocusBreakdownData(categories: result);
  }

  static String _extractCategory(String note) {
    final lower = note.toLowerCase().trim();
    if (lower.isEmpty) return 'Untagged Singles';

    final tagMatch = RegExp(r'#(\w+)').firstMatch(lower);
    if (tagMatch != null) {
      final tag = tagMatch.group(1)!;
      return '#$tag';
    }

    if (lower.contains('work') ||
        lower.contains('code') ||
        lower.contains('deploy') ||
        lower.contains('backend') ||
        lower.contains('frontend')) {
      return 'Deep Work';
    }
    if (lower.contains('study') ||
        lower.contains('read') ||
        lower.contains('book') ||
        lower.contains('chapter')) {
      return 'Study / Reading';
    }
    if (lower.contains('gym') ||
        lower.contains('run') ||
        lower.contains('water') ||
        lower.contains('health') ||
        lower.contains('walk')) {
      return 'Health / Exercise';
    }
    if (lower.contains('call') ||
        lower.contains('meet') ||
        lower.contains('client') ||
        lower.contains('sync')) {
      return 'Meetings / Calls';
    }

    return 'Quick Notes';
  }

  static ActivityGridStats _computeGridStats(
    List<Moment> entries,
    DateTime now,
  ) {
    final Map<String, int> intensities = {};
    for (final e in entries) {
      intensities[e.date] = (intensities[e.date] ?? 0) + 1;
    }

    int activeCount = 0;
    const totalDays = 90;
    for (int i = 0; i < totalDays; i++) {
      final d = now.subtract(Duration(days: i));
      final k = dateKey(d);
      if ((intensities[k] ?? 0) > 0) {
        activeCount++;
      }
    }

    // Streaks
    int longest = 0;
    int current = 0;
    int running = 0;

    // Check today or yesterday for current streak
    final todayKey = dateKey(now);
    final yesterdayKey = dateKey(now.subtract(const Duration(days: 1)));
    bool hasRecent =
        (intensities[todayKey] ?? 0) > 0 ||
        (intensities[yesterdayKey] ?? 0) > 0;

    // Check day by day backwards
    if (hasRecent) {
      int checkDay = (intensities[todayKey] ?? 0) > 0 ? 0 : 1;
      while (true) {
        final d = now.subtract(Duration(days: checkDay));
        final k = dateKey(d);
        if ((intensities[k] ?? 0) > 0) {
          current++;
          checkDay++;
        } else {
          break;
        }
      }
    }

    // Longest streak in past 90 days
    for (int i = totalDays - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final k = dateKey(d);
      if ((intensities[k] ?? 0) > 0) {
        running++;
        if (running > longest) longest = running;
      } else {
        running = 0;
      }
    }

    return ActivityGridStats(
      longestStreak: longest,
      currentStreak: current,
      activeDaysCount: activeCount,
      totalDaysCount: totalDays,
      dayIntensities: intensities,
    );
  }
}
