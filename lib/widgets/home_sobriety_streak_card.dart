import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/sobriety_milestones.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Clean, Apple HIG inspired Home Screen Sobriety Streak Progress Card widget.
class HomeSobrietyStreakCard extends StatelessWidget {
  const HomeSobrietyStreakCard({
    super.key,
    required this.duration,
    required this.milestoneTheme,
    required this.streakShields,
    required this.onTapMilestone,
    required this.onTapSettings,
    required this.onOpenUrgeSurfing,
  });

  final Duration duration;
  final String milestoneTheme;
  final int streakShields;
  final void Function(SobrietyMilestoneEntry milestone, int streakDays)
  onTapMilestone;
  final VoidCallback onTapSettings;
  final VoidCallback onOpenUrgeSurfing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final milestoneResult = getMilestoneProgress(duration);

    // Primary label calculation:
    // If < 24h: "0h Clean" (or "Xh Clean")
    // If >= 1 day: e.g. "12d Clean" with milestone title
    final String cleanDurationText;
    if (duration.inDays == 0) {
      final hours = duration.inHours;
      cleanDurationText = hours == 0 ? '0h Clean' : '${hours}h Clean';
    } else {
      final days = duration.inDays;
      cleanDurationText = '${days}d Clean';
    }

    final String milestoneName = milestoneResult.current != null
        ? getMilestoneName(milestoneResult.current!, milestoneTheme)
        : (duration.inHours < 24 ? 'Starting Fresh' : 'First Steps');

    final String nextMilestoneText;
    if (milestoneResult.next != null) {
      final hoursLeft = (milestoneResult.next!.days * 24) - duration.inHours;
      nextMilestoneText = hoursLeft >= 24
          ? 'Next in ${(hoursLeft / 24).ceil()}d'
          : 'Next in ${hoursLeft}h';
    } else {
      nextMilestoneText = 'Mastery';
    }

    final double progress = milestoneResult.progress.clamp(0.04, 1.0);

    final Color progressColor;
    if (milestoneResult.current == null) {
      progressColor = palette.orange;
    } else {
      final days = milestoneResult.current!.days;
      if (days < 7) {
        progressColor = palette.green;
      } else if (days < 30) {
        progressColor = palette.accent;
      } else if (days < 90) {
        progressColor = const Color(0xFFC77DFF);
      } else {
        progressColor = const Color(0xFFFFB703);
      }
    }

    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTapSettings();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onTapSettings();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: palette.surface2,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: palette.border.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: progressColor.withValues(alpha: 0.09),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Smooth background progress fill
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor.withValues(alpha: 0.22),
                            progressColor.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Card contents
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // Emblem badge (Flame or Seedling)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: progressColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: progressColor.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        duration.inDays > 0 ? '🔥' : '🌱',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Main info column
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top subtitle row: clean duration & shields & next target
                          Row(
                            children: [
                              Text(
                                cleanDurationText,
                                style: TextStyle(
                                  color: progressColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (streakShields > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.surface3,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '🛡️',
                                        style: TextStyle(fontSize: 8.5),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '$streakShields',
                                        style: TextStyle(
                                          color: palette.text2,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(width: 6),
                              Text(
                                '• $nextMilestoneText',
                                style: TextStyle(
                                  color: palette.text3,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),

                          // Main bold milestone / status title
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              milestoneName,
                              key: ValueKey(
                                'sobriety-title-$milestoneName-$cleanDurationText',
                              ),
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Action: Urge Surfing button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onOpenUrgeSurfing();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: palette.accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.air_rounded,
                          color: palette.accent,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Subtle Settings indicator icon
                    Icon(
                      CupertinoIcons.chevron_forward,
                      color: palette.text3,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
