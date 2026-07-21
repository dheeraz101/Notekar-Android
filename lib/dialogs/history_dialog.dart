import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/calendar_dialog.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/moment_tile.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class HistoryDialog extends StatefulWidget {
  const HistoryDialog({
    super.key,
    required this.p,
    required this.entries,
    required this.compactRows,
    required this.largeText,
    required this.minimalMomentOptions,
    required this.confirmDelete,
    required this.onDelete,
    required this.onRestore,
    required this.onUpdateNote,
    required this.onDuration,
    this.blur = false,
  });

  final Palette p;
  final List<Moment> entries;
  final bool compactRows;
  final bool largeText;
  final bool minimalMomentOptions;
  final bool confirmDelete;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(Moment entry) onRestore;
  final Future<void> Function(int id, String note) onUpdateNote;
  final void Function(Moment a, Moment b) onDuration;
  final bool blur;

  @override
  State<HistoryDialog> createState() => _HistoryDialogState();
}



class _HistoryDialogState extends State<HistoryDialog> {
  static const _pageSize = 100;
  String _filter = 'all';
  String? _selectedDateKey;
  final List<Moment> _selected = [];
  late List<Moment> _entries;
  late Set<String> _availableDateKeys;
  String? _notice;
  VoidCallback? _noticeUndo;
  Timer? _noticeTimer;
  int _visibleCount = _pageSize;
  int? _pendingDeleteId;
  final _scrollController = ScrollController();

  // Memoized lists
  List<Moment> _filteredEntries = [];
  List<HistoryListItem> _listItems = [];

  @override
  void initState() {
    super.initState();
    _entries = List<Moment>.from(widget.entries);
    _availableDateKeys = _entries.map((entry) => entry.date).toSet();
    _rebuildMemoizedLists();
  }

  void _rebuildMemoizedLists() {
    final today = dateKey(DateTime.now());
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    _filteredEntries = _entries.where((e) {
      if (_filter == 'today') return e.date == today;
      if (_filter == 'week') {
        return DateTime.fromMillisecondsSinceEpoch(
          e.timestamp,
        ).isAfter(weekAgo);
      }
      if (_filter == 'date') return e.date == _selectedDateKey;
      if (_filter == 'in') return e.type == 'in';
      if (_filter == 'out') return e.type == 'out';
      if (_filter == 'single') return e.type == 'single';
      if (_filter == 'notes') return e.note.isNotEmpty;
      return true;
    }).toList();

    _updateVisibleItems();
  }

  void _updateVisibleItems() {
    final rows = _filteredEntries.take(_visibleCount).toList();
    final items = <HistoryListItem>[];
    String? lastLabel;
    for (final row in rows) {
      final label = historySectionLabel(row.timestamp);
      if (label != lastLabel) {
        items.add(HistoryListItem.header(label));
        lastLabel = label;
      }
      items.add(HistoryListItem.moment(row));
    }
    _listItems = items;
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _showNotice(String text, {VoidCallback? onUndo}) {
    _noticeTimer?.cancel();
    setState(() {
      _notice = text;
      _noticeUndo = onUndo;
    });
    _noticeTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _notice = null;
          _noticeUndo = null;
        });
      }
    });
  }

  bool get _hasOlderRows => _visibleCount < _filteredEntries.length;

  IconData get _emptyIcon {
    return switch (_filter) {
      'today' => Icons.today_rounded,
      'week' => Icons.date_range_rounded,
      'date' => Icons.event_busy_rounded,
      'in' => Icons.login_rounded,
      'out' => Icons.logout_rounded,
      'single' => Icons.radio_button_checked_rounded,
      'notes' => Icons.speaker_notes_off_rounded,
      _ => Icons.history_toggle_off_rounded,
    };
  }

  String get _emptyTitle {
    return switch (_filter) {
      'today' => 'Nothing Today',
      'week' => 'Clean Week',
      'date' => 'Empty Date',
      'in' => 'No IN Moments',
      'out' => 'No OUT Moments',
      'single' => 'No Single Logs',
      'notes' => 'No Notes Found',
      _ => 'No History',
    };
  }

  String get _emptyMessage {
    return switch (_filter) {
      'today' => 'Your moments for today will appear here as you log them.',
      'week' => 'You haven\'t saved any moments during the last seven days.',
      'date' => 'There are no records for this specific calendar day.',
      'in' => 'IN moments are created when using Two-Way logging mode.',
      'out' => 'OUT moments complete the pair in Two-Way logging mode.',
      'single' => 'Single logs are standalone timestamps for one-shot events.',
      'notes' => 'Moments with text notes will be listed here for quick review.',
      _ => 'Start capturing moments by tapping the clock on the home screen.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasOlderRows = _hasOlderRows;

    return AppSheet(
      p: widget.p,
      title: 'History',
      docked: true,
      blur: widget.blur,
      largeText: widget.largeText,
      controller: _scrollController,
      showLargeTitle: true,
      removeBottomPadding: true,
      child: SizedBox(
        width: 410,
        height: math.min(MediaQuery.sizeOf(context).height * 0.75, 680),
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: spacing16),
                  sliver: SliverToBoxAdapter(
                    child: AppSheetLargeTitle(
                      p: widget.p,
                      title: 'History',
                      scrollController: _scrollController,
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverStickyHeaderDelegate(
                    height: 56.0 + (_selected.isNotEmpty ? 52.0 : 0.0),
                    child: Container(
                      color: widget.p.surface.withValues(
                        alpha: widget.blur ? 0.65 : 1.0,
                      ),
                      padding: const EdgeInsets.only(bottom: spacing8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: spacing16,
                                  ),
                                  child: Row(
                                    children: [
                                      for (final f in const [
                                        'all',
                                        'date',
                                        'today',
                                        'week',
                                        'in',
                                        'out',
                                        'single',
                                        'notes',
                                      ])
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: spacing8,
                                          ),
                                          child: ChipButton(
                                            p: widget.p,
                                            label:
                                                f == 'single'
                                                    ? null
                                                    : f == 'date' &&
                                                        _selectedDateKey != null
                                                    ? compactDateLabel(
                                                      _selectedDateKey!,
                                                    )
                                                    : f == 'date'
                                                    ? 'Select Date'
                                                    : filterLabel(f),
                                            icon:
                                                f == 'single'
                                                    ? Icons.arrow_upward_rounded
                                                    : null,
                                            semanticLabel:
                                                f == 'single'
                                                    ? 'Single'
                                                    : null,
                                            active: _filter == f,
                                            onTap:
                                                f == 'date'
                                                    ? (_selectedDateKey == null
                                                        ? _openDateFilter
                                                        : () {
                                                          setState(() {
                                                            _filter = 'date';
                                                            _visibleCount =
                                                                _pageSize;
                                                            _rebuildMemoizedLists();
                                                          });
                                                          if (_scrollController.hasClients) {
                                                            _scrollController.jumpTo(0.0);
                                                          }
                                                        })
                                                    : () {
                                                      setState(() {
                                                        _filter = f;
                                                        _visibleCount = _pageSize;
                                                        _rebuildMemoizedLists();
                                                      });
                                                      if (_scrollController.hasClients) {
                                                        _scrollController.jumpTo(0.0);
                                                      }
                                                    },
                                            onLongPress:
                                                f == 'date'
                                                    ? _openDateFilter
                                                    : null,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: spacing8),
                              PressableScale(
                                onTap: () {
                                  if (!_scrollController.hasClients) return;
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                  );
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: widget.p.surface2,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: widget.p.border),
                                  ),
                                  child: Icon(
                                    Icons.keyboard_double_arrow_up_rounded,
                                    color: widget.p.text2,
                                    size: 19,
                                  ),
                                ),
                              ),
                              const SizedBox(width: spacing16),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOutCubic,
                            child:
                                _selected.isEmpty
                                    ? const SizedBox.shrink()
                                    : Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        spacing16,
                                        spacing8,
                                        spacing16,
                                        0,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.p.accent.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: widget.p.accent.withValues(
                                              alpha: 0.20,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Selected ${_selected.length} of 2 for duration',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: widget.p.accent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_listItems.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: HIGEmptyState(
                      p: widget.p,
                      icon: _emptyIcon,
                      title: _emptyTitle,
                      message: _emptyMessage,
                      actionLabel: _filter == 'all' ? 'Start Logging' : 'Show All',
                      onAction: _filter == 'all' 
                        ? () => Navigator.pop(context)
                        : () {
                          setState(() {
                            _filter = 'all';
                            _visibleCount = _pageSize;
                            _rebuildMemoizedLists();
                          });
                        },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index >= _listItems.length) {
                          if (hasOlderRows) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                spacing16,
                                4,
                                spacing16,
                                8,
                              ),
                              child: PressableScale(
                                onTap:
                                    () => setState(() {
                                      _visibleCount += _pageSize;
                                      _updateVisibleItems();
                                    }),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.p.surface2,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: widget.p.border),
                                  ),
                                  child: Text(
                                    'Load older moments',
                                    style: TextStyle(
                                      color: widget.p.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return null;
                        }

                        final item = _listItems[index];
                        if (item.label != null) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              spacing16,
                              spacing12,
                              spacing16,
                              6,
                            ),
                            child: Text(
                              item.label!.toUpperCase(),
                              style: TextStyle(
                                color: widget.p.text3,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                fontVariations: const [FontVariation('wght', 800)],
                                letterSpacing: 0.6,
                              ),
                            ),
                          );
                        }
                        final entry = item.moment!;
                        final selected = _selected.any(
                          (item) => item.id == entry.id,
                        );
                        return Padding(
                          key: ValueKey(entry.id),
                          padding: EdgeInsets.fromLTRB(
                            spacing16,
                            0,
                            spacing16,
                            widget.compactRows ? 3 : 8,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.p.red,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Dismissible(
                              key: ValueKey('dismiss-${entry.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 18),
                                color: widget.p.red,
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                _removeEntry(entry);
                                return false;
                              },
                              onDismissed: (_) => _dismissEntry(entry),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      selected
                                          ? widget.p.surface3
                                          : widget.p.surface2,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: RepaintBoundary(
                                  child: MomentTile(
                                    p: widget.p,
                                    entry: entry,
                                    selected: selected,
                                    compact: widget.compactRows,
                                    onLongPress: () => _showMomentDetails(entry),
                                    onTap: () {
                                      setState(() {
                                        if (selected) {
                                          _selected.removeWhere(
                                            (item) => item.id == entry.id,
                                          );
                                        } else {
                                          if (_selected.length == 2) {
                                            _selected.removeAt(0);
                                          }
                                          _selected.add(entry);
                                        }
                                      });
                                      if (_selected.length == 2) {
                                        widget.onDuration(
                                          _selected[0],
                                          _selected[1],
                                        );
                                        setState(() => _selected.clear());
                                      }
                                    },
                                    onDelete: () => _removeEntry(entry),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: _listItems.length + (hasOlderRows ? 1 : 0)),
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: spacing12, // Elevated to avoid touching the navigation area
              left: 16,
              right: 16,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                reverseDuration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutBack, // Professional iOS spring curve
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(animation);
                  final scale = Tween<double>(
                    begin: 0.92,
                    end: 1.0,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slide,
                      child: ScaleTransition(
                        scale: scale,
                        child: child,
                      ),
                    ),
                  );
                },
                child: _notice == null
                    ? const SizedBox.shrink()
                    : Container(
                        key: const ValueKey('notice-bar'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.p.name == 'amoled'
                              ? const Color(0xFF121212)
                              : widget.p.surface2,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: widget.p.border.withValues(alpha: 0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: (_noticeUndo == null ? widget.p.red : widget.p.accent)
                                    .withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _noticeUndo == null ? Icons.delete_outline_rounded : Icons.info_outline_rounded,
                                color: _noticeUndo == null ? widget.p.red : widget.p.accent,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _notice!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: widget.p.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (_noticeUndo != null) ...[
                              const SizedBox(width: 10),
                              PressableScale(
                                onTap: _noticeUndo,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: widget.p.accent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Undo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeEntry(Moment entry) {
    if (widget.confirmDelete && _pendingDeleteId != entry.id) {
      setState(() => _pendingDeleteId = entry.id);
      _showNotice('Tap delete again to confirm');
      return;
    }
    NotekarHaptics.success('standard'); // History delete is an intentional success action
    setState(() {
      _entries = _entries.where((item) => item.id != entry.id).toList();
      _availableDateKeys = _entries.map((item) => item.date).toSet();
      _selected.removeWhere((item) => item.id == entry.id);
      _pendingDeleteId = null;
      _rebuildMemoizedLists();
    });
    _showNotice('Moment removed', onUndo: () => _restoreRemovedEntry(entry));
    unawaited(widget.onDelete(entry.id));
  }

  Future<void> _openDateFilter() async {
    if (_entries.isEmpty) {
      _showNotice('No moments to pick from');
      return;
    }
    final latest =
        _selectedDateKey == null
            ? DateTime.fromMillisecondsSinceEpoch(_entries.first.timestamp)
            : dateFromKey(_selectedDateKey!);
    final picked = await showGeneralDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close calendar',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder:
          (_, _, _) => MomentCalendarDialog(
            p: widget.p,
            availableDateKeys: _availableDateKeys,
            initialDate: latest,
          ),
    );
    if (picked == null) return;
    setState(() {
      _selectedDateKey = dateKey(picked);
      _filter = 'date';
      _visibleCount = _pageSize;
      _rebuildMemoizedLists();
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  void _dismissEntry(Moment entry) {
    NotekarHaptics.success('standard');
    setState(() {
      _entries = _entries.where((item) => item.id != entry.id).toList();
      _availableDateKeys = _entries.map((item) => item.date).toSet();
      _selected.removeWhere((item) => item.id == entry.id);
      _pendingDeleteId = null;
      _rebuildMemoizedLists();
    });
    _showNotice('Moment removed', onUndo: () => _restoreRemovedEntry(entry));
    unawaited(widget.onDelete(entry.id));
  }

  void _restoreRemovedEntry(Moment entry) {
    _noticeTimer?.cancel();
    setState(() {
      if (!_entries.any((item) => item.id == entry.id)) {
        _entries = [entry, ..._entries]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _availableDateKeys = _entries.map((item) => item.date).toSet();
      }
      _notice = null;
      _noticeUndo = null;
      _pendingDeleteId = null;
      _rebuildMemoizedLists();
    });
    unawaited(widget.onRestore(entry));
  }

  Future<void> _updateEntryNote(Moment entry, String note) async {
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index < 0) return;

    final updated = Moment(
      id: entry.id,
      timestamp: entry.timestamp,
      type: entry.type,
      date: entry.date,
      note: note.trim(),
    );

    setState(() {
      _entries[index] = updated;

      final selectedIndex = _selected.indexWhere((item) => item.id == entry.id);

      if (selectedIndex >= 0) {
        _selected[selectedIndex] = updated;
      }
      _rebuildMemoizedLists();
    });

    await widget.onUpdateNote(entry.id, updated.note);
  }

  Future<void> _showMomentDetails(Moment entry) async {
    HapticFeedback.selectionClick();

    await showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close moment actions',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder:
          (_, _, _) => MomentActionsDialog(
            p: widget.p,
            entry: entry,
            confirmDelete: widget.confirmDelete,
            minimal: widget.minimalMomentOptions,
            onAddOrEditNote: () async {
              Navigator.pop(context);

              final note = await showGeneralDialog<String>(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.42),
                barrierDismissible: true,
                barrierLabel: 'Close note editor',
                transitionDuration: const Duration(milliseconds: 120),
                pageBuilder:
                    (_, _, _) => NoteDialog(
                      p: widget.p,
                      initialNote: entry.note,
                      title:
                          entry.note.trim().isEmpty ? 'Add Note' : 'Edit Note',
                      saveLabel: entry.note.trim().isEmpty ? 'Add Note' : 'Save',
                      allowEmpty: false,
                    ),
              );

              if (note == null) return;

              await _updateEntryNote(entry, note);
              _showNotice(
                entry.note.trim().isEmpty ? 'Note added' : 'Note updated',
              );
            },
            onDeleteNote:
                entry.note.trim().isEmpty
                    ? null
                    : () async {
                      Navigator.pop(context);
                      final previous = entry.note;
                      await _updateEntryNote(entry, '');
                      _showNotice(
                        'Note deleted',
                        onUndo: () {
                          unawaited(_updateEntryNote(entry, previous));
                          _showNotice('Note restored');
                        },
                      );
                    },
            onDeleteMoment: () {
              Navigator.pop(context);
              _removeEntry(entry);
            },
          ),
    );
  }
}

class MomentActionsDialog extends StatefulWidget {
  const MomentActionsDialog({
    super.key,
    required this.p,
    required this.entry,
    required this.confirmDelete,
    required this.onAddOrEditNote,
    required this.onDeleteMoment,
    this.onDeleteNote,
    this.minimal = false,
  });

  final Palette p;
  final Moment entry;
  final bool confirmDelete;
  final VoidCallback onAddOrEditNote;
  final VoidCallback? onDeleteNote;
  final VoidCallback onDeleteMoment;
  final bool minimal;

  @override
  State<MomentActionsDialog> createState() => _MomentActionsDialogState();
}

class _MomentActionsDialogState extends State<MomentActionsDialog> {
  String? _pendingAction;

  void _confirmOrRun(String action, VoidCallback callback) {
    if (!widget.confirmDelete || _pendingAction == action) {
      callback();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _pendingAction = action);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final entry = widget.entry;
    final hasNote = entry.note.trim().isNotEmpty;

    if (widget.minimal) {
      return AppSheet(
        p: p,
        title: 'Moment Options',
        child: SizedBox(
          width: 430,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SettingsStatusPill(
                    p: p,
                    label: entry.type.toUpperCase(),
                    color: momentColor(p, entry.type),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${datePretty(entry.timestamp)} at '
                      '${timeOnly(entry.timestamp)}',
                      style: TextStyle(color: p.text2, fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (hasNote) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.border),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      entry.note,
                      style: TextStyle(color: p.text, height: 1.45),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MinimalActionButton(
                    p: p,
                    icon:
                        hasNote
                            ? Icons.edit_note_rounded
                            : Icons.note_add_rounded,
                    color: p.accent,
                    onTap: widget.onAddOrEditNote,
                  ),
                  if (widget.onDeleteNote != null) ...[
                    const SizedBox(width: 20),
                    _MinimalActionButton(
                      p: p,
                      icon: Icons.comments_disabled_rounded,
                      color: p.orange,
                      pending: _pendingAction == 'note',
                      onTap: () => _confirmOrRun('note', widget.onDeleteNote!),
                    ),
                  ],
                  const SizedBox(width: 20),
                  _MinimalActionButton(
                    p: p,
                    icon: Icons.delete_outline_rounded,
                    color: p.red,
                    pending: _pendingAction == 'moment',
                    onTap: () => _confirmOrRun('moment', widget.onDeleteMoment),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }

    return AppSheet(
      p: p,
      title: 'Moment Options',
      child: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SettingsStatusPill(
                  p: p,
                  label: entry.type.toUpperCase(),
                  color: momentColor(p, entry.type),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${datePretty(entry.timestamp)} at '
                    '${timeOnly(entry.timestamp)}',
                    style: TextStyle(color: p.text2, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (hasNote) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    entry.note,
                    style: TextStyle(color: p.text, height: 1.45),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: MomentOptionPill(
                    p: p,
                    icon:
                        hasNote
                            ? Icons.edit_note_rounded
                            : Icons.note_add_rounded,
                    label: hasNote ? 'Edit Note' : 'Add Note',
                    color: p.accent,
                    onTap: widget.onAddOrEditNote,
                  ),
                ),
                if (widget.onDeleteNote != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: MomentOptionPill(
                      p: p,
                      icon: Icons.comments_disabled_rounded,
                      label: _pendingAction == 'note' ? 'Confirm' : 'Delete Note',
                      color: p.orange,
                      onTap: () => _confirmOrRun('note', widget.onDeleteNote!),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            MomentOptionPill(
              p: p,
              icon: Icons.delete_outline_rounded,
              label: _pendingAction == 'moment' ? 'Confirm' : 'Delete Moment',
              color: p.red,
              fullWidth: true,
              onTap: () => _confirmOrRun('moment', widget.onDeleteMoment),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalActionButton extends StatelessWidget {
  const _MinimalActionButton({
    required this.p,
    required this.icon,
    required this.color,
    required this.onTap,
    this.pending = false,
  });

  final Palette p;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: pending ? color : color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: pending ? color : color.withValues(alpha: 0.28),
            width: 2,
          ),
        ),
        child: Icon(
          pending ? Icons.check_rounded : icon,
          color: pending ? Colors.white : color,
          size: 26,
        ),
      ),
    );
  }
}

class MomentOptionPill extends StatelessWidget {
  const MomentOptionPill({
    super.key,
    required this.p,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  final Palette p;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
