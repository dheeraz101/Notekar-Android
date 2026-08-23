import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class TimeReflectionSheet extends StatefulWidget {
  const TimeReflectionSheet({
    super.key,
    required this.p,
    this.intervalMinutes = 60,
    this.onLogMoment,
  });

  final Palette p;
  final int intervalMinutes;
  final VoidCallback? onLogMoment;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    int intervalMinutes = 60,
    VoidCallback? onLogMoment,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => TimeReflectionSheet(
        p: p,
        intervalMinutes: intervalMinutes,
        onLogMoment: onLogMoment,
      ),
    );
  }

  @override
  State<TimeReflectionSheet> createState() => _TimeReflectionSheetState();
}

class _TimeReflectionSheetState extends State<TimeReflectionSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatIntervalText(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final rem = minutes % 60;
      if (rem == 0) {
        return hours == 1 ? '1 Hour Has Passed' : '$hours Hours Have Passed';
      }
      return '$hours h $rem min Have Passed';
    }
    return '$minutes Minutes Have Passed';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final size = MediaQuery.of(context).size;
    final now = TimeOfDay.now();

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
        border: Border.all(color: p.border.withValues(alpha: 0.5), width: 0.8),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Grabber handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: p.text3.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Top Bar with Close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time Reflection'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  PressableScale(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: p.surface2,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: p.text2,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mindful Breathing Pulsing Ring
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseAnimation.value * 0.12);
                        final glowAlpha = 0.12 + (_pulseAnimation.value * 0.16);

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ambient ring
                            Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: p.accent.withValues(alpha: glowAlpha),
                                ),
                              ),
                            ),
                            // Mid ring
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.surface2,
                                border: Border.all(
                                  color: p.accent.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: p.accent.withValues(alpha: 0.2),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.hourglass_top_rounded,
                                    color: p.accent,
                                    size: 36,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    now.format(context),
                                    style: TextStyle(
                                      color: p.text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Passed interval text
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _formatIntervalText(
                          widget.intervalMinutes,
                        ).localized(context),
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mindfulness Title & Guidance
                    Text(
                      'Take a Mindful Breath'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'With your phone always with you, pause for a moment. Reflect on how you spent your last hour, and decide your focus for the next.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 14,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Quote / Reflection Card
                    Glass(
                      p: p,
                      radius: 20,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.self_improvement_rounded,
                            color: p.accent,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              '"Time is what we want most, but what we use worst."'
                                  .localized(context),
                              style: TextStyle(
                                color: p.text,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons at Bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        widget.onLogMoment?.call();
                      },
                      icon: const Icon(Icons.touch_app_rounded, size: 20),
                      label: Text(
                        'Log Current Moment'.localized(context),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: p.text2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Continue Mindfully'.localized(context),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
