import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class PrivacyLockOverlay extends StatefulWidget {
  const PrivacyLockOverlay({
    super.key,
    required this.p,
    required this.onUnlock,
  });

  final Palette p;
  final VoidCallback onUnlock;

  @override
  State<PrivacyLockOverlay> createState() => _PrivacyLockOverlayState();
}

class _PrivacyLockOverlayState extends State<PrivacyLockOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Slower, calmer pulse
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Positioned.fill(
      child: Material(
        color: p.bg,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [p.bg, p.surface],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                // Minimal pulsing icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.4 + (_pulseController.value * 0.6),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: p.accent.withValues(alpha: 0.2)),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      color: p.accent,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: spacing32),
                Text(
                  'Private by default',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: spacing12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: spacing48),
                  child: Text(
                    'Your moments stay hidden until you unlock NoteKar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                // Minimalist Button (No Shadows/Glows)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: spacing32),
                  child: PressableScale(
                    onTap: widget.onUnlock,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Unlock NoteKar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: spacing48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
