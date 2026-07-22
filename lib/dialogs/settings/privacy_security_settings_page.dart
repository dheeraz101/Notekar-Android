import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/settings_controller.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class PrivacySecuritySettingsPage extends StatelessWidget {
  const PrivacySecuritySettingsPage({
    super.key,
    required this.p,
    required this.controller,
    required this.hasSystemLock,
    required this.onOpenLockSettings,
  });

  final Palette p;
  final SettingsController controller;
  final bool hasSystemLock;
  final VoidCallback onOpenLockSettings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          children: [
            const SizedBox(height: 8),
            if (!hasSystemLock)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: p.orange.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: p.orange,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No Android screen lock detected. Set up a PIN or Biometrics in your device Settings to enable App Lock.',
                          style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SettingsGroup(
              p: p,
              children: [
                SettingsRow(
                  p: p,
                  icon: Icons.lock_outline_rounded,
                  title: 'App Lock',
                  status: hasSystemLock ? 'Configured' : 'Setup Required',
                  color: hasSystemLock ? p.accent : p.orange,
                  onTap: onOpenLockSettings,
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text:
                  'Protect NoteKar with your device screen lock or biometric credentials.',
            ),
            const SizedBox(height: 48),
          ],
        );
      },
    );
  }
}
