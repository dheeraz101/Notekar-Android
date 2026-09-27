import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';

/// Instant, elegant Zen / Doodle-style animated splash screen for NoteKar.
/// Plays a high-frame-rate 600ms doodle stroke reveal, dismissible instantly on tap.
class ZenDoodleSplash extends StatefulWidget {
  const ZenDoodleSplash({super.key, required this.p, required this.onComplete});

  final Palette p;
  final VoidCallback onComplete;

  /// Global session flag ensuring splash only plays once per app process launch.
  static bool hasShownThisSession = false;

  @override
  State<ZenDoodleSplash> createState() => _ZenDoodleSplashState();
}

class _ZenDoodleSplashState extends State<ZenDoodleSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _doodleProgress;
  late final Animation<double> _badgeScale;
  late final Animation<double> _badgeOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<double> _exitOpacity;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    ZenDoodleSplash.hasShownThisSession = true;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // 0ms - 400ms: Doodle stroke sweeps around the badge
    _doodleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );

    // 0ms - 450ms: Badge blooms into place
    _badgeScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutBack),
      ),
    );

    // 0ms - 300ms: Badge fades in
    _badgeOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
    );

    // 250ms - 550ms: NoteKar typography reveals
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    );

    // 550ms - 650ms: Graceful cross-fade into main app
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeInCubic),
      ),
    );

    _controller.forward().then((_) {
      _finish();
    });
  }

  void _finish() {
    if (_isExiting) return;
    _isExiting = true;
    if (mounted) {
      widget.onComplete();
    }
  }

  void _skipInstantly() {
    if (_isExiting) return;
    HapticFeedback.selectionClick();
    _controller.stop();
    _finish();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _skipInstantly,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _exitOpacity.value.clamp(0.0, 1.0),
            child: Container(
              color: widget.p.bg,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zen Ensō Doodle & Squircle Badge
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Hand-drawn Doodle Ensō Painter
                        CustomPaint(
                          size: const Size(140, 140),
                          painter: _ZenDoodlePainter(
                            progress: _doodleProgress.value,
                            color: widget.p.accent,
                          ),
                        ),
                        // Center Squircle Badge with Logo
                        Transform.scale(
                          scale: _badgeScale.value,
                          child: Opacity(
                            opacity: _badgeOpacity.value,
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: widget.p.surface2,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: widget.p.border.withValues(alpha: 0.6),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.p.accent.withValues(
                                      alpha: 0.12,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: CustomPaint(
                                size: const Size(42, 42),
                                painter: _NoteKarGlyphPainter(
                                  color: widget.p.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Brand Title & Tagline
                  Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        Text(
                          'NoteKar',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: widget.p.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Every moment intentional.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: widget.p.text3,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter rendering a Zen ensō / doodle ink sweep around the center badge.
class _ZenDoodlePainter extends CustomPainter {
  const _ZenDoodlePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // Organic doodle sweep arc
    const startAngle = -math.pi * 0.75;
    final sweepAngle = (math.pi * 1.9) * progress;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
    );

    // Subtle decorative doodle tick
    if (progress > 0.4) {
      final tickAngle = startAngle + sweepAngle;
      final tickStart = Offset(
        center.dx + (radius - 2) * math.cos(tickAngle),
        center.dy + (radius - 2) * math.sin(tickAngle),
      );
      final tickEnd = Offset(
        center.dx + (radius + 4) * math.cos(tickAngle),
        center.dy + (radius + 4) * math.sin(tickAngle),
      );
      canvas.drawLine(tickStart, tickEnd, paint..strokeWidth = 1.8);
    }

    canvas.drawPath(path, paint..strokeWidth = 2.4);
  }

  @override
  bool shouldRepaint(covariant _ZenDoodlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Precise vector painter for the Hindi "न" NoteKar insignia.
class _NoteKarGlyphPainter extends CustomPainter {
  const _NoteKarGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Coordinate space normalized from 40x40 viewport
    final scale = size.width / 40.0;
    canvas.save();
    canvas.scale(scale);

    final path = Path();
    path.moveTo(17.5, 8);
    path.lineTo(23, 10.5);
    path.quadraticBezierTo(20.5, 12, 24, 13.5);
    path.lineTo(24.5, 19);
    path.lineTo(25, 14);
    path.quadraticBezierTo(31.4, 11.7, 29, 19.5);
    path.lineTo(28, 23.5);
    path.lineTo(29, 30);
    path.quadraticBezierTo(23, 32.3, 25, 25.5);
    path.lineTo(24, 25.5);
    path.quadraticBezierTo(26.6, 32.8, 20.5, 31);
    path.lineTo(19, 29.5);
    path.lineTo(19, 12);
    path.lineTo(16, 12.5);
    path.lineTo(16, 31);
    path.lineTo(12, 31);
    path.lineTo(12, 11.5);
    path.lineTo(14.5, 9);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NoteKarGlyphPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
