import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/changelog_dialog.dart';
import 'package:notekar/dialogs/feature_conflict_dialog.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/settings/advanced_settings_page.dart';
import 'package:notekar/dialogs/settings/app_icons_settings_page.dart';
import 'package:notekar/dialogs/settings/app_lock_settings_page.dart';
import 'package:notekar/dialogs/settings/capture_settings_page.dart';
import 'package:notekar/dialogs/settings/commits_settings_page.dart';
import 'package:notekar/dialogs/settings/data_backup_settings_page.dart';
import 'package:notekar/dialogs/settings/diagnostics_settings_page.dart';
import 'package:notekar/dialogs/settings/display_settings_page.dart';
import 'package:notekar/dialogs/settings/feedback_changelog_settings_page.dart';
import 'package:notekar/dialogs/settings/help_guides_settings_page.dart';
import 'package:notekar/dialogs/settings/legal_about_settings_page.dart';
import 'package:notekar/dialogs/settings/logging_settings_page.dart';
import 'package:notekar/dialogs/settings/moments_settings_page.dart';
import 'package:notekar/dialogs/settings/personalization_settings_page.dart';
import 'package:notekar/dialogs/settings/privacy_security_settings_page.dart';
import 'package:notekar/dialogs/settings/reminders_settings_page.dart';
import 'package:notekar/dialogs/settings/search_notes_settings_page.dart';
import 'package:notekar/dialogs/settings/security_privacy_details_sheets.dart';
import 'package:notekar/dialogs/settings/settings_dashboard_page.dart';
import 'package:notekar/dialogs/settings/sobriety_companion_settings_page.dart';
import 'package:notekar/dialogs/settings/time_reflection_settings_page.dart';
import 'package:notekar/dialogs/settings/trash_bin_settings_page.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/dialogs/time_reflection_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/network_logger.dart';
import 'package:notekar/utils/update_service.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/guide_help_rows.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    required this.isSystemLockAvailable,
    required this.privacyLockType,
    required this.onPrivacyLockTypeChanged,
    required this.updateStatus,
    this.updateInfo,
    required this.checkingUpdates,
    required this.lastUpdateCheckedAt,
    required this.entriesNotifier,
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
    required this.onResetPrivacyPin,
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
    this.useNumbersInSingle = false,
    this.resetSingleDaily = false,
    this.countOnSave = false,
    this.onUseNumbersInSingle,
    this.onResetSingleDaily,
    this.onCountOnSave,
    required this.onTranslucency,
    this.onSobrietyModeChanged,
    required this.onPrivacyLockDelay,
    required this.onExportCsv,
    required this.onExportRecentCsv,
    required this.onExportJson,
    required this.onExportBackup,
    required this.onImportBackup,
    required this.onRestoreBackupFromString,
    required this.onSaveQuickBackup,
    required this.onCheckUpdates,
    required this.onOpenLink,
    required this.onShowChangelog,
    required this.onReset,
    required this.onFactoryReset,
    required this.onResetSettings,
    required this.onRestoreSettings,
    required this.onFeedback,
    this.onOpenTrash,
    this.lastDeletedPreview,
    required this.trashEntriesNotifier,
    required this.onRestoreTrashMoment,
    required this.onRestoreAllTrash,
    required this.onDeleteTrashPermanent,
    required this.onClearTrash,
    required this.currentLocale,
    required this.onLocaleChanged,
    this.initialCategory,
  });

  final String currentLocale;
  final ValueChanged<String> onLocaleChanged;

  final String? initialCategory;
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
  final bool useNumbersInSingle;
  final bool resetSingleDaily;
  final bool countOnSave;
  final ValueChanged<bool>? onUseNumbersInSingle;
  final ValueChanged<bool>? onResetSingleDaily;
  final ValueChanged<bool>? onCountOnSave;
  final bool enableTranslucency;
  final int privacyLockDelayMinutes;
  final bool isSystemLockAvailable;
  final String privacyLockType;
  final Future<bool> Function(String value) onPrivacyLockTypeChanged;
  final String updateStatus;
  final AppUpdateInfo? updateInfo;
  final bool checkingUpdates;
  final int? lastUpdateCheckedAt;
  final ValueNotifier<List<Moment>> entriesNotifier;
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
  final Future<void> Function() onResetPrivacyPin;
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
  final ValueChanged<bool>? onSobrietyModeChanged;
  final ValueChanged<int> onPrivacyLockDelay;
  final Future<void> Function() onExportCsv;
  final Future<void> Function() onExportRecentCsv;
  final Future<void> Function() onExportJson;
  final Future<void> Function() onExportBackup;
  final Future<void> Function() onImportBackup;
  final Future<bool> Function(String content) onRestoreBackupFromString;
  final Future<void> Function() onSaveQuickBackup;
  final Future<({String status, AppUpdateInfo? info})> Function()
  onCheckUpdates;
  final ValueChanged<String> onOpenLink;
  final ValueChanged<bool> onShowChangelog;
  final Future<void> Function() onReset;
  final Future<void> Function() onFactoryReset;
  final Future<void> Function() onResetSettings;
  final Future<void> Function(Map<String, Object> snapshot) onRestoreSettings;
  final ValueChanged<String> onFeedback;
  final VoidCallback? onOpenTrash;
  final String? lastDeletedPreview;
  final ValueNotifier<List<Moment>> trashEntriesNotifier;
  final Future<void> Function(int id) onRestoreTrashMoment;
  final Future<void> Function() onRestoreAllTrash;
  final Future<void> Function(int id) onDeleteTrashPermanent;
  final Future<void> Function() onClearTrash;

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
  late bool useNumbersInSingle;
  late bool resetSingleDaily;
  late bool countOnSave;
  late bool enableTranslucency;
  late int privacyLockDelayMinutes;
  late String privacyLockType;
  late String currentLocale;
  List<NetworkLogEntry> _networkLogs = [];
  bool _loadingNetworkLogs = false;

  String? _editingReminderType;
  final TextEditingController _reminderMessageController =
      TextEditingController();
  final FocusNode _reminderMessageFocusNode = FocusNode();
  bool _autoStartCardDismissed = false;
  bool _batteryOptimizationCardDismissed = false;

  // Reminders Settings
  bool _dailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 21, minute: 0);
  bool _reflectionReminderEnabled = false;
  int _reflectionReminderIntervalMins = 60;
  bool _reflectionReminderSound = true;
  bool _inactivityReminderEnabled = false;
  int _inactivityIntervalMins = 240;
  bool _weeklyReminderEnabled = false;
  List<int> _weeklyReminderDays = [1];
  TimeOfDay _weeklyReminderTime = const TimeOfDay(hour: 21, minute: 0);
  bool _monthlyReminderEnabled = false;
  int _monthlyReminderDay = 1;
  TimeOfDay _monthlyReminderTime = const TimeOfDay(hour: 21, minute: 0);
  String _dailyReminderBody = 'Time to log a moment!';
  String _weeklyReminderBody = 'Time to log a moment!';
  String _monthlyReminderBody = 'Time to log a moment!';
  bool _hasExactAlarmPermission = true;
  bool _ignoresBatteryOptimizations = true;

  static const _fileChannel = MethodChannel('notekar/files');
  final _logger = AppLogger();

  SharedPreferences? _prefs;

  bool _betaTrack = false;
  bool obfuscateInRecents = false;
  bool showPersistentNotification = false;
  bool enableNoteOnClick = false;
  bool enableSobrietyMode = false;
  String sobrietyResetType = 'any';
  int? sobrietyCustomStartMs;
  String sobrietyMilestoneTheme = 'science';

  String _vtRatio = '0 / 60+ clean';
  String _vtStatus = 'Undetected';
  String _vtScanDate = 'July 2026';
  String _vtUrl =
      'https://www.virustotal.com/gui/file/a95a703eaf519bd0ddf1ab7839dab7a90a02150e7808882c3247cb35465a2bfe';
  String _currentBuildChannel = '';

  Future<void> _loadRemindersSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _betaTrack = _prefs?.getBool('m-update-track-beta') ?? false;
      obfuscateInRecents = _prefs?.getBool('obfuscate_in_recents') ?? false;
      showPersistentNotification =
          _prefs?.getBool('show_persistent_notification') ?? false;
      enableNoteOnClick = _prefs?.getBool('enable_note_on_click') ?? false;
      enableSobrietyMode = _prefs?.getBool('enable_sobriety_mode') ?? false;
      sobrietyResetType = _prefs?.getString('sobriety_reset_type') ?? 'any';
      sobrietyCustomStartMs = _prefs?.getInt('sobriety_custom_start_ms');
      sobrietyMilestoneTheme =
          _prefs?.getString('sobriety_milestone_theme') ?? 'science';
      _autoStartCardDismissed =
          _prefs?.getBool('notekar.autoStartCardDismissed') ?? false;
      _batteryOptimizationCardDismissed =
          _prefs?.getBool('notekar.batteryOptimizationCardDismissed') ?? false;
      _dailyReminderEnabled =
          _prefs?.getBool('reminder_daily_enabled') ?? false;
      _dailyReminderTime = TimeOfDay(
        hour: _prefs?.getInt('reminder_daily_hour') ?? 21,
        minute: _prefs?.getInt('reminder_daily_minute') ?? 0,
      );
      _dailyReminderBody =
          _prefs?.getString('reminder_daily_body') ?? 'Time to log a moment!';

      _reflectionReminderEnabled =
          _prefs?.getBool('reminder_reflection_enabled') ?? false;
      _reflectionReminderIntervalMins =
          _prefs?.getInt('reminder_reflection_interval_mins') ?? 60;
      _reflectionReminderSound =
          _prefs?.getBool('reminder_reflection_sound') ?? true;

      _inactivityReminderEnabled =
          _prefs?.getBool('reminder_inactivity_enabled') ?? false;
      _inactivityIntervalMins =
          _prefs?.getInt('reminder_inactivity_interval_mins') ?? 240;

      _weeklyReminderEnabled =
          _prefs?.getBool('reminder_weekly_enabled') ?? false;
      _weeklyReminderDays =
          (_prefs?.getStringList('reminder_weekly_days') ?? ['1'])
              .map((e) => int.parse(e))
              .toList();
      _weeklyReminderTime = TimeOfDay(
        hour: _prefs?.getInt('reminder_weekly_hour') ?? 21,
        minute: _prefs?.getInt('reminder_weekly_minute') ?? 0,
      );
      _weeklyReminderBody =
          _prefs?.getString('reminder_weekly_body') ?? 'Time to log a moment!';

      _monthlyReminderEnabled =
          _prefs?.getBool('reminder_monthly_enabled') ?? false;
      _monthlyReminderDay = _prefs?.getInt('reminder_monthly_day') ?? 1;
      _monthlyReminderTime = TimeOfDay(
        hour: _prefs?.getInt('reminder_monthly_hour') ?? 21,
        minute: _prefs?.getInt('reminder_monthly_minute') ?? 0,
      );
      _monthlyReminderBody =
          _prefs?.getString('reminder_monthly_body') ?? 'Time to log a moment!';
    });
    try {
      final granted =
          await _fileChannel.invokeMethod<bool>('canScheduleExactAlarms') ??
          true;
      final ignores =
          await _fileChannel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          true;
      if (mounted) {
        setState(() {
          _hasExactAlarmPermission = granted;
          _ignoresBatteryOptimizations = ignores;
        });
      }
    } catch (_) {}
    _loadCachedVirusTotalInfo();
    final lastVtFetchedVersion = _prefs?.getString(
      'notekar.vt_last_fetched_version',
    );
    if (lastVtFetchedVersion != appVersion) {
      _fetchLatestVirusTotalInfo();
    }
  }

  void _loadCachedVirusTotalInfo() {
    if (_prefs == null) return;
    setState(() {
      _vtRatio = _prefs!.getString('notekar.vt_ratio') ?? '0 / 60+ clean';
      _vtStatus = _prefs!.getString('notekar.vt_status') ?? 'Undetected';
      _vtScanDate = _prefs!.getString('notekar.vt_scandate') ?? 'July 2026';
      _vtUrl =
          _prefs!.getString('notekar.current_virustotal_url') ??
          'https://www.virustotal.com/gui/file/a95a703eaf519bd0ddf1ab7839dab7a90a02150e7808882c3247cb35465a2bfe';
      _currentBuildChannel =
          _prefs!.getString('notekar.current_build_channel') ?? '';
    });
  }

  Future<void> _fetchLatestVirusTotalInfo() async {
    try {
      final info = await UpdateService().fetchCurrentVirusTotalInfo(
        trackBeta: _betaTrack,
      );
      if (info != null && mounted) {
        final malicious = info['malicious'] as int? ?? 0;
        final total = info['total'] as int? ?? 68;
        final scanDateUnix = info['scanDate'] as int? ?? 0;
        final url = info['url'] as String? ?? _vtUrl;

        String ratio = '$malicious / $total clean';
        if (malicious == 0) {
          ratio = '0 / 60+ clean';
        }

        String status = malicious == 0 ? 'Undetected' : 'Detected';

        String scanDateStr = 'July 2026';
        if (scanDateUnix > 0) {
          final date = DateTime.fromMillisecondsSinceEpoch(scanDateUnix * 1000);
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          scanDateStr = '${date.day} ${months[date.month - 1]} ${date.year}';
        }

        final channel =
            info['channel'] as String? ?? (_betaTrack ? 'beta' : 'stable');

        setState(() {
          _vtRatio = ratio;
          _vtStatus = status;
          _vtScanDate = scanDateStr;
          _vtUrl = url;
          _currentBuildChannel = channel;
        });

        if (_prefs != null) {
          await _prefs!.setString('notekar.vt_ratio', ratio);
          await _prefs!.setString('notekar.vt_status', status);
          await _prefs!.setString('notekar.vt_scandate', scanDateStr);
          await _prefs!.setString('notekar.current_virustotal_url', url);
          await _prefs!.setString('notekar.current_build_channel', channel);
          await _prefs!.setString(
            'notekar.vt_last_fetched_version',
            appVersion,
          );
        }
      }
    } catch (_) {}
  }

  String _getRemindersStatus() {
    final active =
        _dailyReminderEnabled ||
        _inactivityReminderEnabled ||
        _weeklyReminderEnabled ||
        _monthlyReminderEnabled;
    return active ? 'Active'.localized(context) : 'Inactive'.localized(context);
  }

  Future<void> _syncReminder(String id) async {
    if (_prefs == null) return;
    try {
      if (id == 'daily') {
        if (_dailyReminderEnabled) {
          await _fileChannel.invokeMethod('scheduleReminder', {
            'id': 'reminder_daily',
            'type': 'daily',
            'hour': _dailyReminderTime.hour,
            'minute': _dailyReminderTime.minute,
            'title': 'Logging Reminder'.localized(context),
            'body': _dailyReminderBody == 'Time to log a moment!'
                ? _dailyReminderBody.localized(context)
                : _dailyReminderBody,
          });
        } else {
          await _fileChannel.invokeMethod('cancelReminder', {
            'id': 'reminder_daily',
          });
        }
      } else if (id == 'reflection') {
        if (_reflectionReminderEnabled) {
          await _fileChannel.invokeMethod('scheduleReminder', {
            'id': 'reminder_reflection',
            'type': 'reflection',
            'intervalMinutes': _reflectionReminderIntervalMins,
            'title': 'Time Reflection'.localized(context),
            'body': 'A new hour has passed. Take a mindful pause and reflect.'
                .localized(context),
          });
        } else {
          await _fileChannel.invokeMethod('cancelReminder', {
            'id': 'reminder_reflection',
          });
        }
      } else if (id == 'inactivity') {
        if (_inactivityReminderEnabled) {
          await _fileChannel.invokeMethod('scheduleReminder', {
            'id': 'reminder_inactivity',
            'type': 'inactivity',
            'intervalMinutes': _inactivityIntervalMins,
            'title': 'Logging Reminder'.localized(context),
            'body': 'Time to log a moment!'.localized(context),
          });
        } else {
          await _fileChannel.invokeMethod('cancelReminder', {
            'id': 'reminder_inactivity',
          });
        }
      } else if (id == 'weekly') {
        if (_weeklyReminderEnabled) {
          await _fileChannel.invokeMethod('scheduleReminder', {
            'id': 'reminder_weekly',
            'type': 'weekly',
            'hour': _weeklyReminderTime.hour,
            'minute': _weeklyReminderTime.minute,
            'daysOfWeek': _weeklyReminderDays,
            'title': 'Logging Reminder'.localized(context),
            'body': _weeklyReminderBody == 'Time to log a moment!'
                ? _weeklyReminderBody.localized(context)
                : _weeklyReminderBody,
          });
        } else {
          await _fileChannel.invokeMethod('cancelReminder', {
            'id': 'reminder_weekly',
          });
        }
      } else if (id == 'monthly') {
        if (_monthlyReminderEnabled) {
          await _fileChannel.invokeMethod('scheduleReminder', {
            'id': 'reminder_monthly',
            'type': 'monthly',
            'hour': _monthlyReminderTime.hour,
            'minute': _monthlyReminderTime.minute,
            'dayOfMonth': _monthlyReminderDay,
            'title': 'Logging Reminder'.localized(context),
            'body': _monthlyReminderBody == 'Time to log a moment!'
                ? _monthlyReminderBody.localized(context)
                : _monthlyReminderBody,
          });
        } else {
          await _fileChannel.invokeMethod('cancelReminder', {
            'id': 'reminder_monthly',
          });
        }
      }
    } catch (e, stack) {
      _logger.error('Failed to sync reminder: $id', e, stack);
    }
  }

  void _openReminderMessageEditor(String type) {
    setState(() {
      _editingReminderType = type;
      String initialText = '';
      if (type == 'daily') initialText = _dailyReminderBody;
      if (type == 'weekly') initialText = _weeklyReminderBody;
      if (type == 'monthly') initialText = _monthlyReminderBody;
      _reminderMessageController.text = initialText;
    });
    _openCategory('Reminder Message');
  }

  Future<DateTime?> _showIOSDateTimePicker(
    BuildContext context,
    DateTime initialDateTime,
  ) async {
    final p = paletteFor(theme);
    DateTime selectedDateTime = initialDateTime;

    return showModalBottomSheet<DateTime>(
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
                    'Select Date and Time',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: p.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: initialDateTime,
                        maximumDate: DateTime.now(),
                        onDateTimeChanged: (DateTime dateTime) {
                          selectedDateTime = dateTime;
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          style: TextButton.styleFrom(
                            foregroundColor: p.text2,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Cancel'.localized(context)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, selectedDateTime),
                          style: FilledButton.styleFrom(
                            backgroundColor: p.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text('Confirm'.localized(context)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<TimeOfDay?> _showIOSTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
  ) async {
    final p = paletteFor(theme);
    TimeOfDay selectedTime = initialTime;

    return showModalBottomSheet<TimeOfDay>(
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
                    'Select Time'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: p.text,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime(
                          2026,
                          1,
                          1,
                          initialTime.hour,
                          initialTime.minute,
                        ),
                        onDateTimeChanged: (DateTime dateTime) {
                          selectedTime = TimeOfDay(
                            hour: dateTime.hour,
                            minute: dateTime.minute,
                          );
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          style: TextButton.styleFrom(
                            foregroundColor: p.text2,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'cancel'.localized(context),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, selectedTime),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: p.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            'okay'.localized(context),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: math.max(
                      16.0,
                      MediaQuery.of(context).padding.bottom,
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

  List<Moment> get entries => widget.entriesNotifier.value;

  List<Moment> get _trash => widget.trashEntriesNotifier.value;

  String updateStatus = '';
  AppUpdateInfo? updateInfo;
  bool checkingUpdates = false;

  // Error handling caches
  void Function(FlutterErrorDetails)? _oldOnError;
  bool Function(Object, StackTrace)? _oldPlatformOnError;

  final TextEditingController _settingsSearchController =
      TextEditingController();
  final FocusNode _settingsSearchFocusNode = FocusNode();
  String _settingsQuery = '';

  final TextEditingController _noteSearchController = TextEditingController();
  final FocusNode _noteSearchFocusNode = FocusNode();
  String _noteQuery = '';

  List<String> _recentSearches = [];
  List<String> _recentNoteSearches = [];

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
    useNumbersInSingle = widget.useNumbersInSingle;
    resetSingleDaily = widget.resetSingleDaily;
    countOnSave = widget.countOnSave;
    enableTranslucency = widget.enableTranslucency;
    privacyLockDelayMinutes = widget.privacyLockDelayMinutes;
    privacyLockType = widget.privacyLockType;
    currentLocale = widget.currentLocale;

    if (widget.initialCategory != null) {
      category = widget.initialCategory;
      _categoryStack.clear();
    }

    widget.entriesNotifier.addListener(_onEntriesChanged);
    widget.trashEntriesNotifier.addListener(_onEntriesChanged);

    updateStatus = widget.updateStatus;
    updateInfo = widget.updateInfo;
    checkingUpdates = widget.checkingUpdates;

    _loadRecentSearches();
    _loadRecentNoteSearches();
    _loadRemindersSettings();

    _settingsSearchFocusNode.addListener(() {
      if (_settingsSearchFocusNode.hasFocus && category != 'Search') {
        _openCategory('Search');
      }
    });
    _oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      _oldOnError?.call(details);
      if (mounted) {
        _showErrorReporterDialog(details.exception, details.stack);
      }
    };

    _oldPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      if (mounted) {
        _showErrorReporterDialog(error, stack);
        return true;
      }
      return _oldPlatformOnError?.call(error, stack) ?? false;
    };
  }

  @override
  void dispose() {
    widget.entriesNotifier.removeListener(_onEntriesChanged);
    widget.trashEntriesNotifier.removeListener(_onEntriesChanged);
    _activeController.dispose();
    _settingsSearchController.dispose();
    _settingsSearchFocusNode.dispose();
    _noteSearchController.dispose();
    _noteSearchFocusNode.dispose();
    _reminderMessageController.dispose();
    _reminderMessageFocusNode.dispose();

    FlutterError.onError = _oldOnError;
    PlatformDispatcher.instance.onError = _oldPlatformOnError;

    super.dispose();
  }

  Future<({String status, AppUpdateInfo? info})> _runCheckUpdates() async {
    if (await _isOffline()) {
      _showCustomAlert(
        p: paletteFor(
          theme,
          highContrast: highContrast,
          accentName: accentColor,
        ),
        title: 'Offline',
        message:
            'No internet connection detected. Please connect to the internet to check for updates.',
        icon: Icons.wifi_off_rounded,
        iconColor: Colors.orange,
      );
      return (status: 'Offline', info: null);
    }

    setState(() {
      checkingUpdates = true;
    });
    try {
      final res = await widget.onCheckUpdates();
      if (mounted) {
        setState(() {
          updateStatus = res.status;
          updateInfo = res.info;
          checkingUpdates = false;
        });
      }
      return res;
    } catch (_) {
      if (mounted) {
        setState(() {
          checkingUpdates = false;
        });
      }
      return (status: 'Update check failed', info: null);
    }
  }

  Future<void> _saveTrackPreference(bool beta) async {
    final p = paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );

    // Show transition dialog with iOS style spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: p.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: p.border.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(radius: 16, color: p.accent),
                  const SizedBox(height: 16),
                  Text(
                    beta
                        ? 'Switching to beta build...'.localized(context)
                        : 'Switching to stable build...'.localized(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Dismiss popup overlay
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    setState(() {
      _betaTrack = beta;
    });
    if (_prefs != null) {
      await _prefs!.setBool('m-update-track-beta', beta);
    }
    await _runCheckUpdates();
  }

  void _onEntriesChanged() {
    if (mounted) {
      setState(() {});
    }
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
      'app_icons/purple.png',
    ]) {
      precacheImage(AssetImage(path), context);
    }
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
    final updated = [
      term,
      ..._recentSearches.where((t) => t != term),
    ].take(5).toList();
    await prefs.setStringList('recent_settings_searches', updated);
    setState(() => _recentSearches = updated);
  }

  Future<void> _loadRecentNoteSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentNoteSearches = prefs.getStringList('recent_note_searches') ?? [];
    });
  }

  Future<void> _saveRecentNoteSearch(String term) async {
    if (term.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [
      term,
      ..._recentNoteSearches.where((t) => t != term),
    ].take(5).toList();
    await prefs.setStringList('recent_note_searches', updated);
    setState(() => _recentNoteSearches = updated);
  }

  void _openCategory(String name, {String? parent}) {
    if (name == 'Network Monitor') {
      _loadNetworkLogs();
    }
    setState(() {
      _prevStackLength = _categoryStack.length;
      if (category != null) _categoryStack.add(category!);
      category = name;
    });
    if (name == 'Search') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _settingsSearchFocusNode.requestFocus();
      });
    } else if (name == 'Search Notes') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _noteSearchFocusNode.requestFocus();
      });
    }
  }

  void _popCategory() {
    if (category == 'Search') {
      setState(() {
        _settingsQuery = '';
        _settingsSearchController.clear();
      });
      _settingsSearchFocusNode.unfocus();
    } else if (category == 'Search Notes') {
      setState(() {
        _noteQuery = '';
        _noteSearchController.clear();
      });
      _noteSearchFocusNode.unfocus();
    }
    if (_categoryStack.isEmpty) {
      if (category == null) {
        Navigator.pop(context);
      } else {
        setState(() {
          _prevStackLength = 0;
          category = null;
        });
      }
    } else {
      setState(() {
        _prevStackLength = _categoryStack.length + 1;
        category = _categoryStack.removeLast();
      });
    }
  }

  String get _updateSubtitle {
    if (checkingUpdates) return 'Checking...';
    return updateStatus.isEmpty ? 'Up to date' : updateStatus;
  }

  bool get _updateAvailable => updateStatus.contains('Update available');

  String get _dataHealthStatus {
    final entries = this.entries;
    if (entries.isEmpty) return 'No data';
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = widget.lastSavedAt ?? 0;
    if (now - last < 1000 * 60 * 60 * 24) return 'Healthy';
    return 'Action required';
  }

  List<
    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
      String kind,
      bool? boolValue,
      ValueChanged<bool>? onBoolChanged,
      String? status,
    })
  >
  _allSettingsOptions() {
    final String deletedSubtitle =
        (widget.lastDeletedPreview != null &&
            widget.lastDeletedPreview!.isNotEmpty)
        ? widget.lastDeletedPreview!
        : 'Restore or permanently remove deleted moments';

    final p = paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );

    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
      String kind,
      bool? boolValue,
      ValueChanged<bool>? onBoolChanged,
      String? status,
    })
    item({
      required String title,
      required String subtitle,
      required String category,
      required IconData icon,
      required List<String> keywords,
      required String kind,
      bool? boolValue,
      ValueChanged<bool>? onBoolChanged,
      String? status,
    }) => (
      title: title,
      subtitle: subtitle,
      category: category,
      icon: icon,
      keywords: keywords,
      kind: kind,
      boolValue: boolValue,
      onBoolChanged: onBoolChanged,
      status: status,
    );

    return [
      item(
        title: 'App Version',
        subtitle: 'The current software version installed',
        category: 'Advanced',
        icon: Icons.info_outline_rounded,
        keywords: [
          'version',
          'app version',
          'what is the version',
          'whats is the version',
          'build version',
          'software version',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'v$appVersion',
      ),
      item(
        title: 'Build Number',
        subtitle: 'The compiled internal build identifier',
        category: 'Advanced',
        icon: Icons.tag_rounded,
        keywords: [
          'build number',
          'build id',
          'build identifier',
          'compilation',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: kAppBuildNumber,
      ),
      item(
        title: 'Release Date',
        subtitle: 'When the current version was compiled',
        category: 'Advanced',
        icon: Icons.calendar_today_rounded,
        keywords: [
          'build date',
          'release date',
          'when was the current version released',
          'released date',
          'compiled date',
          'updated date',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: appBuildDate,
      ),
      item(
        title: 'Developer & Creator',
        subtitle: 'Designed & developed by Dheeraj',
        category: 'Advanced',
        icon: Icons.code_rounded,
        keywords: [
          'developer',
          'author',
          'who is the developer',
          'who is the author',
          'creator',
          'who made this app',
          'dheeraj',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Dheeraj',
      ),
      item(
        title: 'Open Source Codebase',
        subtitle: 'Licensed under MIT. Code available on GitHub',
        category: 'Advanced',
        icon: Icons.folder_open_rounded,
        keywords: [
          'is the app opensource',
          'opensource',
          'open source',
          'github code',
          'source code',
          'free software',
          'repository',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'MIT License',
      ),
      item(
        title: 'Security & Integrity',
        subtitle: 'Cryptographically verified with 0/60+ VirusTotal detections',
        category: 'Privacy & Security',
        icon: Icons.gpp_good_rounded,
        keywords: [
          'is the app secure',
          'is the app safe to use',
          'safe',
          'secure',
          'virus',
          'malware',
          'safety',
          'audited',
          'virustotal',
          'clean',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'Verified Safe',
      ),
      item(
        title: 'Privacy & Local Storage',
        subtitle: '100% Offline-first. Zero trackers. Zero data collection',
        category: 'Privacy & Security',
        icon: Icons.shield_rounded,
        keywords: [
          'is the app private',
          'privacy policy',
          'trackers',
          'data collection',
          'spyware',
          'offline privacy',
          'private',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: '100% Offline',
      ),
      item(
        title: 'Network Monitor',
        subtitle: 'Audit application network traffic logs',
        category: 'Advanced',
        icon: Icons.network_check_rounded,
        keywords: [
          'network monitor',
          'traffic',
          'internet',
          'data usage',
          'does the app use internet',
          'is the app sending data',
          'where does the app send data',
          'network traffic',
          'network logs',
          'wifi',
          'mobile data',
          'api logs',
          'requests',
          'privacy log',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
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
      item(
        title: 'Language',
        subtitle: 'Select application language',
        category: 'Language',
        icon: Icons.language_rounded,
        keywords: [
          'language',
          'locale',
          'translate',
          'multilingual',
          'internationalization',
          'translations',
          'i18n',
          'l10n',
          'english',
          'french',
          'francais',
          'hindi',
          'spanish',
          'espanol',
          'german',
          'deutsch',
          'japanese',
          'nihongo',
          'russian',
          'russkiy',
          'arabic',
          'portuguese',
          'italian',
          'chinese',
          'korean',
          'turkish',
          'dutch',
          'polish',
          'swedish',
          'indonesian',
          'vietnamese',
          'thai',
          'ukrainian',
          'greek',
          'czech',
          'romanian',
          'hungarian',
          'danish',
          'finnish',
          'norwegian',
          'hebrew',
          'bengali',
          'marathi',
          'telugu',
          'tamil',
          'gujarati',
          'urdu',
          'kannada',
          'malayalam',
          'punjabi',
          'swahili',
          'persian',
          'malay',
          'tagalog',
          'filipino',
          'slovak',
          'bulgarian',
          'croatian',
          'serbian',
          'lithuanian',
          'slovenian',
          'latvian',
          'estonian',
          'basque',
          'catalan',
          'welsh',
          'irish',
          'icelandic',
          'albanian',
          'macedonian',
          'armenian',
          'georgian',
          'numerals',
          'devanagari',
          'currency',
        ],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: switch (currentLocale) {
          'en' => 'English',
          'fr' => 'Français',
          'hi' => 'हिन्दी',
          'es' => 'Español',
          'de' => 'Deutsch',
          'ja' => '日本語',
          'ru' => 'Русский',
          _ => 'System Default',
        },
      ),
      item(
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
      item(
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
      item(
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
      item(
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
      item(
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
      item(
        title: 'Live Icon Motion',
        subtitle: 'Physics-based icon animations on the home screen',
        category: 'Display',
        icon: Icons.motion_photos_auto_rounded,
        keywords: ['motion', 'animation', 'icon', 'physics', 'live', 'effects'],
        kind: 'switch',
        boolValue: homeMenuAnimations,
        onBoolChanged: (bool value) {
          widget.onHomeMenuAnimations(value).then((applied) {
            if (!mounted) return;
            setState(() {
              homeMenuAnimations = applied ? value : false;
            });
          });
        },
        status: null,
      ),
      item(
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
      item(
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
      item(
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
      item(
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
      item(
        title: 'App Icons',
        subtitle: 'Personalize with 8 handcrafted luxury editions',
        category: 'App Icons',
        icon: Icons.apps_rounded,
        keywords: [
          'icon',
          'launcher',
          'home screen',
          'app icon',
          'aurora',
          'midnight',
          'sapphire',
          'imperial',
          'emerald',
          'sunset',
          'crimson',
          'amethyst',
          'logo',
        ],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: switch (appIconStyle) {
          'default' => 'Aurora',
          'black' => 'Midnight',
          'blue' => 'Sapphire',
          'gold' => 'Imperial',
          'green' => 'Emerald',
          'orange' => 'Sunset',
          'red' => 'Crimson',
          'purple' => 'Amethyst',
          _ => 'Aurora',
        },
      ),
      item(
        title: 'Developer Options',
        subtitle: 'Diagnostics, device health, network monitor, and commits',
        category: 'Developer Options',
        icon: Icons.developer_mode_rounded,
        keywords: [
          'developer',
          'options',
          'debug',
          'commits',
          'diagnostics',
          'device health',
          'network monitor',
          'logs',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
        title: 'Sobriety Tracker',
        subtitle: 'Track recovery streak, milestone badges, and export cards',
        category: 'Sobriety',
        icon: Icons.spa_rounded,
        keywords: [
          'sobriety',
          'tracker',
          'days sober',
          'milestones',
          'streak',
          'badges',
          'celebration',
          'pledge',
          'clean',
          'recovery',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: enableSobrietyMode ? 'Active' : 'Off',
      ),
      item(
        title: 'Dashboard',
        subtitle: 'Interactive summaries, grids, trends, and correlations',
        category: 'Dashboard',
        icon: Icons.dashboard_customize_outlined,
        keywords: [
          'dashboard',
          'analytics',
          'heatmap',
          'trends',
          'insights',
          'graphs',
          'correlation',
          'habits',
          'charts',
          'summary',
          'history grid',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
        title: 'Logging',
        subtitle: 'Configure default mode, tap cooldowns, and reminders',
        category: 'Logging',
        icon: Icons.bolt_rounded,
        keywords: [
          'logging',
          'captures',
          'moments',
          'default mode',
          'cooldown',
          'intervals',
          'startup',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: defaultMode == 'single' ? 'Single' : 'Two-Way',
      ),
      item(
        title: 'Startup Mode',
        subtitle: 'Default mode when opening the app',
        category: 'Capture',
        icon: Icons.bolt_rounded,
        keywords: [
          'startup',
          'mode',
          'default',
          'capture',
          'two-way',
          'single',
        ],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: defaultMode == 'single' ? 'Single' : 'Two-Way',
      ),
      item(
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
      item(
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
      item(
        title: 'Compact History',
        subtitle: 'Denser rows for scanning many moments',
        category: 'Moments',
        icon: Icons.view_agenda_rounded,
        keywords: ['compact', 'history', 'density', 'list', 'rows'],
        kind: 'switch',
        boolValue: compactHistory,
        onBoolChanged: (bool value) async {
          if (value && useNumbersInSingle) {
            final confirmed = await showFeatureConflictDialog(
              context,
              p: p,
              title: 'Turn Off Single Numbers?',
              message:
                  'Compact History cannot be enabled while Single Moment Numbering is active. Disable Single Numbers to use compact rows.',
              confirmLabel: 'Turn Off & Enable',
              icon: Icons.compress_rounded,
              iconColor: p.accent,
            );
            if (!confirmed) return;
            setState(() => useNumbersInSingle = false);
            widget.onUseNumbersInSingle?.call(false);
          }
          setState(() {
            compactHistory = value;
            historyDensity = value ? 'compact' : 'comfortable';
          });
          widget.onCompactHistory(value);
          widget.onHistoryDensity(historyDensity);
        },
        status: null,
      ),
      item(
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
      item(
        title: 'Note on Click',
        subtitle:
            'Tap a moment to view or edit its note, and long-press to select for duration.',
        category: 'Moments',
        icon: Icons.edit_note_rounded,
        keywords: [
          'note',
          'click',
          'tap',
          'history',
          'edit',
          'select',
          'long-press',
        ],
        kind: 'switch',
        boolValue: enableNoteOnClick,
        onBoolChanged: (bool value) async {
          if (_prefs != null) {
            await _prefs!.setBool('enable_note_on_click', value);
          }
          setState(() => enableNoteOnClick = value);
        },
        status: null,
      ),
      item(
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
      item(
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
      item(
        title: 'Use Numbers in Single',
        subtitle:
            'Display sequential 2-digit numbers (00–99) instead of icons in single history moments',
        category: 'Moments',
        icon: Icons.pin_outlined,
        keywords: [
          'single',
          'numbers',
          'counter',
          'digits',
          'history',
          'moments',
          '00',
        ],
        kind: 'switch',
        boolValue: useNumbersInSingle,
        onBoolChanged: (bool value) async {
          if (value && compactHistory) {
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
            setState(() {
              compactHistory = false;
              historyDensity = 'comfortable';
            });
            widget.onCompactHistory(false);
            widget.onHistoryDensity('comfortable');
          }
          setState(() => useNumbersInSingle = value);
          widget.onUseNumbersInSingle?.call(value);
        },
        status: null,
      ),
      item(
        title: 'Reset Daily',
        subtitle:
            'Restart single count from 00 every calendar day while preserving past history',
        category: 'Moments',
        icon: Icons.restart_alt_rounded,
        keywords: [
          'reset',
          'daily',
          'midnight',
          'single',
          'counter',
          'day',
          'history',
        ],
        kind: 'switch',
        boolValue: resetSingleDaily,
        onBoolChanged: (bool value) {
          setState(() => resetSingleDaily = value);
          widget.onResetSingleDaily?.call(value);
        },
        status: null,
      ),
      item(
        title: 'Enable Count on Save',
        subtitle:
            'Show the 2-digit count on the tap pulse animation instead of "SINGLE saved"',
        category: 'Moments',
        icon: Icons.touch_app_outlined,
        keywords: [
          'save',
          'count',
          'timer',
          'pulse',
          'single',
          'feedback',
          'tap',
        ],
        kind: 'switch',
        boolValue: countOnSave,
        onBoolChanged: (bool value) {
          setState(() => countOnSave = value);
          widget.onCountOnSave?.call(value);
        },
        status: null,
      ),
      item(
        title: 'Trash Bin',
        subtitle: deletedSubtitle,
        category: 'Logging',
        icon: Icons.delete_outline_rounded,
        keywords: ['trash', 'deleted', 'restore', 'remove', 'history', 'bin'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: '${_trash.length} items',
      ),
      item(
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
        status: _betaTrack ? 'Beta' : 'Stable',
      ),
      item(
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
      item(
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
      item(
        title: 'Update Track',
        subtitle: 'Choose between Stable and Beta releases',
        category: 'Updates & Notices',
        icon: Icons.track_changes_rounded,
        keywords: ['update', 'track', 'beta', 'stable', 'release', 'notices'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: _betaTrack ? 'Beta' : 'Stable',
      ),
      item(
        title: 'VirusTotal Scan',
        subtitle: 'Dynamic scan report, security ratio, and signature status',
        category: 'Updates & Notices',
        icon: Icons.security_rounded,
        keywords: [
          'security',
          'virustotal',
          'scan',
          'malicious',
          'clean',
          'undetected',
          'ratio',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _vtRatio,
      ),
      item(
        title: 'Offline Commits Cache',
        subtitle: 'View downloaded update commits feed offline',
        category: 'Developer Options',
        icon: Icons.history_rounded,
        keywords: [
          'commits',
          'cache',
          'github',
          'history',
          'feed',
          'offline',
          'developer',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _prefs != null && _prefs!.containsKey('notekar.commits_cache')
            ? 'Cached'
            : 'Empty',
      ),
      item(
        title: 'Backup & Export',
        subtitle:
            'CSV, JSON, download, restore, import, file, reminder, health',
        category: 'Logging',
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
      item(
        title: 'Backup Status',
        subtitle: 'Android backup, health, encryption, and Drive plans',
        category: 'Logging',
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
      item(
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
          'virustotal',
          'vt',
          'sha-256',
          'checksum',
          'safety verification',
          'malware scan',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: privacyLock ? 'On' : 'Off',
      ),
      item(
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
        onBoolChanged: (bool value) {
          if (!value) {
            widget.onPrivacyLock(false).then((_) {
              if (mounted) setState(() => privacyLock = false);
            });
            return;
          }
          widget.onPrivacyLock(true).then((changed) {
            if (changed && mounted) {
              setState(() => privacyLock = true);
            }
          });
        },
        status: null,
      ),
      item(
        title: 'Hide App Content',
        subtitle:
            'Obfuscate screens and block screenshots in the system switcher',
        category: 'Privacy & Security',
        icon: Icons.screenshot_rounded,
        keywords: [
          'hide content',
          'recents',
          'app switcher',
          'obfuscate',
          'screenshot',
          'prevent screenshots',
          'privacy screen',
        ],
        kind: 'switch',
        boolValue: obfuscateInRecents,
        onBoolChanged: (bool value) async {
          if (_prefs != null) {
            await _prefs!.setBool('obfuscate_in_recents', value);
          }
          setState(() => obfuscateInRecents = value);
          try {
            await const MethodChannel(
              'notekar/files',
            ).invokeMethod<void>('setObfuscateInRecents', {'enabled': value});
          } catch (_) {}
        },
        status: null,
      ),
      item(
        title: 'Persistent Control',
        subtitle:
            'Show a sticky notification in the drawer to log check-in/out from lock screen',
        category: 'Logging',
        icon: Icons.notification_important_rounded,
        keywords: [
          'control panel',
          'persistent',
          'notification',
          'lock screen',
          'lockscreen log',
          'sticky notification',
          'quick log notification',
        ],
        kind: 'switch',
        boolValue: showPersistentNotification,
        onBoolChanged: (bool value) async {
          if (_prefs != null) {
            await _prefs!.setBool('show_persistent_notification', value);
          }
          setState(() => showPersistentNotification = value);
          try {
            await const MethodChannel('notekar/files').invokeMethod<void>(
              'setPersistentControlPanel',
              {'enabled': value},
            );
          } catch (_) {}
        },
        status: null,
      ),
      if (privacyLock && widget.isSystemLockAvailable)
        item(
          title: 'Configure Lock',
          subtitle: 'Choose between System Lock or In-App PIN',
          category: 'Configure Lock',
          icon: Icons.security_rounded,
          keywords: [
            'configure lock',
            'system lock',
            'in-app pin',
            'custom lock',
            'change passcode',
            'biometric selector',
            'pin type',
          ],
          kind: 'nav',
          boolValue: null,
          onBoolChanged: null,
          status: privacyLockType == 'system' ? 'System Lock' : 'In-App PIN',
        ),
      if (privacyLock)
        item(
          title: 'When to Lock',
          subtitle: 'Change screen lock timing delay',
          category: 'App Lock',
          icon: Icons.timer_rounded,
          keywords: [
            'delay',
            'lock timing',
            'lock delay',
            'immediately',
            'after 1 minute',
            'when to lock',
          ],
          kind: 'nav',
          boolValue: null,
          onBoolChanged: null,
          status: privacyLockDelayMinutes == 0
              ? 'Immediately'
              : 'After $privacyLockDelayMinutes Min',
        ),
      item(
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
      item(
        title: 'Diagnostics',
        subtitle: 'Version, storage, backup, update status',
        category: 'Diagnostics',
        icon: Icons.monitor_heart_rounded,
        keywords: ['debug', 'support', 'info', 'bug', 'copy', 'logs'],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
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
      item(
        title: 'Network Monitor',
        subtitle: 'Audit application network traffic logs',
        category: 'Network Monitor',
        icon: Icons.network_check_rounded,
        keywords: [
          'network monitor',
          'traffic',
          'internet',
          'data usage',
          'audit',
          'privacy log',
          'api requests',
          'wifi',
          'bytes',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: 'View',
      ),
      item(
        title: 'Reset All Data',
        subtitle: 'Erase every moment and note',
        category: 'Reset',
        icon: Icons.delete_outline_rounded,
        keywords: [
          'clear',
          'erase',
          'delete everything',
          'factory reset',
          'wipe',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: null,
      ),
      item(
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
      item(
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
      item(
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
      item(
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
      item(
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
      item(
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
      item(
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
      item(
        title: 'Reminders',
        subtitle:
            'Daily, inactivity, weekly, and monthly notification reminders',
        category: 'Reminders',
        icon: Icons.notifications_active_outlined,
        keywords: [
          'reminders',
          'notifications',
          'daily',
          'weekly',
          'monthly',
          'inactivity',
          'alerts',
          'log',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _getRemindersStatus(),
      ),
      item(
        title: 'Daily Reminder',
        subtitle: 'Toggle daily logging reminder alerts',
        category: 'Reminders',
        icon: Icons.alarm_rounded,
        keywords: ['daily', 'reminder', 'alarm', 'notification', 'schedule'],
        kind: 'switch',
        boolValue: _dailyReminderEnabled,
        onBoolChanged: (bool value) async {
          setState(() => _dailyReminderEnabled = value);
          await _prefs?.setBool('reminder_daily_enabled', value);
          await _syncReminder('daily');
        },
        status: null,
      ),
      item(
        title: 'Inactivity Reminder',
        subtitle: 'Toggle inactivity-based timestamp reminders',
        category: 'Reminders',
        icon: Icons.timer_off_outlined,
        keywords: ['inactivity', 'inactive', 'timer', 'alert', 'reminders'],
        kind: 'switch',
        boolValue: _inactivityReminderEnabled,
        onBoolChanged: (bool value) async {
          setState(() => _inactivityReminderEnabled = value);
          await _prefs?.setBool('reminder_inactivity_enabled', value);
          await _syncReminder('inactivity');
        },
        status: null,
      ),
      item(
        title: 'Weekly Reminder',
        subtitle: 'Toggle weekly notification alerts',
        category: 'Reminders',
        icon: Icons.calendar_view_week_rounded,
        keywords: ['weekly', 'days', 'sunday', 'monday', 'reminders'],
        kind: 'switch',
        boolValue: _weeklyReminderEnabled,
        onBoolChanged: (bool value) async {
          setState(() => _weeklyReminderEnabled = value);
          await _prefs?.setBool('reminder_weekly_enabled', value);
          await _syncReminder('weekly');
        },
        status: null,
      ),
      item(
        title: 'Time Reflection & Mindfulness',
        subtitle:
            'Full-screen hourly mindfulness prompts and time awareness alerts',
        category: 'Time Reflection',
        icon: Icons.self_improvement_rounded,
        keywords: [
          'reflection',
          'mindfulness',
          'hourly',
          'time',
          'breath',
          'chime',
          'alarm',
          'alert',
        ],
        kind: 'nav',
        boolValue: null,
        onBoolChanged: null,
        status: _reflectionReminderEnabled
            ? 'Active · Every ${_reflectionReminderIntervalMins == 60 ? '1 Hour' : '$_reflectionReminderIntervalMins Mins'}'
            : 'Disabled',
      ),
      item(
        title: 'Monthly Reminder',
        subtitle: 'Toggle monthly notification alerts',
        category: 'Reminders',
        icon: Icons.calendar_month_rounded,
        keywords: ['monthly', 'month', 'days', 'reminders'],
        kind: 'switch',
        boolValue: _monthlyReminderEnabled,
        onBoolChanged: (bool value) async {
          setState(() => _monthlyReminderEnabled = value);
          await _prefs?.setBool('reminder_monthly_enabled', value);
          await _syncReminder('monthly');
        },
        status: null,
      ),
    ];
  }

  List<
    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
      String kind,
      bool? boolValue,
      ValueChanged<bool>? onBoolChanged,
      String? status,
    })
  >
  get _settingsSearchResults {
    final query = _settingsQuery.trim().toLowerCase();
    if (query.isEmpty) return [];

    final all = _allSettingsOptions();

    return all.where((item) {
      final title = item.title.toLowerCase();
      final titleLoc = item.title.localized(context).toLowerCase();
      final subtitle = item.subtitle.toLowerCase();
      final subtitleLoc = item.subtitle.localized(context).toLowerCase();

      if (title.contains(query) || titleLoc.contains(query)) return true;
      if (subtitle.contains(query) || subtitleLoc.contains(query)) return true;
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
      _showErrorReporterDialog(e, null);
    }
  }

  Future<void> _runImport() async {
    try {
      await widget.onImportBackup();
    } catch (e) {
      _showErrorReporterDialog(e, null);
    }
  }

  void _showBetaInfoPopup(Palette p) {
    showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, anim1, _) => ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 310,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: p.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beta Feature'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This feature is currently in active development. While fully functional and secure, you may notice minor adjustments to the layout or performance as we refine the experience. All calculations, data, and security policies remain entirely local to your device.'
                        .localized(context),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 13,
                      height: 1.5,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '* Have suggestions or found a bug? '.localized(
                          context,
                        ),
                        style: TextStyle(color: p.text2, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _openFeedback();
                        },
                        child: Text(
                          'Give Feedback'.localized(context),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PressableScale(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Got It'.localized(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
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

  Future<void> _loadNetworkLogs() async {
    setState(() => _loadingNetworkLogs = true);
    final logs = await NetworkLogger.getLogs();
    if (mounted) {
      setState(() {
        _networkLogs = logs;
        _loadingNetworkLogs = false;
      });
    }
  }

  Future<void> _clearNetworkLogs() async {
    HapticFeedback.mediumImpact();
    await NetworkLogger.clearLogs();
    await _loadNetworkLogs();
  }

  Future<bool> _isOffline() async {
    try {
      final result = await InternetAddress.lookup('github.com');
      return result.isEmpty || result[0].rawAddress.isEmpty;
    } on SocketException catch (_) {
      return true;
    }
  }

  Future<void> _showCustomAlert({
    required Palette p,
    required String title,
    required String message,
    required IconData icon,
    Color? iconColor,
    String? confirmLabel,
    VoidCallback? onConfirm,
    String cancelLabel = 'Close',
  }) {
    final finalIconColor = iconColor ?? p.accent;
    return showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, anim1, _) => ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: p.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: finalIconColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: finalIconColor, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title.localized(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message.localized(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 13,
                      height: 1.5,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (confirmLabel != null && onConfirm != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: p.text,
                              side: BorderSide(color: p.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              cancelLabel.localized(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: finalIconColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onConfirm();
                            },
                            child: Text(
                              confirmLabel.localized(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    PressableScale(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: p.accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          cancelLabel.localized(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorReporterDialog(dynamic error, dynamic stackTrace) {
    final p = paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );

    _showCustomAlert(
      p: p,
      title: 'System Error',
      message:
          'NoteKar encountered an unexpected error: $error\n\nWould you like to automatically report this crash details to our developer team?',
      icon: Icons.error_outline_rounded,
      iconColor: p.red,
      confirmLabel: 'Report',
      cancelLabel: 'Cancel',
      onConfirm: () {
        _submitAutoCrashReport(error, stackTrace, p);
      },
    );
  }

  void _submitAutoCrashReport(dynamic error, dynamic stackTrace, Palette p) {
    final engine = AdaptiveEngine();
    final appVer = '$appVersion ($kAppBuildNumber)';
    final title = Uri.encodeComponent('[CRASH]: Automated Error Report');
    final body = Uri.encodeComponent('''
### Automated Crash Report

**Error Details**
```
$error
```

**Stack Trace**
```
${stackTrace ?? 'No stack trace provided.'}
```

<details>
<summary><b>Device Details (Auto-generated)</b></summary>

- **App Version**: $appVer
- **Device**: ${engine.model}
- **OS**: ${engine.osVersion}

</details>
''');
    final labels = Uri.encodeComponent('bug,automated-report');
    final url = '$githubRepo/issues/new?title=$title&body=$body&labels=$labels';

    if (mounted) {
      Navigator.pop(context);
      widget.onOpenLink(url);
    }
  }

  void _openGithubIssue(String type) {
    final appVer = '$appVersion ($kAppBuildNumber)';
    final deviceModel = AdaptiveEngine().model;
    final osVer = AdaptiveEngine().osVersion;
    final perfTier = AdaptiveEngine().tier.toString().split('.').last;
    final currentTime = DateTime.now().toLocal().toString();

    String titlePrefix = '';
    String bodyTemplate = '';
    String label = '';

    if (type == 'bug') {
      titlePrefix = '[Bug]: ';
      label = 'bug';
      bodyTemplate =
          '''
### Describe the Bug
(Write what happened here...)

### Steps to Reproduce
1. Go to...
2. Click on...

<details>
<summary><b>Device Details (Auto-generated)</b></summary>

- **App Version**: $appVer
- **Device**: $deviceModel
- **OS**: $osVer
- **Performance Tier**: $perfTier
- **Date/Time**: $currentTime

</details>
''';
    } else {
      titlePrefix = '[Feature]: ';
      label = 'enhancement';
      bodyTemplate =
          '''
### Describe your Idea
(Write your feature request here...)

<details>
<summary><b>Device Details (Auto-generated)</b></summary>

- **App Version**: $appVer
- **Device**: $deviceModel
- **OS**: $osVer

</details>
''';
    }

    final encodedTitle = Uri.encodeComponent(titlePrefix);
    final encodedBody = Uri.encodeComponent(bodyTemplate);
    final encodedLabels = Uri.encodeComponent(label);

    final url =
        '$githubRepo/issues/new?title=$encodedTitle&body=$encodedBody&labels=$encodedLabels';
    widget.onOpenLink(url);
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
    _openCategory('Feedback');
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );
    final entries = this.entries;
    final today = dateKey(DateTime.now());
    final todayCount = entries.where((e) => e.date == today).length;
    final engine = AdaptiveEngine();
    bool show(String name) => category == name;
    final sheet = PopScope(
      canPop: category == null && _categoryStack.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _popCategory();
      },
      child: AppSheet(
        p: p,
        title: category == 'Reminder Message'
            ? (_editingReminderType == 'daily'
                  ? 'Daily Reminder Message'.localized(context)
                  : (_editingReminderType == 'weekly'
                        ? 'Weekly Reminder Message'.localized(context)
                        : 'Monthly Reminder Message'.localized(context)))
            : (category ?? 'Settings').localized(context),
        onBack: category != null ? _popCategory : null,
        docked: true,
        blur: !reduceMotion && enableTranslucency && engine.supportsBlur,
        largeText: largeText,
        controller: category == null ? _activeController : null,
        showLargeTitle: category == null,
        removeBottomPadding: true,
        child: SizedBox(
          width: 410,
          height: math.min(MediaQuery.sizeOf(context).height * 0.75, 680),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: engine.isLowEnd ? 120 : 180),
            reverseDuration: Duration(
              milliseconds: engine.isLowEnd ? 100 : 140,
            ),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              if (engine.isLowEnd) {
                return FadeTransition(opacity: animation, child: child);
              }
              final forward = _categoryStack.length >= _prevStackLength;
              final begin = Offset(forward ? 0.25 : -0.25, 0.0);
              final slide = Tween<Offset>(
                begin: begin,
                end: Offset.zero,
              ).animate(animation);
              final fade = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              );

              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: RepaintBoundary(
              key: ValueKey('container-${category ?? 'root'}'),
              child: category == 'Reminder Message'
                  ? ReminderMessagePage(
                      p: p,
                      editingReminderType: _editingReminderType ?? 'daily',
                      currentValue: _editingReminderType == 'daily'
                          ? _dailyReminderBody
                          : (_editingReminderType == 'weekly'
                                ? _weeklyReminderBody
                                : _monthlyReminderBody),
                      recents:
                          _prefs?.getStringList(
                            '${_editingReminderType == 'daily' ? 'reminder_daily_body' : (_editingReminderType == 'weekly' ? 'reminder_weekly_body' : 'reminder_monthly_body')}_recents',
                          ) ??
                          <String>[],
                      onSave: (type, newText) async {
                        setState(() {
                          if (type == 'daily') _dailyReminderBody = newText;
                          if (type == 'weekly') _weeklyReminderBody = newText;
                          if (type == 'monthly') _monthlyReminderBody = newText;
                        });
                        await _prefs?.setString(
                          type == 'daily'
                              ? 'reminder_daily_body'
                              : (type == 'weekly'
                                    ? 'reminder_weekly_body'
                                    : 'reminder_monthly_body'),
                          newText,
                        );
                        await _syncReminder(type);
                      },
                      onPop: _popCategory,
                    )
                  : CustomScrollView(
                      key: ValueKey('scroll-${category ?? 'root'}'),
                      controller: category == null ? _activeController : null,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
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
                                  alpha:
                                      !reduceMotion &&
                                          enableTranslucency &&
                                          AdaptiveEngine().supportsBlur
                                      ? 0.65
                                      : 1.0,
                                ),
                                padding: const EdgeInsets.only(
                                  bottom: spacing8,
                                ),
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
                                    icon: CupertinoIcons.paintbrush,
                                    title: 'Appearance',
                                    status:
                                        theme[0].toUpperCase() +
                                        theme.substring(1),
                                    color: p.accent,
                                    onTap: () =>
                                        _openCategory('Personalization'),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: CupertinoIcons.bolt,
                                    title: 'Logging',
                                    status: defaultMode == 'single'
                                        ? 'Single'
                                        : 'Two-Way',
                                    color: p.green,
                                    onTap: () => _openCategory('Logging'),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: CupertinoIcons.shield,
                                    title: 'Privacy & Security',
                                    status: privacyLock ? 'On' : 'Off',
                                    color: p.green,
                                    onTap: () =>
                                        _openCategory('Privacy & Security'),
                                  ),
                                  // SettingsRow(
                                  //   p: p,
                                  //   icon: CupertinoIcons.folder,
                                  //   title: 'Data & Backup'.localized(context),
                                  //   status:
                                  //       '${entries.length} ${'Logs'.localized(context)}',
                                  //   color: p.green,
                                  //   onTap: () => _openCategory('Data & Backup'),
                                  // ),
                                  SettingsRow(
                                    p: p,
                                    icon: CupertinoIcons.arrow_2_circlepath,
                                    title: 'Updates & Notices',
                                    status: _betaTrack ? 'Beta' : 'Stable',
                                    color: p.accent,
                                    onTap: () =>
                                        _openCategory('Updates & Notices'),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: CupertinoIcons.book,
                                    title: 'About',
                                    status: 'Docs',
                                    color: p.accent,
                                    onTap: () => _openCategory('About'),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: CupertinoIcons.slider_horizontal_3,
                                    title: 'Advanced',
                                    status: 'Tools',
                                    color: p.orange,
                                    onTap: () => _openCategory('Advanced'),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Personalize and configure NoteKar to fit your specific workflow.',
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
                                    title: 'Buy Me a Coffee',
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
                                    icon: Icons.email_rounded,
                                    title: 'Email Support',
                                    color: p.accent,
                                    rowKind: 'link',
                                    onTap: () =>
                                        widget.onOpenLink(supportEmail),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    customIcon: GithubIcon(
                                      size: 16,
                                      color: p.text,
                                    ),
                                    title: 'GitHub',
                                    color: p.text,
                                    rowKind: 'link',
                                    onTap: () => widget.onOpenLink(githubRepo),
                                  ),
                                ],
                              ),
                              if (_updateAvailable) ...[
                                const SizedBox(height: spacing16),
                                PressableScale(
                                  onTap: () => _openCategory('Update Center'),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.surface3,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: p.border,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: p.surface2,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.system_update_rounded,
                                            color: p.text,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Row(
                                            children: [
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
                                              const SizedBox(width: 8),
                                              () {
                                                final date = updateInfo?.date;
                                                final isVeryOld =
                                                    date != null &&
                                                    DateTime.now()
                                                            .difference(date)
                                                            .inDays >
                                                        7;
                                                final isUrgent =
                                                    isVeryOld ||
                                                    (updateInfo?.isImportant ??
                                                        false);
                                                return Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: isUrgent
                                                        ? p.red
                                                        : p.orange,
                                                    shape: BoxShape.circle,
                                                  ),
                                                );
                                              }(),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: p.text3,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: spacing24),
                              SettingsAboutBlock(
                                p: p,
                                onOpenLink: widget.onOpenLink,
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        ],
                        if (show('Search')) ...[
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: SliverStickyHeaderDelegate(
                              height: 64,
                              child: Container(
                                color: p.surface.withValues(
                                  alpha:
                                      !reduceMotion &&
                                          enableTranslucency &&
                                          AdaptiveEngine().supportsBlur
                                      ? 0.65
                                      : 1.0,
                                ),
                                padding: const EdgeInsets.only(
                                  bottom: spacing8,
                                ),
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
                              if (_settingsQuery.trim().isEmpty) ...[
                                if (_recentSearches.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 64),
                                    child: HIGEmptyState(
                                      p: p,
                                      icon: Icons.search_rounded,
                                      title: 'Search Settings'.localized(
                                        context,
                                      ),
                                      message:
                                          'Type to find themes, notifications, security, diagnostic logs, and capture mode configurations.'
                                              .localized(context),
                                      compact: true,
                                    ),
                                  )
                                else ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      8,
                                      20,
                                      12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'RECENT SEARCHES',
                                          style: TextStyle(
                                            color: p.text3,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            await prefs.remove(
                                              'recent_settings_searches',
                                            );
                                            setState(
                                              () => _recentSearches = [],
                                            );
                                          },
                                          child: Text(
                                            'Clear',
                                            style: TextStyle(
                                              color: p.accent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SettingsGroup(
                                    p: p,
                                    insetDividers: true,
                                    children: [
                                      for (final term in _recentSearches)
                                        ...() {
                                          final matched = _allSettingsOptions()
                                              .where(
                                                (item) =>
                                                    item.title == term ||
                                                    item.title.localized(
                                                          context,
                                                        ) ==
                                                        term,
                                              )
                                              .toList();
                                          if (matched.isNotEmpty) {
                                            final result = matched.first;
                                            if (result.kind == 'switch') {
                                              return [
                                                SettingsSwitchRow(
                                                  p: p,
                                                  icon: result.icon,
                                                  title: result.title,
                                                  subtitle: result.subtitle,
                                                  value: result.boolValue!,
                                                  onChanged: (val) {
                                                    _saveRecentSearch(
                                                      result.title,
                                                    );
                                                    result.onBoolChanged!(val);
                                                  },
                                                  color:
                                                      result.title ==
                                                          'Confirm Delete'
                                                      ? p.red
                                                      : p.accent,
                                                ),
                                              ];
                                            } else {
                                              return [
                                                SettingsRow(
                                                  p: p,
                                                  icon: result.icon,
                                                  title: result.title,
                                                  subtitle: result.subtitle,
                                                  status: result.status,
                                                  color:
                                                      (result.title ==
                                                              'Reset All Data' ||
                                                          result.title ==
                                                              'Factory Reset')
                                                      ? p.red
                                                      : p.accent,
                                                  onTap: () {
                                                    _saveRecentSearch(
                                                      result.title,
                                                    );
                                                    if (result.title ==
                                                        'App Version') {
                                                      showGeneralDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            true,
                                                        barrierLabel:
                                                            'Changelog',
                                                        pageBuilder:
                                                            (context, _, _) =>
                                                                ChangelogDialog(
                                                                  p: widget.p,
                                                                ),
                                                      );
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Release Date') {
                                                      _openCategory(
                                                        'Update Center',
                                                      );
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Developer & Creator') {
                                                      const MethodChannel(
                                                        'notekar/files',
                                                      ).invokeMethod<
                                                        void
                                                      >('openUrl', {
                                                        'url':
                                                            'https://github.com/dheeraz101',
                                                      });
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Open Source Codebase') {
                                                      const MethodChannel(
                                                        'notekar/files',
                                                      ).invokeMethod<
                                                        void
                                                      >('openUrl', {
                                                        'url':
                                                            'https://github.com/dheeraz101/Notekar-Android',
                                                      });
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Security & Integrity') {
                                                      showSecurityDetailsSheet(
                                                        context: context,
                                                        p: p,
                                                        reduceMotion:
                                                            reduceMotion,
                                                        enableTranslucency:
                                                            enableTranslucency,
                                                      );
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Privacy & Local Storage') {
                                                      showPrivacyDetailsSheet(
                                                        context: context,
                                                        p: p,
                                                        reduceMotion:
                                                            reduceMotion,
                                                        enableTranslucency:
                                                            enableTranslucency,
                                                      );
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Network Monitor') {
                                                      _openCategory(
                                                        'Network Monitor',
                                                      );
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Reset All Data') {
                                                      unawaited(
                                                        _confirmResetAll(p),
                                                      );
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Factory Reset') {
                                                      unawaited(
                                                        _confirmFactoryReset(p),
                                                      );
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Reset Settings Only') {
                                                      unawaited(
                                                        _confirmResetSettings(),
                                                      );
                                                      return;
                                                    }
                                                    if (result.title ==
                                                        'Recently Deleted') {
                                                      if (widget.onOpenTrash !=
                                                          null) {
                                                        widget.onOpenTrash!();
                                                      }
                                                      return;
                                                    }
                                                    _openCategory(
                                                      result.category,
                                                    );
                                                  },
                                                ),
                                              ];
                                            }
                                          }
                                          // Fallback to text query history item
                                          return [
                                            SettingsRow(
                                              p: p,
                                              icon: Icons.history_rounded,
                                              title: term,
                                              color: p.text3,
                                              onTap: () {
                                                _settingsSearchController.text =
                                                    term;
                                                setState(
                                                  () => _settingsQuery = term,
                                                );
                                                _saveRecentSearch(term);
                                              },
                                            ),
                                          ];
                                        }(),
                                    ],
                                  ),
                                ],
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
                                          onChanged: (val) {
                                            _saveRecentSearch(result.title);
                                            result.onBoolChanged!(val);
                                          },
                                          color:
                                              result.title == 'Confirm Delete'
                                              ? p.red
                                              : p.accent,
                                        )
                                      else
                                        SettingsRow(
                                          p: p,
                                          icon: result.icon,
                                          title: result.title,
                                          subtitle: result.subtitle,
                                          status: result.status,
                                          highlight: _settingsQuery,
                                          color:
                                              result.title ==
                                                      'Reset All Data' ||
                                                  result.title ==
                                                      'Factory Reset'
                                              ? p.red
                                              : p.accent,
                                          onTap: () {
                                            _saveRecentSearch(result.title);
                                            if (result.title == 'App Version') {
                                              showGeneralDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                barrierLabel: 'Changelog',
                                                pageBuilder: (context, _, _) =>
                                                    ChangelogDialog(
                                                      p: widget.p,
                                                    ),
                                              );
                                              return;
                                            }
                                            if (result.title ==
                                                'Release Date') {
                                              _openCategory('Update Center');
                                              return;
                                            }
                                            if (result.title ==
                                                'Developer & Creator') {
                                              const MethodChannel(
                                                'notekar/files',
                                              ).invokeMethod<void>('openUrl', {
                                                'url':
                                                    'https://github.com/dheeraz101',
                                              });
                                              return;
                                            }
                                            if (result.title ==
                                                'Open Source Codebase') {
                                              const MethodChannel(
                                                'notekar/files',
                                              ).invokeMethod<void>('openUrl', {
                                                'url':
                                                    'https://github.com/dheeraz101/Notekar-Android',
                                              });
                                              return;
                                            }
                                            if (result.title ==
                                                'Security & Integrity') {
                                              showSecurityDetailsSheet(
                                                context: context,
                                                p: p,
                                                reduceMotion: reduceMotion,
                                                enableTranslucency:
                                                    enableTranslucency,
                                              );
                                              return;
                                            }
                                            if (result.title ==
                                                'Privacy & Local Storage') {
                                              showPrivacyDetailsSheet(
                                                context: context,
                                                p: p,
                                                reduceMotion: reduceMotion,
                                                enableTranslucency:
                                                    enableTranslucency,
                                              );
                                              return;
                                            }
                                            if (result.title ==
                                                'Network Monitor') {
                                              _openCategory('Network Monitor');
                                              return;
                                            }
                                            if (result.title ==
                                                'Reset All Data') {
                                              unawaited(_confirmResetAll(p));
                                              return;
                                            }
                                            if (result.title ==
                                                'Factory Reset') {
                                              unawaited(
                                                _confirmFactoryReset(p),
                                              );
                                              return;
                                            }
                                            if (result.title ==
                                                'Reset Settings Only') {
                                              unawaited(
                                                _confirmResetSettings(),
                                              );
                                              return;
                                            }
                                            if (result.title ==
                                                'Recently Deleted') {
                                              if (widget.onOpenTrash != null) {
                                                widget.onOpenTrash!();
                                              }
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
                                          message:
                                              'No settings match "${_settingsQuery.trim()}". Try different keywords or check your spelling.',
                                          compact: true,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        ],
                        if (show('Personalization'))
                          SliverToBoxAdapter(
                            child: PersonalizationSettingsPage(
                              p: p,
                              subCategory: 'Personalization',
                              theme: theme,
                              accentColor: accentColor,
                              appIconStyle: appIconStyle,
                              currentLocale: currentLocale,
                              reduceMotion: reduceMotion,
                              enableTranslucency: enableTranslucency,
                              onLocaleChanged: (value) {
                                setState(() => currentLocale = value);
                                widget.onLocaleChanged(value);
                              },
                              onAccentColorChanged: (value) {
                                setState(() => accentColor = value);
                                widget.onAccentColor(value);
                              },
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Display'))
                          SliverToBoxAdapter(
                            child: DisplaySettingsPage(
                              p: p,
                              theme: theme,
                              showSeconds: showSeconds,
                              highlightSeconds: highlightSeconds,
                              buttonLabels: buttonLabels,
                              showHistoryText: showHistoryText,
                              largeControls: largeControls,
                              homeMenuPill: homeMenuPill,
                              reduceMotion: reduceMotion,
                              homeMenuAnimations: homeMenuAnimations,
                              enableTranslucency: enableTranslucency,
                              showLastSavedHint: showLastSavedHint,
                              onThemeChanged: (val) {
                                setState(() => theme = val);
                                widget.onTheme(val);
                              },
                              onShowSecondsChanged: (val) {
                                setState(() => showSeconds = val);
                                widget.onShowSeconds(val);
                              },
                              onHighlightSecondsChanged: (val) {
                                setState(() => highlightSeconds = val);
                                widget.onHighlightSeconds(val);
                              },
                              onFeedback: widget.onFeedback,
                              onButtonLabelsChanged: (val) {
                                setState(() => buttonLabels = val);
                                widget.onButtonLabels(val);
                              },
                              onShowHistoryTextChanged: (val) {
                                setState(() => showHistoryText = val);
                                widget.onShowHistoryText(val);
                              },
                              onLargeControlsChanged: (val) {
                                setState(() => largeControls = val);
                                widget.onLargeControls(val);
                              },
                              onHomeMenuPillChanged: (val) {
                                setState(() => homeMenuPill = val);
                                widget.onHomeMenuPill(val);
                              },
                              onHomeMenuAnimations: widget.onHomeMenuAnimations,
                              onHomeMenuAnimationsChanged: (val) {
                                setState(() => homeMenuAnimations = val);
                              },
                              onTranslucencyChanged: (val) {
                                setState(() => enableTranslucency = val);
                                widget.onTranslucency(val);
                              },
                              onShowLastSavedHintChanged: (val) {
                                setState(() => showLastSavedHint = val);
                                widget.onShowLastSavedHint(val);
                              },
                            ),
                          ),
                        if (show('Accent Color'))
                          SliverToBoxAdapter(
                            child: PersonalizationSettingsPage(
                              p: p,
                              subCategory: 'Accent Color',
                              theme: theme,
                              accentColor: accentColor,
                              appIconStyle: appIconStyle,
                              currentLocale: currentLocale,
                              reduceMotion: reduceMotion,
                              enableTranslucency: enableTranslucency,
                              onLocaleChanged: (value) {
                                setState(() => currentLocale = value);
                                widget.onLocaleChanged(value);
                              },
                              onAccentColorChanged: (value) {
                                setState(() => accentColor = value);
                                widget.onAccentColor(value);
                              },
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('App Icons'))
                          SliverToBoxAdapter(
                            child: AppIconsSettingsPage(
                              p: p,
                              appIconStyle: appIconStyle,
                              onAppIconStyleChanged: (value) {
                                setState(() => appIconStyle = value);
                                unawaited(widget.onAppIconStyle(value));
                              },
                            ),
                          ),
                        if (show('Logging'))
                          SliverToBoxAdapter(
                            child: LoggingSettingsPage(
                              p: p,
                              defaultMode: defaultMode,
                              entriesCount: entries.length,
                              notesCount: entries
                                  .where((e) => e.note.isNotEmpty)
                                  .length,
                              remindersStatus: _getRemindersStatus(),
                              enableSobrietyMode: enableSobrietyMode,
                              showPersistentNotification:
                                  showPersistentNotification,
                              showTrashBin: widget.onOpenTrash != null,
                              trash: _trash,
                              onShowPersistentNotificationChanged:
                                  (value) async {
                                    if (_prefs != null) {
                                      await _prefs!.setBool(
                                        'show_persistent_notification',
                                        value,
                                      );
                                    }
                                    setState(
                                      () => showPersistentNotification = value,
                                    );
                                    try {
                                      await const MethodChannel(
                                        'notekar/files',
                                      ).invokeMethod<void>(
                                        'setPersistentControlPanel',
                                        {'enabled': value},
                                      );
                                    } catch (_) {}
                                  },
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                            ),
                          ),
                        if (show('Dashboard'))
                          SliverToBoxAdapter(
                            child: SettingsDashboardPage(
                              p: p,
                              entries: entries,
                              enableSobrietyMode: enableSobrietyMode,
                              onLogNow: () => Navigator.of(context).pop('log'),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Capture'))
                          SliverToBoxAdapter(
                            child: CaptureSettingsPage(
                              p: p,
                              defaultMode: defaultMode,
                              tapDelay: tapDelay,
                              requireLongPressNote: requireLongPressNote,
                              onDefaultModeChanged: (value) {
                                setState(() => defaultMode = value);
                                widget.onDefaultMode(value);
                              },
                              onTapDelayChanged: (value) {
                                setState(() => tapDelay = value);
                                widget.onDelay(value);
                              },
                              onRequireLongPressNoteChanged: (value) {
                                setState(() => requireLongPressNote = value);
                                widget.onRequireLongPressNote(value);
                              },
                            ),
                          ),
                        if (show('Reminders'))
                          SliverToBoxAdapter(
                            child: RemindersSettingsPage(
                              p: p,
                              hasExactAlarmPermission: _hasExactAlarmPermission,
                              ignoresBatteryOptimizations:
                                  _ignoresBatteryOptimizations,
                              autoStartCardDismissed: _autoStartCardDismissed,
                              reflectionReminderEnabled:
                                  _reflectionReminderEnabled,
                              reflectionReminderIntervalMins:
                                  _reflectionReminderIntervalMins,
                              onOpenTimeReflection: () => _openCategory(
                                'Time Reflection',
                                parent: 'Reminders',
                              ),
                              dailyReminderEnabled: _dailyReminderEnabled,
                              dailyReminderTime: _dailyReminderTime,
                              dailyReminderBody: _dailyReminderBody,
                              inactivityReminderEnabled:
                                  _inactivityReminderEnabled,
                              inactivityIntervalMins: _inactivityIntervalMins,
                              weeklyReminderEnabled: _weeklyReminderEnabled,
                              weeklyReminderDays: _weeklyReminderDays,
                              weeklyReminderTime: _weeklyReminderTime,
                              weeklyReminderBody: _weeklyReminderBody,
                              monthlyReminderEnabled: _monthlyReminderEnabled,
                              monthlyReminderDay: _monthlyReminderDay,
                              monthlyReminderTime: _monthlyReminderTime,
                              monthlyReminderBody: _monthlyReminderBody,
                              onRequestExactAlarmPermission: (value) async {
                                HapticFeedback.selectionClick();
                                final success =
                                    await _fileChannel.invokeMethod<bool>(
                                      'requestExactAlarmPermission',
                                    ) ??
                                    false;
                                if (success) {
                                  final granted =
                                      await _fileChannel.invokeMethod<bool>(
                                        'canScheduleExactAlarms',
                                      ) ??
                                      true;
                                  setState(
                                    () => _hasExactAlarmPermission = granted,
                                  );
                                }
                              },
                              onRequestIgnoreBatteryOptimizations:
                                  (value) async {
                                    HapticFeedback.selectionClick();
                                    final success =
                                        await _fileChannel.invokeMethod<bool>(
                                          'requestIgnoreBatteryOptimizations',
                                        ) ??
                                        false;
                                    if (success) {
                                      final ignores =
                                          await _fileChannel.invokeMethod<bool>(
                                            'isIgnoringBatteryOptimizations',
                                          ) ??
                                          true;
                                      setState(
                                        () => _ignoresBatteryOptimizations =
                                            ignores,
                                      );
                                    }
                                  },
                              batteryOptimizationCardDismissed:
                                  _batteryOptimizationCardDismissed,
                              onDismissBatteryOptimizationCard: () async {
                                setState(
                                  () =>
                                      _batteryOptimizationCardDismissed = true,
                                );
                                await _prefs?.setBool(
                                  'notekar.batteryOptimizationCardDismissed',
                                  true,
                                );
                              },
                              onDismissAutoStartCard: () async {
                                setState(() => _autoStartCardDismissed = true);
                                await _prefs?.setBool(
                                  'notekar.autoStartCardDismissed',
                                  true,
                                );
                              },
                              onOpenAutoStartSettings: () async {
                                HapticFeedback.selectionClick();
                                await _fileChannel.invokeMethod(
                                  'openAutoStartSettings',
                                );
                              },
                              onToggleDailyReminder: (value) async {
                                HapticFeedback.selectionClick();
                                if (value) {
                                  final granted =
                                      await _fileChannel.invokeMethod<bool>(
                                        'requestNotificationPermission',
                                      ) ??
                                      true;
                                  if (!context.mounted) return;
                                  if (!granted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Notification permission needed'
                                              .localized(context),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                }
                                setState(() => _dailyReminderEnabled = value);
                                await _prefs?.setBool(
                                  'reminder_daily_enabled',
                                  value,
                                );
                                await _syncReminder('daily');
                              },
                              onTapDailyTime: () async {
                                HapticFeedback.selectionClick();
                                final time = await _showIOSTimePicker(
                                  context,
                                  _dailyReminderTime,
                                );
                                if (time != null) {
                                  setState(() => _dailyReminderTime = time);
                                  await _prefs?.setInt(
                                    'reminder_daily_hour',
                                    time.hour,
                                  );
                                  await _prefs?.setInt(
                                    'reminder_daily_minute',
                                    time.minute,
                                  );
                                  await _syncReminder('daily');
                                }
                              },
                              onTapDailyMessage: () =>
                                  _openReminderMessageEditor('daily'),
                              onToggleInactivityReminder: (value) async {
                                HapticFeedback.selectionClick();
                                if (value) {
                                  final granted =
                                      await _fileChannel.invokeMethod<bool>(
                                        'requestNotificationPermission',
                                      ) ??
                                      true;
                                  if (!context.mounted) return;
                                  if (!granted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Notification permission needed'
                                              .localized(context),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                }
                                setState(
                                  () => _inactivityReminderEnabled = value,
                                );
                                await _prefs?.setBool(
                                  'reminder_inactivity_enabled',
                                  value,
                                );
                                await _syncReminder('inactivity');
                              },
                              onTapInactivityInterval: (selected) async {
                                setState(
                                  () => _inactivityIntervalMins = selected,
                                );
                                await _prefs?.setInt(
                                  'reminder_inactivity_interval_mins',
                                  selected,
                                );
                                await _syncReminder('inactivity');
                              },
                              onToggleWeeklyReminder: (value) async {
                                HapticFeedback.selectionClick();
                                if (value) {
                                  final granted =
                                      await _fileChannel.invokeMethod<bool>(
                                        'requestNotificationPermission',
                                      ) ??
                                      true;
                                  if (!context.mounted) return;
                                  if (!granted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Notification permission needed'
                                              .localized(context),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                }
                                setState(() => _weeklyReminderEnabled = value);
                                await _prefs?.setBool(
                                  'reminder_weekly_enabled',
                                  value,
                                );
                                await _syncReminder('weekly');
                              },
                              onTapWeeklyDays: (updated) async {
                                setState(
                                  () => _weeklyReminderDays = updated..sort(),
                                );
                                await _prefs?.setStringList(
                                  'reminder_weekly_days',
                                  updated.map((e) => e.toString()).toList(),
                                );
                                await _syncReminder('weekly');
                              },
                              onTapWeeklyTime: () async {
                                HapticFeedback.selectionClick();
                                final time = await _showIOSTimePicker(
                                  context,
                                  _weeklyReminderTime,
                                );
                                if (time != null) {
                                  setState(() => _weeklyReminderTime = time);
                                  await _prefs?.setInt(
                                    'reminder_weekly_hour',
                                    time.hour,
                                  );
                                  await _prefs?.setInt(
                                    'reminder_weekly_minute',
                                    time.minute,
                                  );
                                  await _syncReminder('weekly');
                                }
                              },
                              onTapWeeklyMessage: () =>
                                  _openReminderMessageEditor('weekly'),
                              onToggleMonthlyReminder: (value) async {
                                HapticFeedback.selectionClick();
                                if (value) {
                                  final granted =
                                      await _fileChannel.invokeMethod<bool>(
                                        'requestNotificationPermission',
                                      ) ??
                                      true;
                                  if (!context.mounted) return;
                                  if (!granted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Notification permission needed'
                                              .localized(context),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                }
                                setState(() => _monthlyReminderEnabled = value);
                                await _prefs?.setBool(
                                  'reminder_monthly_enabled',
                                  value,
                                );
                                await _syncReminder('monthly');
                              },
                              onTapMonthlyDay: (selected) async {
                                setState(() => _monthlyReminderDay = selected);
                                await _prefs?.setInt(
                                  'reminder_monthly_day',
                                  selected,
                                );
                                await _syncReminder('monthly');
                              },
                              onTapMonthlyTime: () async {
                                HapticFeedback.selectionClick();
                                final time = await _showIOSTimePicker(
                                  context,
                                  _monthlyReminderTime,
                                );
                                if (time != null) {
                                  setState(() => _monthlyReminderTime = time);
                                  await _prefs?.setInt(
                                    'reminder_monthly_hour',
                                    time.hour,
                                  );
                                  await _prefs?.setInt(
                                    'reminder_monthly_minute',
                                    time.minute,
                                  );
                                  await _syncReminder('monthly');
                                }
                              },
                              onTapMonthlyMessage: () =>
                                  _openReminderMessageEditor('monthly'),
                            ),
                          ),
                        if (show('Time Reflection'))
                          SliverToBoxAdapter(
                            child: TimeReflectionSettingsPage(
                              p: p,
                              reflectionReminderEnabled:
                                  _reflectionReminderEnabled,
                              reflectionReminderIntervalMins:
                                  _reflectionReminderIntervalMins,
                              reflectionReminderSound: _reflectionReminderSound,
                              onToggleReflectionReminder: (value) async {
                                HapticFeedback.selectionClick();
                                if (value) {
                                  final granted =
                                      await _fileChannel.invokeMethod<bool>(
                                        'requestNotificationPermission',
                                      ) ??
                                      true;
                                  if (!context.mounted) return;
                                  if (!granted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Notification permission needed'
                                              .localized(context),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                }
                                setState(
                                  () => _reflectionReminderEnabled = value,
                                );
                                await _prefs?.setBool(
                                  'reminder_reflection_enabled',
                                  value,
                                );
                                await _syncReminder('reflection');
                              },
                              onTapReflectionInterval: (value) async {
                                setState(
                                  () => _reflectionReminderIntervalMins = value,
                                );
                                await _prefs?.setInt(
                                  'reminder_reflection_interval_mins',
                                  value,
                                );
                                if (_reflectionReminderEnabled) {
                                  await _syncReminder('reflection');
                                }
                              },
                              onToggleReflectionSound: (value) async {
                                HapticFeedback.selectionClick();
                                setState(
                                  () => _reflectionReminderSound = value,
                                );
                                await _prefs?.setBool(
                                  'reminder_reflection_sound',
                                  value,
                                );
                              },
                              onPreviewReflectionSheet: () {
                                TimeReflectionSheet.show(
                                  context,
                                  p: p,
                                  intervalMinutes:
                                      _reflectionReminderIntervalMins,
                                );
                              },
                            ),
                          ),
                        if (show('Moments'))
                          SliverToBoxAdapter(
                            child: MomentsSettingsPage(
                              p: p,
                              showTrashBin: widget.onOpenTrash != null,
                              trash: _trash,
                              compactHistory: compactHistory,
                              confirmDelete: confirmDelete,
                              enableNoteOnClick: enableNoteOnClick,
                              extendedDuration: extendedDuration,
                              minimalMomentOptions: minimalMomentOptions,
                              useNumbersInSingle: useNumbersInSingle,
                              resetSingleDaily: resetSingleDaily,
                              countOnSave: countOnSave,
                              notesCount: entries
                                  .where((e) => e.note.isNotEmpty)
                                  .length,
                              onCompactHistoryChanged: (value) {
                                setState(() => compactHistory = value);
                                widget.onCompactHistory(value);
                              },
                              onHistoryDensityChanged: (value) {
                                setState(() => historyDensity = value);
                                widget.onHistoryDensity(value);
                              },
                              onConfirmDeleteChanged: (value) {
                                setState(() => confirmDelete = value);
                                widget.onConfirmDelete(value);
                              },
                              onEnableNoteOnClickChanged: (value) async {
                                if (_prefs != null) {
                                  await _prefs!.setBool(
                                    'enable_note_on_click',
                                    value,
                                  );
                                }
                                setState(() => enableNoteOnClick = value);
                              },
                              onExtendedDurationChanged: (value) {
                                setState(() => extendedDuration = value);
                                widget.onExtendedDuration(value);
                              },
                              onMinimalMomentOptionsChanged: (value) {
                                setState(() => minimalMomentOptions = value);
                                widget.onMinimalMomentOptions(value);
                              },
                              onUseNumbersInSingleChanged: (value) {
                                setState(() => useNumbersInSingle = value);
                                widget.onUseNumbersInSingle?.call(value);
                              },
                              onResetSingleDailyChanged: (value) {
                                setState(() => resetSingleDaily = value);
                                widget.onResetSingleDaily?.call(value);
                              },
                              onCountOnSaveChanged: (value) {
                                setState(() => countOnSave = value);
                                widget.onCountOnSave?.call(value);
                              },
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                            ),
                          ),
                        if (show('Sobriety Companion'))
                          SliverToBoxAdapter(
                            child: SobrietyCompanionSettingsPage(
                              p: p,
                              enableSobrietyMode: enableSobrietyMode,
                              sobrietyResetType: sobrietyResetType,
                              sobrietyCustomStartMs: sobrietyCustomStartMs,
                              sobrietyMilestoneTheme: sobrietyMilestoneTheme,
                              onEnableSobrietyModeChanged: (value) async {
                                if (_prefs != null) {
                                  await _prefs!.setBool(
                                    'enable_sobriety_mode',
                                    value,
                                  );
                                }
                                setState(() => enableSobrietyMode = value);
                                widget.onSobrietyModeChanged?.call(value);
                              },
                              onSobrietyResetTypeChanged: (value) async {
                                if (_prefs != null) {
                                  await _prefs!.setString(
                                    'sobriety_reset_type',
                                    value,
                                  );
                                }
                                setState(() => sobrietyResetType = value);
                              },
                              onSobrietyCustomStartMsChanged: (value) async {
                                if (value == null) {
                                  await _prefs?.remove(
                                    'sobriety_custom_start_ms',
                                  );
                                } else {
                                  await _prefs?.setInt(
                                    'sobriety_custom_start_ms',
                                    value,
                                  );
                                }
                                setState(() => sobrietyCustomStartMs = value);
                              },
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                              onSelectStartDate: (context, initial) =>
                                  _showIOSDateTimePicker(context, initial),
                            ),
                          ),
                        if (show('Trigger Analysis'))
                          SliverToBoxAdapter(
                            child: TriggerAnalysisPage(p: p, entries: entries),
                          ),
                        if (show('Milestone Theme'))
                          SliverToBoxAdapter(
                            child: MilestoneThemePage(
                              p: p,
                              sobrietyMilestoneTheme: sobrietyMilestoneTheme,
                              onThemeChanged: (themeId) async {
                                await _prefs?.setString(
                                  'sobriety_milestone_theme',
                                  themeId,
                                );
                                setState(
                                  () => sobrietyMilestoneTheme = themeId,
                                );
                              },
                            ),
                          ),
                        if (show('Milestones'))
                          SliverToBoxAdapter(
                            child: MilestonesPage(
                              p: p,
                              sobrietyMilestoneTheme: sobrietyMilestoneTheme,
                              entries: entries,
                              sobrietyCustomStartMs: sobrietyCustomStartMs,
                              sobrietyResetType: sobrietyResetType,
                            ),
                          ),
                        if (show('Search Notes'))
                          ...SearchNotesSettingsPage.buildSlivers(
                            context: context,
                            p: p,
                            entries: entries,
                            settingsQuery: _noteQuery,
                            onQueryChanged: (value) =>
                                setState(() => _noteQuery = value),
                            onClearQuery: () => setState(() {
                              _noteSearchController.clear();
                              _noteQuery = '';
                            }),
                            settingsSearchController: _noteSearchController,
                            settingsSearchFocusNode: _noteSearchFocusNode,
                            compactHistory: compactHistory,
                            reduceMotion: reduceMotion,
                            enableTranslucency: enableTranslucency,
                            recentSearches: _recentNoteSearches,
                            onSaveRecentSearch: _saveRecentNoteSearch,
                            onClearRecentSearches: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('recent_note_searches');
                              setState(() => _recentNoteSearches = []);
                            },
                          ),
                        if (show('Guides'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
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
                                    text:
                                        'Every tap saves one standalone moment.',
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
                                        'Open Settings, then Logging, Moments, Search Notes to find note text by words, date, or time.',
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
                                        'Touch and hold any history moment to add, read, edit, or delete its note.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.lock_rounded,
                                    title: 'App Lock & Custom PIN',
                                    text:
                                        'Configure App Lock to use either native biometrics (System Lock) or a secure local passcode (In-App PIN). Features rate-limiting lockout protection.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.auto_awesome_motion_rounded,
                                    title: 'Minimal Moment Options',
                                    text:
                                        'Enable in Settings > Logging > Moments to use a fast, icon-only row for editing and deleting.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.auto_awesome_rounded,
                                    title: 'Adaptive Engine',
                                    text:
                                        'Notekar automatically tunes visual effects to your CPU, RAM, and SDK. Check stats in Advanced > Device Health.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.delete_outline_rounded,
                                    title: 'Restore Deleted Moments',
                                    text:
                                        'Open Trash Bin in History or Settings > Moments to view, restore, or permanently remove deleted moments.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.backup_rounded,
                                    title: 'Back Up Data',
                                    text:
                                        'Export a JSON backup before resetting, changing phones, or testing a new build.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.notifications_active_outlined,
                                    title: 'Logging Reminders',
                                    text:
                                        'Configure daily, weekly, monthly, or inactivity-based notifications under Settings > Logging > Reminders. Custom messages let you personalize alerts.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.dashboard_customize_rounded,
                                    title: 'Dashboard & Analytics',
                                    text:
                                        'Open Settings > Logging > Dashboard to see habit grids, activity trends, correlation insights, and anomaly alerts compiled locally.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.widgets_rounded,
                                    title: 'Home Screen Widget',
                                    text:
                                        'Add the NoteKar widget to your launcher. Tap IN, OUT, or TAP to log instantly in the background with real-time widget updates, or tap NOTE to open a native quick-log overlay.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.screenshot_rounded,
                                    title: 'Hide Content in Recents',
                                    text:
                                        'Turn on Hide App Content in Recents under Settings > Privacy & Security to cover app screens and block screenshots when minimizing the app.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.notification_important_rounded,
                                    title: 'Persistent Control',
                                    text:
                                        'Enable in Settings > Logging to show a low-priority, sticky control notification in the system drawer for instant checking IN/OUT from the lock screen.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.pin_outlined,
                                    title:
                                        'Sequential Single Numbering (00–99)',
                                    text:
                                        'Enable "Use Numbers in Single" under Settings > Logging > Moments to show clean 2-digit sequential counters (00 to 99) on standalone moments. Enable "Reset Daily" to automatically restart from 00 every midnight.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.touch_app_outlined,
                                    title: 'Count on Save Pulse',
                                    text:
                                        'Turn on "Enable Count on Save" in Settings > Logging > Moments to display your updated 2-digit sequential count directly inside the glowing ripple pulse on the home screen when tapping.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.apps_rounded,
                                    title: '8 Luxury App Icon Editions',
                                    text:
                                        'Personalize your home screen with 8 handcrafted launcher styles under Settings > Personalization > App Icons: Aurora (Default), Midnight (Onyx), Sapphire (Ocean), Imperial (Gold), Emerald (Forest), Sunset (Coral), Crimson (Velvet), and Amethyst (Nebula).',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.spa_rounded,
                                    title: 'Sobriety Tracker & Milestone Cards',
                                    text:
                                        'Track your recovery journey with live streak counters, unlock 10 milestone badges with confetti celebrations, and generate high-res shareable PNG cards under Settings > Personalization > Sobriety Tracker.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.calendar_month_rounded,
                                    title: 'iOS Calendar & Date Navigation',
                                    text:
                                        'Tap any date in the History screen to launch the fluid calendar picker with month controls, highlighted log days, and instant jump to Today.',
                                  ),
                                  GuideRow(
                                    p: p,
                                    icon: Icons.developer_mode_rounded,
                                    title: 'Developer Options & Telemetry',
                                    text:
                                        'Inspect internal diagnostics, device hardware health metrics, real-time network request audits, and GitHub commits cache under Settings > Advanced > Developer Options.',
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'NoteKar stores moments privately on this device. Backups are files you control.',
                              ),
                              const SizedBox(height: spacing48),
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
                                  HelpRow(
                                    p: p,
                                    question: 'Can I restore deleted moments?',
                                    answer:
                                        'Yes! Deleted moments are moved to Trash Bin. You can restore individual moments or all moments anytime from History or Settings > Moments.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'Can I view updates while offline?',
                                    answer:
                                        'Yes! NoteKar automatically caches the latest commits feed when you check for updates online. If you are offline, you will still see the cached feed, though checking for new updates will show a "No internet" notice.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question: 'What is the Network Monitor?',
                                    answer:
                                        'NoteKar includes an offline-first Network Monitor that displays a real-time audit log of every internet request made by the app (like update checks, changelogs, and notice checks), including status codes, request sizes, and purpose. No data ever leaves your device.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question: 'Switching track shows no update',
                                    answer:
                                        'If you are on a Beta release (which has a higher version code) and switch to the Stable track, Android prevents installing an older version (downgrading). You will see the update option once a newer Stable build is officially released. Alternatively, you can uninstall the Beta version and download the Stable version manually.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question: 'Update check failed',
                                    answer:
                                        'First confirm that your phone is connected to the internet. If other websites work, GitHub may be unavailable or limiting requests. Wait a few minutes and try again.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question: 'App Notices are not appearing',
                                    answer:
                                        'Confirm App Notices are enabled and Android notification permission is allowed. Battery restrictions or background limits may delay checks. Opening NoteKar while online also triggers a notice check.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question: 'NoteKar is offline',
                                    answer:
                                        'Logging, History, notes, settings, and local backups work without internet. Only update checks, external links, and App Notices require a connection.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'Backup import found no new moments',
                                    answer:
                                        'The backup was read correctly, but its moments already exist on this device. NoteKar skips duplicates instead of adding them again.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question: 'Backup import failed',
                                    answer:
                                        'Make sure you selected a NoteKar JSON backup that was not renamed, manually edited, or damaged. Try exporting a fresh backup.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'Live Icon Motion will not turn on',
                                    answer:
                                        'Turn off Reduced Motion first. If NoteKar reports that the motion sensor is unavailable, the phone does not provide a usable accelerometer stream or your hardware tier is set to Power Saver.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'Live Icon Motion looks slow or delayed',
                                    answer:
                                        'The movement is intentionally smoothed to prevent jitter. Lower-end phones may also reduce animation performance automatically based on CPU and RAM stats.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'How does App Lock protect NoteKar?',
                                    answer:
                                        'You can lock NoteKar using either your device\'s native credentials (System Lock) or a custom 4-digit passcode (In-App PIN). If you choose System Lock, removing your device lock screen security will automatically disable App Lock for safety. In-App PIN runs independently and includes rate-limiting lockout protection.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'App Lock appears after the notification panel',
                                    answer:
                                        'If App Lock is set to Immediately, opening Recents or pulling down the notification panel counts as leaving NoteKar. This ensures your moments stay hidden.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'The app icon did not change immediately',
                                    answer:
                                        'Some Android launchers cache icons. Return to the home screen, wait briefly, or restart the launcher or phone.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question: 'A moment was saved accidentally',
                                    answer:
                                        'Use Undo immediately after saving, or remove it from History. You can enable Confirm Delete for extra protection.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'My data disappeared after clearing app storage',
                                    answer:
                                        'NoteKar stores data locally. Clearing Android app storage deletes that local data. Restore it using a backup file if one was exported earlier.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'Will reminders work when the app is closed?',
                                    answer:
                                        'Yes! NoteKar registers reminders directly with Android\'s system AlarmManager. The OS will launch our background notification receiver and show the alert even if the app is closed or force-killed.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'Why am I not receiving reminders?',
                                    answer:
                                        'Make sure Android notification permissions are allowed for NoteKar. On some devices, OEM power-saving modes or background execution restrictions may block or delay scheduled alarms. Consider disabling battery optimization for NoteKar.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question: 'Is NoteKar safe to use?',
                                    answer:
                                        'Absolutely. NoteKar is open-source and offline-first. To guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via VirusTotal. You can inspect the live scan report under Updates & Notices.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'How do I add and use the home screen widget?',
                                    answer:
                                        'Touch and hold an empty space on your phone\'s home screen, select Widgets, and drag NoteKar to your screen. You can log immediately using the quick-action buttons. Tapping the top history stack opens the main app.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question: 'Is my Dashboard data uploaded?',
                                    answer:
                                        'No. All stats, activity heatmaps, anomalies, and correlation graphs are computed completely offline on your device. We do not track or upload your habits or logs.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'How do I block screenshots and screen previews?',
                                    answer:
                                        'Enable "Hide App Content" under Settings > Privacy & Security. Once enabled, screenshots will be blocked inside NoteKar, and the system app switcher card will appear blank.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'How do I log directly from the lock screen?',
                                    answer:
                                        'Turn on "Persistent Control" in Settings > Logging. A sticky, low-priority control card will appear in your notification drawer with quick actions to log IN, OUT, or write a quick note instantly.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'How does Sequential Single Numbering work?',
                                    answer:
                                        'When "Use Numbers in Single" is enabled, single moments are tagged with 00 to 99 sequence badges. If "Reset Daily" is enabled, the count restarts at 00 every midnight while keeping past days intact.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'Where are Diagnostics and Network Monitor?',
                                    answer:
                                        'Advanced tools and telemetry are organized under Settings > Advanced > Developer Options, including real-time hardware health, diagnostics logs, network audits, and cached commit feeds.',
                                  ),
                                  HelpRow(
                                    p: p,
                                    question:
                                        'How do I export my Sobriety Milestones?',
                                    answer:
                                        'Open Settings > Personalization > Sobriety Tracker, tap on any unlocked milestone badge in the milestones gallery, and tap "Export Milestone Card" to share a high-res image directly.',
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'NoteKar is offline-first. Internet-related failures should never block logging or access to saved history.',
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Update Center'))
                          SliverToBoxAdapter(
                            child: UpdateCenterView(
                              p: p,
                              appVersion: appVersion,
                              enableTranslucency: enableTranslucency,
                              reduceMotion: reduceMotion,
                              onOpenLink: widget.onOpenLink,
                              prefs: _prefs,
                              onCheckUpdates: _runCheckUpdates,
                              updateInfo: updateInfo,
                              checkingUpdates: checkingUpdates,
                              updateStatus: updateStatus,
                              currentBuildChannel: _currentBuildChannel,
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Build Choose'))
                          SliverToBoxAdapter(
                            child: BuildTrackSelectPage(
                              p: p,
                              betaTrack: _betaTrack,
                              onSaveTrackPreference: _saveTrackPreference,
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Developer Options'))
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: spacing8),
                                SettingsGroup(
                                  p: p,
                                  insetDividers: true,
                                  children: [
                                    SettingsRow(
                                      p: p,
                                      icon: Icons.bug_report_outlined,
                                      title: 'Diagnostics'.localized(context),
                                      status: 'View'.localized(context),
                                      color: p.accent,
                                      onTap: () => _openCategory(
                                        'Diagnostics',
                                        parent: 'Developer Options',
                                      ),
                                    ),
                                    SettingsRow(
                                      p: p,
                                      icon: Icons.memory_rounded,
                                      title: 'Device Health'.localized(context),
                                      status: AdaptiveEngine().healthStatus
                                          .localized(context),
                                      color: p.accent,
                                      onTap: () => _openCategory(
                                        'Device Health',
                                        parent: 'Developer Options',
                                      ),
                                    ),
                                    SettingsRow(
                                      p: p,
                                      icon: Icons.network_check_rounded,
                                      title: 'Network Monitor'.localized(
                                        context,
                                      ),
                                      status: 'View'.localized(context),
                                      color: p.accent,
                                      onTap: () => _openCategory(
                                        'Network Monitor',
                                        parent: 'Developer Options',
                                      ),
                                    ),
                                    SettingsRow(
                                      p: p,
                                      icon: Icons.history_rounded,
                                      title: 'Commits'.localized(context),
                                      status: 'Activity'.localized(context),
                                      color: p.accent,
                                      onTap: () => _openCategory(
                                        'Commits',
                                        parent: 'Developer Options',
                                      ),
                                    ),
                                  ],
                                ),
                                SettingsPageDescription(
                                  p: p,
                                  text:
                                      'Developer tools and system debugging utilities.'
                                          .localized(context),
                                ),
                                const SizedBox(height: spacing48),
                              ],
                            ),
                          ),
                        if (show('Commits'))
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: spacing8),
                                CommitsSettingsPage(
                                  p: p,
                                  enableTranslucency: enableTranslucency,
                                  reduceMotion: reduceMotion,
                                ),
                                const SizedBox(height: spacing48),
                              ],
                            ),
                          ),
                        if (show('Updates & Notices'))
                          SliverToBoxAdapter(
                            child: UpdatesNoticesSettingsPage(
                              p: p,
                              checkingUpdates: checkingUpdates,
                              updateInfo: updateInfo,
                              betaTrack: _betaTrack,
                              remoteNotices: remoteNotices,
                              onRemoteNoticesChanged: (value) {
                                setState(() => remoteNotices = value);
                                widget.onRemoteNotices(value);
                              },
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Data & Backup'))
                          SliverToBoxAdapter(
                            child: DataBackupSettingsPage(
                              p: p,
                              subCategory: 'Data & Backup',
                              entriesCount: entries.length,
                              dataHealthStatus: _dataHealthStatus,
                              backupReminderDays: backupReminderDays,
                              onBackupReminderDaysChanged: (value) {
                                setState(() => backupReminderDays = value);
                                widget.onBackupReminderDays(value);
                              },
                              onExportCsv: () => unawaited(
                                _runExport('CSV', widget.onExportCsv),
                              ),
                              onExportRecentCsv: () => unawaited(
                                _runExport(
                                  'Recent CSV',
                                  widget.onExportRecentCsv,
                                ),
                              ),
                              onExportJson: () => unawaited(
                                _runExport('JSON', widget.onExportJson),
                              ),
                              onExportBackup: () => unawaited(
                                _runExport('Backup', widget.onExportBackup),
                              ),
                              onImportBackup: () => unawaited(_runImport()),
                              onRestoreBackupFromString:
                                  widget.onRestoreBackupFromString,
                              onSaveQuickBackup: widget.onSaveQuickBackup,
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Backup & Export'))
                          SliverToBoxAdapter(
                            child: DataBackupSettingsPage(
                              p: p,
                              subCategory: 'Backup & Export',
                              entriesCount: entries.length,
                              dataHealthStatus: _dataHealthStatus,
                              backupReminderDays: backupReminderDays,
                              onBackupReminderDaysChanged: (value) {
                                setState(() => backupReminderDays = value);
                                widget.onBackupReminderDays(value);
                              },
                              onExportCsv: () => unawaited(
                                _runExport('CSV', widget.onExportCsv),
                              ),
                              onExportRecentCsv: () => unawaited(
                                _runExport(
                                  'Recent CSV',
                                  widget.onExportRecentCsv,
                                ),
                              ),
                              onExportJson: () => unawaited(
                                _runExport('JSON', widget.onExportJson),
                              ),
                              onExportBackup: () => unawaited(
                                _runExport('Backup', widget.onExportBackup),
                              ),
                              onImportBackup: () => unawaited(_runImport()),
                              onRestoreBackupFromString:
                                  widget.onRestoreBackupFromString,
                              onSaveQuickBackup: widget.onSaveQuickBackup,
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Backup Status'))
                          SliverToBoxAdapter(
                            child: DataBackupSettingsPage(
                              p: p,
                              subCategory: 'Backup Status',
                              entriesCount: entries.length,
                              dataHealthStatus: _dataHealthStatus,
                              backupReminderDays: backupReminderDays,
                              onBackupReminderDaysChanged: (value) {
                                setState(() => backupReminderDays = value);
                                widget.onBackupReminderDays(value);
                              },
                              onExportCsv: () => unawaited(
                                _runExport('CSV', widget.onExportCsv),
                              ),
                              onExportRecentCsv: () => unawaited(
                                _runExport(
                                  'Recent CSV',
                                  widget.onExportRecentCsv,
                                ),
                              ),
                              onExportJson: () => unawaited(
                                _runExport('JSON', widget.onExportJson),
                              ),
                              onExportBackup: () => unawaited(
                                _runExport('Backup', widget.onExportBackup),
                              ),
                              onImportBackup: () => unawaited(_runImport()),
                              onRestoreBackupFromString:
                                  widget.onRestoreBackupFromString,
                              onSaveQuickBackup: widget.onSaveQuickBackup,
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Local Backups'))
                          SliverToBoxAdapter(
                            child: LocalBackupsPage(
                              p: p,
                              onRestore: widget.onRestoreBackupFromString,
                              onCreateQuickBackup: widget.onSaveQuickBackup,
                            ),
                          ),
                        if (show('Privacy & Security'))
                          SliverToBoxAdapter(
                            child: PrivacySecuritySettingsPage(
                              p: p,
                              vtRatio: _vtRatio,
                              vtStatus: _vtStatus,
                              vtScanDate: _vtScanDate,
                              vtUrl: _vtUrl,
                              privacyLock: privacyLock,
                              obfuscateInRecents: obfuscateInRecents,
                              onObfuscateInRecentsChanged: (value) async {
                                if (_prefs != null) {
                                  await _prefs!.setBool(
                                    'obfuscate_in_recents',
                                    value,
                                  );
                                }
                                setState(() => obfuscateInRecents = value);
                                try {
                                  await const MethodChannel(
                                    'notekar/files',
                                  ).invokeMethod<void>(
                                    'setObfuscateInRecents',
                                    {'enabled': value},
                                  );
                                } catch (_) {}
                              },
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('App Lock'))
                          SliverToBoxAdapter(
                            child: AppLockSettingsPage(
                              p: p,
                              subCategory: 'App Lock',
                              privacyLock: privacyLock,
                              isSystemLockAvailable:
                                  widget.isSystemLockAvailable,
                              privacyLockType: privacyLockType,
                              privacyLockDelayMinutes: privacyLockDelayMinutes,
                              onPrivacyLockChanged: (value) async {
                                if (!value) {
                                  await widget.onPrivacyLock(false);
                                  if (mounted) {
                                    setState(() => privacyLock = false);
                                  }
                                  return;
                                }
                                final changed = await widget.onPrivacyLock(
                                  true,
                                );
                                if (changed && mounted) {
                                  setState(() => privacyLock = true);
                                }
                              },
                              onResetPrivacyPin: () async {
                                await widget.onResetPrivacyPin();
                              },
                              onPrivacyLockTypeChanged: (value) async {
                                if (privacyLockType == value) {
                                  return;
                                }
                                final success = await widget
                                    .onPrivacyLockTypeChanged(value);
                                if (success && mounted) {
                                  setState(() {
                                    privacyLockType = value;
                                  });
                                  _popCategory();
                                }
                              },
                              onPrivacyLockDelayChanged: (value) {
                                setState(() => privacyLockDelayMinutes = value);
                                widget.onPrivacyLockDelay(value);
                              },
                              onOpenCategory: _openCategory,
                              onPopCategory: _popCategory,
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Configure Lock'))
                          SliverToBoxAdapter(
                            child: AppLockSettingsPage(
                              p: p,
                              subCategory: 'Configure Lock',
                              privacyLock: privacyLock,
                              isSystemLockAvailable:
                                  widget.isSystemLockAvailable,
                              privacyLockType: privacyLockType,
                              privacyLockDelayMinutes: privacyLockDelayMinutes,
                              onPrivacyLockChanged: (value) async {
                                if (!value) {
                                  await widget.onPrivacyLock(false);
                                  if (mounted) {
                                    setState(() => privacyLock = false);
                                  }
                                  return;
                                }
                                final changed = await widget.onPrivacyLock(
                                  true,
                                );
                                if (changed && mounted) {
                                  setState(() => privacyLock = true);
                                }
                              },
                              onResetPrivacyPin: () async {
                                await widget.onResetPrivacyPin();
                              },
                              onPrivacyLockTypeChanged: (value) async {
                                if (privacyLockType == value) {
                                  return;
                                }
                                final success = await widget
                                    .onPrivacyLockTypeChanged(value);
                                if (success && mounted) {
                                  setState(() {
                                    privacyLockType = value;
                                  });
                                  _popCategory();
                                }
                              },
                              onPrivacyLockDelayChanged: (value) {
                                setState(() => privacyLockDelayMinutes = value);
                                widget.onPrivacyLockDelay(value);
                              },
                              onOpenCategory: _openCategory,
                              onPopCategory: _popCategory,
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('About') || show('Help & Guides'))
                          SliverToBoxAdapter(
                            child: HelpGuidesSettingsPage(
                              p: p,
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                            ),
                          ),
                        if (show('Advanced'))
                          SliverToBoxAdapter(
                            child: AdvancedSettingsPage(
                              p: p,
                              subCategory: 'Advanced',
                              currentLocale: currentLocale,
                              onLocaleChanged: (value) {
                                setState(() => currentLocale = value);
                                widget.onLocaleChanged(value);
                              },
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                              hapticStyle: hapticStyle,
                              reduceMotion: reduceMotion,
                              largeText: largeText,
                              highContrast: highContrast,
                              healthStatus: AdaptiveEngine().healthStatus,
                              onHapticStyleChanged: (value) {
                                setState(() => hapticStyle = value);
                                widget.onHapticStyle(value);
                              },
                              onReduceMotionChanged: (value) {
                                setState(() {
                                  reduceMotion = value;
                                  if (value) homeMenuAnimations = false;
                                });
                                widget.onReduceMotion(value);
                              },
                              onLargeTextChanged: (value) {
                                setState(() => largeText = value);
                                widget.onLargeText(value);
                              },
                              onHighContrastChanged: (value) {
                                setState(() => highContrast = value);
                                widget.onHighContrast(value);
                              },
                              onResetSettings: () =>
                                  unawaited(_confirmResetSettings()),
                              onResetAllData: () =>
                                  unawaited(_confirmResetAll(p)),
                              onFactoryReset: () =>
                                  unawaited(_confirmFactoryReset(p)),
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                            ),
                          ),
                        if (show('Language'))
                          SliverToBoxAdapter(
                            child: AdvancedSettingsPage(
                              p: p,
                              subCategory: 'Language',
                              currentLocale: currentLocale,
                              onLocaleChanged: (value) {
                                setState(() => currentLocale = value);
                                widget.onLocaleChanged(value);
                              },
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                              hapticStyle: hapticStyle,
                              reduceMotion: reduceMotion,
                              largeText: largeText,
                              highContrast: highContrast,
                              healthStatus: AdaptiveEngine().healthStatus,
                              onHapticStyleChanged: (value) {
                                setState(() => hapticStyle = value);
                                widget.onHapticStyle(value);
                              },
                              onReduceMotionChanged: (value) {
                                setState(() {
                                  reduceMotion = value;
                                  if (value) homeMenuAnimations = false;
                                });
                                widget.onReduceMotion(value);
                              },
                              onLargeTextChanged: (value) {
                                setState(() => largeText = value);
                                widget.onLargeText(value);
                              },
                              onHighContrastChanged: (value) {
                                setState(() => highContrast = value);
                                widget.onHighContrast(value);
                              },
                              onResetSettings: () =>
                                  unawaited(_confirmResetSettings()),
                              onResetAllData: () =>
                                  unawaited(_confirmResetAll(p)),
                              onFactoryReset: () =>
                                  unawaited(_confirmFactoryReset(p)),
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                            ),
                          ),
                        if (show('Accessibility'))
                          SliverToBoxAdapter(
                            child: AdvancedSettingsPage(
                              p: p,
                              subCategory: 'Accessibility',
                              hapticStyle: hapticStyle,
                              reduceMotion: reduceMotion,
                              largeText: largeText,
                              highContrast: highContrast,
                              healthStatus: AdaptiveEngine().healthStatus,
                              onHapticStyleChanged: (value) {
                                setState(() => hapticStyle = value);
                                widget.onHapticStyle(value);
                              },
                              onReduceMotionChanged: (value) {
                                setState(() {
                                  reduceMotion = value;
                                  if (value) homeMenuAnimations = false;
                                });
                                widget.onReduceMotion(value);
                              },
                              onLargeTextChanged: (value) {
                                setState(() => largeText = value);
                                widget.onLargeText(value);
                              },
                              onHighContrastChanged: (value) {
                                setState(() => highContrast = value);
                                widget.onHighContrast(value);
                              },
                              onResetSettings: () =>
                                  unawaited(_confirmResetSettings()),
                              onResetAllData: () =>
                                  unawaited(_confirmResetAll(p)),
                              onFactoryReset: () =>
                                  unawaited(_confirmFactoryReset(p)),
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                            ),
                          ),
                        if (show('Reset'))
                          SliverToBoxAdapter(
                            child: AdvancedSettingsPage(
                              p: p,
                              subCategory: 'Reset',
                              hapticStyle: hapticStyle,
                              reduceMotion: reduceMotion,
                              largeText: largeText,
                              highContrast: highContrast,
                              healthStatus: AdaptiveEngine().healthStatus,
                              onHapticStyleChanged: (value) {
                                setState(() => hapticStyle = value);
                                widget.onHapticStyle(value);
                              },
                              onReduceMotionChanged: (value) {
                                setState(() {
                                  reduceMotion = value;
                                  if (value) homeMenuAnimations = false;
                                });
                                widget.onReduceMotion(value);
                              },
                              onLargeTextChanged: (value) {
                                setState(() => largeText = value);
                                widget.onLargeText(value);
                              },
                              onHighContrastChanged: (value) {
                                setState(() => highContrast = value);
                                widget.onHighContrast(value);
                              },
                              onResetSettings: () =>
                                  unawaited(_confirmResetSettings()),
                              onResetAllData: () =>
                                  unawaited(_confirmResetAll(p)),
                              onFactoryReset: () =>
                                  unawaited(_confirmFactoryReset(p)),
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                            ),
                          ),
                        if (show('Diagnostics'))
                          SliverToBoxAdapter(
                            child: DiagnosticsSettingsPage(
                              p: p,
                              subCategory: 'Diagnostics',
                              entries: entries,
                              todayCount: todayCount,
                              appVersion: appVersion,
                              appBuildNumber: kAppBuildNumber,
                              appBuildDate: appBuildDate,
                              updateSubtitle: _updateSubtitle,
                              lastUpdateCheckedAt: widget.lastUpdateCheckedAt,
                              remoteNotices: remoteNotices,
                              onCopyDiagnosticsFeedback: (msg) {
                                widget.onFeedback(msg);
                              },
                              reduceMotion: reduceMotion,
                              enableTranslucency: enableTranslucency,
                              networkLogs: _networkLogs,
                              loadingNetworkLogs: _loadingNetworkLogs,
                              onClearNetworkLogs: _clearNetworkLogs,
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Device Health'))
                          SliverToBoxAdapter(
                            child: DiagnosticsSettingsPage(
                              p: p,
                              subCategory: 'Device Health',
                              entries: entries,
                              todayCount: todayCount,
                              appVersion: appVersion,
                              appBuildNumber: kAppBuildNumber,
                              appBuildDate: appBuildDate,
                              updateSubtitle: _updateSubtitle,
                              lastUpdateCheckedAt: widget.lastUpdateCheckedAt,
                              remoteNotices: remoteNotices,
                              onCopyDiagnosticsFeedback: (msg) {
                                widget.onFeedback(msg);
                              },
                              reduceMotion: reduceMotion,
                              enableTranslucency: enableTranslucency,
                              networkLogs: _networkLogs,
                              loadingNetworkLogs: _loadingNetworkLogs,
                              onClearNetworkLogs: _clearNetworkLogs,
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Network Monitor'))
                          SliverToBoxAdapter(
                            child: DiagnosticsSettingsPage(
                              p: p,
                              subCategory: 'Network Monitor',
                              entries: entries,
                              todayCount: todayCount,
                              appVersion: appVersion,
                              appBuildNumber: kAppBuildNumber,
                              appBuildDate: appBuildDate,
                              updateSubtitle: _updateSubtitle,
                              lastUpdateCheckedAt: widget.lastUpdateCheckedAt,
                              remoteNotices: remoteNotices,
                              onCopyDiagnosticsFeedback: (msg) {
                                widget.onFeedback(msg);
                              },
                              reduceMotion: reduceMotion,
                              enableTranslucency: enableTranslucency,
                              networkLogs: _networkLogs,
                              loadingNetworkLogs: _loadingNetworkLogs,
                              onClearNetworkLogs: _clearNetworkLogs,
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Privacy Policy'))
                          SliverToBoxAdapter(
                            child: LegalAboutSettingsPage(
                              p: p,
                              subCategory: 'Privacy Policy',
                              appVersion: appVersion,
                              privacyPolicyUrl: privacyPolicyUrl,
                              termsUrl: termsUrl,
                              onOpenLink: widget.onOpenLink,
                            ),
                          ),
                        if (show('Terms of Use'))
                          SliverToBoxAdapter(
                            child: LegalAboutSettingsPage(
                              p: p,
                              subCategory: 'Terms of Use',
                              appVersion: appVersion,
                              privacyPolicyUrl: privacyPolicyUrl,
                              termsUrl: termsUrl,
                              onOpenLink: widget.onOpenLink,
                            ),
                          ),
                        if (show('Licenses'))
                          SliverToBoxAdapter(
                            child: LegalAboutSettingsPage(
                              p: p,
                              subCategory: 'Licenses',
                              appVersion: appVersion,
                              privacyPolicyUrl: privacyPolicyUrl,
                              termsUrl: termsUrl,
                              onOpenLink: widget.onOpenLink,
                            ),
                          ),
                        if (show('Feedback'))
                          SliverToBoxAdapter(
                            child: FeedbackChangelogSettingsPage(
                              p: p,
                              subCategory: 'Feedback',
                              onOpenGithubIssue: _openGithubIssue,
                            ),
                          ),

                        if (show("What's New"))
                          SliverToBoxAdapter(
                            child: FeedbackChangelogSettingsPage(
                              p: p,
                              subCategory: "What's New",
                              onOpenGithubIssue: _openGithubIssue,
                            ),
                          ),
                        if (show('Trash Bin')) ...[
                          ...TrashBinSettingsPage.buildSlivers(
                            context: context,
                            p: p,
                            trash: _trash,
                            onRestoreAllTrash: () async {
                              await widget.onRestoreAllTrash();
                              if (mounted) setState(() {});
                            },
                            onClearTrash: () async {
                              await widget.onClearTrash();
                              if (mounted) setState(() {});
                            },
                            onRestoreTrashMoment: (id) async {
                              await widget.onRestoreTrashMoment(id);
                              if (mounted) setState(() {});
                            },
                            onDeleteTrashPermanent: (id) async {
                              await widget.onDeleteTrashPermanent(id);
                              if (mounted) setState(() {});
                            },
                          ),
                        ],
                        if (show('Changelog'))
                          SliverToBoxAdapter(
                            child: FeedbackChangelogSettingsPage(
                              p: p,
                              subCategory: 'Changelog',
                              onOpenGithubIssue: _openGithubIssue,
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
