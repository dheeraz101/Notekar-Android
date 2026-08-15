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
  // Trigger tactile haptic pattern
  HapticFeedback.heavyImpact();
  await Future.delayed(const Duration(milliseconds: 100));
  HapticFeedback.mediumImpact();

  if (!context.mounted) return;

  final title = getMilestoneName(milestone, themeId);
  final flavor = getMilestoneFlavor(milestone, themeId);

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Milestone Celebration',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, anim1, anim2, child) {
      final curved = Curves.easeOutBack.transform(anim1.value);
      return Transform.scale(
        scale: 0.85 + (curved * 0.15),
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
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(color: p.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                showGeneralDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: 'Share Milestone',
                                  pageBuilder: (context, anim1, anim2) =>
                                      ShareableMilestoneSheet(
                                        p: p,
                                        milestoneTitle: title,
                                        dayLabel: milestone.dayLabel,
                                        streakDays: streakDays,
                                      ),
                                );
                              },
                              icon: Icon(
                                CupertinoIcons.share,
                                size: 16,
                                color: p.text,
                              ),
                              label: Text(
                                'Share'.localized(context),
                                style: TextStyle(
                                  color: p.text,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: p.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Continue'.localized(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
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
        final scale = 1.0 + (_controller.value * 0.08);
        final glow = 12.0 + (_controller.value * 12.0);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB703), Color(0xFFFF8000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB703).withValues(alpha: 0.5),
                  blurRadius: glow,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        );
      },
    );
  }
}

/// Lightweight Particle Confetti Overlay
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
    _particles = List.generate(55, (index) {
      return _Particle(
        x: random.nextDouble(),
        startY: -0.30 - random.nextDouble() * 0.50,
        speedY: 1.40 + random.nextDouble() * 0.75,
        speedX: (random.nextDouble() - 0.5) * 0.35,
        size: 9.0 + random.nextDouble() * 11.0,
        color: [
          const Color(0xFFFFB703),
          const Color(0xFF0A84FF),
          const Color(0xFF30D158),
          const Color(0xFFFF453A),
          const Color(0xFFBF5AF2),
          const Color(0xFFFF2D55),
          const Color(0xFF5AC8FA),
        ][random.nextInt(7)],
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 8.0,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
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
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });

  final double x;
  final double startY;
  final double speedY;
  final double speedX;
  final double size;
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
    // Fade out smoothly towards the end of the one-shot animation
    final globalAlpha = progress > 0.80
        ? (1.0 - ((progress - 0.80) / 0.20)).clamp(0.0, 1.0)
        : 1.0;

    if (globalAlpha <= 0.0) return;

    for (final p in particles) {
      final currentY = p.startY + (p.speedY * progress);
      final currentX = (p.x + (p.speedX * progress)) % 1.0;

      if (currentY < -0.1 || currentY > 1.2) continue;

      final dx = currentX * size.width;
      final dy = currentY * size.height;

      final paint = Paint()
        ..color = p.color.withValues(alpha: 0.92 * globalAlpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.rotation + (progress * p.rotationSpeed));

      // Flutter effect: scale width sinusoidally for 3D paper spin
      final flutterScale = math.sin(progress * 10 + p.rotation);
      canvas.scale(flutterScale.abs().clamp(0.2, 1.0), 1.0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.55,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
