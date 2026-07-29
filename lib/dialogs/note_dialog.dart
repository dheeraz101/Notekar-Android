import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late final TextEditingController _controller;
  final _scrollController = ScrollController();
  bool _showWarning = false;

  bool _sobrietyMode = false;
  String? _selectedMood;
  String? _selectedTrigger;
  bool _relapseSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _controller.addListener(_scrollToBottom);
    _loadSobrietyMode();
    // Pre-check if note already contains relapse or tags
    if (widget.initialNote.contains('#relapse')) {
      _relapseSelected = true;
    }
  }

  Future<void> _loadSobrietyMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sobrietyMode = prefs.getBool('enable_sobriety_mode') ?? false;
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollToBottom);
    _controller.dispose();
    _scrollController.dispose();
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
            style: TextStyle(color: widget.p.text2, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: spacing12),
          SizedBox(
            height: 160,
            child: TextField(
              controller: _controller,
              scrollController: _scrollController,
              autofocus: true,
              maxLength: maxNoteLength,
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
            max: maxNoteLength,
          ),
          if (_sobrietyMode) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mark as Relapse / Reset',
                  style: TextStyle(
                    color: widget.p.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Switch.adaptive(
                  value: _relapseSelected,
                  activeTrackColor: widget.p.orange,
                  onChanged: (value) {
                    setState(() => _relapseSelected = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'MOOD TAG',
              style: TextStyle(
                color: widget.p.text2,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Bored', 'Anxious', 'Fatigue', 'Stressed', 'Lonely']
                    .map((mood) {
                      final isSelected = _selectedMood == mood.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildTagChip(mood, isSelected, () {
                          setState(() {
                            _selectedMood = isSelected
                                ? null
                                : mood.toLowerCase();
                          });
                        }, widget.p.accent),
                      );
                    })
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'TRIGGER TAG',
              style: TextStyle(
                color: widget.p.text2,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                      'Social Media',
                      'Video',
                      'Alone',
                      'Late Night',
                      'Fatigue',
                    ].map((trigger) {
                      final triggerKey = trigger.toLowerCase().replaceAll(
                        ' ',
                        '_',
                      );
                      final isSelected = _selectedTrigger == triggerKey;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildTagChip(trigger, isSelected, () {
                          setState(() {
                            _selectedTrigger = isSelected ? null : triggerKey;
                          });
                        }, widget.p.orange),
                      );
                    }).toList(),
              ),
            ),
          ],
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

  Widget _buildTagChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color activeColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : widget.p.surface3,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : widget.p.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : widget.p.text2,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    var note = _controller.text.trim();

    if (_sobrietyMode) {
      final List<String> tags = [];
      if (_relapseSelected) {
        tags.add('#relapse');
      }
      if (_selectedMood != null) {
        tags.add('#mood:$_selectedMood');
      }
      if (_selectedTrigger != null) {
        tags.add('#trigger:$_selectedTrigger');
      }

      if (tags.isNotEmpty) {
        final tagsString = tags.join(' ');
        if (note.isEmpty) {
          note = tagsString;
        } else {
          var cleanNote = note;
          cleanNote = cleanNote.replaceAll('#relapse', '').trim();
          cleanNote = cleanNote.replaceAll(RegExp(r'#mood:\w+'), '').trim();
          cleanNote = cleanNote.replaceAll(RegExp(r'#trigger:\w+'), '').trim();
          note = cleanNote.isEmpty ? tagsString : '$cleanNote $tagsString';
        }
      }
    }

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

    final color = danger
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
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
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
