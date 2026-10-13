import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';

/// A rich [TextEditingController] that formats Markdown syntax live in the text box.
///
/// Automatically styles:
/// - **Bold**: `**text**` renders bold with delicately dimmed `**` tokens.
/// - *Italic*: `*text*` renders in italics with dimmed `*` tokens.
/// - `Monospace / Code`: `` `text` `` renders in monospace with subtle tint.
/// - ~~Strikethrough~~: `~~text~~` renders with strikethrough decoration.
/// - #Hashtag: `#tag` renders in accent color and semibold.
/// - > Blockquote: Lines starting with `> ` render in italicized quote style.
/// - Checklist: Lines starting with `- [ ] ` or `- [x] ` render styled markers.
/// - Bullet: Lines starting with `• ` or `- ` render highlighted bullets.
class MarkdownTextEditingController extends TextEditingController {
  MarkdownTextEditingController({super.text, required this.palette});

  Palette palette;

  // Pattern matching inline formatting
  static final RegExp _inlineRegex = RegExp(
    r'(\*\*(?:[^*]|\*(?!\*))+\*\*)|' // 1: **bold**
    r'(\*(?:[^*])+\*)|' // 2: *italic*
    r'(`(?:[^`])+`)|' // 3: `code`
    r'(~~(?:[^~])+~~)|' // 4: ~~strike~~
    r'(#[a-zA-Z0-9_\-]+)', // 5: #hashtag
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle =
        style ??
        TextStyle(
          color: palette.text,
          fontSize: 16.0,
          letterSpacing: 0.1,
          height: 1.45,
        );

    final textVal = text;
    if (textVal.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    // Split text into lines to properly format line-based blockquotes & lists
    final lines = textVal.split('\n');
    final List<InlineSpan> lineSpans = [];

    final syntaxDimStyle = baseStyle.copyWith(
      color: palette.subtext.withValues(alpha: 0.38),
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('> ')) {
        // Blockquote line
        final quoteContent = line.substring(2);
        lineSpans.add(TextSpan(text: '> ', style: syntaxDimStyle));
        lineSpans.addAll(
          _parseInlineSpans(
            quoteContent,
            baseStyle.copyWith(
              color: palette.subtext,
              fontStyle: FontStyle.italic,
            ),
            syntaxDimStyle,
          ),
        );
      } else if (line.startsWith('- [ ] ') || line.startsWith('- [x] ')) {
        // Checklist line
        final isChecked = line.startsWith('- [x] ');
        final prefix = line.substring(0, 6);
        final content = line.substring(6);

        lineSpans.add(
          TextSpan(
            text: prefix,
            style: baseStyle.copyWith(
              color: isChecked ? palette.accent : palette.subtext,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        lineSpans.addAll(
          _parseInlineSpans(
            content,
            isChecked
                ? baseStyle.copyWith(
                    color: palette.text3,
                    decoration: TextDecoration.lineThrough,
                  )
                : baseStyle,
            syntaxDimStyle,
          ),
        );
      } else if (line.startsWith('• ') || line.startsWith('- ')) {
        // Bullet list line
        final prefix = line.startsWith('• ') ? '• ' : '- ';
        final content = line.substring(prefix.length);

        lineSpans.add(
          TextSpan(
            text: prefix,
            style: baseStyle.copyWith(
              color: palette.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        lineSpans.addAll(_parseInlineSpans(content, baseStyle, syntaxDimStyle));
      } else {
        // Normal text line with inline formatting
        lineSpans.addAll(_parseInlineSpans(line, baseStyle, syntaxDimStyle));
      }

      // Re-add newline between lines
      if (i < lines.length - 1) {
        lineSpans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: lineSpans, style: baseStyle);
  }

  List<InlineSpan> _parseInlineSpans(
    String line,
    TextStyle baseStyle,
    TextStyle syntaxDimStyle,
  ) {
    if (line.isEmpty) return const [];

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in _inlineRegex.allMatches(line)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: line.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      final matchedText = match.group(0)!;

      if (matchedText.startsWith('**') &&
          matchedText.endsWith('**') &&
          matchedText.length >= 4) {
        // Bold: **text**
        final inner = matchedText.substring(2, matchedText.length - 2);
        spans.add(
          TextSpan(
            children: [
              TextSpan(text: '**', style: syntaxDimStyle),
              TextSpan(
                text: inner,
                style: baseStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.text,
                ),
              ),
              TextSpan(text: '**', style: syntaxDimStyle),
            ],
          ),
        );
      } else if (matchedText.startsWith('*') &&
          matchedText.endsWith('*') &&
          matchedText.length >= 2) {
        // Italic: *text*
        final inner = matchedText.substring(1, matchedText.length - 1);
        spans.add(
          TextSpan(
            children: [
              TextSpan(text: '*', style: syntaxDimStyle),
              TextSpan(
                text: inner,
                style: baseStyle.copyWith(
                  fontStyle: FontStyle.italic,
                  color: palette.text,
                ),
              ),
              TextSpan(text: '*', style: syntaxDimStyle),
            ],
          ),
        );
      } else if (matchedText.startsWith('`') &&
          matchedText.endsWith('`') &&
          matchedText.length >= 2) {
        // Monospace / Code: `code`
        final inner = matchedText.substring(1, matchedText.length - 1);
        spans.add(
          TextSpan(
            children: [
              TextSpan(text: '`', style: syntaxDimStyle),
              TextSpan(
                text: inner,
                style: baseStyle.copyWith(
                  fontFamily: 'monospace',
                  color: palette.accent,
                  backgroundColor: palette.surface3.withValues(alpha: 0.6),
                ),
              ),
              TextSpan(text: '`', style: syntaxDimStyle),
            ],
          ),
        );
      } else if (matchedText.startsWith('~~') &&
          matchedText.endsWith('~~') &&
          matchedText.length >= 4) {
        // Strikethrough: ~~text~~
        final inner = matchedText.substring(2, matchedText.length - 2);
        spans.add(
          TextSpan(
            children: [
              TextSpan(text: '~~', style: syntaxDimStyle),
              TextSpan(
                text: inner,
                style: baseStyle.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: palette.subtext,
                ),
              ),
              TextSpan(text: '~~', style: syntaxDimStyle),
            ],
          ),
        );
      } else if (matchedText.startsWith('#')) {
        // Hashtag: #tag
        spans.add(
          TextSpan(
            text: matchedText,
            style: baseStyle.copyWith(
              color: palette.accent,
              fontWeight: FontWeight.w700,
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
}
