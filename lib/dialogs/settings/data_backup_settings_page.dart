import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/app_utils.dart';

class DataBackupSettingsPage extends StatelessWidget {
  const DataBackupSettingsPage({
    super.key,
    required this.p,
    required this.subCategory,
    required this.entriesCount,
    required this.dataHealthStatus,
    required this.backupReminderDays,
    required this.onBackupReminderDaysChanged,
    required this.onExportCsv,
    required this.onExportRecentCsv,
    required this.onExportJson,
    required this.onExportBackup,
    required this.onImportBackup,
    required this.onOpenCategory,
    required this.onLearnMoreBeta,
  });

  final Palette p;
  final String
  subCategory; // 'Data & Backup', 'Backup & Export', 'Backup Status'
  final int entriesCount;
  final String dataHealthStatus;
  final int backupReminderDays;
  final ValueChanged<int> onBackupReminderDaysChanged;
  final VoidCallback onExportCsv;
  final VoidCallback onExportRecentCsv;
  final VoidCallback onExportJson;
  final VoidCallback onExportBackup;
  final VoidCallback onImportBackup;
  final void Function(String category, {required String parent}) onOpenCategory;
  final VoidCallback onLearnMoreBeta;

  @override
  Widget build(BuildContext context) {
    if (subCategory == 'Data & Backup') {
      return _buildMain(context);
    } else if (subCategory == 'Backup & Export') {
      return _buildExport(context);
    } else if (subCategory == 'Backup Status') {
      return _buildStatus(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMain(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.archive_outlined,
              title: 'Backup & Export'.localized(context),
              status: '$entriesCount ${'Logs'.localized(context)}',
              color: p.green,
              onTap: () =>
                  onOpenCategory('Backup & Export', parent: 'Data & Backup'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.health_and_safety_outlined,
              title: 'Backup Status'.localized(context),
              status: dataHealthStatus,
              color: p.accent,
              onTap: () =>
                  onOpenCategory('Backup Status', parent: 'Data & Backup'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'NoteKar uses a private offline database. Use these tools to secure your history via manual exports.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildExport(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          title: 'Backup Schedule',
          children: [
            for (final days in [0, 7, 14, 30])
              SettingsRow(
                p: p,
                title: days == 0
                    ? 'Disabled'.localized(context)
                    : 'Every $days Days'.localized(context),
                trailing: backupReminderDays == days
                    ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                    : const SizedBox.shrink(),
                onTap: () {
                  if (backupReminderDays == days) return;
                  onBackupReminderDaysChanged(days);
                },
              ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text: backupReminderDays == 0
              ? 'Reminders are currently disabled. Set an interval to be reminded to safeguard your data.'
                    .localized(context)
              : 'NoteKar will prompt for a backup every $backupReminderDays days.'
                    .localized(context),
        ),

        SettingsGroup(
          p: p,
          title: 'CSV Export',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.table_chart_outlined,
              title: 'Export CSV'.localized(context),
              status: 'Table'.localized(context),
              color: p.green,
              rowKind: 'link',
              onTap: onExportCsv,
            ),
            SettingsRow(
              p: p,
              icon: Icons.date_range_outlined,
              title: 'Export Last 7 Days'.localized(context),
              status: 'Recent'.localized(context),
              color: p.green,
              rowKind: 'link',
              onTap: onExportRecentCsv,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Export moments to standard CSV formats. "Export CSV" saves your entire history, while "Export Last 7 Days" saves only recent records.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          title: 'JSON Export',
          children: [
            SettingsRow(
              p: p,
              icon: Icons.code_rounded,
              title: 'Export JSON'.localized(context),
              status: 'Dev'.localized(context),
              color: p.accent,
              rowKind: 'link',
              onTap: onExportJson,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Export moments to developer-friendly JSON format for advanced integrations and data portability.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          title: 'Database Backups',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.archive_outlined,
              title: 'Export Backup'.localized(context),
              status: 'Full'.localized(context),
              color: p.accent,
              rowKind: 'link',
              onTap: onExportBackup,
            ),
            SettingsRow(
              p: p,
              icon: Icons.unarchive_outlined,
              title: 'Import Backup'.localized(context),
              status: 'Restore'.localized(context),
              color: p.orange,
              rowKind: 'link',
              onTap: onImportBackup,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Manage complete database backups. Safely archive your entire history or restore it when migrating to another device.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          title: 'Active Protection',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.android_rounded,
              title: 'Android Backup'.localized(context),
              color: p.green,
              status: 'Active'.localized(context),
            ),
            SettingsRow(
              p: p,
              icon: Icons.favorite_outline_rounded,
              title: 'Data Health'.localized(context),
              color: p.green,
              status: dataHealthStatus,
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Android OS auto-backup preserves app preferences only. Your moments and notes stay 100% local and private to this device.'
                  .localized(context),
        ),

        SettingsGroup(
          p: p,
          title: 'Cloud & Sync (Planned)',
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.lock_outlined,
              title: 'Encrypted Backup'.localized(context),
              color: p.orange,
              status: 'Planned'.localized(context),
            ),
            SettingsRow(
              p: p,
              icon: Icons.cloud_outlined,
              title: 'Google Drive Backup'.localized(context),
              color: p.orange,
              status: 'Planned'.localized(context),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Planned cloud features will provide direct cloud synchronization across your personal devices.'
                  .localized(context),
        ),

        SettingsBetaNote(
          p: p,
          text: 'The current features on this page are under Beta stage.'
              .localized(context),
          onLearnMore: onLearnMoreBeta,
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
