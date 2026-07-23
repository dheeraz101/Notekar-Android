import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';

class MarkdownText extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final lines = text.split('\n');
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

      // Unordered Lists
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildRichText(
    String rawText, {
    bool isHeader = false,
    double headerSize = 12.0,
  }) {
    final List<InlineSpan> spans = [];
    final regExp = RegExp(
      r'(\*\*.*?\*\*|\[.*?\]\(.*?\)|`.*?`)',
      caseSensitive: false,
    );

    final matches = regExp.allMatches(rawText);
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: rawText.substring(lastIndex, match.start),
            style: TextStyle(
              color: isHeader ? p.text : p.text2,
              fontSize: headerSize,
              fontWeight: isHeader ? FontWeight.w800 : FontWeight.normal,
              height: 1.45,
            ),
          ),
        );
      }

      final matchText = match.group(0)!;
      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        spans.add(
          TextSpan(
            text: matchText.substring(2, matchText.length - 2),
            style: TextStyle(
              color: p.text,
              fontSize: headerSize,
              fontWeight: FontWeight.w800,
              height: 1.45,
            ),
          ),
        );
      } else if (matchText.startsWith('`') && matchText.endsWith('`')) {
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
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => onOpenLink(url),
              child: Text(
                label,
                style: TextStyle(
                  color: p.accent,
                  fontSize: headerSize,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: p.accent,
                ),
              ),
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < rawText.length) {
      spans.add(
        TextSpan(
          text: rawText.substring(lastIndex),
          style: TextStyle(
            color: isHeader ? p.text : p.text2,
            fontSize: headerSize,
            fontWeight: isHeader ? FontWeight.w800 : FontWeight.normal,
            height: 1.45,
          ),
        ),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }
}
