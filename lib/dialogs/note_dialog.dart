import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notekar/dialogs/big_note_dialog.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/audio_service.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/markdown_text_editing_controller.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/hashtag_suggestion_overlay.dart';
import 'package:notekar/widgets/photo_lightbox_dialog.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WhatsApp-style keyboard-docked note composer with quick tags carousel,
/// expandable vertical height for scrolling, and circular send button.
class NoteDialog extends StatefulWidget {
  const NoteDialog({
    super.key,
    required this.p,
    this.initialNote = '',
    this.initialImagePath,
    this.initialVoicePath,
    this.initialVoiceDurationMs,
    this.title = 'Add Note',
    this.saveLabel = 'Save',
    this.allowEmpty = true,
    this.blur = false,
    this.largeText = false,
    this.hintText,
  });

  final Palette p;
  final String initialNote;
  final String? initialImagePath;
  final String? initialVoicePath;
  final int? initialVoiceDurationMs;
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

  List<String> _stagedImagePaths = [];
  List<String> _stagedVoicePaths = [];
  List<int> _stagedVoiceDurations = [];
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  late final UndoHistoryController _undoController;

  @override
  void initState() {
    super.initState();
    _controller = MarkdownTextEditingController(
      text: widget.initialNote,
      palette: widget.p,
    );
    _undoController = UndoHistoryController();
    if (widget.initialImagePath != null &&
        widget.initialImagePath!.trim().isNotEmpty) {
      _stagedImagePaths = widget.initialImagePath!
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (widget.initialVoicePath != null &&
        widget.initialVoicePath!.trim().isNotEmpty) {
      _stagedVoicePaths = widget.initialVoicePath!
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (widget.initialVoiceDurationMs != null) {
        _stagedVoiceDurations = [widget.initialVoiceDurationMs!];
      }
    }
    _loadSobrietyMode();

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

  @override
  void dispose() {
    _recordingTimer?.cancel();
    if (_isRecording) {
      AudioService.instance.cancelRecording();
    }
    _undoController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_stagedImagePaths.length >= 5) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.selectionClick();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (picked != null) {
        final saved = await MediaStorageService.instance.saveImage(
          xFile: picked,
        );
        if (mounted) {
          setState(() {
            _stagedImagePaths.add(saved);
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<void> _toggleVoiceRecording() async {
    HapticFeedback.mediumImpact();
    if (_isRecording) {
      await _stopVoiceRecording();
    } else {
      if (_stagedVoicePaths.length >= 5) {
        HapticFeedback.heavyImpact();
        return;
      }
      await _startVoiceRecording();
    }
  }

  Future<void> _startVoiceRecording() async {
    final res = await AudioService.instance.startRecording();
    if (res != null && mounted) {
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _isRecording) {
          setState(() => _recordingSeconds++);
        }
      });
    }
  }

  Future<void> _stopVoiceRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    final res = await AudioService.instance.stopRecording();
    if (mounted) {
      setState(() {
        _isRecording = false;
        if (res != null) {
          final path = res['filePath'] as String?;
          final dur =
              (res['durationMs'] as num?)?.toInt() ??
              (_recordingSeconds * 1000);
          if (path != null && path.isNotEmpty) {
            _stagedVoicePaths.add(path);
            _stagedVoiceDurations.add(dur);
          }
        }
      });
    }
  }

  Future<void> _cancelVoiceRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    await AudioService.instance.cancelRecording();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
      });
    }
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(1, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String _formatMs(int ms) {
    final totalSec = ms ~/ 1000;
    return _formatSeconds(totalSec);
  }

  Future<void> _openBigNote() async {
    final result = await Navigator.of(context).push<NoteResult>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => BigNoteDialog(
          p: widget.p,
          initialNote: _controller.text,
          initialImagePath: _stagedImagePaths.isEmpty
              ? null
              : _stagedImagePaths.join('|'),
          initialVoicePath: _stagedVoicePaths.isEmpty
              ? null
              : _stagedVoicePaths.join('|'),
          initialVoiceDurationMs: _stagedVoiceDurations.isEmpty
              ? null
              : _stagedVoiceDurations.fold<int>(0, (int a, int b) => a + b),
          title: 'Plus Note',
          blur: widget.blur,
          largeText: widget.largeText,
        ),
      ),
    );
    if (result != null && mounted) {
      _controller.text = result.note;
      setState(() {
        _stagedImagePaths = result.effectiveImagePaths;
        _stagedVoicePaths = result.effectiveVoicePaths;
        _stagedVoiceDurations = result.voiceDurations;
      });
      Navigator.pop(context, result);
    }
  }

  int get _wordCount {
    final text = _controller.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  String get _readingTimeEstimate {
    final words = _wordCount;
    if (words <= 0) return '<1 min read';
    final mins = (words / 200).ceil();
    return mins <= 1 ? '<1 min read' : '$mins min read';
  }

  void _wrapOrInsert(String prefix, String suffix) {
    HapticFeedback.selectionClick();
    final text = _controller.text;
    final selection = _controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final selectedText = text.substring(selection.start, selection.end);
      final replaced = '$prefix$selectedText$suffix';
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        replaced,
      );
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + prefix.length,
          extentOffset: selection.start + prefix.length + selectedText.length,
        ),
      );
    } else {
      final pos = selection.isValid && selection.start >= 0
          ? selection.start
          : text.length;
      final newText = text.replaceRange(pos, pos, '$prefix$suffix');
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: pos + prefix.length),
      );
    }
  }

  void _insertLinePrefix(String linePrefix) {
    HapticFeedback.selectionClick();
    final text = _controller.text;
    final selection = _controller.selection;
    final pos = selection.isValid && selection.start >= 0
        ? selection.start
        : text.length;

    final isLineStart = pos == 0 || (pos > 0 && text[pos - 1] == '\n');
    final insertion = isLineStart ? linePrefix : '\n$linePrefix';
    final newText = text.replaceRange(pos, pos, insertion);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + insertion.length),
    );
  }

  Future<void> _loadSobrietyMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _sobrietyMode = prefs.getBool('enable_sobriety_mode') ?? false;
      _availableShields = prefs.getInt('streak_shields') ?? 1;
    });
  }

  Widget _buildFormattingButton({
    String? label,
    IconData? icon,
    bool isBold = false,
    bool isItalic = false,
    bool isMono = false,
    bool isStrike = false,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      enabled: enabled,
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
          decoration: BoxDecoration(
            color: widget.p.surface2,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: widget.p.border.withValues(alpha: 0.5)),
          ),
          child: icon != null
              ? Icon(icon, size: 11.5, color: widget.p.text2)
              : Text(
                  label ?? '',
                  style: TextStyle(
                    color: widget.p.text2,
                    fontSize: 11.5,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    fontFamily: isMono ? 'monospace' : null,
                    decoration: isStrike ? TextDecoration.lineThrough : null,
                  ),
                ),
        ),
      ),
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
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
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
                                  ),
                                  if (value.text.trim().isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: widget.p.surface3,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '$_wordCount words • $_readingTimeEstimate',
                                        style: TextStyle(
                                          color: widget.p.text3,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          const Spacer(),
                          // Telegram-style Extra Mode: Expand into Full-Screen Writing Canvas
                          PressableScale(
                            onTap: _openBigNote,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: widget.p.surface3,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.arrow_up_left_arrow_down_right,
                                size: 13,
                                color: widget.p.text2,
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
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_up_rounded,
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
                                Icons.close_rounded,
                                size: 12,
                                color: widget.p.text2,
                              ),
                            ),
                          ),
                        ],
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
                                        Icons.security_rounded,
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
                                          Icons.security_rounded,
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

                      // Active Voice Recording Indicator Bar
                      if (_isRecording) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.p.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: widget.p.red.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recording ${_formatSeconds(_recordingSeconds)}',
                                style: TextStyle(
                                  color: widget.p.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Dynamic Amplitude Waveform Bars
                              AnimatedBuilder(
                                animation: AudioService.instance,
                                builder: (context, _) {
                                  final amp = AudioService
                                      .instance
                                      .currentRecordingAmplitude;
                                  const barCount = 7;
                                  final factors = [
                                    0.35,
                                    0.7,
                                    1.0,
                                    0.85,
                                    1.0,
                                    0.65,
                                    0.4,
                                  ];
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(barCount, (i) {
                                      final h = (4.0 + 16.0 * amp * factors[i])
                                          .clamp(4.0, 18.0);
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 1.5,
                                        ),
                                        width: 2.5,
                                        height: h,
                                        decoration: BoxDecoration(
                                          color: widget.p.red,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                              const Spacer(),
                              PressableScale(
                                onTap: _cancelVoiceRecording,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    CupertinoIcons.trash,
                                    size: 16,
                                    color: widget.p.text3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PressableScale(
                                onTap: _stopVoiceRecording,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.p.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.checkmark,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Done',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Staged Image Preview Bar (Multi-photo strip)
                      if (_stagedImagePaths.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
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
                                children: [
                                  Icon(
                                    CupertinoIcons.photo_fill_on_rectangle_fill,
                                    size: 13,
                                    color: widget.p.accent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${_stagedImagePaths.length}/5 Photos attached',
                                    style: TextStyle(
                                      color: widget.p.text,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 52,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _stagedImagePaths.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, idx) {
                                    final imgPath = _stagedImagePaths[idx];
                                    return Stack(
                                      children: [
                                        PressableScale(
                                          onTap: () {
                                            PhotoLightboxDialog.show(
                                              context,
                                              p: widget.p,
                                              imagePaths: _stagedImagePaths,
                                              initialIndex: idx,
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: SizedBox(
                                              width: 52,
                                              height: 52,
                                              child: _buildStagedImageThumbnail(
                                                imgPath,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: PressableScale(
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              setState(() {
                                                _stagedImagePaths.removeAt(idx);
                                              });
                                            },
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.65,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  CupertinoIcons.xmark,
                                                  size: 10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Staged Voice Preview Bar (Multi-voice notes)
                      if (_stagedVoicePaths.isNotEmpty) ...[
                        Column(
                          children: List.generate(_stagedVoicePaths.length, (
                            idx,
                          ) {
                            final dur = idx < _stagedVoiceDurations.length
                                ? _stagedVoiceDurations[idx]
                                : 0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.p.surface2,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.p.border.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.mic_fill,
                                    size: 15,
                                    color: widget.p.accent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Voice Note ${idx + 1} (${_formatMs(dur)})',
                                    style: TextStyle(
                                      color: widget.p.text,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  PressableScale(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _stagedVoicePaths.removeAt(idx);
                                        if (idx <
                                            _stagedVoiceDurations.length) {
                                          _stagedVoiceDurations.removeAt(idx);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
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
                            );
                          }),
                        ),
                      ],

                      // Media Action Chips Row (Camera, Photo, Mic)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            PressableScale(
                              onTap: () => _pickPhoto(ImageSource.camera),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
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
                                      CupertinoIcons.camera_fill,
                                      size: 12,
                                      color: widget.p.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Camera',
                                      style: TextStyle(
                                        color: widget.p.text2,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            PressableScale(
                              onTap: () => _pickPhoto(ImageSource.gallery),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
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
                                      CupertinoIcons
                                          .photo_fill_on_rectangle_fill,
                                      size: 12,
                                      color: widget.p.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Photo',
                                      style: TextStyle(
                                        color: widget.p.text2,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            PressableScale(
                              onTap: _toggleVoiceRecording,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _isRecording
                                      ? widget.p.red.withValues(alpha: 0.15)
                                      : widget.p.surface2,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: _isRecording
                                        ? widget.p.red
                                        : widget.p.border.withValues(
                                            alpha: 0.6,
                                          ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isRecording
                                          ? CupertinoIcons.stop_fill
                                          : CupertinoIcons.mic_fill,
                                      size: 12,
                                      color: _isRecording
                                          ? widget.p.red
                                          : widget.p.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isRecording ? 'Stop' : 'Voice',
                                      style: TextStyle(
                                        color: _isRecording
                                            ? widget.p.red
                                            : widget.p.text2,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            PressableScale(
                              onTap: _openBigNote,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
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
                                      CupertinoIcons.doc_text_fill,
                                      size: 12,
                                      color: widget.p.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Note',
                                      style: TextStyle(
                                        color: widget.p.text2,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_sobrietyMode) ...[
                              const SizedBox(width: 6),
                              PressableScale(
                                onTap: () {
                                  setState(
                                    () =>
                                        _showSobrietyTray = !_showSobrietyTray,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _relapseSelected
                                        ? widget.p.orange.withValues(
                                            alpha: 0.15,
                                          )
                                        : widget.p.surface2,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _relapseSelected
                                          ? widget.p.orange
                                          : widget.p.border.withValues(
                                              alpha: 0.6,
                                            ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons
                                            .exclamationmark_shield_fill,
                                        size: 12,
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
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Inline Hashtag Autocomplete Suggestions Overlay
                      HashtagSuggestionOverlay(
                        controller: _controller,
                        p: widget.p,
                      ),

                      // Telegram-style Keyboard-Docked Rich Formatting Bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              // Undo / Redo
                              ListenableBuilder(
                                listenable: _undoController,
                                builder: (context, _) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildFormattingButton(
                                      icon: CupertinoIcons.arrow_uturn_left,
                                      enabled: _undoController.value.canUndo,
                                      onTap: () {
                                        if (_undoController.value.canUndo) {
                                          HapticFeedback.lightImpact();
                                          _undoController.undo();
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    _buildFormattingButton(
                                      icon: CupertinoIcons.arrow_uturn_right,
                                      enabled: _undoController.value.canRedo,
                                      onTap: () {
                                        if (_undoController.value.canRedo) {
                                          HapticFeedback.lightImpact();
                                          _undoController.redo();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                width: 1,
                                height: 16,
                                color: widget.p.border.withValues(alpha: 0.5),
                              ),

                              // Bold
                              _buildFormattingButton(
                                label: 'B',
                                isBold: true,
                                onTap: () => _wrapOrInsert('**', '**'),
                              ),
                              const SizedBox(width: 4),

                              // Italic
                              _buildFormattingButton(
                                label: 'I',
                                isItalic: true,
                                onTap: () => _wrapOrInsert('*', '*'),
                              ),
                              const SizedBox(width: 4),

                              // Monospace / Code
                              _buildFormattingButton(
                                label: '` `',
                                isMono: true,
                                onTap: () => _wrapOrInsert('`', '`'),
                              ),
                              const SizedBox(width: 4),

                              // Strikethrough
                              _buildFormattingButton(
                                label: 'S',
                                isStrike: true,
                                onTap: () => _wrapOrInsert('~~', '~~'),
                              ),
                              const SizedBox(width: 4),

                              // Blockquote
                              _buildFormattingButton(
                                label: '" "',
                                onTap: () => _insertLinePrefix('> '),
                              ),
                              const SizedBox(width: 4),

                              // Checklist
                              _buildFormattingButton(
                                label: '[ ]',
                                onTap: () => _insertLinePrefix('- [ ] '),
                              ),
                              const SizedBox(width: 4),

                              // Bullet List
                              _buildFormattingButton(
                                label: '•',
                                onTap: () => _insertLinePrefix('• '),
                              ),
                            ],
                          ),
                        ),
                      ),

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
                                undoController: _undoController,
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

  Widget _buildStagedImageThumbnail(String imagePath) {
    final file = MediaStorageService.instance.resolveFileSync(imagePath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return FutureBuilder<File>(
      future: MediaStorageService.instance.resolveFile(imagePath),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.existsSync()) {
          return Image.file(snapshot.data!, fit: BoxFit.cover);
        }
        return Container(
          color: widget.p.surface3,
          child: Icon(CupertinoIcons.photo, size: 20, color: widget.p.text3),
        );
      },
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

    final hasMedia =
        _stagedImagePaths.isNotEmpty || _stagedVoicePaths.isNotEmpty;
    if (!widget.allowEmpty && note.isEmpty && !hasMedia) {
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

    // Record usage of these tags and auto-create any newly typed tags
    if (extractedTags.isNotEmpty) {
      for (final t in extractedTags) {
        final clean = '#$t';
        if (TagService.instance.findActivityTag(clean) == null) {
          unawaited(TagService.instance.addCustomTag(clean));
        }
      }
      TagService.instance.recordUsages(
        extractedTags.map((t) => '#$t').toList(),
      );
    }

    final pipeImages = _stagedImagePaths.isEmpty
        ? null
        : _stagedImagePaths.join('|');
    final pipeVoices = _stagedVoicePaths.isEmpty
        ? null
        : _stagedVoicePaths.join('|');
    final totalDuration = _stagedVoiceDurations.isEmpty
        ? null
        : _stagedVoiceDurations.fold(0, (a, b) => a + b);

    Navigator.pop(
      context,
      NoteResult(
        note,
        extractedTags,
        imagePath: pipeImages,
        voicePath: pipeVoices,
        voiceDurationMs: totalDuration,
        imagePaths: _stagedImagePaths,
        voicePaths: _stagedVoicePaths,
        voiceDurations: _stagedVoiceDurations,
      ),
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
