import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class PrivacySecuritySettingsPage extends StatelessWidget {
  const PrivacySecuritySettingsPage({
    super.key,
    required this.p,
    required this.vtRatio,
    required this.vtStatus,
    required this.vtScanDate,
    required this.vtUrl,
    required this.privacyLock,
    required this.obfuscateInRecents,
    required this.onObfuscateInRecentsChanged,
    required this.onOpenCategory,
    required this.onLearnMoreBeta,
  });

  final Palette p;
  final String vtRatio;
  final String vtStatus;
  final String vtScanDate;
  final String vtUrl;
  final bool privacyLock;
  final bool obfuscateInRecents;
  final ValueChanged<bool> onObfuscateInRecentsChanged;
  final void Function(String category, {required String parent}) onOpenCategory;
  final VoidCallback onLearnMoreBeta;

  static const _fileChannel = MethodChannel('notekar/files');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.checkmark_shield_fill,
              title: 'Safety Verified',
              subtitle: 'Verified clean of malicious activity',
              color: p.green,
              status: vtStatus,
              onTap: () async {
                try {
                  await _fileChannel.invokeMethod<void>('openUrl', {
                    'url': vtUrl,
                  });
                } catch (_) {}
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await _fileChannel.invokeMethod<void>('openUrl', {
                        'url': vtUrl,
                      });
                    } catch (_) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.green.withValues(alpha: 0.15),
                    foregroundColor: p.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.security_rounded, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'VT Report'.localized(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await _fileChannel.invokeMethod<void>('openUrl', {
                        'url':
                            'https://github.com/dheeraz101/Notekar-Android/releases/latest',
                      });
                    } catch (_) {}
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.text2,
                    side: BorderSide(color: p.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fingerprint_rounded, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'SHA-256 Hashes'.localized(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          p: p,
          title: 'Data & Privacy',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.analytics_outlined,
              title: 'No Analytics',
              color: p.green,
              status: 'None',
            ),
            SettingsRow(
              p: p,
              icon: Icons.wifi_off_rounded,
              title: 'Network Use',
              color: p.accent,
              status: 'Limited',
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'NoteKar contains zero third-party telemetry. Network access is restricted strictly to update checks and announcement fetching.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.lock_outlined,
              title: 'App Lock',
              color: p.orange,
              status: privacyLock ? 'On' : 'Off',
              onTap: () =>
                  onOpenCategory('App Lock', parent: 'Privacy & Security'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Protect your saved history using device biometric authentication or system PIN.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              icon: Icons.screenshot_rounded,
              title: 'Hide App Content',
              subtitle:
                  'Obfuscate application screens and block screenshots in the system recents switcher.',
              value: obfuscateInRecents,
              color: p.green,
              onChanged: onObfuscateInRecentsChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Requires user consent. When enabled, your sensitive moments and notes cannot be viewed from the app switcher.'
                  .localized(context),
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
