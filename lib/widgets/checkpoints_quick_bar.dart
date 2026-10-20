import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/checkpoint_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Fast-entry horizontal chip bar for 1-tap logging of routine habit checkpoints.
class CheckpointsQuickBar extends StatelessWidget {
  const CheckpointsQuickBar({
    super.key,
    required this.p,
    required this.moments,
    required this.onLogCheckpoint,
    this.onOpenDashboard,
  });

  final Palette p;
  final List<Moment> moments;
  final void Function(CheckpointPreset preset) onLogCheckpoint;
  final VoidCallback? onOpenDashboard;

  @override
  Widget build(BuildContext context) {
    final presets = CheckpointService.instance.presets;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Icon(Icons.flag_rounded, size: 13, color: p.accent),
                const SizedBox(width: 5),
                Text(
                  'ROUTINE CHECKPOINTS',
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (onOpenDashboard != null)
                  PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onOpenDashboard!();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Insights',
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: p.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Horizontal Chip Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                ...presets.map((preset) {
                  final isDone = CheckpointService.instance.isCompletedToday(
                    preset.id,
                    moments,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PressableScale(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onLogCheckpoint(preset);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDone
                              ? p.accent.withValues(alpha: 0.12)
                              : p.surface2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDone
                                ? p.accent.withValues(alpha: 0.4)
                                : p.border.withValues(alpha: 0.6),
                            width: isDone ? 1.0 : 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              preset.emoji,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              preset.label,
                              style: TextStyle(
                                color: isDone ? p.accent : p.text,
                                fontSize: 11.5,
                                fontWeight: isDone
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                            if (isDone) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: p.accent,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
