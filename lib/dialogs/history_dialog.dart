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
  final bool confirmDelete;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(Moment entry) onRestore;
  final Future<void> Function(int id, String note) onUpdateNote;
  final void Function(Moment a, Moment b) onDuration;
  final bool blur;

  @override
  State<HistoryDialog> createState() => _HistoryDialogState();
}

class _NoticePill extends StatelessWidget {
  const _NoticePill({
    required this.p,
    required this.label,
    required this.color,
    this.onTap,
  });

  final Palette p;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      enabled: onTap != null,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: onTap == null ? p.text2 : color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
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

  @override
  void initState() {
    super.initState();
    _entries = List<Moment>.from(widget.entries);
    _availableDateKeys = _entries.map((entry) => entry.date).toSet();
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
    _noticeTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _notice = null;
          _noticeUndo = null;
        });
      }
    });
  }

  List<Moment> get _allRows {
    final today = dateKey(DateTime.now());
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _entries.where((e) {
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
  }

  List<Moment> get _rows => _allRows.take(_visibleCount).toList();

  List<HistoryListItem> get _items {
    final items = <HistoryListItem>[];
    String? lastLabel;
    for (final row in _rows) {
      final label = historySectionLabel(row.timestamp);
      if (label != lastLabel) {
        items.add(HistoryListItem.header(label));
        lastLabel = label;
      }
      items.add(HistoryListItem.moment(row));
    }
    return items;
  }

  bool get _hasOlderRows => _visibleCount < _allRows.length;

  String get _emptyMessage {
    return switch (_filter) {
      'today' => 'No moments today.\nTap the screen to save your first one.',
      'week' => 'No moments this week.\nYour recent logs will appear here.',
      'date' => 'No moments on this date.\nChoose another day with a dot.',
      'in' => 'No IN moments yet.\nTwo-Way mode will create them.',
      'out' => 'No OUT moments yet.\nFinish a Two-Way pair to see one.',
      'single' =>
        'No Single moments yet.\nSwitch mode when you need one-shot logs.',
      'notes' => 'No notes yet.\nLong press the screen to save a note.',
      _ => 'No moments yet.\nTap to save a moment. Long press to add a note.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final hasOlderRows = _hasOlderRows;

    final sheet = AppSheet(
      p: widget.p,
      title: 'History',
      docked: true,
      blur: widget.blur,
      controller: _scrollController,
      showLargeTitle: true,
      child: SizedBox(
        width: 430,
        height: math.min(MediaQuery.sizeOf(context).height * 0.64, 560),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, spacing48),
                itemCount: items.isEmpty
                    ? 3
                    : items.length + (hasOlderRows ? 1 : 0) + 2,
                itemBuilder: (_, index) {
                  // Index 0: Large Title
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: spacing16),
                      child: AppSheetLargeTitle(
                        p: widget.p,
                        title: 'History',
                        scrollController: _scrollController,
                      ),
                    );
                  }
                  // Index 1: Filter Row
                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: spacing16),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: spacing16),
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
                                      padding: const EdgeInsets.only(right: spacing8),
                                      child: ChipButton(
                                        p: widget.p,
                                        label: f == 'single'
                                            ? null
                                            : f == 'date' && _selectedDateKey != null
                                            ? compactDateLabel(_selectedDateKey!)
                                            : f == 'date'
                                            ? 'Select Date'
                                            : filterLabel(f),
                                        icon: f == 'single'
                                            ? Icons.arrow_upward_rounded
                                            : null,
                                        semanticLabel: f == 'single' ? 'Single' : null,
                                        active: _filter == f,
                                        onTap: f == 'date'
                                            ? (_selectedDateKey == null
                                                ? _openDateFilter
                                                : () => setState(() {
                                                      _filter = 'date';
                                                      _visibleCount = _pageSize;
                                                    }))
                                            : () => setState(() {
                                                  _filter = f;
                                                  _visibleCount = _pageSize;
                                                }),
                                        onLongPress: f == 'date' ? _openDateFilter : null,
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
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.fastEaseInToSlowEaseOut,
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
                    );
                  }

                  // Empty State
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: spacing48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _emptyMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: widget.p.text2,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: widget.p.accent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Start Logging'),
                          ),
                        ],
                      ),
                    );
                  }

                  final itemIndex = index - 2;

                  if (itemIndex >= items.length) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(spacing16, 4, spacing16, 8),
                      child: PressableScale(
                        onTap: () => setState(() {
                          _visibleCount += _pageSize;
                        }),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: widget.p.surface2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.p.border,
                            ),
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
                  final item = items[itemIndex];
                  if (item.label != null) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(spacing16 + 4, 8, spacing16 + 4, 8),
                      child: Text(
                        item.label!,
                        style: TextStyle(
                          color: widget.p.text3,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
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
                            color: selected
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
                              onLongPress: () =>
                                  _showMomentDetails(entry),
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
                },
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: _notice == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: MediaQuery.paddingOf(context).bottom + 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _NoticePill(
                            p: widget.p,
                            label: _notice!,
                            color: _noticeUndo == null
                                ? widget.p.red
                                : widget.p.accent,
                          ),
                          if (_noticeUndo != null) ...[
                            const SizedBox(width: 8),
                            _NoticePill(
                              p: widget.p,
                              label: 'Undo',
                              color: widget.p.accent,
                              onTap: _noticeUndo,
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
    if (!widget.largeText) return sheet;
    return MediaQuery(data: largerTextQuery(context), child: sheet);
  }

  void _removeEntry(Moment entry) {
    if (widget.confirmDelete && _pendingDeleteId != entry.id) {
      setState(() => _pendingDeleteId = entry.id);
      _showNotice('Tap delete again to confirm');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _entries = _entries.where((item) => item.id != entry.id).toList();
      _availableDateKeys = _entries.map((item) => item.date).toSet();
      _selected.removeWhere((item) => item.id == entry.id);
      _pendingDeleteId = null;
    });
    _showNotice('Moment removed', onUndo: () => _restoreRemovedEntry(entry));
    unawaited(widget.onDelete(entry.id));
  }

  Future<void> _openDateFilter() async {
    if (_entries.isEmpty) {
      _showNotice('No moments to pick from');
      return;
    }
    final latest = _selectedDateKey == null
        ? DateTime.fromMillisecondsSinceEpoch(_entries.first.timestamp)
        : dateFromKey(_selectedDateKey!);
    final picked = await showGeneralDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close calendar',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => MomentCalendarDialog(
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
    });
  }

  void _dismissEntry(Moment entry) {
    HapticFeedback.mediumImpact();
    setState(() {
      _entries = _entries.where((item) => item.id != entry.id).toList();
      _availableDateKeys = _entries.map((item) => item.date).toSet();
      _selected.removeWhere((item) => item.id == entry.id);
      _pendingDeleteId = null;
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
      pageBuilder: (_, _, _) => MomentActionsDialog(
        p: widget.p,
        entry: entry,
        confirmDelete: widget.confirmDelete,
        onAddOrEditNote: () async {
          Navigator.pop(context);

          final note = await showGeneralDialog<String>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.42),
            barrierDismissible: true,
            barrierLabel: 'Close note editor',
            transitionDuration: const Duration(milliseconds: 120),
            pageBuilder: (_, _, _) => NoteDialog(
              p: widget.p,
              initialNote: entry.note,
              title: entry.note.trim().isEmpty ? 'Add Note' : 'Edit Note',
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
        onDeleteNote: entry.note.trim().isEmpty
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
  });

  final Palette p;
  final Moment entry;
  final bool confirmDelete;
  final VoidCallback onAddOrEditNote;
  final VoidCallback? onDeleteNote;
  final VoidCallback onDeleteMoment;

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
                    icon: hasNote
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
                      label: _pendingAction == 'note'
                          ? 'Confirm'
                          : 'Delete Note',
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
