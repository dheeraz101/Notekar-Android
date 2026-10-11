import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// An Apple HIG frosted floating pill overlay for inline hashtag autocomplete.
///
/// Detects when the user types `#` or `#query` in the text field,
/// fetches matching suggestions from [TagService], and renders a
/// horizontal chip bar above the keyboard or input field. Tapping a tag
/// seamlessly completes the hashtag with a trailing space.
class HashtagSuggestionOverlay extends StatefulWidget {
  const HashtagSuggestionOverlay({
    super.key,
    required this.controller,
    required this.p,
    this.entries = const [],
    this.onTagSelected,
  });

  final TextEditingController controller;
  final Palette p;
  final List<Moment> entries;
  final ValueChanged<String>? onTagSelected;

  @override
  State<HashtagSuggestionOverlay> createState() =>
      _HashtagSuggestionOverlayState();
}

class _HashtagSuggestionOverlayState extends State<HashtagSuggestionOverlay> {
  List<String> _suggestions = [];
  int _hashStartIndex = -1;
  int _hashEndIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _checkHashtagQuery();
  }

  @override
  void didUpdateWidget(covariant HashtagSuggestionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _checkHashtagQuery();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _checkHashtagQuery();
  }

  void _checkHashtagQuery() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (!selection.isValid || selection.isCollapsed == false) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = []);
      }
      return;
    }

    final cursor = selection.baseOffset;
    if (cursor < 1) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = []);
      }
      return;
    }

    // Look backward from cursor to locate the '#' symbol
    int hashIdx = -1;
    for (int i = cursor - 1; i >= 0; i--) {
      final ch = text[i];
      if (ch == '#') {
        // Ensure '#' is either at index 0 or preceded by whitespace / punctuation
        if (i == 0 ||
            text[i - 1] == ' ' ||
            text[i - 1] == '\n' ||
            text[i - 1] == '\t') {
          hashIdx = i;
        }
        break;
      }
      // Stop scanning if a whitespace or newline is encountered before '#'
      if (ch == ' ' || ch == '\n' || ch == '\t') {
        break;
      }
    }

    if (hashIdx < 0) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = []);
      }
      return;
    }

    final queryPrefix = text.substring(hashIdx, cursor);
    final results = TagService.instance.suggestTags(
      queryPrefix,
      widget.entries,
    );

    if (mounted) {
      setState(() {
        _hashStartIndex = hashIdx;
        _hashEndIndex = cursor;
        _suggestions = results;
      });
    }
  }

  void _selectTag(String tag) {
    HapticFeedback.lightImpact();
    final text = widget.controller.text;
    final cleanTag = tag.startsWith('#') ? tag : '#$tag';
    final completedTag = '$cleanTag ';

    if (_hashStartIndex >= 0 && _hashEndIndex <= text.length) {
      final before = text.substring(0, _hashStartIndex);
      final after = text.substring(_hashEndIndex);
      final newText = '$before$completedTag$after';
      final newCursorPos = _hashStartIndex + completedTag.length;

      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPos),
      );
    } else {
      widget.controller.text = '$text $completedTag';
    }

    setState(() => _suggestions = []);
    widget.onTagSelected?.call(cleanTag);
  }

  @override
  Widget build(BuildContext context) {
    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: _suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final tag = _suggestions[index];
          final cleanTag = tag.startsWith('#') ? tag : '#$tag';
          final actTag = TagService.instance.findActivityTag(cleanTag);

          return PressableScale(
            onTap: () => _selectTag(cleanTag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: widget.p.surface2.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: widget.p.accent.withValues(alpha: 0.35),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actTag != null) ...[
                    Icon(actTag.icon, size: 12, color: widget.p.accent),
                    const SizedBox(width: 4),
                  ] else ...[
                    Text(
                      '#',
                      style: TextStyle(
                        color: widget.p.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    TagService.stripHash(cleanTag),
                    style: TextStyle(
                      color: widget.p.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
