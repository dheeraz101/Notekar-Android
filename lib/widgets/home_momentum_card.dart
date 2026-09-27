import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/theme/app_tokens.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// An interactive, Apple HIG-inspired Momentum card displayed on the Home Screen.
/// Prominently surfaces today's real tracked progress, streak momentum, and grace shields,
/// solving the feature discoverability crisis with 1-tap access to the Intelligence Hub.
class HomeMomentumCard extends StatelessWidget {
  const HomeMomentumCard({
    super.key,
    required this.trackedDuration,
    required this.momentsCount,
    required this.currentStreak,
    required this.bankedGraceDays,
    required this.activeCategory,
    required this.onTap,
    this.isSessionOngoing = false,
  });

  final Duration trackedDuration;
  final int momentsCount;
  final int currentStreak;
  final int bankedGraceDays;
  final String activeCategory;
  final VoidCallback onTap;
  final bool isSessionOngoing;

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
    final p = context.palette;
    final formattedTime = _formatDuration(trackedDuration);

    return PressableScale(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          borderRadius: NkTokens.radii.card,
          border: Border.all(
            color: isSessionOngoing
                ? p.accent.withValues(alpha: 0.5)
                : p.border.withValues(alpha: 0.2),
            width: 1.0,
          ),
          boxShadow: NkTokens.elevation.cardShadow(p.bg),
        ),
        child: Glass(
          p: p,
          borderRadius: NkTokens.radii.card,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Left: Progress Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSessionOngoing
                      ? p.green.withValues(alpha: 0.15)
                      : p.accent.withValues(alpha: 0.15),
                ),
                child: Icon(
                  isSessionOngoing
                      ? Icons.play_arrow_rounded
                      : Icons.insights_rounded,
                  color: isSessionOngoing ? p.green : p.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Middle: Metrics summary
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          isSessionOngoing
                              ? 'RECORDING SESSION'
                              : 'TODAY\'S MOMENTUM',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isSessionOngoing ? p.green : p.text3,
                          ),
                        ),
                        if (activeCategory != 'All' &&
                            activeCategory.isNotEmpty) ...[
                          Text(
                            ' • ',
                            style: TextStyle(color: p.text3, fontSize: 10),
                          ),
                          Text(
                            activeCategory.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: p.accent,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: p.text,
                          ),
                        ),
                        Text(
                          ' tracked',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: p.text2,
                          ),
                        ),
                        if (momentsCount > 0) ...[
                          Text(
                            ' • $momentsCount ${momentsCount == 1 ? 'log' : 'logs'}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
                              color: p.text3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Right: Streak badge & disclosure arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: NkTokens.radii.pill,
                      color: currentStreak > 0
                          ? p.orange.withValues(alpha: 0.15)
                          : p.surface3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentStreak > 0 ? '🔥 $currentStreak' : '⚡ Start',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: currentStreak > 0 ? p.orange : p.text3,
                          ),
                        ),
                        if (bankedGraceDays > 0) ...[
                          const SizedBox(width: 3),
                          Icon(Icons.shield_rounded, size: 11, color: p.green),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Insights',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: p.accent,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: p.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
