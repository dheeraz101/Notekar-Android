import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';

/// Full day detail and reflection sheet in Apple HIG style.
class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({
    super.key,
    required this.p,
    required this.section,
    required this.allEntries,
    this.onEditNote,
    this.onOpenManualEntry,
  });

  final Palette p;
  final TimelineDaySection section;
  final List<Moment> allEntries;
  final ValueChanged<Moment>? onEditNote;
  final void Function({
    DateTime? prefilledStartTime,
    DateTime? prefilledEndTime,
  })?
  onOpenManualEntry;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      p: p,
      title: section.displayTitle,
      child: DayDetailContent(
        p: p,
        section: section,
        allEntries: allEntries,
        onEditNote: onEditNote,
        onOpenManualEntry: onOpenManualEntry,
      ),
    );
  }
}

/// Full day detail and reflection content in Apple HIG style.
class DayDetailContent extends StatelessWidget {
  const DayDetailContent({
    super.key,
    required this.p,
    required this.section,
    required this.allEntries,
    this.onEditNote,
    this.onOpenManualEntry,
    this.padding = const EdgeInsets.only(bottom: 24),
  });

  final Palette p;
  final TimelineDaySection section;
  final List<Moment> allEntries;
  final ValueChanged<Moment>? onEditNote;
  final void Function({
    DateTime? prefilledStartTime,
    DateTime? prefilledEndTime,
  })?
  onOpenManualEntry;
  final EdgeInsets padding;

  String _formatDuration(Duration d) {
    final totalMins = d.inMinutes;
    if (totalMins <= 0) return '0m';
    final hours = totalMins ~/ 60;
    final mins = totalMins % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final dayItems = section.items;

    // Temporal groups
    int morningMs = 0;
    int afternoonMs = 0;
    int eveningMs = 0;
    int nightMs = 0;

    int longestSessionMs = 0;
    final Map<int, int> hourActivity = {};

    for (final it in dayItems) {
      final dt = DateTime.fromMillisecondsSinceEpoch(it.primaryTimestamp);
      final hour = dt.hour;
      hourActivity[hour] = (hourActivity[hour] ?? 0) + 1;

      final int durMs;
      if (it is TimelineSessionItem) {
        durMs = it.duration.inMilliseconds;
        longestSessionMs = math.max(longestSessionMs, durMs);
      } else if (it is TimelineSingleItem) {
        durMs = 15 * 60 * 1000;
      } else {
        durMs = 0;
      }

      if (hour >= 6 && hour < 12) {
        morningMs += durMs;
      } else if (hour >= 12 && hour < 17) {
        afternoonMs += durMs;
      } else if (hour >= 17 && hour < 21) {
        eveningMs += durMs;
      } else {
        nightMs += durMs;
      }
    }

    int? peakHour;
    int maxHourCount = 0;
    hourActivity.forEach((hour, count) {
      if (count > maxHourCount) {
        maxHourCount = count;
        peakHour = hour;
      }
    });

    final totalTracked = section.totalTrackedDuration;
    // Conscious window baseline of 10 hours
    const consciousWindow = Duration(hours: 10);
    final intentionalityRatio = consciousWindow.inMilliseconds > 0
        ? (totalTracked.inMilliseconds / consciousWindow.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${section.totalLogs} logs • ${_formatDuration(totalTracked)} tracked',
              style: TextStyle(
                color: p.text2,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Top Summary Hero
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONSCIOUS TRACKING'.localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${(intentionalityRatio * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: intentionalityRatio,
                    minHeight: 8,
                    backgroundColor: p.surface3,
                    valueColor: AlwaysStoppedAnimation<Color>(p.accent),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryMetric(
                        label: 'Tracked',
                        value: _formatDuration(totalTracked),
                        color: p.accent,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: p.border.withValues(alpha: 0.5),
                    ),
                    Expanded(
                      child: _buildSummaryMetric(
                        label: 'Longest Focus',
                        value: longestSessionMs > 0
                            ? _formatDuration(
                                Duration(milliseconds: longestSessionMs),
                              )
                            : '--',
                        color: p.green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: p.border.withValues(alpha: 0.5),
                    ),
                    Expanded(
                      child: _buildSummaryMetric(
                        label: 'Peak Hour',
                        value: peakHour != null ? '${peakHour!}:00' : '--',
                        color: p.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Temporal Breakdown
          Text(
            'DAY RHYTHM'.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildTemporalTile(
                label: 'Morning',
                sub: '6am - 12pm',
                duration: Duration(milliseconds: morningMs),
                icon: CupertinoIcons.sunrise_fill,
                color: p.orange,
              ),
              const SizedBox(width: 8),
              _buildTemporalTile(
                label: 'Afternoon',
                sub: '12pm - 5pm',
                duration: Duration(milliseconds: afternoonMs),
                icon: CupertinoIcons.sun_max_fill,
                color: p.accent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTemporalTile(
                label: 'Evening',
                sub: '5pm - 9pm',
                duration: Duration(milliseconds: eveningMs),
                icon: CupertinoIcons.sunset_fill,
                color: p.blue,
              ),
              const SizedBox(width: 8),
              _buildTemporalTile(
                label: 'Night',
                sub: '9pm - 6am',
                duration: Duration(milliseconds: nightMs),
                icon: CupertinoIcons.moon_stars_fill,
                color: p.text2,
              ),
            ],
          ),

          // Category Breakdown
          if (section.categoryBreakdown.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'MODES & CATEGORIES'.localized(context),
              style: TextStyle(
                color: p.text3,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.border.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  for (final entry in section.categoryBreakdown.entries) ...[
                    _buildCategoryRow(
                      category: entry.key,
                      duration: entry.value,
                      totalDayDuration: totalTracked,
                    ),
                    if (entry.key != section.categoryBreakdown.keys.last)
                      Divider(
                        color: p.border.withValues(alpha: 0.4),
                        height: 16,
                      ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Timeline items preview for this day
          Text(
            'TIMELINE LOGS'.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          for (final it in dayItems) ...[
            _buildTimelineItemRow(context, it),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: p.text3,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTemporalTile({
    required String label,
    required String sub,
    required Duration duration,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      color: duration.inMinutes > 0 ? color : p.text3,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow({
    required String category,
    required Duration duration,
    required Duration totalDayDuration,
  }) {
    final meta = getCategoryMeta(category, p);
    final pct = totalDayDuration.inMilliseconds > 0
        ? (duration.inMilliseconds / totalDayDuration.inMilliseconds * 100)
              .clamp(0.0, 100.0)
        : 0.0;

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: meta.color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(meta.icon, size: 14, color: meta.color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            category,
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${pct.toStringAsFixed(0)}%',
          style: TextStyle(
            color: p.text3,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _formatDuration(duration),
          style: TextStyle(
            color: meta.color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItemRow(BuildContext context, TimelineItem item) {
    if (item is TimelineSessionItem) {
      final timeRange =
          '${timeOnly(item.startTimestamp)} → ${item.endTimestamp != null ? timeOnly(item.endTimestamp!) : "Live"}';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: p.green, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeRange,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (item.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () {
                        final endStr = item.endTimestamp != null
                            ? timeOnly(item.endTimestamp!)
                            : 'Now';
                        NotePreviewSheet.show(
                          context,
                          p: p,
                          note: item.note,
                          title: '${timeOnly(item.startTimestamp)} - $endStr',
                          category: item.category,
                          onEdit: onEditNote != null
                              ? () => onEditNote!(item.noteMoment)
                              : null,
                        );
                      },
                      child: IosEmojiText(
                        item.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.text2, fontSize: 11.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              _formatDuration(item.duration),
              style: TextStyle(
                color: p.green,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    } else if (item is TimelineSingleItem) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeOnly(item.primaryTimestamp),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (item.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () {
                        NotePreviewSheet.show(
                          context,
                          p: p,
                          note: item.note,
                          title: timeOnly(item.primaryTimestamp),
                          category: item.category,
                          onEdit: onEditNote != null
                              ? () => onEditNote!(item.moment)
                              : null,
                        );
                      },
                      child: IosEmojiText(
                        item.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.text2, fontSize: 11.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              item.type.toUpperCase(),
              style: TextStyle(
                color: p.text3,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
