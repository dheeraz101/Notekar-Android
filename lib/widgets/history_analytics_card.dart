import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({
    super.key,
    required this.p,
    required this.entries,
  });

  final Palette p;
  final List<Moment> entries;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = dateKey(now);
    final yesterdayStr = dateKey(now.subtract(const Duration(days: 1)));

    final todayEntries = entries.where((e) => e.date == todayStr).toList();
    final yesterdayEntries = entries
        .where((e) => e.date == yesterdayStr)
        .toList();

    final todayCount = todayEntries.length;
    final yesterdayCount = yesterdayEntries.length;
    final diff = todayCount - yesterdayCount;

    final diffText = diff > 0
        ? '+$diff logs vs yesterday'
        : (diff < 0
              ? '${diff.abs()} fewer logs than yesterday'
              : 'Same count as yesterday');

    // Calculate Average Interval between consecutive moments
    int avgIntervalMinutes = 0;
    if (entries.length > 1) {
      int totalDiffMs = 0;
      int count = 0;
      for (int i = 0; i < entries.length - 1; i++) {
        final diffMs = (entries[i].timestamp - entries[i + 1].timestamp).abs();
        if (diffMs <= 24 * 60 * 60 * 1000) {
          totalDiffMs += diffMs;
          count++;
        }
      }
      if (count > 0) {
        avgIntervalMinutes = (totalDiffMs / count / 60000).round();
      }
    }

    final inCount = entries.where((e) => e.type == 'in').length;
    final outCount = entries.where((e) => e.type == 'out').length;
    final totalInOut = inCount + outCount;
    final inRatio = totalInOut > 0 ? inCount / totalInOut : 0.5;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: p.accent,
                    size: 17,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Summary',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      diffText,
                      style: TextStyle(
                        color: diff > 0
                            ? p.green
                            : (diff < 0 ? p.orange : p.text3),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatMetric(
                  p: p,
                  label: 'Today',
                  value: '$todayCount',
                  sub: 'moments',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: p.border.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _StatMetric(
                  p: p,
                  label: 'Avg Interval',
                  value: avgIntervalMinutes > 0
                      ? '${avgIntervalMinutes}m'
                      : '--',
                  sub: 'between taps',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: p.border.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _StatMetric(
                  p: p,
                  label: 'Total Logs',
                  value: '${entries.length}',
                  sub: 'recorded',
                ),
              ),
            ],
          ),
          if (totalInOut > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: (inRatio * 100).round(),
                      child: Container(color: p.accent),
                    ),
                    Expanded(
                      flex: ((1 - inRatio) * 100).round(),
                      child: Container(color: p.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'IN ($inCount)',
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'OUT ($outCount)',
                  style: TextStyle(
                    color: p.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ActivityTrendsCard extends StatelessWidget {
  const ActivityTrendsCard({super.key, required this.p, required this.entries});

  final Palette p;
  final List<Moment> entries;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayCounts = <_DayStat>[];
    int maxDayCount = 1;
    int weeklyTotal = 0;
    String peakDayName = 'None';
    int peakCount = 0;

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final k = dateKey(day);
      final c = entries.where((e) => e.date == k).length;
      weeklyTotal += c;
      if (c > maxDayCount) maxDayCount = c;
      if (c > peakCount) {
        peakCount = c;
        peakDayName = _weekdayFull(day.weekday);
      }
      dayCounts.add(
        _DayStat(
          dayLabel: _weekdayShort(day.weekday),
          count: c,
          isToday: i == 0,
        ),
      );
    }

    final subtitleText = peakCount > 0
        ? 'Weekly total: $weeklyTotal logs • Peak: $peakDayName ($peakCount)'
        : 'No moments captured over the last 7 days';

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: p.orange.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    color: p.orange,
                    size: 17,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7-Day Activity Trends',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Upper Labels Region - Fixed alignment
          SizedBox(
            height: 14,
            child: Row(
              children: [
                for (final ds in dayCounts)
                  Expanded(
                    child: Center(
                      child: Text(
                        ds.count > 0 ? '${ds.count}' : '',
                        style: TextStyle(
                          color: ds.isToday ? p.accent : p.text2,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Bars Region
          SizedBox(
            height: 40,
            child: Row(
              children: [
                for (final ds in dayCounts)
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 18,
                        height: math.max(6.0, (ds.count / maxDayCount) * 40.0),
                        decoration: BoxDecoration(
                          color: ds.isToday
                              ? p.accent
                              : (ds.count > 0
                                    ? p.accent.withValues(alpha: 0.45)
                                    : p.border.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Fixed Bottom Baseline Day Labels Region
          SizedBox(
            height: 18,
            child: Row(
              children: [
                for (final ds in dayCounts)
                  Expanded(
                    child: Center(
                      child: Text(
                        ds.dayLabel,
                        style: TextStyle(
                          color: ds.isToday ? p.accent : p.text3,
                          fontSize: 11,
                          fontWeight: ds.isToday
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _weekdayShort(int w) {
    return switch (w) {
      DateTime.monday => 'M',
      DateTime.tuesday => 'T',
      DateTime.wednesday => 'W',
      DateTime.thursday => 'T',
      DateTime.friday => 'F',
      DateTime.saturday => 'S',
      DateTime.sunday => 'S',
      _ => '',
    };
  }

  static String _weekdayFull(int w) {
    return switch (w) {
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      DateTime.saturday => 'Saturday',
      DateTime.sunday => 'Sunday',
      _ => '',
    };
  }
}

class _DayStat {
  const _DayStat({
    required this.dayLabel,
    required this.count,
    required this.isToday,
  });

  final String dayLabel;
  final int count;
  final bool isToday;
}

class _StatMetric extends StatelessWidget {
  const _StatMetric({
    required this.p,
    required this.label,
    required this.value,
    required this.sub,
  });

  final Palette p;
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: p.text3,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: p.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        Text(sub, style: TextStyle(color: p.text2, fontSize: 10)),
      ],
    );
  }
}

class ActivityHeatmapCard extends StatelessWidget {
  const ActivityHeatmapCard({
    super.key,
    required this.p,
    required this.entries,
  });

  final Palette p;
  final List<Moment> entries;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 370));
    final alignmentDays = startDate.weekday - DateTime.monday;
    final gridStartDate = startDate.subtract(Duration(days: alignmentDays));

    final countMap = <String, int>{};
    for (final entry in entries) {
      countMap[entry.date] = (countMap[entry.date] ?? 0) + 1;
    }

    final List<Widget> columns = [];
    DateTime runner = gridStartDate;

    while (runner.isBefore(now) || dateKey(runner) == dateKey(now)) {
      final List<Widget> dayCells = [];
      for (int d = 0; d < 7; d++) {
        final currentDay = runner.add(Duration(days: d));
        final key = dateKey(currentDay);
        final count = countMap[key] ?? 0;

        Color cellColor;
        if (currentDay.isAfter(now)) {
          cellColor = Colors.transparent;
        } else if (count == 0) {
          cellColor = p.border.withValues(alpha: 0.15);
        } else if (count <= 2) {
          cellColor = p.accent.withValues(alpha: 0.25);
        } else if (count <= 4) {
          cellColor = p.accent.withValues(alpha: 0.55);
        } else {
          cellColor = p.accent;
        }

        dayCells.add(
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(2.5),
              border: count == 0
                  ? Border.all(
                      color: p.border.withValues(alpha: 0.2),
                      width: 0.5,
                    )
                  : null,
            ),
          ),
        );
      }

      columns.add(Column(mainAxisSize: MainAxisSize.min, children: dayCells));

      runner = runner.add(const Duration(days: 7));
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: p.green.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.grid_on_rounded, color: p.green, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Heatmap',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your tap density over the past year',
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(mainAxisSize: MainAxisSize.min, children: columns),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less ', style: TextStyle(color: p.text3, fontSize: 10)),
              _buildLegendCell(p.border.withValues(alpha: 0.15), p),
              _buildLegendCell(p.accent.withValues(alpha: 0.25), p),
              _buildLegendCell(p.accent.withValues(alpha: 0.55), p),
              _buildLegendCell(p.accent, p),
              Text(' More', style: TextStyle(color: p.text3, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCell(Color color, Palette p) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.5),
        border: color == p.border.withValues(alpha: 0.15)
            ? Border.all(color: p.border.withValues(alpha: 0.2), width: 0.5)
            : null,
      ),
    );
  }
}

class IntelligentInsightsCard extends StatelessWidget {
  const IntelligentInsightsCard({
    super.key,
    required this.p,
    required this.entries,
  });

  final Palette p;
  final List<Moment> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: p.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tips_and_updates_outlined,
                    color: p.accent,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intelligent Insights',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Log correlation and activity highlights',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_graph_rounded,
                      color: p.text3.withValues(alpha: 0.5),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No correlation data available',
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Log some moments to calculate correlation and insights.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: p.text3, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    int morning = 0;
    int afternoon = 0;
    int evening = 0;
    int night = 0;

    int weekdaysCount = 0;
    int weekendsCount = 0;

    final dayCounts = List<int>.filled(8, 0);

    for (final entry in entries) {
      final dt = DateTime.fromMillisecondsSinceEpoch(entry.timestamp);
      final hour = dt.hour;

      if (hour >= 6 && hour < 12) {
        morning++;
      } else if (hour >= 12 && hour < 17) {
        afternoon++;
      } else if (hour >= 17 && hour < 22) {
        evening++;
      } else {
        night++;
      }

      if (dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday) {
        weekendsCount++;
      } else {
        weekdaysCount++;
      }

      dayCounts[dt.weekday]++;
    }

    final total = entries.length;

    String peakSlot = 'Afternoon';
    int peakSlotCount = afternoon;
    if (morning > peakSlotCount) {
      peakSlot = 'Morning';
      peakSlotCount = morning;
    }
    if (evening > peakSlotCount) {
      peakSlot = 'Evening';
      peakSlotCount = evening;
    }
    if (night > peakSlotCount) {
      peakSlot = 'Night';
      peakSlotCount = night;
    }
    final peakPercentage = total > 0
        ? (peakSlotCount / total * 100).round()
        : 0;

    int peakDayIdx = 1;
    for (int i = 2; i <= 7; i++) {
      if (dayCounts[i] > dayCounts[peakDayIdx]) {
        peakDayIdx = i;
      }
    }
    final peakDayName = _weekdayFull(peakDayIdx);

    final double weekdayDensity = weekdaysCount / 5.0;
    final double weekendDensity = weekendsCount / 2.0;
    String densityCompare = 'You log equally throughout the week.';
    if (weekdayDensity > weekendDensity && weekendDensity > 0) {
      final pct = (((weekdayDensity - weekendDensity) / weekendDensity) * 100)
          .round();
      densityCompare = 'You are $pct% more active on weekdays than weekends.';
    } else if (weekendDensity > weekdayDensity && weekdayDensity > 0) {
      final pct = (((weekendDensity - weekdayDensity) / weekdayDensity) * 100)
          .round();
      densityCompare = 'You are $pct% more active on weekends than weekdays.';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.tips_and_updates_outlined,
                  color: p.accent,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Intelligent Insights',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Log correlation and activity highlights',
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildInsightRow(
            Icons.access_time_rounded,
            'Time Slot Bias',
            'Your peak slot is $peakSlot ($peakPercentage% of logs).',
            p,
          ),
          const Divider(height: 24, thickness: 0.5, color: Colors.transparent),
          _buildInsightRow(
            Icons.calendar_today_rounded,
            'Weekly Pattern',
            densityCompare,
            p,
          ),
          const Divider(height: 24, thickness: 0.5, color: Colors.transparent),
          _buildInsightRow(
            Icons.star_outline_rounded,
            'Peak Performance Day',
            'You log most consistently on ${peakDayName}s.',
            p,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String title, String body, Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: p.accent, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: p.text,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            body,
            style: TextStyle(color: p.text2, fontSize: 12.5, height: 1.35),
          ),
        ),
      ],
    );
  }

  String _weekdayFull(int w) {
    return switch (w) {
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      DateTime.saturday => 'Saturday',
      DateTime.sunday => 'Sunday',
      _ => '',
    };
  }
}

class AnomalyAlertCard extends StatelessWidget {
  const AnomalyAlertCard({
    super.key,
    required this.p,
    required this.entries,
    required this.onLogNow,
  });

  final Palette p;
  final List<Moment> entries;
  final VoidCallback onLogNow;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final lastLog = entries.first;
    final lastLogTime = DateTime.fromMillisecondsSinceEpoch(lastLog.timestamp);
    final now = DateTime.now();
    final difference = now.difference(lastLogTime);

    if (difference.inHours < 48) {
      return const SizedBox.shrink();
    }

    final days = difference.inDays;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.red.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: p.red.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: p.red,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logging Gap Detected',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'It has been $days days since your last log.',
                      style: TextStyle(
                        color: p.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Keep your logs consistent to compile accurate correlation graphs and activity heatmaps.',
            style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: p.red,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: onLogNow,
            child: const Text(
              'Log Moment Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
