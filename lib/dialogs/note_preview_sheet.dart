import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/common_elements.dart';

/// Item representing a note for linear navigation in [NotePreviewSheet].
class NotePreviewItem {
  const NotePreviewItem({
    required this.note,
    this.title = 'Note Preview',
    this.category,
    this.dateStr,
    this.onEdit,
  });

  final String note;
  final String title;
  final String? category;
  final String? dateStr;
  final VoidCallback? onEdit;
}

/// Read-only note preview bottom sheet with full text viewing, interactive links,
/// safe external departure confirmation dialog, copying, previous/next note stepping, and edit action.
class NotePreviewSheet extends StatefulWidget {
  const NotePreviewSheet({
    super.key,
    required this.p,
    required this.note,
    required this.title,
    this.category,
    this.onEdit,
    this.dateStr,
    this.items,
    this.initialIndex = 0,
    this.onIndexChanged,
  });

  final Palette p;
  final String note;
  final String title;
  final String? category;
  final VoidCallback? onEdit;
  final String? dateStr;
  final List<NotePreviewItem>? items;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required String note,
    required String title,
    String? category,
    VoidCallback? onEdit,
    String? dateStr,
    List<NotePreviewItem>? items,
    int initialIndex = 0,
    ValueChanged<int>? onIndexChanged,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: kTelegramSpringSheetAnimation,
      builder: (ctx) => NotePreviewSheet(
        p: p,
        note: note,
        title: title,
        category: category,
        onEdit: onEdit,
        dateStr: dateStr,
        items: items,
        initialIndex: initialIndex,
        onIndexChanged: onIndexChanged,
      ),
    );
  }

  @override
  State<NotePreviewSheet> createState() => _NotePreviewSheetState();
}

class _NotePreviewSheetState extends State<NotePreviewSheet> {
  final List<TapGestureRecognizer> _recognizers = [];
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (widget.items != null && widget.items!.isNotEmpty) {
      _currentIndex = _currentIndex.clamp(0, widget.items!.length - 1);
    }
  }

  void _prevNote() {
    if (widget.items != null && _currentIndex > 0) {
      HapticFeedback.selectionClick();
      setState(() {
        _clearRecognizers();
        _currentIndex--;
      });
      widget.onIndexChanged?.call(_currentIndex);
    }
  }

  void _nextNote() {
    if (widget.items != null && _currentIndex < widget.items!.length - 1) {
      HapticFeedback.selectionClick();
      setState(() {
        _clearRecognizers();
        _currentIndex++;
      });
      widget.onIndexChanged?.call(_currentIndex);
    }
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  static final RegExp _inlineTokenRegex = RegExp(
    r'(\[([^\]]+)\]\((https?://[^\s)]+|www\.[^\s)]+)\))|' // 1: [label](url), 2: label, 3: url
    r'(https?://[^\s]+|www\.[^\s]+)|' // 4: raw url
    r'(\*\*\*(?:[^\s*](?:[^*\n]*?[^\s*])?)\*\*\*)|' // 5: ***bold italic***
    r'(\*\*(?:[^\s*](?:[^*\n]*?[^\s*])?)\*\*)|' // 6: **bold**
    r'(\*(?:[^\s*](?:[^*\n]*?[^\s*])?)\*)|' // 7: *italic*
    r'(`(?:[^`\n]+?)`)|' // 8: `code`
    r'(~~(?:[^\s~](?:[^~\n]*?[^\s~])?)~~)|' // 9: ~~strike~~
    r'(#[a-zA-Z0-9_\u0900-\u097F\u0080-\uFFFF]+)', // 10: #hashtag
    caseSensitive: false,
  );

  static String _cleanNoteBody(String note) {
    if (note.isEmpty) return '';
    // Strip standalone hashtags (e.g. #focus), but preserve Markdown headers like '# Heading'
    final withoutTags = note.replaceAll(
      RegExp(r'(?:^|\s)#[a-zA-Z0-9_\u0900-\u097F\u0080-\uFFFF]+'),
      '',
    );
    final lines = withoutTags.split('\n').map((l) => l.trimRight()).toList();
    while (lines.isNotEmpty && lines.first.trim().isEmpty) {
      lines.removeAt(0);
    }
    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }
    return lines.join('\n');
  }

  List<InlineSpan> _buildInlineSpans(
    String line,
    TextStyle baseStyle,
    Palette p,
  ) {
    if (line.isEmpty) return const [];

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in _inlineTokenRegex.allMatches(line)) {
      if (match.start > lastIndex) {
        final plain = line.substring(lastIndex, match.start);
        spans.add(TextSpan(text: plain, style: baseStyle));
      }

      final matchedText = match.group(0)!;

      if (match.group(1) != null &&
          match.group(2) != null &&
          match.group(3) != null) {
        // [label](url)
        var displayLabel = match.group(2)!;
        var targetUrl = match.group(3)!;
        if (targetUrl.toLowerCase().startsWith('www.')) {
          targetUrl = 'https://$targetUrl';
        }

        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            AppHaptics.tap();
            openExternalLinkSafely(context, p: widget.p, url: targetUrl);
          };
        _recognizers.add(recognizer);

        spans.add(
          TextSpan(
            text: displayLabel,
            style: baseStyle.copyWith(
              color: p.accent,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: p.accent,
            ),
            recognizer: recognizer,
          ),
        );
      } else if (match.group(4) != null) {
        // Raw URL
        String urlCandidate = matchedText;
        String trailing = '';
        while (urlCandidate.isNotEmpty &&
            (urlCandidate.endsWith('.') ||
                urlCandidate.endsWith(',') ||
                urlCandidate.endsWith(';') ||
                urlCandidate.endsWith(')'))) {
          trailing = urlCandidate[urlCandidate.length - 1] + trailing;
          urlCandidate = urlCandidate.substring(0, urlCandidate.length - 1);
        }

        String targetUrl = urlCandidate;
        if (targetUrl.toLowerCase().startsWith('www.')) {
          targetUrl = 'https://$targetUrl';
        }

        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            AppHaptics.tap();
            openExternalLinkSafely(context, p: widget.p, url: targetUrl);
          };
        _recognizers.add(recognizer);

        spans.add(
          TextSpan(
            text: urlCandidate,
            style: baseStyle.copyWith(
              color: p.accent,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: p.accent,
            ),
            recognizer: recognizer,
          ),
        );

        if (trailing.isNotEmpty) {
          spans.add(TextSpan(text: trailing, style: baseStyle));
        }
      } else if (match.group(5) != null) {
        // ***bold italic*** -> bold & italic without ***
        final inner = matchedText.substring(3, matchedText.length - 3);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: p.text,
            ),
          ),
        );
      } else if (match.group(6) != null) {
        // **bold** -> bold without **
        final inner = matchedText.substring(2, matchedText.length - 2);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
        );
      } else if (match.group(7) != null) {
        // *italic* -> italic without *
        final inner = matchedText.substring(1, matchedText.length - 1);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(8) != null) {
        // `code` -> monospace without backticks
        final inner = matchedText.substring(1, matchedText.length - 1);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(
              fontFamily: 'monospace',
              letterSpacing: -0.2,
              color: p.accent,
              backgroundColor: p.surface3.withValues(alpha: 0.8),
            ),
          ),
        );
      } else if (match.group(9) != null) {
        // ~~strike~~ -> strikethrough without ~~
        final inner = matchedText.substring(2, matchedText.length - 2);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(
              decoration: TextDecoration.lineThrough,
              color: p.text3,
            ),
          ),
        );
      } else if (match.group(10) != null) {
        // #hashtag
        spans.add(
          TextSpan(
            text: matchedText,
            style: baseStyle.copyWith(
              color: p.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: matchedText, style: baseStyle));
      }

      lastIndex = match.end;
    }

    if (lastIndex < line.length) {
      spans.add(TextSpan(text: line.substring(lastIndex), style: baseStyle));
    }

    return spans;
  }

  Widget _buildFormattedContent(String text, TextStyle baseStyle, Palette p) {
    _clearRecognizers();
    if (text.isEmpty) {
      return Text(
        'No text in note.',
        style: baseStyle.copyWith(color: p.text3, fontStyle: FontStyle.italic),
      );
    }

    final lines = text.split('\n');
    final List<Widget> children = [];

    final headingStyle1 = baseStyle.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: p.text,
      height: 1.35,
    );
    final headingStyle2 = baseStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: p.text,
      height: 1.35,
    );
    final headingStyle3 = baseStyle.copyWith(
      fontSize: 14.5,
      fontWeight: FontWeight.w700,
      color: p.text,
      height: 1.35,
    );
    final checkedStyle = baseStyle.copyWith(
      decoration: TextDecoration.lineThrough,
      color: p.text3,
    );
    final quoteStyle = baseStyle.copyWith(
      color: p.text2,
      fontStyle: FontStyle.italic,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      // Empty line / paragraph separator
      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      // Horizontal Divider: *** or --- or * * * or ___
      if (trimmed == '***' ||
          trimmed == '---' ||
          trimmed == '* * *' ||
          trimmed == '___') {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(
              color: p.border.withValues(alpha: 0.5),
              height: 1,
              thickness: 1,
            ),
          ),
        );
        continue;
      }

      // Headings: #, ##, ###
      if (line.startsWith('# ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text.rich(
              TextSpan(
                children: _buildInlineSpans(
                  line.substring(2),
                  headingStyle1,
                  p,
                ),
              ),
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('## ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 3.0),
            child: Text.rich(
              TextSpan(
                children: _buildInlineSpans(
                  line.substring(3),
                  headingStyle2,
                  p,
                ),
              ),
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('### ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
            child: Text.rich(
              TextSpan(
                children: _buildInlineSpans(
                  line.substring(4),
                  headingStyle3,
                  p,
                ),
              ),
            ),
          ),
        );
        continue;
      }

      // Checklists: - [x] or - [ ] or * [x] or * [ ]
      if (line.startsWith('- [x] ') ||
          line.startsWith('- [X] ') ||
          line.startsWith('* [x] ') ||
          line.startsWith('* [X] ')) {
        final content = line.substring(6);
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.5, right: 8.0),
                  child: Icon(
                    Icons.check_box_rounded,
                    size: 16,
                    color: p.accent,
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _buildInlineSpans(content, checkedStyle, p),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('- [ ] ') || line.startsWith('* [ ] ')) {
        final content = line.substring(6);
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.5, right: 8.0),
                  child: Icon(
                    Icons.check_box_outline_blank_rounded,
                    size: 16,
                    color: p.text3,
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _buildInlineSpans(content, baseStyle, p),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Bullet lists: - , * , •
      if (line.startsWith('- ') ||
          line.startsWith('* ') ||
          line.startsWith('• ')) {
        final content = line.substring(2);
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7.0, right: 8.0),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: p.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _buildInlineSpans(content, baseStyle, p),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Numbered lists: e.g. 1. , 2.
      final numMatch = RegExp(r'^(\d+\.)\s+').firstMatch(line);
      if (numMatch != null) {
        final prefix = numMatch.group(0)!;
        final numLabel = numMatch.group(1)!;
        final content = line.substring(prefix.length);
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Text(
                    numLabel,
                    style: baseStyle.copyWith(
                      color: p.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _buildInlineSpans(content, baseStyle, p),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Blockquotes: >
      if (line.startsWith('> ')) {
        final content = line.substring(2);
        children.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3.0),
            padding: const EdgeInsets.only(left: 10.0, top: 2.0, bottom: 2.0),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: p.accent.withValues(alpha: 0.6),
                  width: 3,
                ),
              ),
            ),
            child: Text.rich(
              TextSpan(children: _buildInlineSpans(content, quoteStyle, p)),
            ),
          ),
        );
        continue;
      }

      // Standard text line
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: Text.rich(
            TextSpan(children: _buildInlineSpans(line, baseStyle, p)),
          ),
        ),
      );
    }

    return SelectionArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final currentItem = (widget.items != null && widget.items!.isNotEmpty)
        ? widget.items![_currentIndex]
        : NotePreviewItem(
            note: widget.note,
            title: widget.title,
            category: widget.category,
            dateStr: widget.dateStr,
            onEdit: widget.onEdit,
          );

    final cleanNote = currentItem.note.trim();
    final rawTags = NoteTagExtractor.extractHashtags(cleanNote);
    final catLower = (currentItem.category ?? '').toLowerCase().trim();
    final tags = rawTags
        .where((t) => t.toLowerCase().replaceAll('#', '').trim() != catLower)
        .toSet()
        .toList();
    final cleanBody = _cleanNoteBody(cleanNote);
    final displayText = cleanBody.isNotEmpty
        ? cleanBody
        : (cleanNote.isEmpty ? 'No text in note.' : cleanNote);

    final baseStyle = TextStyle(
      color: p.text,
      fontSize: 15,
      height: 1.45,
      fontWeight: FontWeight.w500,
    );

    final bool hasMultiple = widget.items != null && widget.items!.length > 1;

    return AppSheet(
      p: p,
      title: currentItem.title,
      trailingAction: hasMultiple
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _currentIndex > 0 ? _prevNote : null,
                  behavior: HitTestBehavior.opaque,
                  child: Opacity(
                    opacity: _currentIndex > 0 ? 1.0 : 0.35,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.surface3,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 20,
                        color: p.text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface3,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: p.border.withValues(alpha: 0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${_currentIndex + 1} of ${widget.items!.length}',
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _currentIndex < widget.items!.length - 1
                      ? _nextNote
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: Opacity(
                    opacity: _currentIndex < widget.items!.length - 1
                        ? 1.0
                        : 0.35,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.surface3,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: p.text,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentItem.category != null ||
              currentItem.dateStr != null ||
              tags.isNotEmpty) ...[
            Row(
              children: [
                if (currentItem.category != null &&
                    currentItem.category!.trim().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: p.accent.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      currentItem.category!,
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (currentItem.dateStr != null)
                  Text(
                    currentItem.dateStr!,
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map((t) {
                  final actTag = TagService.instance.findActivityTag(t);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: p.border.withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          actTag?.icon ?? Icons.label_rounded,
                          size: 11,
                          color: p.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          actTag?.label ?? TagService.stripHash(t),
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: spacing12),
          ],

          // Note text card with rich markdown formatting, interactive links, safe departure dialog & horizontal swipe
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < -150) {
                  _nextNote();
                } else if (details.primaryVelocity! > 150) {
                  _prevNote();
                }
              }
            },
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 340),
              padding: const EdgeInsets.all(spacing16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border.withValues(alpha: 0.6)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildFormattedContent(displayText, baseStyle, p),
              ),
            ),
          ),

          const SizedBox(height: spacing16),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.text2,
                    side: BorderSide(color: p.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: cleanNote));
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.content_paste_rounded, size: 16),
                  label: const Text('Copy Note'),
                ),
              ),
              if (currentItem.onEdit != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      currentItem.onEdit!();
                    },
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text(
                      'Edit Note',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Daily Review Linear Navigation Bar (< [ N of Total ] >)
          if (hasMultiple) ...[
            const SizedBox(height: spacing12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _currentIndex > 0 ? _prevNote : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 46,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _currentIndex > 0
                            ? p.surface3
                            : p.surface2.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: p.border.withValues(
                            alpha: _currentIndex > 0 ? 0.75 : 0.25,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: _currentIndex > 0
                            ? p.text
                            : p.text3.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: p.border.withValues(alpha: 0.55),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${_currentIndex + 1} of ${widget.items!.length}',
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _currentIndex < widget.items!.length - 1
                        ? _nextNote
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 46,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _currentIndex < widget.items!.length - 1
                            ? p.surface3
                            : p.surface2.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: p.border.withValues(
                            alpha: _currentIndex < widget.items!.length - 1
                                ? 0.75
                                : 0.25,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: _currentIndex < widget.items!.length - 1
                            ? p.text
                            : p.text3.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
