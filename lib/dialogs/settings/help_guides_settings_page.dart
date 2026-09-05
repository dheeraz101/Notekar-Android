import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class HelpGuidesSettingsPage extends StatelessWidget {
  const HelpGuidesSettingsPage({
    super.key,
    required this.p,
    required this.onOpenCategory,
    this.onOpenTour,
  });

  final Palette p;
  final void Function(String category, {required String parent}) onOpenCategory;
  final void Function(List<String> pages)? onOpenTour;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          title: 'Interactive Feature Tours'.localized(context),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.auto_stories_rounded,
              title: 'Life Ledger Timeline Tour'.localized(context),
              subtitle:
                  'Redesigned History, session pairing, live end & calendar'
                      .localized(context),
              color: p.accent,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: p.text3,
                size: 20,
              ),
              onTap: () => onOpenTour?.call(['history-redesign']),
            ),
            SettingsRow(
              p: p,
              icon: Icons.insights_rounded,
              title: 'Executive Intelligence Hub Tour'.localized(context),
              subtitle: 'Redesigned Dashboard, daily rhythm & activity grid'
                  .localized(context),
              color: p.orange,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: p.text3,
                size: 20,
              ),
              onTap: () => onOpenTour?.call(['dashboard-redesign']),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Step-by-step interactive walkthroughs highlighting deep features and Apple Human Interface Guidelines styling.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          title: 'Documentation',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.auto_stories_rounded,
              title: 'Guides'.localized(context),
              color: p.accent,
              status: 'Tutorials'.localized(context),
              onTap: () => onOpenCategory('Guides', parent: 'Help & Guides'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.help_outline_rounded,
              title: 'Help'.localized(context),
              color: p.orange,
              status: 'FAQ'.localized(context),
              onTap: () => onOpenCategory('Help', parent: 'Help & Guides'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Explore interactive tutorials for tap logging, duration calculations, and troubleshooting.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          title: 'Legal & Compliance',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.description_outlined,
              title: 'Licenses'.localized(context),
              color: p.accent,
              status: 'Open Source'.localized(context),
              onTap: () => onOpenCategory('Licenses', parent: 'Help & Guides'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.article_outlined,
              title: 'Terms of Use'.localized(context),
              color: p.orange,
              status: 'MIT'.localized(context),
              onTap: () =>
                  onOpenCategory('Terms of Use', parent: 'Help & Guides'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.security_rounded,
              title: 'Privacy Policy'.localized(context),
              color: p.green,
              status: 'Offline-First'.localized(context),
              onTap: () =>
                  onOpenCategory('Privacy Policy', parent: 'Help & Guides'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Review open-source licenses, app usage terms, and offline-first privacy policies.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
