import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class LoggingSettingsPage extends StatelessWidget {
  const LoggingSettingsPage({
    super.key,
    required this.p,
    required this.defaultMode,
    required this.entriesCount,
    required this.remindersStatus,
    required this.enableSobrietyMode,
    required this.showPersistentNotification,
    required this.onShowPersistentNotificationChanged,
    required this.onOpenCategory,
  });

  final Palette p;
  final String defaultMode;
  final int entriesCount;
  final String remindersStatus;
  final bool enableSobrietyMode;
  final bool showPersistentNotification;
  final ValueChanged<bool> onShowPersistentNotificationChanged;
  final void Function(String category, {required String parent}) onOpenCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.dashboard_customize_outlined,
              title: 'Dashboard',
              color: p.accent,
              onTap: () => onOpenCategory('Dashboard', parent: 'Logging'),
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
              status: defaultMode == 'single' ? 'Single' : 'Two-Way',
              color: p.green,
              onTap: () => onOpenCategory('Capture', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.history_rounded,
              title: 'Moments'.localized(context),
              status: '$entriesCount ${'Logs'.localized(context)}',
              color: p.orange,
              onTap: () => onOpenCategory('Moments', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.notifications_active_outlined,
              title: 'Reminders',
              status: remindersStatus,
              color: p.accent,
              onTap: () => onOpenCategory('Reminders', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.import_export_rounded,
              title: 'Backup & Export'.localized(context),
              status: 'Data'.localized(context),
              color: p.green,
              onTap: () => onOpenCategory('Backup & Export', parent: 'Logging'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.delete_outline_rounded,
              title: 'Trash Bin'.localized(context),
              status: 'Manage'.localized(context),
              color: p.red,
              onTap: () => onOpenCategory('Trash Bin', parent: 'Logging'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'These settings define how moments are recorded and prepared for export.'
                  .localized(context),
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
              icon: Icons.notification_important_rounded,
              title: 'Persistent Control',
              subtitle:
                  'Show a sticky notification in the drawer to log check-in/out directly from the lock screen.'
                      .localized(context),
              value: showPersistentNotification,
              color: p.accent,
              onChanged: onShowPersistentNotificationChanged,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Enables quick, low-priority control notification in the system drawer for convenience.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
