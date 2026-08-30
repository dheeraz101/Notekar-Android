import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class AdvancedSettingsPage extends StatelessWidget {
  const AdvancedSettingsPage({
    super.key,
    required this.p,
    required this.subCategory,
    this.currentLocale = 'system',
    this.onLocaleChanged,
    this.onLearnMoreBeta,
    required this.hapticStyle,
    required this.reduceMotion,
    required this.largeText,
    required this.highContrast,
    required this.healthStatus,
    required this.onHapticStyleChanged,
    required this.onReduceMotionChanged,
    required this.onLargeTextChanged,
    required this.onHighContrastChanged,
    required this.onResetSettings,
    required this.onResetAllData,
    required this.onFactoryReset,
    required this.onOpenCategory,
  });

  final Palette p;
  final String subCategory; // 'Advanced', 'Language', 'Accessibility', 'Reset'
  final String currentLocale;
  final ValueChanged<String>? onLocaleChanged;
  final VoidCallback? onLearnMoreBeta;
  final String hapticStyle;
  final bool reduceMotion;
  final bool largeText;
  final bool highContrast;
  final String healthStatus;

  final ValueChanged<String> onHapticStyleChanged;
  final ValueChanged<bool> onReduceMotionChanged;
  final ValueChanged<bool> onLargeTextChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final VoidCallback onResetSettings;
  final VoidCallback onResetAllData;
  final VoidCallback onFactoryReset;
  final void Function(String category, {required String parent}) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    if (subCategory == 'Advanced') {
      return _buildAdvanced(context);
    } else if (subCategory == 'Language') {
      return _buildLanguage(context);
    } else if (subCategory == 'Accessibility') {
      return _buildAccessibility(context);
    } else if (subCategory == 'Reset') {
      return _buildReset(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildAdvanced(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.translate_rounded,
              title: 'Language'.localized(context),
              status: switch (currentLocale) {
                'en' => 'English',
                'fr' => 'Français',
                'hi' => 'हिन्दी',
                'es' => 'Español',
                'de' => 'Deutsch',
                'ja' => '日本語',
                'ru' => 'Русский',
                _ => 'System Default',
              }.localized(context),
              color: p.accent,
              onTap: () => onOpenCategory('Language', parent: 'Advanced'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.accessibility_new_rounded,
              title: 'Accessibility'.localized(context),
              status: hapticStyle.isEmpty
                  ? ''
                  : hapticStyle[0].toUpperCase() + hapticStyle.substring(1),
              color: p.orange,
              onTap: () => onOpenCategory('Accessibility', parent: 'Advanced'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.link,
              title: 'Bridges & Automation'.localized(context),
              status: 'Bridges'.localized(context),
              color: p.accent,
              onTap: () => onOpenCategory(
                'Integrations & Automation',
                parent: 'Advanced',
              ),
            ),
            SettingsRow(
              p: p,
              icon: Icons.developer_mode_rounded,
              title: 'Developer Options'.localized(context),
              status: 'Tools'.localized(context),
              color: p.accent,
              onTap: () =>
                  onOpenCategory('Developer Options', parent: 'Advanced'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.restart_alt_rounded,
              title: 'Reset'.localized(context),
              status: 'Wipe'.localized(context),
              color: p.red,
              onTap: () => onOpenCategory('Reset', parent: 'Advanced'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'These tools are intended for system maintenance and troubleshooting.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildLanguage(BuildContext context) {
    final availableLanguages = [
      (
        code: 'system',
        name: 'System Default',
        native: 'System Default',
        subtitle: 'Follow device system language',
      ),
      (
        code: 'en',
        name: 'English',
        native: 'English',
        subtitle: 'Core built-in language',
      ),
      (
        code: 'fr',
        name: 'French',
        native: '🇫🇷  Français',
        subtitle: 'French localization (100% offline)',
      ),
      (
        code: 'hi',
        name: 'Hindi',
        native: '🇮🇳  हिन्दी',
        subtitle: 'Hindi localization (100% offline)',
      ),
      (
        code: 'es',
        name: 'Spanish',
        native: '🇪🇸  Español',
        subtitle: 'Spanish localization (100% offline)',
      ),
      (
        code: 'de',
        name: 'German',
        native: '🇩🇪  Deutsch',
        subtitle: 'German localization (100% offline)',
      ),
      (
        code: 'ja',
        name: 'Japanese',
        native: '🇯🇵  日本語',
        subtitle: 'Japanese localization (100% offline)',
      ),
      (
        code: 'ru',
        name: 'Russian',
        native: '🇷🇺  Русский',
        subtitle: 'Russian localization (100% offline)',
      ),
    ];

    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          title: 'Available Languages'.localized(context).toUpperCase(),
          children: [
            for (final lang in availableLanguages)
              SettingsRow(
                p: p,
                title: lang.native.localized(context),
                subtitle: lang.subtitle.localized(context),
                trailing: currentLocale == lang.code
                    ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                    : const SizedBox.shrink(),
                onTap: () {
                  if (currentLocale == lang.code) return;
                  HapticFeedback.selectionClick();
                  onLocaleChanged?.call(lang.code);
                },
              ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'All 7 supported languages are 100% built into NoteKar, requiring zero network downloads or data usage.'
                  .localized(context),
        ),
        const SizedBox(height: spacing12),
        SettingsGroup(
          p: p,
          title: 'Upcoming Languages'.localized(context).toUpperCase(),
          description:
              'These languages are planned for future releases. Help translate NoteKar on GitHub.'
                  .localized(context),
          children: [
            for (final lang in kUpcomingLanguages)
              SettingsRow(
                p: p,
                title: lang.native,
                trailing: UpcomingBadge(p: p),
                onTap: () =>
                    showUpcomingLanguageNotice(context, p, lang.native),
              ),
          ],
        ),
        if (onLearnMoreBeta != null)
          SettingsBetaNote(
            p: p,
            text: 'The current features on this page are under Beta stage.'
                .localized(context),
            onLearnMore: onLearnMoreBeta!,
          ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildAccessibility(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          title: 'Haptic Style',
          children: [
            for (final style in ['off', 'light', 'standard'])
              SettingsRow(
                p: p,
                title: style[0].toUpperCase() + style.substring(1),
                trailing: hapticStyle == style
                    ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                    : const SizedBox.shrink(),
                onTap: () {
                  if (hapticStyle == style) return;
                  HapticFeedback.selectionClick();
                  onHapticStyleChanged(style);
                },
              ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Configure the intensity of vibration feedback during taps and saves.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Reduced Motion',
              color: p.green,
              value: reduceMotion,
              onChanged: onReduceMotionChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Disables fluid physics and parallax effects to improve performance and stability.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Large Text',
              color: p.accent,
              value: largeText,
              onChanged: onLargeTextChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Increases type scale across moment rows and sheet dialogs for enhanced readability.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'High Contrast Mode',
              color: p.orange,
              value: highContrast,
              onChanged: onHighContrastChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Enhances borders and text contrast to ensure maximum visibility under bright lighting conditions.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildReset(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.restore_rounded,
              title: 'Reset Settings'.localized(context),
              subtitle:
                  'Restores default themes, haptics, and notification preferences without deleting saved moments.'
                      .localized(context),
              color: p.orange,
              onTap: onResetSettings,
            ),
          ],
        ),
        const SizedBox(height: spacing12),

        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.delete_forever_rounded,
              title: 'Reset All Data'.localized(context),
              subtitle:
                  'Permanently removes all saved moments and session histories from local storage.'
                      .localized(context),
              color: p.red,
              onTap: onResetAllData,
            ),
          ],
        ),
        const SizedBox(height: spacing12),

        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.phonelink_erase_rounded,
              title: 'Factory Reset'.localized(context),
              subtitle:
                  'Completely wipes all moments, preferences, and hardware keys back to fresh install state.'
                      .localized(context),
              color: p.red,
              onTap: onFactoryReset,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Data wipe operations are permanent and cannot be undone unless you have exported a JSON backup.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
