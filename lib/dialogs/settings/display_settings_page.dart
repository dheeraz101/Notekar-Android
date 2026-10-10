import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({
    super.key,
    required this.p,
    required this.theme,
    required this.showSeconds,
    required this.highlightSeconds,
    this.use24HourFormat = true,
    this.clockFont = 'BebasNeue',
    this.onClockFontChanged,
    required this.buttonLabels,
    required this.showHistoryText,
    required this.largeControls,
    required this.homeMenuPill,
    required this.reduceMotion,
    required this.homeMenuAnimations,
    required this.enableTranslucency,
    required this.showLastSavedHint,
    this.showImagesAlways = true,
    this.onShowImagesAlwaysChanged,
    required this.onThemeChanged,
    required this.onShowSecondsChanged,
    required this.onHighlightSecondsChanged,
    this.onUse24HourFormatChanged,
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
  final bool use24HourFormat;
  final String clockFont;
  final bool buttonLabels;
  final bool showHistoryText;
  final bool largeControls;
  final bool homeMenuPill;
  final bool reduceMotion;
  final bool homeMenuAnimations;
  final bool enableTranslucency;
  final bool showLastSavedHint;
  final bool showImagesAlways;
  final ValueChanged<bool>? onShowImagesAlwaysChanged;

  final ValueChanged<String> onThemeChanged;
  final ValueChanged<bool> onShowSecondsChanged;
  final ValueChanged<bool> onHighlightSecondsChanged;
  final ValueChanged<bool>? onUse24HourFormatChanged;
  final ValueChanged<String>? onClockFontChanged;
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
        _DisplayLivePreview(
          p: p,
          theme: theme,
          clockFont: clockFont,
          use24HourFormat: use24HourFormat,
          showSeconds: showSeconds,
          highlightSeconds: highlightSeconds,
        ),
        const SizedBox(height: spacing12),
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
              subtitle:
                  'Dynamically display seconds across the clock, timeline, calendar, and search notes.'
                      .localized(context),
              color: p.accent,
              value: showSeconds,
              onChanged: (val) {
                setGlobalShowSeconds(val);
                onShowSecondsChanged(val);
              },
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
          text:
              'Configure the precision of timestamps app-wide, including clock and moment logs.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          title: 'Time Format',
          showDividers: false,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        if (!use24HourFormat) return;
                        AppHaptics.select();
                        onUse24HourFormatChanged?.call(false);
                      },
                      child: Container(
                        height: 76,
                        decoration: BoxDecoration(
                          color: !use24HourFormat ? p.surface3 : p.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: !use24HourFormat
                              ? Border.all(color: p.accent, width: 1.5)
                              : Border.all(
                                  color: p.border.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '9:41 AM',
                              style: TextStyle(
                                fontFamily: clockFont,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: !use24HourFormat ? p.text : p.text2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '12-Hour (AM/PM)'.localized(context),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: !use24HourFormat ? p.text : p.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        if (use24HourFormat) return;
                        AppHaptics.select();
                        onUse24HourFormatChanged?.call(true);
                      },
                      child: Container(
                        height: 76,
                        decoration: BoxDecoration(
                          color: use24HourFormat ? p.surface3 : p.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: use24HourFormat
                              ? Border.all(color: p.accent, width: 1.5)
                              : Border.all(
                                  color: p.border.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '21:41',
                              style: TextStyle(
                                fontFamily: clockFont,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: use24HourFormat ? p.text : p.text2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '24-Hour (Standard)'.localized(context),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: use24HourFormat ? p.text : p.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Display timestamps in standard 12-hour AM/PM or international 24-hour time across the app.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          title: 'Clock Typography',
          showDividers: false,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        if (clockFont == 'BebasNeue') return;
                        AppHaptics.select();
                        onClockFontChanged?.call('BebasNeue');
                      },
                      child: Container(
                        height: 76,
                        decoration: BoxDecoration(
                          color: clockFont == 'BebasNeue'
                              ? p.surface3
                              : p.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: clockFont == 'BebasNeue'
                              ? Border.all(color: p.accent, width: 1.5)
                              : Border.all(
                                  color: p.border.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '10:42',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 26,
                                color: clockFont == 'BebasNeue'
                                    ? p.text
                                    : p.text2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Condensed Digital'.localized(context),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: clockFont == 'BebasNeue'
                                    ? p.text
                                    : p.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        if (clockFont == 'Inter') return;
                        AppHaptics.select();
                        onClockFontChanged?.call('Inter');
                      },
                      child: Container(
                        height: 76,
                        decoration: BoxDecoration(
                          color: clockFont == 'Inter' ? p.surface3 : p.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: clockFont == 'Inter'
                              ? Border.all(color: p.accent, width: 1.5)
                              : Border.all(
                                  color: p.border.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '10:42',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                                color: clockFont == 'Inter' ? p.text : p.text2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Geometric Modern'.localized(context),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: clockFont == 'Inter' ? p.text : p.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Choose between condensed display numerals or geometric modern typography for the home clock.'
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
          title: 'Timeline & Media'.localized(context),
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Show Images Always'.localized(context),
              subtitle:
                  'Keep timeline photos and receipts expanded by default. When disabled, photos appear as compact bars.'
                      .localized(context),
              color: p.accent,
              value: showImagesAlways,
              onChanged: onShowImagesAlwaysChanged ?? (_) {},
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Configure how images and media attachments appear in the history timeline.'
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

class _DisplayLivePreview extends StatelessWidget {
  const _DisplayLivePreview({
    required this.p,
    required this.theme,
    required this.clockFont,
    required this.use24HourFormat,
    required this.showSeconds,
    required this.highlightSeconds,
  });

  final Palette p;
  final String theme;
  final String clockFont;
  final bool use24HourFormat;
  final bool showSeconds;
  final bool highlightSeconds;

  @override
  Widget build(BuildContext context) {
    final timeStr = use24HourFormat ? '14:32' : '02:32';
    final secondsStr = showSeconds ? ':48' : '';
    final periodStr = use24HourFormat ? '' : ' PM';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.surface3.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.eye_fill, size: 10, color: p.text3),
                    const SizedBox(width: 4),
                    Text(
                      'Live Display Preview'.localized(context),
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${theme.toUpperCase()} • $clockFont',
                style: TextStyle(
                  color: p.text3,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: clockFont,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: p.text,
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(text: timeStr),
                if (showSeconds)
                  TextSpan(
                    text: secondsStr,
                    style: TextStyle(
                      color: highlightSeconds ? p.accent : p.text3,
                      fontSize: 26,
                    ),
                  ),
                if (!use24HourFormat)
                  TextSpan(
                    text: periodStr,
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: p.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Deep Work Focus'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Check In'.localized(context),
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
