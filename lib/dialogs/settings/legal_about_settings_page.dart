import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class LegalAboutSettingsPage extends StatelessWidget {
  const LegalAboutSettingsPage({
    super.key,
    required this.p,
    required this.subCategory, // 'Privacy Policy', 'Terms of Use', 'Licenses'
    required this.appVersion,
    required this.privacyPolicyUrl,
    required this.termsUrl,
    required this.onOpenLink,
  });

  final Palette p;
  final String subCategory;
  final String appVersion;
  final String privacyPolicyUrl;
  final String termsUrl;
  final ValueChanged<String> onOpenLink;

  @override
  Widget build(BuildContext context) {
    if (subCategory == 'Privacy Policy') {
      return _buildPrivacyPolicy(context);
    } else if (subCategory == 'Terms of Use') {
      return _buildTermsOfUse(context);
    } else if (subCategory == 'Licenses') {
      return _buildLicenses(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPrivacyPolicy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        Text(
          'Your Privacy Matters'.localized(context),
          style: TextStyle(
            color: p.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: spacing12),
        Text(
          'NoteKar is designed with an "Offline-First" philosophy. We believe your personal moments and notes belong to you and only you.'
              .localized(context),
          style: TextStyle(color: p.text2, fontSize: 15, height: 1.45),
        ),
        const SizedBox(height: spacing24),
        SettingsGroup(
          p: p,
          children: [
            _PolicySection(
              p: p,
              icon: Icons.storage_rounded,
              title: 'Local Storage'.localized(context),
              text:
                  'All moments and notes are stored locally on your device using an encrypted-ready database (Hive). No data is ever uploaded to a cloud server unless you manually export a backup file.'
                      .localized(context),
            ),
            _PolicySection(
              p: p,
              icon: Icons.analytics_outlined,
              title: 'No Tracking'.localized(context),
              text:
                  'We do not use any third-party analytics, tracking pixels, or advertising SDKs. Your app usage remains completely anonymous and private.'
                      .localized(context),
            ),
            _PolicySection(
              p: p,
              icon: Icons.wifi_rounded,
              title: 'Limited Connectivity'.localized(context),
              text:
                  'The app only uses the internet to check for software updates on GitHub and to fetch occasional app notices if enabled. No personal data is transmitted during these checks.'
                      .localized(context),
            ),
          ],
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => onOpenLink(privacyPolicyUrl),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text(
            'Full Online Policy'.localized(context),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: p.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: spacing32),
      ],
    );
  }

  Widget _buildTermsOfUse(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        Text(
          'Terms of Use'.localized(context),
          style: TextStyle(
            color: p.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: spacing12),
        Text(
          'By using NoteKar, you agree to our terms of service and how we handle open source licenses.'
              .localized(context),
          style: TextStyle(color: p.text2, fontSize: 15, height: 1.45),
        ),
        const SizedBox(height: spacing24),
        SettingsGroup(
          p: p,
          children: [
            _PolicySection(
              p: p,
              icon: Icons.gavel_rounded,
              title: 'App Usage'.localized(context),
              text:
                  'NoteKar is provided "as is" for personal use. You are responsible for your own data backups and for ensuring your use of the app complies with local laws.'
                      .localized(context),
            ),
            _PolicySection(
              p: p,
              icon: Icons.code_rounded,
              title: 'Open Source'.localized(context),
              text:
                  'NoteKar is open source software. Individual components and libraries are subject to their respective licenses, which can be viewed in the Licenses section.'
                      .localized(context),
            ),
          ],
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => onOpenLink(termsUrl),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text(
            'Full Online Terms'.localized(context),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: p.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: spacing32),
      ],
    );
  }

  Widget _buildLicenses(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'icon-maskable-512.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NoteKar',
                style: TextStyle(
                  color: p.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Version v$appVersion',
                style: TextStyle(color: p.text3, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing32),
        SettingsGroup(
          p: p,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Software Licenses'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NoteKar is built using Flutter and several high-quality open source packages. You can view the full legal notices and individual package licenses below.'
                        .localized(context),
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => showLicensePage(
            context: context,
            applicationName: 'NoteKar',
            applicationVersion: 'v$appVersion',
            applicationIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'icon-maskable-512.png',
                  width: 64,
                  height: 64,
                ),
              ),
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: p.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text(
            'View Full Licenses'.localized(context),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: spacing32),
      ],
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.p,
    required this.icon,
    required this.title,
    required this.text,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: p.accent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
