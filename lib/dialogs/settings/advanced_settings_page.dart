import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class AdvancedSettingsPage extends StatelessWidget {
  const AdvancedSettingsPage({
    super.key,
    required this.p,
    required this.subCategory,
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
  final String subCategory; // 'Advanced', 'Accessibility', 'Reset'
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
              title: 'Larger Text',
              color: p.orange,
              value: largeText,
              onChanged: onLargeTextChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Increases the global font scale for improved legibility across all interfaces.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'High Contrast',
              color: p.green,
              value: highContrast,
              onChanged: onHighContrastChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Enhances visibility by using pure black backgrounds and high-intensity accent colors.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildReset(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.restore_rounded,
              title: 'Reset Settings Only'.localized(context),
              color: p.orange,
              rowKind: 'popup',
              onTap: onResetSettings,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Restores all settings options to their factory defaults. Your saved moments and notes are kept intact.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.delete_forever_rounded,
              title: 'Reset All Data'.localized(context),
              color: p.red,
              rowKind: 'popup',
              onTap: onResetAllData,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Permanently deletes all saved timestamps and notes from this device. Preferences remain unchanged.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.restart_alt_rounded,
              title: 'Factory Reset'.localized(context),
              color: p.red,
              rowKind: 'popup',
              onTap: onFactoryReset,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Completely clears all saved data and resets all settings to original fresh state.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
