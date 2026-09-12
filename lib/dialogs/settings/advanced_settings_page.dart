import 'package:flutter/cupertino.dart';
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
              title: 'Automation'.localized(context),
              status: 'Automation'.localized(context),
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
        subtitle: 'Follows device system language',
      ),
      (
        code: 'en',
        name: 'English',
        native: 'English',
        subtitle: 'How are you?',
      ),
      (
        code: 'fr',
        name: 'French',
        native: 'Français',
        subtitle: 'Comment allez-vous ?',
      ),
      (code: 'hi', name: 'Hindi', native: 'हिन्दी', subtitle: 'आप कैसे हैं?'),
      (
        code: 'es',
        name: 'Spanish',
        native: 'Español',
        subtitle: '¿Cómo estás?',
      ),
      (
        code: 'de',
        name: 'German',
        native: 'Deutsch',
        subtitle: 'Wie geht es dir?',
      ),
      (code: 'ja', name: 'Japanese', native: '日本語', subtitle: 'お元気ですか？'),
      (
        code: 'ru',
        name: 'Russian',
        native: 'Русский',
        subtitle: 'Как ваши дела?',
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
                title: lang.native,
                subtitle: lang.subtitle,
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
              'NoteKar includes native offline localization across all supported languages with zero data usage.'
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
          SettingsBetaNote(p: p, onLearnMore: onLearnMoreBeta!),
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
              onChanged: (val) {
                final systemScale = MediaQuery.of(context).textScaler.scale(1);
                if (val && systemScale >= 1.15) {
                  showCupertinoDialog<void>(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: Text('System Text Size Active'.localized(ctx)),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Your device already has larger text enabled in system settings. Enabling additional in-app enlargement may alter layout proportions.'
                              .localized(ctx),
                        ),
                      ),
                      actions: [
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Keep System Default'.localized(ctx)),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: false,
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onLargeTextChanged(true);
                          },
                          child: Text('Enable Anyway'.localized(ctx)),
                        ),
                      ],
                    ),
                  );
                } else {
                  onLargeTextChanged(val);
                }
              },
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
              subtitle: 'Restore default preferences and layout'.localized(
                context,
              ),
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
              subtitle: 'Delete all recorded moments and sessions'.localized(
                context,
              ),
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
              subtitle: 'Erase all data and restore factory settings'.localized(
                context,
              ),
              color: p.red,
              onTap: onFactoryReset,
            ),
          ],
        ),
        const SizedBox(height: spacing4),
        SettingsPageDescription(
          p: p,
          showIcon: true,
          icon: Icons.warning_amber_rounded,
          iconColor: p.red,
          text:
              'Data wipe operations permanently erase local storage and cannot be undone. Export a backup beforehand from Data & Backup.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
