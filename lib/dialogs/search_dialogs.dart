import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

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

class _NoteSearchRow {
  const _NoteSearchRow({required this.entry, required this.searchText});

  final Moment entry;
  final String searchText;
}

class _NoteSearchContentState extends State<NoteSearchContent> {
  static const _pageSize = 100;
  final _controller = TextEditingController();
  int _visibleCount = _pageSize;
  String _query = '';
  late List<_NoteSearchRow> _searchRows;

  @override
  void initState() {
    super.initState();
    _searchRows = _buildSearchRows(widget.entries);
  }

  @override
  void didUpdateWidget(covariant NoteSearchContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.entries, widget.entries)) {
      _searchRows = _buildSearchRows(widget.entries);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Moment> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _searchRows.map((row) => row.entry).toList();
    return _searchRows
        .where((row) => row.searchText.contains(q))
        .map((row) => row.entry)
        .toList();
  }

  List<_NoteSearchRow> _buildSearchRows(List<Moment> entries) {
    return entries
        .where((entry) => entry.note.trim().isNotEmpty)
        .map(
          (entry) => _NoteSearchRow(
            entry: entry,
            searchText:
                '${entry.note} ${datePretty(entry.timestamp)} '
                        '${timeOnly(entry.timestamp)} ${entry.type}'
                    .toLowerCase(),
          ),
        )
        .toList();
  }

  List<Moment> get _visibleRows => _matches.take(_visibleCount).toList();

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;
    final hasOlderRows = _visibleCount < _matches.length;

    Widget content = Column(
      children: [
        SearchNotesBox(
          p: widget.p,
          controller: _controller,
          onChanged: (value) => setState(() {
            _query = value;
            _visibleCount = _pageSize;
          }),
          onClear: () => setState(() {
            _controller.clear();
            _query = '';
            _visibleCount = _pageSize;
          }),
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
                  padding: const EdgeInsets.only(bottom: spacing64),
                  itemCount: rows.length + (hasOlderRows ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index >= rows.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: spacing48),
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
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: widget.compactRows ? 10 : 16,
                        left: spacing16,
                        right: spacing16,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(spacing16),
                        decoration: BoxDecoration(
                          color: widget.p.surface2,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: widget.p.border.withValues(alpha: 0.6),
                            width: 0.8,
                          ),
                          boxShadow: widget.p.name == 'amoled'
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
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
                                    color: momentColor(widget.p, entry.type)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    entry.type.toUpperCase(),
                                    style: TextStyle(
                                      color: momentColor(widget.p, entry.type),
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
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
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
  });

  final Palette p;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        style: TextStyle(color: p.text, fontSize: 14),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: p.text3, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, color: p.text3, size: 18),
                ),
          hintText: 'Search notes',
          hintStyle: TextStyle(color: p.text3),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}
