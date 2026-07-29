import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({
    super.key,
    required this.p,
    required this.theme,
    required this.showSeconds,
    required this.highlightSeconds,
    required this.buttonLabels,
    required this.showHistoryText,
    required this.largeControls,
    required this.homeMenuPill,
    required this.reduceMotion,
    required this.homeMenuAnimations,
    required this.enableTranslucency,
    required this.showLastSavedHint,
    required this.onThemeChanged,
    required this.onShowSecondsChanged,
    required this.onHighlightSecondsChanged,
    required this.onFeedback,
    required this.onButtonLabelsChanged,
    required this.onShowHistoryTextChanged,
    required this.onLargeControlsChanged,
    required this.onHomeMenuPillChanged,
    required this.onHomeMenuAnimations,
    required this.onHomeMenuAnimationsChanged,
    required this.onTranslucencyChanged,
    required this.onShowLastSavedHintChanged,
  });

  final Palette p;
  final String theme;
  final bool showSeconds;
  final bool highlightSeconds;
  final bool buttonLabels;
  final bool showHistoryText;
  final bool largeControls;
  final bool homeMenuPill;
  final bool reduceMotion;
  final bool homeMenuAnimations;
  final bool enableTranslucency;
  final bool showLastSavedHint;

  final ValueChanged<String> onThemeChanged;
  final ValueChanged<bool> onShowSecondsChanged;
  final ValueChanged<bool> onHighlightSecondsChanged;
  final ValueChanged<String> onFeedback;
  final ValueChanged<bool> onButtonLabelsChanged;
  final ValueChanged<bool> onShowHistoryTextChanged;
  final ValueChanged<bool> onLargeControlsChanged;
  final ValueChanged<bool> onHomeMenuPillChanged;
  final Future<bool> Function(bool) onHomeMenuAnimations;
  final ValueChanged<bool> onHomeMenuAnimationsChanged;
  final ValueChanged<bool> onTranslucencyChanged;
  final ValueChanged<bool> onShowLastSavedHintChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          title: 'Theme',
          showDividers: false,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ThemeChoice(
                      p: p,
                      label: 'Dark',
                      active: theme == 'dark',
                      color: const Color(0xFF1C1C1E),
                      onTap: () {
                        if (theme == 'dark') return;
                        HapticFeedback.selectionClick();
                        onThemeChanged('dark');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThemeChoice(
                      p: p,
                      label: 'Light',
                      active: theme == 'light',
                      color: const Color(0xFFF2F2F7),
                      onTap: () {
                        if (theme == 'light') return;
                        HapticFeedback.selectionClick();
                        onThemeChanged('light');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThemeChoice(
                      p: p,
                      label: 'AMOLED',
                      active: theme == 'amoled',
                      color: const Color(0xFF000000),
                      onTap: () {
                        if (theme == 'amoled') return;
                        HapticFeedback.selectionClick();
                        onThemeChanged('amoled');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'Select a theme that best suits your environment.'.localized(
            context,
          ),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Show Seconds',
              color: p.accent,
              value: showSeconds,
              onChanged: onShowSecondsChanged,
            ),
            SettingsSwitchRow(
              p: p,
              title: 'Highlight Seconds',
              color: p.accent,
              value: showSeconds && highlightSeconds,
              enabled: showSeconds,
              disabledMessage: 'Enable Show Seconds first'.localized(context),
              onDisabledTap: onFeedback,
              onChanged: (value) {
                if (!showSeconds) return;
                onHighlightSecondsChanged(value);
              },
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'Configure the home screen clock and visual feedback.'
              .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Button Labels',
              color: p.green,
              value: buttonLabels,
              onChanged: onButtonLabelsChanged,
            ),
            SettingsSwitchRow(
              p: p,
              title: 'History Text',
              color: p.green,
              value: showHistoryText,
              onChanged: onShowHistoryTextChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Show descriptive text labels on the primary navigation and action buttons.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Large Controls',
              color: p.orange,
              value: largeControls,
              onChanged: onLargeControlsChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'Increases the size of interactive elements for easier tapping.'
              .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Toolbar Backplate',
              color: p.accent,
              value: homeMenuPill,
              onChanged: onHomeMenuPillChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'Adds a subtle glass-like container behind the home toolbar.'
              .localized(context),
        ),

        if (AdaptiveEngine().supportsAdvancedAnimations) ...[
          SettingsGroup(
            p: p,
            children: [
              SettingsSwitchRow(
                p: p,
                title: 'Live Icon Motion',
                color: p.accent,
                value: !reduceMotion && homeMenuAnimations,
                enabled: !reduceMotion,
                disabledMessage: 'Disable Reduce Motion first'.localized(
                  context,
                ),
                onDisabledTap: onFeedback,
                onChanged: (value) async {
                  if (reduceMotion) return;
                  final applied = await onHomeMenuAnimations(value);
                  onHomeMenuAnimationsChanged(applied ? value : false);
                },
              ),
            ],
          ),
          SettingsPageDescription(
            p: p,
            text:
                'Enables fluid physics for toolbar icons. Automatically scales based on CPU and RAM performance.'
                    .localized(context),
          ),
        ],
        if (AdaptiveEngine().supportsBlur) ...[
          SettingsGroup(
            p: p,
            children: [
              SettingsSwitchRow(
                p: p,
                title: 'Enable Translucency',
                color: p.accent,
                value: !reduceMotion && enableTranslucency,
                enabled: !reduceMotion,
                onDisabledTap: onFeedback,
                onChanged: onTranslucencyChanged,
              ),
            ],
          ),
          SettingsPageDescription(
            p: p,
            text:
                'Applies real-time Gaussian blur to system surfaces. Requires a high-performance GPU tier.'
                    .localized(context),
          ),
        ],
        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Last Saved Hint',
              color: p.accent,
              value: showLastSavedHint,
              onChanged: onShowLastSavedHintChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Provides visual feedback for the time elapsed since your last moment.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
