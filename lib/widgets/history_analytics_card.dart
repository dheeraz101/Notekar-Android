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
    if (entries.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final todayStr = dateKey(now);
    final yesterdayStr = dateKey(now.subtract(const Duration(days: 1)));

    final todayEntries = entries.where((e) => e.date == todayStr).toList();
    final yesterdayEntries = entries.where((e) => e.date == yesterdayStr).toList();

    final todayCount = todayEntries.length;
    final yesterdayCount = yesterdayEntries.length;
    final diff = todayCount - yesterdayCount;
    final diffStr = diff > 0 ? '+$diff from yesterday' : (diff < 0 ? '$diff from yesterday' : 'Same as yesterday');

    // Calculate Average Interval between consecutive moments
    int avgIntervalMinutes = 0;
    if (entries.length > 1) {
      int totalDiffMs = 0;
      int count = 0;
      for (int i = 0; i < entries.length - 1; i++) {
        final diffMs = (entries[i].timestamp - entries[i + 1].timestamp).abs();
        // Ignore multi-day gaps (> 24h) for realistic intra-day averages
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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.analytics_rounded, color: p.accent, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Activity Summary',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  diffStr,
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
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
