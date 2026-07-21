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
import 'package:notekar/widgets/history_analytics_card.dart';
import 'package:notekar/widgets/pressable_scale.dart';
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



class _SettingsDialogState extends State<SettingsDialog> {
  String? category;
  final List<String> _categoryStack = [];
  int _prevStackLength = 0;
  final _activeController = ScrollController();

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

  String updateStatus = '';
  bool checkingUpdates = false;

  final TextEditingController _settingsSearchController = TextEditingController();
  final FocusNode _settingsSearchFocusNode = FocusNode();
  String _settingsQuery = '';
  List<String> _recentSearches = [];

  List<Moment> get entries => widget.entries;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final path in const [
      'icon-maskable-512.png',
      'app_icons/black.png',
      'app_icons/blue.png',
      'app_icons/gold.png',
      'app_icons/green.png',
      'app_icons/orange.png',
      'app_icons/red.png',
    ]) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  void dispose() {
    _settingsSearchController.dispose();
    _settingsSearchFocusNode.dispose();
    _activeController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_settings_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String term) async {
    if (term.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [term, ..._recentSearches.where((t) => t != term)].take(5).toList();
    await prefs.setStringList('recent_settings_searches', updated);
    setState(() => _recentSearches = updated);
  }

  void _openCategory(String name, {String? parent}) {
    setState(() {
      _prevStackLength = _categoryStack.length;
      if (category != null) _categoryStack.add(category!);
      category = name;
      _activeController.jumpTo(0.0);
    });
  }

  void _popCategory() {
    if (category == 'Search') {
      setState(() {
        _settingsQuery = '';
        _settingsSearchController.clear();
      });
      _settingsSearchFocusNode.unfocus();
    }
    if (_categoryStack.isEmpty) {
      if (category == null) {
        Navigator.pop(context);
      } else {
        setState(() {
          _prevStackLength = 0;
          category = null;
          _activeController.jumpTo(0.0);
        });
      }
    } else {
      setState(() {
        _prevStackLength = _categoryStack.length + 1;
        category = _categoryStack.removeLast();
        _activeController.jumpTo(0.0);
      });
    }
  }

  String get _updateSubtitle {
    if (checkingUpdates) return 'Checking...';
    return updateStatus.isEmpty ? 'Up to date' : updateStatus;
  }

  bool get _updateAvailable => updateStatus.contains('Update available');
  bool get _upToDate => updateStatus.contains('Up to date');
  String get _availableVersion => updateStatus.split(' ').last;

  String get _dataHealthStatus {
    final entries = widget.entries;
    if (entries.isEmpty) return 'No data';
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = widget.lastSavedAt ?? 0;
    if (now - last < 1000 * 60 * 60 * 24) return 'Healthy';
    return 'Action required';
  }

  List<({
    String title,
    String subtitle,
    String category,
    IconData icon,
    List<String> keywords,
    String kind,
    bool? boolValue,
    ValueChanged<bool>? onBoolChanged,
    String? status,
  })> get _settingsSearchResults {
    final query = _settingsQuery.trim().toLowerCase();
    if (query.isEmpty) return [];

    final all = [
      (
        title: 'Theme',
        subtitle: 'Dark, light, or amoled mode',
        category: 'Display',
        icon: Icons.brightness_6_rounded,
        keywords: ['theme', 'dark', 'light', 'amoled', 'appearance', 'mode'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: theme[0].toUpperCase() + theme.substring(1),
      ),
      (
        title: 'Show Seconds',
        subtitle: 'Display seconds on the home clock',
        category: 'Display',
        icon: Icons.timer_rounded,
        keywords: ['seconds', 'clock', 'time', 'display'],
        kind: 'switch',
        boolValue: showSeconds,
        onBoolChanged: (bool value) {
          setState(() => showSeconds = value);
          widget.onShowSeconds(value);
        },
        status: null,
      ),
      (
        title: 'Highlight Seconds',
        subtitle: 'Colored seconds in two-way mode',
        category: 'Display',
        icon: Icons.auto_awesome_rounded,
        keywords: ['seconds', 'highlight', 'color', 'clock'],
        kind: 'switch',
        boolValue: highlightSeconds,
        onBoolChanged: (bool value) {
          setState(() => highlightSeconds = value);
          widget.onHighlightSeconds(value);
        },
        status: null,
      ),
      (
        title: 'Button Labels',
        subtitle: 'Show text labels under toolbar icons',
        category: 'Display',
        icon: Icons.label_rounded,
        keywords: ['labels', 'text', 'icons', 'toolbar', 'names'],
        kind: 'switch',
        boolValue: buttonLabels,
        onBoolChanged: (bool value) {
          setState(() => buttonLabels = value);
          widget.onButtonLabels(value);
        },
        status: null,
      ),
      (
        title: 'Large Controls',
        subtitle: 'Increase touch targets for primary actions',
        category: 'Display',
        icon: Icons.ads_click_rounded,
        keywords: ['large', 'size', 'buttons', 'controls', 'touch'],
        kind: 'switch',
        boolValue: largeControls,
        onBoolChanged: (bool value) {
          setState(() => largeControls = value);
          widget.onLargeControls(value);
        },
        status: null,
      ),
      (
        title: 'Toolbar Backplate',
        subtitle: 'Show a subtle background pill for the toolbar',
        category: 'Display',
        icon: Icons.shape_line_rounded,
        keywords: ['toolbar', 'backplate', 'pill', 'background', 'style'],
        kind: 'switch',
        boolValue: homeMenuPill,
        onBoolChanged: (bool value) {
          setState(() => homeMenuPill = value);
          widget.onHomeMenuPill(value);
        },
        status: null,
      ),
      (
        title: 'Live Icon Motion',
        subtitle: 'Physics-based icon animations on the home screen',
        category: 'Display',
        icon: Icons.motion_photos_auto_rounded,
        keywords: ['motion', 'animation', 'icon', 'physics', 'live', 'effects'],
        kind: 'switch',
        boolValue: homeMenuAnimations,
        onBoolChanged: (bool value) async {
          final applied = await widget.onHomeMenuAnimations(value);
          if (!mounted) return;
          setState(() {
            homeMenuAnimations = applied ? value : false;
          });
        },
        status: null,
      ),
      (
        title: 'Enable Translucency',
        subtitle: 'Glass-like blur effects on system surfaces',
        category: 'Display',
        icon: Icons.opacity_rounded,
        keywords: ['blur', 'glass', 'transparency', 'translucent', 'effects'],
        kind: 'switch',
        boolValue: enableTranslucency,
        onBoolChanged: (bool value) {
          setState(() => enableTranslucency = value);
          widget.onTranslucency(value);
        },
        status: null,
      ),
      (
        title: 'History Text',
        subtitle: 'Show "HISTORY" label on the home button',
        category: 'Display',
        icon: Icons.format_list_bulleted_rounded,
        keywords: ['history', 'text', 'label', 'home'],
        kind: 'switch',
        boolValue: showHistoryText,
        onBoolChanged: (bool value) {
          setState(() => showHistoryText = value);
          widget.onShowHistoryText(value);
        },
        status: null,
      ),
      (
        title: 'Last Saved Hint',
        subtitle: 'Show time since the last moment was saved',
        category: 'Display',
        icon: Icons.tips_and_updates_rounded,
        keywords: ['hint', 'last saved', 'time', 'feedback'],
        kind: 'switch',
        boolValue: showLastSavedHint,
        onBoolChanged: (bool value) {
          setState(() => showLastSavedHint = value);
          widget.onShowLastSavedHint(value);
        },
        status: null,
      ),
      (
        title: 'Accent Color',
        subtitle: 'Choose a primary color for the interface',
        category: 'Accent Color',
        icon: Icons.palette_rounded,
        keywords: ['accent', 'color', 'theme', 'tint', 'highlights'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: accentColor[0].toUpperCase() + accentColor.substring(1),
      ),
      (
        title: 'App Icons',
        subtitle: 'Change the Android launcher icon',
        category: 'App Icons',
        icon: Icons.apps_rounded,
        keywords: ['icon', 'launcher', 'home screen', 'app icon'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: appIconStyle[0].toUpperCase() + appIconStyle.substring(1),
      ),
      (
        title: 'Startup Mode',
        subtitle: 'Default mode when opening the app',
        category: 'Capture',
        icon: Icons.bolt_rounded,
        keywords: ['startup', 'mode', 'default', 'capture', 'two-way', 'single'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: defaultMode == 'single' ? 'Single' : 'Two-Way',
      ),
      (
        title: 'Tap Delay',
        subtitle: 'Minimum time between accidental taps',
        category: 'Capture',
        icon: Icons.slow_motion_video_rounded,
        keywords: ['delay', 'tap', 'cooldown', 'accident', 'speed'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: delayLabel(tapDelay),
      ),
      (
        title: 'Require Note on Hold',
        subtitle: 'Prompt for a note when long-pressing',
        category: 'Capture',
        icon: Icons.edit_note_rounded,
        keywords: ['note', 'hold', 'long press', 'require', 'context'],
        kind: 'switch',
        boolValue: requireLongPressNote,
        onBoolChanged: (bool value) {
          setState(() => requireLongPressNote = value);
          widget.onRequireLongPressNote(value);
        },
        status: null,
      ),
      (
        title: 'Compact History',
        subtitle: 'Denser rows for scanning many moments',
        category: 'Moments',
        icon: Icons.view_agenda_rounded,
        keywords: ['compact', 'history', 'density', 'list', 'rows'],
        kind: 'switch',
        boolValue: compactHistory,
        onBoolChanged: (bool value) {
          setState(() {
            compactHistory = value;
            historyDensity = value ? 'compact' : 'comfortable';
          });
          widget.onCompactHistory(value);
          widget.onHistoryDensity(historyDensity);
        },
        status: null,
      ),
      (
        title: 'Confirm Delete',
        subtitle: 'Show a prompt before deleting moments',
        category: 'Moments',
        icon: Icons.delete_sweep_rounded,
        keywords: ['delete', 'confirm', 'safety', 'prompt', 'remove'],
        kind: 'switch',
        boolValue: confirmDelete,
        onBoolChanged: (bool value) {
          setState(() => confirmDelete = value);
          widget.onConfirmDelete(value);
        },
        status: null,
      ),
      (
        title: 'Extended Duration',
        subtitle: 'Show days, months, and years in time between moments',
        category: 'Moments',
        icon: Icons.timer_rounded,
        keywords: [
          'time',
          'duration',
          'years',
          'months',
          'days',
          'long intervals',
          'history',
        ],
        kind: 'switch',
        boolValue: extendedDuration,
        onBoolChanged: (bool value) {
          setState(() => extendedDuration = value);
          widget.onExtendedDuration(value);
        },
        status: null,
      ),
      (
        title: 'Minimal Moment Options',
        subtitle: 'Use a compact horizontal row of icons for actions',
        category: 'Moments',
        icon: Icons.auto_awesome_motion_rounded,
        keywords: ['minimal', 'icons', 'actions', 'compact', 'row', 'history'],
        kind: 'switch',
        boolValue: minimalMomentOptions,
        onBoolChanged: (bool value) {
          setState(() => minimalMomentOptions = value);
          widget.onMinimalMomentOptions(value);
        },
        status: null,
      ),
      (
        title: 'Updates & Notices',
        subtitle: 'Software update, app notices, changelog',
        category: 'Updates & Notices',
        icon: Icons.update_rounded,
        keywords: [
          'update',
          'github',
          'release',
          'notification',
          'notice',
          'version',
          'check',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'v$appVersion',
      ),
      (
        title: "What's New",
        subtitle: 'Latest release highlights',
        category: "What's New",
        icon: Icons.new_releases_rounded,
        keywords: ['new', 'latest', 'release', 'features', 'changelog'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      (
        title: 'Changelog',
        subtitle: 'Release history and fixes',
        category: 'Changelog',
        icon: Icons.article_rounded,
        keywords: ['changes', 'release notes', 'version', 'history', 'log'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      (
        title: 'Backup & Export',
        subtitle:
            'CSV, JSON, download, restore, import, file, reminder, health',
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
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: '${entries.length} Logs',
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
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _dataHealthStatus,
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
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: privacyLock ? 'On' : 'Off',
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
        kind: 'switch',
        boolValue: privacyLock,
        onBoolChanged: (bool value) async {
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
        status: null,
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
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: hapticStyle[0].toUpperCase() + hapticStyle.substring(1),
      ),
      (
        title: 'Diagnostics',
        subtitle: 'Version, storage, backup, update status',
        category: 'Diagnostics',
        icon: Icons.monitor_heart_rounded,
        keywords: ['debug', 'support', 'info', 'bug', 'copy', 'logs'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'v$appVersion',
      ),
      (
        title: 'Device Health',
        subtitle: 'Adaptive engine and performance status',
        category: 'Device Health',
        icon: Icons.health_and_safety_rounded,
        keywords: [
          'adaptive engine',
          'performance',
          'hardware',
          'specs',
          'optimization',
          'tier',
          'ram',
          'cpu',
          'cores',
          'low end',
          'lag',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: AdaptiveEngine().healthStatus,
      ),
      (
        title: 'Reset All Data',
        subtitle: 'Erase every moment and note',
        category: 'Reset',
        icon: Icons.delete_outline_rounded,
        keywords: ['clear', 'erase', 'delete everything', 'factory reset', 'wipe'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      (
        title: 'Factory Reset',
        subtitle: 'Erase data and settings, then show welcome',
        category: 'Reset',
        icon: Icons.restart_alt_rounded,
        keywords: ['fresh start', 'welcome', 'reset app', 'new app', 'wipe'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      (
        title: 'Reset Settings Only',
        subtitle: 'Restore preferences and keep moments',
        category: 'Reset',
        icon: Icons.settings_backup_restore_rounded,
        keywords: ['preferences', 'defaults', 'settings reset', 'undo'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      (
        title: 'Privacy Policy',
        subtitle: 'Data safety and local storage commitment',
        category: 'Privacy Policy',
        icon: Icons.privacy_tip_rounded,
        keywords: [
          'privacy',
          'policy',
          'data',
          'safety',
          'local',
          'offline',
          'legal',
          'google',
          'play',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      (
        title: 'Terms of Use',
        subtitle: 'App usage rules and open source terms',
        category: 'Terms of Use',
        icon: Icons.gavel_rounded,
        keywords: [
          'terms',
          'usage',
          'rules',
          'conditions',
          'legal',
          'google',
          'play',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      (
        title: 'Licenses',
        subtitle: 'Software credits and open source legal notices',
        category: 'Licenses',
        icon: Icons.description_rounded,
        keywords: [
          'license',
          'legal',
          'credits',
          'open source',
          'libraries',
          'packages',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
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
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      (
        title: 'Help',
        subtitle: 'Fix updates, backups, notices, motion, and common issues',
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
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
    ];

    return all.where((item) {
      if (item.title.toLowerCase().contains(query)) return true;
      if (item.subtitle.toLowerCase().contains(query)) return true;
      return item.keywords.any((k) => k.contains(query));
    }).toList();
  }

  Future<void> _confirmResetSettings() async {
    final yes = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close reset',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ResetAllConfirmSheet(
        p: paletteFor(
          theme,
          highContrast: highContrast,
          accentName: accentColor,
        ),
        title: 'Reset Settings',
        message:
            'This returns all options to their original values. Your saved history and notes will not be affected. Type RESET to continue.',
      ),
    );
    if (yes == true) {
      await widget.onResetSettings();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _runExport(String type, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      widget.onFeedback('Export failed: $e');
    }
  }

  Future<void> _runImport() async {
    try {
      await widget.onImportBackup();
    } catch (e) {
      widget.onFeedback('Import failed: $e');
    }
  }

  void _showBetaInfoPopup(Palette p) {
    showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      barrierDismissible: true,
      barrierLabel: 'Close beta info',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, anim1, _) => ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: p.border.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.science_rounded, color: p.accent, size: 24),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'NoteKar Beta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are testing upcoming features before stable release. Features are actively polished while your data remains 100% private and local.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  PressableScale(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Got It',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deviceHealthPage(Palette p) {
    final engine = AdaptiveEngine();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (engine.isLowEnd || engine.tier == PerformanceTier.low) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: p.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: p.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Optimized Performance Mode',
                        style: TextStyle(
                          color: p.orange,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'NoteKar has automatically scaled back live animations and blur effects to preserve battery and maintain maximum responsiveness on your device hardware.',
                        style: TextStyle(color: p.text2, fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SettingsGroup(
          p: p,
          title: 'Adaptive Engine Overview',
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.memory_rounded, color: p.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Real-time Hardware Tuning',
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The Adaptive Engine analyzes system RAM capacity, CPU core count, and GPU tier at launch to tune visual effects for optimum 60 FPS performance without heating or lag.',
                    style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          p: p,
          title: 'Hardware Diagnostics',
          children: [
            DiagnosticRow(p: p, label: 'Performance Tier', value: engine.tier.name.toUpperCase()),
            DiagnosticRow(p: p, label: 'RAM Capacity', value: '${engine.ramGb} GB'),
            DiagnosticRow(p: p, label: 'CPU Cores', value: '${engine.processors} Cores'),
            DiagnosticRow(p: p, label: 'System Blur', value: engine.supportsBlur ? 'Supported' : 'Hardware Limited'),
            DiagnosticRow(p: p, label: 'Live Animations', value: engine.supportsAdvancedAnimations ? 'High Performance' : 'Optimized'),
          ],
        ),
        const SizedBox(height: 10),
        SettingsPageDescription(
          p: p,
          text: 'Technical stats about your device and the Adaptive Engine.',
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
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
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
        SettingsGroup(
          p: p,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
          ],
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
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('icon-maskable-512.png', width: 64, height: 64),
              ),
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: p.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
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
        SettingsGroup(
          p: p,
          children: [
            _PolicySection(
              p: p,
              icon: Icons.storage_rounded,
              title: 'Local Storage',
              text: 'All moments and notes are stored locally on your device using an encrypted-ready database (Hive). No data is ever uploaded to a cloud server unless you manually export a backup file.',
            ),
            _PolicySection(
              p: p,
              icon: Icons.analytics_outlined,
              title: 'No Tracking',
              text: 'We do not use any third-party analytics, tracking pixels, or advertising SDKs. Your app usage remains completely anonymous and private.',
            ),
            _PolicySection(
              p: p,
              icon: Icons.wifi_rounded,
              title: 'Limited Connectivity',
              text: 'The app only uses the internet to check for software updates on GitHub and to fetch occasional app notices if enabled. No personal data is transmitted during these checks.',
            ),
          ],
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => widget.onOpenLink(privacyPolicyUrl),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text('Full Online Policy', style: TextStyle(fontWeight: FontWeight.w800)),
          style: FilledButton.styleFrom(
            backgroundColor: p.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: spacing32),
      ],
    );
  }

  Widget _termsOfUsePage(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        Text(
          'Terms of Use',
          style: TextStyle(
            color: p.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: spacing12),
        Text(
          'By using NoteKar, you agree to our terms of service and how we handle open source licenses.',
          style: TextStyle(color: p.text2, fontSize: 15, height: 1.45),
        ),
        const SizedBox(height: spacing24),
        SettingsGroup(
          p: p,
          children: [
            _PolicySection(
              p: p,
              icon: Icons.gavel_rounded,
              title: 'App Usage',
              text: 'NoteKar is provided "as is" for personal use. You are responsible for your own data backups and for ensuring your use of the app complies with local laws.',
            ),
            _PolicySection(
              p: p,
              icon: Icons.code_rounded,
              title: 'Open Source',
              text: 'NoteKar is open source software. Individual components and libraries are subject to their respective licenses, which can be viewed in the Licenses section.',
            ),
          ],
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => widget.onOpenLink(termsUrl),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text('Full Online Terms', style: TextStyle(fontWeight: FontWeight.w800)),
          style: FilledButton.styleFrom(
            backgroundColor: p.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
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
        const SizedBox(height: 20),
        PressableScale(
          onTap: () {
            Clipboard.setData(
              ClipboardData(
                text: _diagnosticsText(entries, todayCount, latest),
              ),
            );
            widget.onFeedback('Diagnostics copied');
          },
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.content_copy_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Copy Diagnostics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SettingsPageDescription(p: p, text: 'Diagnostics help in troubleshooting. Copying them does not send any data automatically.'),
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
        const SizedBox(height: spacing4),
        SettingsPageDescription(
          p: p,
          showIcon: true,
          text: 'App Icons change the Android launcher icon. Note: Some launchers may take a few seconds to update.',
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
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
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
          SettingsGroup(
            p: p,
            children: [
              Padding(
                padding: const EdgeInsets.all(spacing20),
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
            ],
          ),
          const SizedBox(height: spacing24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: p.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
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
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: p.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, color: p.green, size: 36),
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
                  borderRadius: BorderRadius.circular(999),
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
      canPop: category == null && _categoryStack.isEmpty,
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
        controller: category == null ? _activeController : null,
        showLargeTitle: category == null,
        removeBottomPadding: true,
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
              key: ValueKey('container-${category ?? 'root'}'),
              child: CustomScrollView(
                key: ValueKey('scroll-${category ?? 'root'}'),
                controller: category == null ? _activeController : null,
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
                        readOnly: true,
                        onTap: () => _openCategory('Search'),
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
                        insetDividers: true,
                        children: [
                          SettingsRow(
                            p: p,
                            icon: Icons.brush_rounded,
                            title: 'Personalization',
                            status: theme[0].toUpperCase() + theme.substring(1),
                            color: p.accent,
                            onTap: () => _openCategory('Personalization'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.bolt_rounded,
                            title: 'Logging',
                            status: defaultMode == 'single' ? 'Single' : 'Two-Way',
                            color: p.green,
                            onTap: () => _openCategory('Logging'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.verified_user_rounded,
                            title: 'Privacy & Security',
                            status: privacyLock ? 'On' : 'Off',
                            color: p.green,
                            onTap: () => _openCategory('Privacy & Security'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.storage_rounded,
                            title: 'Data & Backup',
                            status: '${entries.length} Logs',
                            color: p.green,
                            onTap: () => _openCategory('Data & Backup'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.update_rounded,
                            title: 'Updates & Notices',
                            status: 'v$appVersion',
                            color: p.accent,
                            onTap: () => _openCategory('Updates & Notices'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.auto_stories_rounded,
                            title: 'Help & Guides',
                            status: 'Docs',
                            color: p.accent,
                            onTap: () => _openCategory('Help & Guides'),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.settings_suggest_rounded,
                            title: 'Advanced',
                            status: 'Tools',
                            color: p.orange,
                            onTap: () => _openCategory('Advanced'),
                          ),
                        ],
                      ),
                      const SizedBox(height: spacing16),
                      SettingsGroup(
                        p: p,
                        insetDividers: true,
                        title: 'Support & Community',
                        children: [
                          SettingsRow(
                            p: p,
                            icon: Icons.coffee_rounded,
                            title: 'Buy me a Coffee',
                            color: const Color(0xFFFFDD00),
                            rowKind: 'link',
                            onTap: () => widget.onOpenLink(coffeeLink),
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.feedback_rounded,
                            title: 'Feedback',
                            color: p.green,
                            rowKind: 'popup',
                            onTap: _openFeedback,
                          ),
                          SettingsRow(
                            p: p,
                            icon: Icons.code_rounded,
                            title: 'GitHub',
                            color: p.text,
                            rowKind: 'link',
                            onTap: () => widget.onOpenLink(githubRepo),
                          ),
                        ],
                      ),
                      if (updateStatus.toLowerCase().contains('available') || updateStatus.toLowerCase().contains('new release')) ...[
                        const SizedBox(height: spacing16),
                        PressableScale(
                          onTap: () => _openCategory('Update Center'),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: p.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: p.accent.withValues(alpha: 0.4), width: 1.2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: p.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.system_update_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    updateStatus,
                                    style: TextStyle(
                                      color: p.text,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: p.accent, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    SettingsPageDescription(
                      p: p,
                      text: 'Personalize and configure NoteKar to fit your specific workflow.',
                    ),
                      const SizedBox(height: spacing24),
                      SettingsAboutBlock(p: p, onOpenLink: widget.onOpenLink),
                      const SizedBox(height: spacing16),
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
                        insetDividers: true,
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
                        insetDividers: true,
                        children: [
                          for (final result in _settingsSearchResults)
                            if (result.kind == 'switch')
                              SettingsSwitchRow(
                                p: p,
                                icon: result.icon,
                                title: result.title,
                                subtitle: result.subtitle,
                                value: result.boolValue!,
                                onChanged: result.onBoolChanged!,
                                color: result.title == 'Confirm Delete' ? p.red : p.accent,
                              )
                            else
                              SettingsRow(
                                p: p,
                                icon: result.icon,
                                title: result.title,
                                subtitle: result.subtitle,
                                status: result.status,
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
                    const SizedBox(height: spacing16),
                  ]),
                ),
              ],
              if (show('Personalization'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      insetDividers: true,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.dark_mode_outlined,
                          title: 'Display',
                          status: theme[0].toUpperCase() + theme.substring(1),
                          color: p.accent,
                          onTap: () => _openCategory('Display', parent: 'Personalization'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.color_lens_outlined,
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
                          color: p.orange,
                          onTap: () => _openCategory('App Icons', parent: 'Personalization'),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'These settings refine the interface aesthetic and do not modify your saved data.',
                    ),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Display'))
                SliverList(
                  delegate: SliverChildListDelegate([
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
                                  color: const Color(0xFF000000),
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
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Select a theme that best suits your environment.'),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(
                          p: p,
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
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Configure the home screen clock and visual feedback.'),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(
                          p: p,
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
                          title: 'History Text',
                          color: p.green,
                          value: showHistoryText,
                          onChanged: (value) {
                            setState(() => showHistoryText = value);
                            widget.onShowHistoryText(value);
                          },
                        ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Show descriptive text labels on the primary navigation and action buttons.'),
                    const SizedBox(height: 10),
                    SettingsGroup(p: p, children: [SettingsSwitchRow(p: p, title: 'Large Controls', color: p.orange, value: largeControls, onChanged: (value) { setState(() => largeControls = value); widget.onLargeControls(value); })]),
                    SettingsPageDescription(p: p, text: 'Increases the size of interactive elements for easier tapping.'),
                    const SizedBox(height: 10),
                    SettingsGroup(p: p, children: [SettingsSwitchRow(p: p, title: 'Toolbar Backplate', color: p.accent, value: homeMenuPill, onChanged: (value) { setState(() => homeMenuPill = value); widget.onHomeMenuPill(value); })]),
                    SettingsPageDescription(p: p, text: 'Adds a subtle glass-like container behind the home toolbar.'),
                    const SizedBox(height: 10),
                    if (AdaptiveEngine().supportsAdvancedAnimations) ...[
                      SettingsGroup(p: p, children: [SettingsSwitchRow(p: p, title: 'Live Icon Motion', color: p.accent, value: !reduceMotion && homeMenuAnimations, enabled: !reduceMotion, disabledMessage: 'Disable Reduce Motion first', onDisabledTap: widget.onFeedback, onChanged: (value) async { if (reduceMotion) return; final applied = await widget.onHomeMenuAnimations(value); if (!mounted) return; setState(() { homeMenuAnimations = applied ? value : false; }); })]),
                      SettingsPageDescription(p: p, text: 'Enables fluid physics for toolbar icons. Automatically scales based on CPU and RAM performance.'),
                      const SizedBox(height: 10),
                    ],
                    if (AdaptiveEngine().supportsBlur) ...[
                      SettingsGroup(p: p, children: [SettingsSwitchRow(p: p, title: 'Enable Translucency', color: p.accent, value: !reduceMotion && enableTranslucency, enabled: !reduceMotion, onDisabledTap: widget.onFeedback, onChanged: (value) { setState(() => enableTranslucency = value); widget.onTranslucency(value); })]),
                      SettingsPageDescription(p: p, text: 'Applies real-time Gaussian blur to system surfaces. Requires a high-performance GPU tier.'),
                      const SizedBox(height: 10),
                    ],
                    SettingsGroup(p: p, children: [SettingsSwitchRow(p: p, title: 'Last Saved Hint', color: p.accent, value: showLastSavedHint, onChanged: (value) { setState(() => showLastSavedHint = value); widget.onShowLastSavedHint(value); })]),
                    SettingsPageDescription(p: p, text: 'Provides visual feedback for the time elapsed since your last moment.'),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Accent Color'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      showDividers: false,
                      children: [
                        ColorChoiceSetting(
                          p: p,
                          value: accentColor,
                          blur: !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur,
                          onChanged: (value) {
                            if (value == accentColor) return;
                            HapticFeedback.selectionClick();
                            setState(() => accentColor = value);
                            widget.onAccentColor(value);
                          },
                        ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Select an accent color for buttons and fluid interface highlights.'),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('App Icons'))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      _appIconsPage(p),
                      const SizedBox(height: spacing16),
                    ],
                  ),
                ),
              if (show('Logging'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    ActivitySummaryCard(p: p, entries: entries),
                    const SizedBox(height: 6),
                    ActivityTrendsCard(p: p, entries: entries),
                    SettingsPageDescription(
                      p: p,
                      text: 'Visual overview of your logging frequency, 7-day activity trends, and average interval between moments.',
                    ),
                    const SizedBox(height: 12),
                    SettingsGroup(
                      p: p,
                      title: 'Logging Controls',
                      insetDividers: true,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.touch_app_rounded,
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
                      text: 'These settings define how moments are recorded and prepared for export.',
                    ),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Capture'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      title: 'Startup Mode',
                      children: [
                        SettingsRow(
                          p: p,
                          title: 'Single',
                          subtitle: 'Every tap records a standalone moment.',
                          trailing: defaultMode == 'single' ? Icon(Icons.check_rounded, color: p.accent, size: 20) : const SizedBox.shrink(),
                          onTap: () {
                            if (defaultMode == 'single') return;
                            setState(() => defaultMode = 'single');
                            widget.onDefaultMode('single');
                          },
                        ),
                        SettingsRow(
                          p: p,
                          title: 'Two-Way',
                          subtitle: 'Sessions are recorded as IN and OUT pairs.',
                          trailing: defaultMode == 'two-way' ? Icon(Icons.check_rounded, color: p.accent, size: 20) : const SizedBox.shrink(),
                          onTap: () {
                            if (defaultMode == 'two-way') return;
                            setState(() => defaultMode = 'two-way');
                            widget.onDefaultMode('two-way');
                          },
                        ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Defines the primary logging mode active when the app launches.'),
                    const SizedBox(height: 10),
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
                              Text('Tap Delay', style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 15)),
                              Text(delayLabel(tapDelay), style: TextStyle(color: p.text2, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              DelayStepButton(
                                p: p,
                                icon: Icons.remove_rounded,
                                enabled: (delayIndex < 0 ? 0 : delayIndex) > 0,
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
                                p: p,
                                icon: Icons.add_rounded,
                                enabled: (delayIndex < 0 ? 0 : delayIndex) < delayValues.length - 1,
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
                    SettingsPageDescription(
                      p: p,
                      text: 'Tap Delay prevents accidental rapid-fire logging by setting a cooldown between captured moments.',
                    ),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(
                          p: p,
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
                    SettingsPageDescription(p: p, text: 'Forces context entry for any moment captured via the long-press gesture.'),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Moments'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      title: 'History Controls',
                      children: [
                        SettingsSwitchRow(
                          p: p,
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
                          title: 'Confirm Delete',
                          color: p.red,
                          value: confirmDelete,
                          onChanged: (value) {
                            setState(() => confirmDelete = value);
                            widget.onConfirmDelete(value);
                          },
                        ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Controls log spacing density and requires a safety confirmation before deleting history moments.'),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(
                          p: p,
                          title: 'Extended Duration',
                          color: p.accent,
                          value: extendedDuration,
                          onChanged: (value) {
                            setState(() => extendedDuration = value);
                            widget.onExtendedDuration(value);
                          },
                        ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Includes years, months, and days breakdown for long time intervals between moments.'),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(
                          p: p,
                          title: 'Minimal Moment Options',
                          color: p.accent,
                          value: minimalMomentOptions,
                          onChanged: (value) {
                            setState(() => minimalMomentOptions = value);
                            widget.onMinimalMomentOptions(value);
                          },
                        ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Enables streamlined icon-only quick action buttons when managing history moments.'),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
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
                    const SizedBox(height: spacing16),
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
                      padding: const EdgeInsets.fromLTRB(spacing16, spacing4, spacing16, spacing16),
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
                                  borderRadius: BorderRadius.circular(32),
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
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Help'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
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
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Update Center'))
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: spacing20),
                    child: _updateCenterPage(p),
                  ),
                ),              if (show('Updates & Notices'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.system_update_outlined,
                          title: 'Software Update',
                          color: p.accent,
                          status: 'v$appVersion',
                          onTap: () => _openCategory('Update Center', parent: 'Updates & Notices'),
                        ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Keep NoteKar up to date with the latest features and security patches.'),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(
                          p: p,
                          title: 'App Notices',
                          color: p.accent,
                          value: remoteNotices,
                          onChanged: (value) {
                            setState(() => remoteNotices = value);
                            widget.onRemoteNotices(value);
                          },
                        ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Checks for official announcement notices and bug fix announcements.'),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      title: 'Release Notes & History',
                      insetDividers: true,
                      children: [
                        SettingsRow(p: p, icon: Icons.auto_awesome_rounded, title: "What's New", color: p.orange, status: 'Recent', onTap: () => _openCategory("What's New", parent: 'Updates & Notices')),
                        SettingsRow(p: p, icon: Icons.history_edu_rounded, title: 'Changelog', color: p.green, status: 'History', onTap: () => _openCategory('Changelog', parent: 'Updates & Notices')),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'View release highlights, version logs, and bug fix summaries for NoteKar.'),
                    const SizedBox(height: 10),
                    SettingsBetaNote(
                      p: p,
                      text: 'The current features on this page are under Beta stage.',
                      onLearnMore: () => _showBetaInfoPopup(p),
                    ),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Data & Backup'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      insetDividers: true,
                      children: [
                        SettingsRow(p: p, icon: Icons.archive_outlined, title: 'Backup & Export', status: '${entries.length} Logs', color: p.green, onTap: () => _openCategory('Backup & Export', parent: 'Data & Backup')),
                        SettingsRow(p: p, icon: Icons.health_and_safety_outlined, title: 'Backup Status', status: _dataHealthStatus, color: p.accent, onTap: () => _openCategory('Backup Status', parent: 'Data & Backup')),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'NoteKar uses a private offline database. Use these tools to secure your history via manual exports.',
                    ),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Backup & Export'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      title: 'Backup Schedule',
                      children: [
                        for (final days in [0, 7, 14, 30])
                          SettingsRow(
                            p: p,
                            title: days == 0 ? 'Disabled' : 'Every $days Days',
                            trailing: backupReminderDays == days ? Icon(Icons.check_rounded, color: p.accent, size: 20) : const SizedBox.shrink(),
                            onTap: () {
                              if (backupReminderDays == days) return;
                              setState(() => backupReminderDays = days);
                              widget.onBackupReminderDays(days);
                            },
                          ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: backupReminderDays == 0 ? 'Reminders are currently disabled. Set an interval to be reminded to safeguard your data.' : 'NoteKar will prompt for a backup every $backupReminderDays days.',
                    ),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      insetDividers: true,
                      children: [
                        SettingsRow(p: p, icon: Icons.table_chart_outlined, title: 'Export CSV', status: 'Table', color: p.green, rowKind: 'link', onTap: () => unawaited(_runExport('CSV', widget.onExportCsv))),
                        SettingsRow(p: p, icon: Icons.date_range_outlined, title: 'Export Last 7 Days', status: 'Recent', color: p.green, rowKind: 'link', onTap: () => unawaited(_runExport('Recent CSV', widget.onExportRecentCsv))),
                        SettingsRow(p: p, icon: Icons.code_rounded, title: 'Export JSON', status: 'Dev', color: p.accent, rowKind: 'link', onTap: () => unawaited(_runExport('JSON', widget.onExportJson))),
                        SettingsRow(p: p, icon: Icons.archive_outlined, title: 'Export Backup', status: 'Full', color: p.accent, rowKind: 'link', onTap: () => unawaited(_runExport('Backup', widget.onExportBackup))),
                        SettingsRow(p: p, icon: Icons.unarchive_outlined, title: 'Import Backup', status: 'Restore', color: p.orange, rowKind: 'link', onTap: () => unawaited(_runImport())),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Export moments to standard CSV or JSON files for backups, external analysis, or phone transfers.',
                    ),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Backup Status'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      title: 'Active Protection',
                      insetDividers: true,
                      children: [
                        SettingsRow(p: p, icon: Icons.android_rounded, title: 'Android Backup', color: p.green, status: 'Active'),
                        SettingsRow(p: p, icon: Icons.favorite_outline_rounded, title: 'Data Health', color: p.green, status: _dataHealthStatus),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Android OS auto-backup preserves app preferences only. Your moments and notes stay 100% local and private to this device.',
                    ),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      title: 'Cloud & Sync (Planned)',
                      insetDividers: true,
                      children: [
                        SettingsRow(p: p, icon: Icons.lock_outlined, title: 'Encrypted Backup', color: p.orange, status: 'Planned'),
                        SettingsRow(p: p, icon: Icons.cloud_outlined, title: 'Google Drive Backup', color: p.orange, status: 'Planned'),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Planned cloud features will provide direct cloud synchronization across your personal devices.',
                      bottomPadding: 0,
                    ),
                    const SizedBox(height: 10),
                    SettingsBetaNote(
                      p: p,
                      text: 'The current features on this page are under Beta stage.',
                      onLearnMore: () => _showBetaInfoPopup(p),
                    ),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Privacy & Security'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      title: 'Data & Privacy',
                      insetDividers: true,
                      children: [
                        SettingsRow(p: p, icon: Icons.analytics_outlined, title: 'No Analytics', color: p.green, status: 'None'),
                        SettingsRow(p: p, icon: Icons.wifi_off_rounded, title: 'Network Use', color: p.accent, status: 'Limited'),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'NoteKar contains zero third-party telemetry. Network access is restricted strictly to update checks and announcement fetching.',
                    ),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.lock_outlined,
                          title: 'App Lock',
                          color: p.orange,
                          status: privacyLock ? 'On' : 'Off',
                          onTap: () => _openCategory('App Lock', parent: 'Privacy & Security'),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Protect your saved history using device biometric authentication or system PIN.',
                      bottomPadding: 0,
                    ),
                    const SizedBox(height: 10),
                    SettingsBetaNote(
                      p: p,
                      text: 'The current features on this page are under Beta stage.',
                      onLearnMore: () => _showBetaInfoPopup(p),
                    ),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('App Lock'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsSwitchRow(
                          p: p,
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
                    SettingsPageDescription(p: p, text: 'Requires biometric or system PIN authentication to open NoteKar.'),
                    if (privacyLock) ...[
                      const SizedBox(height: 10),
                      SettingsGroup(
                        p: p,
                        title: 'When to Lock',
                        children: [
                          for (final entry in const {'0': 'Immediately', '1': 'After 1 Minute', '5': 'After 5 Minutes', '10': 'After 10 Minutes'}.entries)
                            SettingsRow(
                              p: p,
                              title: entry.value,
                              trailing: privacyLockDelayMinutes == int.parse(entry.key) ? Icon(Icons.check_rounded, color: p.accent, size: 20) : const SizedBox.shrink(),
                              onTap: () {
                                final minutes = int.parse(entry.key);
                                if (minutes == privacyLockDelayMinutes) return;
                                setState(() => privacyLockDelayMinutes = minutes);
                                widget.onPrivacyLockDelay(minutes);
                              },
                            ),
                        ],
                      ),
                      SettingsPageDescription(
                        p: p,
                        text: 'Note: Selecting "Immediately" will automatically lock NoteKar as soon as you switch apps, view recent apps, or open your phone notification panel.',
                      ),
                    ],
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Help & Guides'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      title: 'Documentation',
                      insetDividers: true,
                      children: [
                        SettingsRow(p: p, icon: Icons.auto_stories_rounded, title: 'Guides', color: p.accent, status: 'Tutorials', onTap: () => _openCategory('Guides', parent: 'Help & Guides')),
                        SettingsRow(p: p, icon: Icons.help_outline_rounded, title: 'Help', color: p.orange, status: 'FAQ', onTap: () => _openCategory('Help', parent: 'Help & Guides')),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Explore interactive tutorials for tap logging, duration calculations, and troubleshooting.'),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      title: 'Legal & Compliance',
                      insetDividers: true,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.description_outlined,
                          title: 'Licenses',
                          color: p.accent,
                          status: 'Open Source',
                          onTap: () => _openCategory('Licenses', parent: 'Help & Guides'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.article_outlined,
                          title: 'Terms of Use',
                          color: p.orange,
                          status: 'MIT',
                          onTap: () => _openCategory('Terms of Use', parent: 'Help & Guides'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.security_rounded,
                          title: 'Privacy Policy',
                          color: p.green,
                          status: 'Offline-First',
                          onTap: () => _openCategory('Privacy Policy', parent: 'Help & Guides'),
                        ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Review open-source licenses, app usage terms, and offline-first privacy policies.'),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Advanced'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      insetDividers: true,
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
                          icon: Icons.bug_report_outlined,
                          title: 'Diagnostics',
                          status: 'v$appVersion',
                          color: p.accent,
                          onTap: () => _openCategory('Diagnostics', parent: 'Advanced'),
                        ),
                        SettingsRow(
                          p: p,
                          icon: Icons.memory_rounded,
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
                      text: 'These tools are intended for system maintenance and troubleshooting.',
                    ),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Accessibility'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      title: 'Haptic Style',
                      children: [
                        for (final style in ['off', 'light', 'standard'])
                          SettingsRow(
                            p: p,
                            title: style[0].toUpperCase() + style.substring(1),
                            trailing: hapticStyle == style ? Icon(Icons.check_rounded, color: p.accent, size: 20) : const SizedBox.shrink(),
                            onTap: () {
                              if (hapticStyle == style) return;
                              HapticFeedback.selectionClick();
                              setState(() => hapticStyle = style);
                              widget.onHapticStyle(style);
                            },
                          ),
                      ],
                    ),
                    SettingsPageDescription(p: p, text: 'Configure the intensity of vibration feedback during taps and saves.'),
                    const SizedBox(height: 10),
                    SettingsGroup(p: p, children: [SettingsSwitchRow(p: p, title: 'Reduced Motion', color: p.green, value: reduceMotion, onChanged: (value) { setState(() { reduceMotion = value; if (value) homeMenuAnimations = false; }); widget.onReduceMotion(value); })]),
                    SettingsPageDescription(p: p, text: 'Disables fluid physics and parallax effects to improve performance and stability.'),
                    const SizedBox(height: 10),
                    SettingsGroup(p: p, children: [SettingsSwitchRow(p: p, title: 'Larger Text', color: p.orange, value: largeText, onChanged: (value) { setState(() => largeText = value); widget.onLargeText(value); })]),
                    SettingsPageDescription(p: p, text: 'Increases the global font scale for improved legibility across all interfaces.'),
                    const SizedBox(height: 10),
                    SettingsGroup(p: p, children: [SettingsSwitchRow(p: p, title: 'High Contrast', color: p.green, value: highContrast, onChanged: (value) { setState(() => highContrast = value); widget.onHighContrast(value); })]),
                    SettingsPageDescription(p: p, text: 'Enhances visibility by using pure black backgrounds and high-intensity accent colors.'),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Reset'))
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: spacing8),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.restore_rounded,
                          title: 'Reset Settings Only',
                          color: p.orange,
                          rowKind: 'popup',
                          onTap: () => unawaited(_confirmResetSettings()),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Restores all settings options to their factory defaults. Your saved moments and notes are kept intact.',
                    ),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.delete_forever_rounded,
                          title: 'Reset All Data',
                          color: p.red,
                          rowKind: 'popup',
                          onTap: () => unawaited(_confirmResetAll(p)),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Permanently deletes all saved timestamps and notes from this device. Preferences remain unchanged.',
                    ),
                    const SizedBox(height: 10),
                    SettingsGroup(
                      p: p,
                      children: [
                        SettingsRow(
                          p: p,
                          icon: Icons.restart_alt_rounded,
                          title: 'Factory Reset',
                          color: p.red,
                          rowKind: 'popup',
                          onTap: () => unawaited(_confirmFactoryReset(p)),
                        ),
                      ],
                    ),
                    SettingsPageDescription(
                      p: p,
                      text: 'Completely clears all saved data and resets all settings to original fresh state.',
                    ),
                    const SizedBox(height: spacing16),
                  ]),
                ),
              if (show('Diagnostics'))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      _diagnosticsPage(p, entries, todayCount),
                      const SizedBox(height: spacing16),
                    ],
                  ),
                ),
              if (show('Device Health'))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      _deviceHealthPage(p),
                      const SizedBox(height: spacing16),
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
              if (show('Terms of Use'))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _termsOfUsePage(p),
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
                      const SizedBox(height: spacing16),
                    ],
                  ),
                ),
              if (show('Changelog'))
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: spacing8),
                      ChangelogSettingsPage(p: p, latestOnly: false),
                      const SizedBox(height: spacing16),
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
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 13,
                    height: 1.5,
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
