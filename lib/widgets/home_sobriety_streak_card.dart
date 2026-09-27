import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/sobriety_milestones.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Clean, modular Home Screen Sobriety Streak Progress Card widget.
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

    // Pill label: first 24h → "Oh Clean", then milestone name
    final String bigLabel;
    if (duration.inHours < 24) {
      bigLabel = 'Oh Clean';
    } else {
      bigLabel = milestoneResult.current != null
          ? getMilestoneName(milestoneResult.current!, milestoneTheme)
          : 'Oh Clean';
    }

    final String milestoneDaysLeftText;
    if (milestoneResult.next != null) {
      final hoursLeft = (milestoneResult.next!.days * 24) - duration.inHours;
      milestoneDaysLeftText = hoursLeft >= 24
          ? 'Next in ${(hoursLeft / 24).ceil()}d'
          : 'Next in ${hoursLeft}h';
    } else {
      milestoneDaysLeftText = 'Mastery achieved';
    }

    final String smallLabel;
    final String shieldText = streakShields > 0
        ? ' • $streakShields active'
        : '';
    if (duration.inDays == 0) {
      final hours = duration.inHours;
      smallLabel =
          '$hours ${hours == 1 ? 'hr' : 'hrs'} clean$shieldText • $milestoneDaysLeftText';
    } else {
      final days = duration.inDays;
      smallLabel =
          '$days ${days == 1 ? 'day' : 'days'} clean$shieldText • $milestoneDaysLeftText';
    }
    final double progress = milestoneResult.progress;

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

    final String flameText = duration.inDays > 0
        ? ' 🔥 ${duration.inDays}d'
        : '';
    final String displayLabel = '$bigLabel$flameText';

    return PressableScale(
      onTap: () {
        if (milestoneResult.current != null) {
          onTapMilestone(milestoneResult.current!, duration.inDays);
        } else {
          onTapSettings();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            // Background track
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: palette.surface2,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: palette.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: progressColor.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            // Progress fill
            FractionallySizedBox(
              widthFactor: progress.clamp(0.05, 1.0),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Text content
            SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (smallLabel.isNotEmpty)
                            Text(
                              smallLabel,
                              style: TextStyle(
                                color: palette.text2,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 450),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.80, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.elasticOut,
                                      ),
                                    ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              displayLabel,
                              key: ValueKey(
                                'streak-${duration.inDays}-$displayLabel',
                              ),
                              style: TextStyle(
                                color: palette.text,
                                fontSize: smallLabel.isEmpty ? 20 : 17,
                                fontWeight: FontWeight.w900,
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
                    GestureDetector(
                      onTap: onOpenUrgeSurfing,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: palette.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.air_rounded,
                          color: palette.accent,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: palette.text3,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
