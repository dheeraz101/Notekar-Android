import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class AdvancedSettingsPage extends StatefulWidget {
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
    this.soundEffects = true,
    required this.onHapticStyleChanged,
    this.onSoundEffectsChanged,
    required this.onReduceMotionChanged,
    required this.onLargeTextChanged,
    required this.onHighContrastChanged,
    required this.onResetSettings,
    required this.onResetAllData,
    required this.onFactoryReset,
    required this.onOpenCategory,
    required this.onExportCsv,
    required this.onExportJson,
    required this.onExportBackup,
    required this.onResetCircuitBreakers,
    this.isGodModeUnlocked = false,
    this.isCircuitBreakerTripped = false,
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
  final bool soundEffects;
  final bool isGodModeUnlocked;
  final bool isCircuitBreakerTripped;

  final ValueChanged<String> onHapticStyleChanged;
  final ValueChanged<bool>? onSoundEffectsChanged;
  final ValueChanged<bool> onReduceMotionChanged;
  final ValueChanged<bool> onLargeTextChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final VoidCallback onResetSettings;
  final VoidCallback onResetAllData;
  final VoidCallback onFactoryReset;
  final VoidCallback onExportCsv;
  final VoidCallback onExportJson;
  final VoidCallback onExportBackup;
  final VoidCallback onResetCircuitBreakers;
  final void Function(String category, {required String parent}) onOpenCategory;

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  bool _isResettingCircuitBreakers = false;
  bool _isExportingLogs = false;

  @override
  Widget build(BuildContext context) {
    if (widget.subCategory == 'Advanced') {
      return _buildAdvanced(context);
    } else if (widget.subCategory == 'Language') {
      return _buildLanguage(context);
    } else if (widget.subCategory == 'Accessibility') {
      return _buildAccessibility(context);
    } else if (widget.subCategory == 'Reset') {
      return _buildReset(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildAdvanced(BuildContext context) {
    final p = widget.p;

    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.globe,
              title: 'Language'.localized(context),
              status: switch (widget.currentLocale) {
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
              onTap: () =>
                  widget.onOpenCategory('Language', parent: 'Advanced'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.person_crop_circle,
              title: 'Accessibility'.localized(context),
              status: widget.hapticStyle.isEmpty
                  ? ''
                  : widget.hapticStyle[0].toUpperCase() +
                        widget.hapticStyle.substring(1),
              color: p.orange,
              onTap: () =>
                  widget.onOpenCategory('Accessibility', parent: 'Advanced'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.link,
              title: 'Automation'.localized(context),
              status: 'Bridge'.localized(context),
              color: p.accent,
              onTap: () => widget.onOpenCategory(
                'Integrations & Automation',
                parent: 'Advanced',
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'These tools are intended for system maintenance and troubleshooting.'
                  .localized(context),
        ),
        const SizedBox(height: spacing12),

        // System Tools Group
        SettingsGroup(
          p: p,
          title: 'Advanced Systems'.localized(context),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.wrench_fill,
              title: 'Developer Options'.localized(context),
              status: 'Tools'.localized(context),
              color: p.accent,
              onTap: () => widget.onOpenCategory(
                'Developer Options',
                parent: 'Advanced',
              ),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.arrow_counterclockwise,
              title: 'Factory Reset'.localized(context),
              status: 'Wipe'.localized(context),
              color: p.red,
              onTap: () => widget.onOpenCategory('Reset', parent: 'Advanced'),
            ),
            if (widget.isGodModeUnlocked)
              SettingsRow(
                p: p,
                icon: CupertinoIcons.sparkles,
                title: 'God Mode'.localized(context),
                status: 'Unlocked'.localized(context),
                color: const Color(0xFFFFD700),
                onTap: () =>
                    widget.onOpenCategory('God Mode', parent: 'Advanced'),
              ),
          ],
        ),

        const SizedBox(height: spacing12),

        // Diagnostics & Safeguards (Minimal Apple HIG)
        SettingsGroup(
          p: p,
          title: 'Diagnostics & Safeguards'.localized(context),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: widget.isCircuitBreakerTripped
                  ? CupertinoIcons.bolt_slash_fill
                  : CupertinoIcons.shield_fill,
              title: 'Circuit Breakers'.localized(context),
              status: widget.isCircuitBreakerTripped
                  ? 'Tripped'.localized(context)
                  : 'Healthy'.localized(context),
              color: widget.isCircuitBreakerTripped ? p.red : p.green,
              trailing: _isResettingCircuitBreakers
                  ? CupertinoActivityIndicator(radius: 8, color: p.accent)
                  : null,
              onTap: () async {
                if (_isResettingCircuitBreakers) return;
                setState(() => _isResettingCircuitBreakers = true);
                await Future.delayed(const Duration(milliseconds: 1400));
                if (!mounted) return;
                widget.onResetCircuitBreakers();
                setState(() => _isResettingCircuitBreakers = false);
              },
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.doc_text_fill,
              title: 'Export Diagnostic Logs'.localized(context),
              status: 'JSON'.localized(context),
              color: p.accent,
              trailing: _isExportingLogs
                  ? CupertinoActivityIndicator(radius: 8, color: p.accent)
                  : null,
              onTap: () async {
                if (_isExportingLogs) return;
                setState(() => _isExportingLogs = true);
                await Future.delayed(const Duration(milliseconds: 1400));
                if (!mounted) return;
                widget.onExportJson();
                setState(() => _isExportingLogs = false);
              },
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'Self-healing circuit breakers and diagnostic event exports.'
              .localized(context),
        ),
        const SizedBox(height: spacing24),
      ],
    );
  }

  Widget _buildLanguage(BuildContext context) {
    final p = widget.p;

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
            for (final lang in availableLanguages) ...[
              () {
                final isBeta = lang.code != 'system' && lang.code != 'en';
                final isSelected = widget.currentLocale == lang.code;
                return SettingsRow(
                  p: p,
                  title: lang.native,
                  subtitle: lang.subtitle,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isBeta && !isSelected) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: p.orange.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: p.orange.withValues(alpha: 0.28),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'BETA',
                            style: TextStyle(
                              color: p.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                      if (isBeta && isSelected) ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFCC00),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isSelected)
                        Icon(
                          CupertinoIcons.checkmark,
                          color: p.accent,
                          size: 18,
                        ),
                    ],
                  ),
                  onTap: () async {
                    if (widget.currentLocale == lang.code) return;
                    if (isBeta) {
                      HapticFeedback.lightImpact();
                      final confirmed = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: Text('Beta Language Notice'.localized(ctx)),
                          content: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'The language "${lang.native}" is currently in beta and you may see inconsistencies throughout the app.'
                                  .localized(ctx),
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text('Cancel'.localized(ctx)),
                            ),
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text('OK'.localized(ctx)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                    }
                    HapticFeedback.selectionClick();
                    widget.onLocaleChanged?.call(lang.code);
                  },
                );
              }(),
            ],
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
        if (widget.onLearnMoreBeta != null)
          SettingsBetaNote(p: p, onLearnMore: widget.onLearnMoreBeta!),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildAccessibility(BuildContext context) {
    final p = widget.p;

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
                trailing: widget.hapticStyle == style
                    ? Icon(CupertinoIcons.checkmark, color: p.accent, size: 18)
                    : const SizedBox.shrink(),
                onTap: () {
                  if (widget.hapticStyle == style) return;
                  HapticFeedback.selectionClick();
                  widget.onHapticStyleChanged(style);
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
              title: 'Sound Effects',
              subtitle:
                  'Play instant tactile auditory feedback on clicks, taps, and swipe actions.'
                      .localized(context),
              color: p.accent,
              value: widget.soundEffects,
              onChanged: widget.onSoundEffectsChanged ?? (_) {},
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Tactile auditory clicks provide immediate physical reassurance upon every capture.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Reduced Motion',
              color: p.green,
              value: widget.reduceMotion,
              onChanged: widget.onReduceMotionChanged,
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
              value: widget.largeText,
              onChanged: (val) {
                final systemScale = MediaQuery.of(context).textScaler.scale(1);
                if (val && systemScale >= 1.15) {
                  showCupertinoDialog<void>(
                    context: context,
                    builder: (ctx) => CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: p.name == 'light'
                            ? Brightness.light
                            : Brightness.dark,
                        primaryColor: p.accent,
                      ),
                      child: CupertinoAlertDialog(
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
                              widget.onLargeTextChanged(true);
                            },
                            child: Text('Enable Anyway'.localized(ctx)),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  widget.onLargeTextChanged(val);
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
              value: widget.highContrast,
              onChanged: widget.onHighContrastChanged,
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
    final p = widget.p;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.arrow_counterclockwise,
              title: 'Reset Settings'.localized(context),
              subtitle: 'Restore default preferences and layout'.localized(
                context,
              ),
              color: p.orange,
              onTap: widget.onResetSettings,
            ),
          ],
        ),
        const SizedBox(height: spacing12),

        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.trash_fill,
              title: 'Reset All Data'.localized(context),
              subtitle: 'Delete all recorded moments and sessions'.localized(
                context,
              ),
              color: p.red,
              onTap: widget.onResetAllData,
            ),
          ],
        ),
        const SizedBox(height: spacing12),

        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.trash_circle_fill,
              title: 'Factory Reset'.localized(context),
              subtitle: 'Erase all data and restore factory settings'.localized(
                context,
              ),
              color: p.red,
              onTap: widget.onFactoryReset,
            ),
          ],
        ),
        const SizedBox(height: spacing4),
        SettingsPageDescription(
          p: p,
          showIcon: true,
          icon: CupertinoIcons.exclamationmark_triangle_fill,
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
