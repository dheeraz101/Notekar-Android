import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/changelog_dialog.dart';
import 'package:notekar/dialogs/feature_conflict_dialog.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/dialogs/official_bulletins_sheet.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/dialogs/settings/activity_tags_settings_page.dart';
import 'package:notekar/dialogs/settings/advanced_settings_page.dart';
import 'package:notekar/dialogs/settings/app_icons_settings_page.dart';
import 'package:notekar/dialogs/settings/app_lock_settings_page.dart';
import 'package:notekar/dialogs/settings/app_philosophy_settings_page.dart';
import 'package:notekar/dialogs/settings/capture_settings_page.dart';
import 'package:notekar/dialogs/settings/commits_settings_page.dart';
import 'package:notekar/dialogs/settings/data_backup_settings_page.dart';
import 'package:notekar/dialogs/settings/diagnostics_settings_page.dart';
import 'package:notekar/dialogs/settings/display_settings_page.dart';
import 'package:notekar/dialogs/settings/feedback_changelog_settings_page.dart';
import 'package:notekar/dialogs/settings/goals_settings_page.dart';
import 'package:notekar/dialogs/settings/god_mode_settings_page.dart';
import 'package:notekar/dialogs/settings/help_guides_settings_page.dart';
import 'package:notekar/dialogs/settings/integrations_settings_page.dart';
import 'package:notekar/dialogs/settings/legal_about_settings_page.dart';
import 'package:notekar/dialogs/settings/life_audit_page.dart';
import 'package:notekar/dialogs/settings/logging_settings_page.dart';
import 'package:notekar/dialogs/settings/modes_categories_settings_page.dart';
import 'package:notekar/dialogs/settings/moments_settings_page.dart';
import 'package:notekar/dialogs/settings/personal_profile_settings_page.dart';
import 'package:notekar/dialogs/settings/personalization_settings_page.dart';
import 'package:notekar/dialogs/settings/privacy_security_settings_page.dart';
import 'package:notekar/dialogs/settings/reminders_settings_page.dart';
import 'package:notekar/dialogs/settings/search_notes_settings_page.dart';
import 'package:notekar/dialogs/settings/security_privacy_details_sheets.dart';
import 'package:notekar/dialogs/settings/settings_dashboard_page.dart';
import 'package:notekar/dialogs/settings/sobriety_companion_settings_page.dart';
import 'package:notekar/dialogs/settings/time_reflection_settings_page.dart';
import 'package:notekar/dialogs/settings/trash_bin_settings_page.dart';
import 'package:notekar/dialogs/settings/upcoming_features_settings_page.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/dialogs/time_reflection_sheet.dart';
import 'package:notekar/dialogs/timeline_filter_sheet.dart';
import 'package:notekar/models/app_notice.dart';
import 'package:notekar/models/help_guide_data.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/calendar_sync_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/markdown_sync_service.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/utils/network_logger.dart';
import 'package:notekar/utils/notice_service.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/utils/update_service.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/guide_help_rows.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings/settings_dialog_search.dart';

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

    required this.confirmDelete,
    required this.showSeconds,
    required this.highlightSeconds,
    this.use24Hour = true,
    this.clockFont = 'BebasNeue',
    this.onClockFontChanged,
    required this.buttonLabels,
    required this.largeControls,
    required this.homeMenuPill,
    required this.homeMenuAnimations,
    required this.showHistoryText,
    required this.showLastSavedHint,
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

    required this.onConfirmDelete,
    required this.onShowSeconds,
    required this.onHighlightSeconds,
    this.onUse24Hour,
    required this.onButtonLabels,
    required this.onLargeControls,
    required this.onHomeMenuPill,
    required this.onHomeMenuAnimations,
    required this.onShowHistoryText,
    required this.onShowLastSavedHint,
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
    this.onTriggerUrlScheme,
    this.onAdaptiveColorChanged,
    this.soundEffects = true,
    this.onSoundEffects,
    this.activeCategory,
    this.isSessionRunning = false,
    this.floatingTimerEnabled = false,
    this.onFloatingTimerChanged,
  });

  final bool floatingTimerEnabled;
  final ValueChanged<bool>? onFloatingTimerChanged;
  final String? activeCategory;
  final bool isSessionRunning;
  final bool soundEffects;
  final ValueChanged<bool>? onSoundEffects;
  final ValueChanged<bool>? onAdaptiveColorChanged;
  final ValueChanged<String>? onTriggerUrlScheme;
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

  final bool confirmDelete;
  final bool showSeconds;
  final bool highlightSeconds;
  final bool use24Hour;
  final bool buttonLabels;
  final bool largeControls;
  final bool homeMenuPill;
  final bool homeMenuAnimations;
  final bool showHistoryText;
  final bool showLastSavedHint;
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

  final ValueChanged<bool> onConfirmDelete;
  final ValueChanged<bool> onShowSeconds;
  final ValueChanged<bool> onHighlightSeconds;
  final ValueChanged<bool>? onUse24Hour;
  final String clockFont;
  final ValueChanged<String>? onClockFontChanged;
  final ValueChanged<bool> onButtonLabels;
  final ValueChanged<bool> onLargeControls;
  final ValueChanged<bool> onHomeMenuPill;
  final Future<bool> Function(bool) onHomeMenuAnimations;
  final ValueChanged<bool> onShowHistoryText;
  final ValueChanged<bool> onShowLastSavedHint;
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

  void update(VoidCallback fn) => setState(fn);

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

  late bool confirmDelete;
  late bool showSeconds;
  late bool highlightSeconds;
  late bool use24Hour;
  late String clockFont;
  late bool buttonLabels;
  late bool largeControls;
  late bool homeMenuPill;
  late bool homeMenuAnimations;
  late bool showHistoryText;
  late bool showLastSavedHint;
  late bool extendedDuration;
  late bool minimalMomentOptions;
  late bool useNumbersInSingle;
  late bool resetSingleDaily;
  late bool countOnSave;
  late bool enableTranslucency;
  late int privacyLockDelayMinutes;
  late String privacyLockType;
  late String currentLocale;
  late bool soundEffects;
  bool _rainbowCards = false;
  TimelineFilterCriteria _searchNotesFilterCriteria =
      const TimelineFilterCriteria();
  final List<Moment> _searchNotesSelectedMoments = [];
  List<NetworkLogEntry> _networkLogs = [];
  bool _loadingNetworkLogs = false;
  AppNotice? _criticalNotice;

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
  TimeOfDay _reflectionStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _reflectionEndTime = const TimeOfDay(hour: 22, minute: 0);
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
  String _reflectionReminderBody = '';
  bool _hasExactAlarmPermission = true;
  bool _ignoresBatteryOptimizations = true;

  static const _fileChannel = MethodChannel('notekar/files');
  final _logger = AppLogger();

  SharedPreferences? _prefs;

  bool _betaTrack = false;
  bool _autoDeleteUpdateCache = false;
  bool obfuscateInRecents = false;
  bool showPersistentNotification = false;
  String notifLogAction = 'popup';
  bool enableNoteOnClick = false;
  bool enableSobrietyMode = false;
  String sobrietyResetType = 'any';
  int? sobrietyCustomStartMs;
  String sobrietyMilestoneTheme = 'science';
  double _timeAuditSleepHours = 10.0;
  double _timeAuditEssentialsHours = 4.0;

  String _vtRatio = '0 / 60+ clean';
  String _vtStatus = 'Undetected';
  String _vtScanDate = 'July 2026';
  String _vtUrl =
      'https://www.virustotal.com/gui/file/a95a703eaf519bd0ddf1ab7839dab7a90a02150e7808882c3247cb35465a2bfe';
  String _currentBuildChannel = '';

  Future<void> _loadCriticalNotice() async {
    if (!remoteNotices) return;
    try {
      var notice = await NoticeService.instance.getActiveCriticalAdvisory();
      if (mounted && notice != null) {
        setState(() {
          _criticalNotice = notice;
        });
      }
      // Silently check for fresh bulletins if stale (> 4 hours)
      await NoticeService.instance.syncIfStale();
      notice = await NoticeService.instance.getActiveCriticalAdvisory();
      if (mounted) {
        setState(() {
          _criticalNotice = notice;
        });
      }
    } catch (_) {}
  }

  Widget _buildCriticalAdvisoryBanner(Palette p) {
    if (!remoteNotices || _criticalNotice == null) {
      return const SizedBox.shrink();
    }
    final notice = _criticalNotice!;

    return Padding(
      padding: const EdgeInsets.only(bottom: spacing12),
      child: PressableScale(
        onTap: () {
          OfficialBulletinsSheet.show(
            context,
            p: p,
            onOpenLink: widget.onOpenLink,
            onLearnMoreBeta: () => _showBetaInfoPopup(p),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: p.red.withValues(alpha: 0.35), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: p.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'CRITICAL ADVISORY'.localized(context),
                          style: TextStyle(
                            color: p.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            await NoticeService.instance.dismissNotice(
                              notice.id,
                            );
                            if (mounted) {
                              setState(() => _criticalNotice = null);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 16,
                              color: p.text3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: spacing4),
                    Text(
                      notice.localizedTitle(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notice.localizedBody(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 13,
                        height: 1.3,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleIdProfileCard(Palette p) {
    return AnimatedBuilder(
      animation: UserProfileService(),
      builder: (context, _) {
        final profile = UserProfileService();
        final horizon = profile.calculateLifeHorizon();
        final hasName = profile.name.trim().isNotEmpty;
        final displayName = hasName
            ? profile.name.trim()
            : 'Your Identity'.localized(context);

        String subtitle;
        if (horizon.hasDob) {
          final weeksStr = horizon.remainingWeeks.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
          subtitle =
              'Age ${horizon.ageYears} • ${horizon.targetYears}y Horizon • $weeksStr wks left';
        } else {
          subtitle = 'Set up your profile, age & life horizon'.localized(
            context,
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: spacing12),
          child: PressableScale(
            onTap: () {
              NotekarHaptics.selection('standard');
              _openCategory('Personal Profile');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: p.border.withValues(alpha: 0.5),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  profile.buildAvatarWidget(p: p, size: 54),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.text3,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.chevron_forward,
                    color: p.text3.withValues(alpha: 0.6),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadRemindersSettings() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs?.getBool('god_mode_unlocked') == null && _isGodModeUnlocked) {
      unawaited(_prefs?.setBool('god_mode_unlocked', true));
    }
    setState(() {
      _betaTrack = _prefs?.getBool('m-update-track-beta') ?? false;
      _autoDeleteUpdateCache =
          _prefs?.getBool('auto_delete_update_cache') ?? false;
      obfuscateInRecents = _prefs?.getBool('obfuscate_in_recents') ?? false;
      showPersistentNotification =
          _prefs?.getBool('show_persistent_notification') ?? false;
      notifLogAction = _prefs?.getString('notif_log_action') ?? 'popup';
      enableNoteOnClick = _prefs?.getBool('enable_note_on_click') ?? false;
      enableSobrietyMode = _prefs?.getBool('enable_sobriety_mode') ?? false;
      sobrietyResetType = _prefs?.getString('sobriety_reset_type') ?? 'any';
      sobrietyCustomStartMs = _prefs?.getInt('sobriety_custom_start_ms');
      sobrietyMilestoneTheme =
          _prefs?.getString('sobriety_milestone_theme') ?? 'science';
      _timeAuditSleepHours =
          _prefs?.getDouble('time_audit_sleep_hours') ?? 10.0;
      _timeAuditEssentialsHours =
          _prefs?.getDouble('time_audit_essentials_hours') ?? 4.0;
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
      _reflectionReminderBody =
          _prefs?.getString('reminder_reflection_body') ?? '';
      _reflectionStartTime = TimeOfDay(
        hour: _prefs?.getInt('reminder_reflection_start_hour') ?? 9,
        minute: _prefs?.getInt('reminder_reflection_start_minute') ?? 0,
      );
      _reflectionEndTime = TimeOfDay(
        hour: _prefs?.getInt('reminder_reflection_end_hour') ?? 22,
        minute: _prefs?.getInt('reminder_reflection_end_minute') ?? 0,
      );

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
            'startHour': _reflectionStartTime.hour,
            'startMinute': _reflectionStartTime.minute,
            'endHour': _reflectionEndTime.hour,
            'endMinute': _reflectionEndTime.minute,
            'title': 'Mindfulness'.localized(context),
            'body': _reflectionReminderBody.trim().isNotEmpty
                ? _reflectionReminderBody.trim()
                : 'Pause. Breathe. Be present in this moment.'.localized(
                    context,
                  ),
          });
        } else {
          await _fileChannel.invokeMethod('cancelReminder', {
            'id': 'reminder_reflection',
          });
          await _fileChannel.invokeMethod('cancelReminder', {
            'id': 'reminder_reflection_test',
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
                        brightness: p.name == 'light'
                            ? Brightness.light
                            : Brightness.dark,
                        primaryColor: p.accent,
                        textTheme: CupertinoTextThemeData(
                          textStyle: TextStyle(
                            color: p.text,
                            decoration: TextDecoration.none,
                          ),
                          dateTimePickerTextStyle: TextStyle(
                            color: p.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
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
                        brightness: p.name == 'light'
                            ? Brightness.light
                            : Brightness.dark,
                        primaryColor: p.accent,
                        textTheme: CupertinoTextThemeData(
                          textStyle: TextStyle(
                            color: p.text,
                            decoration: TextDecoration.none,
                          ),
                          dateTimePickerTextStyle: TextStyle(
                            color: p.text,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
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

  bool get _isGodModeUnlocked {
    final pref = _prefs?.getBool('god_mode_unlocked');
    if (pref != null) return pref;
    return entries.any(
      (e) =>
          e.note.toLowerCase().contains('god mode unlocked') ||
          e.note.toLowerCase().contains('#godmode'),
    );
  }

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

    confirmDelete = widget.confirmDelete;
    showSeconds = widget.showSeconds;
    highlightSeconds = widget.highlightSeconds;
    use24Hour = widget.use24Hour;
    clockFont = widget.clockFont;
    buttonLabels = widget.buttonLabels;
    largeControls = widget.largeControls;
    homeMenuPill = widget.homeMenuPill;
    homeMenuAnimations = widget.homeMenuAnimations;
    showHistoryText = widget.showHistoryText;
    showLastSavedHint = widget.showLastSavedHint;
    extendedDuration = widget.extendedDuration;
    minimalMomentOptions = widget.minimalMomentOptions;
    useNumbersInSingle = widget.useNumbersInSingle;
    resetSingleDaily = widget.resetSingleDaily;
    countOnSave = widget.countOnSave;
    enableTranslucency = widget.enableTranslucency;
    privacyLockDelayMinutes = widget.privacyLockDelayMinutes;
    privacyLockType = widget.privacyLockType;
    currentLocale = widget.currentLocale;
    soundEffects = widget.soundEffects;
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() {
          _rainbowCards = prefs.getBool('m-rainbow-cards') ?? false;
        });
      }
    });

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
    _loadCriticalNotice();

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
        icon: CupertinoIcons.wifi_slash,
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

  Future<void> _handleAutoDeleteUpdateCache(bool value, Palette p) async {
    setState(() => _autoDeleteUpdateCache = value);
    await _prefs?.setBool('auto_delete_update_cache', value);
    if (value) {
      final deleted = await UpdateService().clearCachedBuilds();
      if (!mounted) return;
      showIosPillToast(
        context: context,
        p: p,
        message: deleted > 0
            ? 'Update cache cleared ($deleted files)'.localized(context)
            : 'Update cache cleared'.localized(context),
        icon: CupertinoIcons.sparkles,
      );
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

  void _toggleSelectSearchNoteMoment(Moment entry, Palette p) {
    if (_searchNotesSelectedMoments.any((m) => m.id == entry.id)) {
      setState(() {
        _searchNotesSelectedMoments.removeWhere((m) => m.id == entry.id);
      });
    } else if (_searchNotesSelectedMoments.isEmpty) {
      setState(() {
        _searchNotesSelectedMoments.add(entry);
      });
    } else {
      final first = _searchNotesSelectedMoments.first;
      setState(() {
        _searchNotesSelectedMoments.clear();
      });
      showTimeDifferenceDialog(
        context,
        p: p,
        a: first,
        b: entry,
        largeText: largeText,
        blur: enableTranslucency,
      );
    }
  }

  Future<void> _editNoteInSearch(Moment moment) async {
    HapticFeedback.lightImpact();
    final p = paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );
    final result = await showGeneralDialog<NoteResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close note editor',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => NoteDialog(
        p: p,
        initialNote: moment.note,
        title: 'Edit Note'.localized(context),
        saveLabel: 'Save'.localized(context),
        allowEmpty: false,
      ),
    );
    if (result == null || !mounted) return;

    final repo = MomentRepository();
    await repo.ensureInitialized();
    final updatedTags = result.tags.isNotEmpty
        ? result.tags
        : NoteTagExtractor.extractHashtags(
            result.note,
          ).map((t) => t.replaceFirst('#', '').toLowerCase()).toList();
    final updatedMoment = moment.copyWith(
      note: result.note.trim(),
      tags: updatedTags,
    );
    await repo.saveMoment(updatedMoment);

    final current = List<Moment>.from(widget.entriesNotifier.value);
    final idx = current.indexWhere((m) => m.id == moment.id);
    if (idx >= 0) {
      current[idx] = updatedMoment;
      widget.entriesNotifier.value = current;
    }
    if (mounted) {
      showIosPillToast(
        context: context,
        p: p,
        message: 'Note updated'.localized(context),
        icon: CupertinoIcons.checkmark_circle_fill,
      );
    }
  }

  void _openCategory(String name, {String? parent}) {
    if (name == 'God Mode' && !_isGodModeUnlocked) {
      return;
    }
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
    NotekarHaptics.selection(hapticStyle);
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

  Future<void> _exportMarkdown() async {
    HapticFeedback.mediumImpact();
    final moments = widget.entriesNotifier.value;
    final exportOp = const MarkdownSyncService().exportMarkdownFile(moments);
    final delayOp = Future.delayed(const Duration(milliseconds: 1000));
    final results = await Future.wait([exportOp, delayOp]);
    final savedFileName = results[0];
    if (mounted) {
      if (savedFileName != null) {
        showIosPillToast(
          context: context,
          p: widget.p,
          message: 'Saved to Downloads/$savedFileName'.localized(context),
          icon: CupertinoIcons.checkmark_circle_fill,
        );
      } else {
        showIosPillToast(
          context: context,
          p: widget.p,
          message: 'Failed to export Markdown journal.'.localized(context),
          icon: CupertinoIcons.exclamationmark_circle,
        );
      }
    }
  }

  Future<void> _exportCalendar() async {
    HapticFeedback.mediumImpact();
    final moments = widget.entriesNotifier.value;
    final exportOp = const CalendarSyncService().exportCalendarFile(moments);
    final delayOp = Future.delayed(const Duration(milliseconds: 1000));
    final results = await Future.wait([exportOp, delayOp]);
    final savedFileName = results[0];
    if (mounted) {
      if (savedFileName != null) {
        showIosPillToast(
          context: context,
          p: widget.p,
          message: 'Saved to Downloads/$savedFileName'.localized(context),
          icon: CupertinoIcons.checkmark_circle_fill,
        );
      } else {
        showIosPillToast(
          context: context,
          p: widget.p,
          message: 'Failed to export Calendar sessions.'.localized(context),
          icon: CupertinoIcons.exclamationmark_circle,
        );
      }
    }
  }

  void _showBetaInfoPopup(Palette p) {
    showBetaInfoPopup(context, p, onFeedback: _openFeedback);
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
    final cupertinoThemeData = CupertinoThemeData(
      brightness: p.name == 'light' ? Brightness.light : Brightness.dark,
      primaryColor: p.accent,
    );

    if (confirmLabel != null && onConfirm != null) {
      return showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoTheme(
          data: cupertinoThemeData,
          child: CupertinoAlertDialog(
            title: Text(title.localized(ctx)),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(message.localized(ctx)),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  NotekarHaptics.selection('standard');
                  Navigator.pop(ctx);
                },
                child: Text(cancelLabel.localized(ctx)),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  NotekarHaptics.selection('standard');
                  Navigator.pop(ctx);
                  onConfirm();
                },
                child: Text(confirmLabel.localized(ctx)),
              ),
            ],
          ),
        ),
      );
    }

    return showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoTheme(
        data: cupertinoThemeData,
        child: CupertinoAlertDialog(
          title: Text(title.localized(ctx)),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(message.localized(ctx)),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                NotekarHaptics.selection('standard');
                Navigator.pop(ctx);
              },
              child: Text(cancelLabel.localized(ctx)),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorReporterDialog(dynamic error, dynamic stackTrace) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
        icon: CupertinoIcons.exclamationmark_circle,
        iconColor: p.red,
        confirmLabel: 'Report',
        cancelLabel: 'Cancel',
        onConfirm: () {
          _submitAutoCrashReport(error, stackTrace, p);
        },
      );
    });
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
        title: category?.startsWith('Mode: ') == true
            ? category!.substring(6)
            : category == 'Reminder Message'
            ? (_editingReminderType == 'daily'
                  ? 'Daily Reminder Message'.localized(context)
                  : (_editingReminderType == 'weekly'
                        ? 'Weekly Reminder Message'.localized(context)
                        : 'Monthly Reminder Message'.localized(context)))
            : category == 'Integrations & Automation'
            ? 'Automation'.localized(context)
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
                              if (_criticalNotice != null)
                                _buildCriticalAdvisoryBanner(p),
                              _buildAppleIdProfileCard(p),

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
                                    status: defaultModeLabel(defaultMode),
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
                                  if (_isGodModeUnlocked)
                                    SettingsRow(
                                      p: p,
                                      icon: CupertinoIcons.sparkles,
                                      title: 'God Mode',
                                      status: 'Unlocked',
                                      color: const Color(0xFFFFD700),
                                      onTap: () => _openCategory('God Mode'),
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
                                    icon: CupertinoIcons.gift,
                                    title: 'Buy Me a Coffee',
                                    color: const Color(0xFFFFDD00),
                                    rowKind: 'link',
                                    onTap: () => widget.onOpenLink(coffeeLink),
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon:
                                        CupertinoIcons.bubble_left_bubble_right,
                                    title: 'Feedback',
                                    color: p.green,
                                    rowKind: 'popup',
                                    onTap: _openFeedback,
                                  ),
                                  SettingsRow(
                                    p: p,
                                    icon: CupertinoIcons.mail,
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
                                            CupertinoIcons
                                                .arrow_2_circlepath_circle_fill,
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
                                          CupertinoIcons.chevron_forward,
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
                        if (show('Search')) ..._buildSearchSlivers(p),
                        if (show('Personal Profile'))
                          SliverToBoxAdapter(
                            child: PersonalProfileSettingsPage(
                              p: p,
                              onSaved: () => setState(() {}),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
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
                              use24HourFormat: use24Hour,
                              clockFont: clockFont,
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
                              onUse24HourFormatChanged: (val) {
                                setState(() => use24Hour = val);
                                widget.onUse24Hour?.call(val);
                              },
                              onClockFontChanged: (val) {
                                setState(() => clockFont = val);
                                widget.onClockFontChanged?.call(val);
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
                              godModeUnlocked: _isGodModeUnlocked,
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
                              notifLogAction: notifLogAction,
                              onNotifLogActionChanged: (val) async {
                                final mode = val ? 'popup' : 'silent';
                                setState(() => notifLogAction = mode);
                                await _prefs?.setString(
                                  'notif_log_action',
                                  mode,
                                );
                              },
                              showTrashBin: widget.onOpenTrash != null,
                              trash: _trash,
                              rainbowCards: _rainbowCards,
                              onRainbowCardsChanged: (val) async {
                                setState(() => _rainbowCards = val);
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('m-rainbow-cards', val);
                              },
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
                              onOpenLifeAudit: () => _openCategory(
                                'Life Audit',
                                parent: 'Dashboard',
                              ),
                              onOpenGoals: () => _openCategory(
                                'Targets & Goals',
                                parent: 'Dashboard',
                              ),
                            ),
                          ),
                        if (show('Targets & Goals') || show('Goals'))
                          SliverToBoxAdapter(
                            child: GoalsSettingsPage(
                              p: p,
                              moments: entries,
                              activeCategory: widget.activeCategory,
                              isSessionRunning: widget.isSessionRunning,
                            ),
                          ),
                        if (show('Life Audit'))
                          SliverToBoxAdapter(
                            child: LifeAuditPage(
                              p: p,
                              entries: entries,
                              sleepHours: _timeAuditSleepHours,
                              essentialsHours: _timeAuditEssentialsHours,
                              onOpenPersonalProfile: () =>
                                  _openCategory('Personal Profile'),
                              onSleepHoursChanged: (val) async {
                                setState(() => _timeAuditSleepHours = val);
                                await _prefs?.setDouble(
                                  'time_audit_sleep_hours',
                                  val,
                                );
                              },
                              onEssentialsHoursChanged: (val) async {
                                setState(() => _timeAuditEssentialsHours = val);
                                await _prefs?.setDouble(
                                  'time_audit_essentials_hours',
                                  val,
                                );
                              },
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Capture'))
                          SliverToBoxAdapter(
                            child: CaptureSettingsPage(
                              p: p,
                              defaultMode: defaultMode,
                              tapDelay: tapDelay,
                              enableNoteOnClick: enableNoteOnClick,
                              onDefaultModeChanged: (value) {
                                setState(() => defaultMode = value);
                                widget.onDefaultMode(value);
                              },
                              onTapDelayChanged: (value) {
                                setState(() => tapDelay = value);
                                widget.onDelay(value);
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
                                    showIosPillToast(
                                      context: context,
                                      p: p,
                                      message: 'Notification permission needed'
                                          .localized(context),
                                      icon: CupertinoIcons.bell_slash,
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
                                    showIosPillToast(
                                      context: context,
                                      p: p,
                                      message: 'Notification permission needed'
                                          .localized(context),
                                      icon: CupertinoIcons.bell_slash,
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
                                    showIosPillToast(
                                      context: context,
                                      p: p,
                                      message: 'Notification permission needed'
                                          .localized(context),
                                      icon: CupertinoIcons.bell_slash,
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
                                    showIosPillToast(
                                      context: context,
                                      p: p,
                                      message: 'Notification permission needed'
                                          .localized(context),
                                      icon: CupertinoIcons.bell_slash,
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
                              reflectionReminderMessage:
                                  _reflectionReminderBody,
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
                                    showIosPillToast(
                                      context: context,
                                      p: p,
                                      message: 'Notification permission needed'
                                          .localized(context),
                                      icon: CupertinoIcons.bell_slash,
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
                              onUpdateReflectionMessage: (value) async {
                                setState(() => _reflectionReminderBody = value);
                                await _prefs?.setString(
                                  'reminder_reflection_body',
                                  value,
                                );
                                if (_reflectionReminderEnabled) {
                                  await _syncReminder('reflection');
                                }
                              },
                              reflectionStartTime: _reflectionStartTime,
                              reflectionEndTime: _reflectionEndTime,
                              onTapStartTime: () async {
                                HapticFeedback.selectionClick();
                                final time = await _showIOSTimePicker(
                                  context,
                                  _reflectionStartTime,
                                );
                                if (time != null) {
                                  setState(() => _reflectionStartTime = time);
                                  await _prefs?.setInt(
                                    'reminder_reflection_start_hour',
                                    time.hour,
                                  );
                                  await _prefs?.setInt(
                                    'reminder_reflection_start_minute',
                                    time.minute,
                                  );
                                  if (_reflectionReminderEnabled) {
                                    await _syncReminder('reflection');
                                  }
                                }
                              },
                              onTapEndTime: () async {
                                HapticFeedback.selectionClick();
                                final time = await _showIOSTimePicker(
                                  context,
                                  _reflectionEndTime,
                                );
                                if (time != null) {
                                  setState(() => _reflectionEndTime = time);
                                  await _prefs?.setInt(
                                    'reminder_reflection_end_hour',
                                    time.hour,
                                  );
                                  await _prefs?.setInt(
                                    'reminder_reflection_end_minute',
                                    time.minute,
                                  );
                                  if (_reflectionReminderEnabled) {
                                    await _syncReminder('reflection');
                                  }
                                }
                              },
                              onPreviewReflectionSheet: () async {
                                HapticFeedback.heavyImpact();
                                if (!context.mounted) return;
                                showIosPillToast(
                                  context: context,
                                  p: p,
                                  message:
                                      'Test alarm scheduled in 3 seconds! Lock phone or exit app.'
                                          .localized(context),
                                  icon: CupertinoIcons.alarm,
                                  duration: const Duration(seconds: 3),
                                );
                                try {
                                  await _fileChannel.invokeMethod<
                                    void
                                  >('scheduleReminder', {
                                    'id': 'reminder_reflection_test',
                                    'type': 'reflection',
                                    'delaySeconds': 3,
                                    'intervalMinutes': 0,
                                    'title': 'Mindfulness',
                                    'body':
                                        _reflectionReminderBody
                                            .trim()
                                            .isNotEmpty
                                        ? _reflectionReminderBody.trim()
                                        : 'Pause. Breathe. Be present in this moment.',
                                  });
                                } catch (_) {}
                                await Future<void>.delayed(
                                  const Duration(seconds: 3),
                                );
                                if (context.mounted) {
                                  TimeReflectionSheet.show(
                                    context,
                                    p: p,
                                    intervalMinutes:
                                        _reflectionReminderIntervalMins,
                                    customMessage: _reflectionReminderBody,
                                  );
                                }
                              },
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Moments'))
                          SliverToBoxAdapter(
                            child: MomentsSettingsPage(
                              p: p,
                              showTrashBin: widget.onOpenTrash != null,
                              trash: _trash,

                              confirmDelete: confirmDelete,
                              extendedDuration: extendedDuration,
                              minimalMomentOptions: minimalMomentOptions,
                              useNumbersInSingle: useNumbersInSingle,
                              resetSingleDaily: resetSingleDaily,
                              countOnSave: countOnSave,
                              notesCount: entries
                                  .where((e) => e.note.isNotEmpty)
                                  .length,

                              onHistoryDensityChanged: (value) {
                                setState(() => historyDensity = value);
                                widget.onHistoryDensity(value);
                              },
                              onConfirmDeleteChanged: (value) {
                                setState(() => confirmDelete = value);
                                widget.onConfirmDelete(value);
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
                        if (show('Sobriety Companion') || show('Sobriety'))
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
                        if (show('Modes') || show('Modes & Categories'))
                          SliverToBoxAdapter(
                            child: ModesCategoriesSettingsPage(
                              p: p,
                              entries: entries,
                              onOpenCategory: (cat, {parent}) =>
                                  _openCategory(cat, parent: parent),
                              onCategoriesChanged: () {
                                setState(() {});
                              },
                              onAdaptiveColorChanged:
                                  widget.onAdaptiveColorChanged,
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Activity Tags') ||
                            show('Tags') ||
                            show('Quick Tags'))
                          SliverToBoxAdapter(
                            child: ActivityTagsSettingsPage(
                              p: p,
                              onTagsChanged: () => setState(() {}),
                            ),
                          ),
                        if (category != null && category!.startsWith('Mode: '))
                          SliverToBoxAdapter(
                            child: ModeDetailSettingsPage(
                              p: p,
                              category: category!.substring(6),
                              entries: entries,
                              onDelete: () {
                                _popCategory();
                                setState(() {});
                              },
                              onCategoriesChanged: () {
                                setState(() {});
                              },
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
                            historyDensity: historyDensity,

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
                            filterCriteria: _searchNotesFilterCriteria,
                            onFilterCriteriaChanged: (crit) => setState(
                              () => _searchNotesFilterCriteria = crit,
                            ),
                            selectedMoments: _searchNotesSelectedMoments,
                            onToggleSelectMoment: (entry) =>
                                _toggleSelectSearchNoteMoment(entry, p),
                            onClearSelection: () => setState(
                              () => _searchNotesSelectedMoments.clear(),
                            ),
                            rainbowCards: _rainbowCards,
                            onEditNote: _editNoteInSearch,
                          ),
                        if (show('Guides'))
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: spacing8),
                              SettingsGroup(
                                p: p,
                                showDividers: true,
                                children: [
                                  for (final g in allGuideItems)
                                    GuideRow(
                                      p: p,
                                      icon:
                                          g.icon ??
                                          CupertinoIcons.question_circle,
                                      title: g.title,
                                      text: g.content,
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
                                  for (final h in allHelpFaqItems)
                                    HelpRow(
                                      p: p,
                                      question: h.title,
                                      answer: h.content,
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
                                      icon: CupertinoIcons.ant,
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
                                      icon: CupertinoIcons.gauge,
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
                                      icon: CupertinoIcons.wifi,
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
                                      icon: CupertinoIcons.clock_fill,
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
                                if (value) {
                                  _loadCriticalNotice();
                                }
                              },
                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                              onOpenLink: widget.onOpenLink,
                              autoDeleteUpdateCache: _autoDeleteUpdateCache,
                              onAutoDeleteUpdateCacheChanged: (value) =>
                                  _handleAutoDeleteUpdateCache(value, p),
                            ),
                          ),
                        if (show('Official Bulletins'))
                          SliverToBoxAdapter(
                            child: OfficialBulletinsContent(
                              p: p,
                              onOpenLink: widget.onOpenLink,
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                            ),
                          ),
                        if (show('Data & Backup') ||
                            show('Backup & Export') ||
                            show('Backup Status'))
                          SliverToBoxAdapter(
                            child: DataBackupSettingsPage(
                              p: p,
                              subCategory: category ?? 'Data & Backup',
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
                              onExportMarkdown: () => unawaited(
                                _runExport('Markdown', _exportMarkdown),
                              ),
                              onExportCalendar: () => unawaited(
                                _runExport('Calendar', _exportCalendar),
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
                        if (show('App Philosophy'))
                          SliverToBoxAdapter(
                            child: AppPhilosophySettingsPage(
                              p: p,
                              appVersion: appVersion,
                            ),
                          ),
                        if (show('Upcoming Features'))
                          SliverToBoxAdapter(
                            child: UpcomingFeaturesSettingsPage(p: p),
                          ),
                        if (show('Advanced') ||
                            show('Language') ||
                            show('Accessibility') ||
                            show('Reset'))
                          SliverToBoxAdapter(
                            child: AdvancedSettingsPage(
                              p: p,
                              subCategory: category ?? 'Advanced',
                              isGodModeUnlocked: _isGodModeUnlocked,
                              currentLocale: currentLocale,
                              onLocaleChanged: (value) {
                                setState(() => currentLocale = value);
                                widget.onLocaleChanged(value);
                              },
                              onLearnMoreBeta: () => _showBetaInfoPopup(p),
                              hapticStyle: hapticStyle,
                              soundEffects: soundEffects,
                              onSoundEffectsChanged: (value) async {
                                setState(() => soundEffects = value);
                                widget.onSoundEffects?.call(value);
                                AppSound.setEnabled(value);
                                if (value) AppSound.click();
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool(
                                  'm-acoustic-feedback',
                                  value,
                                );
                              },
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
                              onExportCsv: () => unawaited(
                                _runExport('CSV', widget.onExportCsv),
                              ),
                              onExportJson: () => unawaited(
                                _runExport('JSON', widget.onExportJson),
                              ),
                              onExportBackup: () => unawaited(
                                _runExport('Backup', widget.onExportBackup),
                              ),
                              onResetCircuitBreakers: () {
                                widget.onFeedback('All Circuit Breakers Reset');
                              },

                              onOpenCategory: (category, {required parent}) =>
                                  _openCategory(category, parent: parent),
                            ),
                          ),
                        if (show('Diagnostics') ||
                            show('Device Health') ||
                            show('Network Monitor'))
                          SliverToBoxAdapter(
                            child: DiagnosticsSettingsPage(
                              p: p,
                              subCategory: category ?? 'Diagnostics',
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
                        if (show('Privacy Policy') ||
                            show('Terms of Use') ||
                            show('Licenses'))
                          SliverToBoxAdapter(
                            child: LegalAboutSettingsPage(
                              p: p,
                              subCategory: category ?? 'Privacy Policy',
                              appVersion: appVersion,
                              privacyPolicyUrl: privacyPolicyUrl,
                              termsUrl: termsUrl,
                              onOpenLink: widget.onOpenLink,
                            ),
                          ),
                        if (show('Feedback') ||
                            show("What's New") ||
                            show('Changelog'))
                          SliverToBoxAdapter(
                            child: FeedbackChangelogSettingsPage(
                              p: p,
                              subCategory: category ?? 'Feedback',
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

                        if (show('Integrations & Automation'))
                          SliverToBoxAdapter(
                            child: IntegrationsSettingsPage(
                              p: p,
                              entriesNotifier: widget.entriesNotifier,
                              onTriggerUrlScheme: (url) {
                                _popCategory();
                                widget.onTriggerUrlScheme?.call(url);
                              },
                            ),
                          ),
                        if (show('God Mode'))
                          SliverToBoxAdapter(
                            child: GodModeSettingsPage(
                              p: p,
                              currentTheme: theme,
                              onThemeChanged: (val) {
                                setState(() => theme = val);
                                widget.onTheme(val);
                              },
                              totalMoments: entries.length,
                              streakDays: _prefs?.getInt('streak_days') ?? 0,
                              onRelockGodMode: () async {
                                if (_prefs != null) {
                                  await _prefs!.setBool(
                                    'god_mode_unlocked',
                                    false,
                                  );
                                  await _prefs!.setBool(
                                    'god_mode_game_enabled',
                                    false,
                                  );
                                }
                                final godModeEntries = entries
                                    .where(
                                      (e) =>
                                          e.note.toLowerCase().contains(
                                            'god mode unlocked',
                                          ) ||
                                          e.note.toLowerCase().contains(
                                            '#godmode',
                                          ),
                                    )
                                    .toList();
                                if (godModeEntries.isNotEmpty) {
                                  final updated = List<Moment>.from(entries)
                                    ..removeWhere(
                                      (e) =>
                                          e.note.toLowerCase().contains(
                                            'god mode unlocked',
                                          ) ||
                                          e.note.toLowerCase().contains(
                                            '#godmode',
                                          ),
                                    );
                                  widget.entriesNotifier.value = updated;
                                  final repo = MomentRepository();
                                  await repo.ensureInitialized();
                                  for (final gm in godModeEntries) {
                                    await repo.deleteMoment(gm.id);
                                    await repo.permanentlyDeleteTrashMoment(
                                      gm.id,
                                    );
                                  }
                                }
                                if (theme == 'matrix' || theme == 'eink') {
                                  setState(() => theme = 'dark');
                                  widget.onTheme('dark');
                                }
                                setState(() {
                                  category = null;
                                  _categoryStack.clear();
                                });
                                if (context.mounted) {
                                  showIosPillToast(
                                    context: context,
                                    p: p,
                                    message: 'God Mode has been revoked.'
                                        .localized(context),
                                    icon: CupertinoIcons.shield,
                                  );
                                }
                              },
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
