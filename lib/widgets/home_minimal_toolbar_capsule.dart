import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Minimal, floating capsule toolbar for the Home Screen.
class HomeMinimalToolbarCapsule extends StatelessWidget {
  const HomeMinimalToolbarCapsule({
    super.key,
    required this.palette,
    required this.mode,
    required this.enableTranslucency,
    required this.onToggleMode,
    required this.onOpenHistory,
    required this.onOpenSettings,
    this.isSessionActive = false,
    this.isPaused = false,
    this.onTogglePause,
  });

  final Palette palette;
  final String mode;
  final bool enableTranslucency;
  final VoidCallback onToggleMode;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenSettings;
  final bool isSessionActive;
  final bool isPaused;
  final VoidCallback? onTogglePause;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: palette.surface2.withValues(
          alpha: enableTranslucency && AdaptiveEngine().supportsBlur
              ? 0.75
              : 0.95,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.border.withValues(alpha: 0.35),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PressableScale(
            onTap: isSessionActive && onTogglePause != null
                ? onTogglePause!
                : onToggleMode,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                isSessionActive
                    ? (isPaused
                          ? CupertinoIcons.play_arrow_solid
                          : CupertinoIcons.pause_fill)
                    : (mode == 'single'
                          ? Icons.radio_button_checked_rounded
                          : Icons.all_inclusive_rounded),
                size: 16,
                color: isSessionActive
                    ? (isPaused ? palette.orange : palette.text)
                    : palette.accent,
              ),
            ),
          ),
          Container(
            width: 0.5,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: palette.border.withValues(alpha: 0.4),
          ),
          PressableScale(
            onTap: onOpenHistory,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(CupertinoIcons.clock, size: 16, color: palette.text),
            ),
          ),
          Container(
            width: 0.5,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: palette.border.withValues(alpha: 0.4),
          ),
          PressableScale(
            onTap: onOpenSettings,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                CupertinoIcons.gear_alt,
                size: 16,
                color: palette.text2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
