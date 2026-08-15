import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class PersonalizationSettingsPage extends StatelessWidget {
  const PersonalizationSettingsPage({
    super.key,
    required this.p,
    required this.subCategory,
    required this.theme,
    required this.accentColor,
    required this.appIconStyle,
    required this.currentLocale,
    required this.reduceMotion,
    required this.enableTranslucency,
    required this.onLocaleChanged,
    required this.onAccentColorChanged,
    required this.onOpenCategory,
    required this.onLearnMoreBeta,
  });

  final Palette p;
  final String subCategory; // 'Personalization', 'Language', 'Accent Color'
  final String theme;
  final String accentColor;
  final String appIconStyle;
  final String currentLocale;
  final bool reduceMotion;
  final bool enableTranslucency;

  final ValueChanged<String> onLocaleChanged;
  final ValueChanged<String> onAccentColorChanged;
  final void Function(String category, {required String parent}) onOpenCategory;
  final VoidCallback onLearnMoreBeta;

  @override
  Widget build(BuildContext context) {
    if (subCategory == 'Personalization') {
      return _buildPersonalization(context);
    } else if (subCategory == 'Language') {
      return _buildLanguage(context);
    } else if (subCategory == 'Accent Color') {
      return _buildAccentColor(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPersonalization(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.dark_mode_outlined,
              title: 'Display'.localized(context),
              status: theme.isEmpty
                  ? ''
                  : theme[0].toUpperCase() + theme.substring(1),
              color: p.accent,
              onTap: () => onOpenCategory('Display', parent: 'Personalization'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.color_lens_outlined,
              title: 'Accent Color'.localized(context),
              status: accentColor.isEmpty
                  ? ''
                  : accentColor[0].toUpperCase() + accentColor.substring(1),
              color: p.accent,
              onTap: () =>
                  onOpenCategory('Accent Color', parent: 'Personalization'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.apps_rounded,
              title: 'App Icons'.localized(context),
              status: switch (appIconStyle) {
                'default' => 'Aurora',
                'black' => 'Midnight',
                'blue' => 'Sapphire',
                'gold' => 'Imperial',
                'green' => 'Emerald',
                'orange' => 'Sunset',
                'red' => 'Crimson',
                'purple' => 'Amethyst',
                _ => 'Aurora',
              }.localized(context),
              color: p.orange,
              onTap: () =>
                  onOpenCategory('App Icons', parent: 'Personalization'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.language_rounded,
              title: 'Language'.localized(context),
              status: switch (currentLocale) {
                'en' => 'English',
                'hi' => 'हिन्दी',
                'es' => 'Español',
                _ => 'System Default',
              },
              color: p.accent,
              onTap: () =>
                  onOpenCategory('Language', parent: 'Personalization'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'These settings refine the interface aesthetic and do not modify your saved data.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildLanguage(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          children: [
            for (final entry in [
              (code: 'system', name: 'System Default'),
              (code: 'en', name: 'English'),
              (code: 'hi', name: 'हिन्दी (Hindi)'),
              (code: 'es', name: 'Español (Spanish)'),
            ])
              SettingsRow(
                p: p,
                title: entry.name,
                trailing: currentLocale == entry.code
                    ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                    : const SizedBox.shrink(),
                onTap: () {
                  if (currentLocale == entry.code) return;
                  HapticFeedback.selectionClick();
                  onLocaleChanged(entry.code);
                },
              ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'Select your preferred language for the application.'.localized(
            context,
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

  Widget _buildAccentColor(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          showDividers: false,
          children: [
            ColorChoiceSetting(
              p: p,
              value: accentColor,
              blur:
                  !reduceMotion &&
                  enableTranslucency &&
                  AdaptiveEngine().supportsBlur,
              onChanged: (value) {
                if (value == accentColor) return;
                HapticFeedback.selectionClick();
                onAccentColorChanged(value);
              },
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Select an accent color for buttons and fluid interface highlights.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
