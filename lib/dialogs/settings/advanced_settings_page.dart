import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/dynamic_l10n_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  final Map<String, double> _downloadProgress = {};
  final Set<String> _downloadingCodes = {};

  Future<void> _handleDownloadAndApply(String code) async {
    HapticFeedback.selectionClick();
    setState(() {
      _downloadingCodes.add(code);
      _downloadProgress[code] = 0.1;
    });

    final success = await DynamicL10nService.instance.downloadLanguage(
      code,
      onProgress: (p) {
        if (mounted) {
          setState(() => _downloadProgress[code] = p);
        }
      },
    );

    if (!mounted) return;
    setState(() {
      _downloadingCodes.remove(code);
      _downloadProgress.remove(code);
    });

    if (success) {
      HapticFeedback.mediumImpact();
      widget.onLocaleChanged?.call(code);
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to download language pack. Check network connection.'
                .localized(context),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleDelete(String code) async {
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await DynamicL10nService.instance.deleteLanguage(code, prefs);
    if (!mounted) return;
    setState(() {});
    if (widget.currentLocale == code) {
      widget.onLocaleChanged?.call('en');
    }
  }

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
              icon: Icons.translate_rounded,
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
              icon: Icons.accessibility_new_rounded,
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
              icon: Icons.developer_mode_rounded,
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
              icon: Icons.restart_alt_rounded,
              title: 'Reset'.localized(context),
              status: 'Wipe'.localized(context),
              color: p.red,
              onTap: () => widget.onOpenCategory('Reset', parent: 'Advanced'),
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
    final p = widget.p;
    final l10nService = DynamicL10nService.instance;
    final languages = l10nService.catalog;

    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          title: 'Core Languages'.localized(context).toUpperCase(),
          children: [
            SettingsRow(
              p: p,
              title: 'System Default'.localized(context),
              subtitle: 'Follow device settings'.localized(context),
              trailing: widget.currentLocale == 'system'
                  ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                  : const SizedBox.shrink(),
              onTap: () {
                if (widget.currentLocale == 'system') return;
                HapticFeedback.selectionClick();
                widget.onLocaleChanged?.call('system');
              },
            ),
            SettingsRow(
              p: p,
              title: 'English',
              subtitle: 'Core built-in language'.localized(context),
              trailing: widget.currentLocale == 'en'
                  ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                  : const SizedBox.shrink(),
              onTap: () {
                if (widget.currentLocale == 'en') return;
                HapticFeedback.selectionClick();
                widget.onLocaleChanged?.call('en');
              },
            ),
          ],
        ),
        const SizedBox(height: spacing12),

        SettingsGroup(
          p: p,
          title: 'On-Demand Language Packs'.localized(context).toUpperCase(),
          children: [
            for (final lang in languages)
              _buildLanguageRow(
                p: p,
                flag: lang.flag,
                name: lang.name,
                englishName: '${lang.englishName} (~${lang.sizeKb} KB)',
                code: lang.code,
              ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Downloaded language packs operate 100% offline. Deleting a language frees local storage and restores English.'
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
          SettingsBetaNote(
            p: p,
            text: 'The current features on this page are under Beta stage.'
                .localized(context),
            onLearnMore: widget.onLearnMoreBeta!,
          ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildLanguageRow({
    required Palette p,
    required String flag,
    required String name,
    required String englishName,
    required String code,
  }) {
    final isSelected = widget.currentLocale == code;
    final isDownloaded = DynamicL10nService.instance.isDownloaded(code);
    final isDownloading = _downloadingCodes.contains(code);
    final progress = _downloadProgress[code] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? p.accent : p.border.withValues(alpha: 0.5),
              ),
            ),
            alignment: Alignment.center,
            child: Text(flag, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.localized(context),
                  style: TextStyle(
                    color: isSelected ? p.accent : p.text,
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  englishName.localized(context),
                  style: TextStyle(color: p.text3, fontSize: 11.5),
                ),
              ],
            ),
          ),
          if (isDownloading) ...[
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                value: progress > 0.1 ? progress : null,
                strokeWidth: 2.2,
                color: p.accent,
              ),
            ),
          ] else if (isSelected) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.accent.withValues(alpha: 0.35)),
              ),
              child: Text(
                'Active'.localized(context),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ] else if (isDownloaded) ...[
            PressableScale(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onLocaleChanged?.call(code);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.border.withValues(alpha: 0.6)),
                ),
                child: Text(
                  'Use'.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PressableScale(
              onTap: () => _handleDelete(code),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 15,
                  color: p.red,
                ),
              ),
            ),
          ] else ...[
            PressableScale(
              onTap: () => _handleDownloadAndApply(code),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_download_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Get'.localized(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
                    ? Icon(Icons.check_rounded, color: p.accent, size: 20)
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
              onChanged: widget.onLargeTextChanged,
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
              icon: Icons.restore_rounded,
              title: 'Reset Settings'.localized(context),
              subtitle:
                  'Restores default themes, haptics, and notification preferences without deleting saved moments.'
                      .localized(context),
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
              icon: Icons.delete_forever_rounded,
              title: 'Reset All Data'.localized(context),
              subtitle:
                  'Permanently removes all saved moments and session histories from local storage.'
                      .localized(context),
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
              icon: Icons.phonelink_erase_rounded,
              title: 'Factory Reset'.localized(context),
              subtitle:
                  'Completely wipes all moments, preferences, and hardware keys back to fresh install state.'
                      .localized(context),
              color: p.red,
              onTap: widget.onFactoryReset,
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
