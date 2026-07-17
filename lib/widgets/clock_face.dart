import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';

class LiveClockFace extends StatefulWidget {
  const LiveClockFace({
    super.key,
    required this.p,
    required this.pulseToken,
    required this.pulseType,
    required this.showSeconds,
    required this.highlightSeconds,
  });

  final Palette p;
  final int pulseToken;
  final String pulseType;
  final bool showSeconds;
  final bool highlightSeconds;

  @override
  State<LiveClockFace> createState() => _LiveClockFaceState();
}

class _LiveClockFaceState extends State<LiveClockFace> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scheduleNextTick();
  }

  void _scheduleNextTick() {
    _timer?.cancel();

    final now = DateTime.now();
    final millisecondsUntilNextSecond = 1000 - now.millisecond;

    _timer = Timer(Duration(milliseconds: millisecondsUntilNextSecond), () {
      if (!mounted) return;

      setState(() => _now = DateTime.now());
      _scheduleNextTick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClockFace(
      now: _now,
      p: widget.p,
      pulseToken: widget.pulseToken,
      pulseType: widget.pulseType,
      minimal: false,
      showSeconds: widget.showSeconds,
      highlightSeconds: widget.highlightSeconds,
    );
  }
}

class ClockFace extends StatefulWidget {
  const ClockFace({
    super.key,
    required this.now,
    required this.p,
    required this.pulseToken,
    required this.pulseType,
    required this.minimal,
    required this.showSeconds,
    required this.highlightSeconds,
  });

  final DateTime now;
  final Palette p;
  final int pulseToken;
  final String pulseType;
  final bool minimal;
  final bool showSeconds;
  final bool highlightSeconds;

  @override
  State<ClockFace> createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace> {
  bool _bright = false;
  Timer? _timer;

  @override
  void didUpdateWidget(covariant ClockFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulseToken != widget.pulseToken) {
      _timer?.cancel();
      setState(() => _bright = true);
      _timer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _bright = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hm =
        '${widget.now.hour.toString().padLeft(2, '0')}:${widget.now.minute.toString().padLeft(2, '0')}';
    final sec = '.${widget.now.second.toString().padLeft(2, '0')}';
    final actionColor = widget.p.accent;
    final clockColor = _bright
        ? actionColor.withValues(alpha: widget.p.name == 'light' ? 0.70 : 0.58)
        : widget.p.clock;
    final secondsColor = widget.highlightSeconds ? widget.p.text3 : clockColor;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            hm,
            style: TextStyle(
              color: clockColor,
              fontSize: 116,
              fontWeight: FontWeight.w200,
              height: 1,
              letterSpacing: -4,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (!widget.minimal && widget.showSeconds)
            Text(
              sec,
              style: TextStyle(
                color: _bright
                    ? actionColor.withValues(alpha: 0.75)
                    : secondsColor,
                fontSize: 42,
                fontWeight: FontWeight.w200,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}
