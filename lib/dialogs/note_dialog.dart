import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

class NoteDialog extends StatefulWidget {
  const NoteDialog({
    super.key,
    required this.p,
    this.initialNote = '',
    this.title = 'Add Note',
    this.saveLabel = 'Save',
    this.allowEmpty = true,
    this.blur = false,
    this.largeText = false,
  });

  final Palette p;
  final String initialNote;
  final String title;
  final String saveLabel;
  final bool allowEmpty;
  final bool blur;
  final bool largeText;

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  static const _maxChars = 280;
  late final TextEditingController _controller;
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      p: widget.p,
      title: widget.title,
      blur: widget.blur,
      largeText: widget.largeText,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialNote.isEmpty
                ? 'Add a short detail to this moment.'
                : 'Update the note attached to this moment.',
            style: TextStyle(
              color: widget.p.text2,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: spacing12),
          SizedBox(
            height: 160,
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLength: _maxChars,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              scrollPadding: const EdgeInsets.all(spacing64),
              style: TextStyle(color: widget.p.text),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'What should this moment remember?',
                hintStyle: TextStyle(color: widget.p.text3),
                filled: true,
                fillColor: widget.p.surface3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _showWarning ? widget.p.red : widget.p.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _showWarning ? widget.p.red : widget.p.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _showWarning ? widget.p.red : widget.p.accent,
                  ),
                ),
              ),
              onChanged: (text) {
                setState(() {
                  _showWarning = false;
                });
              },
              onSubmitted: (_) => _saveNote(),
            ),
          ),
          const SizedBox(height: spacing12),
          _LinearCharacterIndicator(
            p: widget.p,
            count: _controller.text.length,
            max: _maxChars,
          ),
          if (_showWarning)
            Padding(
              padding: const EdgeInsets.only(top: spacing8),
              child: Text(
                'Write something to save.',
                style: TextStyle(
                  color: widget.p.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(height: spacing16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.p.accent,
                  ),
                  onPressed: () {
                    if (widget.allowEmpty) {
                      Navigator.pop(context, '');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.allowEmpty ? 'Skip' : 'Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.p.accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveNote,
                  child: Text(widget.saveLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    final note = _controller.text.trim();

    if (!widget.allowEmpty && note.isEmpty) {
      HapticFeedback.selectionClick();
      setState(() => _showWarning = true);
      return;
    }

    Navigator.pop(context, note);
  }
}

class _LinearCharacterIndicator extends StatelessWidget {
  const _LinearCharacterIndicator({
    required this.p,
    required this.count,
    required this.max,
  });

  final Palette p;
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final remaining = max - count;
    final progress = (count / max).clamp(0.0, 1.0);
    final alert = remaining <= 20;
    final danger = remaining <= 0;

    final color =
        danger
            ? p.red
            : alert
            ? p.orange
            : p.accent.withValues(alpha: 0.8);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$count / $max',
          style: TextStyle(
            color: alert ? color : p.text3,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
