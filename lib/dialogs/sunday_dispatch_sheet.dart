import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// The "Sunday Evening Dispatch" — Apple News / Monocle style editorial retrospective sheet.
class SundayDispatchSheet extends StatelessWidget {
  const SundayDispatchSheet({
    super.key,
    required this.p,
    required this.entries,
  });

  final Palette p;
  final List<Moment> entries;

  String _formatDuration(Duration d) {
    final totalMinutes = d.inMinutes;
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final weekEntries = entries.where((e) {
      final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
      return dt.isAfter(sevenDaysAgo) &&
          dt.isBefore(now.add(const Duration(hours: 1)));
    }).toList();

    final sections = buildTimelineDaySections(weekEntries);

    int totalWeekMs = 0;
    int restMs = 0;
    final Map<int, int> weekdayMs = {};
    final Map<String, int> timeOfDayMs = {
      'morning': 0,
      'afternoon': 0,
      'evening': 0,
      'night': 0,
    };
    final Map<String, int> modeMs = {};

    for (final sec in sections) {
      for (final it in sec.items) {
        final dt = DateTime.fromMillisecondsSinceEpoch(it.primaryTimestamp);
        final dur = switch (it) {
          TimelineSessionItem s => s.duration.inMilliseconds,
          TimelineSingleItem _ => 15 * 60 * 1000,
          TimelineGapItem g => g.duration.inMilliseconds,
        };

        final cat = switch (it) {
          TimelineSessionItem s =>
            CategoryService.extractCategory(s.inMoment) ?? 'Work',
          TimelineSingleItem s =>
            CategoryService.extractCategory(s.moment) ?? 'General',
          TimelineGapItem _ => 'Rest',
        };

        if (cat.toLowerCase() == 'rest' || cat.toLowerCase() == 'sleep') {
          restMs += dur;
          continue;
        }

        totalWeekMs += dur;
        weekdayMs[dt.weekday] = (weekdayMs[dt.weekday] ?? 0) + dur;

        final hour = dt.hour;
        if (hour >= 6 && hour < 12) {
          timeOfDayMs['morning'] = (timeOfDayMs['morning'] ?? 0) + dur;
        } else if (hour >= 12 && hour < 17) {
          timeOfDayMs['afternoon'] = (timeOfDayMs['afternoon'] ?? 0) + dur;
        } else if (hour >= 17 && hour < 21) {
          timeOfDayMs['evening'] = (timeOfDayMs['evening'] ?? 0) + dur;
        } else {
          timeOfDayMs['night'] = (timeOfDayMs['night'] ?? 0) + dur;
        }

        modeMs[cat] = (modeMs[cat] ?? 0) + dur;
      }
    }

    // Find peak day
    int peakWeekday = 3; // Wednesday default
    int maxDayMs = 0;
    weekdayMs.forEach((day, ms) {
      if (ms > maxDayMs) {
        maxDayMs = ms;
        peakWeekday = day;
      }
    });

    final weekdayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final peakDayName = weekdayNames[(peakWeekday - 1).clamp(0, 6)];

    // Find peak window
    String peakWindow = 'afternoon';
    int maxWindowMs = 0;
    timeOfDayMs.forEach((win, ms) {
      if (ms > maxWindowMs) {
        maxWindowMs = ms;
        peakWindow = win;
      }
    });

    final focusHours = (totalWeekMs / (1000 * 60 * 60)).toStringAsFixed(1);
    final restHours = (restMs / (1000 * 60 * 60)).toStringAsFixed(1);
    final activeDaysCount = sections.where((s) => s.items.isNotEmpty).length;

    final weekRange =
        '${sevenDaysAgo.day} ${_monthName(sevenDaysAgo.month)} — ${now.day} ${_monthName(now.month)}';

    return AppSheet(
      p: p,
      title: 'Sunday Dispatch'.localized(context),
      docked: true,
      child: SizedBox(
        height: math.min(MediaQuery.sizeOf(context).height * 0.72, 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lead Tag & User Avatar Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'RETROSPECTIVE • $weekRange'.toUpperCase(),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: UserProfileService(),
                    builder: (context, _) {
                      final profile = UserProfileService();
                      if (profile.name.trim().isEmpty &&
                          profile.avatarBytes == null &&
                          profile.presetAvatarIndex == null) {
                        return const SizedBox.shrink();
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          profile.buildAvatarWidget(
                            p: p,
                            size: 22,
                            showBorder: false,
                          ),
                          if (profile.name.trim().isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              profile.name.trim(),
                              style: TextStyle(
                                color: p.text2,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Headline
              AnimatedBuilder(
                animation: UserProfileService(),
                builder: (context, _) {
                  final profile = UserProfileService();
                  final title = profile.name.trim().isNotEmpty
                      ? 'A Week of Deliberate Focus, ${profile.name.trim()}'
                      : 'A Week of Deliberate Focus';
                  return Text(
                    title,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      fontFamily: 'Inter',
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Editorial Narrative Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This week, you lived $focusHours hours with deliberate focus across $activeDaysCount active days. '
                      'Your circadian peak flourished on $peakDayName $peakWindow, where deep flow emerged with greatest momentum. '
                      '${restMs > 0 ? '$restHours hours were consciously reclaimed as rest and restorative recovery.' : 'Rest and renewal sustained your conscious presence.'}',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 14.5,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3 Clean Summary Badges
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Conscious Focus',
                      value: '${focusHours}h',
                      color: p.accent,
                      icon: CupertinoIcons.scope,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Peak Circadian',
                      value: peakDayName,
                      sub: peakWindow.capitalize(),
                      color: p.orange,
                      icon: CupertinoIcons.sparkles,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Reclaimed Rest',
                      value: '${restHours}h',
                      color: p.green,
                      icon: CupertinoIcons.moon_stars_fill,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Top Modes Section
              Text(
                'WEEKLY COMPOSITION'.localized(context),
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    if (modeMs.isEmpty)
                      Text(
                        'No moments recorded yet this week.',
                        style: TextStyle(color: p.text3, fontSize: 13),
                      )
                    else
                      for (final entry in modeMs.entries) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: getCategoryMeta(entry.key, p).color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                _formatDuration(
                                  Duration(milliseconds: entry.value),
                                ),
                                style: TextStyle(
                                  color: p.text2,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 1-Tap Button: "Save to Sovereign Archive"
              PressableScale(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _exportToSovereignArchive(
                    context: context,
                    weekRange: weekRange,
                    focusHours: focusHours,
                    restHours: restHours,
                    peakDayName: peakDayName,
                    peakWindow: peakWindow,
                    modeMs: modeMs,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: p.accent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.arrow_down_doc_fill,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Save to Sovereign Archive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    String? sub,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: p.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (sub != null)
            Text(
              sub,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.text3,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _exportToSovereignArchive({
    required BuildContext context,
    required String weekRange,
    required String focusHours,
    required String restHours,
    required String peakDayName,
    required String peakWindow,
    required Map<String, int> modeMs,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('# NoteKar Sovereign Life Ledger');
    buffer.writeln('**Retrospective**: $weekRange');
    buffer.writeln('**Generated**: ${DateTime.now().toIso8601String()}\n');
    buffer.writeln('## Executive Reflection');
    buffer.writeln(
      'This week, you lived **$focusHours hours** with deliberate focus. '
      'Your circadian peak flourished on **$peakDayName $peakWindow**. '
      '**$restHours hours** were reclaimed as conscious rest & recovery.\n',
    );
    buffer.writeln('## Temporal Composition');
    for (final entry in modeMs.entries) {
      final dur = _formatDuration(Duration(milliseconds: entry.value));
      buffer.writeln('- **${entry.key}**: $dur');
    }
    buffer.writeln(
      '\n---\n*Preserved offline with sovereign local privacy via NoteKar.*',
    );

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    showIosPillToast(
      context: context,
      p: p,
      message: 'Markdown Copied • Sovereign Archive Ready',
      icon: CupertinoIcons.doc_checkmark_fill,
    );
  }

  String _monthName(int month) {
    const names = [
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
    return names[(month - 1).clamp(0, 11)];
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
