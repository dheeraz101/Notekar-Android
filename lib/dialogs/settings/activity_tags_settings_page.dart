// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/activity_tag.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';

/// Standalone Settings Page for managing the 15 Researched Activity Quick Tags.
class ActivityTagsSettingsPage extends StatefulWidget {
  const ActivityTagsSettingsPage({
    super.key,
    required this.p,
    this.onTagsChanged,
  });

  final Palette p;
  final VoidCallback? onTagsChanged;

  @override
  State<ActivityTagsSettingsPage> createState() =>
      _ActivityTagsSettingsPageState();
}

class _ActivityTagsSettingsPageState extends State<ActivityTagsSettingsPage> {
  final TagService _tagService = TagService.instance;
  List<ActivityTag> _tags = [];
  bool _loading = true;

  static final List<int> _availableGlyphs = [
    CupertinoIcons.tag_fill.codePoint,
    CupertinoIcons.compass_fill.codePoint,
    CupertinoIcons.flame_fill.codePoint,
    CupertinoIcons.book_fill.codePoint,
    CupertinoIcons.device_laptop.codePoint,
    CupertinoIcons.drop_fill.codePoint,
    CupertinoIcons.sparkles.codePoint,
    CupertinoIcons.doc_text_fill.codePoint,
    CupertinoIcons.heart_circle_fill.codePoint,
    CupertinoIcons.car_fill.codePoint,
    CupertinoIcons.flame.codePoint,
    CupertinoIcons.trash.codePoint,
    CupertinoIcons.gamecontroller_fill.codePoint,
    CupertinoIcons.person_2_fill.codePoint,
    CupertinoIcons.suit_club_fill.codePoint,
    CupertinoIcons.moon_fill.codePoint,
  ];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    await _tagService.load();
    if (mounted) {
      setState(() {
        _tags = List.from(_tagService.activityTags);
        _loading = false;
      });
    }
  }

  Future<void> _promptAddOrEditTag([ActivityTag? existing]) async {
    HapticFeedback.lightImpact();
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    int selectedGlyph = existing?.iconCodePoint ?? _availableGlyphs[0];

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: widget.p.name == 'light'
              ? Brightness.light
              : Brightness.dark,
          primaryColor: widget.p.accent,
        ),
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => CupertinoAlertDialog(
            title: Text(
              existing == null
                  ? 'New Activity Tag'.localized(context)
                  : 'Edit Activity Tag'.localized(context),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoTextField(
                    controller: labelCtrl,
                    autofocus: true,
                    placeholder: 'e.g. Journaling, Cycling'.localized(context),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: widget.p.surface3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.p.border.withValues(alpha: 0.6),
                      ),
                    ),
                    style: TextStyle(color: widget.p.text, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select Glyph'.localized(context).toUpperCase(),
                    style: TextStyle(
                      color: widget.p.text3,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _availableGlyphs.map((glyph) {
                      final isSelected = selectedGlyph == glyph;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() => selectedGlyph = glyph);
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? widget.p.accent.withValues(alpha: 0.2)
                                : widget.p.surface3,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? widget.p.accent
                                  : widget.p.border.withValues(alpha: 0.4),
                              width: isSelected ? 1.8 : 0.8,
                            ),
                          ),
                          child: Icon(
                            ActivityTag.iconForCodePoint(glyph),
                            size: 16,
                            color: isSelected
                                ? widget.p.accent
                                : widget.p.text2,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(dialogCtx, false),
                child: Text('Cancel'.localized(context)),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  final text = labelCtrl.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.pop(dialogCtx, true);
                  }
                },
                child: Text('Save'.localized(context)),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      final label = labelCtrl.text.trim();
      if (existing == null) {
        final newTag = ActivityTag(
          id: 'act_${DateTime.now().millisecondsSinceEpoch}',
          label: label,
          iconCodePoint: selectedGlyph,
        );
        await _tagService.addActivityTag(newTag);
      } else {
        final oldLabel = existing.label;
        final updated = existing.copyWith(
          label: label,
          iconCodePoint: selectedGlyph,
        );
        await _tagService.updateActivityTag(updated);
        if (oldLabel.toLowerCase() != label.toLowerCase()) {
          final updatedNotes = await _tagService.renameTagAcrossAllNotes(
            oldTag: oldLabel,
            newTag: label,
          );
          if (mounted && updatedNotes > 0) {
            showIosPillToast(
              context: context,
              p: widget.p,
              message: 'Updated $updatedNotes notes to #$label'.localized(
                context,
              ),
              icon: Icons.check_circle_rounded,
            );
          }
        }
      }
      await _loadTags();
      widget.onTagsChanged?.call();
    }
  }

  Future<void> _confirmDeleteTag(ActivityTag tag) async {
    HapticFeedback.lightImpact();
    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('Delete "${tag.label}"?'.localized(context)),
        message: Text(
          'Choose whether to remove this tag from your quick list or remove it from all historical notes.'
              .localized(context),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'quick_only'),
            child: Text('Remove from Quick List Only'.localized(context)),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, 'all_notes'),
            child: Text('Remove from All Existing Notes'.localized(context)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel'.localized(context)),
        ),
      ),
    );

    if (action != null && mounted) {
      await _tagService.removeActivityTag(tag.id);
      if (action == 'all_notes') {
        final count = await _tagService.removeTagFromAllNotes(tag: tag.label);
        if (mounted && count > 0) {
          showIosPillToast(
            context: context,
            p: widget.p,
            message: 'Removed from $count notes'.localized(context),
            icon: Icons.delete_sweep_rounded,
          );
        }
      }
      await _loadTags();
      widget.onTagsChanged?.call();
    }
  }

  Future<void> _confirmResetDefaults() async {
    HapticFeedback.lightImpact();
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Reset Quick Tags?'.localized(context)),
        content: Text(
          'Restore the 15 standard research-backed activity tags?'.localized(
            context,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.localized(context)),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Reset'.localized(context)),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await _tagService.resetToDefaultTags();
      await _loadTags();
      widget.onTagsChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: widget.p,
          text:
              'Activity tags empower instant 1-tap logging across note dialogs, notification motivation panel, and widget quick session popups.'
                  .localized(context),
        ),
        const SizedBox(height: 16),

        // Header Actions Row: Add Tag & Reset to Defaults
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PressableScale(
              onTap: () => _promptAddOrEditTag(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.p.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.p.accent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.add, size: 14, color: widget.p.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Add Quick Tag'.localized(context),
                      style: TextStyle(
                        color: widget.p.accent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PressableScale(
              onTap: _confirmResetDefaults,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.p.surface3,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.p.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_counterclockwise,
                      size: 13,
                      color: widget.p.text2,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Reset (15)'.localized(context),
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
          ],
        ),
        const SizedBox(height: 16),

        // Reorderable Grouped List
        Container(
          decoration: BoxDecoration(
            color: widget.p.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.p.border.withValues(alpha: 0.6)),
          ),
          clipBehavior: Clip.antiAlias,
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tags.length,
            // ignore: deprecated_member_use
            onReorder: (oldIdx, newIdx) async {
              setState(() {
                if (oldIdx < newIdx) newIdx -= 1;
                final tag = _tags.removeAt(oldIdx);
                _tags.insert(newIdx, tag);
              });
              await _tagService.reorderActivityTags(oldIdx, newIdx);
              widget.onTagsChanged?.call();
            },
            itemBuilder: (ctx, idx) {
              final tag = _tags[idx];
              return Container(
                key: ValueKey(tag.id),
                decoration: BoxDecoration(
                  border: idx < _tags.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: widget.p.border.withValues(alpha: 0.35),
                          ),
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // Drag Handle Indicator
                      ReorderableDragStartListener(
                        index: idx,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            CupertinoIcons.bars,
                            size: 18,
                            color: widget.p.text3.withValues(alpha: 0.7),
                          ),
                        ),
                      ),

                      // Glyph icon badge
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: widget.p.surface3,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(tag.icon, size: 17, color: widget.p.accent),
                      ),
                      const SizedBox(width: 12),

                      // Label & slug
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tag.label,
                              style: TextStyle(
                                color: widget.p.text,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              tag.hashtag,
                              style: TextStyle(
                                color: widget.p.text3,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit button
                      PressableScale(
                        onTap: () => _promptAddOrEditTag(tag),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: widget.p.surface3,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CupertinoIcons.square_pencil,
                            size: 14,
                            color: widget.p.text2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Delete button
                      PressableScale(
                        onTap: () => _confirmDeleteTag(tag),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: widget.p.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CupertinoIcons.trash,
                            size: 14,
                            color: widget.p.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}
