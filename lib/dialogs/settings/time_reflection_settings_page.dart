import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class TimeReflectionSettingsPage extends StatelessWidget {
  const TimeReflectionSettingsPage({
    super.key,
    required this.p,
    required this.reflectionReminderEnabled,
    required this.reflectionReminderIntervalMins,
    required this.reflectionReminderSound,
    required this.onToggleReflectionReminder,
    required this.onTapReflectionInterval,
    required this.onToggleReflectionSound,
    required this.onTestReflectionAlert,
    required this.onPreviewReflectionSheet,
  });

  final Palette p;
  final bool reflectionReminderEnabled;
  final int reflectionReminderIntervalMins;
  final bool reflectionReminderSound;
  final ValueChanged<bool> onToggleReflectionReminder;
  final ValueChanged<int> onTapReflectionInterval;
  final ValueChanged<bool> onToggleReflectionSound;
  final VoidCallback onTestReflectionAlert;
  final VoidCallback onPreviewReflectionSheet;

  String _intervalLabel(BuildContext context, int minutes) {
    return switch (minutes) {
      15 => 'Every 15 Minutes',
      30 => 'Every 30 Minutes',
      45 => 'Every 45 Minutes',
      60 => 'Every 1 Hour (Recommended)',
      120 => 'Every 2 Hours',
      _ => 'Every $minutes Minutes',
    }.localized(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Header Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Glass(
            p: p,
            radius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
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
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Time Reflection & Mindfulness'.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'A full-screen mindful reminder that turns your phone into an awareness anchor throughout the day.'
                      .localized(context),
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
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
                      Text(
                        reflectionReminderEnabled
                            ? '${'Active'.localized(context)} · ${_intervalLabel(context, reflectionReminderIntervalMins)}'
                            : 'Inactive'.localized(context),
                        style: TextStyle(
                          color: reflectionReminderEnabled ? p.green : p.text3,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

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
                status: _intervalLabel(context, reflectionReminderIntervalMins),
                color: p.accent,
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final selected = await showDialog<int>(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text(
                          'Time Reflection Interval'.localized(context),
                        ),
                        children: [
                          for (final interval in [15, 30, 45, 60, 120])
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, interval),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  _intervalLabel(context, interval),
                                  style: TextStyle(color: p.text, fontSize: 16),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                  if (selected != null) {
                    onTapReflectionInterval(selected);
                  }
                },
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
                title: 'Test Full-Screen Alarm Alert'.localized(context),
                status: 'Test Now'.localized(context),
                color: p.accent,
                onTap: onTestReflectionAlert,
              ),
              SettingsRow(
                p: p,
                title: 'Preview In-App Sheet'.localized(context),
                status: 'Open'.localized(context),
                color: p.accent,
                onTap: onPreviewReflectionSheet,
              ),
            ],
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'When active, your phone will wake up with a soothing alarm tone and present a full-screen reflection prompt at your chosen frequency even if the screen is locked.'
                  .localized(context),
        ),

        // Why This Feature Exists Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Glass(
            p: p,
            radius: 18,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: p.orange,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Why Time Reflection?'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
        ),

        // How to Use Effectively Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Glass(
            p: p,
            radius: 18,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: p.green,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'How to Use It Effectively'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildGuideStep(
                  context,
                  p: p,
                  step: '1',
                  icon: Icons.air_rounded,
                  title: 'Take Three Deep Breaths'.localized(context),
                  desc:
                      'When the alert wakes your screen, pause whatever you are doing. Inhale deeply, exhale slowly, and ground yourself in the present moment.'
                          .localized(context),
                ),
                const SizedBox(height: 12),
                _buildGuideStep(
                  context,
                  p: p,
                  step: '2',
                  icon: Icons.history_toggle_off_rounded,
                  title: 'Acknowledge the Elapsed Hour'.localized(context),
                  desc:
                      'Look back at the last 60 minutes with kindness. Did you spend it intentionally, or did time slip away? Awareness is the first step to freedom.'
                          .localized(context),
                ),
                const SizedBox(height: 12),
                _buildGuideStep(
                  context,
                  p: p,
                  step: '3',
                  icon: Icons.crisis_alert_rounded,
                  title: 'Set One Focus For Next Hour'.localized(context),
                  desc:
                      'Choose a single primary intention for the upcoming hour before continuing your tasks.'
                          .localized(context),
                ),
                const SizedBox(height: 12),
                _buildGuideStep(
                  context,
                  p: p,
                  step: '4',
                  icon: Icons.edit_note_rounded,
                  title: 'Log a Quick Moment'.localized(context),
                  desc:
                      'Tap "Log Current Moment" to capture an insight, gratitude, or achievement directly into NoteKar.'
                          .localized(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGuideStep(
    BuildContext context, {
    required Palette p,
    required String step,
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
            color: p.surface2,
            border: Border.all(
              color: p.accent.withValues(alpha: 0.3),
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
