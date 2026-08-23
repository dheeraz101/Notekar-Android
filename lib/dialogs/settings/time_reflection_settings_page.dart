import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class TimeReflectionSettingsPage extends StatelessWidget {
  const TimeReflectionSettingsPage({
    super.key,
    required this.p,
    required this.reflectionReminderEnabled,
    required this.reflectionReminderIntervalMins,
    required this.reflectionReminderSound,
    this.reflectionReminderMessage = '',
    this.reflectionStartTime = const TimeOfDay(hour: 9, minute: 0),
    this.reflectionEndTime = const TimeOfDay(hour: 22, minute: 0),
    required this.onToggleReflectionReminder,
    required this.onTapReflectionInterval,
    required this.onToggleReflectionSound,
    this.onUpdateReflectionMessage,
    this.onTapStartTime,
    this.onTapEndTime,
    required this.onPreviewReflectionSheet,
  });

  final Palette p;
  final bool reflectionReminderEnabled;
  final int reflectionReminderIntervalMins;
  final bool reflectionReminderSound;
  final String reflectionReminderMessage;
  final TimeOfDay reflectionStartTime;
  final TimeOfDay reflectionEndTime;
  final ValueChanged<bool> onToggleReflectionReminder;
  final ValueChanged<int> onTapReflectionInterval;
  final ValueChanged<bool> onToggleReflectionSound;
  final ValueChanged<String>? onUpdateReflectionMessage;
  final VoidCallback? onTapStartTime;
  final VoidCallback? onTapEndTime;
  final VoidCallback onPreviewReflectionSheet;

  String _shortInterval(BuildContext context, int minutes) {
    return switch (minutes) {
      15 => '15 Mins',
      30 => '30 Mins',
      45 => '45 Mins',
      60 => '1 Hour',
      120 => '2 Hours',
      _ => '$minutes Mins',
    }.localized(context);
  }

  String _fullIntervalLabel(BuildContext context, int minutes) {
    return switch (minutes) {
      15 => 'Every 15 Minutes',
      30 => 'Every 30 Minutes',
      45 => 'Every 45 Minutes',
      60 => 'Every 1 Hour (Recommended)',
      120 => 'Every 2 Hours',
      _ => 'Every $minutes Minutes',
    }.localized(context);
  }

  Future<void> _openIOSIntervalPicker(BuildContext context) async {
    HapticFeedback.selectionClick();
    final intervals = [15, 30, 45, 60, 120];

    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: p.border.withValues(alpha: 0.5),
              width: 0.8,
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Glass(
              p: p,
              radius: 32,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // iOS Grab handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: p.text3.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reminder Interval'.localized(context),
                          style: TextStyle(
                            color: p.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        PressableScale(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.surface2,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: p.text2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < intervals.length; i++) ...[
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(ctx, intervals[i]);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 15,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _fullIntervalLabel(
                                          context,
                                          intervals[i],
                                        ),
                                        style: TextStyle(
                                          color:
                                              intervals[i] ==
                                                  reflectionReminderIntervalMins
                                              ? p.accent
                                              : p.text,
                                          fontSize: 15,
                                          fontWeight:
                                              intervals[i] ==
                                                  reflectionReminderIntervalMins
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (intervals[i] ==
                                        reflectionReminderIntervalMins)
                                      Icon(
                                        Icons.check_rounded,
                                        color: p.accent,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (i < intervals.length - 1)
                              Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: p.border,
                                indent: 18,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      onTapReflectionInterval(selected);
    }
  }

  Future<void> _openMessageEditor(BuildContext context) async {
    HapticFeedback.selectionClick();
    final controller = TextEditingController(text: reflectionReminderMessage);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final textLen = controller.text.length;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: Glass(
                    p: p,
                    radius: 32,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: p.text3.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Message'.localized(context),
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              PressableScale(
                                onTap: () => Navigator.pop(ctx),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: p.surface2,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: p.text2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: controller,
                            maxLength: 60,
                            maxLines: 2,
                            autofocus: true,
                            onChanged: (_) => setModalState(() {}),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Short motivational line'.localized(
                                context,
                              ),
                              hintStyle: TextStyle(
                                color: p.text3,
                                fontSize: 13,
                              ),
                              counterText: '$textLen/60',
                              counterStyle: TextStyle(
                                color: textLen > 55 ? p.orange : p.text3,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              filled: true,
                              fillColor: p.surface2,
                              contentPadding: const EdgeInsets.all(16),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: p.accent,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: p.border.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              if (controller.text.isNotEmpty)
                                Expanded(
                                  flex: 1,
                                  child: TextButton(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      controller.clear();
                                      onUpdateReflectionMessage?.call('');
                                      Navigator.pop(ctx);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: p.text3,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: Text('Reset'.localized(context)),
                                  ),
                                ),
                              if (controller.text.isNotEmpty)
                                const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    onUpdateReflectionMessage?.call(
                                      controller.text.trim(),
                                    );
                                    Navigator.pop(ctx);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: p.accent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Save Message'.localized(context),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),

        // Hero Header Card (Matching SettingsGroup width & radius)
        Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(32),
            border: p.name == 'amoled'
                ? Border.all(color: p.border.withValues(alpha: 0.5), width: 0.8)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.accent.withValues(alpha: 0.15),
                  border: Border.all(
                    color: p.accent.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.self_improvement_rounded,
                  color: p.accent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Mindfulness'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'A full-screen mindful reminder that turns your phone into an awareness anchor throughout the day.'
                    .localized(context),
                style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (reflectionReminderEnabled ? p.green : p.text3)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (reflectionReminderEnabled ? p.green : p.text3)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: reflectionReminderEnabled ? p.green : p.text3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        reflectionReminderEnabled
                            ? '${'Active'.localized(context)} · ${_shortInterval(context, reflectionReminderIntervalMins)}'
                            : 'Disabled'.localized(context),
                        style: TextStyle(
                          color: reflectionReminderEnabled ? p.green : p.text3,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing12),

        // Controls Group
        SettingsGroup(
          p: p,
          title: 'Configuration'.localized(context).toUpperCase(),
          children: [
            SettingsSwitchRow(
              p: p,
              title: 'Enable Time Reflection'.localized(context),
              color: p.accent,
              value: reflectionReminderEnabled,
              onChanged: onToggleReflectionReminder,
            ),
            if (reflectionReminderEnabled) ...[
              SettingsRow(
                p: p,
                title: 'Reminder Interval'.localized(context),
                status: _shortInterval(context, reflectionReminderIntervalMins),
                color: p.accent,
                onTap: () => _openIOSIntervalPicker(context),
              ),
              SettingsSwitchRow(
                p: p,
                title: 'Sound & Chime Alert'.localized(context),
                color: p.accent,
                value: reflectionReminderSound,
                onChanged: onToggleReflectionSound,
              ),
              SettingsRow(
                p: p,
                title: 'Message'.localized(context),
                status: reflectionReminderMessage.trim().isNotEmpty
                    ? 'Custom'.localized(context)
                    : 'Default'.localized(context),
                color: p.accent,
                onTap: () => _openMessageEditor(context),
              ),
              SettingsRow(
                p: p,
                title: 'Test Alert'.localized(context),
                status: 'Test (3s)'.localized(context),
                color: p.accent,
                onTap: onPreviewReflectionSheet,
              ),
            ],
          ],
        ),
        if (reflectionReminderEnabled) ...[
          const SizedBox(height: spacing8),
          SettingsGroup(
            p: p,
            title: 'Active Schedule'.localized(context).toUpperCase(),
            children: [
              SettingsRow(
                p: p,
                title: 'Start Time'.localized(context),
                status: reflectionStartTime.format(context),
                color: p.accent,
                onTap: onTapStartTime,
              ),
              SettingsRow(
                p: p,
                title: 'End Time'.localized(context),
                status: reflectionEndTime.format(context),
                color: p.accent,
                onTap: onTapEndTime,
              ),
            ],
          ),
          SettingsPageDescription(
            p: p,
            text:
                'Alarms only alert between ${reflectionStartTime.format(context)} and ${reflectionEndTime.format(context)} to keep your sleep peaceful and uninterrupted.'
                    .localized(context),
          ),
        ],

        const SizedBox(height: spacing8),

        // Why Time Reflection Card
        SettingsGroup(
          p: p,
          title: 'Why Time Reflection?'.localized(context).toUpperCase(),
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our phones are with us every single hour of the day. In the rush of daily life, hours frequently disappear into reactive multitasking and endless scrolling.'
                        .localized(context),
                    style: TextStyle(color: p.text2, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Time Reflection interrupts autopilot living. An hourly chime transforms your phone from a source of distraction into a mindful ally, helping you feel the passage of time and regain conscious control of your day.'
                        .localized(context),
                    style: TextStyle(color: p.text2, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: spacing12),

        // How to Use It Effectively Card
        SettingsGroup(
          p: p,
          title: 'How to Use It Effectively'.localized(context).toUpperCase(),
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _buildGuideStep(
                    context,
                    p: p,
                    icon: Icons.air_rounded,
                    title: 'Take Three Deep Breaths'.localized(context),
                    desc:
                        'When the alert wakes your screen, pause whatever you are doing. Inhale deeply, exhale slowly, and ground yourself in the present moment.'
                            .localized(context),
                  ),
                  const SizedBox(height: 14),
                  _buildGuideStep(
                    context,
                    p: p,
                    icon: Icons.history_toggle_off_rounded,
                    title: 'Acknowledge the Elapsed Hour'.localized(context),
                    desc:
                        'Look back at the last 60 minutes with kindness. Did you spend it intentionally, or did time slip away? Awareness is the first step to freedom.'
                            .localized(context),
                  ),
                  const SizedBox(height: 14),
                  _buildGuideStep(
                    context,
                    p: p,
                    icon: Icons.crisis_alert_rounded,
                    title: 'Set One Focus For Next Hour'.localized(context),
                    desc:
                        'Choose a single primary intention for the upcoming hour before continuing your tasks.'
                            .localized(context),
                  ),
                  const SizedBox(height: 14),
                  _buildGuideStep(
                    context,
                    p: p,
                    icon: Icons.edit_note_rounded,
                    title: 'Log a Quick Moment'.localized(context),
                    desc:
                        'Tap "Log Current Moment" to capture an insight, gratitude, or achievement directly into NoteKar.'
                            .localized(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGuideStep(
    BuildContext context, {
    required Palette p,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: p.surface,
            border: Border.all(
              color: p.accent.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Center(child: Icon(icon, size: 16, color: p.accent)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: p.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: TextStyle(color: p.text2, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
