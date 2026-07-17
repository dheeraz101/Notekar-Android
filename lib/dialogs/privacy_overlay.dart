import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class PrivacyLockOverlay extends StatelessWidget {
  const PrivacyLockOverlay({
    super.key,
    required this.p,
    required this.onUnlock,
  });

  final Palette p;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: p.bg,
        child: DefaultTextStyle(
          style: TextStyle(
            color: p.text,
            decoration: TextDecoration.none,
            fontFamily: 'Roboto',
          ),
          child: ColoredBox(
            color: p.bg,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: spacing32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.surface2,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.border),
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            color: p.accent,
                            size: 23,
                          ),
                        ),
                        const SizedBox(height: spacing24),
                        Text(
                          'Private by default',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: spacing8),
                        Text(
                          'Your moments stay hidden until you unlock NoteKar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 13,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: spacing24),
                        PressableScale(
                          onTap: onUnlock,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: spacing16,
                              vertical: spacing16,
                            ),
                            decoration: BoxDecoration(
                              color: p.accent,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: selectedGlow(p.accent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_open_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: spacing8),
                                Text(
                                  'Unlock NoteKar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
