import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';

enum UrgeMode { boxBreathing, grounding }

class UrgeSurfingDialog extends StatefulWidget {
  const UrgeSurfingDialog({super.key, required this.p});

  final Palette p;

  @override
  State<UrgeSurfingDialog> createState() => _UrgeSurfingDialogState();
}

class _UrgeSurfingDialogState extends State<UrgeSurfingDialog>
    with SingleTickerProviderStateMixin {
  UrgeMode _mode = UrgeMode.boxBreathing;

  // Box Breathing state
  late AnimationController _breathingController;
  Timer? _timer;
  int _secondsRemaining = 60;
  String _phaseText = 'Inhale';
  int _phaseIndex = 0; // 0: Inhale, 1: Hold, 2: Exhale, 3: Hold
  bool _isActive = false;

  // Grounding state (5-4-3-2-1)
  int _groundingStep = 5;
  final List<String> _groundingPrompts = [
    'Acknowledge 5 things you can SEE around you.',
    'Acknowledge 4 things you can TOUCH around you.',
    'Acknowledge 3 things you can HEAR around you.',
    'Acknowledge 2 things you can SMELL around you.',
    'Acknowledge 1 thing you can TASTE right now.',
  ];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breathingController.addStatusListener((status) {
      if (!_isActive) return;
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _nextPhase();
      }
    });
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _secondsRemaining = 60;
      _phaseIndex = 0;
      _phaseText = 'Inhale';
    });
    HapticFeedback.mediumImpact();
    _breathingController.forward(from: 0.0);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        t.cancel();
        _stopBreathing();
        HapticFeedback.heavyImpact();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _nextPhase() {
    if (!_isActive) return;
    _phaseIndex = (_phaseIndex + 1) % 4;
    HapticFeedback.lightImpact();

    switch (_phaseIndex) {
      case 0:
        _phaseText = 'Inhale';
        _breathingController.forward(from: 0.0);
        break;
      case 1:
        _phaseText = 'Hold';
        _breathingController.stop();
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && _isActive && _phaseIndex == 1) _nextPhase();
        });
        break;
      case 2:
        _phaseText = 'Exhale';
        _breathingController.reverse(from: 1.0);
        break;
      case 3:
        _phaseText = 'Hold';
        _breathingController.stop();
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && _isActive && _phaseIndex == 3) _nextPhase();
        });
        break;
    }
    setState(() {});
  }

  void _stopBreathing() {
    _timer?.cancel();
    _breathingController.stop();
    setState(() {
      _isActive = false;
      _phaseText = 'Completed';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return AppSheet(
      p: p,
      title: 'Urge Surfing & Grounding'.localized(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Segmented Control Switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _mode = UrgeMode.boxBreathing);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _mode == UrgeMode.boxBreathing
                            ? p.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: _mode == UrgeMode.boxBreathing
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Box Breathing'.localized(context),
                        style: TextStyle(
                          color: _mode == UrgeMode.boxBreathing
                              ? p.text
                              : p.text2,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _mode = UrgeMode.grounding);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _mode == UrgeMode.grounding
                            ? p.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: _mode == UrgeMode.grounding
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '5-4-3-2-1 Grounding'.localized(context),
                        style: TextStyle(
                          color: _mode == UrgeMode.grounding ? p.text : p.text2,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_mode == UrgeMode.boxBreathing) ...[
            Center(
              child: AnimatedBuilder(
                animation: _breathingController,
                builder: (context, child) {
                  final scale = 1.0 + (_breathingController.value * 0.35);
                  return Container(
                    width: 140 * scale,
                    height: 140 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.accent.withValues(alpha: 0.15),
                      border: Border.all(
                        color: p.accent,
                        width: _isActive ? 4 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: p.accent.withValues(
                            alpha: 0.25 * _breathingController.value,
                          ),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _phaseText,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (_isActive) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${_secondsRemaining}s',
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Cravings peak and crest like ocean waves. Breathe through the wave for 60 seconds.'
                  .localized(context),
              style: TextStyle(color: p.text2, fontSize: 12, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _isActive ? p.red : p.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: _isActive ? _stopBreathing : _startBreathing,
                icon: Icon(
                  _isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(
                  (_isActive ? 'Pause Timer' : 'Start 60s Breathing Session')
                      .localized(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else ...[
            // Grounding 5-4-3-2-1
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: p.surface2.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int step = 5; step >= 1; step--) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _groundingStep == step
                                ? p.accent
                                : p.surface3,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$step',
                            style: TextStyle(
                              color: _groundingStep == step
                                  ? Colors.white
                                  : p.text2,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (step > 1) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    _getGroundingIcon(_groundingStep),
                    color: p.accent,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _groundingPrompts[5 - _groundingStep],
                    style: TextStyle(
                      color: p.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    if (_groundingStep > 1) {
                      _groundingStep--;
                    } else {
                      _groundingStep = 5;
                      HapticFeedback.heavyImpact();
                    }
                  });
                },
                child: Text(
                  (_groundingStep > 1
                          ? 'Next Grounding Sense'
                          : 'Reset Technique')
                      .localized(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  IconData _getGroundingIcon(int step) {
    switch (step) {
      case 5:
        return CupertinoIcons.eye_fill;
      case 4:
        return CupertinoIcons.hand_draw_fill;
      case 3:
        return CupertinoIcons.speaker_2_fill;
      case 2:
        return CupertinoIcons.wind;
      case 1:
        return CupertinoIcons.heart_fill;
      default:
        return CupertinoIcons.circle;
    }
  }
}
