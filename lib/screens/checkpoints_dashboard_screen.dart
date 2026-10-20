import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/checkpoint_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Flagship Apple HIG Checkpoints & Habits Consistency Dashboard.
/// Tracks routine habit execution (Waking Up, Bedtime, Bathing, Breakfast, etc.),
/// timing variance (mean time μ, standard deviation ±σ), streaks, and 7-day completion matrices.
class CheckpointsDashboardScreen extends StatefulWidget {
  const CheckpointsDashboardScreen({
    super.key,
    required this.p,
    required this.moments,
    required this.onLogCheckpoint,
    this.initialPresetId,
  });

  final Palette p;
  final List<Moment> moments;
  final Future<void> Function(CheckpointPreset preset) onLogCheckpoint;
  final String? initialPresetId;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required List<Moment> moments,
    required Future<void> Function(CheckpointPreset preset) onLogCheckpoint,
    String? initialPresetId,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: kTelegramSpringSheetAnimation,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.90,
        child: CheckpointsDashboardScreen(
          p: p,
          moments: moments,
          onLogCheckpoint: onLogCheckpoint,
          initialPresetId: initialPresetId,
        ),
      ),
    );
  }

  @override
  State<CheckpointsDashboardScreen> createState() =>
      _CheckpointsDashboardScreenState();
}

class _CheckpointsDashboardScreenState
    extends State<CheckpointsDashboardScreen> {
  late String? _selectedPresetId;

  @override
  void initState() {
    super.initState();
    _selectedPresetId = widget.initialPresetId;
  }

  CheckpointPreset? _findPreset(String id) {
    for (final p in CheckpointService.instance.presets) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final presets = CheckpointService.instance.presets;

    // Compute stats for all presets
    final Map<String, CheckpointStats> statsMap = {};
    int activeCount = 0;
    int totalScoreSum = 0;

    for (final preset in presets) {
      final stats = CheckpointService.instance.calculateStats(
        preset.id,
        widget.moments,
      );
      statsMap[preset.id] = stats;
      if (stats.totalLoggedCount > 0) {
        activeCount++;
        totalScoreSum += stats.consistencyScore;
      }
    }

    final overallConsistency = activeCount == 0
        ? 0
        : (totalScoreSum / activeCount).round();

    final selectedPreset = _selectedPresetId == null
        ? null
        : _findPreset(_selectedPresetId!);
    final selectedStats = _selectedPresetId == null
        ? null
        : statsMap[_selectedPresetId!];

    return AppSheet(
      p: p,
      title: 'Habit Checkpoints',
      trailingAction: PressableScale(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: p.surface2,
            shape: BoxShape.circle,
            border: Border.all(color: p.border.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.close_rounded, size: 18, color: p.text2),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Consistency Summary Card
            _buildOverallConsistencyCard(
              p,
              overallConsistency,
              activeCount,
              presets.length,
            ),
            const SizedBox(height: 16),

            // Horizontal Filter Chips
            _buildHabitFilterBar(p, presets),
            const SizedBox(height: 16),

            // Detail Content
            if (selectedPreset != null && selectedStats != null)
              _buildSingleHabitView(p, selectedPreset, selectedStats)
            else
              _buildAllHabitsOverview(p, presets, statsMap),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallConsistencyCard(
    Palette p,
    int overallScore,
    int activeCount,
    int totalCount,
  ) {
    return Glass(
      p: p,
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (overallScore / 100.0).clamp(0.0, 1.0),
                  strokeWidth: 7,
                  backgroundColor: p.surface3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    overallScore >= 75
                        ? p.green
                        : (overallScore >= 50 ? p.accent : p.orange),
                  ),
                ),
                Text(
                  '$overallScore%',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habit Consistency'.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$activeCount of $totalCount routine habits tracked recently.'
                      .localized(context),
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (overallScore >= 70 ? p.green : p.accent)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        overallScore >= 70
                            ? 'Stable Routine'
                            : (overallScore >= 40
                                  ? 'Building Rhythm'
                                  : 'Early Rhythm'),
                        style: TextStyle(
                          color: overallScore >= 70 ? p.green : p.accent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
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

  Widget _buildHabitFilterBar(Palette p, List<CheckpointPreset> presets) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // "All Habits" Chip
          PressableScale(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPresetId = null);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _selectedPresetId == null ? p.accent : p.surface2,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _selectedPresetId == null
                      ? p.accent
                      : p.border.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'All Habits'.localized(context),
                style: TextStyle(
                  color: _selectedPresetId == null ? Colors.white : p.text,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          ...presets.map((preset) {
            final isSelected = _selectedPresetId == preset.id;
            return PressableScale(
              key: ValueKey('filter_${preset.id}'),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedPresetId = preset.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? p.accent.withValues(alpha: 0.18)
                      : p.surface2,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? p.accent
                        : p.border.withValues(alpha: 0.5),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(preset.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      preset.label,
                      style: TextStyle(
                        color: isSelected ? p.accent : p.text,
                        fontSize: 12.5,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSingleHabitView(
    Palette p,
    CheckpointPreset preset,
    CheckpointStats stats,
  ) {
    final isDoneToday = CheckpointService.instance.isCompletedToday(
      preset.id,
      widget.moments,
    );

    // Extract recent logs for this checkpoint
    final habitLogs = CheckpointService.instance
        .getMomentsForPreset(preset.id, widget.moments)
        .reversed
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card: Timing Variance & Stats
        Glass(
          p: p,
          radius: 24,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      preset.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.label,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          stats.totalLoggedCount > 0
                              ? '${stats.totalLoggedCount} logs • ${stats.consistencyLevel}'
                              : 'No logs recorded yet',
                          style: TextStyle(color: p.text2, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  PressableScale(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      await widget.onLogCheckpoint(preset);
                      if (mounted) setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDoneToday
                            ? p.green.withValues(alpha: 0.15)
                            : p.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDoneToday
                                ? Icons.check_circle_rounded
                                : Icons.add_rounded,
                            size: 14,
                            color: isDoneToday ? p.green : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDoneToday ? 'Done Today' : 'Log Now',
                            style: TextStyle(
                              color: isDoneToday ? p.green : Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      p,
                      label: 'Average Time (μ)',
                      value: stats.totalLoggedCount > 0
                          ? stats.formattedMeanTime
                          : '--:--',
                      sub: preset.formattedTargetTime.isNotEmpty
                          ? 'Target: ${preset.formattedTargetTime}'
                          : 'Routine time',
                      icon: Icons.access_time_rounded,
                      color: p.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      p,
                      label: 'Timing Variance (±σ)',
                      value: stats.formattedVariance,
                      sub: stats.consistencyLevel,
                      icon: Icons.show_chart_rounded,
                      color: stats.consistencyColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      p,
                      label: 'Consistency Score',
                      value: '${stats.consistencyScore}%',
                      sub: '${stats.completedLast7Days} of 7 days',
                      icon: Icons.verified_rounded,
                      color: stats.consistencyColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      p,
                      label: 'Current Streak',
                      value: '${stats.streakDays} Days',
                      sub: stats.streakDays > 0
                          ? 'Active streak 🔥'
                          : 'Start streak today',
                      icon: Icons.local_fire_department_rounded,
                      color: p.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section Title: Recent Logs
        Text(
          'Recent Checkpoint Logs'.localized(context),
          style: TextStyle(
            color: p.text,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),

        if (habitLogs.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.border.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Text(
              'No checkpoint logs recorded for this habit yet.\nTap "Log Now" to record your first checkpoint!'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: math.min(10, habitLogs.length),
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final moment = habitLogs[index];
              final dt = DateTime.fromMillisecondsSinceEpoch(moment.timestamp);
              final timeStr = timeOnly(moment.timestamp);
              final dateStr = datePretty(moment.timestamp);

              // Calculate deviation from mean if stats available
              String? deviationStr;
              if (stats.totalLoggedCount > 0) {
                final logMins = dt.hour * 60 + dt.minute;
                final diffMinutes = (logMins - stats.meanMinuteOfDay).round();
                if (diffMinutes.abs() <= 5) {
                  deviationStr = 'On time';
                } else if (diffMinutes > 0) {
                  deviationStr = '+$diffMinutes min from avg';
                } else {
                  deviationStr = '$diffMinutes min from avg';
                }
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.border.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: p.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: p.text,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (moment.note.isNotEmpty &&
                              moment.note != '${preset.emoji} ${preset.label}')
                            Text(
                              moment.note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: p.text2, fontSize: 11.5),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (deviationStr != null)
                          Text(
                            deviationStr,
                            style: TextStyle(
                              color: deviationStr == 'On time'
                                  ? p.green
                                  : p.text3,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAllHabitsOverview(
    Palette p,
    List<CheckpointPreset> presets,
    Map<String, CheckpointStats> statsMap,
  ) {
    // Generate the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(
      7,
      (i) => now.subtract(Duration(days: 6 - i)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 7-Day Matrix Table Card
        Glass(
          p: p,
          radius: 24,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '7-Day Completion Matrix'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Last 7 Days'.localized(context),
                    style: TextStyle(color: p.text3, fontSize: 11.5),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Matrix Header (Day Labels)
              Row(
                children: [
                  const SizedBox(width: 90), // Offset for habit label
                  ...last7Days.map((day) {
                    final dayLabel = _dayOfWeekShort(day.weekday);
                    final dayNum = day.day.toString();
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            dayLabel,
                            style: TextStyle(
                              color: p.text3,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            dayNum,
                            style: TextStyle(
                              color: p.text,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),

              // Rows for each preset
              ...presets.map((preset) {
                final presetMoments = CheckpointService.instance
                    .getMomentsForPreset(preset.id, widget.moments);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Row(
                          children: [
                            Text(
                              preset.emoji,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                preset.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...last7Days.map((day) {
                        final dk = dateKey(day);
                        final isDone = presetMoments.any((m) => m.date == dk);

                        return Expanded(
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? p.accent
                                    : p.surface3.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: isDone
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section Title: Habit Consistency Ranking
        Text(
          'Habit Consistency Breakdown'.localized(context),
          style: TextStyle(
            color: p.text,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),

        // List of all presets ordered by consistency score
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: presets.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final preset = presets[index];
            final stats = statsMap[preset.id]!;
            final score = stats.consistencyScore;

            return PressableScale(
              key: ValueKey('rank_${preset.id}'),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedPresetId = preset.id);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.border.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        preset.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                preset.label,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (stats.streakDays > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${stats.streakDays}d 🔥',
                                    style: TextStyle(
                                      color: p.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stats.totalLoggedCount > 0
                                ? 'Avg: ${stats.formattedMeanTime} • ${stats.formattedVariance} variance'
                                : 'Not logged recently',
                            style: TextStyle(color: p.text2, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$score%',
                          style: TextStyle(
                            color: stats.consistencyColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${stats.totalLoggedCount} logs',
                          style: TextStyle(color: p.text3, fontSize: 10.5),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 18, color: p.text3),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    Palette p, {
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.text3, fontSize: 10.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: p.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _dayOfWeekShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'T';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'S';
      default:
        return '';
    }
  }
}
