import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

/// Dedicated Apple HIG Journal / Big Note canvas for expansive thoughts,
/// reflections, and long-form notes attached to moments.
class BigNoteDialog extends StatefulWidget {
  const BigNoteDialog({
    super.key,
    required this.p,
    this.initialNote = '',
    this.initialImagePath,
    this.initialVoicePath,
    this.initialVoiceDurationMs,
    this.title = 'Plus Note',
    this.saveLabel = 'Done',
    this.allowEmpty = true,
    this.blur = false,
    this.largeText = false,
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

  @override
  State<BigNoteDialog> createState() => _BigNoteDialogState();
}

class _BigNoteDialogState extends State<BigNoteDialog> {
  late final TextEditingController _controller;
  late final UndoHistoryController _undoController;
  final FocusNode _focusNode = FocusNode();

  List<String> _stagedImagePaths = [];
  List<String> _stagedVoicePaths = [];
  List<int> _stagedVoiceDurations = [];
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  List<String> _tags = const [];

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
    _loadTags();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadTags() async {
    final tagService = TagService.instance;
    await tagService.load();
    if (mounted) setState(() => _tags = tagService.customTags);
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

  void _insertTag(String tag) {
    HapticFeedback.selectionClick();
    final text = _controller.text;
    final spacer = text.isEmpty || text.endsWith(' ') || text.endsWith('\n')
        ? ''
        : ' ';
    final newText = '$text$spacer$tag ';
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  Future<void> _showAddTagDialog() async {
    final textController = TextEditingController();
    final created = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('New Hashtag'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CupertinoTextField(
            controller: textController,
            autofocus: true,
            placeholder: 'tag (e.g. journal, gym)',
            style: TextStyle(color: widget.p.text),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '#',
                style: TextStyle(
                  color: widget.p.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Remove $tag?'),
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
      await TagService.instance.removeCustomTag(tag);
      if (mounted) {
        setState(() => _tags = TagService.instance.customTags);
      }
    }
  }

  void _insertSnippet(String snippet) {
    HapticFeedback.selectionClick();
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, snippet);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
  }

  void _insertTimestamp() {
    final now = DateTime.now();
    final timeStr =
        '[${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}] ';
    _insertSnippet(timeStr);
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

  void _save() {
    HapticFeedback.mediumImpact();
    final text = _controller.text.trim();

    // Extract tags from the final note text
    final tagRegex = RegExp(r'#([a-zA-Z0-9_-]+)');
    final extractedTags = tagRegex
        .allMatches(text)
        .map((m) => m.group(1)!.toLowerCase())
        .toSet()
        .toList();

    // Record usage of these tags
    if (extractedTags.isNotEmpty) {
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
        text,
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

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final topPadding = media.padding.top;
    final bottomPadding = media.padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: p.bg,
      body: Column(
        children: [
          // 1. Pinned Apple HIG Frosted Glass Header Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              math.max(topPadding, 12.0),
              16,
              12,
            ),
            decoration: BoxDecoration(
              color: p.surface.withValues(alpha: widget.blur ? 0.85 : 0.98),
              border: Border(
                bottom: BorderSide(
                  color: p.border.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel / Dismiss button
                PressableScale(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Text(
                      widget.allowEmpty ? 'Cancel' : 'Dismiss',
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Center Document Title & Reading Time Badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_rounded, size: 16, color: p.accent),
                    const SizedBox(width: 6),
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controller,
                      builder: (context, _, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: p.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _readingTimeEstimate,
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Done / Save pill button
                PressableScale(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.saveLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Metadata / Telemetry Bar (Date, Word Count, Char Count)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            color: p.surface2.withValues(alpha: 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  datePretty(DateTime.now().millisecondsSinceEpoch),
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, val, _) {
                    final charCount = val.text.length;
                    final wordCount = _wordCount;
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: p.surface3,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$wordCount words',
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: p.surface3,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$charCount chars',
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. Expansive, Distraction-Free Full-Screen Writing Surface
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: TextField(
                controller: _controller,
                undoController: _undoController,
                focusNode: _focusNode,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                scrollPhysics: const BouncingScrollPhysics(),
                style: TextStyle(
                  color: p.text,
                  fontSize: widget.largeText ? 17.5 : 16.0,
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
                decoration: InputDecoration(
                  hintText: 'Write in depth without limits...',
                  hintStyle: TextStyle(
                    color: p.text3.withValues(alpha: 0.7),
                    fontSize: 16.0,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          // 4. Inline Hashtag Suggestions Overlay (above keyboard)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: HashtagSuggestionOverlay(controller: _controller, p: p),
          ),

          // 5. Live Voice Recording Bar (when active)
          if (_isRecording)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.p.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.p.red.withValues(alpha: 0.4)),
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
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: AudioService.instance,
                    builder: (context, _) {
                      final amp =
                          AudioService.instance.currentRecordingAmplitude;
                      const barCount = 7;
                      final factors = [0.35, 0.7, 1.0, 0.85, 1.0, 0.65, 0.4];
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(barCount, (i) {
                          final h = (4.0 + 16.0 * amp * factors[i]).clamp(
                            4.0,
                            18.0,
                          );
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            width: 2.5,
                            height: h,
                            decoration: BoxDecoration(
                              color: widget.p.red,
                              borderRadius: BorderRadius.circular(999),
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

          // 6. Staged Image Preview Bar (Multi-photo strip)
          if (_stagedImagePaths.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.p.surface,
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
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: _buildStagedImageThumbnail(imgPath),
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
                                    color: Colors.black.withValues(alpha: 0.65),
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

          // 7. Staged Voice Preview Bar (Multi-voice notes)
          if (_stagedVoicePaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: List.generate(_stagedVoicePaths.length, (idx) {
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
                      color: widget.p.surface,
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
                              if (idx < _stagedVoiceDurations.length) {
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
            ),

          // 8. Telegram-Style Accessory Toolbar (Pinned Above Virtual Keyboard)
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              math.max(8.0, bottomInset > 0 ? 8.0 : bottomPadding + 6.0),
            ),
            decoration: BoxDecoration(
              color: p.surface2,
              border: Border(
                top: BorderSide(
                  color: p.border.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ROW 1: Telegram Rich Formatting & Undo/Redo Controls
                SingleChildScrollView(
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
                            _buildFormatButton(
                              icon: CupertinoIcons.arrow_uturn_left,
                              label: 'Undo',
                              enabled: _undoController.value.canUndo,
                              onTap: () {
                                if (_undoController.value.canUndo) {
                                  HapticFeedback.lightImpact();
                                  _undoController.undo();
                                }
                              },
                            ),
                            const SizedBox(width: 4),
                            _buildFormatButton(
                              icon: CupertinoIcons.arrow_uturn_right,
                              label: 'Redo',
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
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 1,
                        height: 18,
                        color: p.border.withValues(alpha: 0.5),
                      ),

                      // Bold
                      _buildFormatButton(
                        label: 'B',
                        isBold: true,
                        onTap: () => _wrapOrInsert('**', '**'),
                      ),
                      const SizedBox(width: 4),

                      // Italic
                      _buildFormatButton(
                        label: 'I',
                        isItalic: true,
                        onTap: () => _wrapOrInsert('*', '*'),
                      ),
                      const SizedBox(width: 4),

                      // Monospace / Code
                      _buildFormatButton(
                        label: '` `',
                        isMono: true,
                        onTap: () => _wrapOrInsert('`', '`'),
                      ),
                      const SizedBox(width: 4),

                      // Strikethrough
                      _buildFormatButton(
                        label: 'S',
                        isStrike: true,
                        onTap: () => _wrapOrInsert('~~', '~~'),
                      ),
                      const SizedBox(width: 4),

                      // Quote
                      _buildFormatButton(
                        label: '" "',
                        onTap: () => _insertLinePrefix('> '),
                      ),
                      const SizedBox(width: 4),

                      // Checklist
                      _buildQuickAction(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Checklist',
                        onTap: () => _insertLinePrefix('- [ ] '),
                      ),
                      const SizedBox(width: 4),

                      // Bullet List
                      _buildQuickAction(
                        icon: Icons.format_list_bulleted_rounded,
                        label: 'Bullet',
                        onTap: () => _insertLinePrefix('• '),
                      ),
                      const SizedBox(width: 4),

                      // Timestamp
                      _buildQuickAction(
                        icon: Icons.schedule_rounded,
                        label: 'Time',
                        onTap: _insertTimestamp,
                      ),
                      const SizedBox(width: 6),

                      // Clear
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (context, val, _) {
                          if (val.text.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return PressableScale(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _controller.clear();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: p.text3,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ROW 2: Media Quick Actions & Tags Carousel
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildQuickAction(
                        icon: CupertinoIcons.camera_fill,
                        label: 'Camera',
                        onTap: () => _pickPhoto(ImageSource.camera),
                      ),
                      const SizedBox(width: 6),
                      _buildQuickAction(
                        icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                        label: 'Photo',
                        onTap: () => _pickPhoto(ImageSource.gallery),
                      ),
                      const SizedBox(width: 6),
                      _buildQuickAction(
                        icon: _isRecording
                            ? CupertinoIcons.stop_fill
                            : CupertinoIcons.mic_fill,
                        label: _isRecording ? 'Stop' : 'Voice',
                        onTap: _toggleVoiceRecording,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 1,
                        height: 18,
                        color: p.border.withValues(alpha: 0.5),
                      ),

                      // Tags
                      for (final tag in _tags)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: PressableScale(
                            onTap: () => _insertTag(tag),
                            onLongPress: () => _confirmDeleteTag(tag),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: p.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: p.border.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Add tag button
                      PressableScale(
                        onTap: _showAddTagDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: p.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: p.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 12,
                                color: p.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tag',
                                style: TextStyle(
                                  color: p.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.p.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: widget.p.border.withValues(alpha: 0.5)),
          ),
          child: icon != null
              ? Icon(icon, size: 12, color: widget.p.text2)
              : Text(
                  label ?? '',
                  style: TextStyle(
                    color: widget.p.text2,
                    fontSize: 12,
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

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.p.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: widget.p.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: widget.p.text2),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: widget.p.text2,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
