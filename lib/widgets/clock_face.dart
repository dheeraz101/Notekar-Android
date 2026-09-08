import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

class LiveClockFace extends StatefulWidget {
  const LiveClockFace({
    super.key,
    required this.p,
    required this.pulseToken,
    required this.pulseType,
    required this.showSeconds,
    required this.highlightSeconds,
    this.sessionStart,
  });

  final Palette p;
  final int pulseToken;
  final String pulseType;
  final bool showSeconds;
  final bool highlightSeconds;
  final int? sessionStart;

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
    Duration? sessionElapsed;
    if (widget.sessionStart != null) {
      final startDt = DateTime.fromMillisecondsSinceEpoch(widget.sessionStart!);
      sessionElapsed = _now.difference(startDt);
      if (sessionElapsed.isNegative) sessionElapsed = Duration.zero;
    }

    return ClockFace(
      now: _now,
      p: widget.p,
      pulseToken: widget.pulseToken,
      pulseType: widget.pulseType,
      minimal: false,
      showSeconds: widget.showSeconds,
      highlightSeconds: widget.highlightSeconds,
      sessionElapsed: sessionElapsed,
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
    this.sessionElapsed,
  });

  final DateTime now;
  final Palette p;
  final int pulseToken;
  final String pulseType;
  final bool minimal;
  final bool showSeconds;
  final bool highlightSeconds;
  final Duration? sessionElapsed;

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
    final isSessionActive = widget.sessionElapsed != null;
    final String hm;
    final String sec;

    if (isSessionActive) {
      final elapsed = widget.sessionElapsed!;
      if (elapsed.inHours > 0) {
        final hours = elapsed.inHours.toString().padLeft(2, '0');
        final mins = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
        final secs = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
        hm = '$hours:$mins';
        sec = '.$secs';
      } else {
        final mins = elapsed.inMinutes.toString().padLeft(2, '0');
        final secs = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
        hm = '$mins:$secs';
        sec = '';
      }
    } else {
      hm =
          '${widget.now.hour.toString().padLeft(2, '0')}:${widget.now.minute.toString().padLeft(2, '0')}';
      sec = '.${widget.now.second.toString().padLeft(2, '0')}';
    }

    final actionColor = isSessionActive
        ? widget.p.green
        : momentColor(widget.p, widget.pulseType);
    final baseClockColor = isSessionActive ? widget.p.green : widget.p.clock;
    final clockColor = _bright
        ? actionColor.withValues(alpha: widget.p.name == 'light' ? 0.70 : 0.58)
        : baseClockColor;
    final secondsColor = widget.highlightSeconds
        ? clockColor
        : clockColor.withValues(alpha: 0.38);
    final mediaQuery = MediaQuery.of(context);
    final clampedScaler = mediaQuery.textScaler.clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.25,
    );
    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: clampedScaler),
      child: AnimatedScale(
        scale: _bright ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                hm,
                style: TextStyle(
                  color: clockColor,
                  fontFamily: 'BebasNeue',
                  fontFamilyFallback: const [
                    'Roboto Condensed',
                    'sans-serif-condensed',
                    'Arial Narrow',
                    'sans-serif',
                  ],
                  fontSize: 144,
                  fontWeight: FontWeight.w400,
                  height: 1,
                  letterSpacing: 1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (!widget.minimal && widget.showSeconds && sec.isNotEmpty)
                Text(
                  sec,
                  style: TextStyle(
                    color: _bright
                        ? actionColor.withValues(alpha: 0.75)
                        : secondsColor,
                    fontFamily: 'BebasNeue',
                    fontFamilyFallback: const [
                      'Roboto Condensed',
                      'sans-serif-condensed',
                      'Arial Narrow',
                      'sans-serif',
                    ],
                    fontSize: 52,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
