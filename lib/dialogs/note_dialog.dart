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
    this.saveLabel = 'Save Moment',
    this.allowEmpty = true,
    this.blur = false,
  });

  final Palette p;
  final String initialNote;
  final String title;
  final String saveLabel;
  final bool allowEmpty;
  final bool blur;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialNote.isEmpty
                ? 'Add a short detail to this moment.'
                : 'Update the note attached to this moment.',
            style: TextStyle(color: widget.p.text2, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: spacing8),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: _maxChars,
            maxLines: 4,
            minLines: 2,
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
            onChanged: (_) => setState(() => _showWarning = false),
            onSubmitted: (_) => _saveNote(),
          ),
          const SizedBox(height: spacing8),
          Row(
            children: [
              Expanded(
                child: AnimatedOpacity(
                  opacity: _showWarning ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: Text(
                    'Write something to save.',
                    style: TextStyle(
                      color: widget.p.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              _CharacterCounter(
                p: widget.p,
                count: _controller.text.length,
                max: _maxChars,
              ),
            ],
          ),
          const SizedBox(height: spacing12),
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
              const SizedBox(width: 10),
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

class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({
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
    final color = alert ? p.orange : p.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.4,
            backgroundColor: p.surface3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          alert ? '$remaining' : '$count/$max',
          style: TextStyle(
            color: alert ? color : p.text3,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
