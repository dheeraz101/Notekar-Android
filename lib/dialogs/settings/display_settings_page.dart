import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/settings_controller.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({
    super.key,
    required this.p,
    required this.controller,
    required this.onFeedback,
  });

  final Palette p;
  final SettingsController controller;
  final ValueChanged<String> onFeedback;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = controller.reduceMotion;
    final enableTranslucency = controller.enableTranslucency;
    final homeMenuAnimations = controller.homeMenuAnimations;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          children: [
            const SizedBox(height: 8),
            SettingsGroup(
              p: p,
              children: [
                SettingsRow(
                  p: p,
                  icon: Icons.language_rounded,
                  title: 'App Language',
                  status: switch (controller.locale) {
                    'en' => 'English',
                    'hi' => 'Hindi',
                    'es' => 'Spanish',
                    _ => 'System Default',
                  },
                  color: p.accent,
                  onTap: () {
                    final nextLocale = switch (controller.locale) {
                      'system' => 'en',
                      'en' => 'hi',
                      'hi' => 'es',
                      _ => 'system',
                    };
                    controller.setLocale(nextLocale);
                  },
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text:
                  'Set your preferred application language or follow system default.',
            ),
            SettingsGroup(
              p: p,
              children: [
                SettingsSwitchRow(
                  p: p,
                  title: 'Show Seconds',
                  color: p.accent,
                  value: controller.showSeconds,
                  onChanged: (val) => controller.setShowSeconds(val),
                ),
                SettingsSwitchRow(
                  p: p,
                  title: 'Highlight Seconds',
                  color: p.accent,
                  value: controller.showSeconds && controller.highlightSeconds,
                  enabled: controller.showSeconds,
                  disabledMessage: 'Enable Show Seconds first',
                  onDisabledTap: onFeedback,
                  onChanged: (val) {
                    if (!controller.showSeconds) return;
                    controller.setHighlightSeconds(val);
                  },
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text: 'Configure the home screen clock and visual feedback.',
            ),
            SettingsGroup(
              p: p,
              children: [
                SettingsSwitchRow(
                  p: p,
                  title: 'Button Labels',
                  color: p.accent,
                  value: controller.buttonLabels,
                  onChanged: (val) => controller.setButtonLabels(val),
                ),
                SettingsSwitchRow(
                  p: p,
                  title: 'History Text',
                  color: p.green,
                  value: controller.showHistoryText,
                  onChanged: (val) => controller.setShowHistoryText(val),
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text:
                  'Show descriptive text labels on primary navigation buttons.',
            ),
            SettingsGroup(
              p: p,
              children: [
                SettingsSwitchRow(
                  p: p,
                  title: 'Large Controls',
                  color: p.orange,
                  value: controller.largeControls,
                  onChanged: (val) => controller.setLargeControls(val),
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text:
                  'Increases the size of interactive elements for easier tapping.',
            ),
            SettingsGroup(
              p: p,
              children: [
                SettingsSwitchRow(
                  p: p,
                  title: 'Toolbar Backplate',
                  color: p.accent,
                  value: controller.homeMenuPill,
                  onChanged: (val) => controller.setHomeMenuPill(val),
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text: 'Adds a subtle glass container behind the home toolbar.',
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
                    disabledMessage: 'Disable Reduce Motion first',
                    onDisabledTap: onFeedback,
                    onChanged: (val) {
                      if (reduceMotion) return;
                      controller.setHomeMenuAnimations(val);
                    },
                  ),
                ],
              ),
              SettingsPageDescription(
                p: p,
                text: 'Enables fluid physics for toolbar icons.',
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
                    onChanged: (val) => controller.setEnableTranslucency(val),
                  ),
                ],
              ),
              SettingsPageDescription(
                p: p,
                text: 'Applies real-time Gaussian blur to system surfaces.',
              ),
            ],
            SettingsGroup(
              p: p,
              children: [
                SettingsSwitchRow(
                  p: p,
                  title: 'Last Saved Hint',
                  color: p.accent,
                  value: controller.showLastSavedHint,
                  onChanged: (val) => controller.setShowLastSavedHint(val),
                ),
              ],
            ),
            SettingsPageDescription(
              p: p,
              text:
                  'Provides visual feedback for the time elapsed since your last moment.',
            ),
            const SizedBox(height: 48),
          ],
        );
      },
    );
  }
}
