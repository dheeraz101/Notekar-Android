import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/changelog_dialog.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/sobriety_milestones.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/network_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/guide_help_rows.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/widgets/history_analytics_card.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/update_service.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/dialogs/settings/commits_settings_page.dart';
import 'package:notekar/dialogs/settings/display_settings_page.dart';

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
  final ValueChanged<int> onPrivacyLockDelay;
  final Future<void> Function() onExportCsv;
  final Future<void> Function() onExportRecentCsv;
  final Future<void> Function() onExportJson;
  final Future<void> Function() onExportBackup;
  final Future<void> Function() onImportBackup;
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
  late bool enableTranslucency;
  late int privacyLockDelayMinutes;
  late String privacyLockType;
  late String currentLocale;
  List<NetworkLogEntry> _networkLogs = [];
  bool _loadingNetworkLogs = false;
  int? _expandedNetworkLogIndex;

  String? _editingReminderType;
  final TextEditingController _reminderMessageController =
      TextEditingController();
  final FocusNode _reminderMessageFocusNode = FocusNode();
  bool _autoStartCardDismissed = false;

  // Reminders Settings
  bool _dailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 21, minute: 0);
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
      _dailyReminderEnabled =
          _prefs?.getBool('reminder_daily_enabled') ?? false;
      _dailyReminderTime = TimeOfDay(
        hour: _prefs?.getInt('reminder_daily_hour') ?? 21,
        minute: _prefs?.getInt('reminder_daily_minute') ?? 0,
      );
      _dailyReminderBody =
          _prefs?.getString('reminder_daily_body') ?? 'Time to log a moment!';

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
    _fetchLatestVirusTotalInfo();
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
            'title': 'logging reminder'.localized(context),
            'body': _dailyReminderBody == 'Time to log a moment!'
                ? _dailyReminderBody.localized(context)
                : _dailyReminderBody,
          });
        } else {
          await _fileChannel.invokeMethod('cancelReminder', {
            'id': 'reminder_daily',
          });
        }
      } else if (id == 'inactivity') {
        if (_inactivityReminderEnabled) {
          await _fileChannel.invokeMethod('scheduleReminder', {
            'id': 'reminder_inactivity',
            'type': 'inactivity',
            'intervalMinutes': _inactivityIntervalMins,
            'title': 'logging reminder'.localized(context),
            'body': 'time to log a moment!'.localized(context),
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
            'title': 'logging reminder'.localized(context),
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
            'title': 'logging reminder'.localized(context),
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

  Widget _reminderMessagePage(Palette p) {
    if (_editingReminderType == null) return const SizedBox.shrink();

    final type = _editingReminderType!;

    final prefKey = type == 'daily'
        ? 'reminder_daily_body'
        : (type == 'weekly' ? 'reminder_weekly_body' : 'reminder_monthly_body');
    final recentsKey = '${prefKey}_recents';
    final recents = _prefs?.getStringList(recentsKey) ?? <String>[];

    final currentValue = type == 'daily'
        ? _dailyReminderBody
        : (type == 'weekly' ? _weeklyReminderBody : _monthlyReminderBody);
    recents.removeWhere((item) => item.trim().isEmpty || item == currentValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Reminder Message'.localized(context).toUpperCase(),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reminderMessageController,
                    focusNode: _reminderMessageFocusNode,
                    maxLines: 1,
                    maxLength: 60,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter reminder message...'.localized(context),
                      hintStyle: TextStyle(color: p.text3),
                      counterText: '',
                      filled: true,
                      fillColor: p.surface2,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _reminderMessageFocusNode.hasFocus
                              ? Icons.check_rounded
                              : Icons.edit_rounded,
                          color: _reminderMessageFocusNode.hasFocus
                              ? p.accent
                              : p.text3,
                          size: 20,
                        ),
                        onPressed: () {
                          if (_reminderMessageFocusNode.hasFocus) {
                            _reminderMessageFocusNode.unfocus();
                          } else {
                            _reminderMessageFocusNode.requestFocus();
                          }
                        },
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: p.accent, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: p.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (recents.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Recent Messages'.localized(context).toUpperCase(),
                        style: TextStyle(
                          color: p.text3,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SettingsGroup(
                      p: p,
                      insetDividers: true,
                      children: [
                        for (final item in recents.take(5))
                          SettingsRow(
                            p: p,
                            icon: Icons.history_rounded,
                            title: item,
                            color: p.text3,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _reminderMessageController.text = item;
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 16),
            child: FilledButton(
              onPressed: () async {
                final newText = _reminderMessageController.text.trim();
                if (newText != currentValue) {
                  if (currentValue.trim().isNotEmpty &&
                      currentValue != 'Time to log a moment!') {
                    recents.insert(0, currentValue);
                    final uniqueRecents = recents.toSet().toList();
                    await _prefs?.setStringList(
                      recentsKey,
                      uniqueRecents.take(5).toList(),
                    );
                  }

                  setState(() {
                    if (type == 'daily') _dailyReminderBody = newText;
                    if (type == 'weekly') _weeklyReminderBody = newText;
                    if (type == 'monthly') _monthlyReminderBody = newText;
                  });
                  await _prefs?.setString(prefKey, newText);
                  await _syncReminder(type);
                }
                _popCategory();
              },
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Save'.localized(context),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
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
                          child: const Text('Cancel'),
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
                          child: const Text('Confirm'),
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
  List<String> _recentSearches = [];

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

  void _openCategory(String name, {String? parent}) {
    if (name == 'Network Monitor') {
      _loadNetworkLogs();
    }
    setState(() {
      _prevStackLength = _categoryStack.length;
      if (category != null) _categoryStack.add(category!);
      category = name;
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
  get _settingsSearchResults {
    final query = _settingsQuery.trim().toLowerCase();
    if (query.isEmpty) return [];

    final String deletedSubtitle =
        (widget.lastDeletedPreview != null &&
            widget.lastDeletedPreview!.isNotEmpty)
        ? widget.lastDeletedPreview!
        : 'Restore or permanently remove deleted moments';

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

    final all = [
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
        status: '$appVersion ($appBuildNumber)',
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
          'english',
          'hindi',
          'spanish',
          'espanol',
        ],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: switch (currentLocale) {
          'en' => 'English',
          'hi' => 'हिन्दी',
          'es' => 'Español',
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
        subtitle: 'Change the Android launcher icon',
        category: 'App Icons',
        icon: Icons.apps_rounded,
        keywords: ['icon', 'launcher', 'home screen', 'app icon'],
        kind: 'selector',
        boolValue: null,
        onBoolChanged: null,
        status: appIconStyle[0].toUpperCase() + appIconStyle.substring(1),
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
        title: 'Trash Bin',
        subtitle: deletedSubtitle,
        category: 'Trash Bin',
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
        category: 'Updates & Notices',
        icon: Icons.history_rounded,
        keywords: ['commits', 'cache', 'github', 'history', 'feed', 'offline'],
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
      item(
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

  Widget _buildSobrietyAnalyticsCard(Palette p) {
    final relapseMoments = widget.entriesNotifier.value
        .where((e) => e.note.contains('#relapse'))
        .toList();
    if (relapseMoments.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
        padding: const EdgeInsets.all(spacing16),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
        ),
        child: Column(
          children: [
            Icon(Icons.spa_rounded, color: p.accent, size: 28),
            const SizedBox(height: 8),
            Text(
              'No relapses recorded yet!'.localized(context),
              style: TextStyle(
                color: p.text,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your clean streak is active and running.'.localized(context),
              style: TextStyle(color: p.text2, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final Map<String, int> triggerCounts = {};
    final Map<String, int> moodCounts = {};
    final Map<int, int> hourCounts = {};

    for (var m in relapseMoments) {
      final note = m.note;
      final triggerMatch = RegExp(r'#trigger:(\w+)').firstMatch(note);
      if (triggerMatch != null) {
        final t = triggerMatch.group(1)!;
        triggerCounts[t] = (triggerCounts[t] ?? 0) + 1;
      }
      final moodMatch = RegExp(r'#mood:(\w+)').firstMatch(note);
      if (moodMatch != null) {
        final md = moodMatch.group(1)!;
        moodCounts[md] = (moodCounts[md] ?? 0) + 1;
      }
      final dt = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
      final hour = dt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    String topTrigger = 'None';
    int maxTriggerCount = 0;
    triggerCounts.forEach((k, v) {
      if (v > maxTriggerCount) {
        maxTriggerCount = v;
        topTrigger = k.replaceAll('_', ' ').toUpperCase();
      }
    });

    String topMood = 'None';
    int maxMoodCount = 0;
    moodCounts.forEach((k, v) {
      if (v > maxMoodCount) {
        maxMoodCount = v;
        topMood = k.toUpperCase();
      }
    });

    final Map<String, int> rangeCounts = {
      'Morning': 0,
      'Afternoon': 0,
      'Evening': 0,
      'Night': 0,
    };
    hourCounts.forEach((h, count) {
      if (h >= 5 && h < 12) {
        rangeCounts['Morning'] = rangeCounts['Morning']! + count;
      } else if (h >= 12 && h < 17) {
        rangeCounts['Afternoon'] = rangeCounts['Afternoon']! + count;
      } else if (h >= 17 && h < 21) {
        rangeCounts['Evening'] = rangeCounts['Evening']! + count;
      } else {
        rangeCounts['Night'] = rangeCounts['Night']! + count;
      }
    });

    String peakTimeRange = 'Night';
    int maxRangeCount = 0;
    rangeCounts.forEach((k, v) {
      if (v > maxRangeCount) {
        maxRangeCount = v;
        peakTimeRange = k;
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing8,
      ),
      padding: const EdgeInsets.all(spacing16),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: p.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sobriety Trigger Analysis'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildMetricTile(
                  p,
                  'Total Relapses',
                  '${relapseMoments.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricTile(p, 'Top Trigger', topTrigger)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildMetricTile(p, 'Top Mood', topMood)),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(p, 'Peak Risk Window', peakTimeRange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(Palette p, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.localized(context).toUpperCase(),
            style: TextStyle(
              color: p.text2,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.localized(context),
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
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
    final appVer = '$appVersion ($appBuildNumber)';
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
    final appVer = '$appVersion ($appBuildNumber)';
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

  Widget _feedbackRootPage(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.bug_report_rounded,
              title: 'Report a Bug'.localized(context),
              subtitle: "Something isn't working as expected.".localized(
                context,
              ),
              color: p.red,
              onTap: () => _openGithubIssue('bug'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.auto_awesome_rounded,
              title: 'Request a Feature'.localized(context),
              subtitle: 'Suggest a new idea or improvement.'.localized(context),
              color: p.accent,
              onTap: () => _openGithubIssue('feature'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Select an option to open GitHub and submit a structured issue. Your device specifications will be prefilled automatically.'
                  .localized(context),
        ),
      ],
    );
  }

  Widget _networkMonitorHeader(Palette p) {
    double totalKb = 0;
    for (final entry in _networkLogs) {
      final sizeStr = entry.size.toLowerCase();
      if (sizeStr.contains('kb')) {
        totalKb += double.tryParse(sizeStr.replaceAll('kb', '').trim()) ?? 0.0;
      } else if (sizeStr.contains('mb')) {
        totalKb +=
            (double.tryParse(sizeStr.replaceAll('mb', '').trim()) ?? 0.0) *
            1024.0;
      }
    }
    String totalData = '';
    if (totalKb > 1024) {
      totalData = '${(totalKb / 1024).toStringAsFixed(2)} MB';
    } else {
      totalData = '${totalKb.toStringAsFixed(1)} KB';
    }

    final useTranslucency =
        !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: useTranslucency ? p.surface2.withValues(alpha: 0.8) : p.surface2,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Consumed'.localized(context).toUpperCase(),
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalData,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Requests'.localized(context).toUpperCase(),
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_networkLogs.length} reqs',
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: p.border.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Offline Privacy Log'.localized(context),
                style: TextStyle(
                  color: p.text2,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              PressableScale(
                onTap: _clearNetworkLogs,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: p.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: p.red.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Clear'.localized(context),
                    style: TextStyle(
                      color: p.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _networkMonitorLogsList(Palette p) {
    if (_loadingNetworkLogs) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_networkLogs.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: HIGEmptyState(
            p: p,
            icon: Icons.wifi_tethering_off_rounded,
            title: 'No Network Traffic',
            message:
                'All network activities made by NoteKar are audited and recorded here.',
            compact: true,
          ),
        ),
      ];
    }

    final useTranslucency =
        !reduceMotion && enableTranslucency && AdaptiveEngine().supportsBlur;

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = _networkLogs[index];
          final isExpanded = _expandedNetworkLogIndex == index;
          final timeStr =
              '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}';
          final dateStr =
              '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}';

          Color statusColor = p.green;
          if (entry.statusCode < 200 || entry.statusCode >= 300) {
            statusColor = p.red;
          }

          Color methodBg = p.accent.withValues(alpha: 0.1);
          Color methodText = p.accent;
          if (entry.method == 'HEAD') {
            methodBg = p.text2.withValues(alpha: 0.1);
            methodText = p.text2;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: useTranslucency
                  ? p.surface.withValues(alpha: 0.4)
                  : p.surface2,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: p.border.withValues(alpha: 0.2)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _expandedNetworkLogIndex = isExpanded ? null : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: methodBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.method,
                            style: TextStyle(
                              color: methodText,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.purpose.localized(context),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.size,
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Status ${entry.statusCode}',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$dateStr • $timeStr',
                          style: TextStyle(color: p.text3, fontSize: 10.5),
                        ),
                      ],
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 12),
                      Divider(
                        color: p.border.withValues(alpha: 0.2),
                        height: 1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ENDPOINT URL'.localized(context),
                        style: TextStyle(
                          color: p.text3,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        entry.url,
                        style: TextStyle(
                          color: p.accent,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }, childCount: _networkLogs.length),
      ),
    ];
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
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 12,
                          height: 1.35,
                        ),
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
            DiagnosticRow(
              p: p,
              label: 'Performance Tier',
              value: engine.tier.name.toUpperCase(),
            ),
            DiagnosticRow(
              p: p,
              label: 'RAM Capacity',
              value: '${engine.ramGb} GB',
            ),
            DiagnosticRow(
              p: p,
              label: 'CPU Cores',
              value: '${engine.processors} Cores',
            ),
            DiagnosticRow(
              p: p,
              label: 'System Blur',
              value: engine.supportsBlur ? 'Supported' : 'Hardware Limited',
            ),
            DiagnosticRow(
              p: p,
              label: 'Live Animations',
              value: engine.supportsAdvancedAnimations
                  ? 'High Performance'
                  : 'Optimized',
            ),
          ],
        ),

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
                  child: Image.asset(
                    'icon-maskable-512.png',
                    fit: BoxFit.cover,
                  ),
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
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 14,
                      height: 1.45,
                    ),
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
                child: Image.asset(
                  'icon-maskable-512.png',
                  width: 64,
                  height: 64,
                ),
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
          child: const Text(
            'View Full Licenses',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
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
              text:
                  'All moments and notes are stored locally on your device using an encrypted-ready database (Hive). No data is ever uploaded to a cloud server unless you manually export a backup file.',
            ),
            _PolicySection(
              p: p,
              icon: Icons.analytics_outlined,
              title: 'No Tracking',
              text:
                  'We do not use any third-party analytics, tracking pixels, or advertising SDKs. Your app usage remains completely anonymous and private.',
            ),
            _PolicySection(
              p: p,
              icon: Icons.wifi_rounded,
              title: 'Limited Connectivity',
              text:
                  'The app only uses the internet to check for software updates on GitHub and to fetch occasional app notices if enabled. No personal data is transmitted during these checks.',
            ),
          ],
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => widget.onOpenLink(privacyPolicyUrl),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text(
            'Full Online Policy',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
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
              text:
                  'NoteKar is provided "as is" for personal use. You are responsible for your own data backups and for ensuring your use of the app complies with local laws.',
            ),
            _PolicySection(
              p: p,
              icon: Icons.code_rounded,
              title: 'Open Source',
              text:
                  'NoteKar is open source software. Individual components and libraries are subject to their respective licenses, which can be viewed in the Licenses section.',
            ),
          ],
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => widget.onOpenLink(termsUrl),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text(
            'Full Online Terms',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
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
        : relativeAge(entries.map((entry) => entry.timestamp).reduce(math.max));
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
            DiagnosticRow(p: p, label: 'Build Date', value: appBuildDate),
            DiagnosticRow(p: p, label: 'Build Date', value: appBuildDate),
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

        SettingsPageDescription(
          p: p,
          text:
              'Diagnostics help in troubleshooting. Copying them does not send any data automatically.',
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
        SettingsPageDescription(
          p: p,
          showIcon: true,
          text:
              'App Icons change the Android launcher icon. Note: Some launchers may take a few seconds to update.',
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
    _openCategory('Feedback');
  }

  Widget _updateCenterPage(Palette p) {
    return UpdateCenterView(
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
    );
  }

  Widget _buildChoosePage(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.check_circle_outline_rounded,
              title: 'Stable Build',
              subtitle: 'Recommended for standard users.'.localized(context),
              trailing: !_betaTrack
                  ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                  : const SizedBox.shrink(),
              onTap: () => _saveTrackPreference(false),
            ),
            SettingsRow(
              p: p,
              icon: Icons.track_changes_rounded,
              title: 'Beta Build',
              subtitle: 'Early access to active development features.'
                  .localized(context),
              trailing: _betaTrack
                  ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                  : const SizedBox.shrink(),
              onTap: () => _saveTrackPreference(true),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stable track offers thoroughly tested releases. Beta track offers active pre-release compilation builds.'
                    .localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 13,
                  height: 1.45,
                  letterSpacing: -0.05,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '1.',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Switching to the Stable Build track will fetch the last released stable build and show the update.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '2.',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Switching to the Beta Build track will fetch the last compiled beta build and show the update.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '3.',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'If in a Beta build and switched to Stable now, you will only receive Stable releases when a higher version is published.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '4.',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'If in a Stable build and switched to Beta now, you will receive upcoming Beta releases immediately as they are published.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 13,
                        height: 1.45,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SettingsBetaNote(
          p: p,
          text: 'The features on this track are under active beta testing.'
              .localized(context),
          onLearnMore: () => _showBetaInfoPopup(p),
        ),
        const SizedBox(height: spacing48),
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
    final entries = this.entries;
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
                  ? _reminderMessagePage(p)
                  : CustomScrollView(
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
                                    icon: Icons.brush_rounded,
                                    title: 'Personalization',
                                    status:
                                        theme[0].toUpperCase() +
                                        theme.substring(1),
                                    color: p.accent,
                                    onTap: () =>
                                        _openCategory('Personalization'),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.bolt_rounded,
                                    title: 'Logging',
                                    status: defaultMode == 'single'
                                        ? 'Single'
                                        : 'Two-Way',
                                    color: p.green,
                                    onTap: () => _openCategory('Logging'),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.verified_user_rounded,
                                    title: 'Privacy & Security',
                                    status: privacyLock ? 'On' : 'Off',
                                    color: p.green,
                                    onTap: () =>
                                        _openCategory('Privacy & Security'),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.storage_rounded,
                                    title: 'Data & Backup'.localized(context),
                                    status:
                                        '${entries.length} ${'Logs'.localized(context)}',
                                    color: p.green,
                                    onTap: () => _openCategory('Data & Backup'),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.update_rounded,
                                    title: 'Updates & Notices',
                                    status: _betaTrack ? 'Beta' : 'Stable',
                                    color: p.accent,
                                    onTap: () =>
                                        _openCategory('Updates & Notices'),
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
                              if (_settingsQuery.trim().isEmpty &&
                                  _recentSearches.isNotEmpty) ...[
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
                                          setState(() => _recentSearches = []);
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
                                              _showSecurityDetailsSheet(
                                                context,
                                                p,
                                              );
                                              return;
                                            }
                                            if (result.title ==
                                                'Privacy & Local Storage') {
                                              _showPrivacyDetailsSheet(
                                                context,
                                                p,
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
                                    status:
                                        theme[0].toUpperCase() +
                                        theme.substring(1),
                                    color: p.accent,
                                    onTap: () => _openCategory(
                                      'Display',
                                      parent: 'Personalization',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.color_lens_outlined,
                                    title: 'Accent Color',
                                    status:
                                        accentColor[0].toUpperCase() +
                                        accentColor.substring(1),
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
                                    status:
                                        appIconStyle[0].toUpperCase() +
                                        appIconStyle.substring(1),
                                    color: p.orange,
                                    onTap: () => _openCategory(
                                      'App Icons',
                                      parent: 'Personalization',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.language_rounded,
                                    title: 'Language',
                                    status: switch (currentLocale) {
                                      'en' => 'English',
                                      'hi' => 'हिन्दी',
                                      'es' => 'Español',
                                      _ => 'System Default',
                                    },
                                    color: p.accent,
                                    onTap: () => _openCategory(
                                      'Language',
                                      parent: 'Personalization',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'These settings refine the interface aesthetic and do not modify your saved data.',
                              ),
                              const SizedBox(height: spacing48),
                            ]),
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
                        if (show('Language'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsGroup(
                                p: p,
                                children: [
                                  for (final entry in [
                                    (code: 'system', name: 'System Default'),
                                    (code: 'en', name: 'English'),
                                    (code: 'hi', name: 'हिन्दी (Hindi)'),
                                    (code: 'es', name: 'Español (Spanish)'),
                                  ])
                                    SettingsRow(
                                      p: p,
                                      title: entry.name,
                                      trailing: currentLocale == entry.code
                                          ? Icon(
                                              Icons.check_rounded,
                                              color: p.accent,
                                              size: 20,
                                            )
                                          : const SizedBox.shrink(),
                                      onTap: () {
                                        if (currentLocale == entry.code) return;
                                        HapticFeedback.selectionClick();
                                        setState(
                                          () => currentLocale = entry.code,
                                        );
                                        widget.onLocaleChanged(entry.code);
                                      },
                                    ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Select your preferred language for the application.'
                                        .localized(context),
                              ),
                              SettingsBetaNote(
                                p: p,
                                text:
                                    'The current features on this page are under Beta stage.'
                                        .localized(context),
                                onLearnMore: () => _showBetaInfoPopup(p),
                              ),
                              const SizedBox(height: spacing48),
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
                                    blur:
                                        !reduceMotion &&
                                        enableTranslucency &&
                                        AdaptiveEngine().supportsBlur,
                                    onChanged: (value) {
                                      if (value == accentColor) return;
                                      HapticFeedback.selectionClick();
                                      setState(() => accentColor = value);
                                      widget.onAccentColor(value);
                                    },
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Select an accent color for buttons and fluid interface highlights.',
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('App Icons'))
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: spacing8),
                                _appIconsPage(p),
                                const SizedBox(height: spacing48),
                              ],
                            ),
                          ),
                        if (show('Logging'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.dashboard_customize_outlined,
                                    title: 'Dashboard',
                                    color: p.accent,
                                    onTap: () => _openCategory(
                                      'Dashboard',
                                      parent: 'Logging',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Interactive summary dashboards, activity heatmaps, weekly trends, and intelligence insights.'
                                        .localized(context),
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
                                    status: defaultMode == 'single'
                                        ? 'Single'
                                        : 'Two-Way',
                                    color: p.green,
                                    onTap: () => _openCategory(
                                      'Capture',
                                      parent: 'Logging',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.history_rounded,
                                    title: 'Moments'.localized(context),
                                    status:
                                        '${entries.length} ${'Logs'.localized(context)}',
                                    color: p.orange,
                                    onTap: () => _openCategory(
                                      'Moments',
                                      parent: 'Logging',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.notifications_active_outlined,
                                    title: 'Reminders',
                                    status: _getRemindersStatus(),
                                    color: p.accent,
                                    onTap: () => _openCategory(
                                      'Reminders',
                                      parent: 'Logging',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'These settings define how moments are recorded and prepared for export.',
                              ),
                              const SizedBox(height: 12),
                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.self_improvement_rounded,
                                    title: 'Sobriety Companion',
                                    color: p.orange,
                                    status: enableSobrietyMode ? 'On' : 'Off',
                                    onTap: () => _openCategory(
                                      'Sobriety Companion',
                                      parent: 'Logging',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Track clean streaks, log relapses with mood and trigger tags, and view offline pattern analysis.',
                              ),
                              const SizedBox(height: 12),
                              SettingsGroup(
                                p: p,
                                title: 'Notification Panel',
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    icon: Icons.notification_important_rounded,
                                    title: 'Persistent Control',
                                    subtitle:
                                        'Show a sticky notification in the drawer to log check-in/out directly from the lock screen.',
                                    value: showPersistentNotification,
                                    color: p.accent,
                                    onChanged: (value) async {
                                      if (_prefs != null) {
                                        await _prefs!.setBool(
                                          'show_persistent_notification',
                                          value,
                                        );
                                      }
                                      setState(
                                        () =>
                                            showPersistentNotification = value,
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
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Enables quick, low-priority control notification in the system drawer for convenience.',
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Dashboard'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Live activity tracking dashboard featuring real-time metric analysis, habit tracking grids, activity trends, and correlation intelligence calculated from your moments.'
                                        .localized(context),
                              ),
                              AnomalyAlertCard(
                                p: p,
                                entries: entries,
                                onLogNow: () =>
                                    Navigator.of(context).pop('log'),
                              ),
                              if (entries.isNotEmpty &&
                                  DateTime.now()
                                          .difference(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              entries.first.timestamp,
                                            ),
                                          )
                                          .inHours >=
                                      48)
                                const SizedBox(height: 6),
                              if (enableSobrietyMode) ...[
                                _buildSobrietyAnalyticsCard(p),
                                const SizedBox(height: 6),
                              ],
                              _buildDashboardSectionHeader(
                                p,
                                Icons.analytics_outlined,
                                'Real-time Metrics',
                              ),
                              ActivitySummaryCard(p: p, entries: entries),
                              const SizedBox(height: 8),
                              _buildDashboardSectionHeader(
                                p,
                                Icons.trending_up_rounded,
                                'Habit Frequency & Trends',
                              ),
                              ActivityTrendsCard(p: p, entries: entries),
                              const SizedBox(height: 6),
                              ActivityHeatmapCard(p: p, entries: entries),
                              const SizedBox(height: 8),
                              _buildDashboardSectionHeader(
                                p,
                                Icons.insights_rounded,
                                'Correlation Intelligence',
                              ),
                              IntelligentInsightsCard(p: p, entries: entries),
                              SettingsBetaNote(
                                p: p,
                                text:
                                    'The current features on this page are under Beta stage.'
                                        .localized(context),
                                onLearnMore: () => _showBetaInfoPopup(p),
                              ),
                              const SizedBox(height: spacing48),
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
                                    subtitle:
                                        'Every tap records a standalone moment.',
                                    trailing: defaultMode == 'single'
                                        ? Icon(
                                            Icons.check_rounded,
                                            color: p.accent,
                                            size: 20,
                                          )
                                        : const SizedBox.shrink(),
                                    onTap: () {
                                      if (defaultMode == 'single') return;
                                      setState(() => defaultMode = 'single');
                                      widget.onDefaultMode('single');
                                    },
                                  ),
                                  SettingsRow(
                                    p: p,
                                    title: 'Two-Way',
                                    subtitle:
                                        'Sessions are recorded as IN and OUT pairs.',
                                    trailing: defaultMode == 'two-way'
                                        ? Icon(
                                            Icons.check_rounded,
                                            color: p.accent,
                                            size: 20,
                                          )
                                        : const SizedBox.shrink(),
                                    onTap: () {
                                      if (defaultMode == 'two-way') return;
                                      setState(() => defaultMode = 'two-way');
                                      widget.onDefaultMode('two-way');
                                    },
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Defines the primary logging mode active when the app launches.',
                              ),

                              Glass(
                                p: p,
                                radius: 32,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  18,
                                  16,
                                  14,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tap Delay',
                                          style: TextStyle(
                                            color: p.text,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          delayLabel(tapDelay),
                                          style: TextStyle(
                                            color: p.text2,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        DelayStepButton(
                                          p: p,
                                          icon: Icons.remove_rounded,
                                          enabled:
                                              (delayIndex < 0
                                                  ? 0
                                                  : delayIndex) >
                                              0,
                                          onTap: () {
                                            final current = delayIndex < 0
                                                ? 0
                                                : delayIndex;
                                            final next =
                                                delayValues[math.max(
                                                  0,
                                                  current - 1,
                                                )];
                                            NotekarHaptics.selection(
                                              'standard',
                                            );
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
                                                  inactiveTrackColor:
                                                      p.surface3,
                                                  thumbColor: Colors.white,
                                                  overlayColor: p.accent
                                                      .withValues(alpha: 0.12),
                                                  trackHeight: 5,
                                                  tickMarkShape:
                                                      SliderTickMarkShape
                                                          .noTickMark,
                                                ),
                                                child: Slider(
                                                  min: 0,
                                                  max: 6,
                                                  divisions: 6,
                                                  value:
                                                      (delayIndex < 0
                                                              ? 0
                                                              : delayIndex)
                                                          .toDouble(),
                                                  onChanged: (value) {
                                                    final next =
                                                        delayValues[value
                                                            .round()];
                                                    if (next == tapDelay) {
                                                      return;
                                                    }
                                                    NotekarHaptics.selection(
                                                      'standard',
                                                    );
                                                    setState(
                                                      () => tapDelay = next,
                                                    );
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
                                          p: p,
                                          icon: Icons.add_rounded,
                                          enabled:
                                              (delayIndex < 0
                                                  ? 0
                                                  : delayIndex) <
                                              delayValues.length - 1,
                                          onTap: () {
                                            final current = delayIndex < 0
                                                ? 0
                                                : delayIndex;
                                            final next =
                                                delayValues[math.min(
                                                  delayValues.length - 1,
                                                  current + 1,
                                                )];
                                            NotekarHaptics.selection(
                                              'standard',
                                            );
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
                                text:
                                    'Tap Delay prevents accidental rapid-fire logging by setting a cooldown between captured moments.',
                              ),

                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'Require Note on Hold',
                                    color: p.orange,
                                    value: requireLongPressNote,
                                    onChanged: (value) {
                                      setState(
                                        () => requireLongPressNote = value,
                                      );
                                      widget.onRequireLongPressNote(value);
                                    },
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Forces context entry for any moment captured via the long-press gesture.',
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Reminders'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              if (!_hasExactAlarmPermission)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  child: Glass(
                                    p: p,
                                    radius: 20,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              color: p.orange,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Alarms Permission Required'
                                                    .localized(context),
                                                style: TextStyle(
                                                  color: p.text,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'To trigger reminders precisely when the app is closed, NoteKar requires the "Alarms & Reminders" permission.'
                                              .localized(context),
                                          style: TextStyle(
                                            color: p.text2,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () async {
                                            HapticFeedback.selectionClick();
                                            final success =
                                                await _fileChannel.invokeMethod<
                                                  bool
                                                >(
                                                  'requestExactAlarmPermission',
                                                ) ??
                                                false;
                                            if (success) {
                                              final granted =
                                                  await _fileChannel
                                                      .invokeMethod<bool>(
                                                        'canScheduleExactAlarms',
                                                      ) ??
                                                  true;
                                              setState(
                                                () => _hasExactAlarmPermission =
                                                    granted,
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: p.orange,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                          child: Text(
                                            'Grant Permission'.localized(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (!_ignoresBatteryOptimizations)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  child: Glass(
                                    p: p,
                                    radius: 20,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.battery_alert_rounded,
                                              color: p.orange,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Battery Optimization Active'
                                                    .localized(context),
                                                style: TextStyle(
                                                  color: p.text,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Aggressive battery cleaners on low-end devices can kill NoteKar in the background. Disable battery optimization to guarantee reminders fire 100% of the time.'
                                              .localized(context),
                                          style: TextStyle(
                                            color: p.text2,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () async {
                                            HapticFeedback.selectionClick();
                                            final success =
                                                await _fileChannel.invokeMethod<
                                                  bool
                                                >(
                                                  'requestIgnoreBatteryOptimizations',
                                                ) ??
                                                false;
                                            if (success) {
                                              final ignores =
                                                  await _fileChannel.invokeMethod<
                                                    bool
                                                  >(
                                                    'isIgnoringBatteryOptimizations',
                                                  ) ??
                                                  true;
                                              setState(
                                                () =>
                                                    _ignoresBatteryOptimizations =
                                                        ignores,
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: p.orange,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                          child: Text(
                                            'Disable Battery Optimization'
                                                .localized(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (!_autoStartCardDismissed)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Glass(
                                    p: p,
                                    radius: 20,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.autorenew_rounded,
                                              color: p.orange,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Auto-Start & Background Activity'
                                                    .localized(context),
                                                style: TextStyle(
                                                  color: p.text,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.close_rounded,
                                                color: p.text3,
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                setState(
                                                  () =>
                                                      _autoStartCardDismissed =
                                                          true,
                                                );
                                                await _prefs?.setBool(
                                                  'notekar.autoStartCardDismissed',
                                                  true,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'On devices like Xiaomi, Samsung, Oppo, Vivo, or Huawei, the OS restricts background alarms when swiped away from recents. Grant "Auto-Start" or allow "Background Activity" to ensure reminders trigger.'
                                              .localized(context),
                                          style: TextStyle(
                                            color: p.text2,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () async {
                                            HapticFeedback.selectionClick();
                                            await _fileChannel.invokeMethod(
                                              'openAutoStartSettings',
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: p.orange,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                          child: Text(
                                            'Configure Settings'.localized(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Daily reminder group
                              SettingsGroup(
                                p: p,
                                title: 'daily reminder'
                                    .localized(context)
                                    .toUpperCase(),
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'daily reminder'.localized(context),
                                    color: p.accent,
                                    value: _dailyReminderEnabled,
                                    onChanged: (value) async {
                                      HapticFeedback.selectionClick();
                                      if (value) {
                                        final granted =
                                            await _fileChannel.invokeMethod<
                                              bool
                                            >(
                                              'requestNotificationPermission',
                                            ) ??
                                            true;
                                        if (!context.mounted) return;
                                        if (!granted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
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
                                        () => _dailyReminderEnabled = value,
                                      );
                                      await _prefs?.setBool(
                                        'reminder_daily_enabled',
                                        value,
                                      );
                                      await _syncReminder('daily');
                                    },
                                  ),
                                  if (_dailyReminderEnabled) ...[
                                    SettingsRow(
                                      p: p,
                                      title: 'Time'.localized(context),
                                      status: _dailyReminderTime.format(
                                        context,
                                      ),
                                      color: p.accent,
                                      onTap: () async {
                                        HapticFeedback.selectionClick();
                                        final time = await _showIOSTimePicker(
                                          context,
                                          _dailyReminderTime,
                                        );
                                        if (time != null) {
                                          setState(
                                            () => _dailyReminderTime = time,
                                          );
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
                                    ),
                                    SettingsRow(
                                      p: p,
                                      title: 'Message'.localized(context),
                                      status: _dailyReminderBody.trim().isEmpty
                                          ? 'Empty'.localized(context)
                                          : 'Set'.localized(context),
                                      color: p.accent,
                                      onTap: () =>
                                          _openReminderMessageEditor('daily'),
                                    ),
                                  ],
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Triggers a daily logging reminder alert at your chosen time.'
                                        .localized(context),
                              ),

                              // Inactivity reminder group
                              SettingsGroup(
                                p: p,
                                title: 'inactivity reminder'
                                    .localized(context)
                                    .toUpperCase(),
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'inactivity reminder'.localized(
                                      context,
                                    ),
                                    color: p.orange,
                                    value: _inactivityReminderEnabled,
                                    onChanged: (value) async {
                                      HapticFeedback.selectionClick();
                                      if (value) {
                                        final granted =
                                            await _fileChannel.invokeMethod<
                                              bool
                                            >(
                                              'requestNotificationPermission',
                                            ) ??
                                            true;
                                        if (!context.mounted) return;
                                        if (!granted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
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
                                        () =>
                                            _inactivityReminderEnabled = value,
                                      );
                                      await _prefs?.setBool(
                                        'reminder_inactivity_enabled',
                                        value,
                                      );
                                      await _syncReminder('inactivity');
                                    },
                                  ),
                                  if (_inactivityReminderEnabled)
                                    SettingsRow(
                                      p: p,
                                      title: 'remind if inactive for'.localized(
                                        context,
                                      ),
                                      status:
                                          '${_inactivityIntervalMins ~/ 60} ${_inactivityIntervalMins == 60 ? 'hour'.localized(context) : 'hours'.localized(context)}',
                                      color: p.orange,
                                      onTap: () async {
                                        HapticFeedback.selectionClick();
                                        final selected = await showDialog<int>(
                                          context: context,
                                          builder: (context) {
                                            return SimpleDialog(
                                              title: Text(
                                                'remind if inactive for'
                                                    .localized(context),
                                              ),
                                              children: [
                                                for (final interval in [
                                                  60,
                                                  120,
                                                  240,
                                                  480,
                                                  720,
                                                  1440,
                                                ])
                                                  SimpleDialogOption(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          interval,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8.0,
                                                          ),
                                                      child: Text(
                                                        '${interval ~/ 60} ${interval == 60 ? 'hour'.localized(context) : 'hours'.localized(context)}',
                                                        style: TextStyle(
                                                          color: p.text,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        );
                                        if (selected != null) {
                                          setState(
                                            () => _inactivityIntervalMins =
                                                selected,
                                          );
                                          await _prefs?.setInt(
                                            'reminder_inactivity_interval_mins',
                                            selected,
                                          );
                                          await _syncReminder('inactivity');
                                        }
                                      },
                                    ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Reschedules a timer on every moment you record. Alerts you if you haven\'t logged anything in the selected interval.'
                                        .localized(context),
                              ),

                              // Weekly reminder group
                              SettingsGroup(
                                p: p,
                                title: 'weekly reminder'
                                    .localized(context)
                                    .toUpperCase(),
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'weekly reminder'.localized(context),
                                    color: p.green,
                                    value: _weeklyReminderEnabled,
                                    onChanged: (value) async {
                                      HapticFeedback.selectionClick();
                                      if (value) {
                                        final granted =
                                            await _fileChannel.invokeMethod<
                                              bool
                                            >(
                                              'requestNotificationPermission',
                                            ) ??
                                            true;
                                        if (!context.mounted) return;
                                        if (!granted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
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
                                        () => _weeklyReminderEnabled = value,
                                      );
                                      await _prefs?.setBool(
                                        'reminder_weekly_enabled',
                                        value,
                                      );
                                      await _syncReminder('weekly');
                                    },
                                  ),
                                  if (_weeklyReminderEnabled) ...[
                                    SettingsRow(
                                      p: p,
                                      title: 'days of week'.localized(context),
                                      status: _weeklyReminderDays
                                          .map((d) {
                                            return switch (d) {
                                              1 => 'Sun'.localized(context),
                                              2 => 'Mon'.localized(context),
                                              3 => 'Tue'.localized(context),
                                              4 => 'Wed'.localized(context),
                                              5 => 'Thu'.localized(context),
                                              6 => 'Fri'.localized(context),
                                              7 => 'Sat'.localized(context),
                                              _ => '',
                                            };
                                          })
                                          .join(', '),
                                      color: p.green,
                                      onTap: () async {
                                        HapticFeedback.selectionClick();
                                        final days = [1, 2, 3, 4, 5, 6, 7];
                                        final selectedDays = List<int>.from(
                                          _weeklyReminderDays,
                                        );
                                        final updated = await showDialog<List<int>>(
                                          context: context,
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder: (context, setDialogState) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'days of week'.localized(
                                                      context,
                                                    ),
                                                  ),
                                                  content: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: days.map((day) {
                                                        final name =
                                                            switch (day) {
                                                              1 =>
                                                                'Sunday'
                                                                    .localized(
                                                                      context,
                                                                    ),
                                                              2 =>
                                                                'Monday'
                                                                    .localized(
                                                                      context,
                                                                    ),
                                                              3 =>
                                                                'Tuesday'
                                                                    .localized(
                                                                      context,
                                                                    ),
                                                              4 =>
                                                                'Wednesday'
                                                                    .localized(
                                                                      context,
                                                                    ),
                                                              5 =>
                                                                'Thursday'
                                                                    .localized(
                                                                      context,
                                                                    ),
                                                              6 =>
                                                                'Friday'
                                                                    .localized(
                                                                      context,
                                                                    ),
                                                              7 =>
                                                                'Saturday'
                                                                    .localized(
                                                                      context,
                                                                    ),
                                                              _ => '',
                                                            };
                                                        final contains =
                                                            selectedDays
                                                                .contains(day);
                                                        return CheckboxListTile(
                                                          title: Text(
                                                            name,
                                                            style: TextStyle(
                                                              color: p.text,
                                                            ),
                                                          ),
                                                          value: contains,
                                                          activeColor: p.accent,
                                                          onChanged: (val) {
                                                            setDialogState(() {
                                                              if (val == true) {
                                                                selectedDays
                                                                    .add(day);
                                                              } else {
                                                                selectedDays
                                                                    .remove(
                                                                      day,
                                                                    );
                                                              }
                                                            });
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            selectedDays,
                                                          ),
                                                      child: Text(
                                                        'okay'.localized(
                                                          context,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                        if (updated != null) {
                                          setState(
                                            () =>
                                                _weeklyReminderDays = updated
                                                  ..sort(),
                                          );
                                          await _prefs?.setStringList(
                                            'reminder_weekly_days',
                                            updated
                                                .map((e) => e.toString())
                                                .toList(),
                                          );
                                          await _syncReminder('weekly');
                                        }
                                      },
                                    ),
                                    SettingsRow(
                                      p: p,
                                      title: 'Time'.localized(context),
                                      status: _weeklyReminderTime.format(
                                        context,
                                      ),
                                      color: p.green,
                                      onTap: () async {
                                        HapticFeedback.selectionClick();
                                        final time = await _showIOSTimePicker(
                                          context,
                                          _weeklyReminderTime,
                                        );
                                        if (time != null) {
                                          setState(
                                            () => _weeklyReminderTime = time,
                                          );
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
                                    ),
                                    SettingsRow(
                                      p: p,
                                      title: 'Message'.localized(context),
                                      status: _weeklyReminderBody.trim().isEmpty
                                          ? 'Empty'.localized(context)
                                          : 'Set'.localized(context),
                                      color: p.green,
                                      onTap: () =>
                                          _openReminderMessageEditor('weekly'),
                                    ),
                                  ],
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Triggers reminders on specific days of the week.'
                                        .localized(context),
                              ),

                              // Monthly reminder group
                              SettingsGroup(
                                p: p,
                                title: 'monthly reminder'
                                    .localized(context)
                                    .toUpperCase(),
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'monthly reminder'.localized(
                                      context,
                                    ),
                                    color: p.red,
                                    value: _monthlyReminderEnabled,
                                    onChanged: (value) async {
                                      HapticFeedback.selectionClick();
                                      if (value) {
                                        final granted =
                                            await _fileChannel.invokeMethod<
                                              bool
                                            >(
                                              'requestNotificationPermission',
                                            ) ??
                                            true;
                                        if (!context.mounted) return;
                                        if (!granted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
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
                                        () => _monthlyReminderEnabled = value,
                                      );
                                      await _prefs?.setBool(
                                        'reminder_monthly_enabled',
                                        value,
                                      );
                                      await _syncReminder('monthly');
                                    },
                                  ),
                                  if (_monthlyReminderEnabled) ...[
                                    SettingsRow(
                                      p: p,
                                      title: 'day of month'.localized(context),
                                      status: '$_monthlyReminderDay',
                                      color: p.red,
                                      onTap: () async {
                                        HapticFeedback.selectionClick();
                                        final selected = await showDialog<int>(
                                          context: context,
                                          builder: (context) {
                                            return SimpleDialog(
                                              title: Text(
                                                'day of month'.localized(
                                                  context,
                                                ),
                                              ),
                                              children: [
                                                for (
                                                  int day = 1;
                                                  day <= 28;
                                                  day++
                                                )
                                                  SimpleDialogOption(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          day,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 6.0,
                                                          ),
                                                      child: Text(
                                                        '$day',
                                                        style: TextStyle(
                                                          color: p.text,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        );
                                        if (selected != null) {
                                          setState(
                                            () =>
                                                _monthlyReminderDay = selected,
                                          );
                                          await _prefs?.setInt(
                                            'reminder_monthly_day',
                                            selected,
                                          );
                                          await _syncReminder('monthly');
                                        }
                                      },
                                    ),
                                    SettingsRow(
                                      p: p,
                                      title: 'Time'.localized(context),
                                      status: _monthlyReminderTime.format(
                                        context,
                                      ),
                                      color: p.red,
                                      onTap: () async {
                                        HapticFeedback.selectionClick();
                                        final time = await _showIOSTimePicker(
                                          context,
                                          _monthlyReminderTime,
                                        );
                                        if (time != null) {
                                          setState(
                                            () => _monthlyReminderTime = time,
                                          );
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
                                    ),
                                    SettingsRow(
                                      p: p,
                                      title: 'Message'.localized(context),
                                      status:
                                          _monthlyReminderBody.trim().isEmpty
                                          ? 'Empty'.localized(context)
                                          : 'Set'.localized(context),
                                      color: p.red,
                                      onTap: () =>
                                          _openReminderMessageEditor('monthly'),
                                    ),
                                  ],
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Triggers a monthly reminder on a chosen calendar day.'
                                        .localized(context),
                              ),

                              const SizedBox(height: spacing48),
                            ]),
                          ),

                        if (show('Moments'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              if (widget.onOpenTrash != null) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    16,
                                    8,
                                  ),
                                  child: Text(
                                    'RECENTLY DELETED'.localized(context),
                                    style: TextStyle(
                                      color: p.text3,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: p.surface2,
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      child: Column(
                                        children: [
                                          SettingsRow(
                                            p: p,
                                            icon: Icons.delete_outline_rounded,
                                            title: 'Trash Bin'.localized(
                                              context,
                                            ),
                                            status:
                                                '${_trash.length} ${(_trash.length == 1 ? "item" : "items").localized(context)}',
                                            color: p.orange,
                                            onTap: () => _openCategory(
                                              'Trash Bin',
                                              parent: 'Moments',
                                            ),
                                          ),
                                          Divider(height: 0.5, color: p.border),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: p.surface3.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                            child: Text(
                                              _trash.isEmpty
                                                  ? 'Restore or permanently remove deleted moments'
                                                        .localized(context)
                                                  : '${_trash.first.date} • ${_trash.first.note.isEmpty ? 'No note'.localized(context) : _trash.first.note}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: p.text3,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
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
                                      'View and restore moments deleted within the last 30 days.',
                                ),
                              ],
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
                                        historyDensity = value
                                            ? 'compact'
                                            : 'comfortable';
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
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'Note on Click',
                                    subtitle:
                                        'Tap a moment to view or edit its note, and long-press to select for duration.',
                                    color: p.accent,
                                    value: enableNoteOnClick,
                                    onChanged: (value) async {
                                      if (_prefs != null) {
                                        await _prefs!.setBool(
                                          'enable_note_on_click',
                                          value,
                                        );
                                      }
                                      setState(() => enableNoteOnClick = value);
                                    },
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Controls log spacing density, tap actions, and delete confirmations for history moments.',
                              ),

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
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Includes years, months, and days breakdown for long time intervals between moments.',
                              ),

                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'Minimal Moment Options',
                                    color: p.accent,
                                    value: minimalMomentOptions,
                                    onChanged: (value) {
                                      setState(
                                        () => minimalMomentOptions = value,
                                      );
                                      widget.onMinimalMomentOptions(value);
                                    },
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Enables streamlined icon-only quick action buttons when managing history moments.',
                              ),

                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.search_rounded,
                                    title: 'Search Notes'.localized(context),
                                    color: p.accent,
                                    status:
                                        '${entries.where((e) => e.note.isNotEmpty).length} ${'Notes'.localized(context)}',
                                    onTap: () => _openCategory(
                                      'Search Notes',
                                      parent: 'Moments',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Sobriety Companion'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Privacy-first streak tracking and relapse diary. All data stays on your device. Existing logs are never altered.'
                                        .localized(context),
                              ),
                              SettingsGroup(
                                p: p,
                                title: 'Streak Mode'.localized(context),
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    icon: Icons.self_improvement_rounded,
                                    title: 'Enable Sobriety Mode'.localized(
                                      context,
                                    ),
                                    subtitle:
                                        'Adds a clean streak card to your home screen and adapts home screen widgets.'
                                            .localized(context),
                                    color: p.orange,
                                    value: enableSobrietyMode,
                                    onChanged: (value) async {
                                      if (_prefs != null) {
                                        await _prefs!.setBool(
                                          'enable_sobriety_mode',
                                          value,
                                        );
                                      }
                                      setState(
                                        () => enableSobrietyMode = value,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (enableSobrietyMode) ...[
                                SettingsPageDescription(
                                  p: p,
                                  text:
                                      'Your home screen will show a live streak card with milestone badges. The home widget will adapt to show RESET and DIARY buttons.'
                                          .localized(context),
                                ),
                                const SizedBox(height: 12),
                                SettingsGroup(
                                  p: p,
                                  title: 'Streak Reset Logic'.localized(
                                    context,
                                  ),
                                  children: [
                                    SettingsSwitchRow(
                                      p: p,
                                      icon: Icons.restart_alt_rounded,
                                      title: 'Reset on Relapse Tag Only'
                                          .localized(context),
                                      subtitle:
                                          'Only moments tagged #relapse reset the streak. Turn off to reset on any new log.'
                                              .localized(context),
                                      color: p.orange,
                                      value: sobrietyResetType == 'relapse',
                                      onChanged: (value) async {
                                        final nextType = value
                                            ? 'relapse'
                                            : 'any';
                                        if (_prefs != null) {
                                          await _prefs!.setString(
                                            'sobriety_reset_type',
                                            nextType,
                                          );
                                        }
                                        setState(
                                          () => sobrietyResetType = nextType,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SettingsGroup(
                                  p: p,
                                  title: 'Trigger Diary'.localized(context),
                                  children: [
                                    SettingsRow(
                                      p: p,
                                      icon: Icons.analytics_rounded,
                                      title: 'Trigger Analysis'.localized(
                                        context,
                                      ),
                                      subtitle:
                                          'View your relapse pattern insights, top moods, and peak vulnerability windows.'
                                              .localized(context),
                                      color: p.orange,
                                      trailing: Icon(
                                        Icons.chevron_right_rounded,
                                        color: p.text3,
                                        size: 20,
                                      ),
                                      onTap: () => _openCategory(
                                        'Trigger Analysis',
                                        parent: 'Sobriety Companion',
                                      ),
                                    ),
                                  ],
                                ),
                                SettingsPageDescription(
                                  p: p,
                                  text:
                                      'When logging a moment with Sobriety Mode on, you can tag mood (Bored, Anxious, Lonely...) and trigger (Social Media, Late Night...). These are stored as hashtags in the note for full backwards compatibility.'
                                          .localized(context),
                                ),
                                const SizedBox(height: 12),
                                SettingsGroup(
                                  p: p,
                                  title: 'Custom Start Date'.localized(context),
                                  children: [
                                    SettingsRow(
                                      p: p,
                                      icon: Icons.calendar_today_rounded,
                                      title: 'Set Sobriety Start Date'
                                          .localized(context),
                                      subtitle: sobrietyCustomStartMs != null
                                          ? '${"From".localized(context)} ${datePretty(sobrietyCustomStartMs!)} ${"at".localized(context)} ${timeOnly(sobrietyCustomStartMs!).substring(0, 5)}'
                                          : 'Not set: using last log or relapse tag'
                                                .localized(context),
                                      color: p.orange,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (sobrietyCustomStartMs != null)
                                            GestureDetector(
                                              onTap: () async {
                                                await _prefs?.remove(
                                                  'sobriety_custom_start_ms',
                                                );
                                                setState(
                                                  () => sobrietyCustomStartMs =
                                                      null,
                                                );
                                              },
                                              child: Icon(
                                                Icons.close_rounded,
                                                color: p.text3,
                                                size: 18,
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: p.text3,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        final now = DateTime.now();
                                        final initialDateTime =
                                            sobrietyCustomStartMs != null
                                            ? DateTime.fromMillisecondsSinceEpoch(
                                                sobrietyCustomStartMs!,
                                              )
                                            : now.subtract(
                                                const Duration(days: 7),
                                              );
                                        final picked =
                                            await _showIOSDateTimePicker(
                                              context,
                                              initialDateTime,
                                            );
                                        if (picked != null && mounted) {
                                          final ms =
                                              picked.millisecondsSinceEpoch;
                                          await _prefs?.setInt(
                                            'sobriety_custom_start_ms',
                                            ms,
                                          );
                                          setState(
                                            () => sobrietyCustomStartMs = ms,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                SettingsPageDescription(
                                  p: p,
                                  text:
                                      'Were you already clean before installing? Set your actual start date here. This overrides automatic detection from your logs.'
                                          .localized(context),
                                ),
                                const SizedBox(height: 12),
                                SettingsGroup(
                                  p: p,
                                  title: 'Milestone Theme'.localized(context),
                                  children: [
                                    SettingsRow(
                                      p: p,
                                      icon: Icons.palette_rounded,
                                      title: 'Theme Style'.localized(context),
                                      subtitle: () {
                                        final t = kMilestoneThemes.firstWhere(
                                          (t) => t.id == sobrietyMilestoneTheme,
                                          orElse: () => kMilestoneThemes.first,
                                        );
                                        return '${t.emoji} ${t.name.localized(context)}: ${t.description.localized(context)}';
                                      }(),
                                      color: p.orange,
                                      trailing: Icon(
                                        Icons.chevron_right_rounded,
                                        color: p.text3,
                                        size: 20,
                                      ),
                                      onTap: () => _openCategory(
                                        'Milestone Theme',
                                        parent: 'Sobriety Companion',
                                      ),
                                    ),
                                    SettingsRow(
                                      p: p,
                                      icon: Icons.emoji_events_rounded,
                                      title: 'View All Milestones'.localized(
                                        context,
                                      ),
                                      subtitle:
                                          'See all 21 milestones with descriptions from day 1 to 10 years.'
                                              .localized(context),
                                      color: p.orange,
                                      trailing: Icon(
                                        Icons.chevron_right_rounded,
                                        color: p.text3,
                                        size: 20,
                                      ),
                                      onTap: () => _openCategory(
                                        'Milestones',
                                        parent: 'Sobriety Companion',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Trigger Analysis'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Offline analysis of your logged relapse moments. No data leaves your device.',
                              ),
                              _buildSobrietyAnalyticsCard(p),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Milestone Theme'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Choose the narrative style for your milestone names. Each theme is psychologically curated to match a different self-image and motivation style.',
                              ),
                              SettingsGroup(
                                p: p,
                                children: [
                                  for (final theme in kMilestoneThemes)
                                    SettingsRow(
                                      p: p,
                                      title: '${theme.emoji} ${theme.name}',
                                      subtitle: theme.description,
                                      color: p.orange,
                                      trailing:
                                          sobrietyMilestoneTheme == theme.id
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
                                        await _prefs?.setString(
                                          'sobriety_milestone_theme',
                                          theme.id,
                                        );
                                        setState(
                                          () =>
                                              sobrietyMilestoneTheme = theme.id,
                                        );
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Milestones'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'All 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. Names shown in your current theme.',
                              ),
                              SettingsGroup(
                                p: p,
                                children: [
                                  for (final milestone in kSobrietyMilestones)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: spacing16,
                                        vertical: spacing12,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 52,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: p.orange.withValues(
                                                alpha: 0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  milestone.days.toString(),
                                                  style: TextStyle(
                                                    color: p.orange,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'DAYS',
                                                  style: TextStyle(
                                                    color: p.orange.withValues(
                                                      alpha: 0.7,
                                                    ),
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  getMilestoneName(
                                                    milestone,
                                                    sobrietyMilestoneTheme,
                                                  ),
                                                  style: TextStyle(
                                                    color: p.text,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  milestone.whyItMatters,
                                                  style: TextStyle(
                                                    color: p.text2,
                                                    fontSize: 11,
                                                    height: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  getMilestoneFlavor(
                                                    milestone,
                                                    sobrietyMilestoneTheme,
                                                  ),
                                                  style: TextStyle(
                                                    color: p.orange.withValues(
                                                      alpha: 0.8,
                                                    ),
                                                    fontSize: 10,
                                                    fontStyle: FontStyle.italic,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Search Notes')) ...[
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: SliverStickyHeaderDelegate(
                              height: 80,
                              child: Container(
                                color: p.surface.withValues(
                                  alpha:
                                      !reduceMotion &&
                                          enableTranslucency &&
                                          AdaptiveEngine().supportsBlur
                                      ? 0.65
                                      : 1.0,
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  spacing16,
                                  spacing8,
                                  spacing16,
                                  spacing12,
                                ),
                                child: SearchNotesBox(
                                  p: p,
                                  controller: _settingsSearchController,
                                  onChanged: (value) =>
                                      setState(() => _settingsQuery = value),
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
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  8,
                                ),
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
                                ),
                              ];
                            }

                            return [
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  spacing16,
                                  spacing4,
                                  spacing16,
                                  spacing16,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    if (index >= notes.length) return null;
                                    final entry = notes[index];

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: compactHistory ? 10 : 16,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(
                                          spacing16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: p.surface2,
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          border: Border.all(
                                            color: p.border.withValues(
                                              alpha: 0.6,
                                            ),
                                            width: 0.8,
                                          ),
                                          boxShadow: p.name == 'amoled'
                                              ? null
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.04,
                                                        ),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: momentColor(
                                                      p,
                                                      entry.type,
                                                    ).withValues(alpha: 0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    entry.type.toUpperCase(),
                                                    style: TextStyle(
                                                      color: momentColor(
                                                        p,
                                                        entry.type,
                                                      ),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w900,
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
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFeatures: const [
                                                        FontFeature.tabularFigures(),
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
                                  }, childCount: notes.length),
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
                          SliverToBoxAdapter(child: _updateCenterPage(p)),
                        if (show('Build Choose'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              _buildChoosePage(p),
                            ]),
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
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsGroup(
                                p: p,
                                insetDividers: true,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.system_update_outlined,
                                    title: 'Software Update',
                                    color: p.text2,
                                    status: null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (checkingUpdates)
                                          const CupertinoActivityIndicator(
                                            radius: 6,
                                            color: Colors.grey,
                                          )
                                        else if (updateInfo != null)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color:
                                                  (updateInfo!.isSecurity ==
                                                          true ||
                                                      updateInfo!.isImportant ==
                                                          true)
                                                  ? p.red
                                                  : p.orange,
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                        else
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: p.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        const SizedBox(width: spacing8),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: p.text3,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    onTap: () => _openCategory(
                                      'Update Center',
                                      parent: 'Updates & Notices',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.track_changes_rounded,
                                    title: 'Build Channel',
                                    color: p.accent,
                                    status: _betaTrack
                                        ? 'Beta'.localized(context)
                                        : 'Stable'.localized(context),
                                    onTap: () => _openCategory(
                                      'Build Choose',
                                      parent: 'Updates & Notices',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Keep NoteKar up to date with the latest features and security patches.'
                                        .localized(context),
                              ),
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
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Checks for official announcement notices and bug fix announcements.'
                                        .localized(context),
                              ),
                              SettingsGroup(
                                p: p,
                                title: 'Release Notes & History',
                                insetDividers: true,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.auto_awesome_rounded,
                                    title: "What's New",
                                    color: p.orange,
                                    status: 'Recent'.localized(context),
                                    onTap: () => _openCategory(
                                      "What's New",
                                      parent: 'Updates & Notices',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.history_edu_rounded,
                                    title: 'Changelog',
                                    color: p.green,
                                    status: 'History'.localized(context),
                                    onTap: () => _openCategory(
                                      'Changelog',
                                      parent: 'Updates & Notices',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.history_rounded,
                                    title: 'Commits',
                                    color: p.accent,
                                    status: 'Activity'.localized(context),
                                    onTap: () => _openCategory(
                                      'Commits',
                                      parent: 'Updates & Notices',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'View release highlights, version logs, and bug fix summaries for NoteKar.',
                              ),

                              SettingsBetaNote(
                                p: p,
                                text:
                                    'The current features on this page are under Beta stage.',
                                onLearnMore: () => _showBetaInfoPopup(p),
                              ),
                              const SizedBox(height: spacing48),
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
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.archive_outlined,
                                    title: 'Backup & Export'.localized(context),
                                    status:
                                        '${entries.length} ${'Logs'.localized(context)}',
                                    color: p.green,
                                    onTap: () => _openCategory(
                                      'Backup & Export',
                                      parent: 'Data & Backup',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.health_and_safety_outlined,
                                    title: 'Backup Status'.localized(context),
                                    status: _dataHealthStatus,
                                    color: p.accent,
                                    onTap: () => _openCategory(
                                      'Backup Status',
                                      parent: 'Data & Backup',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'NoteKar uses a private offline database. Use these tools to secure your history via manual exports.',
                              ),
                              const SizedBox(height: spacing48),
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
                                      title: days == 0
                                          ? 'Disabled'
                                          : 'Every $days Days',
                                      trailing: backupReminderDays == days
                                          ? Icon(
                                              Icons.check_rounded,
                                              color: p.accent,
                                              size: 20,
                                            )
                                          : const SizedBox.shrink(),
                                      onTap: () {
                                        if (backupReminderDays == days) return;
                                        setState(
                                          () => backupReminderDays = days,
                                        );
                                        widget.onBackupReminderDays(days);
                                      },
                                    ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text: backupReminderDays == 0
                                    ? 'Reminders are currently disabled. Set an interval to be reminded to safeguard your data.'
                                    : 'NoteKar will prompt for a backup every $backupReminderDays days.',
                              ),

                              SettingsGroup(
                                p: p,
                                title: 'CSV Export',
                                insetDividers: true,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.table_chart_outlined,
                                    title: 'Export CSV',
                                    status: 'Table',
                                    color: p.green,
                                    rowKind: 'link',
                                    onTap: () => unawaited(
                                      _runExport('CSV', widget.onExportCsv),
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.date_range_outlined,
                                    title: 'Export Last 7 Days',
                                    status: 'Recent',
                                    color: p.green,
                                    rowKind: 'link',
                                    onTap: () => unawaited(
                                      _runExport(
                                        'Recent CSV',
                                        widget.onExportRecentCsv,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Export moments to standard CSV formats. "Export CSV" saves your entire history, while "Export Last 7 Days" saves only recent records.',
                              ),

                              SettingsGroup(
                                p: p,
                                title: 'JSON Export',
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.code_rounded,
                                    title: 'Export JSON',
                                    status: 'Dev',
                                    color: p.accent,
                                    rowKind: 'link',
                                    onTap: () => unawaited(
                                      _runExport('JSON', widget.onExportJson),
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Export moments to developer-friendly JSON format for advanced integrations and data portability.',
                              ),

                              SettingsGroup(
                                p: p,
                                title: 'Database Backups',
                                insetDividers: true,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.archive_outlined,
                                    title: 'Export Backup',
                                    status: 'Full',
                                    color: p.accent,
                                    rowKind: 'link',
                                    onTap: () => unawaited(
                                      _runExport(
                                        'Backup',
                                        widget.onExportBackup,
                                      ),
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.unarchive_outlined,
                                    title: 'Import Backup',
                                    status: 'Restore',
                                    color: p.orange,
                                    rowKind: 'link',
                                    onTap: () => unawaited(_runImport()),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Manage complete database backups. Safely archive your entire history or restore it when migrating to another device.',
                              ),
                              const SizedBox(height: spacing48),
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
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.android_rounded,
                                    title: 'Android Backup',
                                    color: p.green,
                                    status: 'Active',
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.favorite_outline_rounded,
                                    title: 'Data Health',
                                    color: p.green,
                                    status: _dataHealthStatus,
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Android OS auto-backup preserves app preferences only. Your moments and notes stay 100% local and private to this device.',
                              ),

                              SettingsGroup(
                                p: p,
                                title: 'Cloud & Sync (Planned)',
                                insetDividers: true,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.lock_outlined,
                                    title: 'Encrypted Backup',
                                    color: p.orange,
                                    status: 'Planned',
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.cloud_outlined,
                                    title: 'Google Drive Backup',
                                    color: p.orange,
                                    status: 'Planned',
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Planned cloud features will provide direct cloud synchronization across your personal devices.',
                              ),

                              SettingsBetaNote(
                                p: p,
                                text:
                                    'The current features on this page are under Beta stage.',
                                onLearnMore: () => _showBetaInfoPopup(p),
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Privacy & Security'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Glass(
                                  p: p,
                                  radius: 32,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: p.green.withValues(
                                                alpha: 0.12,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.verified_user_rounded,
                                              color: p.green,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'VirusTotal Safety Scan'
                                                      .localized(context),
                                                  style: TextStyle(
                                                    color: p.text,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Verified clean of malicious activity'
                                                      .localized(context),
                                                  style: TextStyle(
                                                    color: p.text3,
                                                    fontSize: 11.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // 2x2 Metric Table
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 52,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              alignment: Alignment.centerLeft,
                                              decoration: BoxDecoration(
                                                color: p.surface3.withValues(
                                                  alpha: 0.4,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: p.border.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .check_circle_outline_rounded,
                                                    color: p.green,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Ratio'.localized(
                                                            context,
                                                          ),
                                                          style: TextStyle(
                                                            color: p.text3,
                                                            fontSize: 9.5,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          _vtRatio.localized(
                                                            context,
                                                          ),
                                                          style: TextStyle(
                                                            color: p.text,
                                                            fontSize: 11.5,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              height: 52,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              alignment: Alignment.centerLeft,
                                              decoration: BoxDecoration(
                                                color: p.surface3.withValues(
                                                  alpha: 0.4,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: p.border.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.shield_outlined,
                                                    color: p.green,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Status'.localized(
                                                            context,
                                                          ),
                                                          style: TextStyle(
                                                            color: p.text3,
                                                            fontSize: 9.5,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          _vtStatus.localized(
                                                            context,
                                                          ),
                                                          style: TextStyle(
                                                            color:
                                                                _vtStatus ==
                                                                    'Detected'
                                                                ? p.red
                                                                : p.green,
                                                            fontSize: 11.5,
                                                            fontWeight:
                                                                FontWeight.w700,
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
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 52,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              alignment: Alignment.centerLeft,
                                              decoration: BoxDecoration(
                                                color: p.surface3.withValues(
                                                  alpha: 0.4,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: p.border.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .calendar_today_rounded,
                                                    color: p.text3,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Last Scan'.localized(
                                                            context,
                                                          ),
                                                          style: TextStyle(
                                                            color: p.text3,
                                                            fontSize: 9.5,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          _vtScanDate.localized(
                                                            context,
                                                          ),
                                                          style: TextStyle(
                                                            color: p.text,
                                                            fontSize: 11.5,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              height: 52,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              alignment: Alignment.centerLeft,
                                              decoration: BoxDecoration(
                                                color: p.surface3.withValues(
                                                  alpha: 0.4,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: p.border.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.lock_outline_rounded,
                                                    color: p.text3,
                                                    size: 15,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Signature'.localized(
                                                            context,
                                                          ),
                                                          style: TextStyle(
                                                            color: p.text3,
                                                            fontSize: 9.5,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          'Developer Key'
                                                              .localized(
                                                                context,
                                                              ),
                                                          style: TextStyle(
                                                            color: p.text,
                                                            fontSize: 11.5,
                                                            fontWeight:
                                                                FontWeight.w700,
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
                                      const SizedBox(height: 16),
                                      Text(
                                        'NoteKar builds undergo automated CodeQL scanner compilation and local VirusTotal scans. Binaries are signed with our official certificate to ensure absolute integrity.'
                                            .localized(context),
                                        style: TextStyle(
                                          color: p.text2,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  await _fileChannel
                                                      .invokeMethod<void>(
                                                        'openUrl',
                                                        {'url': _vtUrl},
                                                      );
                                                } catch (_) {}
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: p.green
                                                    .withValues(alpha: 0.15),
                                                foregroundColor: p.green,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.security_rounded,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      'VT Report'.localized(
                                                        context,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      softWrap: false,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                try {
                                                  await _fileChannel.invokeMethod<
                                                    void
                                                  >('openUrl', {
                                                    'url':
                                                        'https://github.com/dheeraz101/Notekar-Android/releases/latest',
                                                  });
                                                } catch (_) {}
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: p.text2,
                                                side: BorderSide(
                                                  color: p.border,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.fingerprint_rounded,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      'SHA-256 Hashes'
                                                          .localized(context),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      softWrap: false,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SettingsGroup(
                                p: p,
                                title: 'Data & Privacy',
                                insetDividers: true,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.analytics_outlined,
                                    title: 'No Analytics',
                                    color: p.green,
                                    status: 'None',
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.wifi_off_rounded,
                                    title: 'Network Use',
                                    color: p.accent,
                                    status: 'Limited',
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'NoteKar contains zero third-party telemetry. Network access is restricted strictly to update checks and announcement fetching.',
                              ),

                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.lock_outlined,
                                    title: 'App Lock',
                                    color: p.orange,
                                    status: privacyLock ? 'On' : 'Off',
                                    onTap: () => _openCategory(
                                      'App Lock',
                                      parent: 'Privacy & Security',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Protect your saved history using device biometric authentication or system PIN.',
                              ),

                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    icon: Icons.screenshot_rounded,
                                    title: 'Hide App Content',
                                    subtitle:
                                        'Obfuscate application screens and block screenshots in the system recents switcher.',
                                    value: obfuscateInRecents,
                                    color: p.green,
                                    onChanged: (value) async {
                                      if (_prefs != null) {
                                        await _prefs!.setBool(
                                          'obfuscate_in_recents',
                                          value,
                                        );
                                      }
                                      setState(
                                        () => obfuscateInRecents = value,
                                      );
                                      try {
                                        await const MethodChannel(
                                          'notekar/files',
                                        ).invokeMethod<void>(
                                          'setObfuscateInRecents',
                                          {'enabled': value},
                                        );
                                      } catch (_) {}
                                    },
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Requires user consent. When enabled, your sensitive moments and notes cannot be viewed from the app switcher.',
                              ),

                              SettingsBetaNote(
                                p: p,
                                text:
                                    'The current features on this page are under Beta stage.',
                                onLearnMore: () => _showBetaInfoPopup(p),
                              ),
                              const SizedBox(height: spacing48),
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
                                        if (mounted) {
                                          setState(() => privacyLock = false);
                                        }
                                        return;
                                      }
                                      final changed = await widget
                                          .onPrivacyLock(true);
                                      if (changed && mounted) {
                                        setState(() => privacyLock = true);
                                      }
                                    },
                                  ),
                                  if (privacyLock &&
                                      widget.isSystemLockAvailable)
                                    SettingsRow(
                                      p: p,
                                      title: 'Configure Lock',
                                      status: privacyLockType == 'system'
                                          ? 'System Lock'
                                          : 'In-App PIN',
                                      onTap: () =>
                                          _openCategory('Configure Lock'),
                                    ),
                                  if (privacyLock &&
                                      privacyLockType == 'custom_pin')
                                    SettingsRow(
                                      p: p,
                                      title: 'Reset PIN Lock'.localized(
                                        context,
                                      ),
                                      subtitle:
                                          'Change your secure in-app passcode.'
                                              .localized(context),
                                      color: p.accent,
                                      onTap: () async {
                                        await widget.onResetPrivacyPin();
                                      },
                                    ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Requires biometric or system PIN authentication to open NoteKar.',
                              ),
                              if (privacyLock) ...[
                                SettingsGroup(
                                  p: p,
                                  title: 'When to Lock',
                                  children: [
                                    for (final entry in const {
                                      '0': 'Immediately',
                                      '1': 'After 1 Minute',
                                      '5': 'After 5 Minutes',
                                      '10': 'After 10 Minutes',
                                    }.entries)
                                      SettingsRow(
                                        p: p,
                                        title: entry.value,
                                        trailing:
                                            privacyLockDelayMinutes ==
                                                int.parse(entry.key)
                                            ? Icon(
                                                Icons.check_rounded,
                                                color: p.accent,
                                                size: 20,
                                              )
                                            : const SizedBox.shrink(),
                                        onTap: () {
                                          final minutes = int.parse(entry.key);
                                          if (minutes ==
                                              privacyLockDelayMinutes) {
                                            return;
                                          }
                                          setState(
                                            () => privacyLockDelayMinutes =
                                                minutes,
                                          );
                                          widget.onPrivacyLockDelay(minutes);
                                        },
                                      ),
                                  ],
                                ),
                                SettingsPageDescription(
                                  p: p,
                                  text:
                                      'Note: Selecting "Immediately" will automatically lock NoteKar as soon as you switch apps, view recent apps, or open your phone notification panel.',
                                ),
                              ],
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Configure Lock'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    title: 'System Lock'.localized(context),
                                    subtitle:
                                        'Use fingerprint, face, or system PIN.'
                                            .localized(context),
                                    trailing: privacyLockType == 'system'
                                        ? Icon(
                                            Icons.check_rounded,
                                            color: p.accent,
                                            size: 20,
                                          )
                                        : const SizedBox.shrink(),
                                    onTap: () async {
                                      if (privacyLockType == 'system') {
                                        return;
                                      }
                                      final success = await widget
                                          .onPrivacyLockTypeChanged('system');
                                      if (success && mounted) {
                                        setState(() {
                                          privacyLockType = 'system';
                                        });
                                        _popCategory();
                                      }
                                    },
                                  ),
                                  SettingsRow(
                                    p: p,
                                    title: 'In-App PIN'.localized(context),
                                    subtitle:
                                        'Configure a dedicated 4-digit passcode.'
                                            .localized(context),
                                    trailing: privacyLockType == 'custom_pin'
                                        ? Icon(
                                            Icons.check_rounded,
                                            color: p.accent,
                                            size: 20,
                                          )
                                        : const SizedBox.shrink(),
                                    onTap: () async {
                                      if (privacyLockType == 'custom_pin') {
                                        return;
                                      }
                                      final success = await widget
                                          .onPrivacyLockTypeChanged(
                                            'custom_pin',
                                          );
                                      if (success && mounted) {
                                        setState(() {
                                          privacyLockType = 'custom_pin';
                                        });
                                        _popCategory();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  5,
                                  20,
                                  16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select how you want to unlock NoteKar. System Lock integrates natively with Android biometric credentials, while In-App PIN utilizes a custom passcode secure to this application.'
                                          .localized(context),
                                      style: TextStyle(
                                        color: p.text3,
                                        fontSize: 13,
                                        height: 1.45,
                                        letterSpacing: -0.05,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          child: Text(
                                            '1.',
                                            style: TextStyle(
                                              color: p.text3,
                                              fontSize: 13,
                                              height: 1.45,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.05,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'System Lock integrates directly with your Android keyguard system, providing hardware-level biometric or PIN protection.'
                                                .localized(context),
                                            style: TextStyle(
                                              color: p.text3,
                                              fontSize: 13,
                                              height: 1.45,
                                              letterSpacing: -0.05,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          child: Text(
                                            '2.',
                                            style: TextStyle(
                                              color: p.text3,
                                              fontSize: 13,
                                              height: 1.45,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.05,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'In-App PIN is cryptographically secured locally using SHA-256 and has built-in brute-force protection to prevent unauthorized access.'
                                                .localized(context),
                                            style: TextStyle(
                                              color: p.text3,
                                              fontSize: 13,
                                              height: 1.45,
                                              letterSpacing: -0.05,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SettingsBetaNote(
                                p: p,
                                text:
                                    'The current features on this page are under Beta stage.'
                                        .localized(context),
                                onLearnMore: () => _showBetaInfoPopup(p),
                              ),
                              const SizedBox(height: spacing48),
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
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.auto_stories_rounded,
                                    title: 'Guides',
                                    color: p.accent,
                                    status: 'Tutorials',
                                    onTap: () => _openCategory(
                                      'Guides',
                                      parent: 'Help & Guides',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.help_outline_rounded,
                                    title: 'Help',
                                    color: p.orange,
                                    status: 'FAQ',
                                    onTap: () => _openCategory(
                                      'Help',
                                      parent: 'Help & Guides',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Explore interactive tutorials for tap logging, duration calculations, and troubleshooting.',
                              ),

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
                                    onTap: () => _openCategory(
                                      'Licenses',
                                      parent: 'Help & Guides',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.article_outlined,
                                    title: 'Terms of Use',
                                    color: p.orange,
                                    status: 'MIT',
                                    onTap: () => _openCategory(
                                      'Terms of Use',
                                      parent: 'Help & Guides',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.security_rounded,
                                    title: 'Privacy Policy',
                                    color: p.green,
                                    status: 'Offline-First',
                                    onTap: () => _openCategory(
                                      'Privacy Policy',
                                      parent: 'Help & Guides',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Review open-source licenses, app usage terms, and offline-first privacy policies.',
                              ),
                              const SizedBox(height: spacing48),
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
                                    status:
                                        hapticStyle[0].toUpperCase() +
                                        hapticStyle.substring(1),
                                    color: p.orange,
                                    onTap: () => _openCategory(
                                      'Accessibility',
                                      parent: 'Advanced',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.bug_report_outlined,
                                    title: 'Diagnostics',
                                    status: 'View',
                                    color: p.accent,
                                    onTap: () => _openCategory(
                                      'Diagnostics',
                                      parent: 'Advanced',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.memory_rounded,
                                    title: 'Device Health',
                                    status: AdaptiveEngine().healthStatus,
                                    color: p.accent,
                                    onTap: () => _openCategory(
                                      'Device Health',
                                      parent: 'Advanced',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.network_check_rounded,
                                    title: 'Network Monitor',
                                    status: 'View',
                                    color: p.accent,
                                    onTap: () => _openCategory(
                                      'Network Monitor',
                                      parent: 'Advanced',
                                    ),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.restart_alt_rounded,
                                    title: 'Reset',
                                    status: 'Wipe',
                                    color: p.red,
                                    onTap: () => _openCategory(
                                      'Reset',
                                      parent: 'Advanced',
                                    ),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'These tools are intended for system maintenance and troubleshooting.',
                              ),
                              const SizedBox(height: spacing48),
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
                                  for (final style in [
                                    'off',
                                    'light',
                                    'standard',
                                  ])
                                    SettingsRow(
                                      p: p,
                                      title:
                                          style[0].toUpperCase() +
                                          style.substring(1),
                                      trailing: hapticStyle == style
                                          ? Icon(
                                              Icons.check_rounded,
                                              color: p.accent,
                                              size: 20,
                                            )
                                          : const SizedBox.shrink(),
                                      onTap: () {
                                        if (hapticStyle == style) return;
                                        HapticFeedback.selectionClick();
                                        setState(() => hapticStyle = style);
                                        widget.onHapticStyle(style);
                                      },
                                    ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Configure the intensity of vibration feedback during taps and saves.',
                              ),

                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'Reduced Motion',
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
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Disables fluid physics and parallax effects to improve performance and stability.',
                              ),

                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'Larger Text',
                                    color: p.orange,
                                    value: largeText,
                                    onChanged: (value) {
                                      setState(() => largeText = value);
                                      widget.onLargeText(value);
                                    },
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Increases the global font scale for improved legibility across all interfaces.',
                              ),

                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsSwitchRow(
                                    p: p,
                                    title: 'High Contrast',
                                    color: p.green,
                                    value: highContrast,
                                    onChanged: (value) {
                                      setState(() => highContrast = value);
                                      widget.onHighContrast(value);
                                    },
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Enhances visibility by using pure black backgrounds and high-intensity accent colors.',
                              ),
                              const SizedBox(height: spacing48),
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
                                    onTap: () =>
                                        unawaited(_confirmResetSettings()),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Restores all settings options to their factory defaults. Your saved moments and notes are kept intact.',
                              ),

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
                                text:
                                    'Permanently deletes all saved timestamps and notes from this device. Preferences remain unchanged.',
                              ),

                              SettingsGroup(
                                p: p,
                                children: [
                                  SettingsRow(
                                    p: p,
                                    icon: Icons.restart_alt_rounded,
                                    title: 'Factory Reset',
                                    color: p.red,
                                    rowKind: 'popup',
                                    onTap: () =>
                                        unawaited(_confirmFactoryReset(p)),
                                  ),
                                ],
                              ),
                              SettingsPageDescription(
                                p: p,
                                text:
                                    'Completely clears all saved data and resets all settings to original fresh state.',
                              ),
                              const SizedBox(height: spacing48),
                            ]),
                          ),
                        if (show('Diagnostics'))
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: spacing8),
                                _diagnosticsPage(p, entries, todayCount),
                                const SizedBox(height: spacing48),
                              ],
                            ),
                          ),
                        if (show('Device Health'))
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: spacing8),
                                _deviceHealthPage(p),
                                const SizedBox(height: spacing48),
                              ],
                            ),
                          ),
                        if (show('Network Monitor')) ...[
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: spacing8),
                                _networkMonitorHeader(p),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          ..._networkMonitorLogsList(p),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: spacing48),
                          ),
                        ],
                        if (show('Privacy Policy'))
                          SliverToBoxAdapter(child: _privacyPolicyPage(p)),
                        if (show('Terms of Use'))
                          SliverToBoxAdapter(child: _termsOfUsePage(p)),
                        if (show('Licenses'))
                          SliverToBoxAdapter(child: _licensesPage(p)),
                        if (show('Feedback'))
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: spacing8),
                                _feedbackRootPage(p),
                                const SizedBox(height: spacing48),
                              ],
                            ),
                          ),

                        if (show("What's New"))
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: spacing8),
                                ChangelogSettingsPage(p: p, latestOnly: true),
                                const SizedBox(height: spacing48),
                              ],
                            ),
                          ),
                        if (show('Trash Bin')) ...[
                          if (_trash.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: p.text2,
                                          side: BorderSide(color: p.border),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () async {
                                          final confirmed =
                                              await showGeneralDialog<bool>(
                                                context: context,
                                                barrierColor: Colors.black
                                                    .withValues(alpha: 0.42),
                                                barrierDismissible: true,
                                                barrierLabel:
                                                    'Close restore confirmation',
                                                transitionDuration:
                                                    const Duration(
                                                      milliseconds: 120,
                                                    ),
                                                pageBuilder: (_, _, _) =>
                                                    ActionConfirmSheet(
                                                      p: p,
                                                      title:
                                                          'Restore All Moments?',
                                                      message:
                                                          'This will return all items currently in the trash to your history.',
                                                      confirmLabel:
                                                          'Restore All',
                                                      icon:
                                                          Icons.restore_rounded,
                                                    ),
                                              );
                                          if (confirmed == true) {
                                            await widget.onRestoreAllTrash();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.restore_rounded,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Restore All',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: p.text2,
                                          side: BorderSide(color: p.border),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () async {
                                          final confirmed =
                                              await showGeneralDialog<bool>(
                                                context: context,
                                                barrierColor: Colors.black
                                                    .withValues(alpha: 0.42),
                                                barrierDismissible: true,
                                                barrierLabel:
                                                    'Close empty confirmation',
                                                transitionDuration:
                                                    const Duration(
                                                      milliseconds: 120,
                                                    ),
                                                pageBuilder: (_, _, _) =>
                                                    ActionConfirmSheet(
                                                      p: p,
                                                      title: 'Empty Trash?',
                                                      message:
                                                          'Permanently delete all trash? This cannot be undone.',
                                                      confirmLabel: 'Empty',
                                                      isDestructive: true,
                                                      icon: Icons
                                                          .delete_forever_rounded,
                                                    ),
                                              );
                                          if (confirmed == true) {
                                            await widget.onClearTrash();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete_forever_rounded,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Empty Trash',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ...() {
                            if (_trash.isEmpty) {
                              return [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: HIGEmptyState(
                                    p: p,
                                    icon: Icons.delete_outline_rounded,
                                    title: 'Trash is Empty',
                                    message:
                                        'Deleted moments will appear here for 30 days.',
                                  ),
                                ),
                              ];
                            }

                            return [
                              SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final moment = _trash[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: p.surface2,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: p.border.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: momentColor(
                                                p,
                                                moment.type,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Icon(
                                              momentIcon(moment.type),
                                              color: momentColor(
                                                p,
                                                moment.type,
                                              ),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      timeOnly(
                                                        moment.timestamp,
                                                      ),
                                                      style: TextStyle(
                                                        color: p.text,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      moment.date,
                                                      style: TextStyle(
                                                        color: p.text3,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (moment.note.isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    moment.note,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: p.text2,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.restore_rounded,
                                              color: p.text2,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              await widget.onRestoreTrashMoment(
                                                moment.id,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_forever_rounded,
                                              color: p.text2,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              final confirmed = await showGeneralDialog<bool>(
                                                context: context,
                                                barrierColor: Colors.black
                                                    .withValues(alpha: 0.42),
                                                barrierDismissible: true,
                                                barrierLabel:
                                                    'Close delete confirmation',
                                                transitionDuration:
                                                    const Duration(
                                                      milliseconds: 120,
                                                    ),
                                                pageBuilder: (_, _, _) =>
                                                    ActionConfirmSheet(
                                                      p: p,
                                                      title:
                                                          'Delete Permanently?',
                                                      message:
                                                          'This moment will be erased forever.',
                                                      confirmLabel: 'Delete',
                                                      isDestructive: true,
                                                      icon: Icons
                                                          .delete_forever_rounded,
                                                    ),
                                              );
                                              if (confirmed == true) {
                                                await widget
                                                    .onDeleteTrashPermanent(
                                                      moment.id,
                                                    );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }, childCount: _trash.length),
                              ),
                            ];
                          }(),
                          const SliverPadding(
                            padding: EdgeInsets.only(bottom: 48),
                          ),
                        ],
                        if (show('Changelog'))
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: spacing8),
                                ChangelogSettingsPage(p: p, latestOnly: false),
                                const SizedBox(height: spacing48),
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

  Widget _buildDashboardSectionHeader(Palette p, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 16, bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: p.accent, size: 15),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: p.text3,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  void _showSecurityDetailsSheet(BuildContext context, Palette p) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Security Info',
      pageBuilder: (context, _, _) => AppSheet(
        p: p,
        title: 'Security & Integrity'.localized(context),
        docked: true,
        blur:
            !reduceMotion &&
            enableTranslucency &&
            AdaptiveEngine().supportsBlur,
        child: SizedBox(
          width: 410,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: p.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.gpp_good_rounded,
                      color: p.green,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Is NoteKar Safe to Use?'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'NoteKar is built with maximum user safety, open-source integrity, and dynamic cryptosecurity checks:'
                      .localized(context),
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoDetailRow(
                  p: p,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Zero Malware & Detections',
                  text:
                      'NoteKar is audited and verified clean (0/60+ engine detections) by VirusTotal security scanners on every release compilation.',
                ),
                const SizedBox(height: 12),
                _buildInfoDetailRow(
                  p: p,
                  icon: Icons.lock_outline_rounded,
                  title: 'Hardware-Backed Encryption',
                  text:
                      'Databases are sealed with 256-bit AES cryptographic keys generated inside the hardware secure Android Keystore.',
                ),
                const SizedBox(height: 12),
                _buildInfoDetailRow(
                  p: p,
                  icon: Icons.code_rounded,
                  title: 'Auditable Open-Source Code',
                  text:
                      'Every line of code is hosted publicly on GitHub. You can audit, review, compile, or fork the app independently.',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text('Close'.localized(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyDetailsSheet(BuildContext context, Palette p) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Privacy Info',
      pageBuilder: (context, _, _) => AppSheet(
        p: p,
        title: 'Privacy & Offline Model'.localized(context),
        docked: true,
        blur:
            !reduceMotion &&
            enableTranslucency &&
            AdaptiveEngine().supportsBlur,
        child: SizedBox(
          width: 410,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.shield_rounded,
                      color: p.accent,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Is NoteKar Private?'.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Privacy is not a setting; it is our architecture. NoteKar is designed to operate with zero server connections:'
                      .localized(context),
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoDetailRow(
                  p: p,
                  icon: Icons.cloud_off_rounded,
                  title: '100% Offline Database',
                  text:
                      'Your check-ins, habits, and notes are saved directly to local storage. There is no cloud sync, meaning your records never leave this device.',
                ),
                const SizedBox(height: 12),
                _buildInfoDetailRow(
                  p: p,
                  icon: Icons.track_changes_rounded,
                  title: 'No Trackers or Analytics',
                  text:
                      'NoteKar contains zero telemetry, tracking SDKs, or commercial analytics. We do not inspect your usage habits or profiling details.',
                ),
                const SizedBox(height: 12),
                _buildInfoDetailRow(
                  p: p,
                  icon: Icons.key_rounded,
                  title: 'Local Control & Decryption',
                  text:
                      'You have complete command of your data. You can inspect logs, clean databases, export backups, or wipe all records instantly.',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text('Close'.localized(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoDetailRow({
    required Palette p,
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: p.accent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text.localized(context),
                style: TextStyle(color: p.text2, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
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
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
