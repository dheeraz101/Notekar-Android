import 'package:flutter/material.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';

class TrashBinSettingsPage {
  static List<Widget> buildSlivers({
    required BuildContext context,
    required Palette p,
    required List<Moment> trash,
    required VoidCallback onRestoreAllTrash,
    required VoidCallback onClearTrash,
    required ValueChanged<int> onRestoreTrashMoment,
    required ValueChanged<int> onDeleteTrashPermanent,
  }) {
    return [
      if (trash.isNotEmpty)
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
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final confirmed = await showGeneralDialog<bool>(
                        context: context,
                        barrierColor: Colors.black.withValues(alpha: 0.42),
                        barrierDismissible: true,
                        barrierLabel: 'Close restore confirmation',
                        transitionDuration: const Duration(milliseconds: 120),
                        pageBuilder: (_, _, _) => ActionConfirmSheet(
                          p: p,
                          title: 'Restore All Moments?'.localized(context),
                          message:
                              'This will return all items currently in the trash to your history.'
                                  .localized(context),
                          confirmLabel: 'Restore All'.localized(context),
                          icon: Icons.restore_rounded,
                        ),
                      );
                      if (confirmed == true) {
                        onRestoreAllTrash();
                      }
                    },
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: Text(
                      'Restore All'.localized(context),
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final confirmed = await showGeneralDialog<bool>(
                        context: context,
                        barrierColor: Colors.black.withValues(alpha: 0.42),
                        barrierDismissible: true,
                        barrierLabel: 'Close empty confirmation',
                        transitionDuration: const Duration(milliseconds: 120),
                        pageBuilder: (_, _, _) => ActionConfirmSheet(
                          p: p,
                          title: 'Empty Trash?'.localized(context),
                          message:
                              'Permanently delete all trash? This cannot be undone.'
                                  .localized(context),
                          confirmLabel: 'Empty'.localized(context),
                          isDestructive: true,
                          icon: Icons.delete_forever_rounded,
                        ),
                      );
                      if (confirmed == true) {
                        onClearTrash();
                      }
                    },
                    icon: const Icon(Icons.delete_forever_rounded, size: 18),
                    label: Text(
                      'Empty Trash'.localized(context),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ...() {
        if (trash.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: HIGEmptyState(
                p: p,
                icon: Icons.delete_outline_rounded,
                title: 'Trash is Empty',
                message: 'Deleted moments will appear here for 30 days.',
              ),
            ),
          ];
        }

        return [
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final moment = trash[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: p.border.withValues(alpha: 0.6)),
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
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Icon(
                          momentIcon(moment.type),
                          color: momentColor(p, moment.type),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  timeOnly(moment.timestamp),
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
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
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: p.text2, fontSize: 13),
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
                        onPressed: () => onRestoreTrashMoment(moment.id),
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
                            barrierColor: Colors.black.withValues(alpha: 0.42),
                            barrierDismissible: true,
                            barrierLabel: 'Close delete confirmation',
                            transitionDuration: const Duration(
                              milliseconds: 120,
                            ),
                            pageBuilder: (_, _, _) => ActionConfirmSheet(
                              p: p,
                              title: 'Delete Permanently?'.localized(context),
                              message: 'This moment will be erased forever.'
                                  .localized(context),
                              confirmLabel: 'Delete'.localized(context),
                              isDestructive: true,
                              icon: Icons.delete_forever_rounded,
                            ),
                          );
                          if (confirmed == true) {
                            onDeleteTrashPermanent(moment.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: trash.length),
          ),
        ];
      }(),
      const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
    ];
  }
}
