import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class CaptureSettingsPage extends StatelessWidget {
  const CaptureSettingsPage({
    super.key,
    required this.p,
    required this.defaultMode,
    required this.tapDelay,
    required this.enableNoteOnClick,
    required this.onDefaultModeChanged,
    required this.onTapDelayChanged,
    required this.onEnableNoteOnClickChanged,
  });

  final Palette p;
  final String defaultMode;
  final int tapDelay;
  final bool enableNoteOnClick;

  final ValueChanged<String> onDefaultModeChanged;
  final ValueChanged<int> onTapDelayChanged;
  final ValueChanged<bool> onEnableNoteOnClickChanged;

  @override
  Widget build(BuildContext context) {
    final delayIndex = delayValues.indexOf(tapDelay);

    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          title: 'Startup Mode',
          children: [
            SettingsRow(
              p: p,
              title: 'Single'.localized(context),
              subtitle: 'Every tap records a standalone moment.'.localized(
                context,
              ),
              trailing: defaultMode == 'single'
                  ? Icon(CupertinoIcons.checkmark, color: p.accent, size: 18)
                  : const SizedBox.shrink(),
              onTap: () {
                if (defaultMode == 'single') return;
                onDefaultModeChanged('single');
              },
            ),
            SettingsRow(
              p: p,
              title: 'Two-Way'.localized(context),
              subtitle: 'Sessions are recorded as IN and OUT pairs.'.localized(
                context,
              ),
              trailing: defaultMode == 'two-way'
                  ? Icon(CupertinoIcons.checkmark, color: p.accent, size: 18)
                  : const SizedBox.shrink(),
              onTap: () {
                if (defaultMode == 'two-way') return;
                onDefaultModeChanged('two-way');
              },
            ),
            SettingsRow(
              p: p,
              title: 'Last Used'.localized(context),
              subtitle:
                  'Resumes whichever mode was active when you last used the app.'
                      .localized(context),
              trailing: defaultMode == 'last-used'
                  ? Icon(CupertinoIcons.checkmark, color: p.accent, size: 18)
                  : const SizedBox.shrink(),
              onTap: () {
                if (defaultMode == 'last-used') return;
                onDefaultModeChanged('last-used');
              },
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Defines the primary logging mode active when the app launches. Select Last Used to remember and restore your previous workflow.'
                  .localized(context),
        ),

        Glass(
          p: p,
          radius: 32,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tap Delay'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    delayLabel(tapDelay).localized(context),
                    style: TextStyle(color: p.text2, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  DelayStepButton(
                    p: p,
                    icon: CupertinoIcons.minus,
                    enabled: (delayIndex < 0 ? 0 : delayIndex) > 0,
                    onTap: () {
                      final current = delayIndex < 0 ? 0 : delayIndex;
                      final next = delayValues[math.max(0, current - 1)];
                      NotekarHaptics.selection('standard');
                      onTapDelayChanged(next);
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: p.accent,
                            inactiveTrackColor: p.surface3,
                            thumbColor: Colors.white,
                            overlayColor: p.accent.withValues(alpha: 0.12),
                            trackHeight: 5,
                            tickMarkShape: SliderTickMarkShape.noTickMark,
                          ),
                          child: Slider(
                            min: 0,
                            max: 6,
                            divisions: 6,
                            value: (delayIndex < 0 ? 0 : delayIndex).toDouble(),
                            onChanged: (value) {
                              final next = delayValues[value.round()];
                              if (next == tapDelay) return;
                              NotekarHaptics.selection('standard');
                              onTapDelayChanged(next);
                            },
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -4),
                          child: SliderScale(p: p, activeValue: tapDelay),
                        ),
                      ],
                    ),
                  ),
                  DelayStepButton(
                    p: p,
                    icon: CupertinoIcons.plus,
                    enabled:
                        (delayIndex < 0 ? 0 : delayIndex) <
                        delayValues.length - 1,
                    onTap: () {
                      final current = delayIndex < 0 ? 0 : delayIndex;
                      final next =
                          delayValues[math.min(
                            delayValues.length - 1,
                            current + 1,
                          )];
                      NotekarHaptics.selection('standard');
                      onTapDelayChanged(next);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Tap Delay prevents accidental rapid-fire logging by setting a cooldown between captured moments.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Note on Click',
              subtitle:
                  'Tap to compose a note before logging. When disabled, tapping logs instantly and holding prompts for a note.',
              color: p.accent,
              value: enableNoteOnClick,
              onChanged: onEnableNoteOnClickChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'When enabled, tap opens the note composer for both single moments and two-way sessions.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
