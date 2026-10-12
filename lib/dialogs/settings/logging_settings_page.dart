import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/daily_wrapup_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoggingSettingsPage extends StatefulWidget {
  const LoggingSettingsPage({
    super.key,
    required this.p,
    required this.defaultMode,
    required this.entriesCount,
    this.notesCount = 0,
    required this.remindersStatus,
    required this.enableSobrietyMode,
    required this.showPersistentNotification,
    this.notifLogAction = 'popup',
    this.onNotifLogActionChanged,
    this.showTrashBin = false,
    this.trash = const [],
    this.rainbowCards = false,
    this.onRainbowCardsChanged,
    required this.onShowPersistentNotificationChanged,
    required this.onOpenCategory,
  });

  final Palette p;
  final String defaultMode;
  final int entriesCount;
  final int notesCount;
  final String remindersStatus;
  final bool enableSobrietyMode;
  final bool showPersistentNotification;
  final String notifLogAction;
  final ValueChanged<bool>? onNotifLogActionChanged;
  final bool showTrashBin;
  final List<Moment> trash;
  final bool rainbowCards;
  final ValueChanged<bool>? onRainbowCardsChanged;
  final ValueChanged<bool> onShowPersistentNotificationChanged;
  final void Function(String category, {required String parent}) onOpenCategory;

  @override
  State<LoggingSettingsPage> createState() => _LoggingSettingsPageState();
}

class _LoggingSettingsPageState extends State<LoggingSettingsPage> {
  static const _channel = MethodChannel('notekar/files');

  Palette get p => widget.p;
  String get defaultMode => widget.defaultMode;
  int get entriesCount => widget.entriesCount;
  int get notesCount => widget.notesCount;
  String get remindersStatus => widget.remindersStatus;
  bool get enableSobrietyMode => widget.enableSobrietyMode;
  bool get showPersistentNotification => widget.showPersistentNotification;
  String get notifLogAction => widget.notifLogAction;
  ValueChanged<bool>? get onNotifLogActionChanged =>
      widget.onNotifLogActionChanged;
  bool get showTrashBin => widget.showTrashBin;
  List<Moment> get trash => widget.trash;
  bool get rainbowCards => widget.rainbowCards;
  ValueChanged<bool>? get onRainbowCardsChanged => widget.onRainbowCardsChanged;
  ValueChanged<bool> get onShowPersistentNotificationChanged =>
      widget.onShowPersistentNotificationChanged;
  void Function(String category, {required String parent}) get onOpenCategory =>
      widget.onOpenCategory;

  bool _floatingBubbleEnabled = false;
  String _singleTapAction = 'quick_log';
  String _doubleTapAction = 'quick_menu';
  String _concurrencyMode = 'exclusive';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _floatingBubbleEnabled =
            prefs.getBool('floating_timer_enabled') ?? false;
        _singleTapAction =
            prefs.getString('floating_single_tap_action') ?? 'quick_log';
        _doubleTapAction =
            prefs.getString('floating_double_tap_action') ?? 'quick_menu';
        _concurrencyMode =
            prefs.getString('timer_concurrency_mode') ?? 'exclusive';
      });
    }
  }

  Future<void> _toggleConcurrencyMode() async {
    HapticFeedback.lightImpact();
    final newMode = _concurrencyMode == 'exclusive' ? 'parallel' : 'exclusive';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timer_concurrency_mode', newMode);
    setState(() => _concurrencyMode = newMode);
  }

  Future<void> _toggleFloatingBubble(bool val) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    if (val) {
      final canDraw =
          await _channel.invokeMethod<bool>('canDrawOverlays') ?? false;
      if (!canDraw) {
        await _channel.invokeMethod('requestOverlayPermission');
      } else {
        await _channel.invokeMethod('startFloatingTimer');
      }
    } else {
      await _channel.invokeMethod('stopFloatingTimer');
    }
    await prefs.setBool('floating_timer_enabled', val);
    setState(() => _floatingBubbleEnabled = val);
  }

  Future<void> _showGesturePicker({required bool isSingleTap}) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    final p = widget.p;

    final title = isSingleTap ? 'Single Tap Action' : 'Double Tap Action';
    final subtitle = isSingleTap
        ? 'Choose what happens when tapping the floating bubble'
        : 'Choose what happens when double tapping the floating bubble';

    final actions = isSingleTap
        ? [
            AppleHigActionItem(
              title: 'Quick Log Entry',
              subtitle: 'Haptic instant logging without opening the app',
              icon: CupertinoIcons.bolt_fill,
              color: p.accent,
              isSelected: _singleTapAction == 'quick_log',
              onTap: () async {
                await prefs.setString(
                  'floating_single_tap_action',
                  'quick_log',
                );
                if (mounted) setState(() => _singleTapAction = 'quick_log');
              },
            ),
            AppleHigActionItem(
              title: 'Expand Controls',
              subtitle: 'Reveal pause, resume, note, and stop actions',
              icon: CupertinoIcons.arrow_up_left_arrow_down_right,
              color: p.blue,
              isSelected: _singleTapAction == 'toggle_expand',
              onTap: () async {
                await prefs.setString(
                  'floating_single_tap_action',
                  'toggle_expand',
                );
                if (mounted) setState(() => _singleTapAction = 'toggle_expand');
              },
            ),
          ]
        : [
            AppleHigActionItem(
              title: 'Modes & Activity Menu',
              subtitle: 'Open the floating quick note and mode picker',
              icon: CupertinoIcons.square_grid_2x2,
              color: p.accent,
              isSelected: _doubleTapAction == 'quick_menu',
              onTap: () async {
                await prefs.setString(
                  'floating_double_tap_action',
                  'quick_menu',
                );
                if (mounted) setState(() => _doubleTapAction = 'quick_menu');
              },
            ),
            AppleHigActionItem(
              title: 'Expand / Collapse',
              subtitle: 'Toggle the action toolbar visibility',
              icon: CupertinoIcons.arrow_up_left_arrow_down_right,
              color: p.blue,
              isSelected: _doubleTapAction == 'toggle_expand',
              onTap: () async {
                await prefs.setString(
                  'floating_double_tap_action',
                  'toggle_expand',
                );
                if (mounted) setState(() => _doubleTapAction = 'toggle_expand');
              },
            ),
          ];

    if (!mounted) return;
    await AppleHigActionSheet.show<void>(
      context,
      p: p,
      title: title.localized(context),
      subtitle: subtitle.localized(context),
      actions: actions,
    );
  }

  void _openDailyWrapup() {
    final moments = MomentRepository().getAllMoments();
    DailyWrapupSheet.show(
      context,
      p: widget.p,
      moments: moments,
      onEndActiveSessions: () async {
        await _channel.invokeMethod('stopFloatingTimer');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.chart_bar_square,
              title: 'Dashboard'.localized(context),
              status: '$entriesCount ${'Logs'.localized(context)}',
              color: p.accent,
              onTap: () => onOpenCategory('Dashboard', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.hourglass,
              title: 'Life Audit'.localized(context),
              status: 'Time Wastage'.localized(context),
              color: p.red,
              onTap: () => onOpenCategory('Life Audit', parent: 'Logging'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Executive activity intelligence, time wastage auditing, 24-hour baseline accounting, and mortality insights.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          title: 'Logging Controls'.localized(context),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.hand_point_right_fill,
              title: 'Capture'.localized(context),
              status: defaultModeLabel(defaultMode),
              color: p.green,
              onTap: () => onOpenCategory('Capture', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.clock_fill,
              title: 'Moments'.localized(context),
              status: '$notesCount ${'Notes'.localized(context)}',
              color: p.orange,
              onTap: () => onOpenCategory('Moments', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.square_grid_2x2,
              title: 'Modes'.localized(context),
              status: 'Focus Modes'.localized(context),
              color: p.accent,
              onTap: () => onOpenCategory('Modes', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.flag,
              title: 'Targets & Projects'.localized(context),
              status: 'Pacing & Goals'.localized(context),
              color: p.accent,
              onTap: () =>
                  onOpenCategory('Targets & Projects', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.tag,
              title: 'Activity Tags'.localized(context),
              status: 'Quick Tags'.localized(context),
              color: p.accent,
              onTap: () => onOpenCategory('Activity Tags', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.bell,
              title: 'Reminders'.localized(context),
              status: remindersStatus,
              color: p.accent,
              onTap: () => onOpenCategory('Reminders', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.arrow_up_doc,
              title: 'Backup & Export'.localized(context),
              status: 'Data'.localized(context),
              color: p.green,
              onTap: () => onOpenCategory('Backup & Export', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.trash,
              title: 'Trash Bin'.localized(context),
              status: trash.isEmpty
                  ? 'Empty'.localized(context)
                  : '${trash.length} ${(trash.length == 1 ? "item" : "items").localized(context)}',
              color: p.orange,
              onTap: () => onOpenCategory('Trash Bin', parent: 'Logging'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'These settings define how moments are recorded, restored from trash, and prepared for export.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.sparkles,
              title: 'Sobriety Companion',
              color: p.orange,
              status: enableSobrietyMode ? 'On' : 'Off',
              onTap: () =>
                  onOpenCategory('Sobriety Companion', parent: 'Logging'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Track clean streaks, log relapses with mood and trigger tags, and view offline pattern analysis.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          title: 'Notification Panel',
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Persistent Control',
              subtitle:
                  'Show a sticky notification in the drawer to log check-in/out directly from the lock screen.'
                      .localized(context),
              value: showPersistentNotification,
              color: p.accent,
              onChanged: onShowPersistentNotificationChanged,
            ),
            if (showPersistentNotification)
              SettingsSwitchRow(
                p: p,
                title: 'Quick Note Popup'.localized(context),
                subtitle:
                    'Prompt for tags and notes when logging from notification.'
                        .localized(context),
                value: notifLogAction != 'silent',
                color: p.accent,
                onChanged: onNotifLogActionChanged ?? (_) {},
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _NotificationPreviewCard(
                p: p,
                enabled: showPersistentNotification,
                quickNoteEnabled: notifLogAction != 'silent',
              ),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Enables quick, low-priority control notification in the system drawer for convenience.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          title: 'Card Chromatics'.localized(context),
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Rainbow Cards'.localized(context),
              subtitle:
                  'Tint cards with category colors across timeline, calendar, and search notes while preserving contrast.'
                      .localized(context),
              value: rainbowCards,
              color: p.accent,
              onChanged: onRainbowCardsChanged ?? (_) {},
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Subtle chromatic tinting provides effortless visual distinction between categories without visual fatigue.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          title: 'Floating Quick-Action Overlay'.localized(context),
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Persistent Floating Bubble'.localized(context),
              subtitle:
                  'Keep a floating bubble over all apps to log moments and start timers with a single tap.'
                      .localized(context),
              value: _floatingBubbleEnabled,
              color: p.accent,
              onChanged: _toggleFloatingBubble,
            ),
            if (_floatingBubbleEnabled) ...[
              SettingsRow(
                p: p,
                icon: CupertinoIcons.hand_point_right,
                title: 'Single Tap Action'.localized(context),
                status: _singleTapAction == 'quick_log'
                    ? 'Quick Log Note'.localized(context)
                    : 'Expand Controls'.localized(context),
                color: p.accent,
                onTap: () => _showGesturePicker(isSingleTap: true),
              ),
              SettingsRow(
                p: p,
                icon: CupertinoIcons.bolt,
                title: 'Double Tap Action'.localized(context),
                status: _doubleTapAction == 'quick_menu'
                    ? 'Modes & Tags Menu'.localized(context)
                    : 'Toggle Expand'.localized(context),
                color: p.accent,
                onTap: () => _showGesturePicker(isSingleTap: false),
              ),
            ],
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'The floating overlay provides frictionless access anywhere on Android. Single-tap to log notes and double-tap to start mode sessions.'
                  .localized(context),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          p: p,
          title: 'Time-Awareness & Concurrency'.localized(context),
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.arrow_2_circlepath,
              title: 'Timer Concurrency'.localized(context),
              subtitle:
                  'Auto-pause previous timer when starting a new mode to prevent overlapping hours.'
                      .localized(context),
              status: _concurrencyMode == 'exclusive'
                  ? 'Auto-Pause (Exclusive)'
                  : 'Parallel Timers',
              color: p.accent,
              onTap: _toggleConcurrencyMode,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.moon_stars,
              title: 'Daily Wrap-up (End All)'.localized(context),
              subtitle:
                  'Seal open sessions and review today’s conscious time breakdown and calendar sync.'
                      .localized(context),
              status: 'Wrap Up',
              color: p.green,
              onTap: _openDailyWrapup,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Concurrency controls prevent unintentional time overlapping. The daily wrap-up seals active timers and tallies conscious vs unconscious hours.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}

class _NotificationPreviewCard extends StatelessWidget {
  const _NotificationPreviewCard({
    required this.p,
    required this.enabled,
    required this.quickNoteEnabled,
  });

  final Palette p;
  final bool enabled;
  final bool quickNoteEnabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: p.surface2.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.bell_slash_fill, size: 16, color: p.text3),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Persistent drawer notification is turned off.'.localized(
                  context,
                ),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Header
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.clock_fill,
                  size: 10,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'NoteKar',
                style: TextStyle(
                  color: p.text2,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  '•',
                  style: TextStyle(color: p.text3, fontSize: 11),
                ),
              ),
              Text(
                'Active Session'.localized(context),
                style: TextStyle(color: p.text3, fontSize: 11),
              ),
              const Spacer(),
              Text('now', style: TextStyle(color: p.text3, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),

          // Notification Content
          Text(
            'Deep Work • Focus Mode'.localized(context),
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '01:24:18 elapsed · Chronometer live ticker'.localized(context),
            style: TextStyle(color: p.text2, fontSize: 11.5),
          ),
          const SizedBox(height: 10),

          // Action Chips
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.square_fill, size: 9, color: p.accent),
                    const SizedBox(width: 5),
                    Text(
                      'Check Out'.localized(context),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      quickNoteEnabled
                          ? CupertinoIcons.pencil_circle
                          : CupertinoIcons.bolt_fill,
                      size: 10,
                      color: p.text,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      (quickNoteEnabled ? 'Quick Note' : 'Quick Log').localized(
                        context,
                      ),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
