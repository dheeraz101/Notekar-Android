import 'package:flutter/material.dart';

class IosEmojiText extends StatelessWidget {
  const IosEmojiText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  bool _isEmoji(int rune) {
    return (rune >= 0x1F300 &&
            rune <= 0x1FADF) || // Emoticons, Pictographs, Food, etc.
        (rune >= 0x2600 && rune <= 0x27BF) || // Dingbats & Symbols
        (rune >= 0x1F1E6 && rune <= 0x1F1FF) || // Flags
        (rune == 0x200D) || // ZWJ
        (rune == 0xFE0F); // Variation selector
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final fontSize = baseStyle.fontSize ?? 14.0;

    final List<InlineSpan> spans = [];
    final runes = text.runes.toList();
    final buffer = StringBuffer();

    int i = 0;
    while (i < runes.length) {
      final rune = runes[i];

      if (_isEmoji(rune)) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
          buffer.clear();
        }

        final List<int> emojiSequence = [rune];
        i++;
        while (i < runes.length && _isEmoji(runes[i])) {
          emojiSequence.add(runes[i]);
          i++;
        }

        final hexList = emojiSequence
            .where(
              (r) => r != 0xFE0F,
            ) // Skip selector for URL matching compatibility
            .map((r) => r.toRadixString(16).toLowerCase())
            .toList();

        final hexStr = hexList.join('-');
        final originalEmojiStr = String.fromCharCodes(emojiSequence);

        if (hexStr.isNotEmpty) {
          final cdnUrl =
              'https://cdn.jsdelivr.net/gh/iamcal/emoji-data@master/img-apple-64/$hexStr.png';

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Image.network(
                cdnUrl,
                width: fontSize * 1.3,
                height: fontSize * 1.3,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    originalEmojiStr,
                    style: baseStyle.copyWith(fontFamily: 'Roboto'),
                  );
                },
              ),
            ),
          );
        } else {
          spans.add(TextSpan(text: originalEmojiStr, style: baseStyle));
        }
      } else {
        buffer.writeCharCode(rune);
        i++;
      }
    }

    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
