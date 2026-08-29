import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class TimeReflectionSheet extends StatefulWidget {
  const TimeReflectionSheet({
    super.key,
    required this.p,
    this.intervalMinutes = 60,
    this.customMessage,
    this.playSound = true,
    this.onLogMoment,
  });

  final Palette p;
  final int intervalMinutes;
  final String? customMessage;
  final bool playSound;
  final VoidCallback? onLogMoment;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    int intervalMinutes = 60,
    String? customMessage,
    bool playSound = true,
    VoidCallback? onLogMoment,
  }) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => Material(
        color: Colors.transparent,
        child: TimeReflectionSheet(
          p: p,
          intervalMinutes: intervalMinutes,
          customMessage: customMessage,
          playSound: playSound,
          onLogMoment: onLogMoment,
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curve = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curve),
            child: child,
          ),
        );
      },
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

    if (widget.playSound) {
      SystemSound.play(SystemSoundType.alert);
      try {
        const MethodChannel(
          'notekar/files',
        ).invokeMethod('playReflectionSound');
      } catch (_) {}
    }
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
    final now = TimeOfDay.now();
    final message =
        (widget.customMessage != null &&
            widget.customMessage!.trim().isNotEmpty)
        ? widget.customMessage!.trim()
        : 'Pause. Breathe. Be present in this moment.'.localized(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: p.bg,
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar with Alarm Badge and Close
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: p.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: p.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Mindfulness Alarm'.localized(context),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PressableScale(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: p.surface2,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: p.text2,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Mindful Breathing Pulsing Ring with Large Clock
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          final scale = 1.0 + (_pulseAnimation.value * 0.14);
                          final glowAlpha =
                              0.12 + (_pulseAnimation.value * 0.18);

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ambient ring
                              Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: p.accent.withValues(
                                      alpha: glowAlpha,
                                    ),
                                  ),
                                ),
                              ),
                              // Mid ring
                              Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: p.surface2,
                                  border: Border.all(
                                    color: p.accent.withValues(alpha: 0.4),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: p.accent.withValues(alpha: 0.25),
                                      blurRadius: 32,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.self_improvement_rounded,
                                      color: p.accent,
                                      size: 42,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      now.format(context),
                                      style: TextStyle(
                                        color: p.text,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Passed interval badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: p.accent.withValues(alpha: 0.35),
                        ),
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

                    const SizedBox(height: 18),

                    // Mindfulness Title
                    Text(
                      'Take a Mindful Breath'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    // Focused Custom / Motivational Message (max 60 chars)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 360),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Single Primary Action Button at Bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    widget.onLogMoment?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "I'm Mindful".localized(context),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
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
