import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/changelog_dialog.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/guide_help_rows.dart';
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
  late bool enableTranslucency;
  late int privacyLockDelayMinutes;
  late String updateStatus;
  late bool checkingUpdates;
  final List<String> _categoryStack = [];
  String? exportState;
  Timer? _exportStateTimer;
  final _settingsSearchController = TextEditingController();
  final _settingsScrollController = ScrollController();
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
    enableTranslucency = widget.enableTranslucency;
    privacyLockDelayMinutes = widget.privacyLockDelayMinutes;
    updateStatus = widget.updateStatus;
    checkingUpdates = widget.checkingUpdates;
  }

  @override
  void dispose() {
    _exportStateTimer?.cancel();
    _settingsSearchController.dispose();
    _settingsScrollController.dispose();
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
    'enableTranslucency': enableTranslucency,
    'privacyLockDelayMinutes': privacyLockDelayMinutes,
  };

  String? get category => _categoryStack.isEmpty ? null : _categoryStack.last;

  String get _backLabel {
    if (_categoryStack.length >= 2) {
      return _categoryStack[_categoryStack.length - 2];
    }
    return 'Settings';
  }

  void _jumpSettingsTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_settingsScrollController.hasClients) return;
      _settingsScrollController.jumpTo(0);
    });
  }

  void _openCategory(String next, {String? parent}) {
    setState(() {
      if (parent != null && _categoryStack.lastOrNull != parent) {
        _categoryStack
          ..clear()
          ..add(parent);
      }
      if (_categoryStack.lastOrNull != next) _categoryStack.add(next);
      _settingsQuery = '';
      _settingsSearchController.clear();
    });
    _jumpSettingsTop();
  }

  bool _popCategory() {
    if (_categoryStack.isEmpty) return false;
    setState(() => _categoryStack.removeLast());
    _jumpSettingsTop();
    return true;
  }

  Future<void> _runExport(String label, Future<void> Function() action) async {
    _exportStateTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() => exportState = '$label exporting...');
    await action();
    if (!mounted) return;
    setState(() => exportState = '$label exported');
    _exportStateTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => exportState = null);
    });
  }

  Future<void> _runImport() async {
    _exportStateTimer?.cancel();
    HapticFeedback.selectionClick();
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

  String get _updateTitle => _updateAvailable
      ? 'Install Update'
      : _upToDate
      ? "You're Up to Date"
      : 'Check for Update';

  String get _updateSubtitle {
    if (_updateAvailable) return 'Install latest builds from GitHub';
    if (checkingUpdates) return 'Checking GitHub Releases...';
    if (_upToDate) return 'NoteKar is already on the latest build.';
    return 'Current version v$appVersion';
  }

  String get _backupAgeLine {
    if (widget.lastBackupAt == null) return 'not created yet';
    return relativeAge(widget.lastBackupAt!);
  }

  String get _backupReminderSubtitle {
    if (backupReminderDays == 0) {
      return 'No reminder. Back up whenever you choose.';
    }
    return 'A local reminder appears after $backupReminderDays days without a backup.';
  }

  String get _privacyLockSubtitle {
    if (privacyLock) {
      return 'App Lock is on. NoteKar locks ${privacyLockDelayLabel(privacyLockDelayMinutes).toLowerCase()} after you leave.';
    }
    return 'Use your Android screen lock before NoteKar opens, with timing controls below.';
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
    final rows = _settingsSearchRowsCache ??=
        <
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
            subtitle: 'Theme, clock, toolbar, labels, large controls',
            category: 'Display',
            icon: Icons.color_lens_rounded,
            keywords: [
              'look',
              'ui',
              'color',
              'dark',
              'light',
              'amoled',
              'home',
            ],
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
            keywords: ['toolbar', 'menu', 'animation', 'motion', 'icons'],
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
            ],
          ),
          (
            title: 'App Icons',
            subtitle: 'Default plus black, blue, gold, green, orange, and red',
            category: 'App Icons',
            icon: Icons.apps_rounded,
            keywords: ['icon', 'launcher', 'app icon', 'black', 'gold', 'red'],
          ),
          (
            title: 'Capture',
            subtitle: 'Default mode, tap delay, and note-focused hold',
            category: 'Capture',
            icon: Icons.touch_app_rounded,
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
            ],
          ),
          (
            title: 'Moments',
            subtitle: 'History density, confirm delete, moments',
            category: 'Moments',
            icon: Icons.history_rounded,
            keywords: [
              'moments',
              'logs',
              'records',
              'delete',
              'compact',
              'density',
            ],
          ),
          (
            title: 'Updates',
            subtitle: 'Check for update, remote notices, changelog',
            category: 'Updates',
            icon: Icons.system_update_alt_rounded,
            keywords: ['update', 'github', 'release', 'notification', 'notice'],
          ),
          (
            title: "What's New",
            subtitle: 'Latest release highlights',
            category: "What's New",
            icon: Icons.new_releases_rounded,
            keywords: ['new', 'latest', 'release', 'features'],
          ),
          (
            title: 'Changelog',
            subtitle: 'Release history and fixes',
            category: 'Changelog',
            icon: Icons.article_rounded,
            keywords: ['changes', 'release notes', 'version', 'history'],
          ),
          (
            title: 'Backup & Export',
            subtitle: 'CSV, JSON, backup reminder, import, Android backup',
            category: 'Backup & Export',
            icon: Icons.backup_rounded,
            keywords: [
              'csv',
              'json',
              'download',
              'restore',
              'import',
              'file',
              'reminder',
              'health',
            ],
          ),
          (
            title: 'Backup Status',
            subtitle: 'Android backup, health, encryption, and Drive plans',
            category: 'Backup Status',
            icon: Icons.health_and_safety_rounded,
            keywords: [
              'android backup',
              'backup health',
              'data health',
              'encrypted backup',
              'google drive',
              'drive backup',
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
            ],
          ),
          (
            title: 'Diagnostics',
            subtitle: 'Version, storage, backup, update status',
            category: 'Diagnostics',
            icon: Icons.monitor_heart_rounded,
            keywords: ['debug', 'support', 'info', 'bug', 'copy'],
          ),
          (
            title: 'Reset All Data',
            subtitle: 'Erase every moment and note',
            category: 'Reset',
            icon: Icons.delete_outline_rounded,
            keywords: ['clear', 'erase', 'delete everything', 'factory reset'],
          ),
          (
            title: 'Factory Reset',
            subtitle: 'Erase data and settings, then show welcome',
            category: 'Reset',
            icon: Icons.restart_alt_rounded,
            keywords: ['fresh start', 'welcome', 'reset app', 'new app'],
          ),
          (
            title: 'Reset Settings Only',
            subtitle: 'Restore preferences and keep moments',
            category: 'Reset',
            icon: Icons.tune_rounded,
            keywords: ['preferences', 'defaults', 'settings reset'],
          ),
          (
            title: 'Guides',
            subtitle: 'Learn taps, notes, history, and backups',
            category: 'Help & Guides',
            icon: Icons.menu_book_rounded,
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
            ],
          ),
        ];
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

  Widget _deviceHealthPage(Palette p) {
    final engine = AdaptiveEngine();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: spacing16),
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
        SettingsPageNote(
          p: p,
          text:
              'The Adaptive Engine automatically tunes Notekar to your device hardware. On low-power devices, expensive effects like background blur are hidden to keep the app snappy.',
        ),
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
              subtitle: _privacyLockSubtitle,
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
            subtitle:
                'Now locks as soon as NoteKar leaves focus. Delays wait in the background.',
            value: '$privacyLockDelayMinutes',
            blur: widget.blur,
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
    return SettingsGroup(
      p: p,
      showDividers: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.35,
            children: [
              for (final icon in icons.entries)
                AppIconChoice(
                  p: p,
                  label: icon.value.$1,
                  asset: icon.value.$2,
                  active: appIconStyle == icon.key,
                  onTap: () {
                    if (icon.key == appIconStyle) return;
                    HapticFeedback.selectionClick();
                    setState(() => appIconStyle = icon.key);
                    unawaited(widget.onAppIconStyle(icon.key));
                  },
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: SettingsPageNote(
            p: p,
            text:
                'App Icons change the Android launcher icon. Default uses the current colored NoteKar icon.',
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
    bool show(String name) => category == name;
    final sheet = PopScope(
      canPop: _categoryStack.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _popCategory();
      },
      child: AppSheet(
        p: p,
        title: category ?? 'Settings',
        docked: true,
        blur: widget.blur,
        controller: _settingsScrollController,
        showLargeTitle: category == null,
        child: SizedBox(
          width: 430,
          height: math.min(MediaQuery.sizeOf(context).height * 0.68, 620),
          child: ListView(
            controller: _settingsScrollController,
            children: [
              if (category != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: spacing12),
                  child: PressableScale(
                    onTap: _popCategory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: spacing16,
                        vertical: spacing12,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: p.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chevron_left_rounded,
                            color: p.text,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _backLabel,
                            style: TextStyle(
                              color: p.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (category == null) ...[
                AppSheetLargeTitle(
                  p: p,
                  title: 'Settings',
                  scrollController: _settingsScrollController,
                  extra: SettingsSearchBox(
                    p: p,
                    controller: _settingsSearchController,
                    onChanged: (value) =>
                        setState(() => _settingsQuery = value),
                    onClear: () => setState(() {
                      _settingsQuery = '';
                      _settingsSearchController.clear();
                    }),
                  ),
                ),
                if (_settingsQuery.trim().isNotEmpty) ...[
                  const SizedBox(height: spacing8),
                  SettingsGroup(
                    p: p,
                    children: [
                      for (final result in _settingsSearchResults)
                        SettingsRow(
                          p: p,
                          icon: result.icon,
                          title: result.title,
                          subtitle: result.subtitle,
                          highlight: _settingsQuery,
                          color:
                              result.title == 'Reset All Data' ||
                                  result.title == 'Factory Reset'
                              ? p.red
                              : p.accent,
                          onTap: () {
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
                        SettingsRow(
                          p: p,
                          icon: Icons.search_off_rounded,
                          title: 'No Results',
                          subtitle:
                              'Try theme, backup, delay, privacy, reset, or notes',
                          color: p.text2,
                        ),
                    ],
                  ),
                  const SizedBox(height: spacing16),
                ],
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.tune_rounded,
                      title: 'Personalization',
                      subtitle: 'Theme, toolbar, action color, and app icons',
                      color: p.accent,
                      onTap: () => _openCategory('Personalization'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.bolt_rounded,
                      title: 'Logging',
                      subtitle: 'Capture behavior, tap delay, and history',
                      color: p.green,
                      onTap: () => _openCategory('Logging'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.verified_user_rounded,
                      title: 'Privacy & Security',
                      subtitle: 'Local data, network use, and screen lock',
                      color: p.green,
                      onTap: () => _openCategory('Privacy & Security'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.backup_rounded,
                      title: 'Data & Backup',
                      subtitle: 'Export, import, reminders, and data health',
                      color: p.green,
                      onTap: () => _openCategory('Data & Backup'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.system_update_alt_rounded,
                      title: 'Updates',
                      subtitle: _updateSubtitle,
                      color: p.accent,
                      onTap: () => _openCategory('Updates'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.menu_book_rounded,
                      title: 'Help & Guides',
                      subtitle: 'Learn logging, notes, history, and backups',
                      color: p.accent,
                      onTap: () => _openCategory('Help & Guides'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.tune_rounded,
                      title: 'Advanced',
                      subtitle: 'Accessibility, diagnostics, and reset',
                      color: p.orange,
                      onTap: () => _openCategory('Advanced'),
                    ),
                  ],
                ),
                const SizedBox(height: spacing24),
                SettingsAboutBlock(
                  p: p,
                  onEmailTap: () =>
                      widget.onOpenLink(supportEmail),
                  onGitHubTap: () =>
                      widget.onOpenLink(githubRepo),
                  onVersionLongPress: () =>
                      widget.onOpenLink(officialSite),
                ),
              ],
              if (show('Personalization')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.color_lens_rounded,
                      title: 'Display',
                      subtitle: 'Theme, clock, motion, and toolbar',
                      color: p.accent,
                      onTap: () =>
                          _openCategory('Display', parent: 'Personalization'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.palette_rounded,
                      title: 'Accent Color',
                      subtitle: 'Choose colors for buttons and highlights',
                      color: p.accent,
                      onTap: () => _openCategory(
                        'Accent Color',
                        parent: 'Personalization',
                      ),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.apps_rounded,
                      title: 'App Icons',
                      subtitle: 'Choose the Android launcher icon',
                      color: p.accent,
                      onTap: () =>
                          _openCategory('App Icons', parent: 'Personalization'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Personalization keeps the app feeling yours without changing saved moments.',
                ),
              ],
              if (show('Display')) ...[
                SettingsGroup(
                  p: p,
                  showDividers: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ThemeChoice(
                              p: p,
                              label: 'Dark',
                              active: theme == 'dark',
                              color: Colors.black,
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
                              color: Colors.black,
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
                      subtitle: 'Show the seconds beside the main time',
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
                      subtitle: 'Use a softer separate color for seconds',
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
                      subtitle: 'Use compact text buttons in the toolbar',
                      color: p.green,
                      value: buttonLabels,
                      onChanged: (value) {
                        setState(() => buttonLabels = value);
                        widget.onButtonLabels(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.touch_app_rounded,
                      title: 'Large Controls',
                      subtitle: 'Increase toolbar touch targets',
                      color: p.orange,
                      value: largeControls,
                      onChanged: (value) {
                        setState(() => largeControls = value);
                        widget.onLargeControls(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.blur_on_rounded,
                      title: 'Toolbar Backplate',
                      subtitle:
                          'Keep the floating capsule behind home controls',
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
                        subtitle: buttonLabels
                            ? 'Turn off Button Labels to see icon motion'
                            : reduceMotion
                            ? 'Turn off Reduced Motion to use phone-tilt motion'
                            : 'Use gentle phone-tilt motion for home icons',
                        color: p.accent,
                        value: !reduceMotion && homeMenuAnimations,
                        enabled: !reduceMotion,
                        disabledMessage: 'Disable Reduce Motion first',
                        onDisabledTap: widget.onFeedback,
                        onChanged: (value) async {
                          if (reduceMotion) return;

                          final applied = await widget.onHomeMenuAnimations(
                            value,
                          );

                          if (!mounted) return;

                          setState(() {
                            homeMenuAnimations = applied ? value : false;
                          });
                        },
                      ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.history_rounded,
                      title: 'History Text',
                      subtitle: 'Show the History label in the home menu',
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
                      subtitle: 'Keep the quick undo hint after each save',
                      color: p.accent,
                      value: showLastSavedHint,
                      onChanged: (value) {
                        setState(() => showLastSavedHint = value);
                        widget.onShowLastSavedHint(value);
                      },
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Display is personal. These choices change the interface only; your saved moments and notes stay exactly where they are.',
                ),
              ],
              if (show('Accent Color')) ...[
                ColorChoiceSetting(
                  p: p,
                  title: 'Accent Color',
                  subtitle:
                      'Choose the color used for buttons, highlights, and saved feedback.',
                  value: accentColor,
                  blur: widget.blur,
                  onChanged: (value) {
                    if (value == accentColor) return;
                    HapticFeedback.selectionClick();
                    setState(() => accentColor = value);
                    widget.onAccentColor(value);
                  },
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Accent Color changes interface highlights only. It does not change or classify saved moments.',
                ),
              ],
              if (show('App Icons')) _appIconsPage(p),
              if (show('Logging')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.touch_app_rounded,
                      title: 'Capture',
                      subtitle: 'Startup mode, tap delay, and notes',
                      color: p.green,
                      onTap: () => _openCategory('Capture', parent: 'Logging'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.history_rounded,
                      title: 'Moments',
                      subtitle: 'History density, delete safety, and totals',
                      color: p.orange,
                      onTap: () => _openCategory('Moments', parent: 'Logging'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Logging controls how moments are captured and how history is reviewed.',
                ),
              ],
              if (show('Capture')) ...[
                SegmentedSetting(
                  key: ValueKey('mode-$defaultMode-${p.name}'),
                  p: p,
                  title: 'Startup Mode',
                  subtitle: 'Choose the mode NoteKar opens with.',
                  value: defaultMode,
                  blur: widget.blur,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tap Delay',
                                  style: TextStyle(
                                    color: p.text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Set the minimum time between saved taps',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: p.text2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SettingsStatusPill(
                            p: p,
                            label: delayLabel(tapDelay),
                            color: p.accent,
                          ),
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
                            blur: widget.blur,
                            onTap: () {
                              final current = delayIndex < 0 ? 0 : delayIndex;
                              final next = delayValues[math.max(0, current - 1)];
                              HapticFeedback.selectionClick();
                              setState(() => tapDelay = next);
                              widget.onDelay(next);
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
                                    overlayColor: p.accent.withValues(
                                      alpha: 0.12,
                                    ),
                                    trackHeight: 5,
                                    tickMarkShape:
                                        SliderTickMarkShape.noTickMark,
                                  ),
                                  child: Slider(
                                    key: ValueKey(
                                      'delay-slider-$tapDelay-${p.name}',
                                    ),
                                    min: 0,
                                    max: 6,
                                    divisions: 6,
                                    value: (delayIndex < 0 ? 0 : delayIndex)
                                        .toDouble(),
                                    onChanged: (value) {
                                      final next = delayValues[value.round()];
                                      if (next == tapDelay) return;
                                      HapticFeedback.selectionClick();
                                      setState(() => tapDelay = next);
                                      widget.onDelay(next);
                                    },
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(0, -4),
                                  child: SliderScale(
                                    p: p,
                                    activeValue: tapDelay,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DelayStepButton(
                            key: ValueKey('delay-plus-$tapDelay-${p.name}'),
                            p: p,
                            icon: Icons.add_rounded,
                            enabled:
                                (delayIndex < 0 ? 0 : delayIndex) <
                                delayValues.length - 1,
                            blur: widget.blur,
                            onTap: () {
                              final current = delayIndex < 0 ? 0 : delayIndex;
                              final next =
                                  delayValues[math.min(
                                    delayValues.length - 1,
                                    current + 1,
                                  )];
                              HapticFeedback.selectionClick();
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
                      subtitle:
                          'Long press opens notes. Empty notes will not be saved.',
                      color: p.orange,
                      value: requireLongPressNote,
                      onChanged: (value) {
                        setState(() => requireLongPressNote = value);
                        widget.onRequireLongPressNote(value);
                      },
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Capture controls how moments are saved. Startup mode applies next launch; tap delay and note-focused hold apply right away.',
                ),
              ],
              if (show('Moments')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.view_agenda_rounded,
                      title: 'Compact History',
                      subtitle:
                          'Use denser rows for faster scanning and less scrolling',
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
                      subtitle: 'Ask before deleting a saved moment',
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
                      subtitle:
                          'Show days, months, and years in time between moments',
                      color: p.accent,
                      value: extendedDuration,
                      onChanged: (value) {
                        setState(() => extendedDuration = value);
                        widget.onExtendedDuration(value);
                      },
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.insights_rounded,
                      title: 'Moments',
                      subtitle: '${entries.length} total - $todayCount today',
                      color: p.orange,
                      status: '$todayCount today',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.search_rounded,
                      title: 'Search Notes',
                      subtitle: 'Find saved notes by text, date, time, or type',
                      color: p.accent,
                      status:
                          '${entries.where((e) => e.note.isNotEmpty).length} notes',
                      onTap: () =>
                          _openCategory('Search Notes', parent: 'Moments'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Moments are stored locally for quick review. Compact rows help with scanning; confirmation helps avoid accidental deletes.',
                ),
              ],
              if (show('Search Notes')) ...[
                NoteSearchContent(
                  p: p,
                  entries: entries,
                  compactRows: compactHistory,
                  height: math.min(
                    MediaQuery.sizeOf(context).height * 0.56,
                    500,
                  ),
                ),
              ],
              if (show('Guides')) ...[
                SettingsGroup(
                  p: p,
                  showDividers: true,
                  children: [
                    GuideRow(
                      p: p,
                      icon: Icons.touch_app_rounded,
                      title: 'Save a Moment',
                      text:
                          'Tap the home screen once to save the current time.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.compare_arrows_rounded,
                      title: 'Two-Way Mode',
                      text:
                          'First tap saves In. The next tap saves Out and completes the pair.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.radio_button_checked_rounded,
                      title: 'Single Mode',
                      text: 'Every tap saves one standalone moment.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.note_add_rounded,
                      title: 'Add a Note',
                      text:
                          'Touch and hold the home screen to write a note before saving.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.history_rounded,
                      title: 'Review History',
                      text:
                          'Open History to review moments, use Select Date for a calendar day, or filter by Today and This Week.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.search_rounded,
                      title: 'Search Notes',
                      text:
                          'Open Settings, then Logging, Moments, Search Notes to find note text by words, date, time, or type.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.timer_rounded,
                      title: 'Time Between Moments',
                      text:
                          'Select one moment, then another, to calculate the time between them.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.subject_rounded,
                      title: 'Manage Moment Notes',
                      text:
                          'Touch and hold any history moment to add, read, edit, or delete its note. Deleted notes and moments show an Undo pill.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.lock_rounded,
                      title: 'App Lock Timing',
                      text:
                          'Immediate App Lock covers NoteKar in Recents and when the notification shade sends the app inactive.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.backup_rounded,
                      title: 'Back Up Data',
                      text:
                          'Export a backup before resetting, changing phones, or testing a new build.',
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'NoteKar stores moments privately on this device. Backups are files you control.',
                ),
              ],
              if (show('Help')) ...[
                SettingsGroup(
                  p: p,
                  showDividers: true,
                  children: [
                    HelpRow(
                      p: p,
                      question: 'Update check failed',
                      answer:
                          'First confirm that your phone is connected to the internet. '
                          'If other websites work, GitHub may be unavailable or limiting requests. '
                          'Wait a few minutes and try again.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'App Notices are not appearing',
                      answer:
                          'Confirm App Notices are enabled and Android notification permission '
                          'is allowed. Battery restrictions or background limits may delay checks. '
                          'Opening NoteKar while online also triggers a notice check.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'NoteKar is offline',
                      answer:
                          'Logging, History, notes, settings, and local backups work without internet. '
                          'Only update checks, external links, and App Notices require a connection.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'Backup import found no new moments',
                      answer:
                          'The backup was read correctly, but its moments already exist on this device. '
                          'NoteKar skips duplicates instead of adding them again.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'Backup import failed',
                      answer:
                          'Make sure you selected a NoteKar JSON backup that was not renamed, '
                          'manually edited, or damaged. Try exporting a fresh backup.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'Live Icon Motion will not turn on',
                      answer:
                          'Turn off Reduced Motion first. If NoteKar reports that the motion sensor '
                          'is unavailable, the phone does not provide a usable accelerometer stream.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'Live Icon Motion looks slow or delayed',
                      answer:
                          'The movement is intentionally smoothed to prevent jitter. Lower-end phones '
                          'may also reduce animation performance when many screens are open.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'App Lock will not turn on',
                      answer:
                          'Add a PIN, password, pattern, fingerprint, or other supported screen lock '
                          'in Android settings, then try again.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'App Lock appears after the notification panel',
                      answer:
                          'If App Lock is set to Immediately, opening Recents or pulling down the notification panel counts as leaving NoteKar. The lock overlay hides your moments before you return.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'The app icon did not change immediately',
                      answer:
                          'Some Android launchers cache icons. Return to the home screen, wait briefly, '
                          'or restart the launcher or phone.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'A moment was saved accidentally',
                      answer:
                          'Use Undo immediately after saving, or remove it from History. '
                          'You can enable Confirm Delete for extra protection.',
                    ),
                    HelpRow(
                      p: p,
                      question:
                          'My data disappeared after clearing app storage',
                      answer:
                          'NoteKar stores data locally. Clearing Android app storage deletes that local data. '
                          'Restore it using a backup file if one was exported earlier.',
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'NoteKar is offline-first. Internet-related failures should never block logging or access to saved history.',
                ),
              ],
              if (show('Updates')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: checkingUpdates
                          ? Icons.sync_rounded
                          : _updateAvailable
                          ? Icons.download_rounded
                          : Icons.system_update_alt_rounded,
                      title: _updateTitle,
                      subtitle: _updateSubtitle,
                      color: p.accent,
                      status: 'v$appVersion',
                      onTap: () async {
                        if (_updateAvailable) {
                          widget.onOpenLink(githubReleases);
                          return;
                        }
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
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.notifications_active_rounded,
                      title: 'App Notices',
                      subtitle: 'Allow occasional release and app notices',
                      color: p.accent,
                      value: remoteNotices,
                      onChanged: (value) {
                        setState(() => remoteNotices = value);
                        widget.onRemoteNotices(value);
                      },
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.new_releases_rounded,
                      title: "What's New",
                      subtitle: 'See highlights from the latest release',
                      color: p.orange,
                      status: 'New',
                      onTap: () =>
                          _openCategory("What's New", parent: 'Updates'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.article_rounded,
                      title: 'Changelog',
                      subtitle: 'Read release history and fixes',
                      color: p.green,
                      status: 'v$appVersion',
                      onTap: () =>
                          _openCategory('Changelog', parent: 'Updates'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Updates and notices are optional network checks. NoteKar keeps working offline even when these checks are unavailable.',
                ),
              ],
              if (show('Data & Backup')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.backup_rounded,
                      title: 'Backup & Export',
                      subtitle: 'CSV, JSON, import, and backup reminders',
                      color: p.green,
                      onTap: () => _openCategory(
                        'Backup & Export',
                        parent: 'Data & Backup',
                      ),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.health_and_safety_rounded,
                      title: 'Backup Status',
                      subtitle: 'Android backup, health, and planned options',
                      color: p.accent,
                      onTap: () => _openCategory(
                        'Backup Status',
                        parent: 'Data & Backup',
                      ),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Data & Backup is where you move, restore, and protect saved history.',
                ),
              ],
              if (show('Backup & Export')) ...[
                SegmentedSetting(
                  key: ValueKey(
                    'backup-reminder-$backupReminderDays-${p.name}',
                  ),
                  p: p,
                  title: 'Backup Reminder (days)',
                  subtitle: _backupReminderSubtitle,
                  value: '$backupReminderDays',
                  values: const {'0': 'Off', '7': '7', '14': '14', '30': '30'},
                  onChanged: (value) {
                    final days = int.tryParse(value) ?? 0;
                    if (days == backupReminderDays) return;
                    HapticFeedback.selectionClick();
                    setState(() => backupReminderDays = days);
                    widget.onBackupReminderDays(days);
                  },
                ),
                const SizedBox(height: 10),
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.description_rounded,
                      title: 'Export CSV',
                      subtitle: exportState?.startsWith('CSV') == true
                          ? exportState!
                          : 'Save a spreadsheet-friendly copy',
                      color: p.green,
                      active: exportState?.startsWith('CSV') == true,
                      onTap: () =>
                          unawaited(_runExport('CSV', widget.onExportCsv)),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.date_range_rounded,
                      title: 'Export Last 7 Days',
                      subtitle: 'Save only recent moments as CSV',
                      color: p.green,
                      onTap: () => unawaited(
                        _runExport('Recent CSV', widget.onExportRecentCsv),
                      ),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.data_object_rounded,
                      title: 'Export JSON',
                      subtitle: exportState?.startsWith('JSON') == true
                          ? exportState!
                          : 'Save a structured developer-friendly copy',
                      color: p.accent,
                      active: exportState?.startsWith('JSON') == true,
                      onTap: () =>
                          unawaited(_runExport('JSON', widget.onExportJson)),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.backup_rounded,
                      title: 'Backup',
                      subtitle: exportState?.startsWith('Backup') == true
                          ? exportState!
                          : 'Create a portable backup file',
                      color: p.accent,
                      active: exportState?.startsWith('Backup') == true,
                      onTap: () => unawaited(
                        _runExport('Backup', widget.onExportBackup),
                      ),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.drive_folder_upload_rounded,
                      title: 'Import Backup',
                      subtitle: exportState?.startsWith('Import') == true
                          ? exportState!
                          : 'Merge a NoteKar backup into this device. Existing moments stay safe.',
                      color: p.orange,
                      active: exportState?.startsWith('Import') == true,
                      onTap: () => unawaited(_runImport()),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Exports create files you control. Imports merge into your current history so existing moments are not overwritten.',
                ),
              ],
              if (show('Backup Status')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.cloud_done_rounded,
                      title: 'Android Backup',
                      subtitle: 'Included in device transfer and Google backup',
                      color: p.green,
                      status: 'On',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.health_and_safety_rounded,
                      title: 'Data Health',
                      subtitle:
                          '${entries.length} moments - Backup $_backupAgeLine',
                      color: p.green,
                      status: _dataHealthStatus,
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.lock_rounded,
                      title: 'Encrypted Backup',
                      subtitle:
                          'Password-protected backups need a proper crypto flow before release.',
                      color: p.orange,
                      status: 'Planned',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.drive_folder_upload_rounded,
                      title: 'Google Drive Backup',
                      subtitle:
                          'Optional Drive sync needs Google sign-in and Drive permission setup.',
                      color: p.orange,
                      status: 'Planned',
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Backup Status shows what Android can already protect and which backup options still need release-ready setup.',
                ),
              ],
              if (show('Privacy & Security')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.analytics_outlined,
                      title: 'No Analytics',
                      subtitle:
                          'No analytics, ads, crash reporting, or telemetry SDKs.',
                      color: p.green,
                      status: 'None',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.wifi_rounded,
                      title: 'Network Use',
                      subtitle:
                          'Internet is only used when you check updates or enable App Notices.',
                      color: p.accent,
                      status: 'Limited',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.lock_rounded,
                      title: 'App Lock',
                      subtitle: 'Screen lock and lock timing',
                      color: p.orange,
                      onTap: () => _openCategory(
                        'App Lock',
                        parent: 'Privacy & Security',
                      ),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Privacy & Security covers what stays on-device, when the network is used, and when NoteKar asks Android to lock.',
                ),
              ],
              if (show('Help & Guides')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.menu_book_rounded,
                      title: 'Guides',
                      subtitle:
                          'Learn logging, notes, search, App Lock, and backups',
                      color: p.accent,
                      onTap: () =>
                          _openCategory('Guides', parent: 'Help & Guides'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.help_outline_rounded,
                      title: 'Help',
                      subtitle:
                          'Solutions for updates, backups, App Lock, and common issues',
                      color: p.orange,
                      onTap: () =>
                          _openCategory('Help', parent: 'Help & Guides'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Guides explain how NoteKar works. Help covers common problems and practical fixes.',
                ),
              ],
              if (show('App Lock')) _appLockPage(p),
              if (show('Advanced')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.accessibility_new_rounded,
                      title: 'Accessibility',
                      subtitle: 'Motion, touch, text, and contrast',
                      color: p.orange,
                      onTap: () =>
                          _openCategory('Accessibility', parent: 'Advanced'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.monitor_heart_rounded,
                      title: 'Diagnostics',
                      subtitle: 'Support details and current app state',
                      color: p.accent,
                      onTap: () =>
                          _openCategory('Diagnostics', parent: 'Advanced'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.health_and_safety_rounded,
                      title: 'Device Health',
                      subtitle: 'Adaptive engine and performance status',
                      color: p.accent,
                      onTap: () =>
                          _openCategory('Device Health', parent: 'Advanced'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.restart_alt_rounded,
                      title: 'Reset',
                      subtitle: 'Reset settings, data, or the whole app',
                      color: p.red,
                      onTap: () => _openCategory('Reset', parent: 'Advanced'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Advanced groups support tools and reset controls away from everyday settings.',
                ),
              ],
              if (show('Accessibility')) ...[
                SegmentedSetting(
                  key: ValueKey('haptic-style-$hapticStyle-${p.name}'),
                  p: p,
                  title: 'Haptic Style',
                  subtitle: 'Choose how NoteKar responds to key actions',
                  value: hapticStyle,
                  values: const {
                    'off': 'Off',
                    'light': 'Light',
                    'standard': 'Standard',
                  },
                  onChanged: (value) {
                    if (value == hapticStyle) return;
                    HapticFeedback.selectionClick();
                    setState(() => hapticStyle = value);
                    widget.onHapticStyle(value);
                  },
                ),
                const SizedBox(height: 10),
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.motion_photos_off_rounded,
                      title: 'Reduced Motion',
                      subtitle: 'Use simpler feedback and fewer animations',
                      color: p.green,
                      value: reduceMotion,
                      onChanged: (value) {
                        setState(() {
                          reduceMotion = value;
                          if (value) homeMenuAnimations = false;
                        });
                        widget.onReduceMotion(value);
                      },
                    ),
                    if (AdaptiveEngine().supportsBlur)
                      SettingsSwitchRow(
                        p: p,
                        icon: Icons.blur_on_rounded,
                        title: 'Enable Translucency',
                        subtitle: reduceMotion
                            ? 'Turn off Reduced Motion to enable translucency'
                            : 'Use frosted glass blur on Toolbar and Sheets',
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
                      icon: Icons.format_size_rounded,
                      title: 'Larger Text',
                      subtitle:
                          'Makes easier to read while keeping the layout stable.',
                      color: p.orange,
                      value: largeText,
                      onChanged: (value) {
                        setState(() => largeText = value);
                        widget.onLargeText(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.contrast_rounded,
                      title: 'High Contrast',
                      subtitle: 'Increase contrast for text and controls',
                      color: p.green,
                      value: highContrast,
                      onChanged: (value) {
                        setState(() => highContrast = value);
                        widget.onHighContrast(value);
                      },
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Accessibility settings are local comfort choices. Change them anytime; your saved data is not affected.',
                ),
              ],
              if (show('Reset')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.tune_rounded,
                      title: 'Reset Settings Only',
                      subtitle:
                          'Restore preferences while keeping moments and notes',
                      color: p.orange,
                      onTap: () => unawaited(_confirmResetSettings()),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.delete_outline_rounded,
                      title: 'Reset All Data',
                      subtitle: 'Erase every moment and note on this device',
                      color: p.red,
                      onTap: () => unawaited(_confirmResetAll(p)),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.restart_alt_rounded,
                      title: 'Factory Reset',
                      subtitle:
                          'Erase data and settings, then show welcome setup',
                      color: p.red,
                      onTap: () => unawaited(_confirmFactoryReset(p)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Reset is intentionally separate from everyday settings. Back up first before deleting moments or factory resetting the app.',
                  style: TextStyle(color: p.text2, fontSize: 12, height: 1.45),
                ),
              ],
              if (show('Diagnostics')) ...[
                _diagnosticsPage(p, entries, todayCount),
                SettingsPageNote(
                  p: p,
                  text:
                      'Diagnostics are for support and bug reports. Copying them does not send anything automatically.',
                ),
              ],
              if (show('Device Health')) _deviceHealthPage(p),
              if (show("What's New"))
                ChangelogSettingsPage(p: p, latestOnly: true),
              if (show('Changelog'))
                ChangelogSettingsPage(p: p, latestOnly: false),
            ],
          ),
        ),
      ),
    );
    if (!largeText) return sheet;
    return MediaQuery(data: largerTextQuery(context), child: sheet);
  }
}
