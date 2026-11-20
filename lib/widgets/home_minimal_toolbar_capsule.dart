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
    final isLight = !palette.isDark;
    final iconColor = isLight ? const Color(0xFF1C1C1E) : palette.text;
    final secondaryIconColor = isLight
        ? const Color(0xFF3C3C43)
        : palette.text2;

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isLight
            ? const Color(0xFFFFFFFF).withValues(
                alpha: enableTranslucency && AdaptiveEngine().supportsBlur
                    ? 0.90
                    : 0.98,
              )
            : palette.surface2.withValues(
                alpha: enableTranslucency && AdaptiveEngine().supportsBlur
                    ? 0.75
                    : 0.95,
              ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isLight
              ? const Color(0xFFD1D1D6).withValues(alpha: 0.85)
              : palette.border.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.14 : 0.12),
            blurRadius: 12,
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
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(
                  isSessionActive
                      ? (isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded)
                      : (mode == 'single'
                            ? Icons.radio_button_checked_rounded
                            : Icons.all_inclusive_rounded),
                  size: 18,
                  color: isSessionActive
                      ? (isPaused
                            ? palette.orange
                            : (isLight
                                  ? const Color(0xFF1C1C1E)
                                  : palette.text))
                      : palette.accent,
                ),
              ),
            ),
          ),
          Container(
            width: 0.5,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: isLight
                ? const Color(0xFFD1D1D6).withValues(alpha: 0.7)
                : palette.border.withValues(alpha: 0.4),
          ),
          PressableScale(
            onTap: onOpenHistory,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: iconColor,
                ),
              ),
            ),
          ),
          Container(
            width: 0.5,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: isLight
                ? const Color(0xFFD1D1D6).withValues(alpha: 0.7)
                : palette.border.withValues(alpha: 0.4),
          ),
          PressableScale(
            onTap: onOpenSettings,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.settings_rounded,
                  size: 18,
                  color: secondaryIconColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
