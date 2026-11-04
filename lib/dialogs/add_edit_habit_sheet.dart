import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/checkpoint_service.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Apple HIG bottom sheet to create or edit habit checkpoints.
class AddEditHabitSheet extends StatefulWidget {
  const AddEditHabitSheet({
    super.key,
    required this.p,
    this.preset,
    this.onSaved,
  });

  final Palette p;
  final CheckpointPreset? preset;
  final VoidCallback? onSaved;

  static Future<bool?> show(
    BuildContext context, {
    required Palette p,
    CheckpointPreset? preset,
    VoidCallback? onSaved,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: kTelegramSpringSheetAnimation,
      builder: (ctx) =>
          AddEditHabitSheet(p: p, preset: preset, onSaved: onSaved),
    );
  }

  @override
  State<AddEditHabitSheet> createState() => _AddEditHabitSheetState();
}

class _AddEditHabitSheetState extends State<AddEditHabitSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _emojiController;
  late String _selectedEmoji;
  late String _selectedCategory;
  int? _targetMinuteOfDay;
  bool _isAnytime = false;

  static const List<String> _popularEmojis = [
    '🌅',
    '🪥',
    '🍳',
    '🥗',
    '🏋️',
    '🧘',
    '📖',
    '💧',
    '🎯',
    '🍽️',
    '🌙',
    '✍️',
    '💊',
    '🌿',
    '💻',
    '🧹',
  ];

  List<String> _availableCategories = [
    'Routine',
    'Health',
    'Mind',
    'Productivity',
    'Personal',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.preset;
    _selectedEmoji = p?.emoji ?? '🎯';
    _selectedCategory = p?.category ?? 'Routine';
    _targetMinuteOfDay = p?.targetMinuteOfDay ?? 540; // 09:00 AM default
    _isAnytime = p?.targetMinuteOfDay == null;
    _titleController = TextEditingController(text: p?.label ?? '');
    _emojiController = TextEditingController(text: _selectedEmoji);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final serviceCats = await CategoryService.instance.getCategories();
    if (mounted) {
      setState(() {
        final merged = <String>{..._availableCategories, ...serviceCats};
        if (_selectedCategory.isNotEmpty) {
          merged.add(_selectedCategory);
        }
        _availableCategories = merged.toList();
      });
    }
  }

  Future<void> _showNewCategoryDialog() async {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();
    Color selectedColor = CategoryService.appleHigColors[0];

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: widget.p.isDark ? Brightness.dark : Brightness.light,
          primaryColor: widget.p.accent,
        ),
        child: StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return CupertinoAlertDialog(
              title: Text('New Category'.localized(ctx)),
              content: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoTextField(
                      controller: textController,
                      autofocus: true,
                      placeholder: 'Category Name (e.g. Study, Fitness)'
                          .localized(ctx),
                      placeholderStyle: TextStyle(color: widget.p.text3),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 15,
                      inputFormatters: [LengthLimitingTextInputFormatter(15)],
                      style: TextStyle(color: widget.p.text),
                      decoration: BoxDecoration(
                        color: widget.p.isDark
                            ? widget.p.surface3
                            : const Color(0xFFE5E5EA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.p.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final col in CategoryService.appleHigColors) ...[
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setDialogState(() => selectedColor = col);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: col,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selectedColor == col
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: selectedColor == col
                                        ? [
                                            BoxShadow(
                                              color: col.withValues(alpha: 0.5),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: selectedColor == col
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 13,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Cancel'.localized(ctx)),
                  onPressed: () => Navigator.pop(ctx, false),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Add'.localized(ctx)),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (created == true) {
      final name = textController.text.trim();
      if (name.isNotEmpty) {
        await CategoryService.instance.addCategory(name, color: selectedColor);
        HapticFeedback.mediumImpact();
        if (mounted) {
          setState(() {
            if (!_availableCategories.contains(name)) {
              _availableCategories.add(name);
            }
            _selectedCategory = name;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  String _formatMinute(int? minutes) {
    if (minutes == null) return 'Anytime';
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final displayM = m.toString().padLeft(2, '0');
    return '$displayH:$displayM $period';
  }

  Future<void> _pickTime() async {
    HapticFeedback.selectionClick();
    final currentMin = _targetMinuteOfDay ?? 540;
    final initialTime = TimeOfDay(
      hour: currentMin ~/ 60,
      minute: currentMin % 60,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.p.accent,
              surface: widget.p.surface,
              onSurface: widget.p.text,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _isAnytime = false;
        _targetMinuteOfDay = picked.hour * 60 + picked.minute;
      });
    }
  }

  Future<void> _saveHabit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    final id =
        widget.preset?.id ??
        'custom_${DateTime.now().millisecondsSinceEpoch}_${title.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';

    final updated = CheckpointPreset(
      id: id,
      label: title,
      emoji: _selectedEmoji.trim().isNotEmpty ? _selectedEmoji.trim() : '🎯',
      category: _selectedCategory,
      targetMinuteOfDay: _isAnytime ? null : _targetMinuteOfDay,
    );

    await CheckpointService.instance.addPreset(updated);
    widget.onSaved?.call();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _confirmDelete() async {
    final preset = widget.preset;
    if (preset == null) return;

    HapticFeedback.selectionClick();
    final confirmed = await AppleHigActionSheet.show<bool>(
      context,
      p: widget.p,
      title: 'Delete Habit Checkpoint',
      subtitle:
          'Are you sure you want to remove "${preset.label}" from your habits?',
      actions: [
        AppleHigActionItem<bool>(
          title: 'Delete Habit'.localized(context),
          isDestructive: true,
          icon: CupertinoIcons.trash,
          value: true,
        ),
      ],
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      await CheckpointService.instance.deletePreset(preset.id);
      widget.onSaved?.call();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final isEditing = widget.preset != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(
            top: BorderSide(color: p.border.withValues(alpha: 0.6), width: 0.8),
          ),
        ),
        padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + bottomInset),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center pill drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: p.text3.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row
              Row(
                children: [
                  Text(
                    (isEditing ? 'Edit Habit' : 'New Habit Checkpoint')
                        .localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  PressableScale(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: p.surface2,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 13,
                        color: p.text2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Emoji Selection Strip & Custom Input
              Text(
                'Habit Icon'.localized(context),
                style: TextStyle(
                  color: p.text2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Active / Custom Emoji Input Box
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p.accent, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _emojiController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() => _selectedEmoji = val.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ..._popularEmojis.map((emoji) {
                            final isSelected = _selectedEmoji == emoji;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: PressableScale(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedEmoji = emoji;
                                    _emojiController.text = emoji;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? p.accent.withValues(alpha: 0.18)
                                        : p.surface2,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? p.accent
                                          : p.border.withValues(alpha: 0.5),
                                      width: isSelected ? 1.5 : 0.8,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Habit Title Text Input
              Text(
                'Habit Name'.localized(context),
                style: TextStyle(
                  color: p.text2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _titleController,
                  autofocus: !isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. Drink 2L Water, 30m Reading'.localized(
                      context,
                    ),
                    hintStyle: TextStyle(color: p.text3, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Selection
              Text(
                'Category'.localized(context),
                style: TextStyle(
                  color: p.text2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._availableCategories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final catColor =
                        CategoryService.instance.getCategoryColor(cat) ??
                        widget.p.accent;
                    return PressableScale(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = cat);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? catColor.withValues(alpha: 0.18)
                              : p.surface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? catColor
                                : p.border.withValues(alpha: 0.5),
                            width: isSelected ? 1.4 : 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: catColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            Text(
                              cat.localized(context),
                              style: TextStyle(
                                color: isSelected
                                    ? (p.isDark ? Colors.white : catColor)
                                    : p.text2,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  // '+ New Category' chip
                  PressableScale(
                    onTap: _showNewCategoryDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: p.accent.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.plus, size: 12, color: p.accent),
                          const SizedBox(width: 4),
                          Text(
                            'New Category'.localized(context),
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
              const SizedBox(height: 16),

              // Target Time Row
              Text(
                'Target Time'.localized(context),
                style: TextStyle(
                  color: p.text2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isAnytime = !_isAnytime);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isAnytime
                            ? p.accent.withValues(alpha: 0.16)
                            : p.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isAnytime
                              ? p.accent
                              : p.border.withValues(alpha: 0.5),
                          width: _isAnytime ? 1.2 : 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAnytime
                                ? CupertinoIcons.checkmark_alt_circle_fill
                                : CupertinoIcons.circle,
                            size: 14,
                            color: _isAnytime ? p.accent : p.text3,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Flexible Anytime'.localized(context),
                            style: TextStyle(
                              color: _isAnytime ? p.accent : p.text2,
                              fontSize: 12,
                              fontWeight: _isAnytime
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (!_isAnytime)
                    PressableScale(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: p.surface2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: p.border.withValues(alpha: 0.6),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              size: 13,
                              color: p.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatMinute(_targetMinuteOfDay),
                              style: TextStyle(
                                color: p.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Save & Delete Action Buttons
              Row(
                children: [
                  if (isEditing) ...[
                    PressableScale(
                      onTap: _confirmDelete,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.trash,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: PressableScale(
                      onTap: _saveHabit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: p.accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (isEditing ? 'Save Changes' : 'Create Habit')
                              .localized(context),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
