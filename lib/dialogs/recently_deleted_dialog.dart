import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';

class RecentlyDeletedDialog extends StatefulWidget {
  const RecentlyDeletedDialog({
    super.key,
    required this.p,
    required this.trashEntries,
    required this.onRestoreMoment,
    required this.onRestoreAll,
    required this.onDeletePermanent,
    required this.onClearTrash,
    this.blur = false,
  });

  final Palette p;
  final List<Moment> trashEntries;
  final Future<void> Function(int id) onRestoreMoment;
  final Future<void> Function() onRestoreAll;
  final Future<void> Function(int id) onDeletePermanent;
  final Future<void> Function() onClearTrash;
  final bool blur;

  @override
  State<RecentlyDeletedDialog> createState() => _RecentlyDeletedDialogState();
}

class _RecentlyDeletedDialogState extends State<RecentlyDeletedDialog> {
  late List<Moment> _trash;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _trash = List.from(widget.trashEntries);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmRestoreAll() async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close restore confirmation',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ActionConfirmSheet(
        p: widget.p,
        title: 'Restore All Moments?'.localized(context),
        message:
            'This will return all items currently in the trash to your history.'
                .localized(context),
        confirmLabel: 'Restore All'.localized(context),
        icon: Icons.restore_rounded,
      ),
    );

    if (confirmed == true) {
      await widget.onRestoreAll();
      setState(() => _trash.clear());
    }
  }

  Future<void> _confirmEmptyTrash() async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close empty confirmation',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ActionConfirmSheet(
        p: widget.p,
        title: 'Empty Trash?'.localized(context),
        message:
            'This will permanently delete all moments in the trash. This action cannot be undone.'
                .localized(context),
        confirmLabel: 'Empty Trash'.localized(context),
        isDestructive: true,
        icon: Icons.delete_forever_rounded,
      ),
    );

    if (confirmed == true) {
      await widget.onClearTrash();
      setState(() => _trash.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return AppSheet(
      p: p,
      title: 'Trash Bin'.localized(context),
      blur: widget.blur,
      docked: true,
      onBack: () => Navigator.pop(context),
      controller: _scrollController,
      showLargeTitle: true,
      removeBottomPadding: true,
      child: SizedBox(
        width: 410,
        height: math.min(MediaQuery.sizeOf(context).height * 0.75, 680),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: spacing4),
                child: AppSheetLargeTitle(
                  p: p,
                  title: 'Trash Bin'.localized(context),
                  scrollController: _scrollController,
                ),
              ),
            ),

            if (_trash.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
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
                          onPressed: _confirmRestoreAll,
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
                          onPressed: _confirmEmptyTrash,
                          icon: const Icon(
                            Icons.delete_forever_rounded,
                            size: 18,
                          ),
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

            if (_trash.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: p.surface2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: p.text3,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Trash is Empty'.localized(context),
                        style: TextStyle(
                          color: p.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Deleted moments will appear here for easy restoration.'
                            .localized(context),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: p.surface2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: p.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Items auto-delete permanently after 30 days'
                                  .localized(context),
                              style: TextStyle(
                                color: p.text3,
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
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final moment = _trash[index];
                  final formattedTime = timeOnly(moment.timestamp);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.6),
                        ),
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
                                      formattedTime,
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
                                    style: TextStyle(
                                      color: p.text2,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Restore'.localized(context),
                            icon: Icon(
                              Icons.restore_rounded,
                              color: p.text2,
                              size: 20,
                            ),
                            onPressed: () async {
                              await widget.onRestoreMoment(moment.id);
                              setState(() {
                                _trash.removeWhere((m) => m.id == moment.id);
                              });
                            },
                          ),
                          IconButton(
                            tooltip: 'Delete Permanently'.localized(context),
                            icon: Icon(
                              Icons.delete_forever_rounded,
                              color: p.text2,
                              size: 20,
                            ),
                            onPressed: () async {
                              final confirmed = await showGeneralDialog<bool>(
                                context: context,
                                barrierColor: Colors.black.withValues(
                                  alpha: 0.42,
                                ),
                                barrierDismissible: true,
                                barrierLabel: 'Close delete confirmation',
                                transitionDuration: const Duration(
                                  milliseconds: 120,
                                ),
                                pageBuilder: (_, _, _) => ActionConfirmSheet(
                                  p: widget.p,
                                  title: 'Delete Permanently?'.localized(
                                    context,
                                  ),
                                  message: 'This moment will be erased forever.'
                                      .localized(context),
                                  confirmLabel: 'Delete'.localized(context),
                                  isDestructive: true,
                                  icon: Icons.delete_forever_rounded,
                                ),
                              );
                              if (confirmed == true) {
                                await widget.onDeletePermanent(moment.id);
                                setState(() {
                                  _trash.removeWhere((m) => m.id == moment.id);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _trash.length),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
}
