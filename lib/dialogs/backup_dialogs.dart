import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/backup_models.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class BackupImportPreviewDialog extends StatelessWidget {
  const BackupImportPreviewDialog({
    super.key,
    required this.p,
    required this.summary,
    this.blur = false,
  });

  final Palette p;
  final BackupDryRunSummary summary;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final exported = summary.exportedAt == null
        ? 'Unknown date'
        : datePretty(summary.exportedAt!.millisecondsSinceEpoch);

    return AppSheet(
      p: p,
      title: 'Review Backup',
      blur: blur,
      child: SizedBox(
        width: 410,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsGroup(
              p: p,
              children: [
                BackupPreviewRow(
                  p: p,
                  label: 'Backup contains',
                  value:
                      '${summary.backupMoments} moments - ${summary.backupNotes} notes',
                  icon: Icons.backup_rounded,
                  color: p.accent,
                ),
                BackupPreviewRow(
                  p: p,
                  label: 'Exported',
                  value: exported,
                  icon: Icons.calendar_month_rounded,
                  color: p.green,
                ),
                BackupPreviewRow(
                  p: p,
                  label: 'New moments',
                  value: '${summary.newMoments}',
                  icon: Icons.add_circle_outline_rounded,
                  color: p.accent,
                ),
                BackupPreviewRow(
                  p: p,
                  label: 'Duplicates skipped',
                  value: '${summary.duplicatesSkipped}',
                  icon: Icons.filter_alt_off_rounded,
                  color: p.orange,
                ),
                BackupPreviewRow(
                  p: p,
                  label: 'Settings to restore',
                  value: '${summary.settingsToRestore}',
                  icon: Icons.tune_rounded,
                  color: p.green,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Import merges new moments into this device. Existing moments stay in place.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed:
                        summary.newMoments == 0 &&
                            summary.settingsToRestore == 0
                        ? null
                        : () => Navigator.pop(context, true),
                    child: const Text('Import'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BackupPreviewRow extends StatelessWidget {
  const BackupPreviewRow({
    super.key,
    required this.p,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final Palette p;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: p.text2,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
