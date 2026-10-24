import 'dart:async';

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
    this.previewModeLabel = 'Focus',
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
  final String previewModeLabel;
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
          previewModeLabel: previewModeLabel,
          largeControls: largeControls,
          buttonLabels: buttonLabels,
          enableTranslucency: enableTranslucency,
          showHistoryText: showHistoryText,
          homeMenuPill: homeMenuPill,
          showLastSavedHint: showLastSavedHint,
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

class _DisplayLivePreview extends StatefulWidget {
  const _DisplayLivePreview({
    required this.p,
    required this.theme,
    required this.clockFont,
    required this.use24HourFormat,
    required this.showSeconds,
    required this.highlightSeconds,
    required this.previewModeLabel,
    required this.largeControls,
    required this.buttonLabels,
    required this.enableTranslucency,
    required this.showHistoryText,
    required this.homeMenuPill,
    required this.showLastSavedHint,
  });

  final Palette p;
  final String theme;
  final String clockFont;
  final bool use24HourFormat;
  final bool showSeconds;
  final bool highlightSeconds;
  final String previewModeLabel;
  final bool largeControls;
  final bool buttonLabels;
  final bool enableTranslucency;
  final bool showHistoryText;
  final bool homeMenuPill;
  final bool showLastSavedHint;

  @override
  State<_DisplayLivePreview> createState() => _DisplayLivePreviewState();
}

class _DisplayLivePreviewState extends State<_DisplayLivePreview> {
  late DateTime _now;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startClockTimer();
  }

  @override
  void didUpdateWidget(covariant _DisplayLivePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showSeconds != widget.showSeconds) _startClockTimer();
  }

  void _startClockTimer() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(
      Duration(seconds: widget.showSeconds ? 1 : 30),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final theme = widget.theme;
    final clockFont = widget.clockFont;
    final use24HourFormat = widget.use24HourFormat;
    final showSeconds = widget.showSeconds;
    final highlightSeconds = widget.highlightSeconds;
    final previewModeLabel = widget.previewModeLabel;
    final largeControls = widget.largeControls;
    final buttonLabels = widget.buttonLabels;
    final enableTranslucency = widget.enableTranslucency;
    final showHistoryText = widget.showHistoryText;
    final homeMenuPill = widget.homeMenuPill;
    final showLastSavedHint = widget.showLastSavedHint;

    final timeOfDay = TimeOfDay.fromDateTime(_now);
    final hour = use24HourFormat
        ? _now.hour
        : (timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod);
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    final secondsStr = showSeconds
        ? ':${_now.second.toString().padLeft(2, '0')}'
        : '';
    final periodStr = use24HourFormat
        ? ''
        : timeOfDay.period == DayPeriod.am
        ? ' AM'
        : ' PM';

    final surfaceBg = enableTranslucency
        ? p.surface2.withValues(alpha: 0.72)
        : p.surface2;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: p.border.withValues(alpha: 0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: p.accent.withValues(alpha: 0.28),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.device_phone_portrait,
                        size: 10,
                        color: p.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE HOME PREVIEW'.localized(context),
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${theme.toUpperCase()} • $clockFont',
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Mini Apple HIG iPhone Mockup Frame
          Container(
            margin: const EdgeInsets.fromLTRB(14, 2, 14, 16),
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: enableTranslucency
                    ? p.border.withValues(alpha: 0.55)
                    : p.border.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  if (enableTranslucency)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              p.accent.withValues(alpha: 0.08),
                              p.surface2.withValues(alpha: 0.45),
                              p.surface.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // iPhone Status Bar: 9:41, Dynamic Island / Notch, Glyphs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '9:41',
                              style: TextStyle(
                                color: p.text2,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            // Dynamic Island Pill or Compact Notch
                            if (homeMenuPill)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: p.accent.withValues(alpha: 0.45),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5.5,
                                      height: 5.5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: p.accent,
                                        boxShadow: [
                                          BoxShadow(
                                            color: p.accent.withValues(
                                              alpha: 0.6,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      previewModeLabel.localized(context),
                                      style: TextStyle(
                                        color: p.text,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                width: 28,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: p.text3.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.signal_cellular_4_bar_rounded,
                                  size: 10,
                                  color: p.text2,
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.wifi_rounded,
                                  size: 10,
                                  color: p.text2,
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.battery_full_rounded,
                                  size: 11,
                                  color: p.text2,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Center Live Clock Display
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: clockFont,
                                fontSize: 38,
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
                                      color: highlightSeconds
                                          ? p.accent
                                          : p.text3,
                                      fontSize: 28,
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
                        ),
                        const SizedBox(height: 12),

                        // Mock Recent Moment Card (Apple HIG stacked layout: no text/badge collision)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: enableTranslucency
                                ? p.surface3.withValues(alpha: 0.55)
                                : p.surface3,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: enableTranslucency
                                  ? p.border.withValues(alpha: 0.45)
                                  : p.border.withValues(alpha: 0.65),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row: Category tag & optional Saved badge
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.accent.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.sparkles,
                                          size: 10,
                                          color: p.accent,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'DEEP WORK',
                                          style: TextStyle(
                                            color: p.accent,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (showLastSavedHint)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.green.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: p.green.withValues(alpha: 0.3),
                                          width: 0.6,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.checkmark_alt,
                                            size: 9,
                                            color: p.green,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'Saved',
                                            style: TextStyle(
                                              color: p.green,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              // Middle row: Distinct title with full width freedom
                              Text(
                                'Deep Work Session Completed',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Bottom row: Metadata track
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.lock_shield,
                                    size: 10,
                                    color: p.text3,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '45m elapsed • Sovereign Local Storage',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: p.text3,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Home Screen Action Bar Preview (reflects largeControls & buttonLabels)
                        Container(
                          height: largeControls ? 60 : 46,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: enableTranslucency
                                ? p.surface.withValues(alpha: 0.70)
                                : p.surface,
                            borderRadius: BorderRadius.circular(
                              largeControls ? 18 : 14,
                            ),
                            border: Border.all(
                              color: p.border.withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _previewControlItem(
                                icon: CupertinoIcons.clock_fill,
                                label: showHistoryText ? 'History' : 'Logs',
                                showLabel: buttonLabels,
                                large: largeControls,
                                p: p,
                              ),
                              _previewControlItem(
                                icon: CupertinoIcons.add,
                                label: 'Log',
                                showLabel: buttonLabels,
                                large: largeControls,
                                isPrimary: true,
                                p: p,
                              ),
                              _previewControlItem(
                                icon: CupertinoIcons.bell_fill,
                                label: 'Remind',
                                showLabel: buttonLabels,
                                large: largeControls,
                                p: p,
                              ),
                              _previewControlItem(
                                icon: CupertinoIcons.ellipsis,
                                label: 'Menu',
                                showLabel: buttonLabels,
                                large: largeControls,
                                p: p,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Apple Home Bar Indicator
                        Center(
                          child: Container(
                            width: 52,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: p.text3.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewControlItem({
    required IconData icon,
    required String label,
    required bool showLabel,
    required bool large,
    required Palette p,
    bool isPrimary = false,
  }) {
    final size = large ? 32.0 : 24.0;
    final iconSize = large ? 16.0 : 13.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPrimary ? p.accent : p.surface3.withValues(alpha: 0.7),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: isPrimary ? Colors.white : p.text,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: p.text3,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
