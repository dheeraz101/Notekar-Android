import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChronoFocusGame extends StatefulWidget {
  const ChronoFocusGame({super.key, required this.p, required this.onClose});

  final Palette p;
  final VoidCallback onClose;

  @override
  State<ChronoFocusGame> createState() => _ChronoFocusGameState();
}

class _ChronoFocusGameState extends State<ChronoFocusGame>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  // Game State
  int _score = 0;
  int _highScore = 0;
  int _sovereignWins = 0;
  bool _won = false;
  bool _glitchFailed = false;

  // Sweep Physics
  double _sweepAngle = 0.0; // 0 to 2*pi
  double _sweepSpeed = 2.4; // Radians per sec

  // Target Zone
  double _targetAngle = math.pi / 2; // Position around circle
  double _targetWidth = 0.45; // Radians wide (~25 degrees)
  String _targetLabel = 'IN';

  // Reticle Angle (Controlled by phone tilt)
  double _reticleAngle = 0.0;
  double _tiltSmoothX = 0.0;
  double _tiltSmoothY = 0.0;

  final List<String> _labels = [
    'IN',
    'OUT',
    'SINGLE',
    'ZEN',
    'PULSE',
    'SOVEREIGN',
  ];

  @override
  void initState() {
    super.initState();
    _loadScores();
    _randomizeTarget();

    try {
      _sensorSub = accelerometerEventStream().listen((event) {
        if (!mounted) return;
        // Smooth filter
        _tiltSmoothX = (_tiltSmoothX * 0.7) + (-event.x * 0.3);
        _tiltSmoothY = (_tiltSmoothY * 0.7) + (event.y * 0.3);

        final angle = math.atan2(_tiltSmoothY, _tiltSmoothX);
        setState(() {
          _reticleAngle = (angle + (2 * math.pi)) % (2 * math.pi);
        });
      });
    } catch (_) {}

    _ticker = createTicker(_onTick)..start();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _highScore = prefs.getInt('chrono_game_high_score') ?? 0;
      _sovereignWins = prefs.getInt('chrono_game_wins') ?? 0;
    });
  }

  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('chrono_game_high_score', _highScore);
    await prefs.setInt('chrono_game_wins', _sovereignWins);
  }

  void _randomizeTarget() {
    final random = math.Random();
    _targetAngle = random.nextDouble() * (2 * math.pi);
    _targetLabel = _labels[random.nextInt(_labels.length)];
    // As score increases, target narrows and sweep speed accelerates!
    _targetWidth = math.max(0.24, 0.48 - (_score * 0.022));
    _sweepSpeed = 2.4 + (_score * 0.38);
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    setState(() {
      _sweepAngle = (_sweepAngle + (_sweepSpeed * 0.016)) % (2 * math.pi);
    });
  }

  void _handleStrike() {
    if (_won) {
      // Reset after victory
      setState(() {
        _score = 0;
        _won = false;
        _randomizeTarget();
      });
      return;
    }

    // Check angle difference between sweep and target
    double diffSweepTarget = (_sweepAngle - _targetAngle).abs();
    if (diffSweepTarget > math.pi) {
      diffSweepTarget = (2 * math.pi) - diffSweepTarget;
    }

    // Check angle difference between reticle tilt and target
    double diffReticleTarget = (_reticleAngle - _targetAngle).abs();
    if (diffReticleTarget > math.pi) {
      diffReticleTarget = (2 * math.pi) - diffReticleTarget;
    }

    final isSweepHit = diffSweepTarget <= (_targetWidth / 2);
    final isReticleHit = diffReticleTarget <= (_targetWidth * 0.85);

    if (isSweepHit && isReticleHit) {
      // PERFECT HIT!
      HapticFeedback.heavyImpact();
      final newScore = _score + 1;
      final newHigh = math.max(_highScore, newScore);

      if (newScore >= 10) {
        // VICTORY: 10 CONSECUTIVE FOCUS HITS!
        HapticFeedback.heavyImpact();
        setState(() {
          _score = newScore;
          _highScore = newHigh;
          _sovereignWins += 1;
          _won = true;
          _glitchFailed = false;
        });
        _saveScores();
      } else {
        setState(() {
          _score = newScore;
          _highScore = newHigh;
          _glitchFailed = false;
          _randomizeTarget();
        });
        _saveScores();
      }
    } else {
      // MISSED! Glitch failure reset
      HapticFeedback.vibrate();
      setState(() {
        _score = 0;
        _glitchFailed = true;
      });
      Future.delayed(const Duration(milliseconds: 320), () {
        if (mounted) setState(() => _glitchFailed = false);
      });
    }
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _glitchFailed
            ? const Color(0xFFFF0055).withValues(alpha: 0.25)
            : p.surface2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _won
              ? const Color(0xFFFFD700)
              : (_glitchFailed ? const Color(0xFFFF0055) : p.border),
          width: _won ? 2 : 1,
        ),
        boxShadow: [
          if (_won)
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _won
                          ? const Color(0xFFFFD700)
                          : p.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _won ? Icons.emoji_events_rounded : Icons.radar_rounded,
                      color: _won ? Colors.black : p.accent,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CHRONO FOCUS'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Best: $_highScore • Wins: $_sovereignWins',
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Icon(Icons.close_rounded, size: 18, color: p.text3),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Interactive Radar Canvas
          GestureDetector(
            onTap: _handleStrike,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.border.withValues(alpha: 0.4)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(160, 160),
                    painter: _ChronoRadarPainter(
                      sweepAngle: _sweepAngle,
                      targetAngle: _targetAngle,
                      targetWidth: _targetWidth,
                      reticleAngle: _reticleAngle,
                      targetLabel: _targetLabel,
                      score: _score,
                      p: p,
                      won: _won,
                      glitch: _glitchFailed,
                    ),
                  ),
                  if (_won)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '⚡ TEMPORAL SOVEREIGN!',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to Play Again',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_score / 10',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          _glitchFailed
                              ? 'TIMING SHATTERED'
                              : 'TILT & TAP ON SYNC',
                          style: TextStyle(
                            color: _glitchFailed
                                ? const Color(0xFFFF0055)
                                : Colors.white.withValues(alpha: 0.6),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Tap Button Action
          PressableScale(
            onTap: _handleStrike,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _won
                      ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                      : [p.accent, p.accent.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _won ? '🏆 CLAIM SOVEREIGN GLORY' : 'STRIKE ON SYNC',
                style: TextStyle(
                  color: _won ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChronoRadarPainter extends CustomPainter {
  _ChronoRadarPainter({
    required this.sweepAngle,
    required this.targetAngle,
    required this.targetWidth,
    required this.reticleAngle,
    required this.targetLabel,
    required this.score,
    required this.p,
    required this.won,
    required this.glitch,
  });

  final double sweepAngle;
  final double targetAngle;
  final double targetWidth;
  final double reticleAngle;
  final String targetLabel;
  final int score;
  final Palette p;
  final bool won;
  final bool glitch;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 14;

    // Outer Ring
    final ringPaint = Paint()
      ..color = won
          ? const Color(0xFFFFD700).withValues(alpha: 0.8)
          : (glitch ? const Color(0xFFFF0055) : p.border.withValues(alpha: 0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.65, ringPaint..strokeWidth = 0.8);

    // Target Arc Zone
    final targetPaint = Paint()
      ..color = won
          ? const Color(0xFFFFD700)
          : const Color(0xFF00FF66).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      targetAngle - (targetWidth / 2),
      targetWidth,
      false,
      targetPaint,
    );

    // Tilt Reticle Position
    final reticleX = center.dx + (radius * 0.85 * math.cos(reticleAngle));
    final reticleY = center.dy + (radius * 0.85 * math.sin(reticleAngle));
    final reticlePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(reticleX, reticleY), 5.0, reticlePaint);
    canvas.drawCircle(
      Offset(reticleX, reticleY),
      8.0,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Sweep Needle
    final sweepX = center.dx + (radius * math.cos(sweepAngle));
    final sweepY = center.dy + (radius * math.sin(sweepAngle));
    final sweepPaint = Paint()
      ..color = won ? const Color(0xFFFFD700) : Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(sweepX, sweepY), sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _ChronoRadarPainter oldDelegate) => true;
}
