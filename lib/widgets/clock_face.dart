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
    this.use24HourFormat = true,
    this.sessionStart,
    this.fontFamily = 'BebasNeue',
  });

  final Palette p;
  final int pulseToken;
  final String pulseType;
  final bool showSeconds;
  final bool highlightSeconds;
  final bool use24HourFormat;
  final int? sessionStart;
  final String fontFamily;

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
      use24HourFormat: widget.use24HourFormat,
      sessionElapsed: sessionElapsed,
      fontFamily: widget.fontFamily,
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
    this.use24HourFormat = true,
    this.sessionElapsed,
    this.fontFamily = 'BebasNeue',
  });

  final DateTime now;
  final Palette p;
  final int pulseToken;
  final String pulseType;
  final bool minimal;
  final bool showSeconds;
  final bool highlightSeconds;
  final bool use24HourFormat;
  final Duration? sessionElapsed;
  final String fontFamily;

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
    final String period;

    if (isSessionActive) {
      period = '';
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
      if (widget.use24HourFormat) {
        hm =
            '${widget.now.hour.toString().padLeft(2, '0')}:${widget.now.minute.toString().padLeft(2, '0')}';
        period = '';
      } else {
        final h = widget.now.hour % 12 == 0 ? 12 : widget.now.hour % 12;
        hm = '$h:${widget.now.minute.toString().padLeft(2, '0')}';
        period = '';
      }
      sec = '.${widget.now.second.toString().padLeft(2, '0')}';
    }

    final bool isContrastClock =
        widget.p.clock == const Color(0xFFFFFFFF) ||
        widget.p.clock == const Color(0xFF000000);
    final baseClockColor = isContrastClock
        ? widget.p.clock
        : (isSessionActive ? widget.p.green : widget.p.clock);
    final actionColor = isContrastClock
        ? (widget.p.clock == const Color(0xFF000000)
              ? const Color(0xDD000000)
              : const Color(0xFFFFFFFF))
        : (isSessionActive
              ? widget.p.green
              : momentColor(widget.p, widget.pulseType));
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
    final isApple =
        widget.fontFamily == 'Inter' || widget.fontFamily == 'SF Pro Display';
    final clockFamily = widget.fontFamily;
    final hmFontSize = isApple ? 106.0 : 144.0;
    final hmFontWeight = isApple ? FontWeight.w800 : FontWeight.w400;
    final hmLetterSpacing = isApple ? -2.5 : 1.0;

    final secFontSize = isApple ? 42.0 : 52.0;
    final secFontWeight = isApple ? FontWeight.w700 : FontWeight.w400;
    final secLetterSpacing = isApple ? -1.0 : 0.5;

    final periodFontSize = isApple ? 26.0 : 32.0;
    final periodFontWeight = isApple ? FontWeight.w700 : FontWeight.w400;
    final periodLetterSpacing = isApple ? -0.5 : 1.0;

    final fallbacks = isApple
        ? const ['Inter', 'SF Pro Display', 'Roboto', 'sans-serif']
        : const [
            'Roboto Condensed',
            'sans-serif-condensed',
            'Arial Narrow',
            'sans-serif',
          ];

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
                  fontFamily: clockFamily,
                  fontFamilyFallback: fallbacks,
                  fontSize: hmFontSize,
                  fontWeight: hmFontWeight,
                  height: 1,
                  letterSpacing: hmLetterSpacing,
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
                    fontFamily: clockFamily,
                    fontFamilyFallback: fallbacks,
                    fontSize: secFontSize,
                    fontWeight: secFontWeight,
                    height: 1,
                    letterSpacing: secLetterSpacing,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              if (!widget.minimal && period.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  period,
                  style: TextStyle(
                    color: _bright
                        ? actionColor.withValues(alpha: 0.75)
                        : secondsColor,
                    fontFamily: clockFamily,
                    fontFamilyFallback: fallbacks,
                    fontSize: periodFontSize,
                    fontWeight: periodFontWeight,
                    height: 1,
                    letterSpacing: periodLetterSpacing,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
