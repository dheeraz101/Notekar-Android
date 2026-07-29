import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class RemindersSettingsPage extends StatelessWidget {
  const RemindersSettingsPage({
    super.key,
    required this.p,
    required this.hasExactAlarmPermission,
    required this.ignoresBatteryOptimizations,
    required this.autoStartCardDismissed,
    required this.dailyReminderEnabled,
    required this.dailyReminderTime,
    required this.dailyReminderBody,
    required this.inactivityReminderEnabled,
    required this.inactivityIntervalMins,
    required this.weeklyReminderEnabled,
    required this.weeklyReminderDays,
    required this.weeklyReminderTime,
    required this.weeklyReminderBody,
    required this.monthlyReminderEnabled,
    required this.monthlyReminderDay,
    required this.monthlyReminderTime,
    required this.monthlyReminderBody,
    required this.onRequestExactAlarmPermission,
    required this.onRequestIgnoreBatteryOptimizations,
    required this.onDismissAutoStartCard,
    required this.onOpenAutoStartSettings,
    required this.onToggleDailyReminder,
    required this.onTapDailyTime,
    required this.onTapDailyMessage,
    required this.onToggleInactivityReminder,
    required this.onTapInactivityInterval,
    required this.onToggleWeeklyReminder,
    required this.onTapWeeklyDays,
    required this.onTapWeeklyTime,
    required this.onTapWeeklyMessage,
    required this.onToggleMonthlyReminder,
    required this.onTapMonthlyDay,
    required this.onTapMonthlyTime,
    required this.onTapMonthlyMessage,
  });

  final Palette p;
  final bool hasExactAlarmPermission;
  final bool ignoresBatteryOptimizations;
  final bool autoStartCardDismissed;

  final bool dailyReminderEnabled;
  final TimeOfDay dailyReminderTime;
  final String dailyReminderBody;

  final bool inactivityReminderEnabled;
  final int inactivityIntervalMins;

  final bool weeklyReminderEnabled;
  final List<int> weeklyReminderDays;
  final TimeOfDay weeklyReminderTime;
  final String weeklyReminderBody;

  final bool monthlyReminderEnabled;
  final int monthlyReminderDay;
  final TimeOfDay monthlyReminderTime;
  final String monthlyReminderBody;

  final ValueChanged<bool> onRequestExactAlarmPermission;
  final ValueChanged<bool> onRequestIgnoreBatteryOptimizations;
  final VoidCallback onDismissAutoStartCard;
  final VoidCallback onOpenAutoStartSettings;

  final ValueChanged<bool> onToggleDailyReminder;
  final VoidCallback onTapDailyTime;
  final VoidCallback onTapDailyMessage;

  final ValueChanged<bool> onToggleInactivityReminder;
  final ValueChanged<int> onTapInactivityInterval;

  final ValueChanged<bool> onToggleWeeklyReminder;
  final ValueChanged<List<int>> onTapWeeklyDays;
  final VoidCallback onTapWeeklyTime;
  final VoidCallback onTapWeeklyMessage;

  final ValueChanged<bool> onToggleMonthlyReminder;
  final ValueChanged<int> onTapMonthlyDay;
  final VoidCallback onTapMonthlyTime;
  final VoidCallback onTapMonthlyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        if (!hasExactAlarmPermission)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Glass(
              p: p,
              radius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Alarms Permission Required'.localized(context),
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
                    style: TextStyle(color: p.text2, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => onRequestExactAlarmPermission(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text('Grant Permission'.localized(context)),
                  ),
                ],
              ),
            ),
          ),

        if (!ignoresBatteryOptimizations)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Glass(
              p: p,
              radius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Battery Optimization Active'.localized(context),
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
                    style: TextStyle(color: p.text2, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => onRequestIgnoreBatteryOptimizations(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Disable Battery Optimization'.localized(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (!autoStartCardDismissed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Glass(
              p: p,
              radius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.autorenew_rounded, color: p.orange, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Auto-Start & Background Activity'.localized(context),
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
                        onPressed: onDismissAutoStartCard,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'On devices like Xiaomi, Samsung, Oppo, Vivo, or Huawei, the OS restricts background alarms when swiped away from recents. Grant "Auto-Start" or allow "Background Activity" to ensure reminders trigger.'
                        .localized(context),
                    style: TextStyle(color: p.text2, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onOpenAutoStartSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text('Configure Settings'.localized(context)),
                  ),
                ],
              ),
            ),
          ),

        // Daily reminder group
        SettingsGroup(
          p: p,
          title: 'daily reminder'.localized(context).toUpperCase(),
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'daily reminder'.localized(context),
              color: p.accent,
              value: dailyReminderEnabled,
              onChanged: onToggleDailyReminder,
            ),
            if (dailyReminderEnabled) ...[
              SettingsRow(
                p: p,
                title: 'Time'.localized(context),
                status: dailyReminderTime.format(context),
                color: p.accent,
                onTap: onTapDailyTime,
              ),
              SettingsRow(
                p: p,
                title: 'Message'.localized(context),
                status: dailyReminderBody.trim().isEmpty
                    ? 'Empty'.localized(context)
                    : 'Set'.localized(context),
                color: p.accent,
                onTap: onTapDailyMessage,
              ),
            ],
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'Triggers a daily logging reminder alert at your chosen time.'
              .localized(context),
        ),

        // Inactivity reminder group
        SettingsGroup(
          p: p,
          title: 'inactivity reminder'.localized(context).toUpperCase(),
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'inactivity reminder'.localized(context),
              color: p.orange,
              value: inactivityReminderEnabled,
              onChanged: onToggleInactivityReminder,
            ),
            if (inactivityReminderEnabled)
              SettingsRow(
                p: p,
                title: 'remind if inactive for'.localized(context),
                status:
                    '${inactivityIntervalMins ~/ 60} ${inactivityIntervalMins == 60 ? 'hour'.localized(context) : 'hours'.localized(context)}',
                color: p.orange,
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final selected = await showDialog<int>(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text(
                          'remind if inactive for'.localized(context),
                        ),
                        children: [
                          for (final interval in [60, 120, 240, 480, 720, 1440])
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, interval),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  '${interval ~/ 60} ${interval == 60 ? 'hour'.localized(context) : 'hours'.localized(context)}',
                                  style: TextStyle(color: p.text, fontSize: 16),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                  if (selected != null) {
                    onTapInactivityInterval(selected);
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
          title: 'weekly reminder'.localized(context).toUpperCase(),
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'weekly reminder'.localized(context),
              color: p.green,
              value: weeklyReminderEnabled,
              onChanged: onToggleWeeklyReminder,
            ),
            if (weeklyReminderEnabled) ...[
              SettingsRow(
                p: p,
                title: 'days of week'.localized(context),
                status: weeklyReminderDays
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
                  final selectedDays = List<int>.from(weeklyReminderDays);
                  final updated = await showDialog<List<int>>(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text('days of week'.localized(context)),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: days.map((day) {
                                  final name = switch (day) {
                                    1 => 'Sunday'.localized(context),
                                    2 => 'Monday'.localized(context),
                                    3 => 'Tuesday'.localized(context),
                                    4 => 'Wednesday'.localized(context),
                                    5 => 'Thursday'.localized(context),
                                    6 => 'Friday'.localized(context),
                                    7 => 'Saturday'.localized(context),
                                    _ => '',
                                  };
                                  final contains = selectedDays.contains(day);
                                  return CheckboxListTile(
                                    title: Text(
                                      name,
                                      style: TextStyle(color: p.text),
                                    ),
                                    value: contains,
                                    activeColor: p.accent,
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val == true) {
                                          selectedDays.add(day);
                                        } else {
                                          selectedDays.remove(day);
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
                                    Navigator.pop(context, selectedDays),
                                child: Text('okay'.localized(context)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                  if (updated != null) {
                    onTapWeeklyDays(updated);
                  }
                },
              ),
              SettingsRow(
                p: p,
                title: 'Time'.localized(context),
                status: weeklyReminderTime.format(context),
                color: p.green,
                onTap: onTapWeeklyTime,
              ),
              SettingsRow(
                p: p,
                title: 'Message'.localized(context),
                status: weeklyReminderBody.trim().isEmpty
                    ? 'Empty'.localized(context)
                    : 'Set'.localized(context),
                color: p.green,
                onTap: onTapWeeklyMessage,
              ),
            ],
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'Triggers reminders on specific days of the week.'.localized(
            context,
          ),
        ),

        // Monthly reminder group
        SettingsGroup(
          p: p,
          title: 'monthly reminder'.localized(context).toUpperCase(),
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'monthly reminder'.localized(context),
              color: p.red,
              value: monthlyReminderEnabled,
              onChanged: onToggleMonthlyReminder,
            ),
            if (monthlyReminderEnabled) ...[
              SettingsRow(
                p: p,
                title: 'day of month'.localized(context),
                status: '$monthlyReminderDay',
                color: p.red,
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final selected = await showDialog<int>(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text('day of month'.localized(context)),
                        children: [
                          for (int day = 1; day <= 28; day++)
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, day),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: Text(
                                  '$day',
                                  style: TextStyle(color: p.text, fontSize: 16),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                  if (selected != null) {
                    onTapMonthlyDay(selected);
                  }
                },
              ),
              SettingsRow(
                p: p,
                title: 'Time'.localized(context),
                status: monthlyReminderTime.format(context),
                color: p.red,
                onTap: onTapMonthlyTime,
              ),
              SettingsRow(
                p: p,
                title: 'Message'.localized(context),
                status: monthlyReminderBody.trim().isEmpty
                    ? 'Empty'.localized(context)
                    : 'Set'.localized(context),
                color: p.red,
                onTap: onTapMonthlyMessage,
              ),
            ],
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: 'Triggers a monthly reminder on a chosen calendar day.'
              .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}

class ReminderMessagePage extends StatefulWidget {
  const ReminderMessagePage({
    super.key,
    required this.p,
    required this.editingReminderType,
    required this.currentValue,
    required this.recents,
    required this.onSave,
    required this.onPop,
  });

  final Palette p;
  final String editingReminderType;
  final String currentValue;
  final List<String> recents;
  final Future<void> Function(String type, String newText) onSave;
  final VoidCallback onPop;

  @override
  State<ReminderMessagePage> createState() => _ReminderMessagePageState();
}

class _ReminderMessagePageState extends State<ReminderMessagePage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

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
                    controller: _controller,
                    focusNode: _focusNode,
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
                          _focusNode.hasFocus
                              ? Icons.check_rounded
                              : Icons.edit_rounded,
                          color: _focusNode.hasFocus ? p.accent : p.text3,
                          size: 20,
                        ),
                        onPressed: () {
                          if (_focusNode.hasFocus) {
                            _focusNode.unfocus();
                          } else {
                            _focusNode.requestFocus();
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
                  if (widget.recents.isNotEmpty) ...[
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
                        for (final item in widget.recents.take(5))
                          SettingsRow(
                            p: p,
                            icon: Icons.history_rounded,
                            title: item,
                            color: p.text3,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _controller.text = item;
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
                final newText = _controller.text.trim();
                await widget.onSave(widget.editingReminderType, newText);
                widget.onPop();
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
}
