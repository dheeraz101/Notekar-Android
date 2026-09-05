import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/dashboard_metrics_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Segmented tab control for switching dashboard timeframes (Today, Week, Month, All).
class TimeframeSegmentedControl extends StatelessWidget {
  const TimeframeSegmentedControl({
    super.key,
    required this.p,
    required this.selected,
    required this.onChanged,
  });

  final Palette p;
  final DashboardTimeframe selected;
  final ValueChanged<DashboardTimeframe> onChanged;

  @override
  Widget build(BuildContext context) {
    final values = DashboardTimeframe.values;
    final selectedIndex = values.indexOf(selected);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border.withValues(alpha: 0.6)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / values.length;

          return Stack(
            children: [
              // Single sliding thumb indicator (smooth iOS UISegmentedControl physics)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: p.accent.withValues(alpha: 0.28),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab text buttons
              Row(
                children: [
                  for (final tf in values)
                    Expanded(
                      child: PressableScale(
                        onTap: () {
                          if (tf != selected) {
                            NotekarHaptics.selection('standard');
                            onChanged(tf);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: TextStyle(
                              color: tf == selected ? Colors.white : p.text3,
                              fontSize: 12.5,
                              fontWeight: tf == selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                            child: Text(
                              tf.label.localized(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Hero card featuring circular activity ring and core glance metrics.
class HeroActivityRingCard extends StatelessWidget {
  const HeroActivityRingCard({super.key, required this.p, required this.data});

  final Palette p;
  final ExecutiveDashboardData data;

  @override
  Widget build(BuildContext context) {
    final ringPct = (data.activityRingRatio * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          // Circular Activity Ring
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: data.activityRingRatio,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: p.surface3,
                    valueColor: AlwaysStoppedAnimation<Color>(p.accent),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$ringPct%',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Glance Metrics Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: p.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Total Tracked: '.localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        data.formattedTotalTracked,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Moments pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: p.surface3.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: p.border.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 13,
                              color: p.text3,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${data.totalMoments} logs',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Pace pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (data.paceIsPositive ? p.green : p.orange)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (data.paceIsPositive ? p.green : p.orange)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              data.paceIsPositive
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 13,
                              color: data.paceIsPositive ? p.green : p.orange,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data.paceText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: data.paceIsPositive
                                      ? p.green
                                      : p.orange,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Focused Intelligent Time-Slot Bias card with horizontal visual distribution bars.
class IntelligentTimeSlotBiasCard extends StatelessWidget {
  const IntelligentTimeSlotBiasCard({
    super.key,
    required this.p,
    required this.data,
  });

  final Palette p;
  final TimeSlotBiasData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.accent.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: p.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Time-Slot Intelligence'.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (data.peakSlotName != 'None')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: p.accent.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '★ ${data.peakSlotName.toUpperCase()}',
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Dynamic Narrative
          Text(
            '"${data.headline}"',
            style: TextStyle(
              color: p.text2,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 16),

          // Distribution Bars
          for (final slot in data.slots) ...[
            _buildSlotBarRow(context, slot),
            if (slot != data.slots.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildSlotBarRow(BuildContext context, TimeSlotStat slot) {
    final barRatio = (slot.percentage / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    slot.name.localized(context),
                    style: TextStyle(
                      color: slot.isPeak ? p.text : p.text2,
                      fontSize: 12,
                      fontWeight: slot.isPeak
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '(${slot.rangeLabel})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: p.text3, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${slot.percentage}%',
                  style: TextStyle(
                    color: slot.isPeak ? p.accent : p.text2,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (slot.isPeak) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.star_rounded, size: 12, color: p.accent),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Horizontal Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 7,
            width: double.infinity,
            color: p.surface3,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: barRatio > 0 ? math.max(barRatio, 0.03) : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: slot.isPeak
                      ? p.accent
                      : p.text3.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 7-day daily rhythm consistency bar chart (Mon - Sun).
class DailyRhythmBarChart extends StatelessWidget {
  const DailyRhythmBarChart({super.key, required this.p, required this.data});

  final Palette p;
  final DailyRhythmData data;

  @override
  Widget build(BuildContext context) {
    final maxMinutes = data.days
        .map((d) => d.trackedDuration.inMinutes)
        .fold<int>(1, (prev, val) => math.max(prev, val));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 18, color: p.accent),
              const SizedBox(width: 8),
              Text(
                'Daily Rhythm (Mon – Sun)'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 7-day bar chart
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in data.days)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Duration text above bar
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            day.trackedDuration.inHours > 0
                                ? '${day.trackedDuration.inHours}h'
                                : (day.trackedDuration.inMinutes > 0
                                      ? '${day.trackedDuration.inMinutes}m'
                                      : (day.count > 0 ? '${day.count}' : '·')),
                            style: TextStyle(
                              color: day.isToday ? p.accent : p.text3,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bar (Anchored at the bottom so low bars rise from the baseline)
                        Expanded(
                          child: FractionallySizedBox(
                            alignment: Alignment.bottomCenter,
                            heightFactor: maxMinutes > 0
                                ? (day.trackedDuration.inMinutes / maxMinutes)
                                      .clamp(0.06, 1.0)
                                : 0.06,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: day.isToday
                                    ? p.accent
                                    : (day.count > 0
                                          ? p.accent.withValues(alpha: 0.4)
                                          : p.surface3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Weekday label
                        Text(
                          day.dayLabel,
                          style: TextStyle(
                            color: day.isToday ? p.accent : p.text2,
                            fontSize: 11,
                            fontWeight: day.isToday
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Weekday vs Weekend Comparison
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.surface3.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: p.text3),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.comparisonText.localized(context),
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 11.5,
                      height: 1.3,
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
}

/// Category and Tag distribution card.
class FocusTagBreakdownCard extends StatelessWidget {
  const FocusTagBreakdownCard({super.key, required this.p, required this.data});

  final Palette p;
  final FocusBreakdownData data;

  @override
  Widget build(BuildContext context) {
    if (data.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label_outline_rounded, size: 18, color: p.accent),
              const SizedBox(width: 8),
              Text(
                'Focus Breakdown'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Multi-color segmented distribution bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              width: double.infinity,
              child: Row(
                children: [
                  for (final cat in data.categories)
                    Flexible(
                      flex: math.max(cat.percentage, 1),
                      child: Container(
                        color: cat.color,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Category List Rows
          for (final cat in data.categories) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: cat.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatDuration(cat.duration)} (${cat.percentage}%)',
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            if (cat != data.categories.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes;
    if (mins <= 0) return '0m';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}

/// 90-day activity matrix with streaks & consistency stats.
class YearlyActivityGridCard extends StatelessWidget {
  const YearlyActivityGridCard({
    super.key,
    required this.p,
    required this.stats,
  });

  final Palette p;
  final ActivityGridStats stats;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.grid_view_rounded, size: 18, color: p.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activity Grid'.localized(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: p.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '(Last 90 Days)'.localized(context),
                            style: TextStyle(
                              color: p.text3,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${stats.activeDaysCount}/${stats.totalDaysCount} Days',
                  style: TextStyle(
                    color: p.green,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 90-day Matrix
          LayoutBuilder(
            builder: (context, constraints) {
              const columns = 15;
              const rows = 6;
              final cellWidth =
                  (constraints.maxWidth - (columns - 1) * 3) / columns;

              return Column(
                children: [
                  for (int r = 0; r < rows; r++) ...[
                    Row(
                      children: [
                        for (int c = 0; c < columns; c++) ...[
                          _buildGridCell(
                            now,
                            (rows - 1 - r) * columns + (columns - 1 - c),
                            cellWidth,
                          ),
                          if (c < columns - 1) const SizedBox(width: 3),
                        ],
                      ],
                    ),
                    if (r < rows - 1) const SizedBox(height: 3),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Streak badges footer
          Row(
            children: [
              Expanded(
                child: _buildStreakCard(
                  icon: Icons.local_fire_department_rounded,
                  color: p.orange,
                  label: 'Current Streak'.localized(context),
                  value: '${stats.currentStreak} days',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStreakCard(
                  icon: Icons.emoji_events_rounded,
                  color: p.accent,
                  label: 'Longest Streak'.localized(context),
                  value: '${stats.longestStreak} days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell(DateTime now, int dayOffset, double size) {
    final day = now.subtract(Duration(days: dayOffset));
    final k = dateKey(day);
    final count = stats.dayIntensities[k] ?? 0;

    Color cellColor = p.surface3;
    if (count >= 5) {
      cellColor = p.green;
    } else if (count >= 3) {
      cellColor = p.green.withValues(alpha: 0.7);
    } else if (count >= 1) {
      cellColor = p.green.withValues(alpha: 0.35);
    }

    return Container(
      width: size,
      height: 9,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStreakCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: p.surface3.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: p.text,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
