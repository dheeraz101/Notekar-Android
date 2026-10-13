import 'package:flutter/material.dart';

/// Renders note and moment text with live Markdown formatting previews.
///
/// Features:
/// - Strips markdown delimiters and formats inline styles:
///   - `**bold**` -> bold text without asterisks
///   - `*italic*` -> italic text without asterisks
///   - `***bold italic***` -> bold italic text without asterisks
///   - `` `code` `` -> monospace font with subtle background tint
///   - `~~strike~~` -> strikethrough text without tildes
///   - `#hashtag` -> styled with accent color and semibold weight
/// - Formats line prefixes:
///   - `- [ ] ` -> `☐ ` (checklist unchecked)
///   - `- [x] ` -> `☑ ` (checklist checked with strikethrough)
///   - `> ` -> `▎ ` (blockquote with italics)
///   - `- ` or `* ` -> `• ` (bullet list)
/// - Fast-path execution for plain notes without markdown
/// - Native emoji support, [maxLines], and [overflow] (ellipsis)
class IosEmojiText extends StatelessWidget {
  const IosEmojiText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
    this.accentColor,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final Color? accentColor;

  static final RegExp _inlineRegex = RegExp(
    r'(\*\*\*(?:[^\s*](?:[^*\n]*?[^\s*])?)\*\*\*)|' // 1: ***bold italic***
    r'(\*\*(?:[^\s*](?:[^*\n]*?[^\s*])?)\*\*)|' // 2: **bold**
    r'(\*(?:[^\s*](?:[^*\n]*?[^\s*])?)\*)|' // 3: *italic*
    r'(`(?:[^`\n]+?)`)|' // 4: `code`
    r'(~~(?:[^\s~](?:[^~\n]*?[^\s~])?)~~)|' // 5: ~~strike~~
    r'(#[a-zA-Z0-9_\u0900-\u097F\u0080-\uFFFF]+)', // 6: #hashtag
  );

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return Text('', style: style);
    }

    final hasMarkdown =
        text.contains('*') ||
        text.contains('`') ||
        text.contains('~') ||
        text.contains('#') ||
        text.contains('>') ||
        text.contains('- [');

    if (!hasMarkdown) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final defaultStyle = DefaultTextStyle.of(context).style;
    final baseStyle = style ?? defaultStyle;
    final accent = accentColor ?? Theme.of(context).colorScheme.primary;

    final span = _parseMarkdown(text, baseStyle, accent);

    return Text.rich(
      span,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  static TextSpan _parseMarkdown(
    String text,
    TextStyle baseStyle,
    Color accentColor,
  ) {
    final lines = text.split('\n');
    final List<InlineSpan> allSpans = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (i > 0) {
        allSpans.add(const TextSpan(text: '\n'));
      }

      if (line.startsWith('- [x] ') || line.startsWith('- [X] ')) {
        allSpans.add(
          TextSpan(
            text: '☑ ',
            style: baseStyle.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        final content = line.substring(6);
        allSpans.addAll(
          _parseInline(
            content,
            baseStyle.copyWith(
              decoration: TextDecoration.lineThrough,
              color: baseStyle.color?.withValues(alpha: 0.65),
            ),
            accentColor,
          ),
        );
      } else if (line.startsWith('- [ ] ')) {
        allSpans.add(
          TextSpan(
            text: '☐ ',
            style: baseStyle.copyWith(
              color: baseStyle.color?.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        final content = line.substring(6);
        allSpans.addAll(_parseInline(content, baseStyle, accentColor));
      } else if (line.startsWith('> ')) {
        allSpans.add(
          TextSpan(
            text: '▎ ',
            style: baseStyle.copyWith(
              color: accentColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        final content = line.substring(2);
        allSpans.addAll(
          _parseInline(
            content,
            baseStyle.copyWith(
              fontStyle: FontStyle.italic,
              color: baseStyle.color?.withValues(alpha: 0.85),
            ),
            accentColor,
          ),
        );
      } else if (line.startsWith('• ') ||
          line.startsWith('- ') ||
          line.startsWith('* ')) {
        allSpans.add(
          TextSpan(
            text: '• ',
            style: baseStyle.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        final content = line.substring(2);
        allSpans.addAll(_parseInline(content, baseStyle, accentColor));
      } else {
        allSpans.addAll(_parseInline(line, baseStyle, accentColor));
      }
    }

    return TextSpan(children: allSpans, style: baseStyle);
  }

  static List<InlineSpan> _parseInline(
    String line,
    TextStyle baseStyle,
    Color accentColor,
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

      if (matchedText.startsWith('***') &&
          matchedText.endsWith('***') &&
          matchedText.length >= 6) {
        final inner = matchedText.substring(3, matchedText.length - 3);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else if (matchedText.startsWith('**') &&
          matchedText.endsWith('**') &&
          matchedText.length >= 4) {
        final inner = matchedText.substring(2, matchedText.length - 2);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else if (matchedText.startsWith('*') &&
          matchedText.endsWith('*') &&
          matchedText.length >= 2) {
        final inner = matchedText.substring(1, matchedText.length - 1);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (matchedText.startsWith('`') &&
          matchedText.endsWith('`') &&
          matchedText.length >= 2) {
        final inner = matchedText.substring(1, matchedText.length - 1);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(
              fontFamily: 'monospace',
              letterSpacing: -0.2,
              backgroundColor: baseStyle.color?.withValues(alpha: 0.08),
            ),
          ),
        );
      } else if (matchedText.startsWith('~~') &&
          matchedText.endsWith('~~') &&
          matchedText.length >= 4) {
        final inner = matchedText.substring(2, matchedText.length - 2);
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
          ),
        );
      } else if (matchedText.startsWith('#')) {
        spans.add(
          TextSpan(
            text: matchedText,
            style: baseStyle.copyWith(
              color: accentColor,
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
}
