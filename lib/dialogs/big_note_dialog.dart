import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dedicated Apple HIG Journal / Big Note canvas for expansive thoughts,
/// reflections, and long-form notes attached to moments.
class BigNoteDialog extends StatefulWidget {
  const BigNoteDialog({
    super.key,
    required this.p,
    this.initialNote = '',
    this.title = 'Big Note',
    this.saveLabel = 'Done',
    this.allowEmpty = true,
    this.blur = false,
    this.largeText = false,
  });

  final Palette p;
  final String initialNote;
  final String title;
  final String saveLabel;
  final bool allowEmpty;
  final bool blur;
  final bool largeText;

  @override
  State<BigNoteDialog> createState() => _BigNoteDialogState();
}

class _BigNoteDialogState extends State<BigNoteDialog> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  List<String> _tags = const [
    '#work',
    '#study',
    '#play',
    '#health',
    '#focus',
    '#routine',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _loadCustomTags();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadCustomTags() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('custom_note_tags');
    if (saved != null && saved.isNotEmpty) {
      if (mounted) setState(() => _tags = saved);
    }
  }

  Future<void> _saveCustomTags(List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_note_tags', tags);
    if (mounted) setState(() => _tags = tags);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _controller.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  void _insertTag(String tag) {
    HapticFeedback.selectionClick();
    final text = _controller.text;
    final spacer = text.isEmpty || text.endsWith(' ') || text.endsWith('\n')
        ? ''
        : ' ';
    final newText = '$text$spacer$tag ';
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  Future<void> _showAddTagDialog() async {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();
    final created = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.p.surface2,
        title: Text(
          'New Hashtag',
          style: TextStyle(
            color: widget.p.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: TextStyle(color: widget.p.text),
          decoration: InputDecoration(
            hintText: 'tag (e.g. #journal, #gym)',
            hintStyle: TextStyle(color: widget.p.text3),
            prefixText: textController.text.startsWith('#') ? null : '#',
            prefixStyle: TextStyle(
              color: widget.p.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: widget.p.text2)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.p.accent),
            onPressed: () {
              final raw = textController.text.trim();
              if (raw.isEmpty) return;
              final clean = raw.startsWith('#') ? raw : '#$raw';
              Navigator.pop(ctx, clean);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (created != null && created.isNotEmpty && !_tags.contains(created)) {
      final updated = List<String>.from(_tags)..add(created);
      await _saveCustomTags(updated);
    }
  }

  Future<void> _confirmDeleteTag(String tag) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.p.surface2,
        title: Text(
          'Remove $tag?',
          style: TextStyle(
            color: widget.p.text,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Do you want to remove this tag from your quick list?',
          style: TextStyle(color: widget.p.text2, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: widget.p.text2)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.p.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final updated = List<String>.from(_tags)..remove(tag);
      await _saveCustomTags(updated);
    }
  }

  void _insertSnippet(String snippet) {
    HapticFeedback.selectionClick();
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, snippet);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
  }

  void _insertTimestamp() {
    final now = DateTime.now();
    final timeStr =
        '[${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}] ';
    _insertSnippet(timeStr);
  }

  void _save() {
    HapticFeedback.mediumImpact();
    final text = _controller.text.trim();
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Glass(
        p: p,
        blur: widget.blur,
        radius: 24,
        padding: EdgeInsets.zero,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
          decoration: BoxDecoration(
            color: p.surface.withValues(alpha: widget.blur ? 0.85 : 0.98),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: p.border.withValues(alpha: 0.6),
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              // Apple HIG Navigation Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: p.border.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PressableScale(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          widget.allowEmpty ? 'Cancel' : 'Dismiss',
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.doc_text,
                          size: 16,
                          color: p.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    PressableScale(
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: p.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          widget.saveLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Metadata bar (Date, Word Count, Character Count)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                color: p.surface2.withValues(alpha: 0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      datePretty(DateTime.now().millisecondsSinceEpoch),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controller,
                      builder: (context, val, _) {
                        final charCount = val.text.length;
                        final wordCount = _wordCount;
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: p.surface3,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$wordCount words',
                                style: TextStyle(
                                  color: p.text2,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: p.surface3,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$charCount chars',
                                style: TextStyle(
                                  color: p.text2,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Expansive Writing Canvas
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    style: TextStyle(
                      color: p.text,
                      fontSize: widget.largeText ? 17 : 15.5,
                      height: 1.45,
                      letterSpacing: 0.1,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write in depth without limits...',
                      hintStyle: TextStyle(
                        color: p.text3.withValues(alpha: 0.7),
                        fontSize: 15.5,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              // Apple Notes Accessory Toolbar (Tags + Quick Insert Actions)
              Container(
                padding: EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  math.max(8.0, bottomInset > 0 ? 8.0 : 12.0),
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  border: Border(
                    top: BorderSide(
                      color: p.border.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Horizontal scrollable tags with Add button
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          for (final tag in _tags)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: PressableScale(
                                onTap: () => _insertTag(tag),
                                onLongPress: () => _confirmDeleteTag(tag),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.surface,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: p.border.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: p.text,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Add tag button
                          PressableScale(
                            onTap: _showAddTagDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: p.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: p.accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.add,
                                    size: 12,
                                    color: p.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tag',
                                    style: TextStyle(
                                      color: p.accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Quick Markdown/Format Actions
                    Row(
                      children: [
                        _buildQuickAction(
                          icon: CupertinoIcons.time,
                          label: 'Time',
                          onTap: _insertTimestamp,
                        ),
                        const SizedBox(width: 6),
                        _buildQuickAction(
                          icon: CupertinoIcons.list_bullet,
                          label: 'Bullet',
                          onTap: () => _insertSnippet('\n• '),
                        ),
                        const SizedBox(width: 6),
                        _buildQuickAction(
                          icon: CupertinoIcons.check_mark_circled,
                          label: 'Checklist',
                          onTap: () => _insertSnippet('\n[ ] '),
                        ),
                        const Spacer(),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _controller,
                          builder: (context, val, _) {
                            if (val.text.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return PressableScale(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _controller.clear();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: p.text3,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.p.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: widget.p.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: widget.p.text2),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: widget.p.text2,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
