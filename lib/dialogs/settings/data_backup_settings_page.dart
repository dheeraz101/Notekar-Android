import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

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
    required this.onRestoreBackupFromString,
    required this.onSaveQuickBackup,
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
  final Future<bool> Function(String content) onRestoreBackupFromString;
  final VoidCallback onSaveQuickBackup;
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
            SettingsRow(
              p: p,
              icon: Icons.folder_zip_outlined,
              title: 'Local Backups'.localized(context),
              status: 'Manage'.localized(context),
              color: p.accent,
              onTap: () =>
                  onOpenCategory('Local Backups', parent: 'Data & Backup'),
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

class LocalBackupsPage extends StatefulWidget {
  const LocalBackupsPage({
    super.key,
    required this.p,
    required this.onRestore,
    required this.onCreateQuickBackup,
  });

  final Palette p;
  final Future<bool> Function(String content) onRestore;
  final VoidCallback onCreateQuickBackup;

  @override
  State<LocalBackupsPage> createState() => _LocalBackupsPageState();
}

class _LocalBackupsPageState extends State<LocalBackupsPage> {
  List<File> _backupFiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _loading = true);
    try {
      const channel = MethodChannel('notekar/files');
      final dataDir = await channel.invokeMethod<String>('appDataDir');
      if (dataDir == null) {
        setState(() {
          _backupFiles = [];
          _loading = false;
        });
        return;
      }
      final dir = Directory('$dataDir/local_backups');
      if (await dir.exists()) {
        final List<FileSystemEntity> entities = await dir.list().toList();
        final List<File> files = entities
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList();
        files.sort((a, b) {
          final aTime = a.lastModifiedSync();
          final bTime = b.lastModifiedSync();
          return bTime.compareTo(aTime);
        });
        setState(() {
          _backupFiles = files;
          _loading = false;
        });
      } else {
        setState(() {
          _backupFiles = [];
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _backupFiles = [];
        _loading = false;
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime dt) {
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
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} - $hour:$minuteStr $period';
  }

  Future<void> _deleteBackup(File file) async {
    try {
      await file.delete();
      await _loadBackups();
    } catch (_) {}
  }

  Future<void> _restoreFile(File file) async {
    try {
      final content = await file.readAsString();
      final success = await widget.onRestore(content);
      if (success) {
        // Success toast is shown in note_kar_home, reload backups just in case
        await _loadBackups();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to read local backup file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Restore previous database states locally with a single tap. Backups here are stored securely inside your local app sandbox.'
                  .localized(context),
        ),
        const SizedBox(height: spacing12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacing16),
          child: SizedBox(
            height: 46,
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                widget.onCreateQuickBackup();
                await Future<void>.delayed(const Duration(milliseconds: 300));
                await _loadBackups();
              },
              icon: const Icon(Icons.add_to_photos_outlined, size: 18),
              label: Text(
                'Create Quick Local Backup'.localized(context),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: spacing16),
        if (_loading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(spacing32),
              child: CircularProgressIndicator(color: p.accent),
            ),
          )
        else if (_backupFiles.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(spacing32),
              child: Text(
                'No local backups found.'.localized(context),
                style: TextStyle(color: p.text3, fontSize: 13),
              ),
            ),
          )
        else
          SettingsGroup(
            p: p,
            title: 'Backup History',
            insetDividers: true,
            children: [for (final file in _backupFiles) _buildBackupRow(file)],
          ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildBackupRow(File file) {
    final p = widget.p;
    final stat = file.statSync();
    final dateFormatted = _formatDate(stat.modified);
    final sizeFormatted = _formatSize(stat.size);

    return Dismissible(
      key: Key(file.path),
      direction: DismissDirection.endToStart,
      background: Container(
        color: p.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (direction) => _deleteBackup(file),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _restoreFile(file),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: spacing16,
              vertical: spacing12,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_zip_outlined,
                    color: p.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormatted,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sizeFormatted,
                        style: TextStyle(color: p.text3, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.restore_rounded, color: p.orange, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
