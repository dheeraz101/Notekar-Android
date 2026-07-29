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
  });

  final Palette p;
  final void Function(String category, {required String parent}) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
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
