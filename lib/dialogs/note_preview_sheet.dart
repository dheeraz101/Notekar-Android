import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/timeline_media_attachment_card.dart';
import 'package:notekar/widgets/timeline_voice_player_pill.dart';

/// Item representing a note for linear navigation in [NotePreviewSheet].
class NotePreviewItem {
  const NotePreviewItem({
    required this.note,
    this.title = 'Note Preview',
    this.category,
    this.dateStr,
    this.onEdit,
    this.imagePath,
    this.voicePath,
    this.voiceDurationMs,
    this.voicePaths,
  });

  final String note;
  final String title;
  final String? category;
  final String? dateStr;
  final VoidCallback? onEdit;
  final String? imagePath;
  final String? voicePath;
  final int? voiceDurationMs;
  final List<String>? voicePaths;
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
    this.imagePath,
    this.voicePath,
    this.voiceDurationMs,
    this.voicePaths,
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
  final String? imagePath;
  final String? voicePath;
  final int? voiceDurationMs;
  final List<String>? voicePaths;
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
    String? imagePath,
    String? voicePath,
    int? voiceDurationMs,
    List<String>? voicePaths,
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
        imagePath: imagePath,
        voicePath: voicePath,
        voiceDurationMs: voiceDurationMs,
        voicePaths: voicePaths,
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
  double _dragDelta = 0;
  bool _isCopied = false;
  Timer? _copyTimer;

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
    _copyTimer?.cancel();
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

  static final RegExp _tagRegex = RegExp(
    r'(?:^|\s)#[a-zA-Z0-9_\u0900-\u097F\u0080-\uFFFF]+',
  );

  static final RegExp _numListRegex = RegExp(r'^(\d+\.)\s+');

  static String _cleanNoteBody(String note) {
    if (note.isEmpty) return '';
    // Strip standalone hashtags (e.g. #focus), but preserve Markdown headers like '# Heading'
    final withoutTags = note.replaceAll(_tagRegex, '');
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
      fontSize: 21,
      fontWeight: FontWeight.w800,
      color: p.text,
      height: 1.35,
      letterSpacing: -0.5,
    );
    final headingStyle2 = baseStyle.copyWith(
      fontSize: 18.5,
      fontWeight: FontWeight.w700,
      color: p.text,
      height: 1.35,
      letterSpacing: -0.4,
    );
    final headingStyle3 = baseStyle.copyWith(
      fontSize: 16.5,
      fontWeight: FontWeight.w700,
      color: p.text,
      height: 1.35,
      letterSpacing: -0.3,
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
      final numMatch = _numListRegex.firstMatch(line);
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
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
            imagePath: widget.imagePath,
            voicePath: widget.voicePath,
            voiceDurationMs: widget.voiceDurationMs,
            voicePaths: widget.voicePaths,
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

    final voiceList = <String>[];
    if (currentItem.voicePaths != null && currentItem.voicePaths!.isNotEmpty) {
      voiceList.addAll(currentItem.voicePaths!);
    } else if (currentItem.voicePath != null &&
        currentItem.voicePath!.trim().isNotEmpty) {
      voiceList.addAll(
        currentItem.voicePath!
            .split('|')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty),
      );
    }

    final imageList = <String>[];
    if (currentItem.imagePath != null &&
        currentItem.imagePath!.trim().isNotEmpty) {
      imageList.addAll(
        currentItem.imagePath!
            .split('|')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty),
      );
    }

    final hasText = cleanNote.isNotEmpty;
    final hasVoice = voiceList.isNotEmpty;
    final hasPhotos = imageList.isNotEmpty;

    final baseStyle = TextStyle(
      color: p.text,
      fontSize: 17,
      height: 1.5,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
    );

    final bool hasMultiple = widget.items != null && widget.items!.length > 1;

    return AppSheet(
      p: p,
      title: currentItem.title,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => _dragDelta = 0,
        onHorizontalDragUpdate: (details) =>
            _dragDelta += details.primaryDelta ?? 0,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0.0;
          if (_dragDelta < -40 || velocity < -150) {
            _nextNote();
          } else if (_dragDelta > 40 || velocity > 150) {
            _prevNote();
          }
          _dragDelta = 0;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentItem.category != null ||
                currentItem.dateStr != null ||
                tags.isNotEmpty ||
                hasVoice ||
                hasPhotos ||
                hasMultiple) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (currentItem.category != null &&
                            currentItem.category!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: p.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: p.accent.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sell_rounded,
                                  size: 13,
                                  color: p.accent,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  currentItem.category!,
                                  style: TextStyle(
                                    color: p.accent,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (hasVoice)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: p.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: p.green.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.mic_fill,
                                  size: 12.5,
                                  color: p.green,
                                ),
                                const SizedBox(width: 4.5),
                                Text(
                                  voiceList.length > 1
                                      ? '${voiceList.length} Voices'
                                      : 'Voice Memo',
                                  style: TextStyle(
                                    color: p.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (hasPhotos)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: p.blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: p.blue.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.photo_fill,
                                  size: 12.5,
                                  color: p.blue,
                                ),
                                const SizedBox(width: 4.5),
                                Text(
                                  imageList.length > 1
                                      ? '${imageList.length} Photos'
                                      : 'Photo',
                                  style: TextStyle(
                                    color: p.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (currentItem.dateStr != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: p.surface3.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: p.border.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.calendar,
                                  size: 13,
                                  color: p.text3,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  currentItem.dateStr!,
                                  style: TextStyle(
                                    color: p.text2,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hasMultiple) ...[
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 13,
                              color: _currentIndex > 0
                                  ? p.text
                                  : p.text3.withValues(alpha: 0.35),
                            ),
                            onPressed: _currentIndex > 0 ? _prevNote : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${_currentIndex + 1} of ${widget.items!.length}',
                              style: TextStyle(
                                color: p.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            icon: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: _currentIndex < widget.items!.length - 1
                                  ? p.text
                                  : p.text3.withValues(alpha: 0.35),
                            ),
                            onPressed: _currentIndex < widget.items!.length - 1
                                ? _nextNote
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
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

            if (hasText)
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: (hasVoice || hasPhotos) ? 240 : 340,
                ),
                padding: const EdgeInsets.all(spacing16),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildFormattedContent(displayText, baseStyle, p),
                ),
              )
            else if (!hasVoice && !hasPhotos)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(spacing16),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'No text in note.',
                  style: baseStyle.copyWith(
                    color: p.text3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Voice recordings if present
            if (hasVoice) ...[
              const SizedBox(height: spacing12),
              for (final vp in voiceList) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: TimelineVoicePlayerPill(
                    p: p,
                    voicePath: vp,
                    durationMs: currentItem.voiceDurationMs ?? 0,
                  ),
                ),
              ],
            ],

            // Photo attachments if present
            if (hasPhotos) ...[
              const SizedBox(height: spacing12),
              for (final ip in imageList) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: TimelineMediaAttachmentCard(
                    p: p,
                    imagePath: ip,
                    isCollapsed: false,
                  ),
                ),
              ],
            ],

            const SizedBox(height: spacing16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isCopied ? p.green : p.text2,
                      backgroundColor: _isCopied
                          ? p.green.withValues(alpha: 0.12)
                          : p.surface2,
                      side: BorderSide(
                        color: _isCopied
                            ? p.green.withValues(alpha: 0.6)
                            : p.border.withValues(alpha: 0.7),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: cleanNote));
                      HapticFeedback.lightImpact();
                      setState(() => _isCopied = true);
                      _copyTimer?.cancel();
                      _copyTimer = Timer(
                        const Duration(milliseconds: 1800),
                        () {
                          if (mounted) setState(() => _isCopied = false);
                        },
                      );
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isCopied
                            ? Icons.check_circle_rounded
                            : Icons.content_paste_rounded,
                        key: ValueKey<bool>(_isCopied),
                        size: 18,
                        color: _isCopied ? p.green : p.text2,
                      ),
                    ),
                    label: Text(
                      _isCopied ? 'Copied!' : 'Copy Note',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _isCopied ? p.green : p.text2,
                      ),
                    ),
                  ),
                ),
                if (currentItem.onEdit != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: p.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        currentItem.onEdit!();
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text(
                        'Edit Note',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
