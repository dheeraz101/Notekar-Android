import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_date_picker_sheet.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/timeline_filter_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/search_index_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/timeline_media_attachment_card.dart';
import 'package:notekar/widgets/timeline_voice_player_pill.dart';

class NoteSearchDialog extends StatefulWidget {
  const NoteSearchDialog({
    super.key,
    required this.p,
    required this.entries,
    required this.compactRows,
  });

  final Palette p;
  final List<Moment> entries;
  final bool compactRows;

  @override
  State<NoteSearchDialog> createState() => _NoteSearchDialogState();
}

class _NoteSearchDialogState extends State<NoteSearchDialog> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      p: widget.p,
      title: 'Search Notes',
      controller: _scrollController,
      showLargeTitle: false,
      removeBottomPadding: true,
      child: SizedBox(
        width: 410,
        height: math.min(MediaQuery.sizeOf(context).height * 0.68, 590),
        child: NoteSearchContent(
          p: widget.p,
          entries: widget.entries,
          compactRows: widget.compactRows,
          scrollController: _scrollController,
        ),
      ),
    );
  }
}

class NoteSearchContent extends StatefulWidget {
  const NoteSearchContent({
    super.key,
    required this.p,
    required this.entries,
    required this.compactRows,
    this.height,
    this.scrollController,
  });

  final Palette p;
  final List<Moment> entries;
  final bool compactRows;
  final double? height;
  final ScrollController? scrollController;

  @override
  State<NoteSearchContent> createState() => _NoteSearchContentState();
}

class _NoteSearchContentState extends State<NoteSearchContent> {
  static const _pageSize = 100;
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _visibleCount = _pageSize;
  String _query = '';
  TimelineFilterCriteria _filterCriteria = const TimelineFilterCriteria();
  String _filter = 'all';
  String? _selectedDateKey;
  final Set<int> _manuallyExpandedImageIds = {};
  final Set<int> _manuallyCollapsedImageIds = {};
  final Set<int> _manuallyExpandedVoiceIds = {};
  final Set<int> _manuallyCollapsedVoiceIds = {};
  final List<Moment> _selectedMoments = [];
  late List<String> _knownTags;

  @override
  void initState() {
    super.initState();
    _knownTags = TagService.instance.getAllKnownTags(widget.entries);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant NoteSearchContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.entries, widget.entries)) {
      _knownTags = TagService.instance.getAllKnownTags(widget.entries);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isImageCollapsed(int id) {
    if (_manuallyExpandedImageIds.contains(id)) return false;
    if (_manuallyCollapsedImageIds.contains(id)) return true;
    return true;
  }

  void _toggleImageCollapse(int id) {
    setState(() {
      if (_isImageCollapsed(id)) {
        _manuallyCollapsedImageIds.remove(id);
        _manuallyExpandedImageIds.add(id);
      } else {
        _manuallyExpandedImageIds.remove(id);
        _manuallyCollapsedImageIds.add(id);
      }
    });
  }

  bool _isVoiceCollapsed(int id) {
    if (_manuallyExpandedVoiceIds.contains(id)) return false;
    if (_manuallyCollapsedVoiceIds.contains(id)) return true;
    return true;
  }

  void _toggleVoiceCollapse(int id) {
    setState(() {
      if (_isVoiceCollapsed(id)) {
        _manuallyCollapsedVoiceIds.remove(id);
        _manuallyExpandedVoiceIds.add(id);
      } else {
        _manuallyExpandedVoiceIds.remove(id);
        _manuallyCollapsedVoiceIds.add(id);
      }
    });
  }

  List<Moment> get _matches {
    var list = SearchIndexService.instance.search(
      allMoments: widget.entries,
      query: _query,
      mode: _filterCriteria.mode,
      category: _filterCriteria.category,
      hashtag: _filterCriteria.hashtag,
    );

    if (_filter == 'today') {
      final today = dateKey(DateTime.now());
      list = list.where((m) => m.date == today).toList();
    } else if (_filter == 'week') {
      final today = dateKey(DateTime.now());
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      list = list.where((m) {
        return m.date == today ||
            DateTime.fromMillisecondsSinceEpoch(m.timestamp).isAfter(weekAgo);
      }).toList();
    } else if (_filter == 'date') {
      if (_selectedDateKey != null) {
        list = list.where((m) => m.date == _selectedDateKey).toList();
      }
    } else if (_filter == 'sessions') {
      list = list.where((m) => m.type == 'in' || m.type == 'out').toList();
    } else if (_filter == 'single') {
      list = list.where((m) => m.type == 'single').toList();
    } else if (_filter == 'notes') {
      list = list.where((m) => m.note.trim().isNotEmpty).toList();
    } else if (_filter == 'media') {
      list = list.where((m) {
        final hasImg = m.imagePath != null && m.imagePath!.isNotEmpty;
        final hasVoice = m.voicePaths.isNotEmpty;
        return hasImg || hasVoice;
      }).toList();
    }
    return list;
  }

  List<Moment> get _visibleRows => _matches.take(_visibleCount).toList();

  void _openFilterSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: widget.p.isDark ? Brightness.dark : Brightness.light,
          primaryColor: widget.p.accent,
        ),
        child: CupertinoActionSheet(
          title: Text(
            'Filter Timeline'.localized(context),
            style: TextStyle(
              color: widget.p.text,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          message: Text(
            'Select moments to display'.localized(context),
            style: TextStyle(color: widget.p.text3, fontSize: 12),
          ),
          actions: [
            for (final f in [
              'all',
              'today',
              'week',
              'sessions',
              'single',
              'notes',
              'media',
              'date',
            ])
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (f == 'date') {
                    _openDateFilter();
                  } else {
                    setState(() {
                      _filter = f;
                      _selectedDateKey = null;
                      _visibleCount = _pageSize;
                    });
                    if (widget.scrollController?.hasClients ?? false) {
                      widget.scrollController!.jumpTo(0.0);
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_filter == f) ...[
                      Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: widget.p.accent,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      switch (f) {
                        'all' => 'All Moments'.localized(context),
                        'today' => 'Today'.localized(context),
                        'week' => 'This Week'.localized(context),
                        'sessions' => 'Sessions (In/Out)'.localized(context),
                        'single' => 'Single Logs'.localized(context),
                        'notes' => 'With Notes'.localized(context),
                        'media' => 'Media (Voice/Images)'.localized(context),
                        'date' => 'Pick Specific Date...'.localized(context),
                        _ => f,
                      },
                      style: TextStyle(
                        color: _filter == f ? widget.p.accent : widget.p.text,
                        fontWeight: _filter == f
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                _openAdvancedFilter();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_filter == 'advanced' || _filterCriteria.isActive) ...[
                    Icon(Icons.check_rounded, size: 16, color: widget.p.accent),
                    const SizedBox(width: 8),
                  ],
                  Icon(Icons.tune_rounded, size: 16, color: widget.p.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Advanced'.localized(context),
                    style: TextStyle(
                      color: (_filter == 'advanced' || _filterCriteria.isActive)
                          ? widget.p.accent
                          : widget.p.text,
                      fontWeight:
                          (_filter == 'advanced' || _filterCriteria.isActive)
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel'.localized(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDateFilter() async {
    if (widget.entries.isEmpty) return;
    final latest = _selectedDateKey == null
        ? DateTime.fromMillisecondsSinceEpoch(widget.entries.first.timestamp)
        : dateFromKey(_selectedDateKey!);
    final now = DateTime.now();
    final earliest = widget.entries.isNotEmpty
        ? DateTime.fromMillisecondsSinceEpoch(widget.entries.last.timestamp)
        : now.subtract(const Duration(days: 365));

    final picked = await AppDatePickerSheet.show(
      context,
      p: widget.p,
      title: 'Pick Specific Date'.localized(context),
      initialDateTime: latest,
      mode: CupertinoDatePickerMode.date,
      minimumDate: DateTime(earliest.year, earliest.month, earliest.day),
      maximumDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
    if (picked == null) return;
    setState(() {
      _selectedDateKey = dateKey(picked);
      _filter = 'date';
      _visibleCount = _pageSize;
    });
    if (widget.scrollController?.hasClients ?? false) {
      widget.scrollController!.jumpTo(0.0);
    }
  }

  Future<void> _openAdvancedFilter() async {
    final cats = await CategoryService().getCategories();
    if (!mounted) return;
    final res = await TimelineFilterSheet.show(
      context,
      p: widget.p,
      initial: _filterCriteria,
      categories: cats,
      hashtags: _knownTags,
    );
    if (res != null) {
      setState(() {
        _filterCriteria = res;
        _filter = 'advanced';
        _visibleCount = _pageSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;
    final hasOlderRows = _visibleCount < _matches.length;

    Widget content = Column(
      children: [
        SearchNotesBox(
          p: widget.p,
          controller: _controller,
          focusNode: _focusNode,
          onChanged: (value) => setState(() {
            _query = value;
            _visibleCount = _pageSize;
          }),
          onClear: () => setState(() {
            _controller.clear();
            _query = '';
            _visibleCount = _pageSize;
          }),
          isFilterActive: _filter != 'all' || _filterCriteria.isActive,
          onTapFilter: _openFilterSheet,
        ),
        if (_selectedMoments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: widget.p.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.p.accent.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.compare_arrows_rounded,
                    color: widget.p.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '1 moment selected. Tap another to compare time.'
                          .localized(context),
                      style: TextStyle(
                        color: widget.p.accent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PressableScale(
                    onTap: () => setState(() => _selectedMoments.clear()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.p.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cancel'.localized(context),
                        style: TextStyle(
                          color: widget.p.text2,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: spacing8),
        if (_query.trim().isEmpty && rows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Text(
                  'ALL NOTES',
                  style: TextStyle(
                    color: widget.p.text3,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${rows.length} items',
                  style: TextStyle(
                    color: widget.p.text3,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: spacing4),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    _query.trim().isEmpty
                        ? 'No notes yet.'
                        : 'No notes match your search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: widget.p.text2, height: 1.4),
                  ),
                )
              : ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.only(bottom: spacing48),
                  itemCount: rows.length + (hasOlderRows ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index >= rows.length) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                          bottom: spacing48,
                        ),
                        child: PressableScale(
                          onTap: () => setState(() {
                            _visibleCount += _pageSize;
                          }),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: widget.p.surface2,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: widget.p.border),
                            ),
                            child: Text(
                              'Load older notes',
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
                    final entry = rows[index];
                    final isSelected = _selectedMoments.any(
                      (m) => m.id == entry.id,
                    );
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: widget.compactRows ? 10 : 16,
                        left: spacing16,
                        right: spacing16,
                      ),
                      child: PressableScale(
                        onTap: () {
                          if (_selectedMoments.isNotEmpty) {
                            if (_selectedMoments.any((m) => m.id == entry.id)) {
                              setState(
                                () => _selectedMoments.removeWhere(
                                  (m) => m.id == entry.id,
                                ),
                              );
                            } else {
                              final first = _selectedMoments.first;
                              setState(() => _selectedMoments.clear());
                              showTimeDifferenceDialog(
                                context,
                                p: widget.p,
                                a: first,
                                b: entry,
                              );
                            }
                          }
                        },
                        onLongPress: () {
                          HapticFeedback.heavyImpact();
                          setState(() {
                            if (_selectedMoments.any((m) => m.id == entry.id)) {
                              _selectedMoments.removeWhere(
                                (m) => m.id == entry.id,
                              );
                            } else {
                              _selectedMoments.add(entry);
                            }
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(spacing16),
                          decoration: BoxDecoration(
                            color: widget.p.surface2,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? widget.p.accent
                                  : widget.p.border.withValues(alpha: 0.6),
                              width: isSelected ? 1.5 : 0.8,
                            ),
                            boxShadow: widget.p.name == 'amoled'
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: momentColor(
                                        widget.p,
                                        entry.type,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      entry.type.toUpperCase(),
                                      style: TextStyle(
                                        color: momentColor(
                                          widget.p,
                                          entry.type,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${datePretty(entry.timestamp)} • ${timeOnly(entry.timestamp)}',
                                      style: TextStyle(
                                        color: widget.p.text3,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PressableScale(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        if (_selectedMoments.any(
                                          (m) => m.id == entry.id,
                                        )) {
                                          _selectedMoments.removeWhere(
                                            (m) => m.id == entry.id,
                                          );
                                        } else if (_selectedMoments.isEmpty) {
                                          _selectedMoments.add(entry);
                                        } else {
                                          final first = _selectedMoments.first;
                                          _selectedMoments.clear();
                                          showTimeDifferenceDialog(
                                            context,
                                            p: widget.p,
                                            a: first,
                                            b: entry,
                                          );
                                        }
                                      });
                                    },
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.compare_arrows_rounded,
                                      size: 16,
                                      color: isSelected
                                          ? widget.p.accent
                                          : widget.p.text3,
                                    ),
                                  ),
                                ],
                              ),
                              if (entry.note.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                IosEmojiText(
                                  entry.note,
                                  style: TextStyle(
                                    color: widget.p.text,
                                    fontSize: 16,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],

                              // Combined collapsed voice & photo pills on same line
                              if (_isVoiceCollapsed(entry.id) &&
                                  _isImageCollapsed(entry.id) &&
                                  entry.voicePaths.isNotEmpty &&
                                  entry.imagePath != null &&
                                  entry.imagePath!.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      TimelineVoicePlayerPill.buildCollapsedPill(
                                        p: widget.p,
                                        count: entry.voicePaths.length,
                                        onToggleCollapse: () =>
                                            _toggleVoiceCollapse(entry.id),
                                        compact: widget.compactRows,
                                      ),
                                      TimelineMediaAttachmentCard.buildCollapsedPill(
                                        p: widget.p,
                                        imagePath: entry.imagePath,
                                        onToggleCollapse: () =>
                                            _toggleImageCollapse(entry.id),
                                        compact: widget.compactRows,
                                      ),
                                    ],
                                  ),
                                )
                              else ...[
                                // Voice Memos (collapsed by default, tap to expand)
                                if (entry.voicePaths.isNotEmpty) ...[
                                  if (_isVoiceCollapsed(entry.id))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child:
                                            TimelineVoicePlayerPill.buildCollapsedPill(
                                              p: widget.p,
                                              count: entry.voicePaths.length,
                                              onToggleCollapse: () =>
                                                  _toggleVoiceCollapse(
                                                    entry.id,
                                                  ),
                                              compact: widget.compactRows,
                                            ),
                                      ),
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10.0,
                                            bottom: 4.0,
                                          ),
                                          child: PressableScale(
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              _toggleVoiceCollapse(entry.id);
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  CupertinoIcons.mic_fill,
                                                  size: 13,
                                                  color: widget.p.accent,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  '${entry.voicePaths.length} Voice Memo${entry.voicePaths.length > 1 ? "s" : ""}',
                                                  style: TextStyle(
                                                    color: widget.p.text2,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  CupertinoIcons.chevron_up,
                                                  size: 11,
                                                  color: widget.p.text3,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        for (final vp in entry.voicePaths) ...[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: TimelineVoicePlayerPill(
                                              p: widget.p,
                                              voicePath: vp,
                                              durationMs:
                                                  entry.voiceDurationMs ?? 0,
                                              compact: widget.compactRows,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                ],

                                // Photos (collapsed by default, tap to expand)
                                if (entry.imagePath != null &&
                                    entry.imagePath!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  TimelineMediaAttachmentCard(
                                    p: widget.p,
                                    imagePath: entry.imagePath!,
                                    isCollapsed: _isImageCollapsed(entry.id),
                                    onToggleCollapse: () =>
                                        _toggleImageCollapse(entry.id),
                                    compact: widget.compactRows,
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    if (widget.height != null) {
      return SizedBox(height: widget.height, child: content);
    }
    return content;
  }
}

class SearchNotesBox extends StatelessWidget {
  const SearchNotesBox({
    super.key,
    required this.p,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.focusNode,
    this.isFilterActive = false,
    this.onTapFilter,
  });

  final Palette p;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final FocusNode? focusNode;
  final bool isFilterActive;
  final VoidCallback? onTapFilter;

  @override
  Widget build(BuildContext context) {
    final searchField = Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(color: p.text, fontSize: 14),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: p.text3, size: 20),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.close_rounded, color: p.text3, size: 18),
                  ),
                ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          hintText: 'Search notes',
          hintStyle: TextStyle(color: p.text3, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );

    if (onTapFilter == null) {
      return searchField;
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 8),
        PressableScale(
          onTap: onTapFilter,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isFilterActive
                  ? p.accent.withValues(alpha: 0.16)
                  : p.surface2,
              shape: BoxShape.circle,
              border: Border.all(
                color: isFilterActive ? p.accent : p.border,
                width: isFilterActive ? 1.5 : 1,
              ),
            ),
            child: Icon(
              isFilterActive ? Icons.filter_list_rounded : Icons.tune_rounded,
              size: 20,
              color: isFilterActive ? p.accent : p.text,
            ),
          ),
        ),
      ],
    );
  }
}

void showTimeDifferenceDialog(
  BuildContext context, {
  required Palette p,
  required Moment a,
  required Moment b,
  bool largeText = false,
  bool blur = false,
  bool extended = true,
}) {
  final start = math.min(a.timestamp, b.timestamp);
  final end = math.max(a.timestamp, b.timestamp);
  final duration = Duration(milliseconds: end - start);
  showGeneralDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    barrierDismissible: true,
    barrierLabel: 'Close duration',
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (_, _, _) => AppSheet(
      p: p,
      title: 'Time Between Moments'.localized(context),
      largeText: largeText,
      blur: blur,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${timeOnly(start)} - ${timeOnly(end)}',
            style: TextStyle(color: p.text2),
          ),
          const SizedBox(height: 10),
          Text(
            durationLabel(duration, extended: extended),
            style: TextStyle(
              color: p.text,
              fontSize: 44,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (duration.inHours >= 24) ...[
            const SizedBox(height: 4),
            Text(
              '(${duration.inHours}h ${duration.inMinutes.remainder(60)}m total)',
              style: TextStyle(
                color: p.text3,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Okay'.localized(context)),
          ),
        ],
      ),
    ),
  );
}
