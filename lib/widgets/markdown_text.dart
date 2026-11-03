import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

class MarkdownText extends StatefulWidget {
  const MarkdownText({
    super.key,
    required this.text,
    required this.p,
    required this.onOpenLink,
  });

  final String text;
  final Palette p;
  final void Function(String url) onOpenLink;

  @override
  State<MarkdownText> createState() => _MarkdownTextState();
}

class _MarkdownTextState extends State<MarkdownText> {
  final List<TapGestureRecognizer> _recognizers = [];

  static final RegExp _tokenRegex = RegExp(
    r"""(\*\*.*?\*\*|~~.*?~~|(?<=[\s\(\[\{\"'']|^)\*.*?\*(?=[\s\)\.\,\!\?\]\}\"'']|$)|(?<=[\s\(\[\{\"'']|^)_.*?_(?=[\s\)\.\,\!\?\]\}\"'']|$)|\[.*?\]\(.*?\)|`.*?`|https?://[^\s]+)""",
    caseSensitive: false,
  );

  static final RegExp _orderedListRegex = RegExp(r'^(\d+)\.\s+(.*)$');

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _createRecognizer(String url) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        AppHaptics.selection();
        widget.onOpenLink(url);
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    _clearRecognizers();
    final p = widget.p;
    final lines = widget.text.split('\n');
    final List<Widget> children = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      // Horizontal Rule
      if (line == '---' || line == '***') {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: p.border.withValues(alpha: 0.3), height: 1),
          ),
        );
        continue;
      }

      // Blockquotes (> Quote)
      if (line.startsWith('> ') || line == '>') {
        final content = line.length > 2 ? line.substring(2) : '';
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Container(
              padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: p.accent.withValues(alpha: 0.7),
                    width: 3.0,
                  ),
                ),
              ),
              child: _buildRichText(content, isItalic: true),
            ),
          ),
        );
        continue;
      }

      // Headings
      if (line.startsWith('# ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
            child: _buildRichText(
              line.substring(2),
              isHeader: true,
              headerSize: 18,
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('## ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
            child: _buildRichText(
              line.substring(3),
              isHeader: true,
              headerSize: 15,
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('### ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: _buildRichText(
              line.substring(4),
              isHeader: true,
              headerSize: 13.5,
            ),
          ),
        );
        continue;
      }

      // Task List Checkboxes (- [ ] or - [x])
      if (line.startsWith('- [ ] ') ||
          line.startsWith('- [x] ') ||
          line.startsWith('- [X] ')) {
        final isChecked = !line.startsWith('- [ ] ');
        final content = line.substring(6);
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                  child: Icon(
                    isChecked
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.circle,
                    size: 15,
                    color: isChecked ? p.green : p.text3,
                  ),
                ),
                Expanded(
                  child: _buildRichText(content, isStrikethrough: isChecked),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Ordered Lists (1. Item)
      final orderedMatch = _orderedListRegex.firstMatch(line);
      if (orderedMatch != null) {
        final numStr = orderedMatch.group(1)!;
        final content = orderedMatch.group(2)!;
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Text(
                    '$numStr.',
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Expanded(child: _buildRichText(content)),
              ],
            ),
          ),
        );
        continue;
      }

      // Unordered Lists (- Item or * Item)
      if (line.startsWith('- ') || line.startsWith('* ')) {
        final content = line.substring(2);
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, right: 6.0),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.text2,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(child: _buildRichText(content)),
              ],
            ),
          ),
        );
        continue;
      }

      // Standard Paragraph
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: _buildRichText(line),
        ),
      );
    }

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildRichText(
    String rawText, {
    bool isHeader = false,
    double headerSize = 12.0,
    bool isItalic = false,
    bool isStrikethrough = false,
  }) {
    final p = widget.p;
    final List<InlineSpan> spans = [];

    final matches = _tokenRegex.allMatches(rawText);
    int lastIndex = 0;

    TextStyle baseStyle({
      bool bold = false,
      bool italic = false,
      bool strike = false,
      Color? color,
    }) {
      return TextStyle(
        color: color ?? (isHeader ? p.text : (strike ? p.text3 : p.text2)),
        fontSize: headerSize,
        fontWeight: isHeader || bold ? FontWeight.w800 : FontWeight.normal,
        fontStyle: isItalic || italic ? FontStyle.italic : FontStyle.normal,
        decoration: isStrikethrough || strike
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        decorationColor: p.text3,
        height: 1.45,
      );
    }

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: rawText.substring(lastIndex, match.start),
            style: baseStyle(),
          ),
        );
      }

      final matchText = match.group(0)!;
      if (matchText.startsWith('**') &&
          matchText.endsWith('**') &&
          matchText.length >= 4) {
        spans.add(
          TextSpan(
            text: matchText.substring(2, matchText.length - 2),
            style: baseStyle(bold: true, color: p.text),
          ),
        );
      } else if (matchText.startsWith('~~') &&
          matchText.endsWith('~~') &&
          matchText.length >= 4) {
        spans.add(
          TextSpan(
            text: matchText.substring(2, matchText.length - 2),
            style: baseStyle(strike: true),
          ),
        );
      } else if ((matchText.startsWith('*') &&
              matchText.endsWith('*') &&
              matchText.length >= 2) ||
          (matchText.startsWith('_') &&
              matchText.endsWith('_') &&
              matchText.length >= 2)) {
        spans.add(
          TextSpan(
            text: matchText.substring(1, matchText.length - 1),
            style: baseStyle(italic: true),
          ),
        );
      } else if (matchText.startsWith('`') &&
          matchText.endsWith('`') &&
          matchText.length >= 2) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: p.surface3,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                matchText.substring(1, matchText.length - 1),
                style: TextStyle(
                  color: p.accent,
                  fontFamily: 'monospace',
                  fontSize: headerSize - 1,
                ),
              ),
            ),
          ),
        );
      } else if (matchText.startsWith('[') && matchText.contains('](')) {
        final closingBracket = matchText.indexOf(']');
        final label = matchText.substring(1, closingBracket);
        final url = matchText.substring(
          closingBracket + 2,
          matchText.length - 1,
        );

        spans.add(
          TextSpan(
            text: label,
            style: TextStyle(
              color: p.accent,
              fontSize: headerSize,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: p.accent,
            ),
            recognizer: _createRecognizer(url),
          ),
        );
      } else if (matchText.startsWith('http://') ||
          matchText.startsWith('https://')) {
        spans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(
              color: p.accent,
              fontSize: headerSize,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: p.accent,
            ),
            recognizer: _createRecognizer(matchText),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < rawText.length) {
      spans.add(
        TextSpan(text: rawText.substring(lastIndex), style: baseStyle()),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }
}
