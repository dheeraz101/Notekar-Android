import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/changelog_dialog.dart';
import 'package:notekar/dialogs/feedback_dialog.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/guide_help_rows.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.p,
    required this.theme,
    required this.defaultMode,
    required this.tapDelay,
    required this.accentColor,
    required this.appIconStyle,
    required this.hapticStyle,
    required this.historyDensity,
    required this.privacyLock,
    required this.backupReminderDays,
    required this.lastBackupAt,
    required this.remoteNotices,
    required this.reduceMotion,
    required this.largeText,
    required this.highContrast,
    required this.compactHistory,
    required this.confirmDelete,
    required this.showSeconds,
    required this.highlightSeconds,
    required this.buttonLabels,
    required this.largeControls,
    required this.homeMenuPill,
    required this.homeMenuAnimations,
    required this.showHistoryText,
    required this.showLastSavedHint,
    required this.requireLongPressNote,
    required this.extendedDuration,
    required this.minimalMomentOptions,
    required this.enableTranslucency,
    required this.privacyLockDelayMinutes,
    required this.updateStatus,
    required this.checkingUpdates,
    required this.lastUpdateCheckedAt,
    required this.entries,
    required this.lastSavedAt,
    this.blur = false,
    required this.onTheme,
    required this.onDefaultMode,
    required this.onDelay,
    required this.onAccentColor,
    required this.onAppIconStyle,
    required this.onHapticStyle,
    required this.onHistoryDensity,
    required this.onPrivacyLock,
    required this.onBackupReminderDays,
    required this.onRemoteNotices,
    required this.onReduceMotion,
    required this.onLargeText,
    required this.onHighContrast,
    required this.onCompactHistory,
    required this.onConfirmDelete,
    required this.onShowSeconds,
    required this.onHighlightSeconds,
    required this.onButtonLabels,
    required this.onLargeControls,
    required this.onHomeMenuPill,
    required this.onHomeMenuAnimations,
    required this.onShowHistoryText,
    required this.onShowLastSavedHint,
    required this.onRequireLongPressNote,
    required this.onExtendedDuration,
    required this.onMinimalMomentOptions,
    required this.onTranslucency,
    required this.onPrivacyLockDelay,
    required this.onExportCsv,
    required this.onExportRecentCsv,
    required this.onExportJson,
    required this.onExportBackup,
    required this.onImportBackup,
    required this.onCheckUpdates,
    required this.onOpenLink,
    required this.onShowChangelog,
    required this.onReset,
    required this.onFactoryReset,
    required this.onResetSettings,
    required this.onRestoreSettings,
    required this.onFeedback,
  });

  final Palette p;
  final String theme;
  final String defaultMode;
  final int tapDelay;
  final String accentColor;
  final String appIconStyle;
  final String hapticStyle;
  final String historyDensity;
  final bool privacyLock;
  final int backupReminderDays;
  final int? lastBackupAt;
  final bool remoteNotices;
  final bool reduceMotion;
  final bool largeText;
  final bool highContrast;
  final bool compactHistory;
  final bool confirmDelete;
  final bool showSeconds;
  final bool highlightSeconds;
  final bool buttonLabels;
  final bool largeControls;
  final bool homeMenuPill;
  final bool homeMenuAnimations;
  final bool showHistoryText;
  final bool showLastSavedHint;
  final bool requireLongPressNote;
  final bool extendedDuration;
  final bool minimalMomentOptions;
  final bool enableTranslucency;
  final int privacyLockDelayMinutes;
  final String updateStatus;
  final bool checkingUpdates;
  final int? lastUpdateCheckedAt;
  final List<Moment> entries;
  final int? lastSavedAt;
  final bool blur;
  final ValueChanged<String> onTheme;
  final ValueChanged<String> onDefaultMode;
  final ValueChanged<int> onDelay;
  final ValueChanged<String> onAccentColor;
  final Future<void> Function(String value) onAppIconStyle;
  final ValueChanged<String> onHapticStyle;
  final ValueChanged<String> onHistoryDensity;
  final Future<bool> Function(bool value) onPrivacyLock;
  final ValueChanged<int> onBackupReminderDays;
  final ValueChanged<bool> onRemoteNotices;
  final ValueChanged<bool> onReduceMotion;
  final ValueChanged<bool> onLargeText;
  final ValueChanged<bool> onHighContrast;
  final ValueChanged<bool> onCompactHistory;
  final ValueChanged<bool> onConfirmDelete;
  final ValueChanged<bool> onShowSeconds;
  final ValueChanged<bool> onHighlightSeconds;
  final ValueChanged<bool> onButtonLabels;
  final ValueChanged<bool> onLargeControls;
  final ValueChanged<bool> onHomeMenuPill;
  final Future<bool> Function(bool) onHomeMenuAnimations;
  final ValueChanged<bool> onShowHistoryText;
  final ValueChanged<bool> onShowLastSavedHint;
  final ValueChanged<bool> onRequireLongPressNote;
  final ValueChanged<bool> onExtendedDuration;
  final ValueChanged<bool> onMinimalMomentOptions;
  final ValueChanged<bool> onTranslucency;
  final ValueChanged<int> onPrivacyLockDelay;
  final Future<void> Function() onExportCsv;
  final Future<void> Function() onExportRecentCsv;
  final Future<void> Function() onExportJson;
  final Future<void> Function() onExportBackup;
  final Future<void> Function() onImportBackup;
  final Future<String> Function() onCheckUpdates;
  final ValueChanged<String> onOpenLink;
  final ValueChanged<bool> onShowChangelog;
  final Future<void> Function() onReset;
  final Future<void> Function() onFactoryReset;
  final Future<void> Function() onResetSettings;
  final Future<void> Function(Map<String, Object> snapshot) onRestoreSettings;
  final ValueChanged<String> onFeedback;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _BetaInfoRow extends StatelessWidget {
  const _BetaInfoRow({
    required this.p,
    required this.number,
    required this.title,
    required this.text,
  });

  final Palette p;
  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF007AFF),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontVariations: [FontVariation('wght', 700)],
              ),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontVariations: const [FontVariation('wght', 600)],
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    fontVariations: const [FontVariation('wght', 400)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsDialogState extends State<SettingsDialog> {
  late String theme;
  late String defaultMode;
  late int tapDelay;
  late String accentColor;
  late String appIconStyle;
  late String hapticStyle;
  late String historyDensity;
  late bool privacyLock;
  late int backupReminderDays;
  late bool remoteNotices;
  late bool reduceMotion;
  late bool largeText;
  late bool highContrast;
  late bool compactHistory;
  late bool confirmDelete;
  late bool showSeconds;
  late bool highlightSeconds;
  late bool buttonLabels;
  late bool largeControls;
  late bool homeMenuPill;
  late bool homeMenuAnimations;
  late bool showHistoryText;
  late bool showLastSavedHint;
  late bool requireLongPressNote;
  late bool extendedDuration;
  late bool minimalMomentOptions;
  late bool enableTranslucency;
  late int privacyLockDelayMinutes;
  late String updateStatus;
  late bool checkingUpdates;
  final List<String> _categoryStack = [];
  int _prevStackLength = 0;
  String? exportState;
  Timer? _exportStateTimer;
  final _settingsSearchController = TextEditingController();
  final _settingsSearchFocusNode = FocusNode();
  List<String> _recentSearches = [];

  final _rootScrollController = ScrollController();
  final Map<String, ScrollController> _subControllers = {};

  String _settingsQuery = '';
  List<
    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
    })
  >?
  _settingsSearchRowsCache;

  @override
  void initState() {
    super.initState();
    theme = widget.theme;
    defaultMode = widget.defaultMode;
    tapDelay = widget.tapDelay;
    accentColor = widget.accentColor;
    appIconStyle = widget.appIconStyle;
    hapticStyle = widget.hapticStyle;
    historyDensity = widget.historyDensity;
    privacyLock = widget.privacyLock;
    backupReminderDays = widget.backupReminderDays;
    remoteNotices = widget.remoteNotices;
    reduceMotion = widget.reduceMotion;
    largeText = widget.largeText;
    highContrast = widget.highContrast;
    compactHistory = widget.compactHistory;
    confirmDelete = widget.confirmDelete;
    showSeconds = widget.showSeconds;
    highlightSeconds = widget.highlightSeconds;
    buttonLabels = widget.buttonLabels;
    largeControls = widget.largeControls;
    homeMenuPill = widget.homeMenuPill;
    homeMenuAnimations = widget.homeMenuAnimations;
    showHistoryText = widget.showHistoryText;
    showLastSavedHint = widget.showLastSavedHint;
    requireLongPressNote = widget.requireLongPressNote;
    extendedDuration = widget.extendedDuration;
    minimalMomentOptions = widget.minimalMomentOptions;
    enableTranslucency = widget.enableTranslucency;
    privacyLockDelayMinutes = widget.privacyLockDelayMinutes;
    updateStatus = widget.updateStatus;
    checkingUpdates = widget.checkingUpdates;

    _loadRecentSearches();
    _settingsSearchFocusNode.addListener(() {
      if (_settingsSearchFocusNode.hasFocus && category != 'Search') {
        _openCategory('Search');
      }
    });

    _precacheIcons();
    _rebuildSearchCache();
  }

  void _rebuildSearchCache() {
    _settingsSearchRowsCache = <
          ({
            String title,
            String subtitle,
            String category,
            IconData icon,
            List<String> keywords,
          })
        >[
          (
            title: 'Display',
            subtitle: 'Theme, clock, toolbar, labels, large controls, blur',
            category: 'Display',
            icon: Icons.monitor_rounded,
            keywords: [
              'look',
              'ui',
              'color',
              'dark',
              'light',
              'amoled',
              'home',
              'translucency',
              'frosted',
              'glass',
              'interface',
            ],
          ),
          (
            title: 'Enable Translucency',
            subtitle: 'Use frosted glass blur on Toolbar and Sheets',
            category: 'Display',
            icon: Icons.opacity_rounded,
            keywords: ['blur', 'frosted', 'glass', 'glassmorphism', 'transparency', 'translucency'],
          ),
          (
            title: 'Show Seconds',
            subtitle: 'Show or hide seconds on the clock',
            category: 'Display',
            icon: Icons.more_time_rounded,
            keywords: ['clock', 'time', 'second', 'seconds'],
          ),
          (
            title: 'Highlight Seconds',
            subtitle: 'Control whether seconds use a separate clock color',
            category: 'Display',
            icon: Icons.highlight_rounded,
            keywords: ['clock', 'time', 'second', 'seconds', 'highlight'],
          ),
          (
            title: 'Button Labels',
            subtitle: 'Text-only toolbar buttons',
            category: 'Display',
            icon: Icons.label_rounded,
            keywords: ['toolbar', 'buttons', 'text', 'icons'],
          ),
          (
            title: 'Live Icon Motion',
            subtitle: 'Use gentle phone-tilt motion for home icons',
            category: 'Display',
            icon: Icons.motion_photos_auto_rounded,
            keywords: ['toolbar', 'menu', 'animation', 'motion', 'icons', 'tilt', 'sensor'],
          ),
          (
            title: 'Accent Color',
            subtitle: 'Choose the color used for buttons, highlights',
            category: 'Personalization',
            icon: Icons.palette_rounded,
            keywords: [
              'accent',
              'blue',
              'green',
              'purple',
              'pink',
              'orange',
              'graphite',
              'teal',
              'mint',
              'cyan',
              'indigo',
              'violet',
              'lavender',
              'rose',
              'coral',
              'amber',
              'sand',
              'sage',
              'olive',
              'slate',
              'brown',
              'theming',
              'style',
            ],
          ),
          (
            title: 'App Icons',
            subtitle: 'Default plus black, blue, gold, green, orange, and red',
            category: 'App Icons',
            icon: Icons.apps_rounded,
            keywords: ['icon', 'launcher', 'app icon', 'black', 'gold', 'red', 'custom icon'],
          ),
          (
            title: 'Capture',
            subtitle: 'Default mode, tap delay, and note-focused hold',
            category: 'Capture',
            icon: Icons.add_task_rounded,
            keywords: [
              'tap',
              'save',
              'mode',
              'single',
              'two way',
              'delay',
              'note',
              'long press',
              'hold',
              'logging',
            ],
          ),
          (
            title: 'Moments',
            subtitle: 'History density, confirm delete, moments, minimal actions, extended time',
            category: 'Moments',
            icon: Icons.history_rounded,
            keywords: [
              'moments',
              'logs',
              'records',
              'delete',
              'compact',
              'density',
              'minimal',
              'icons',
              'actions',
              'extended duration',
              'years',
              'months',
              'days',
              'history',
            ],
          ),
          (
            title: 'Extended Duration',
            subtitle: 'Show days, months, and years in time between moments',
            category: 'Moments',
            icon: Icons.timer_rounded,
            keywords: ['time', 'duration', 'years', 'months', 'days', 'long intervals', 'history'],
          ),
          (
            title: 'Minimal Moment Options',
            subtitle: 'Use a compact horizontal row of icons for actions',
            category: 'Moments',
            icon: Icons.auto_awesome_motion_rounded,
            keywords: ['minimal', 'icons', 'actions', 'compact', 'row', 'history'],
          ),
          (
            title: 'Updates & Notices',
            subtitle: 'Software update, app notices, changelog',
            category: 'Updates & Notices',
            icon: Icons.update_rounded,
            keywords: ['update', 'github', 'release', 'notification', 'notice', 'version', 'check'],
          ),
          (
            title: "What's New",
            subtitle: 'Latest release highlights',
            category: "What's New",
            icon: Icons.new_releases_rounded,
            keywords: ['new', 'latest', 'release', 'features', 'changelog'],
          ),
          (
            title: 'Changelog',
            subtitle: 'Release history and fixes',
            category: 'Changelog',
            icon: Icons.article_rounded,
            keywords: ['changes', 'release notes', 'version', 'history', 'log'],
          ),
          (
            title: 'Backup & Export',
            subtitle: 'CSV, JSON, download, restore, import, file, reminder, health',
            category: 'Backup & Export',
            icon: Icons.import_export_rounded,
            keywords: [
              'csv',
              'json',
              'download',
              'restore',
              'import',
              'file',
              'reminder',
              'health',
              'data',
            ],
          ),
          (
            title: 'Backup Status',
            subtitle: 'Android backup, health, encryption, and Drive plans',
            category: 'Backup Status',
            icon: Icons.cloud_done_rounded,
            keywords: [
              'android backup',
              'backup health',
              'data health',
              'encrypted backup',
              'google drive',
              'drive backup',
              'cloud',
            ],
          ),
          (
            title: 'Privacy & Security',
            subtitle: 'Local storage, network use, and data safety',
            category: 'Privacy & Security',
            icon: Icons.verified_user_rounded,
            keywords: [
              'private',
              'security',
              'safe',
              'secure',
              'encryption',
              'tracking',
              'analytics',
              'data',
              'policy',
              'drive',
              'google',
              'lock',
              'biometric',
              'password',
              'pin',
              'local',
            ],
          ),
          (
            title: 'App Lock',
            subtitle: 'Screen lock and lock timing',
            category: 'App Lock',
            icon: Icons.lock_rounded,
            keywords: [
              'privacy lock',
              'app lock',
              'screen lock',
              'biometric',
              'pin',
              'password',
              'lock timing',
              'fingerprint',
              'face id',
            ],
          ),
          (
            title: 'Accessibility',
            subtitle: 'Haptic style, motion, larger text, high contrast',
            category: 'Accessibility',
            icon: Icons.accessibility_new_rounded,
            keywords: [
              'haptic',
              'vibration',
              'motion',
              'text',
              'contrast',
              'large',
              'quick action',
              'shortcut',
              'a11y',
            ],
          ),
          (
            title: 'Diagnostics',
            subtitle: 'Version, storage, backup, update status',
            category: 'Diagnostics',
            icon: Icons.monitor_heart_rounded,
            keywords: ['debug', 'support', 'info', 'bug', 'copy', 'logs'],
          ),
          (
            title: 'Device Health',
            subtitle: 'Adaptive engine and performance status',
            category: 'Device Health',
            icon: Icons.health_and_safety_rounded,
            keywords: ['adaptive engine', 'performance', 'hardware', 'specs', 'optimization', 'tier', 'ram', 'cpu', 'cores', 'low end', 'lag'],
          ),
          (
            title: 'Reset All Data',
            subtitle: 'Erase every moment and note',
            category: 'Reset',
            icon: Icons.delete_outline_rounded,
            keywords: ['clear', 'erase', 'delete everything', 'factory reset', 'wipe'],
          ),
          (
            title: 'Factory Reset',
            subtitle: 'Erase data and settings, then show welcome',
            category: 'Reset',
            icon: Icons.restart_alt_rounded,
            keywords: ['fresh start', 'welcome', 'reset app', 'new app', 'wipe'],
          ),
          (
            title: 'Reset Settings Only',
            subtitle: 'Restore preferences and keep moments',
            category: 'Reset',
            icon: Icons.settings_backup_restore_rounded,
            keywords: ['preferences', 'defaults', 'settings reset', 'undo'],
          ),
          (
            title: 'Privacy Policy',
            subtitle: 'Data safety and local storage commitment',
            category: 'Privacy Policy',
            icon: Icons.privacy_tip_rounded,
            keywords: ['privacy', 'policy', 'data', 'safety', 'local', 'offline', 'legal'],
          ),
          (
            title: 'Licenses',
            subtitle: 'Software credits and open source legal notices',
            category: 'Licenses',
            icon: Icons.description_rounded,
            keywords: ['license', 'legal', 'credits', 'open source', 'libraries', 'packages'],
          ),
          (
            title: 'Guides',
            subtitle: 'Learn taps, notes, history, and backups',
            category: 'Help & Guides',
            icon: Icons.map_rounded,
            keywords: [
              'guide',
              'help',
              'how to',
              'tap',
              'hold',
              'long press',
              'note',
              'history',
              'duration',
              'time between',
              'backup',
              'adaptive engine',
              'minimal options',
              'tutorial',
            ],
          ),
          (
            title: 'Help',
            subtitle:
                'Fix updates, backups, notices, motion, and common issues',
            category: 'Help',
            icon: Icons.help_outline_rounded,
            keywords: [
              'help',
              'problem',
              'issue',
              'offline',
              'internet',
              'github',
              'update failed',
              'backup',
              'import',
              'notification',
              'notice',
              'sensor',
              'motion',
              'app lock',
              'data missing',
              'extended duration',
              'translucency',
              'support',
            ],
          ),
        ];
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_settings_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(_recentSearches)
      ..remove(t)
      ..insert(0, t);
    if (list.length > 5) list.removeLast();
    setState(() => _recentSearches = list);
    await prefs.setStringList('recent_settings_searches', list);
  }


  void _precacheIcons() {
    for (final icon in const [
      'icon-maskable-512.png',
      'app_icons/black.png',
      'app_icons/blue.png',
      'app_icons/gold.png',
      'app_icons/green.png',
      'app_icons/orange.png',
      'app_icons/red.png',
    ]) {
      precacheImage(AssetImage(icon), context);
    }
  }

  @override
  void dispose() {
    _exportStateTimer?.cancel();
    _settingsSearchController.dispose();
    _settingsSearchFocusNode.dispose();
    _rootScrollController.dispose();
    for (final controller in _subControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, Object> _settingsSnapshot() => {
    'theme': theme,
    'defaultMode': defaultMode,
    'tapDelay': tapDelay,
    'accentColor': accentColor,
    'appIconStyle': appIconStyle,
    'hapticStyle': hapticStyle,
    'historyDensity': historyDensity,
    'privacyLock': privacyLock,
    'backupReminderDays': backupReminderDays,
    'remoteNotices': remoteNotices,
    'reduceMotion': reduceMotion,
    'largeText': largeText,
    'highContrast': highContrast,
    'compactHistory': compactHistory,
    'confirmDelete': confirmDelete,
    'showSeconds': showSeconds,
    'highlightSeconds': highlightSeconds,
    'buttonLabels': buttonLabels,
    'largeControls': largeControls,
    'homeMenuPill': homeMenuPill,
    'homeMenuAnimations': homeMenuAnimations,
    'showHistoryText': showHistoryText,
    'showLastSavedHint': showLastSavedHint,
    'requireLongPressNote': requireLongPressNote,
    'extendedDuration': extendedDuration,
    'minimalMomentOptions': minimalMomentOptions,
    'enableTranslucency': enableTranslucency,
    'privacyLockDelayMinutes': privacyLockDelayMinutes,
  };

  String? get category => _categoryStack.isEmpty ? null : _categoryStack.last;

  ScrollController get _activeController {
    if (category == null) return _rootScrollController;
    return _subControllers.putIfAbsent(category!, () => ScrollController());
  }

  void _openCategory(String next, {String? parent}) {
    setState(() {
      _prevStackLength = _categoryStack.length;
      if (parent != null && _categoryStack.lastOrNull != parent) {
        _categoryStack
          ..clear()
          ..add(parent);
      }
      if (_categoryStack.lastOrNull != next) _categoryStack.add(next);
      _settingsQuery = '';
      _settingsSearchController.clear();
    });
  }

  bool _popCategory() {
    if (_categoryStack.isEmpty) return false;
    setState(() {
      _prevStackLength = _categoryStack.length;
      final popped = _categoryStack.removeLast();
      if (popped == 'Search') {
        _settingsQuery = '';
        _settingsSearchController.clear();
        _settingsSearchFocusNode.unfocus();
      }
    });
    return true;
  }

  Future<void> _runExport(String label, Future<void> Function() action) async {
    _exportStateTimer?.cancel();
    NotekarHaptics.selection('standard');
    setState(() => exportState = '$label exporting...');
    await action();
    if (!mounted) return;
    setState(() => exportState = '$label exported');
    _exportStateTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => exportState = null);
    });
  }

  Future<void> _runImport() async {
    _exportStateTimer?.cancel();
    NotekarHaptics.selection('standard');
    setState(() => exportState = 'Import opening...');
    try {
      await widget.onImportBackup();
      if (!mounted) return;
      setState(() => exportState = 'Import complete');
    } catch (_) {
      if (!mounted) return;
      setState(() => exportState = 'Import failed');
    }
    _exportStateTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => exportState = null);
    });
  }

  Future<void> _confirmResetSettings() async {
    final snapshot = _settingsSnapshot();
    final yes = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close reset settings',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => AppSheet(
        p: paletteFor(
          theme,
          highContrast: highContrast,
          accentName: accentColor,
        ),
        title: 'Reset Settings',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Restore NoteKar preferences to their defaults. Your moments, notes, backups, and exports stay untouched.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: paletteFor(
                  theme,
                  highContrast: highContrast,
                  accentName: accentColor,
                ).text2,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (yes == true) {
      await widget.onResetSettings();
      if (!mounted) return;
      setState(() {
        theme = 'dark';
        defaultMode = 'two-way';
        tapDelay = 0;
        accentColor = 'blue';
        appIconStyle = 'default';
        hapticStyle = 'standard';
        historyDensity = 'comfortable';
        privacyLock = false;
        backupReminderDays = 0;
        remoteNotices = false;
        reduceMotion = false;
        largeText = false;
        highContrast = false;
        compactHistory = false;
        confirmDelete = false;
        showSeconds = true;
        highlightSeconds = true;
        buttonLabels = false;
        largeControls = false;
        homeMenuPill = true;
        homeMenuAnimations = false;
        showHistoryText = true;
        showLastSavedHint = true;
        requireLongPressNote = false;
        extendedDuration = false;
        minimalMomentOptions = false;
        enableTranslucency = true;
        privacyLockDelayMinutes = 0;
      });
      await _showResetSettingsUndo(snapshot);
    }
  }

  Future<void> _showResetSettingsUndo(Map<String, Object> snapshot) async {
    final p = paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );
    final undo = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      barrierDismissible: true,
      barrierLabel: 'Close settings reset',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => AppSheet(
        p: p,
        title: 'Settings Reset',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your preferences are back to the default setup. Moments and notes were not changed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Undo'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (undo == true) {
      await widget.onRestoreSettings(snapshot);
      if (!mounted) return;
      setState(() {
        theme = snapshot['theme'] as String;
        defaultMode = snapshot['defaultMode'] as String;
        tapDelay = snapshot['tapDelay'] as int;
        accentColor = snapshot['accentColor'] as String;
        appIconStyle = snapshot['appIconStyle'] as String;
        hapticStyle = snapshot['hapticStyle'] as String;
        historyDensity = snapshot['historyDensity'] as String;
        privacyLock = snapshot['privacyLock'] as bool;
        backupReminderDays = snapshot['backupReminderDays'] as int;
        remoteNotices = snapshot['remoteNotices'] as bool;
        reduceMotion = snapshot['reduceMotion'] as bool;
        largeText = snapshot['largeText'] as bool;
        highContrast = snapshot['highContrast'] as bool;
        compactHistory = snapshot['compactHistory'] as bool;
        confirmDelete = snapshot['confirmDelete'] as bool;
        showSeconds = snapshot['showSeconds'] as bool;
        highlightSeconds = snapshot['highlightSeconds'] as bool;
        buttonLabels = snapshot['buttonLabels'] as bool;
        largeControls = snapshot['largeControls'] as bool;
        homeMenuPill = snapshot['homeMenuPill'] as bool;
        homeMenuAnimations = snapshot['homeMenuAnimations'] as bool;
        showHistoryText = snapshot['showHistoryText'] as bool;
        showLastSavedHint = snapshot['showLastSavedHint'] as bool;
        requireLongPressNote = snapshot['requireLongPressNote'] as bool;
        extendedDuration = snapshot['extendedDuration'] as bool? ?? false;
        minimalMomentOptions = snapshot['minimalMomentOptions'] as bool? ?? false;
        enableTranslucency = snapshot['enableTranslucency'] as bool? ?? true;
        privacyLockDelayMinutes = snapshot['privacyLockDelayMinutes'] as int;
      });
    }
  }

  String? get _availableVersion {
    final match = RegExp(
      r'v?(\d+(?:\.\d+){0,2}(?:\+\d+)?)',
    ).allMatches(updateStatus).lastOrNull;
    return match?.group(1);
  }

  bool get _updateAvailable {
    if (!updateStatus.toLowerCase().contains('available')) return false;
    final version = _availableVersion;
    if (version == null) return false;
    return isNewerVersion(version, appVersion);
  }

  bool get _upToDate => updateStatus.toLowerCase().contains('up to date');


  String get _updateSubtitle {
    if (_updateAvailable) return 'Install latest builds from GitHub';
    if (checkingUpdates) return 'Checking GitHub Releases...';
    if (_upToDate) return 'NoteKar is already on the latest build.';
    return 'Current version v$appVersion';
  }




  String get _dataHealthStatus {
    if (widget.entries.isEmpty) return 'Empty';
    if (widget.lastBackupAt == null) return 'Backup';
    if (backupReminderDays == 0) return 'Local';
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(widget.lastBackupAt!),
    );
    return age.inDays >= backupReminderDays ? 'Due' : 'Good';
  }

  List<
    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
    })
  >
  get _settingsSearchResults {
    final query = _settingsQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final rows = _settingsSearchRowsCache ?? [];
    return rows
        .where(
          (row) =>
              row.title.toLowerCase().contains(query) ||
              row.subtitle.toLowerCase().contains(query) ||
              row.category.toLowerCase().contains(query) ||
              row.keywords.any((keyword) => keyword.contains(query)),
        )
        .toList();
  }

  Future<void> _showBetaInfoPopup(Palette p) async {
    await showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close beta info',
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (_, _, _) => AppSheet(
        p: p,
        title: 'NoteKar Beta',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Early Access & Refinement',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontVariations: const [FontVariation('wght', 700)],
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Help shape the future of NoteKar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text2,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontVariations: const [FontVariation('wght', 500)],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _BetaInfoRow(
                    p: p,
                    number: '1',
                    title: 'Upcoming Features',
                    text: 'Explore and test new functionality before the stable release.',
                  ),
                  _BetaInfoRow(
                    p: p,
                    number: '2',
                    title: 'Active Polishing',
                    text: 'Features are functional but undergo frequent refinements.',
                  ),
                  _BetaInfoRow(
                    p: p,
                    number: '3',
                    title: 'Privacy First',
                    text: 'Even in Beta, your moments remain local and private.',
                  ),
                  _BetaInfoRow(
                    p: p,
                    number: '4',
                    title: 'Continuous Feedback',
                    text: 'Help us identify issues and polish the experience.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _deviceHealthPage(Palette p) {
    final engine = AdaptiveEngine();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (engine.isLowEnd)
          Container(
            margin: const EdgeInsets.only(bottom: spacing16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: p.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: p.red, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Limited hardware detected. Performance optimizations are active.',
                    style: TextStyle(color: p.red, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(spacing16),
          decoration: BoxDecoration(
            color: p.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.accent.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: p.accent, size: 20),
                  const SizedBox(width: spacing8),
                  Text(
                    'Adaptive Engine',
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spacing8),
              Text(
                engine.optimizationSummary,
                style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing16),
        SettingsGroup(
          p: p,
          children: [
            DiagnosticRow(
              p: p,
              label: 'Device Model',
              value: engine.model,
            ),
            DiagnosticRow(
              p: p,
              label: 'System RAM',
              value: engine.ramGb > 0 ? '${engine.ramGb} GB' : 'Unknown',
            ),
            DiagnosticRow(
              p: p,
              label: 'Performance Tier',
              value: engine.tierLabel,
            ),
            DiagnosticRow(
              p: p,
              label: 'Processors',
              value: '${engine.processors} Cores',
            ),
            DiagnosticRow(
              p: p,
              label: 'OS Version',
              value: engine.osVersion,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'The Adaptive Engine automatically tunes Notekar to your hardware (CPU, RAM, and SDK) to ensure the interface remains snappy.',
          bottomPadding: 0,
        ),
        SettingsBetaNote(
          p: p,
          text: 'The current features on this page are under Beta stage.',
          onLearnMore: () => _showBetaInfoPopup(p),
          bottomPadding: 0,
        ),
      ],
    );
  }

  Widget _licensesPage(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset('icon-maskable-512.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NoteKar',
                style: TextStyle(
                  color: p.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Version v$appVersion',
                style: TextStyle(color: p.text3, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing32),
        Text(
          'Software Licenses',
          style: TextStyle(
            color: p.text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'NoteKar is built using Flutter and several high-quality open source packages. You can view the full legal notices and individual package licenses below.',
          style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => showLicensePage(
            context: context,
            applicationName: 'NoteKar',
            applicationVersion: 'v$appVersion',
            applicationIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('icon-maskable-512.png', width: 64, height: 64),
              ),
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: p.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('View Full Licenses', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: spacing32),
      ],
    );
  }

  Widget _privacyPolicyPage(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        Text(
          'Your Privacy Matters',
          style: TextStyle(
            color: p.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: spacing12),
        Text(
          'NoteKar is designed with an "Offline-First" philosophy. We believe your personal moments and notes belong to you and only you.',
          style: TextStyle(color: p.text2, fontSize: 15, height: 1.45),
        ),
        const SizedBox(height: spacing24),
        _PolicySection(
          p: p,
          icon: Icons.storage_rounded,
          title: 'Local Storage',
          text: 'All moments and notes are stored locally on your device using an encrypted-ready database (Hive). No data is ever uploaded to a cloud server unless you manually export a backup file.',
        ),
        const SizedBox(height: spacing20),
        _PolicySection(
          p: p,
          icon: Icons.analytics_outlined,
          title: 'No Tracking',
          text: 'We do not use any third-party analytics, tracking pixels, or advertising SDKs. Your app usage remains completely anonymous and private.',
        ),
        const SizedBox(height: spacing20),
        _PolicySection(
          p: p,
          icon: Icons.wifi_rounded,
          title: 'Limited Connectivity',
          text: 'The app only uses the internet to check for software updates on GitHub and to fetch occasional app notices if enabled. No personal data is transmitted during these checks.',
        ),
        const SizedBox(height: spacing32),
      ],
    );
  }

  Widget _diagnosticsPage(Palette p, List<Moment> entries, int todayCount) {
    final latest = entries.isEmpty
        ? 'No moments yet'
        : relativeAge(
            entries.map((entry) => entry.timestamp).reduce(math.max),
          );
    final lastChecked = widget.lastUpdateCheckedAt == null
        ? 'Not checked yet'
        : relativeAge(widget.lastUpdateCheckedAt!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          p: p,
          children: [
            DiagnosticRow(
              p: p,
              label: 'App Version',
              value: 'v$appVersion ($appBuildNumber)',
            ),
            DiagnosticRow(
              p: p,
              label: 'Build Date',
              value: appBuildDate,
            ),
            DiagnosticRow(
              p: p,
              label: 'Moments',
              value: '${entries.length} total - $todayCount today',
            ),
            DiagnosticRow(
              p: p,
              label: 'Storage',
              value: 'Saved privately on this device',
            ),
            DiagnosticRow(
              p: p,
              label: 'Android Backup',
              value: 'Enabled for system transfer and Google backup',
            ),
            DiagnosticRow(p: p, label: 'Updates', value: _updateSubtitle),
            DiagnosticRow(p: p, label: 'Last Update Check', value: lastChecked),
            DiagnosticRow(
              p: p,
              label: 'App Notices',
              value: remoteNotices ? 'Enabled' : 'Disabled',
            ),
            DiagnosticRow(p: p, label: 'Last Moment', value: latest),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: p.accent,
            minimumSize: const Size.fromHeight(44),
          ),
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: _diagnosticsText(entries, todayCount, latest),
              ),
            );
            widget.onFeedback('Diagnostics copied');
          },
          child: const Text('Copy Diagnostics'),
        ),
      ],
    );
  }

  String _diagnosticsText(List<Moment> entries, int todayCount, String latest) {
    final logs = AppLogger().diagnosticLogs;
    return [
      'NoteKar diagnostics',
      'Version: v$appVersion ($appBuildNumber)',
      'Build date: $appBuildDate',
      'Moments: ${entries.length} total, $todayCount today',
      'Storage: local offline storage',
      'Android backup: configured',
      'Updates: $_updateSubtitle',
      'Last update check: ${widget.lastUpdateCheckedAt == null ? 'Not checked yet' : relativeAge(widget.lastUpdateCheckedAt!)}',
      'App notices: ${remoteNotices ? 'Enabled' : 'Disabled'}',
      'Last moment: $latest',
      '',
      'Internal Logs:',
      logs.isEmpty ? 'No internal logs available' : logs,
    ].join('\n');
  }

  Widget _appLockPage(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              icon: Icons.lock_rounded,
              title: 'App Lock',
              color: p.accent,
              value: privacyLock,
              onChanged: (value) async {
                if (!value) {
                  await widget.onPrivacyLock(false);
                  if (mounted) setState(() => privacyLock = false);
                  return;
                }
                final changed = await widget.onPrivacyLock(true);
                if (changed && mounted) {
                  setState(() => privacyLock = true);
                }
              },
            ),
          ],
        ),
        if (privacyLock) ...[
          const SizedBox(height: 10),
          SegmentedSetting(
            key: ValueKey('privacy-delay-$privacyLockDelayMinutes-${p.name}'),
            p: p,
            title: 'When to Lock (minutes)',
            value: '$privacyLockDelayMinutes',
            blur: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur,
            values: const {'0': 'Now', '1': '1', '5': '5', '10': '10'},
            status: privacyLockDelayLabel(privacyLockDelayMinutes),
            onChanged: (value) {
              final minutes = int.tryParse(value) ?? 0;
              if (minutes == privacyLockDelayMinutes) return;
              HapticFeedback.selectionClick();
              setState(() => privacyLockDelayMinutes = minutes);
              widget.onPrivacyLockDelay(minutes);
            },
          ),
        ],
        SettingsPageNote(
          p: p,
          text:
              'App Lock uses your Android screen lock. With Now selected, Recents and the notification panel are treated as leaving NoteKar, so the overlay hides your page before you return.',
        ),
      ],
    );
  }

  Widget _appIconsPage(Palette p) {
    const icons = {
      'default': ('Default', 'icon-maskable-512.png'),
      'black': ('Black', 'app_icons/black.png'),
      'blue': ('Blue', 'app_icons/blue.png'),
      'gold': ('Gold', 'app_icons/gold.png'),
      'green': ('Green', 'app_icons/green.png'),
      'orange': ('Orange', 'app_icons/orange.png'),
      'red': ('Red', 'app_icons/red.png'),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing12),
        SizedBox(
          height: 125, // Gallery height
          child: RepaintBoundary(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: spacing16),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                final entry = icons.entries.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: AppIconChoice(
                    p: p,
                    label: entry.value.$1,
                    asset: entry.value.$2,
                    active: appIconStyle == entry.key,
                    onTap: () {
                      if (entry.key == appIconStyle) return;
                      NotekarHaptics.selection('standard');
                      setState(() => appIconStyle = entry.key);
                      unawaited(widget.onAppIconStyle(entry.key));
                    },
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: spacing4), // Minimum space for iOS look
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacing16),
          child: SettingsPageDescription(
            p: p,
            text:
                'App Icons change the Android launcher icon. Note: Some launchers may take a few seconds to update.',
          ),
        ),
      ],
    );
  }

  Future<void> _confirmResetAll(Palette p) async {
    final yes = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close reset',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ResetAllConfirmSheet(
        p: p,
        title: 'Reset All Data',
        message:
            'This deletes every saved moment and note from this device. Settings stay the same. Export or create a backup first if you may need this history later. Type RESET to continue.',
      ),
    );
    if (yes == true) {
      await widget.onReset();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _confirmFactoryReset(Palette p) async {
    final yes = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close factory reset',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ResetAllConfirmSheet(
        p: p,
        title: 'Factory Reset',
        message:
            'This returns NoteKar to a fresh local state by deleting moments, notes, and settings. Export or create a backup first if there is anything you may need later. Type RESET to continue.',
      ),
    );
    if (yes == true) {
      if (mounted) Navigator.pop(context);
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 220), () {
          widget.onFactoryReset();
        }),
      );
    }
  }

  void _openFeedback() {
    showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close feedback',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => FeedbackDialog(
        p: paletteFor(
          theme,
          highContrast: highContrast,
          accentName: accentColor,
        ),
        onOpenLink: widget.onOpenLink,
        blur: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur,
      ),
    );
  }

  Widget _updateCenterPage(Palette p) {
    final availableVersion = _availableVersion;
    final updateAvailable = _updateAvailable;
    final upToDate = _upToDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing24),
        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset('icon-maskable-512.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: spacing20),
              Text(
                'NoteKar',
                style: TextStyle(
                  color: p.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version v$appVersion',
                style: TextStyle(
                  color: p.text3,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing48),
        if (checkingUpdates) ...[
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: p.accent,
                  ),
                ),
                const SizedBox(height: spacing16),
                Text(
                  'Checking for updates...',
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ] else if (updateAvailable) ...[
          Container(
            padding: const EdgeInsets.all(spacing20),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.accent.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.download_rounded, color: p.accent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Update Available',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Version v$availableVersion is now available. This update includes new features, performance improvements, and bug fixes.',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: spacing24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: p.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => widget.onOpenLink(githubReleases),
            child: const Text(
              'Download from GitHub',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ] else if (upToDate) ...[
          Center(
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: p.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, color: p.green, size: 32),
                ),
                const SizedBox(height: spacing16),
                Text(
                  'NoteKar is up to date',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last checked: ${widget.lastUpdateCheckedAt == null ? 'Just now' : relativeAge(widget.lastUpdateCheckedAt!)}',
                  style: TextStyle(color: p.text3, fontSize: 13),
                ),
              ],
            ),
          ),
        ] else ...[
          Center(
            child: Text(
              'Check for the latest features and fixes.',
              style: TextStyle(color: p.text2, fontSize: 14),
            ),
          ),
        ],
        const Spacer(),
        if (!checkingUpdates && !updateAvailable)
          Padding(
            padding: const EdgeInsets.only(bottom: spacing16),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: p.accent,
                minimumSize: const Size.fromHeight(56),
                side: BorderSide(color: p.accent.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                setState(() {
                  checkingUpdates = true;
                  updateStatus = 'Checking for updates...';
                });
                final status = await widget.onCheckUpdates();
                if (mounted) {
                  setState(() {
                    updateStatus = status;
                    checkingUpdates = false;
                  });
                }
              },
              child: const Text(
                'Check for Update',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        SettingsPageDescription(
          p: p,
          text: 'NoteKar is open source. You can always find the latest builds and source code on GitHub.',
          bottomPadding: 0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );
    final entries = widget.entries;
    final today = dateKey(DateTime.now());
    final todayCount = entries.where((e) => e.date == today).length;
    final delayIndex = delayValues.indexOf(tapDelay);
    final engine = AdaptiveEngine();
    bool show(String name) => category == name;
    final sheet = PopScope(
      canPop: _categoryStack.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _popCategory();
      },
      child: AppSheet(
        p: p,
        title: category ?? 'Settings',
        onBack: category != null ? _popCategory : null,
        docked: true,
        blur: !reduceMotion && enableTranslucency && engine.supportsBlur,
        largeText: widget.largeText,
        controller: _activeController,
        showLargeTitle: category == null,
        child: SizedBox(
          width: 410,
          height: math.min(MediaQuery.sizeOf(context).height * 0.75, 680),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: engine.isLowEnd ? 180 : 280),
            reverseDuration: Duration(milliseconds: engine.isLowEnd ? 140 : 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              if (engine.isLowEnd) {
                return FadeTransition(opacity: animation, child: child);
              }
              final forward = _categoryStack.length >= _prevStackLength;
              final begin = Offset(forward ? 0.25 : -0.25, 0.0);
              final slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(animation);
              final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
              
              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: RepaintBoundary(
              child: CustomScrollView(
                key: ValueKey(category ?? 'root'),
                controller: _activeController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
              if (category == null) ...[
                SliverToBoxAdapter(
                  child: AppSheetLargeTitle(
                    p: p,
                    title: 'Settings',
                    scrollController: _activeController,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverStickyHeaderDelegate(
                    height: 64,
                    child: Container(
                      color: p.surface.withValues(
                        alpha: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur ? 0.65 : 1.0,
                      ),
                      padding: const EdgeInsets.only(bottom: spacing8),
                      child: SettingsSearchBox(
                        p: p,
                        controller: _settingsSearchController,
                        focusNode: _settingsSearchFocusNode,
                        onChanged: (value) {
                          setState(() => _settingsQuery = value);
                          if (_activeController.hasClients) {
                            _activeController.jumpTo(0.0);
                          }
                        },
                        onClear: () {
                          setState(() {
                            _settingsQuery = '';
                            _settingsSearchController.clear();
                          });
                          if (_activeController.hasClients) {
                            _activeController.jumpTo(0.0);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                      SettingsGroup(
                        p: p,
                        children: [
                          SettingsRow(
                            p: p,
                            icon: Icons.brush_rounded,
                            title: 'Personalization',
                            color: p.accent,
                            onTap: () => _openCategory('Personalization'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.bolt_rounded,
                            title: 'Logging',
                            color: p.green,
                            onTap: () => _openCategory('Logging'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.verified_user_rounded,
                            title: 'Privacy & Security',
                            color: p.green,
                            onTap: () => _openCategory('Privacy & Security'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.storage_rounded,
                            title: 'Data & Backup',
                            color: p.green,
                            onTap: () => _openCategory('Data & Backup'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.update_rounded,
                            title: 'Updates & Notices',
                            color: p.accent,
                            onTap: () => _openCategory('Updates & Notices'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.auto_stories_rounded,
                            title: 'Help & Guides',
                            color: p.accent,
                            onTap: () => _openCategory('Help & Guides'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.settings_suggest_rounded,
                            title: 'Advanced',
                            color: p.orange,
                            onTap: () => _openCategory('Advanced'),
                          ),
                        ],
                      ),
                      const SizedBox(height: spacing16),
                      SettingsGroup(
                        p: p,
                        title: 'Support & Community',
                        children: [
                          SettingsRow(
                            p: p,
                            icon: Icons.coffee_rounded,
                            title: 'Buy me a Coffee',
                            color: const Color(0xFFFFDD00),
                            onTap: () => widget.onOpenLink(coffeeLink),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.feedback_rounded,
                            title: 'Feedback',
                            color: p.green,
                            onTap: _openFeedback,
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.code_rounded,
                            title: 'GitHub',
                            color: p.text,
                            onTap: () => widget.onOpenLink(githubRepo),
                          ),
                        ],
                      ),
                      SettingsPageDescription(
                        p: p,
                        text: 'Personalize and configure NoteKar to fit your workflow.',
                      ),
                      const SizedBox(height: spacing24),
                      SettingsAboutBlock(p: p),
                      const SizedBox(height: spacing64),
                    ],
                  ),
                ),
              ],
              if (show('Search')) ...[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverStickyHeaderDelegate(
                    height: 64,
                    child: Container(
                      color: p.surface.withValues(
                        alpha: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur ? 0.65 : 1.0,
                      ),
                      padding: const EdgeInsets.only(bottom: spacing8),
                      child: SettingsSearchBox(
                        p: p,
                        controller: _settingsSearchController,
                        focusNode: _settingsSearchFocusNode,
                        onChanged: (value) {
                          setState(() => _settingsQuery = value);
                          if (_activeController.hasClients) {
                            _activeController.jumpTo(0.0);
                          }
                        },
                        onClear: () {
                          setState(() {
                            _settingsQuery = '';
                            _settingsSearchController.clear();
                          });
                          if (_activeController.hasClients) {
                            _activeController.jumpTo(0.0);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    if (_settingsQuery.trim().isEmpty && _recentSearches.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'RECENT SEARCHES',
                              style: TextStyle(color: p.text3, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.remove('recent_settings_searches');
                                setState(() => _recentSearches = []);
                              },
                              child: Text('Clear', style: TextStyle(color: p.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      SettingsGroup(
                        p: p,
                        children: [
                          for (final term in _recentSearches)
                            SettingsRow(
                              p: p,
                              icon: Icons.history_rounded,
                              title: term,
                              color: p.text3,
                              onTap: () {
                                _settingsSearchController.text = term;
                                setState(() => _settingsQuery = term);
                                _saveRecentSearch(term);
                              },
                            ),
                        ],
                      ),
                    ] else if (_settingsQuery.trim().isNotEmpty) ...[
                      SettingsGroup(
                        p: p,
                        children: [
                          for (final result in _settingsSearchResults)
                            SettingsRow(
                              p: p,
                              icon: result.icon,
                              title: result.title,
                              highlight: _settingsQuery,
                              color: result.title == 'Reset All Data' || result.title == 'Factory Reset' ? p.red : p.accent,
                              onTap: () {
                                _saveRecentSearch(result.title);
                                if (result.title == 'Reset All Data') {
                                  unawaited(_confirmResetAll(p));
                                  return;
                                }
                                if (result.title == 'Factory Reset') {
                                  unawaited(_confirmFactoryReset(p));
                                  return;
                                }
                                if (result.title == 'Reset Settings Only') {
                                  unawaited(_confirmResetSettings());
                                  return;
                                }
                                _openCategory(result.category);
                              },
                            ),
                          if (_settingsSearchResults.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 64),
                              child: HIGEmptyState(
                                p: p,
                                icon: Icons.search_off_rounded,
                                title: 'No Results',
                                message: 'No settings match "${_settingsQuery.trim()}". Try different keywords or check your spelling.',
                                compact: true,
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: spacing64),
                  ]),
                ),
              ],
              if (show('Personalization'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Customize the look and feel of NoteKar.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.monitor_rounded,
                          title: 'Display',
                          status: theme[0].toUpperCase() + theme.substring(1),
                          color: p.accent,
                          onTap: () => _openCategory('Display', parent: 'Personalization'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.palette_rounded,
                          title: 'Accent Color',
                          status: accentColor[0].toUpperCase() + accentColor.substring(1),
                          color: p.accent,
                          onTap: () => _openCategory('Accent Color', parent: 'Personalization'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.apps_rounded,
                          title: 'App Icons',
                          status: appIconStyle[0].toUpperCase() + appIconStyle.substring(1),
                          color: p.accent,
                          onTap: () => _openCategory('App Icons', parent: 'Personalization'),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Personalization changes the interface only and does not affect your saved moments.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Display'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Manage themes, the clock, and interface behavior.',
                    ),
                    SettingsGroup(
                      p: p,
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
                                  color: const Color(0xFF1C1C1E), // Deep gray circle
                                  onTap: () {
                                    if (theme == 'dark') return;
                                    HapticFeedback.selectionClick();
                                    setState(() => theme = 'dark');
                                    widget.onTheme('dark');
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
                                    setState(() => theme = 'light');
                                    widget.onTheme('light');
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ThemeChoice(
                                  p: p,
                                  label: 'AMOLED',
                                  active: theme == 'amoled',
                                  color: const Color(0xFF000000), // True black circle
                                  onTap: () {
                                    if (theme == 'amoled') return;
                                    HapticFeedback.selectionClick();
                                    setState(() => theme = 'amoled');
                                    widget.onTheme('amoled');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.more_time_rounded,
                          title: 'Show Seconds',
                          color: p.accent,
                          value: showSeconds,
                          onChanged: (value) {
                            setState(() => showSeconds = value);
                            widget.onShowSeconds(value);
                          },
                        ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.highlight_rounded,
                          title: 'Highlight Seconds',
                          color: p.accent,
                          value: showSeconds && highlightSeconds,
                          enabled: showSeconds,
                          disabledMessage: 'Enable Show Seconds first',
                          onDisabledTap: widget.onFeedback,
                          onChanged: (value) {
                            if (!showSeconds) return;
                            setState(() => highlightSeconds = value);
                            widget.onHighlightSeconds(value);
                          },
                        ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.label_rounded,
                          title: 'Button Labels',
                          color: p.green,
                          value: buttonLabels,
                          onChanged: (value) {
                            setState(() => buttonLabels = value);
                            widget.onButtonLabels(value);
                          },
                        ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.ads_click_rounded,
                          title: 'Large Controls',
                          color: p.orange,
                          value: largeControls,
                          onChanged: (value) {
                            setState(() => largeControls = value);
                            widget.onLargeControls(value);
                          },
                        ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.shape_line_rounded,
                          title: 'Toolbar Backplate',
                          color: p.accent,
                          value: homeMenuPill,
                          onChanged: (value) {
                            setState(() => homeMenuPill = value);
                            widget.onHomeMenuPill(value);
                          },
                        ),
                        if (AdaptiveEngine().supportsAdvancedAnimations)
                          SettingsSwitchRow(
                            p: p,
                            icon: Icons.motion_photos_auto_rounded,
                            title: 'Live Icon Motion',
                            color: p.accent,
                            value: !reduceMotion && homeMenuAnimations,
                            enabled: !reduceMotion,
                            disabledMessage: 'Disable Reduce Motion first',
                            onDisabledTap: widget.onFeedback,
                            onChanged: (value) async {
                              if (reduceMotion) return;
                              final applied = await widget.onHomeMenuAnimations(value);
                              if (!mounted) return;
                              setState(() {
                                homeMenuAnimations = applied ? value : false;
                              });
                            },
                          ),
                        if (AdaptiveEngine().supportsBlur)
                          SettingsSwitchRow(
                            p: p,
                            icon: Icons.opacity_rounded,
                            title: 'Enable Translucency',
                            color: p.accent,
                            value: !reduceMotion && enableTranslucency,
                            enabled: !reduceMotion,
                            onDisabledTap: widget.onFeedback,
                            onChanged: (value) {
                              setState(() => enableTranslucency = value);
                              widget.onTranslucency(value);
                            },
                          ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.format_list_bulleted_rounded,
                          title: 'History Text',
                          color: p.green,
                          value: showHistoryText,
                          onChanged: (value) {
                            setState(() => showHistoryText = value);
                            widget.onShowHistoryText(value);
                          },
                        ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.tips_and_updates_rounded,
                          title: 'Last Saved Hint',
                          color: p.accent,
                          value: showLastSavedHint,
                          onChanged: (value) {
                            setState(() => showLastSavedHint = value);
                            widget.onShowLastSavedHint(value);
                          },
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Effects like Translucency and Live Icon Motion are automatically disabled when Reduced Motion is active to ensure the interface remains stable and responsive.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Accent Color'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Choose the color used for buttons, highlights, and save feedback.',
                    ),
                    ColorChoiceSetting(
                      p: p,
                      title: 'Accent Color',
                      value: accentColor,
                      blur: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur,
                      onChanged: (value) {
                        if (value == accentColor) return;
                        HapticFeedback.selectionClick();
                        setState(() => accentColor = value);
                        widget.onAccentColor(value);
                      },
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'This color changes the app interface only and does not categorize your saved moments.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('App Icons'))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      SettingsPageSubtitle(
                        p: p,
                        text: 'Choose the icon that appears on your Android launcher.',
                      ),
                      _appIconsPage(p),
                      const SizedBox(height: spacing64),
                    ],
                  ),
                ),
              if (show('Logging'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Configure how you capture moments and review your history.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.add_task_rounded,
                          title: 'Capture',
                          status: defaultMode == 'single' ? 'Single' : 'Two-Way',
                          color: p.green,
                          onTap: () => _openCategory('Capture', parent: 'Logging'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.history_rounded,
                          title: 'Moments',
                          status: '${entries.length} Logs',
                          color: p.orange,
                          onTap: () => _openCategory('Moments', parent: 'Logging'),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Logging settings control the "capture-to-history" pipeline and how saved moments are reviewable across devices.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Capture'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Fine-tune the behavior of home screen taps and holds.',
                    ),
                    SegmentedSetting(
                      key: ValueKey('mode-$defaultMode-${p.name}'),
                      p: p,
                      title: 'Startup Mode',
                      value: defaultMode,
                      blur: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur,
                      values: const {'single': 'Single', 'two-way': 'Two-Way'},
                      onChanged: (value) {
                        if (value == defaultMode) return;
                        HapticFeedback.selectionClick();
                        setState(() => defaultMode = value);
                        widget.onDefaultMode(value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Glass(
                      p: p,
                      radius: 12,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text('Tap Delay', style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 15)),
                              ),
                              const SizedBox(width: 10),
                              Text(delayLabel(tapDelay), style: TextStyle(color: p.text2, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              DelayStepButton(
                                key: ValueKey('delay-minus-$tapDelay-${p.name}'),
                                p: p,
                                icon: Icons.remove_rounded,
                                enabled: (delayIndex < 0 ? 0 : delayIndex) > 0,
                                blur: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur,
                                onTap: () {
                                  final current = delayIndex < 0 ? 0 : delayIndex;
                                  final next = delayValues[math.max(0, current - 1)];
                                  NotekarHaptics.selection('standard');
                                  setState(() => tapDelay = next);
                                  widget.onDelay(next);
                                },
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderThemeData(activeTrackColor: p.accent, inactiveTrackColor: p.surface3, thumbColor: Colors.white, overlayColor: p.accent.withValues(alpha: 0.12), trackHeight: 5, tickMarkShape: SliderTickMarkShape.noTickMark),
                                      child: Slider(
                                        key: ValueKey('delay-slider-$tapDelay-${p.name}'),
                                        min: 0, max: 6, divisions: 6,
                                        value: (delayIndex < 0 ? 0 : delayIndex).toDouble(),
                                        onChanged: (value) {
                                          final next = delayValues[value.round()];
                                          if (next == tapDelay) return;
                                          NotekarHaptics.selection('standard');
                                          setState(() => tapDelay = next);
                                          widget.onDelay(next);
                                        },
                                      ),
                                    ),
                                    Transform.translate(offset: const Offset(0, -4), child: SliderScale(p: p, activeValue: tapDelay)),
                                  ],
                                ),
                              ),
                              DelayStepButton(
                                key: ValueKey('delay-plus-$tapDelay-${p.name}'),
                                p: p,
                                icon: Icons.add_rounded,
                                enabled: (delayIndex < 0 ? 0 : delayIndex) < delayValues.length - 1,
                                blur: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur,
                                onTap: () {
                                  final current = delayIndex < 0 ? 0 : delayIndex;
                                  final next = delayValues[math.min(delayValues.length - 1, current + 1)];
                                  NotekarHaptics.selection('standard');
                                  setState(() => tapDelay = next);
                                  widget.onDelay(next);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.edit_note_rounded,
                          title: 'Require Note on Hold',
                          color: p.orange,
                          value: requireLongPressNote,
                          onChanged: (value) {
                            setState(() => requireLongPressNote = value);
                            widget.onRequireLongPressNote(value);
                          },
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Tap Delay prevents accidental double-taps, while Require Note on Hold ensures contexts are always saved for moments captured via long-press.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Moments'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Manage your history layout and review saved moments.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.view_agenda_rounded,
                          title: 'Compact History',
                          color: p.accent,
                          value: compactHistory,
                          onChanged: (value) {
                            setState(() {
                              compactHistory = value;
                              historyDensity = value ? 'compact' : 'comfortable';
                            });
                            widget.onCompactHistory(value);
                            widget.onHistoryDensity(historyDensity);
                          },
                        ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.delete_sweep_rounded,
                          title: 'Confirm Delete',
                          color: p.red,
                          value: confirmDelete,
                          onChanged: (value) {
                            setState(() => confirmDelete = value);
                            widget.onConfirmDelete(value);
                          },
                        ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.timer_rounded,
                          title: 'Extended Duration',
                          color: p.accent,
                          value: extendedDuration,
                          onChanged: (value) {
                            setState(() => extendedDuration = value);
                            widget.onExtendedDuration(value);
                          },
                        ),
                        SettingsSwitchRow(
                          p: p,
                          icon: Icons.auto_awesome_motion_rounded,
                          title: 'Minimal Moment Options',
                          color: p.accent,
                          value: minimalMomentOptions,
                          onChanged: (value) {
                            setState(() => minimalMomentOptions = value);
                            widget.onMinimalMomentOptions(value);
                          },
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.insights_rounded,
                          title: 'Review Logs',
                          status: '$todayCount Today',
                          color: p.orange,
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.search_rounded,
                          title: 'Search Notes',
                          color: p.accent,
                          status: '${entries.where((e) => e.note.isNotEmpty).length} Notes',
                          onTap: () => _openCategory('Search Notes', parent: 'Moments'),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Compact History uses denser rows for faster scanning, and Extended Duration shows years, months, and days in the time intervals between logs.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Search Notes')) ...[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverStickyHeaderDelegate(
                    height: 80,
                    child: Container(
                      color: p.surface.withValues(
                        alpha: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur ? 0.65 : 1.0,
                      ),
                      padding: const EdgeInsets.fromLTRB(spacing16, spacing8, spacing16, spacing12),
                      child: SearchNotesBox(
                        p: p,
                        controller: _settingsSearchController,
                        onChanged: (value) => setState(() => _settingsQuery = value),
                        onClear: () => setState(() {
                          _settingsSearchController.clear();
                          _settingsQuery = '';
                        }),
                      ),
                    ),
                  ),
                ),
                if (_settingsQuery.trim().isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            'ALL NOTES',
                            style: TextStyle(
                              color: p.text3,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${entries.where((e) => e.note.isNotEmpty).length} items',
                            style: TextStyle(
                              color: p.text3,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ...() {
                  final notes = entries
                      .where((e) => e.note.isNotEmpty)
                      .where((e) {
                        final q = _settingsQuery.trim().toLowerCase();
                        if (q.isEmpty) return true;
                        return e.note.toLowerCase().contains(q) ||
                               datePretty(e.timestamp).contains(q) ||
                               timeOnly(e.timestamp).contains(q);
                      })
                      .toList();

                  if (notes.isEmpty) {
                    return [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 48),
                          child: HIGEmptyState(
                            p: p,
                            icon: Icons.speaker_notes_off_rounded,
                            title: 'No Notes Found',
                            message: _settingsQuery.isEmpty 
                                ? 'Capture your first note by holding the clock.' 
                                : 'No notes match "${_settingsQuery.trim()}".',
                            compact: true,
                          ),
                        ),
                      )
                    ];
                  }

                  return [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(spacing16, spacing4, spacing16, spacing64),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= notes.length) return null;
                            final entry = notes[index];

                            return Padding(
                              padding: EdgeInsets.only(bottom: compactHistory ? 10 : 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(spacing16),
                                decoration: BoxDecoration(
                                  color: p.surface2,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: p.border.withValues(alpha: 0.6),
                                    width: 0.8,
                                  ),
                                  boxShadow: p.name == 'amoled'
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: momentColor(p, entry.type)
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            entry.type.toUpperCase(),
                                            style: TextStyle(
                                              color: momentColor(p, entry.type),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '${datePretty(entry.timestamp)} • ${timeOnly(entry.timestamp)}',
                                            style: TextStyle(
                                              color: p.text3,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures()
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      entry.note,
                                      style: TextStyle(
                                        color: p.text,
                                        fontSize: 16,
                                        height: 1.45,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: notes.length,
                        ),
                      ),
                    ),
                  ];
                }(),
              ],
              if (show('Guides'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Step-by-step guides for mastering NoteKar.',
                    ),
                    SettingsGroup(
                      p: p,
                      showDividers: true,
                      children: [
                        GuideRow(p: p, icon: Icons.touch_app_rounded, title: 'Save a Moment', text: 'Tap the home screen once to save the current time.'),
                        GuideRow(p: p, icon: Icons.compare_arrows_rounded, title: 'Two-Way Mode', text: 'First tap saves In. The next tap saves Out and completes the pair.'),
                        GuideRow(p: p, icon: Icons.radio_button_checked_rounded, title: 'Single Mode', text: 'Every tap saves one standalone moment.'),
                        GuideRow(p: p, icon: Icons.note_add_rounded, title: 'Add a Note', text: 'Touch and hold the home screen to write a note before saving.'),
                        GuideRow(p: p, icon: Icons.history_rounded, title: 'Review History', text: 'Open History to review moments, use Select Date for a calendar day, or filter by Today and This Week.'),
                        GuideRow(p: p, icon: Icons.search_rounded, title: 'Search Notes', text: 'Open Settings, then Logging, Moments, Search Notes to find note text by words, date, or time.'),
                        GuideRow(p: p, icon: Icons.timer_rounded, title: 'Time Between Moments', text: 'Select one moment, then another, to calculate the time between them.'),
                        GuideRow(p: p, icon: Icons.subject_rounded, title: 'Manage Moment Notes', text: 'Touch and hold any history moment to add, read, edit, or delete its note.'),
                        GuideRow(p: p, icon: Icons.lock_rounded, title: 'App Lock Timing', text: 'App Lock uses your biometric or PIN. Immediate lock covers NoteKar in Recents or background.'),
                        GuideRow(p: p, icon: Icons.auto_awesome_motion_rounded, title: 'Minimal Moment Options', text: 'Enable in Settings > Logging > Moments to use a fast, icon-only row for editing and deleting.'),
                        GuideRow(p: p, icon: Icons.auto_awesome_rounded, title: 'Adaptive Engine', text: 'Notekar automatically tunes visual effects to your CPU, RAM, and SDK. Check stats in Advanced > Device Health.'),
                        GuideRow(p: p, icon: Icons.backup_rounded, title: 'Back Up Data', text: 'Export a JSON backup before resetting, changing phones, or testing a new build.'),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'NoteKar stores moments privately on this device. Backups are files you control.'),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Help'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Common questions and troubleshooting steps.',
                    ),
                    SettingsGroup(
                      p: p,
                      showDividers: true,
                      children: [
                        HelpRow(p: p, question: 'Update check failed', answer: 'First confirm that your phone is connected to the internet. If other websites work, GitHub may be unavailable or limiting requests. Wait a few minutes and try again.'),
                        HelpRow(p: p, question: 'App Notices are not appearing', answer: 'Confirm App Notices are enabled and Android notification permission is allowed. Battery restrictions or background limits may delay checks. Opening NoteKar while online also triggers a notice check.'),
                        HelpRow(p: p, question: 'NoteKar is offline', answer: 'Logging, History, notes, settings, and local backups work without internet. Only update checks, external links, and App Notices require a connection.'),
                        HelpRow(p: p, question: 'Backup import found no new moments', answer: 'The backup was read correctly, but its moments already exist on this device. NoteKar skips duplicates instead of adding them again.'),
                        HelpRow(p: p, question: 'Backup import failed', answer: 'Make sure you selected a NoteKar JSON backup that was not renamed, manually edited, or damaged. Try exporting a fresh backup.'),
                        HelpRow(p: p, question: 'Live Icon Motion will not turn on', answer: 'Turn off Reduced Motion first. If NoteKar reports that the motion sensor is unavailable, the phone does not provide a usable accelerometer stream or your hardware tier is set to Power Saver.'),
                        HelpRow(p: p, question: 'Live Icon Motion looks slow or delayed', answer: 'The movement is intentionally smoothed to prevent jitter. Lower-end phones may also reduce animation performance automatically based on CPU and RAM stats.'),
                        HelpRow(p: p, question: 'App Lock will not turn on', answer: 'Add a biometric or PIN/Pattern lock in Android settings, then try again. NoteKar uses your system credentials for maximum security.'),
                        HelpRow(p: p, question: 'App Lock appears after the notification panel', answer: 'If App Lock is set to Immediately, opening Recents or pulling down the notification panel counts as leaving NoteKar. This ensures your moments stay hidden.'),
                        HelpRow(p: p, question: 'The app icon did not change immediately', answer: 'Some Android launchers cache icons. Return to the home screen, wait briefly, or restart the launcher or phone.'),
                        HelpRow(p: p, question: 'A moment was saved accidentally', answer: 'Use Undo immediately after saving, or remove it from History. You can enable Confirm Delete for extra protection.'),
                        HelpRow(p: p, question: 'My data disappeared after clearing app storage', answer: 'NoteKar stores data locally. Clearing Android app storage deletes that local data. Restore it using a backup file if one was exported earlier.'),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'NoteKar is offline-first. Internet-related failures should never block logging or access to saved history.'),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Update Center'))
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: spacing20),
                    child: _updateCenterPage(p),
                  ),
                ),
              if (show('Updates & Notices'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Keep NoteKar up to date with the latest features and fixes.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.system_update_rounded,
                          title: 'Software Update',
                          color: p.accent,
                          status: 'v$appVersion',
                          onTap: () => _openCategory('Update Center', parent: 'Updates & Notices'),
                        ),
                        SettingsSwitchRow(p: p, icon: Icons.notifications_active_rounded, title: 'App Notices', color: p.accent, value: remoteNotices, onChanged: (value) { setState(() => remoteNotices = value); widget.onRemoteNotices(value); }),
                        SettingsRow(p: p, icon: Icons.new_releases_rounded, title: "What's New", color: p.orange, status: 'Recent', onTap: () => _openCategory("What's New", parent: 'Updates & Notices')),
                        SettingsRow(p: p, icon: Icons.article_rounded, title: 'Changelog', color: p.green, status: 'History', onTap: () => _openCategory('Changelog', parent: 'Updates & Notices')),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'NoteKar checks GitHub for new releases. App Notices provide occasional updates about new announcements.',
                      bottomPadding: 0,
                    ),
                    SettingsBetaNote(
                      p: p,
                      text: 'The current features on this page are under Beta stage.',
                      onLearnMore: () => _showBetaInfoPopup(p),
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Data & Backup'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Manage how your moments are exported, imported, and protected.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(p: p, icon: Icons.import_export_rounded, title: 'Backup & Export', status: '${entries.length} Logs', color: p.green, onTap: () => _openCategory('Backup & Export', parent: 'Data & Backup')),
                        SettingsRow(p: p, icon: Icons.cloud_done_rounded, title: 'Backup Status', status: _dataHealthStatus, color: p.accent, onTap: () => _openCategory('Backup Status', parent: 'Data & Backup')),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Export backups regularly to keep your history safe when changing devices.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Backup & Export'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Save your history as CSV or JSON files, or create a full NoteKar backup.',
                    ),
                    SegmentedSetting(key: ValueKey('backup-reminder-$backupReminderDays-${p.name}'), p: p, title: 'Backup Reminder', subtitle: backupReminderDays == 0 ? 'Reminders are currently off.' : 'Remind to back up every $backupReminderDays days.', value: '$backupReminderDays', blur: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur, values: const {'0': 'Off', '7': '7', '14': '14', '30': '30'}, onChanged: (value) { final days = int.tryParse(value) ?? 0; if (days == backupReminderDays) return; HapticFeedback.selectionClick(); setState(() => backupReminderDays = days); widget.onBackupReminderDays(days); }),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(p: p, icon: Icons.description_rounded, title: 'Export CSV', status: exportState?.startsWith('CSV') == true ? 'Done' : 'Table', color: p.green, active: exportState?.startsWith('CSV') == true, onTap: () => unawaited(_runExport('CSV', widget.onExportCsv))),
                        SettingsRow(p: p, icon: Icons.date_range_rounded, title: 'Export Last 7 Days', status: 'Recent', color: p.green, onTap: () => unawaited(_runExport('Recent CSV', widget.onExportRecentCsv))),
                        SettingsRow(p: p, icon: Icons.data_object_rounded, title: 'Export JSON', status: exportState?.startsWith('JSON') == true ? 'Done' : 'Dev', color: p.accent, active: exportState?.startsWith('JSON') == true, onTap: () => unawaited(_runExport('JSON', widget.onExportJson))),
                        SettingsRow(p: p, icon: Icons.cloud_upload_rounded, title: 'Backup', status: exportState?.startsWith('Backup') == true ? 'Done' : 'Full', color: p.accent, active: exportState?.startsWith('Backup') == true, onTap: () => unawaited(_runExport('Backup', widget.onExportBackup))),
                        SettingsRow(p: p, icon: Icons.drive_folder_upload_rounded, title: 'Import Backup', status: exportState?.startsWith('Import') == true ? 'Done' : 'Restore', color: p.orange, active: exportState?.startsWith('Import') == true, onTap: () => unawaited(_runImport())),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'CSV is best for spreadsheets, while JSON and Backup are used for restoring history.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Backup Status'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Check the health and sync status of your saved moments.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(p: p, icon: Icons.cloud_done_rounded, title: 'Android Backup', color: p.green, status: 'Active'),
                        SettingsRow(p: p, icon: Icons.health_and_safety_rounded, title: 'Data Health', color: p.green, status: _dataHealthStatus),
                        SettingsRow(p: p, icon: Icons.lock_rounded, title: 'Encrypted Backup', color: p.orange, status: 'Planned'),
                        SettingsRow(p: p, icon: Icons.drive_folder_upload_rounded, title: 'Google Drive Backup', color: p.orange, status: 'Planned'),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Android Backup automatically includes NoteKar in your system-level backups. Planned features will provide additional protection.',
                      bottomPadding: 0,
                    ),
                    SettingsBetaNote(
                      p: p,
                      text: 'The current features on this page are under Beta stage.',
                      onLearnMore: () => _showBetaInfoPopup(p),
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Privacy & Security'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'NoteKar is designed to be private and offline-first.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(p: p, icon: Icons.analytics_outlined, title: 'No Analytics', color: p.green, status: 'None'),
                        SettingsRow(p: p, icon: Icons.wifi_rounded, title: 'Network Use', color: p.accent, status: 'Limited'),
                        SettingsRow(p: p, icon: Icons.lock_rounded, title: 'App Lock', color: p.orange, status: privacyLock ? 'On' : 'Off', onTap: () => _openCategory('App Lock', parent: 'Privacy & Security')),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'NoteKar contains zero third-party tracking, analytics, or telemetry. Network access is strictly limited to update checks.',
                      bottomPadding: 0,
                    ),
                    SettingsBetaNote(
                      p: p,
                      text: 'The current features on this page are under Beta stage.',
                      onLearnMore: () => _showBetaInfoPopup(p),
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Help & Guides'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Step-by-step guides for mastering NoteKar.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(p: p, icon: Icons.map_rounded, title: 'Guides', color: p.accent, onTap: () => _openCategory('Guides', parent: 'Help & Guides')),
                        SettingsRow(p: p, icon: Icons.help_outline_rounded, title: 'Help', color: p.orange, onTap: () => _openCategory('Help', parent: 'Help & Guides')),
                        SettingsRow(
                          p: p,
                          icon: Icons.description_rounded,
                          title: 'Licenses',
                          color: p.accent,
                          onTap: () => _openCategory('Licenses', parent: 'Help & Guides'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.privacy_tip_rounded,
                          title: 'Privacy Policy',
                          color: p.green,
                          onTap: () => _openCategory('Privacy Policy', parent: 'Help & Guides'),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Guides explain core functionality like capturing, history, and backups. Help covers specific troubleshooting steps.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('App Lock'))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      SettingsPageSubtitle(
                        p: p,
                        text: 'Secure NoteKar using your Android screen lock.',
                      ),
                      _appLockPage(p),
                    ],
                  ),
                ),
              if (show('Advanced'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Tools for accessibility, diagnostics, and app maintenance.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.accessibility_new_rounded,
                          title: 'Accessibility',
                          status: hapticStyle[0].toUpperCase() + hapticStyle.substring(1),
                          color: p.orange,
                          onTap: () => _openCategory('Accessibility', parent: 'Advanced'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.monitor_heart_rounded,
                          title: 'Diagnostics',
                          status: 'v$appVersion',
                          color: p.accent,
                          onTap: () => _openCategory('Diagnostics', parent: 'Advanced'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.health_and_safety_rounded,
                          title: 'Device Health',
                          status: AdaptiveEngine().healthStatus,
                          color: p.accent,
                          onTap: () => _openCategory('Device Health', parent: 'Advanced'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.restart_alt_rounded,
                          title: 'Reset',
                          status: 'Wipe',
                          color: p.red,
                          onTap: () => _openCategory('Reset', parent: 'Advanced'),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Advanced settings are intended for specific use cases. Use the Reset tools with caution.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Accessibility'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Adjust NoteKar to your comfort and accessibility needs.',
                    ),
                    SegmentedSetting(key: ValueKey('haptic-style-$hapticStyle-${p.name}'), p: p, title: 'Haptic Style', value: hapticStyle, blur: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur, values: const {'off': 'Off', 'light': 'Light', 'standard': 'Standard'}, onChanged: (value) { if (value == hapticStyle) return; HapticFeedback.selectionClick(); setState(() => hapticStyle = value); widget.onHapticStyle(value); }),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(p: p, icon: Icons.motion_photos_off_rounded, title: 'Reduced Motion', color: p.green, value: reduceMotion, onChanged: (value) { setState(() { reduceMotion = value; if (value) homeMenuAnimations = false; }); widget.onReduceMotion(value); }),
                        SettingsSwitchRow(p: p, icon: Icons.format_size_rounded, title: 'Larger Text', color: p.orange, value: largeText, onChanged: (value) { setState(() => largeText = value); widget.onLargeText(value); }),
                        SettingsSwitchRow(p: p, icon: Icons.contrast_rounded, title: 'High Contrast', color: p.green, value: highContrast, onChanged: (value) { setState(() => highContrast = value); widget.onHighContrast(value); }),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Haptic Style controls vibration feedback, and Reduced Motion disables expensive animations.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Reset'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsPageSubtitle(
                      p: p,
                      text: 'Tools to restore NoteKar to its original state.',
                    ),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(p: p, icon: Icons.settings_backup_restore_rounded, title: 'Reset Settings Only', color: p.orange, onTap: () => unawaited(_confirmResetSettings())),
                        SettingsRow(p: p, icon: Icons.delete_outline_rounded, title: 'Reset All Data', color: p.red, onTap: () => unawaited(_confirmResetAll(p))),
                        SettingsRow(p: p, icon: Icons.restart_alt_rounded, title: 'Factory Reset', color: p.red, onTap: () => unawaited(_confirmFactoryReset(p))),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Reset Settings Only keeps your history, while Reset All Data and Factory Reset will erase it.',
                    ),
                    const SizedBox(height: spacing64),
                  ]),
                ),
              if (show('Diagnostics'))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      SettingsPageSubtitle(
                        p: p,
                        text: 'Detailed system information for support and bug reports.',
                      ),
                      _diagnosticsPage(p, entries, todayCount),
                      SettingsPageDescription(p: p, text: 'Diagnostics help in troubleshooting. Copying them does not send any data automatically.'),
                      const SizedBox(height: spacing64),
                    ],
                  ),
                ),
              if (show('Device Health'))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      _deviceHealthPage(p),
                      SettingsPageDescription(
                        p: p,
                        text: 'Technical stats about your device and the Adaptive Engine.',
                      ),
                    ],
                  ),
                ),
              if (show('Privacy Policy'))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _privacyPolicyPage(p),
                  ),
                ),
              if (show('Licenses'))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _licensesPage(p),
                  ),
                ),
              if (show("What's New"))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      ChangelogSettingsPage(p: p, latestOnly: true),
                    ],
                  ),
                ),
              if (show('Changelog'))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      ChangelogSettingsPage(p: p, latestOnly: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
    if (!largeText) return sheet;
    return sheet;
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.p,
    required this.icon,
    required this.title,
    required this.text,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: p.accent, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: p.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  color: p.text3,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
