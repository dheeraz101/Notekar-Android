import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/feature_conflict_dialog.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/sobriety_milestones.dart';
import 'package:notekar/services/dynamic_l10n_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.p,
    required this.theme,
    required this.defaultMode,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.onTheme,
    required this.onDefaultMode,
    this.appIconStyle = 'default',
    this.onAppIconStyle,
    this.useNumbersInSingle = false,
    this.onUseNumbersInSingle,
    this.resetSingleDaily = false,
    this.onResetSingleDaily,
    this.countOnSave = false,
    this.onCountOnSave,
    this.enableSobrietyMode = false,
    this.onSobrietyMode,
    this.sobrietyMilestoneTheme = 'science',
    this.onSobrietyMilestoneTheme,
    this.compactHistory = false,
    this.onCompactHistory,
    required this.pages,
  });

  final Palette p;
  final String theme;
  final String defaultMode;
  final String currentLocale;
  final ValueChanged<String> onLocaleChanged;
  final ValueChanged<String> onTheme;
  final ValueChanged<String> onDefaultMode;
  final String appIconStyle;
  final ValueChanged<String>? onAppIconStyle;
  final bool useNumbersInSingle;
  final ValueChanged<bool>? onUseNumbersInSingle;
  final bool resetSingleDaily;
  final ValueChanged<bool>? onResetSingleDaily;
  final bool countOnSave;
  final ValueChanged<bool>? onCountOnSave;
  final bool enableSobrietyMode;
  final ValueChanged<bool>? onSobrietyMode;
  final String sobrietyMilestoneTheme;
  final ValueChanged<String>? onSobrietyMilestoneTheme;
  final bool compactHistory;
  final ValueChanged<bool>? onCompactHistory;
  final List<String> pages;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentPage = 0;

  late String theme;
  late String defaultMode;
  late String currentLocale;

  bool _notificationGranted = false;
  bool _batteryExempt = false;
  bool _installGranted = false;

  SharedPreferences? _prefs;
  bool _enableSobrietyMode = false;
  String _sobrietyMilestoneTheme = 'science';
  bool _useNumbersInSingle = false;
  bool _resetSingleDaily = false;
  bool _countOnSave = false;
  String _appIconStyle = 'default';
  bool _enableMindfulness = false;
  final Set<String> _downloadingLanguageCodes = {};

  Future<void> _downloadAndApplyLanguage(String code) async {
    HapticFeedback.selectionClick();
    setState(() {
      _downloadingLanguageCodes.add(code);
    });

    final success = await DynamicL10nService.instance.downloadLanguage(code);

    if (!mounted) return;
    setState(() {
      _downloadingLanguageCodes.remove(code);
    });

    if (success) {
      HapticFeedback.mediumImpact();
      setState(() => currentLocale = code);
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

  static const _fileChannel = MethodChannel('notekar/files');

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    theme = widget.theme;
    defaultMode = widget.defaultMode;
    currentLocale = widget.currentLocale;
    _appIconStyle = widget.appIconStyle;
    _useNumbersInSingle = widget.useNumbersInSingle;
    _resetSingleDaily = widget.resetSingleDaily;
    _countOnSave = widget.countOnSave;
    _enableSobrietyMode = widget.enableSobrietyMode;
    _sobrietyMilestoneTheme = widget.sobrietyMilestoneTheme;

    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
    _loadSobrietyPrefs();
  }

  Future<void> _loadSobrietyPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableSobrietyMode =
          _prefs?.getBool('enable_sobriety_mode') ?? widget.enableSobrietyMode;
      _sobrietyMilestoneTheme =
          _prefs?.getString('sobriety_milestone_theme') ??
          widget.sobrietyMilestoneTheme;
      _useNumbersInSingle =
          _prefs?.getBool('m-use-numbers-in-single') ??
          widget.useNumbersInSingle;
      _resetSingleDaily =
          _prefs?.getBool('m-reset-single-daily') ?? widget.resetSingleDaily;
      _countOnSave = _prefs?.getBool('m-count-on-save') ?? widget.countOnSave;
      _appIconStyle =
          _prefs?.getString('m-app-icon-style') ?? widget.appIconStyle;
      _enableMindfulness =
          _prefs?.getBool('reminder_reflection_enabled') ?? false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final bool notificationGranted =
          await _fileChannel.invokeMethod<bool>('canPostNotifications') ??
          false;
      final bool batteryExempt =
          await _fileChannel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          false;
      final bool installGranted =
          await _fileChannel.invokeMethod<bool>('canInstallPackages') ?? false;
      if (mounted) {
        setState(() {
          _notificationGranted = notificationGranted;
          _batteryExempt = batteryExempt;
          _installGranted = installGranted;
        });
      }
    } catch (_) {}
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildSobrietyPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: p.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: p.orange.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.self_improvement_rounded,
                color: p.orange,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Sobriety Companion'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'A privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 14.5, height: 1.4),
            ),
          ),
          const SizedBox(height: 32),
          SettingsGroup(
            p: p,
            children: [
              SettingsSwitchRow(
                p: p,
                icon: Icons.self_improvement_rounded,
                title: 'Enable Sobriety Mode'.localized(context),
                subtitle:
                    'Adds a clean streak card to your home screen and adapts home screen widgets.'
                        .localized(context),
                color: p.orange,
                value: _enableSobrietyMode,
                onChanged: (value) async {
                  if (_prefs != null) {
                    await _prefs!.setBool('enable_sobriety_mode', value);
                  }
                  setState(() => _enableSobrietyMode = value);
                  widget.onSobrietyMode?.call(value);
                },
              ),
              if (_enableSobrietyMode) ...[
                SettingsRow(
                  p: p,
                  icon: Icons.palette_rounded,
                  title: 'Milestone Theme'.localized(context),
                  subtitle: () {
                    final t = kMilestoneThemes.firstWhere(
                      (t) => t.id == _sobrietyMilestoneTheme,
                      orElse: () => kMilestoneThemes.first,
                    );
                    return '${t.emoji} ${t.name.localized(context)}: ${t.description.localized(context)}';
                  }(),
                  color: p.orange,
                  onTap: () => _showOnboardingThemePicker(context, p),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SettingsPageDescription(
            p: p,
            text:
                'Your data is 100% private and stays offline on this device. Enabling this does not alter any existing logs.'
                    .localized(context),
          ),
        ],
      ),
    );
  }

  void _showOnboardingThemePicker(BuildContext context, Palette p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: p.surface.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: p.accent.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Glass(
              p: p,
              radius: 32,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: p.text3.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Choose Milestone Theme'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final theme in kMilestoneThemes)
                            SettingsRow(
                              p: p,
                              title:
                                  '${theme.emoji} ${theme.name.localized(context)}',
                              subtitle: theme.description.localized(context),
                              color: p.orange,
                              trailing: _sobrietyMilestoneTheme == theme.id
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: p.orange,
                                      size: 20,
                                    )
                                  : Icon(
                                      Icons.circle_outlined,
                                      color: p.text3,
                                      size: 20,
                                    ),
                              onTap: () async {
                                if (_prefs != null) {
                                  await _prefs!.setString(
                                    'sobriety_milestone_theme',
                                    theme.id,
                                  );
                                }
                                setState(
                                  () => _sobrietyMilestoneTheme = theme.id,
                                );
                                widget.onSobrietyMilestoneTheme?.call(theme.id);
                                if (context.mounted) Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMindfulnessPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: p.accent.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.self_improvement_rounded,
                color: p.accent,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Mindfulness & Time Reflection'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Take a 10-second mindful pause each hour to reset, breathe, and reflect without endless scrolling.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 14.5, height: 1.4),
            ),
          ),
          const SizedBox(height: 28),

          // Interactive Apple HIG Settings Group
          SettingsGroup(
            p: p,
            children: [
              SettingsSwitchRow(
                p: p,
                icon: Icons.notifications_active_rounded,
                title: 'Hourly Mindfulness'.localized(context),
                subtitle: 'Hourly chime and mindful pause overlay.'.localized(
                  context,
                ),
                color: p.accent,
                value: _enableMindfulness,
                onChanged: (value) async {
                  if (_prefs != null) {
                    await _prefs!.setBool('reminder_reflection_enabled', value);
                  }
                  setState(() => _enableMindfulness = value);
                },
              ),
              SettingsRow(
                p: p,
                icon: Icons.bedtime_rounded,
                title: 'Active Hours'.localized(context),
                status: '9 AM – 10 PM'.localized(context),
                subtitle: 'Muted overnight to protect your sleep.'.localized(
                  context,
                ),
                color: p.accent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsPageDescription(
            p: p,
            text:
                '100% offline, private, and battery-friendly. You can fine-tune intervals, quiet hours, and custom messages anytime in Settings.'
                    .localized(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // iOS 26 Hero App Badge
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'icon-maskable-512.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to NoteKar'.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A quiet, offline-first way to mark moments the second they happen.'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              for (final option in const ['dark', 'light']) ...[
                Expanded(
                  child: ThemeChoice(
                    p: p,
                    label: option == 'dark' ? 'Dark' : 'Light',
                    active: theme == option,
                    color: option == 'dark'
                        ? Colors.black
                        : const Color(0xFFF2F2F7),
                    onTap: () {
                      setState(() => theme = option);
                      widget.onTheme(option);
                    },
                  ),
                ),
                if (option == 'dark') const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 24),
          SegmentedSetting(
            p: p,
            title: 'Startup Mode'.localized(context),
            subtitle: 'Choose how NoteKar starts when you open it'.localized(
              context,
            ),
            value: defaultMode,
            values: const {'single': 'Single', 'two-way': 'Two-Way'},
            onChanged: (value) {
              setState(() => defaultMode = value);
              widget.onDefaultMode(value);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLanguagePage(Palette p) {
    final l10nService = DynamicL10nService.instance;
    final languages = l10nService.catalog;
    final downloadedPacks = languages
        .where((l) => l10nService.isDownloaded(l.code))
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: p.accent.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.language_rounded, color: p.accent, size: 38),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Choose Language'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Select your preferred interface language. On-demand packages download instantly and work offline.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 14, height: 1.4),
            ),
          ),
          const SizedBox(height: 28),

          // 1. Core Languages
          SettingsGroup(
            p: p,
            title: 'Core Languages'.localized(context).toUpperCase(),
            children: [
              SettingsRow(
                p: p,
                title: 'System Default'.localized(context),
                subtitle: 'Follow device system language'.localized(context),
                trailing: currentLocale == 'system'
                    ? Icon(Icons.check_rounded, color: p.accent, size: 22)
                    : const SizedBox.shrink(),
                onTap: () {
                  if (currentLocale == 'system') return;
                  HapticFeedback.selectionClick();
                  setState(() => currentLocale = 'system');
                  widget.onLocaleChanged('system');
                },
              ),
              SettingsRow(
                p: p,
                title: 'English',
                subtitle: 'Core built-in language'.localized(context),
                trailing: currentLocale == 'en'
                    ? Icon(Icons.check_rounded, color: p.accent, size: 22)
                    : const SizedBox.shrink(),
                onTap: () {
                  if (currentLocale == 'en') return;
                  HapticFeedback.selectionClick();
                  setState(() => currentLocale = 'en');
                  widget.onLocaleChanged('en');
                },
              ),
              for (final pack in downloadedPacks)
                SettingsRow(
                  p: p,
                  title: '${pack.flag}  ${pack.name}',
                  subtitle:
                      '${pack.englishName} (${'Downloaded'.localized(context)})',
                  trailing: currentLocale == pack.code
                      ? Icon(Icons.check_rounded, color: p.accent, size: 22)
                      : const SizedBox.shrink(),
                  onTap: () {
                    if (currentLocale == pack.code) return;
                    HapticFeedback.selectionClick();
                    setState(() => currentLocale = pack.code);
                    widget.onLocaleChanged(pack.code);
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. On-Demand Downloadable Language Packs
          SettingsGroup(
            p: p,
            title: 'On-Demand Language Packs'.localized(context).toUpperCase(),
            children: [
              for (final lang in languages)
                _buildWelcomeLanguagePackRow(p, lang),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Upcoming Languages
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWelcomeLanguagePackRow(Palette p, LanguagePackInfo lang) {
    final isDownloaded = DynamicL10nService.instance.isDownloaded(lang.code);
    final isDownloading = _downloadingLanguageCodes.contains(lang.code);

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
                color: isDownloaded
                    ? p.accent.withValues(alpha: 0.5)
                    : p.border.withValues(alpha: 0.5),
              ),
            ),
            alignment: Alignment.center,
            child: Text(lang.flag, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.name.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${lang.englishName} (~${lang.sizeKb} KB)'.localized(context),
                  style: TextStyle(color: p.text3, fontSize: 12.5),
                ),
              ],
            ),
          ),
          if (isDownloading) ...[
            CupertinoActivityIndicator(radius: 10, color: p.accent),
          ] else if (isDownloaded) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.accent.withValues(alpha: 0.35)),
              ),
              child: Text(
                'Available Above'.localized(context),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            PressableScale(
              onTap: () => _downloadAndApplyLanguage(lang.code),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(999),
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
                        fontSize: 12.5,
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

  Widget _buildSecurityPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: p.accent.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.lock_person_rounded, color: p.accent, size: 38),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Security & Cryptographic Upgrade'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Notekar is now more secure than ever, built to protect your private records.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 14.5, height: 1.4),
            ),
          ),
          const SizedBox(height: 32),
          SettingsGroup(
            p: p,
            children: [
              _buildFeatureRow(
                p: p,
                icon: Icons.vpn_key_rounded,
                title: 'Hardware-Backed Encryption'.localized(context),
                text:
                    'All databases are locked with 256-bit AES keys generated inside the secure Android Keystore, protecting data even on rooted devices.'
                        .localized(context),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.blur_on_rounded,
                title: 'App Switcher Obfuscation'.localized(context),
                text:
                    'Hides your active screen and text previews in the system task switcher, keeping your private thoughts hidden from prying eyes.'
                        .localized(context),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.password_rounded,
                title: 'Secure Passcode Protection'.localized(context),
                text:
                    'In-app PIN configuration is derived using secure key-derivation functions with random salts to prevent passcode extraction.'
                        .localized(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNetworkMonitorPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: p.accent.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.network_check_rounded,
                color: p.accent,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Network & Data Transparency'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'NoteKar now includes a built-in offline-first Network Monitor to track and verify internet connectivity.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 14.5, height: 1.4),
            ),
          ),
          const SizedBox(height: 32),
          SettingsGroup(
            p: p,
            children: [
              _buildFeatureRow(
                p: p,
                icon: Icons.wifi_find_rounded,
                title: 'Real-time Traffic Audit'.localized(context),
                text:
                    'Every single outbound network request made by NoteKar is audited and shown in settings. You know exactly when and why the app uses internet.'
                        .localized(context),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.verified_user_rounded,
                title: '100% Offline Integrity'.localized(context),
                text:
                    'All network logs remain stored locally in private storage. No tracking SDKs or telemetry exist. Your privacy is mathematically secure.'
                        .localized(context),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.system_update_alt_rounded,
                title: 'Smart Bandwidth Saver'.localized(context),
                text:
                    'Warns you before downloading in-app software updates via mobile data and estimates download sizes to save your monthly bandwidth data.'
                        .localized(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Essential Features'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Everything is stored locally and private to your device'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          SettingsGroup(
            p: p,
            children: [
              _buildFeatureRow(
                p: p,
                icon: Icons.touch_app_rounded,
                title: 'Tap to save'.localized(context),
                text: 'Log a moment instantly from the main screen.'.localized(
                  context,
                ),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.swap_vert_rounded,
                title: 'Track starts and stops'.localized(context),
                text: 'Use Single or Two-Way mode based on your flow.'
                    .localized(context),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.edit_note_rounded,
                title: 'Hold for notes'.localized(context),
                text: 'Attach context without slowing the app down.'.localized(
                  context,
                ),
              ),
              _buildFeatureRow(
                p: p,
                icon: Icons.history_rounded,
                title: 'Review and export'.localized(context),
                text: 'Filter history, compare moments, export, or backup.'
                    .localized(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAppIconsPage(Palette p) {
    const icons = {
      'default': ('Default', 'icon-maskable-512.png'),
      'black': ('Midnight', 'app_icons/black.png'),
      'blue': ('Sapphire', 'app_icons/blue.png'),
      'gold': ('Imperial', 'app_icons/gold.png'),
      'green': ('Emerald', 'app_icons/green.png'),
      'orange': ('Sunset', 'app_icons/orange.png'),
      'red': ('Crimson', 'app_icons/red.png'),
      'purple': ('Amethyst', 'app_icons/purple.png'),
    };

    final currentEntry = icons[_appIconStyle];
    final currentAsset = currentEntry?.$2 ?? 'icon-maskable-512.png';
    final currentTitle = currentEntry?.$1 ?? 'Aurora';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 84,
              height: 84,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: p.accent.withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(currentAsset, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Personalized App Icons'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Selected: $currentTitle'.localized(context),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: icons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final entry = icons.entries.elementAt(index);
              final isSelected = _appIconStyle == entry.key;
              return GestureDetector(
                onTap: () async {
                  if (_appIconStyle == entry.key) return;
                  NotekarHaptics.selection('standard');
                  setState(() => _appIconStyle = entry.key);
                  if (_prefs != null) {
                    await _prefs!.setString('m-app-icon-style', entry.key);
                  }
                  widget.onAppIconStyle?.call(entry.key);
                  try {
                    await _fileChannel.invokeMethod<void>('setAppIconStyle', {
                      'style': entry.key,
                    });
                  } catch (_) {}
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? p.accent.withValues(alpha: 0.14)
                        : p.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? p.accent : p.border,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: p.accent.withValues(alpha: 0.20),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      entry.value.$2,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SettingsPageDescription(
            p: p,
            showIcon: true,
            text:
                'You can always switch your app icon anytime in Settings → Personalization.'
                    .localized(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNumberedSinglesPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: p.accent.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '00',
                style: TextStyle(
                  color: p.accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Numbered Single Moments'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an iOS style calendar.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 14.5, height: 1.4),
            ),
          ),
          const SizedBox(height: 32),
          SettingsGroup(
            p: p,
            children: [
              SettingsSwitchRow(
                p: p,
                icon: Icons.pin_outlined,
                title: 'Use Numbers in Single'.localized(context),
                subtitle:
                    'Shows 00–99 counters instead of static icons in history.'
                        .localized(context),
                color: p.accent,
                value: _useNumbersInSingle,
                onChanged: (value) async {
                  if (value) {
                    final isCompact =
                        _prefs?.getBool('m-compact-history') ??
                        widget.compactHistory;
                    if (isCompact) {
                      final confirmed = await showFeatureConflictDialog(
                        context,
                        p: p,
                        title: 'Disable Compact History?',
                        message:
                            'Sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. Turn off Compact History to enable numbers in single mode.',
                        confirmLabel: 'Turn Off & Enable',
                        icon: Icons.pin_outlined,
                        iconColor: p.accent,
                      );
                      if (!confirmed) return;
                      if (_prefs != null) {
                        await _prefs!.setBool('m-compact-history', false);
                        await _prefs!.setString(
                          'm-history-density',
                          'comfortable',
                        );
                      }
                      widget.onCompactHistory?.call(false);
                    }
                  }
                  if (_prefs != null) {
                    await _prefs!.setBool('m-use-numbers-in-single', value);
                  }
                  setState(() => _useNumbersInSingle = value);
                  widget.onUseNumbersInSingle?.call(value);
                },
              ),
              if (_useNumbersInSingle) ...[
                SettingsSwitchRow(
                  p: p,
                  icon: Icons.restart_alt_rounded,
                  title: 'Reset Daily'.localized(context),
                  subtitle:
                      'Restarts count at 00 every midnight while keeping past history intact.'
                          .localized(context),
                  color: p.accent,
                  value: _resetSingleDaily,
                  onChanged: (value) async {
                    if (_prefs != null) {
                      await _prefs!.setBool('m-reset-single-daily', value);
                    }
                    setState(() => _resetSingleDaily = value);
                    widget.onResetSingleDaily?.call(value);
                  },
                ),
                SettingsSwitchRow(
                  p: p,
                  icon: Icons.touch_app_outlined,
                  title: 'Enable Count on Save'.localized(context),
                  subtitle:
                      'Shows sequential numbers (00, 01...) on the tap pulse animation.'
                          .localized(context),
                  color: p.accent,
                  value: _countOnSave,
                  onChanged: (value) async {
                    if (_prefs != null) {
                      await _prefs!.setBool('m-count-on-save', value);
                    }
                    setState(() => _countOnSave = value);
                    widget.onCountOnSave?.call(value);
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SettingsPageDescription(
            p: p,
            text:
                '00 is the starting point. Moments count up to 99 and then restart at 00. You can customize these anytime in Settings > Moments.'
                    .localized(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required Palette p,
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: p.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoMovePage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Repository Migration Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.accent.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: GithubIcon(size: 36, color: p.accent),
          ),
          const SizedBox(height: 24),
          Text(
            'Official Repository Moved'.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We have officially migrated our codebase to a new home. All future releases, updates, and issues will be managed here:'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 24),

          // New Repo Card
          Glass(
            p: p,
            radius: 20,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GithubIcon(size: 20, color: p.text3),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'github.com/dheeraz101/Notekar-Android',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: Text('Open Link'.localized(context)),
                        onPressed: () async {
                          HapticFeedback.selectionClick();
                          try {
                            await _fileChannel.invokeMethod<void>('openUrl', {
                              'url':
                                  'https://github.com/dheeraz101/Notekar-Android',
                            });
                          } catch (_) {}
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: p.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text('Copy'.localized(context)),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Clipboard.setData(
                            const ClipboardData(
                              text:
                                  'https://github.com/dheeraz101/Notekar-Android',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Repository link copied to clipboard'.localized(
                                  context,
                                ),
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: p.text2,
                          side: BorderSide(color: p.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Benefits List
          _buildMigrationBenefitRow(
            p: p,
            icon: Icons.system_update_alt_rounded,
            title: 'Smaller, Optimized APKs'.localized(context),
            text:
                'Access split-per-ABI optimized binaries and Google Play AppBundles directly from the release page.'
                    .localized(context),
          ),
          const SizedBox(height: 16),
          _buildMigrationBenefitRow(
            p: p,
            icon: Icons.bug_report_rounded,
            title: 'Active Issue Tracking'.localized(context),
            text:
                'Submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.'
                    .localized(context),
          ),
          const SizedBox(height: 16),
          _buildMigrationBenefitRow(
            p: p,
            icon: Icons.security_rounded,
            title: 'Automated Security Scans'.localized(context),
            text:
                'All builds now undergo automated CodeQL scans and VirusTotal checks to ensure verification and safety.'
                    .localized(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMigrationBenefitRow({
    required Palette p,
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.surface3,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: p.accent, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(color: p.text2, fontSize: 12.5, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatesPermissionPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.accent.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.install_mobile_rounded,
              color: p.accent,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'In-App OTA Updates'.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To download and install software updates directly within NoteKar, please configure the following security settings:'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 28),

          // Setup Card 1: Notification Permission
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.notifications_active_rounded,
            title: 'Push Alerts & Notices'.localized(context),
            subtitle: 'Notifies you immediately when new releases are compiled.'
                .localized(context),
            isConfigured: _notificationGranted,
            buttonText: 'Grant Permission'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              final granted =
                  await _fileChannel.invokeMethod<bool>(
                    'requestNotificationPermission',
                  ) ??
                  false;
              if (granted) _checkPermissions();
            },
          ),
          const SizedBox(height: 16),

          // Setup Card 2: Install Unknown Apps
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.settings_system_daydream_rounded,
            title: 'Allow App Installation'.localized(context),
            subtitle:
                'Required by Android to launch the system package archive installer for downloaded APKs.'
                    .localized(context),
            isConfigured: _installGranted,
            buttonText: 'Configure Settings'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              await _fileChannel.invokeMethod('openInstallPermissionSettings');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRemindersPage(Palette p) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Reminders Hero Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: p.orange.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.orange.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: p.orange,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reminders & Notifications'.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule offline reminders to log your days. Android requires the following permissions to deliver alerts on time when killed:'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 28),

          // Setup Card 1: Notification Permission
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.notifications_rounded,
            title: 'Allow Notifications'.localized(context),
            subtitle: 'Required to show the logging alerts.'.localized(context),
            isConfigured: _notificationGranted,
            buttonText: 'Grant Permission'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              final granted =
                  await _fileChannel.invokeMethod<bool>(
                    'requestNotificationPermission',
                  ) ??
                  false;
              if (granted) _checkPermissions();
            },
          ),
          const SizedBox(height: 16),

          // Setup Card 2: Battery Optimization
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.battery_saver_rounded,
            title: 'Disable Battery Optimization'.localized(context),
            subtitle:
                'Ensures Android doesn\'t freeze or skip scheduled reminders.'
                    .localized(context),
            isConfigured: _batteryExempt,
            buttonText: 'Set Unrestricted'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              await _fileChannel.invokeMethod(
                'requestIgnoreBatteryOptimizations',
              );
              _checkPermissions();
            },
          ),
          const SizedBox(height: 16),

          // Setup Card 3: Auto-Start (Xiaomi/Oppo/Vivo/etc.)
          _buildPermissionSetupCard(
            p: p,
            icon: Icons.autorenew_rounded,
            title: 'Allow Auto-Start Settings'.localized(context),
            subtitle:
                'On Xiaomi, Oppo, Vivo, Samsung, or Huawei, the OS terminates killed apps unless Auto-Start is granted.'
                    .localized(context),
            isConfigured: false,
            // Cannot detect programmatically
            buttonText: 'Configure Settings'.localized(context),
            onAction: () async {
              HapticFeedback.selectionClick();
              await _fileChannel.invokeMethod('openAutoStartSettings');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPermissionSetupCard({
    required Palette p,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isConfigured,
    required String buttonText,
    required VoidCallback onAction,
  }) {
    return Glass(
      p: p,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isConfigured
                  ? p.green.withValues(alpha: 0.14)
                  : p.surface3,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConfigured ? Icons.check_rounded : icon,
              color: isConfigured ? p.green : p.text3,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                if (!isConfigured) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteFor(theme);
    final bool isLastPage = _currentPage == widget.pages.length - 1;

    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: p.text2,
                        size: 20,
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    )
                  else
                    const SizedBox(width: 48, height: 48),

                  // Skip option for first-time setup
                  if (!isLastPage && widget.pages.length > 1)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Skip'.localized(context),
                        style: TextStyle(
                          color: p.text3,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48, height: 48),
                ],
              ),
            ),

            // Sliding Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: widget.pages.length == 1
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                children: widget.pages.map((key) {
                  if (key == 'welcome') {
                    return _buildWelcomePage(p);
                  }
                  if (key == 'language') {
                    return _buildLanguagePage(p);
                  }
                  if (key == 'security') {
                    return _buildSecurityPage(p);
                  }
                  if (key == 'features') {
                    return _buildFeaturesPage(p);
                  }
                  if (key == 'app-icons') {
                    return _buildAppIconsPage(p);
                  }
                  if (key == 'numbered-singles') {
                    return _buildNumberedSinglesPage(p);
                  }
                  if (key == 'repo-move') {
                    return _buildRepoMovePage(p);
                  }
                  if (key == 'updates-permission') {
                    return _buildUpdatesPermissionPage(p);
                  }
                  if (key == 'reminders') {
                    return _buildRemindersPage(p);
                  }
                  if (key == 'network-monitor') {
                    return _buildNetworkMonitorPage(p);
                  }
                  if (key == 'sobriety') {
                    return _buildSobrietyPage(p);
                  }
                  if (key == 'mindfulness') {
                    return _buildMindfulnessPage(p);
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ),
            ),

            // Pinned Bottom Control Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  // Dot indicators
                  if (widget.pages.length > 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.pages.length, (index) {
                        final bool active = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? p.accent
                                : p.text3.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Continue / Finish Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: p.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        if (isLastPage) {
                          Navigator.pop(context);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                          );
                        }
                      },
                      child: Text(
                        isLastPage
                            ? (widget.pages.length == 1
                                  ? 'Done'.localized(context)
                                  : 'Start Logging'.localized(context))
                            : 'Continue'.localized(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
