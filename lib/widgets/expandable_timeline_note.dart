import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';

/// Renders a timeline note with formatted Markdown syntax (bold, italic, code,
/// strikethrough, hashtags) and an inline "Show more / Show less" expansion toggle
/// when content exceeds the collapsed line limit.
class ExpandableTimelineNote extends StatefulWidget {
  const ExpandableTimelineNote({
    super.key,
    required this.text,
    required this.p,
    this.compact = false,
    this.collapsedMaxLines,
    this.style,
    this.onTapBody,
  });

  final String text;
  final Palette p;
  final bool compact;
  final int? collapsedMaxLines;
  final TextStyle? style;
  final VoidCallback? onTapBody;

  @override
  State<ExpandableTimelineNote> createState() => _ExpandableTimelineNoteState();
}

class _ExpandableTimelineNoteState extends State<ExpandableTimelineNote> {
  bool _isExpanded = false;

  int get _effectiveMaxLines =>
      widget.collapsedMaxLines ?? (widget.compact ? 2 : 4);

  bool get _isLikelyLong {
    final lines = widget.text.split('\n');
    if (lines.length > _effectiveMaxLines) return true;
    if (widget.text.length > (_effectiveMaxLines * 45)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final defaultStyle = DefaultTextStyle.of(context).style;
    final baseStyle = (widget.style ?? defaultStyle).copyWith(
      fontSize: widget.style?.fontSize ?? (widget.compact ? 13.5 : 15.5),
      height: widget.style?.height ?? 1.42,
    );

    final showToggle = _isLikelyLong || _isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTapBody,
          child: IosEmojiText(
            widget.text,
            maxLines: _isExpanded ? null : _effectiveMaxLines,
            overflow: _isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: baseStyle,
            accentColor: widget.p.accent,
          ),
        ),
        if (showToggle)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              AppHaptics.selection();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _isExpanded
                    ? 'show less'.localized(context)
                    : 'show more'.localized(context),
                style: TextStyle(
                  color: widget.p.accent,
                  fontSize: widget.compact ? 12.0 : 13.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
