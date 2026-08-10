import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';

class ActivityHeatmapWidget extends StatelessWidget {
  const ActivityHeatmapWidget({
    super.key,
    required this.p,
    required this.entries,
  });

  final Palette p;
  final List<Moment> entries;

  @override
  Widget build(BuildContext context) {
    // Group entries by date (YYYY-MM-DD)
    final Map<String, int> dailyCounts = {};
    for (final e in entries) {
      final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
      final key =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
    }

    final now = DateTime.now();
    // 16 weeks (~112 days) for clean dashboard preview
    final totalDays = 112;
    final startDate = now.subtract(Duration(days: totalDays - 1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface2.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_on_rounded, color: p.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                '16-Week Habit Activity Grid'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                for (int col = 0; col < 16; col++) ...[
                  Column(
                    children: [
                      for (int row = 0; row < 7; row++) ...[
                        (() {
                          final dayOffset = (col * 7) + row;
                          final date = startDate.add(Duration(days: dayOffset));
                          final key =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          final count = dailyCounts[key] ?? 0;

                          Color boxColor = p.surface3;
                          if (count >= 3) {
                            boxColor = p.accent;
                          } else if (count >= 1) {
                            boxColor = p.accent.withValues(alpha: 0.45);
                          }

                          return Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: boxColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }()),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less'.localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 3),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 3),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'More'.localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
