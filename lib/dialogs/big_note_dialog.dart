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
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/glass.dart';
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
  final FocusNode _focusNode = FocusNode();

  String? _stagedImagePath;
  String? _stagedVoicePath;
  int? _stagedVoiceDurationMs;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  List<String> _tags = const [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _stagedImagePath = widget.initialImagePath;
    _stagedVoicePath = widget.initialVoicePath;
    _stagedVoiceDurationMs = widget.initialVoiceDurationMs;
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
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _controller.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
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

  Future<void> _pickPhoto(ImageSource source) async {
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
            _stagedImagePath = saved;
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
          _stagedVoicePath = res['filePath'] as String?;
          _stagedVoiceDurationMs =
              (res['durationMs'] as num?)?.toInt() ??
              (_recordingSeconds * 1000);
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

  Widget _buildStagedImageThumbnail() {
    if (_stagedImagePath == null) return const SizedBox.shrink();
    final file = MediaStorageService.instance.resolveFileSync(_stagedImagePath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return FutureBuilder<File>(
      future: MediaStorageService.instance.resolveFile(_stagedImagePath),
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

    Navigator.pop(
      context,
      NoteResult(
        text,
        extractedTags,
        imagePath: _stagedImagePath,
        voicePath: _stagedVoicePath,
        voiceDurationMs: _stagedVoiceDurationMs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      padding:
          MediaQuery.viewInsetsOf(context) +
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: Glass(
            p: p,
            blur: widget.blur,
            radius: 24,
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
              child: Column(
                children: [
                  // Navigation Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: BoxDecoration(
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description_rounded,
                              size: 16,
                              color: p.accent,
                            ),
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
                          ],
                        ),
                        PressableScale(
                          onTap: _save,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
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

                  // Metadata bar (Date, Word Count, Character Count)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    color: p.surface2.withValues(alpha: 0.4),
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

                  // Expansive Writing Canvas
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: TextField(
                        controller: _controller,
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
                        style: TextStyle(
                          color: p.text,
                          fontSize: widget.largeText ? 17 : 15.5,
                          height: 1.45,
                          letterSpacing: 0.1,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write in depth without limits...',
                          hintStyle: TextStyle(
                            color: p.text3.withValues(alpha: 0.7),
                            fontSize: 15.5,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),

                  // Live Voice Recording Bar
                  if (_isRecording)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.p.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
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

                  // Staged Image Preview Bar
                  if (_stagedImagePath != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.p.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.p.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: _buildStagedImageThumbnail(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Photo attached',
                                  style: TextStyle(
                                    color: widget.p.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tap ✕ to remove',
                                  style: TextStyle(
                                    color: widget.p.text3,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PressableScale(
                            onTap: () =>
                                setState(() => _stagedImagePath = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: widget.p.surface3,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.xmark,
                                size: 13,
                                color: widget.p.text2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Staged Voice Preview Bar
                  if (_stagedVoicePath != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
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
                            size: 16,
                            color: widget.p.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Voice Note (${_formatMs(_stagedVoiceDurationMs ?? 0)})',
                            style: TextStyle(
                              color: widget.p.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          PressableScale(
                            onTap: () => setState(() {
                              _stagedVoicePath = null;
                              _stagedVoiceDurationMs = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: widget.p.surface3,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.xmark,
                                size: 13,
                                color: widget.p.text2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Apple Notes Accessory Toolbar (Tags + Quick Insert Actions)
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      14,
                      8,
                      14,
                      math.max(8.0, bottomInset > 0 ? 8.0 : 12.0),
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
                        // Horizontal scrollable tags with Add button
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
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
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: p.border.withValues(
                                            alpha: 0.7,
                                          ),
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

                        const SizedBox(height: 8),

                        // Quick Markdown/Format Actions + Media Actions
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
                                icon:
                                    CupertinoIcons.photo_fill_on_rectangle_fill,
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
                              const SizedBox(width: 6),
                              _buildQuickAction(
                                icon: Icons.schedule_rounded,
                                label: 'Time',
                                onTap: _insertTimestamp,
                              ),
                              const SizedBox(width: 6),
                              _buildQuickAction(
                                icon: Icons.format_list_bulleted_rounded,
                                label: 'Bullet',
                                onTap: () => _insertSnippet('\n• '),
                              ),
                              const SizedBox(width: 6),
                              _buildQuickAction(
                                icon: Icons.check_circle_outline_rounded,
                                label: 'Checklist',
                                onTap: () => _insertSnippet('\n[ ] '),
                              ),
                              const SizedBox(width: 8),
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
                      ],
                    ),
                  ),
                ],
              ),
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
