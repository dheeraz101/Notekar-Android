import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/dynamic_l10n_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCenterSheet extends StatefulWidget {
  const LanguageCenterSheet({
    super.key,
    required this.p,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final Palette p;
  final String currentLocale;
  final ValueChanged<String> onLocaleChanged;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required String currentLocale,
    required ValueChanged<String> onLocaleChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => LanguageCenterSheet(
        p: p,
        currentLocale: currentLocale,
        onLocaleChanged: onLocaleChanged,
      ),
    );
  }

  @override
  State<LanguageCenterSheet> createState() => _LanguageCenterSheetState();
}

class _LanguageCenterSheetState extends State<LanguageCenterSheet> {
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
      widget.onLocaleChanged(code);
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
      widget.onLocaleChanged('en');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final l10nService = DynamicL10nService.instance;
    final languages = l10nService.catalog;

    return AppSheet(
      p: p,
      title: 'Language Center'.localized(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsGroup(
            p: p,
            children: [
              // System Default Option
              _buildLanguageRow(
                p: p,
                flag: '🌐',
                name: 'System Default',
                englishName: 'Follow Device Language',
                code: 'system',
                isDefault: true,
              ),
              // English Core Option
              _buildLanguageRow(
                p: p,
                flag: '🇬🇧',
                name: 'English',
                englishName: 'Core App Language (Built-in)',
                code: 'en',
                isDefault: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  isDefault: false,
                ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsPageDescription(
            p: p,
            text:
                'Downloaded language packs operate 100% offline. Deleting a language frees local storage and immediately restores default English.'
                    .localized(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLanguageRow({
    required Palette p,
    required String flag,
    required String name,
    required String englishName,
    required String code,
    required bool isDefault,
  }) {
    final isSelected = widget.currentLocale == code;
    final isDownloaded =
        isDefault || DynamicL10nService.instance.isDownloaded(code);
    final isDownloading = _downloadingCodes.contains(code);
    final progress = _downloadProgress[code] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(12),
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
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  englishName.localized(context),
                  style: TextStyle(color: p.text3, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isDownloading) ...[
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress > 0.1 ? progress : null,
                strokeWidth: 2.5,
                color: p.accent,
              ),
            ),
          ] else if (isSelected) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.accent.withValues(alpha: 0.35)),
              ),
              child: Text(
                'Active'.localized(context),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ] else if (isDownloaded) ...[
            PressableScale(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onLocaleChanged(code);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p.border.withValues(alpha: 0.6)),
                ),
                child: Text(
                  'Use'.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (!isDefault) ...[
              const SizedBox(width: 8),
              PressableScale(
                onTap: () => _handleDelete(code),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: p.red,
                  ),
                ),
              ),
            ],
          ] else ...[
            PressableScale(
              onTap: () => _handleDownloadAndApply(code),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_download_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Get'.localized(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
}
