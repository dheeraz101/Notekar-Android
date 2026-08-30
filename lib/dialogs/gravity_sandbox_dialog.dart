import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GravitySandboxDialog extends StatefulWidget {
  const GravitySandboxDialog({super.key, required this.p});

  final Palette p;

  static Future<void> show(BuildContext context, {required Palette p}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => GravitySandboxDialog(p: p),
    );
  }

  @override
  State<GravitySandboxDialog> createState() => _GravitySandboxDialogState();
}

class _SandboxOrb {
  _SandboxOrb({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.label,
    this.vx = 0.0,
    this.vy = 0.0,
  });

  final int id;
  double x;
  double y;
  double vx;
  double vy;
  final double radius;
  final Color color;
  final String label;
}

class _GravitySandboxDialogState extends State<GravitySandboxDialog>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  final List<_SandboxOrb> _orbs = [];
  double _gx = 0.0;
  double _gy = 980.0; // Default downward gravity (pixels / sec^2)
  Duration? _lastElapsed;
  int _orbIdCounter = 0;
  _SandboxOrb? _draggedOrb;

  @override
  void initState() {
    super.initState();
    _spawnInitialOrbs();

    // Accelerometer Stream
    try {
      _sensorSub = accelerometerEventStream().listen((event) {
        if (!mounted) return;
        // Map sensor coordinates (x tilt -> screen x, y tilt -> screen y)
        setState(() {
          _gx = -event.x * 160.0;
          _gy = event.y * 160.0;
        });
      });
    } catch (_) {}

    _ticker = createTicker(_onTick)..start();
  }

  void _spawnInitialOrbs() {
    final colors = [
      widget.p.accent,
      widget.p.green,
      widget.p.orange,
      widget.p.red,
      widget.p.blue,
      const Color(0xFFFF007A),
      const Color(0xFFFFD600),
      const Color(0xFF00E5FF),
    ];
    final labels = ['IN', 'OUT', 'PULSE', 'ZEN', 'CALM', 'TIME', '7.2.0', '★'];

    for (int i = 0; i < 8; i++) {
      _orbs.add(
        _SandboxOrb(
          id: _orbIdCounter++,
          x: 60.0 + (i * 38.0),
          y: 80.0 + (i % 3 * 60.0),
          vx: (math.Random().nextDouble() - 0.5) * 200,
          vy: (math.Random().nextDouble() - 0.5) * 200,
          radius: 20.0 + (math.Random().nextDouble() * 10),
          color: colors[i % colors.length],
          label: labels[i % labels.length],
        ),
      );
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (_lastElapsed == null) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed!).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.1) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final w = box.size.width;
    final h =
        box.size.height - 130; // Leave space for sheet header and controls

    setState(() {
      for (final orb in _orbs) {
        if (identical(orb, _draggedOrb)) continue;

        // Apply Gravity
        orb.vx += _gx * dt;
        orb.vy += _gy * dt;

        // Air drag
        orb.vx *= 0.992;
        orb.vy *= 0.992;

        // Update Position
        orb.x += orb.vx * dt;
        orb.y += orb.vy * dt;

        // Left / Right Walls
        if (orb.x - orb.radius < 10) {
          orb.x = 10 + orb.radius;
          orb.vx = -orb.vx * 0.72;
          HapticFeedback.selectionClick();
        } else if (orb.x + orb.radius > w - 10) {
          orb.x = w - 10 - orb.radius;
          orb.vx = -orb.vx * 0.72;
          HapticFeedback.selectionClick();
        }

        // Top / Bottom Walls
        if (orb.y - orb.radius < 20) {
          orb.y = 20 + orb.radius;
          orb.vy = -orb.vy * 0.72;
          HapticFeedback.selectionClick();
        } else if (orb.y + orb.radius > h) {
          orb.y = h - orb.radius;
          orb.vy = -orb.vy * 0.72;
          HapticFeedback.selectionClick();
        }
      }

      // Orb-to-Orb Collisions
      for (int i = 0; i < _orbs.length; i++) {
        for (int j = i + 1; j < _orbs.length; j++) {
          final o1 = _orbs[i];
          final o2 = _orbs[j];
          final dx = o2.x - o1.x;
          final dy = o2.y - o1.y;
          final dist = math.sqrt(dx * dx + dy * dy);
          final minDist = o1.radius + o2.radius;

          if (dist < minDist && dist > 0.001) {
            final overlap = 0.5 * (minDist - dist);
            final nx = dx / dist;
            final ny = dy / dist;

            // Separate
            o1.x -= nx * overlap;
            o1.y -= ny * overlap;
            o2.x += nx * overlap;
            o2.y += ny * overlap;

            // Normal velocity
            final kx = o1.vx - o2.vx;
            final ky = o1.vy - o2.vy;
            final p = 2 * (nx * kx + ny * ky) / (1 + 1);

            o1.vx -= p * nx * 0.85;
            o1.vy -= p * ny * 0.85;
            o2.vx += p * nx * 0.85;
            o2.vy += p * ny * 0.85;
          }
        }
      }
    });
  }

  void _spawnNewOrb(Offset pos) {
    HapticFeedback.mediumImpact();
    final colors = [
      widget.p.accent,
      widget.p.green,
      widget.p.orange,
      widget.p.red,
      widget.p.blue,
      const Color(0xFFFF007A),
      const Color(0xFFFFD600),
    ];
    setState(() {
      _orbs.add(
        _SandboxOrb(
          id: _orbIdCounter++,
          x: pos.dx,
          y: pos.dy,
          vx: (math.Random().nextDouble() - 0.5) * 350,
          vy: -200 - math.Random().nextDouble() * 200,
          radius: 22.0 + (math.Random().nextDouble() * 8),
          color: colors[math.Random().nextInt(colors.length)],
          label: 'MOMENT',
        ),
      );
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sensorSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return AppSheet(
      p: p,
      title: 'Mindful Gravity Sandbox'.localized(context),
      showLargeTitle: false,
      trailingAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PressableScale(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() {
                _orbs.clear();
                _spawnInitialOrbs();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 14, color: p.text2),
                  const SizedBox(width: 4),
                  Text(
                    'Reset'.localized(context),
                    style: TextStyle(color: p.text2, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      child: Container(
        height: 520,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            // Instructions banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.border.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.screen_rotation_rounded,
                    size: 16,
                    color: p.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tilt your device to guide gravity. Tap anywhere to spawn orbs.'
                          .localized(context),
                      style: TextStyle(color: p.text2, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Physics Canvas Area
            Expanded(
              child: GestureDetector(
                onTapDown: (details) => _spawnNewOrb(details.localPosition),
                onPanStart: (details) {
                  final pos = details.localPosition;
                  for (final orb in _orbs) {
                    final dx = orb.x - pos.dx;
                    final dy = orb.y - pos.dy;
                    if (math.sqrt(dx * dx + dy * dy) <= orb.radius * 1.5) {
                      _draggedOrb = orb;
                      HapticFeedback.selectionClick();
                      break;
                    }
                  }
                },
                onPanUpdate: (details) {
                  if (_draggedOrb != null) {
                    setState(() {
                      _draggedOrb!.x = details.localPosition.dx;
                      _draggedOrb!.y = details.localPosition.dy;
                      _draggedOrb!.vx = details.delta.dx * 60;
                      _draggedOrb!.vy = details.delta.dy * 60;
                    });
                  }
                },
                onPanEnd: (_) {
                  _draggedOrb = null;
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: p.accent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _SandboxPainter(orbs: _orbs, p: p),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SandboxPainter extends CustomPainter {
  _SandboxPainter({required this.orbs, required this.p});

  final List<_SandboxOrb> orbs;
  final Palette p;

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle background grid
    final gridPaint = Paint()
      ..color = p.border.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Render Orbs
    for (final orb in orbs) {
      // Glow Shadow
      final glowPaint = Paint()
        ..color = orb.color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(orb.x, orb.y), orb.radius + 2, glowPaint);

      // Core Gradient
      final orbPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                orb.color,
                orb.color.withValues(alpha: 0.85),
              ],
              stops: const [0.0, 0.45, 1.0],
              center: const Alignment(-0.35, -0.35),
            ).createShader(
              Rect.fromCircle(center: Offset(orb.x, orb.y), radius: orb.radius),
            );
      canvas.drawCircle(Offset(orb.x, orb.y), orb.radius, orbPaint);

      // Border ring
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(Offset(orb.x, orb.y), orb.radius, borderPaint);

      // Text label inside orb
      final tp = TextPainter(
        text: TextSpan(
          text: orb.label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 7.5,
            letterSpacing: -0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(orb.x - (tp.width / 2), orb.y - (tp.height / 2)));
    }
  }

  @override
  bool shouldRepaint(covariant _SandboxPainter oldDelegate) => true;
}
