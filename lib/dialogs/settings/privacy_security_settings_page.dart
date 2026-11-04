import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class DataSafetySettingsPage extends StatelessWidget {
  const DataSafetySettingsPage({
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
    this.onLearnMoreBeta,
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
  final VoidCallback? onLearnMoreBeta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),

        // 1. Google Play Data Safety Breakdown Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.surface2.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: p.border.withValues(
                alpha: p.name == 'amoled' ? 0.5 : (!p.isDark ? 0.35 : 0.45),
              ),
              width: 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: p.green.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: p.green.withValues(alpha: 0.28),
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.checkmark_shield_fill,
                        color: p.green,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DATA SAFETY SOVEREIGNTY'.localized(context),
                          style: TextStyle(
                            color: p.green,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Google Play & Store Disclosures'.localized(
                                  context,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: p.green.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: p.green.withValues(alpha: 0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '100% On-Device',
                                style: TextStyle(
                                  color: p.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: p.border.withValues(alpha: 0.35)),
              const SizedBox(height: 14),
              _buildSafetyMetricRow(
                context: context,
                title: 'Data Collected',
                value: '0 KB (None)',
                description:
                    'No personal info, identity, or financial details logged',
                isSafe: true,
              ),
              const SizedBox(height: 12),
              _buildSafetyMetricRow(
                context: context,
                title: 'Data Shared',
                value: 'None',
                description:
                    'Zero third-party trackers, advertisers, or cloud brokers',
                isSafe: true,
              ),
              const SizedBox(height: 12),
              _buildSafetyMetricRow(
                context: context,
                title: 'Security Practices',
                value: 'Local Isar Encrypted',
                description:
                    'Encrypted at rest on device with 1-tap complete data wipe',
                isSafe: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Regulatory & Hardware Compliance Links
        SettingsGroup(
          p: p,
          title: 'Standards & Permissions'.localized(context),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.square_stack_3d_up_fill,
              title: 'App Permissions'.localized(context),
              subtitle: 'Microphone, camera, notifications & timers',
              color: p.accent,
              softIcon: true,
              onTap: () =>
                  onOpenCategory('App Permissions', parent: 'Data safety'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.checkmark_shield_fill,
              title: 'Content Rating'.localized(context),
              subtitle: 'Certified clean for all ages (IARC 3+, ESRB E)',
              color: p.green,
              status: 'Everyone 3+',
              softIcon: true,
              onTap: () =>
                  onOpenCategory('Content Rating', parent: 'Data safety'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. VirusTotal & Release Hashes Verification
        SettingsGroup(
          p: p,
          title: 'Integrity Verification'.localized(context),
          children: [
            SettingsRow(
              p: p,
              title: 'Safety Verified',
              subtitle: 'Verified clean of malicious activity',
              color: p.green,
              status: vtStatus,
              onTap: () => openExternalLinkSafely(context, p: p, url: vtUrl),
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
                  onPressed: () =>
                      openExternalLinkSafely(context, p: p, url: vtUrl),
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
                      const Icon(CupertinoIcons.shield, size: 14),
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
                  onPressed: () => openExternalLinkSafely(
                    context,
                    p: p,
                    url:
                        'https://github.com/dheeraz101/Notekar-Android/releases/latest',
                  ),
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
                      const Icon(CupertinoIcons.lock, size: 14),
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

        // 4. Telemetry & Network Policies
        SettingsGroup(
          p: p,
          title: 'Data & Privacy',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.chart_bar,
              title: 'No Analytics',
              color: p.green,
              status: 'None',
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.wifi_slash,
              title: 'Network Use',
              color: p.accent,
              status: 'Limited',
              trailing: Icon(
                CupertinoIcons.chevron_forward,
                color: p.text3,
                size: 20,
              ),
              onTap: () => onOpenCategory(
                'Network Monitor',
                parent: 'Developer Options',
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'NoteKar contains zero third-party telemetry. Network access is restricted strictly to update checks and announcement fetching.'
                  .localized(context),
        ),

        // 5. Biometric Lock
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.lock,
              title: 'App Lock',
              color: p.orange,
              status: privacyLock ? 'On' : 'Off',
              onTap: () => onOpenCategory('App Lock', parent: 'Data safety'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Protect your saved history using device biometric authentication or system PIN.'
                  .localized(context),
        ),

        // 6. Recents Screen Obfuscation
        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
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
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildSafetyMetricRow({
    required BuildContext context,
    required String title,
    required String value,
    required String description,
    required bool isSafe,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 1.5),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isSafe ? p.green.withValues(alpha: 0.15) : p.surface3,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isSafe ? CupertinoIcons.checkmark_alt : CupertinoIcons.info,
              color: isSafe ? p.green : p.text3,
              size: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      title.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 4,
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: isSafe ? p.green : p.text2,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description.localized(context),
                style: TextStyle(color: p.text3, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Backwards compatibility alias for existing routes and test suites
typedef PrivacySecuritySettingsPage = DataSafetySettingsPage;
