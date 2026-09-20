import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/big_note_dialog.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';
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
    this.hintText,
  });

  final Palette p;
  final String initialNote;
  final String title;
  final String saveLabel;
  final bool allowEmpty;
  final bool blur;
  final bool largeText;
  final String? hintText;

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showWarning = false;

  bool _sobrietyMode = false;
  String? _selectedMood;
  String? _selectedTrigger;
  bool _relapseSelected = false;
  int _availableShields = 0;
  bool _shieldActivated = false;

  List<String> _tags = const [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _loadSobrietyMode();
    _loadTags();
    // Pre-check if note already contains relapse or tags
    if (widget.initialNote.contains('#relapse')) {
      _relapseSelected = true;
    }
    if (widget.initialNote.contains('#shielded')) {
      _shieldActivated = true;
    }
    // Instant keyboard focus!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadTags() async {
    final tagService = TagService.instance;
    await tagService.load();
    if (mounted) setState(() => _tags = tagService.customTags);
  }

  Future<void> _showAddTagDialog() async {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();
    final created = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.p.surface2,
        title: Text(
          'New Hashtag',
          style: TextStyle(
            color: widget.p.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: TextStyle(color: widget.p.text),
          decoration: InputDecoration(
            hintText: 'tag (e.g. #deepwork, #ideas)',
            hintStyle: TextStyle(color: widget.p.text3),
            prefixText: textController.text.startsWith('#') ? null : '#',
            prefixStyle: TextStyle(
              color: widget.p.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: widget.p.text2)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.p.accent),
            onPressed: () {
              final raw = textController.text.trim();
              if (raw.isEmpty) return;
              final clean = raw.startsWith('#') ? raw : '#$raw';
              Navigator.pop(ctx, clean);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (created != null && created.isNotEmpty) {
      final added = await TagService.instance.addCustomTag(created);
      if (added && mounted) {
        setState(() => _tags = TagService.instance.customTags);
      }
    }
  }

  Future<void> _confirmDeleteTag(String tag) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.p.surface2,
        title: Text(
          'Remove $tag?',
          style: TextStyle(
            color: widget.p.text,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Do you want to remove this tag from your quick list?',
          style: TextStyle(color: widget.p.text2, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: widget.p.text2)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.p.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TagService.instance.removeCustomTag(tag);
      if (mounted) {
        setState(() => _tags = TagService.instance.customTags);
      }
    }
  }

  Future<void> _openBigNote() async {
    HapticFeedback.selectionClick();
    final result = await showDialog<NoteResult>(
      context: context,
      builder: (ctx) => BigNoteDialog(
        p: widget.p,
        initialNote: _controller.text,
        title: 'Plus Note',
        blur: widget.blur,
        largeText: widget.largeText,
      ),
    );
    if (result != null && mounted) {
      _controller.text = result.note;
      Navigator.pop(context, result);
    }
  }

  Future<void> _loadSobrietyMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sobrietyMode = prefs.getBool('enable_sobriety_mode') ?? false;
      _availableShields = prefs.getInt('streak_shields') ?? 1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    // When keyboard is open, limit scrollable height to 205px to push the relapse switch and tags below the fold.
    // When keyboard is closed, expand to full available height.
    final maxScrollHeight = keyboardHeight > 0
        ? 205.0
        : (screenHeight - 210).clamp(100.0, double.infinity);
    Widget scrollableContent = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxScrollHeight),
      child: SingleChildScrollView(
        child: Column(
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
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              maxLength: widget.initialNote.length > maxNoteLength
                  ? null
                  : maxNoteLength,
              maxLengthEnforcement:
                  MaxLengthEnforcement.truncateAfterCompositionEnds,
              minLines: 4,
              maxLines: 6,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              scrollPadding: const EdgeInsets.all(spacing64),
              style: TextStyle(color: widget.p.text),
              decoration: InputDecoration(
                counterText: '',
                hintText:
                    widget.hintText ?? 'What should this moment remember?',
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
                if (_showWarning) {
                  setState(() {
                    _showWarning = false;
                  });
                }
              },
              onSubmitted: (_) => _saveNote(),
            ),
            const SizedBox(height: spacing12),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                return _LinearCharacterIndicator(
                  p: widget.p,
                  count: value.text.length,
                  max: maxNoteLength,
                );
              },
            ),
            const SizedBox(height: spacing12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (final tag in _tags)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: PressableScale(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          final text = _controller.text;
                          final spacer = text.isEmpty || text.endsWith(' ')
                              ? ''
                              : ' ';
                          final newText = '$text$spacer$tag ';
                          _controller.text = newText;
                          _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: newText.length),
                          );
                        },
                        onLongPress: () => _confirmDeleteTag(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: widget.p.surface2,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: widget.p.border.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: widget.p.text2,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: PressableScale(
                      onTap: _showAddTagDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: widget.p.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: widget.p.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.add,
                              size: 12,
                              color: widget.p.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tag',
                              style: TextStyle(
                                color: widget.p.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_sobrietyMode) ...[
              const SizedBox(height: 14),
              // Compact iOS Switch row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_shield,
                        color: widget.p.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mark as Relapse / Reset',
                        style: TextStyle(
                          color: widget.p.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  _IosStyleSwitch(
                    p: widget.p,
                    value: _relapseSelected,
                    onChanged: (value) {
                      setState(() {
                        _relapseSelected = value;
                        if (!value) _shieldActivated = false;
                      });
                    },
                  ),
                ],
              ),
              if (_relapseSelected && _availableShields > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.shield_fill,
                          color: widget.p.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Use Streak Shield ($_availableShields available)',
                          style: TextStyle(
                            color: widget.p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    _IosStyleSwitch(
                      p: widget.p,
                      value: _shieldActivated,
                      activeColor: widget.p.green,
                      onChanged: (value) {
                        setState(() => _shieldActivated = value);
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // Compact Mood Selection row
              Row(
                children: [
                  Icon(CupertinoIcons.smiley, color: widget.p.accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            [
                              'Bored',
                              'Anxious',
                              'Fatigue',
                              'Stressed',
                              'Lonely',
                            ].map((mood) {
                              final isSelected =
                                  _selectedMood == mood.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: _buildTagChip(mood, isSelected, () {
                                  NotekarHaptics.selection('standard');
                                  setState(() {
                                    _selectedMood = isSelected
                                        ? null
                                        : mood.toLowerCase();
                                  });
                                }, widget.p.accent),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Compact Trigger Selection row
              Row(
                children: [
                  Icon(
                    CupertinoIcons.bolt_horizontal,
                    color: widget.p.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
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
                              final triggerKey = trigger
                                  .toLowerCase()
                                  .replaceAll(' ', '_');
                              final isSelected = _selectedTrigger == triggerKey;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: _buildTagChip(trigger, isSelected, () {
                                  NotekarHaptics.selection('standard');
                                  setState(() {
                                    _selectedTrigger = isSelected
                                        ? null
                                        : triggerKey;
                                  });
                                }, widget.p.orange),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    return AppSheet(
      p: widget.p,
      title: widget.title,
      blur: widget.blur,
      largeText: widget.largeText,
      leadingAction: PressableScale(
        onTap: _openBigNote,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.p.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: widget.p.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.plus_app, size: 13, color: widget.p.accent),
              const SizedBox(width: 4),
              Text(
                'Plus',
                style: TextStyle(
                  color: widget.p.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          scrollableContent,
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
                      Navigator.pop(context, const NoteResult('', []));
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : widget.p.surface3,
          borderRadius: BorderRadius.circular(8),
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
        if (_shieldActivated) {
          tags.add('#shielded');
          SharedPreferences.getInstance().then((prefs) {
            final count = prefs.getInt('streak_shields') ?? 1;
            prefs.setInt('streak_shields', (count - 1).clamp(0, 99));
          });
        }
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
          cleanNote = cleanNote.replaceAll('#shielded', '').trim();
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

    // Extract tags from the final note text for the NoteResult
    final tagRegex = RegExp(r'#([a-zA-Z0-9_-]+)');
    final extractedTags = tagRegex
        .allMatches(note)
        .map((m) => m.group(1)!.toLowerCase())
        .toSet()
        .toList();

    // Record usage of these tags
    if (extractedTags.isNotEmpty) {
      TagService.instance.recordUsages(
        extractedTags.map((t) => '#$t').toList(),
      );
    }

    Navigator.pop(context, NoteResult(note, extractedTags));
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

class _IosStyleSwitch extends StatefulWidget {
  const _IosStyleSwitch({
    required this.p,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  final Palette p;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  @override
  State<_IosStyleSwitch> createState() => _IosStyleSwitchState();
}

class _IosStyleSwitchState extends State<_IosStyleSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stretchController;

  @override
  void initState() {
    super.initState();
    _stretchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _stretchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final switchColor = widget.activeColor ?? widget.p.orange;
    final value = widget.value;

    return GestureDetector(
      onTapDown: (_) {
        _stretchController.forward();
      },
      onTapUp: (_) {
        _stretchController.reverse();
      },
      onTapCancel: () {
        _stretchController.reverse();
      },
      onTap: () {
        widget.onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 62,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? switchColor : widget.p.surface3,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: value ? switchColor : widget.p.border),
        ),
        child: RepaintBoundary(
          child: Stack(
            children: [
              // "On" Indicator (Accessibility style)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: value ? 1.0 : 0.0,
                child: Align(
                  alignment: const Alignment(-0.55, 0),
                  child: Container(
                    width: 1.8,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: _stretchController,
                  builder: (context, child) {
                    final stretch = _stretchController.value * 10;
                    return Container(
                      width: 34 + stretch, // Exact same base thumb width 34
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
