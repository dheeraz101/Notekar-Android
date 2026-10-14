import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';

/// Read-only note preview bottom sheet with full text viewing, interactive links,
/// safe external departure confirmation dialog, copying, and edit action.
class NotePreviewSheet extends StatefulWidget {
  const NotePreviewSheet({
    super.key,
    required this.p,
    required this.note,
    required this.title,
    this.category,
    this.onEdit,
    this.dateStr,
  });

  final Palette p;
  final String note;
  final String title;
  final String? category;
  final VoidCallback? onEdit;
  final String? dateStr;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required String note,
    required String title,
    String? category,
    VoidCallback? onEdit,
    String? dateStr,
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
      ),
    );
  }

  @override
  State<NotePreviewSheet> createState() => _NotePreviewSheetState();
}

class _NotePreviewSheetState extends State<NotePreviewSheet> {
  final List<TapGestureRecognizer> _recognizers = [];

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

  List<InlineSpan> _buildSpans(String text, TextStyle baseStyle) {
    _clearRecognizers();
    if (text.isEmpty) return const [];

    final urlRegExp = RegExp(
      r'(\[([^\]]+)\]\((https?://[^\s)]+|www\.[^\s)]+)\)|https?://[^\s]+|www\.[^\s]+)',
      caseSensitive: false,
    );

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in urlRegExp.allMatches(text)) {
      if (match.start > lastIndex) {
        final plain = text.substring(lastIndex, match.start);
        spans.add(TextSpan(text: plain, style: baseStyle));
      }

      final matchedText = match.group(0)!;
      String displayLabel;
      String targetUrl;
      String trailing = '';

      if (matchedText.startsWith('[') &&
          match.group(2) != null &&
          match.group(3) != null) {
        displayLabel = match.group(2)!;
        targetUrl = match.group(3)!;
      } else {
        String urlCandidate = matchedText;
        while (urlCandidate.isNotEmpty &&
            (urlCandidate.endsWith('.') ||
                urlCandidate.endsWith(',') ||
                urlCandidate.endsWith(';') ||
                urlCandidate.endsWith(')'))) {
          trailing = urlCandidate[urlCandidate.length - 1] + trailing;
          urlCandidate = urlCandidate.substring(0, urlCandidate.length - 1);
        }
        displayLabel = urlCandidate;
        targetUrl = urlCandidate;
      }

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
            color: widget.p.accent,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: widget.p.accent,
          ),
          recognizer: recognizer,
        ),
      );

      if (trailing.isNotEmpty) {
        spans.add(TextSpan(text: trailing, style: baseStyle));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final cleanNote = widget.note.trim();
    final rawTags = NoteTagExtractor.extractHashtags(cleanNote);
    final catLower = (widget.category ?? '').toLowerCase().trim();
    final tags = rawTags
        .where((t) => t.toLowerCase().replaceAll('#', '').trim() != catLower)
        .toSet()
        .toList();
    final cleanBody = NoteTagExtractor.cleanBodyText(cleanNote);
    final displayText = cleanBody.isNotEmpty
        ? cleanBody
        : (cleanNote.isEmpty ? 'No text in note.' : cleanNote);

    final baseStyle = TextStyle(
      color: p.text,
      fontSize: 15,
      height: 1.45,
      fontWeight: FontWeight.w500,
    );

    final hasUrls = RegExp(
      r'https?://|www\.|\[.*?\]\(.*?\)',
      caseSensitive: false,
    ).hasMatch(displayText);

    return AppSheet(
      p: p,
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.category != null ||
              widget.dateStr != null ||
              tags.isNotEmpty) ...[
            Row(
              children: [
                if (widget.category != null &&
                    widget.category!.trim().isNotEmpty) ...[
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
                      widget.category!,
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.dateStr != null)
                  Text(
                    widget.dateStr!,
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

          // Note text card with interactive link detection & safe departure dialog
          Container(
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
              child: SelectionArea(
                child: hasUrls
                    ? Text.rich(
                        TextSpan(children: _buildSpans(displayText, baseStyle)),
                      )
                    : IosEmojiText(displayText, style: baseStyle),
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
              if (widget.onEdit != null) ...[
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
                      widget.onEdit!();
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
        ],
      ),
    );
  }
}
