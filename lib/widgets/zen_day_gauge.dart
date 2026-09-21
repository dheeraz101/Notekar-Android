import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';

/// Serene, ambient 24h Intentionality Ring.
/// Whisper-thin circular arc displaying conscious hours lived today vs daily target.
class ZenDayRing extends StatelessWidget {
  const ZenDayRing({
    super.key,
    required this.p,
    required this.progress,
    this.size = 12.0,
    this.strokeWidth = 1.6,
  });

  final Palette p;
  final double progress;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final isGoalMet = progress >= 1.0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ZenRingPainter(
          trackColor: p.text3.withValues(alpha: 0.2),
          progressColor: isGoalMet ? p.green : p.accent,
          progress: clamped,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _ZenRingPainter extends CustomPainter {
  _ZenRingPainter({
    required this.trackColor,
    required this.progressColor,
    required this.progress,
    required this.strokeWidth,
  });

  final Color trackColor;
  final Color progressColor;
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0.0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ZenRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
