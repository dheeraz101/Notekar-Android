import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class AppLockSettingsPage extends StatelessWidget {
  const AppLockSettingsPage({
    super.key,
    required this.p,
    required this.subCategory,
    required this.privacyLock,
    required this.isSystemLockAvailable,
    required this.privacyLockType,
    required this.privacyLockDelayMinutes,
    required this.onPrivacyLockChanged,
    required this.onResetPrivacyPin,
    required this.onPrivacyLockTypeChanged,
    required this.onPrivacyLockDelayChanged,
    required this.onOpenCategory,
    required this.onPopCategory,
    required this.onLearnMoreBeta,
  });

  final Palette p;
  final String subCategory; // 'App Lock', 'Configure Lock'
  final bool privacyLock;
  final bool isSystemLockAvailable;
  final String privacyLockType;
  final int privacyLockDelayMinutes;

  final ValueChanged<bool> onPrivacyLockChanged;
  final VoidCallback onResetPrivacyPin;
  final ValueChanged<String> onPrivacyLockTypeChanged;
  final ValueChanged<int> onPrivacyLockDelayChanged;
  final void Function(String category) onOpenCategory;
  final VoidCallback onPopCategory;
  final VoidCallback onLearnMoreBeta;

  @override
  Widget build(BuildContext context) {
    if (subCategory == 'App Lock') {
      return _buildAppLock(context);
    } else if (subCategory == 'Configure Lock') {
      return _buildConfigureLock(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildAppLock(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'App Lock',
              color: p.accent,
              value: privacyLock,
              onChanged: onPrivacyLockChanged,
            ),
            if (privacyLock && isSystemLockAvailable)
              SettingsRow(
                p: p,
                title: 'Configure Lock',
                status: privacyLockType == 'system'
                    ? 'System Lock'
                    : 'In-App PIN',
                onTap: () => onOpenCategory('Configure Lock'),
              ),
            if (privacyLock && privacyLockType == 'custom_pin')
              SettingsRow(
                p: p,
                title: 'Reset PIN Lock'.localized(context),
                subtitle: 'Change your secure in-app passcode.'.localized(
                  context,
                ),
                color: p.accent,
                onTap: onResetPrivacyPin,
              ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Requires biometric or system PIN authentication to open NoteKar.'
                  .localized(context),
        ),
        if (privacyLock) ...[
          SettingsGroup(
            p: p,
            title: 'When to Lock',
            children: [
              for (final entry in const {
                '0': 'Immediately',
                '1': 'After 1 Minute',
                '5': 'After 5 Minutes',
                '10': 'After 10 Minutes',
              }.entries)
                SettingsRow(
                  p: p,
                  title: entry.value,
                  trailing: privacyLockDelayMinutes == int.parse(entry.key)
                      ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                      : const SizedBox.shrink(),
                  onTap: () {
                    final minutes = int.parse(entry.key);
                    if (minutes == privacyLockDelayMinutes) {
                      return;
                    }
                    onPrivacyLockDelayChanged(minutes);
                  },
                ),
            ],
          ),
          SettingsPageDescription(
            p: p,
            text:
                'Note: Selecting "Immediately" will automatically lock NoteKar as soon as you switch apps, view recent apps, or open your phone notification panel.'
                    .localized(context),
          ),
        ],
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildConfigureLock(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              title: 'System Lock'.localized(context),
              subtitle: 'Use fingerprint, face, or system PIN.'.localized(
                context,
              ),
              trailing: privacyLockType == 'system'
                  ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                  : const SizedBox.shrink(),
              onTap: () => onPrivacyLockTypeChanged('system'),
            ),
            SettingsRow(
              p: p,
              title: 'In-App PIN'.localized(context),
              subtitle: 'Configure a dedicated 4-digit passcode.'.localized(
                context,
              ),
              trailing: privacyLockType == 'custom_pin'
                  ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                  : const SizedBox.shrink(),
              onTap: () => onPrivacyLockTypeChanged('custom_pin'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select how you want to unlock NoteKar. System Lock integrates natively with Android biometric credentials, while In-App PIN utilizes a custom passcode secure to this application.'
                    .localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 13,
                  height: 1.45,
                  letterSpacing: -0.05,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '1.',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'System Lock integrates directly with your Android keyguard system, providing hardware-level biometric or PIN protection.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '2.',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'In-App PIN is cryptographically secured locally using SHA-256 and has built-in brute-force protection to prevent unauthorized access.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SettingsBetaNote(
          p: p,
          text: 'The current features on this page are under Beta stage.'
              .localized(context),
          onLearnMore: onLearnMoreBeta,
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
