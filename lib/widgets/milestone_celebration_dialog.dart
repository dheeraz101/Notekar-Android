import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/shareable_milestone_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/sobriety_milestones.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/glass.dart';

/// Shows the Sobriety Milestone Unlock Celebration dialog with animated particles and haptics.
Future<void> showMilestoneUnlockDialog({
  required BuildContext context,
  required Palette p,
  required SobrietyMilestoneEntry milestone,
  required String themeId,
  required int streakDays,
  required int streakShields,
}) async {
  // Fire tactile celebration haptic immediately
  HapticFeedback.heavyImpact();

  final title = getMilestoneName(milestone, themeId);
  final flavor = getMilestoneFlavor(milestone, themeId);

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Milestone Celebration',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (context, anim1, anim2, child) {
      final curved = Curves.easeOutCubic.transform(anim1.value);
      return Transform.scale(
        scale: 0.90 + (curved * 0.10),
        child: Opacity(opacity: anim1.value.clamp(0.0, 1.0), child: child),
      );
    },
    pageBuilder: (context, animation1, animation2) {
      return Stack(
        children: [
          // Animated Confetti/Particle overlay
          const Positioned.fill(
            child: IgnorePointer(child: ConfettiParticleOverlay()),
          ),
          // Dialog content
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 420),
              child: Glass(
                p: p,
                radius: 28,
                padding: const EdgeInsets.all(28),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy / Peak Badge with animated glowing ring
                      const _AnimatedTrophyBadge(),
                      const SizedBox(height: 20),

                      // Header
                      Text(
                        'MILESTONE UNLOCKED!'.localized(context),
                        style: TextStyle(
                          color: p.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Milestone Title
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Day Subtitle
                      Text(
                        'Target: ${milestone.dayLabel} • $streakDays Days Protected',
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Flavor / Neuroscience Quote Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: p.surface3.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: p.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '"$flavor"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),

                      if (streakShields > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🛡️ ', style: TextStyle(fontSize: 14)),
                            Text(
                              '$streakShields Streak Shield${streakShields == 1 ? '' : 's'} Active',
                              style: TextStyle(
                                color: p.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: p.border),
                                  foregroundColor: p.text,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.check_rounded, size: 20),
                                label: Text(
                                  'Done'.localized(context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: p.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) {
                                      return ShareableMilestoneSheet(
                                        p: p,
                                        milestoneTitle: title,
                                        dayLabel: milestone.dayLabel,
                                        streakDays: streakDays,
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  CupertinoIcons.share,
                                  size: 18,
                                ),
                                label: Text(
                                  'Share'.localized(context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Animated Trophy Badge with pulsing ring
class _AnimatedTrophyBadge extends StatefulWidget {
  const _AnimatedTrophyBadge();

  @override
  State<_AnimatedTrophyBadge> createState() => _AnimatedTrophyBadgeState();
}

class _AnimatedTrophyBadgeState extends State<_AnimatedTrophyBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = _controller.value;
        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9E00), Color(0xFFFF5400)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFF6D00,
                ).withValues(alpha: 0.35 + (glow * 0.35)),
                blurRadius: 20 + (glow * 12),
                spreadRadius: 2 + (glow * 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.terrain_rounded, color: Colors.white, size: 46),
          ),
        );
      },
    );
  }
}

/// Research-based festive confetti overlay (85 particles, layered sizes, 3D paper flutter)
class ConfettiParticleOverlay extends StatefulWidget {
  const ConfettiParticleOverlay({super.key});

  @override
  State<ConfettiParticleOverlay> createState() =>
      _ConfettiParticleOverlayState();
}

class _ConfettiParticleOverlayState extends State<ConfettiParticleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    // 85 particles: 35 micro glitter, 35 standard ribbon pieces, 15 hero streamers
    _particles = List.generate(85, (index) {
      final isCircle = index % 3 == 0;
      final double size;
      if (index < 35) {
        size = 5.0 + random.nextDouble() * 4.0; // Small glitter (5-9px)
      } else if (index < 70) {
        size = 10.0 + random.nextDouble() * 6.0; // Medium paper chips (10-16px)
      } else {
        size =
            16.0 + random.nextDouble() * 8.0; // Large hero streamers (16-24px)
      }

      return _Particle(
        x: random.nextDouble(),
        startY: -0.15 - random.nextDouble() * 0.65,
        speedY: 1.30 + random.nextDouble() * 0.70,
        speedX: (random.nextDouble() - 0.5) * 0.40,
        size: size,
        isCircle: isCircle,
        color: [
          const Color(0xFFFFD166), // Festive Warm Gold
          const Color(0xFFFFB703), // Sunny Amber
          const Color(0xFF06D6A0), // Emerald Green
          const Color(0xFF30D158), // Vibrant Mint
          const Color(0xFF0A84FF), // Electric Blue
          const Color(0xFF5AC8FA), // Sky Cyan
          const Color(0xFFFF2D55), // Vibrant Coral
          const Color(0xFFFF5C8D), // Hot Pink
          const Color(0xFFBF5AF2), // Royal Purple
        ][random.nextInt(9)],
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 10.0,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value),
        );
      },
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.startY,
    required this.speedY,
    required this.speedX,
    required this.size,
    required this.isCircle,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });

  final double x;
  final double startY;
  final double speedY;
  final double speedX;
  final double size;
  final bool isCircle;
  final Color color;
  final double rotation;
  final double rotationSpeed;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.progress);

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Fade out smoothly during the final 20% of the celebration animation
    final globalAlpha = progress > 0.80
        ? (1.0 - ((progress - 0.80) / 0.20)).clamp(0.0, 1.0)
        : 1.0;

    if (globalAlpha <= 0.0) return;

    for (final p in particles) {
      // Natural gravity with subtle sinusoidal air resistance drift
      final currentY = p.startY + (p.speedY * progress);
      final currentX =
          (p.x +
              (p.speedX * progress) +
              (0.04 * math.sin((progress * 8) + p.rotation))) %
          1.0;

      if (currentY < -0.1 || currentY > 1.2) continue;

      final dx = currentX * size.width;
      final dy = currentY * size.height;

      final paint = Paint()
        ..color = p.color.withValues(alpha: 0.94 * globalAlpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      } else {
        canvas.rotate(p.rotation + (progress * p.rotationSpeed));

        // 3D paper flutter effect
        final flutterScale = math.sin((progress * 12) + p.rotation);
        canvas.scale(flutterScale.abs().clamp(0.15, 1.0), 1.0);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.55,
            ),
            const Radius.circular(2.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
