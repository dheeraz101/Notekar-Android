import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

class HistoryAnalyticsCard extends StatelessWidget {
  const HistoryAnalyticsCard({
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
    final yesterdayEntries = entries.where((e) => e.date == yesterdayStr).toList();

    final todayCount = todayEntries.length;
    final yesterdayCount = yesterdayEntries.length;
    final diff = todayCount - yesterdayCount;

    final diffText = diff > 0
        ? '+$diff logs vs yesterday'
        : (diff < 0 ? '${diff.abs()} fewer logs than yesterday' : 'Same count as yesterday');

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

    // 7-day counts for iOS bar chart
    final dayCounts = <_DayStat>[];
    int maxDayCount = 1;
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final k = dateKey(day);
      final c = entries.where((e) => e.date == k).length;
      if (c > maxDayCount) maxDayCount = c;
      dayCounts.add(_DayStat(
        dayLabel: _weekdayShort(day.weekday),
        count: c,
        isToday: i == 0,
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                child: Icon(Icons.analytics_rounded, color: p.accent, size: 17),
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
          // 3 Core Metrics
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
              Container(width: 1, height: 32, color: p.border.withValues(alpha: 0.4)),
              Expanded(
                child: _StatMetric(
                  p: p,
                  label: 'Avg Interval',
                  value: avgIntervalMinutes > 0 ? '${avgIntervalMinutes}m' : '--',
                  sub: 'between taps',
                ),
              ),
              Container(width: 1, height: 32, color: p.border.withValues(alpha: 0.4)),
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
          const SizedBox(height: 20),
          // iOS 7-Day Bar Chart
          Text(
            'LAST 7 DAYS',
            style: TextStyle(
              color: p.text3,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final ds in dayCounts)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        ds.count > 0 ? '${ds.count}' : '',
                        style: TextStyle(
                          color: ds.isToday ? p.accent : p.text3,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 18,
                        height: math.max(6.0, (ds.count / maxDayCount) * 36.0),
                        decoration: BoxDecoration(
                          color: ds.isToday
                              ? p.accent
                              : (ds.count > 0
                                  ? p.accent.withValues(alpha: 0.4)
                                  : p.border.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ds.dayLabel,
                        style: TextStyle(
                          color: ds.isToday ? p.accent : p.text3,
                          fontSize: 11,
                          fontWeight: ds.isToday ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
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
                  style: TextStyle(color: p.accent, fontSize: 10, fontWeight: FontWeight.w700),
                ),
                Text(
                  'OUT ($outCount)',
                  style: TextStyle(color: p.green, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
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
          style: TextStyle(color: p.text3, fontSize: 11, fontWeight: FontWeight.w500),
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
        Text(
          sub,
          style: TextStyle(color: p.text2, fontSize: 10),
        ),
      ],
    );
  }
}
