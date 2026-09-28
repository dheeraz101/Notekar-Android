import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/big_note_dialog.dart';
import 'package:notekar/models/activity_tag.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WhatsApp-style keyboard-docked note composer with quick tags carousel,
/// expandable vertical height for scrolling, and circular send button.
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
  bool _isExpanded = false;

  bool _sobrietyMode = false;
  bool _showSobrietyTray = false;
  String? _selectedMood;
  String? _selectedTrigger;
  bool _relapseSelected = false;
  int _availableShields = 0;
  bool _shieldActivated = false;

  List<ActivityTag> _activityTags = const [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _loadSobrietyMode();
    _loadTags();

    if (widget.initialNote.contains('#relapse')) {
      _relapseSelected = true;
      _showSobrietyTray = true;
    }
    if (widget.initialNote.contains('#shielded')) {
      _shieldActivated = true;
      _showSobrietyTray = true;
    }

    // Auto-focus keyboard on appearance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadTags() async {
    final tagService = TagService.instance;
    await tagService.load();
    if (mounted) setState(() => _activityTags = tagService.activityTags);
  }

  Future<void> _showAddTagDialog() async {
    final textController = TextEditingController();
    final created = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('New Tag'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CupertinoTextField(
            controller: textController,
            autofocus: true,
            placeholder: 'tag (e.g. Walking, Gym)',
            style: TextStyle(color: widget.p.text),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final raw = textController.text.trim();
              if (raw.isEmpty) return;
              Navigator.pop(ctx, raw);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (created != null && created.isNotEmpty) {
      final added = await TagService.instance.addCustomTag(created);
      if (added && mounted) {
        setState(() => _activityTags = TagService.instance.activityTags);
      }
    }
  }

  Future<void> _confirmDeleteTag(ActivityTag tag) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Remove ${tag.label}?'),
        content: const Text(
          'Do you want to remove this tag from your quick list?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TagService.instance.removeActivityTag(tag.id);
      if (mounted) {
        setState(() => _activityTags = TagService.instance.activityTags);
      }
    }
  }

  Future<void> _openBigNote() async {
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
    if (!mounted) return;
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

  void _insertTag(String tag) {
    final text = _controller.text;
    final spacer = text.isEmpty || text.endsWith(' ') ? '' : ' ';
    final newText = '$text$spacer$tag ';
    _controller.text = newText;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardHeight = media.viewInsets.bottom;
    final bottomPadding = media.padding.bottom;
    final screenHeight = media.size.height;

    // Expandable height bounds
    final keyboardSafeSpace =
        screenHeight -
        (keyboardHeight > 0 ? (keyboardHeight + 40) : (bottomPadding + 60));
    final expandedMaxHeight = (screenHeight * 0.75).clamp(
      320.0,
      keyboardSafeSpace > 320.0 ? keyboardSafeSpace : 320.0,
    );
    final compactMaxHeight = 120.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutQuad,
          padding: EdgeInsets.only(
            bottom: keyboardHeight > 0 ? keyboardHeight : 0,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.p.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              border: Border(
                top: BorderSide(
                  color: widget.p.border.withValues(alpha: 0.65),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: SafeArea(
                top: false,
                bottom: keyboardHeight == 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top header row: Title, Plus button, Expand toggle, Close
                      Row(
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: widget.p.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _controller,
                            builder: (context, value, _) {
                              final count = value.text.length;
                              final remaining = maxNoteLength - count;
                              final alert = remaining <= 20;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: alert
                                      ? widget.p.red.withValues(alpha: 0.15)
                                      : widget.p.surface3,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$count/$maxNoteLength',
                                  style: TextStyle(
                                    color: alert
                                        ? widget.p.red
                                        : widget.p.text3,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          // Plus Full Note Button
                          PressableScale(
                            onTap: _openBigNote,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.p.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: widget.p.accent.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.plus_app,
                                    size: 13,
                                    color: widget.p.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Plus',
                                    style: TextStyle(
                                      color: widget.p.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Expand / Collapse Height Toggle
                          PressableScale(
                            onTap: () {
                              setState(() => _isExpanded = !_isExpanded);
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: widget.p.surface3,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isExpanded
                                    ? CupertinoIcons.chevron_down
                                    : CupertinoIcons.chevron_up,
                                size: 14,
                                color: widget.p.text2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Close / Cancel Button
                          PressableScale(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: widget.p.surface3,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.xmark,
                                size: 12,
                                color: widget.p.text2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Quick Tags Carousel (WhatsApp style directly above text field)
                      SizedBox(
                        height: 28,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: PressableScale(
                                onTap: _showAddTagDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.p.accent.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: widget.p.accent.withValues(
                                        alpha: 0.3,
                                      ),
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
                            for (final tag in _activityTags)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: PressableScale(
                                  onTap: () => _insertTag(tag.hashtag),
                                  onLongPress: () => _confirmDeleteTag(tag),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.p.surface2,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: widget.p.border.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          tag.icon,
                                          size: 12,
                                          color: widget.p.accent,
                                        ),
                                        const SizedBox(width: 4.5),
                                        Text(
                                          tag.label,
                                          style: TextStyle(
                                            color: widget.p.text2,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (_sobrietyMode)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: PressableScale(
                                  onTap: () {
                                    setState(
                                      () => _showSobrietyTray =
                                          !_showSobrietyTray,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _relapseSelected
                                          ? widget.p.orange.withValues(
                                              alpha: 0.15,
                                            )
                                          : widget.p.surface3,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: _relapseSelected
                                            ? widget.p.orange
                                            : widget.p.border,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons
                                              .exclamationmark_shield_fill,
                                          size: 13,
                                          color: _relapseSelected
                                              ? widget.p.orange
                                              : widget.p.text3,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _relapseSelected
                                              ? 'Relapse'
                                              : 'Sobriety',
                                          style: TextStyle(
                                            color: _relapseSelected
                                                ? widget.p.orange
                                                : widget.p.text2,
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

                      // Optional Sobriety Controls Tray
                      if (_sobrietyMode && _showSobrietyTray) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.p.surface2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: widget.p.border.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.exclamationmark_shield,
                                        color: widget.p.orange,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Mark as Relapse / Reset',
                                        style: TextStyle(
                                          color: widget.p.text,
                                          fontSize: 12,
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
                              if (_relapseSelected &&
                                  _availableShields > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.shield_fill,
                                          color: widget.p.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Use Streak Shield ($_availableShields left)',
                                          style: TextStyle(
                                            color: widget.p.text,
                                            fontSize: 12,
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
                                        setState(
                                          () => _shieldActivated = value,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (final mood in [
                                      'Bored',
                                      'Anxious',
                                      'Fatigue',
                                      'Stressed',
                                      'Lonely',
                                    ])
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: _buildTagChip(
                                          mood,
                                          _selectedMood == mood.toLowerCase(),
                                          () {
                                            setState(() {
                                              _selectedMood =
                                                  _selectedMood ==
                                                      mood.toLowerCase()
                                                  ? null
                                                  : mood.toLowerCase();
                                            });
                                          },
                                          widget.p.accent,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Input Bar Row: WhatsApp style (Input box on left + Circular action button on right)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              constraints: BoxConstraints(
                                minHeight: 46,
                                maxHeight: _isExpanded
                                    ? expandedMaxHeight
                                    : compactMaxHeight,
                              ),
                              decoration: BoxDecoration(
                                color: widget.p.surface3,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _showWarning
                                      ? widget.p.red
                                      : widget.p.border.withValues(alpha: 0.8),
                                ),
                              ),
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                maxLength:
                                    widget.initialNote.length > maxNoteLength
                                    ? null
                                    : maxNoteLength,
                                maxLengthEnforcement: MaxLengthEnforcement
                                    .truncateAfterCompositionEnds,
                                minLines: _isExpanded ? 7 : 2,
                                maxLines: _isExpanded ? 14 : 4,
                                textAlignVertical: TextAlignVertical.top,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                autocorrect: true,
                                enableSuggestions: true,
                                scrollPadding: EdgeInsets.zero,
                                style: TextStyle(
                                  color: widget.p.text,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  hintText:
                                      widget.hintText ??
                                      'What should this moment remember?',
                                  hintStyle: TextStyle(
                                    color: widget.p.text3,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (text) {
                                  if (_showWarning) {
                                    setState(() => _showWarning = false);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Circular WhatsApp-style Send/Save Button (Minimal, non-glowing)
                          PressableScale(
                            onTap: _saveNote,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.p.accent,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_showWarning)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            'Write something to save.',
                            style: TextStyle(
                              color: widget.p.red,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            fontSize: 11,
            fontWeight: FontWeight.w700,
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
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? switchColor : widget.p.surface3,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: value ? switchColor : widget.p.border),
        ),
        child: RepaintBoundary(
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: value ? 1.0 : 0.0,
                child: Align(
                  alignment: const Alignment(-0.55, 0),
                  child: Container(
                    width: 1.8,
                    height: 9,
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
                    final stretch = _stretchController.value * 6;
                    return Container(
                      width: 24 + stretch,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
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
