import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class TimelineFilterCriteria {
  const TimelineFilterCriteria({
    this.mode = 'all',
    this.category,
    this.hashtag,
  });

  final String mode; // 'all' | 'single' | 'two-way' | 'media'
  final String? category;
  final String? hashtag;

  bool get isActive => mode != 'all' || category != null || hashtag != null;

  TimelineFilterCriteria copyWith({
    String? mode,
    String? Function()? category,
    String? Function()? hashtag,
  }) {
    return TimelineFilterCriteria(
      mode: mode ?? this.mode,
      category: category != null ? category() : this.category,
      hashtag: hashtag != null ? hashtag() : this.hashtag,
    );
  }
}

class TimelineFilterSheet extends StatefulWidget {
  const TimelineFilterSheet({
    super.key,
    required this.p,
    required this.initial,
    required this.categories,
    required this.hashtags,
    this.largeText = false,
    this.blur = false,
  });

  final Palette p;
  final TimelineFilterCriteria initial;
  final List<String> categories;
  final List<String> hashtags;
  final bool largeText;
  final bool blur;

  static Future<TimelineFilterCriteria?> show(
    BuildContext context, {
    required Palette p,
    required TimelineFilterCriteria initial,
    required List<String> categories,
    required List<String> hashtags,
    bool largeText = false,
    bool blur = false,
  }) {
    return showGeneralDialog<TimelineFilterCriteria>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close filter',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (_, _, _) => TimelineFilterSheet(
        p: p,
        initial: initial,
        categories: categories,
        hashtags: hashtags,
        largeText: largeText,
        blur: blur,
      ),
    );
  }

  @override
  State<TimelineFilterSheet> createState() => _TimelineFilterSheetState();
}

class _TimelineFilterSheetState extends State<TimelineFilterSheet> {
  late String _mode;
  String? _category;
  String? _hashtag;

  @override
  void initState() {
    super.initState();
    _mode = widget.initial.mode;
    _category = widget.initial.category;
    _hashtag = widget.initial.hashtag;
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _mode = 'all';
      _category = null;
      _hashtag = null;
    });
  }

  void _apply() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(
      TimelineFilterCriteria(
        mode: _mode,
        category: _category,
        hashtag: _hashtag,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return AppSheet(
      p: p,
      title: 'Filter Timeline'.localized(context),
      largeText: widget.largeText,
      blur: widget.blur,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: Capture Mode Segmented Control
          Text(
            'CAPTURE MODE'.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl<String>(
            groupValue: _mode,
            backgroundColor: p.surface2,
            thumbColor: p.surface,
            children: {
              'all': Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Text(
                  'All Modes'.localized(context),
                  style: TextStyle(
                    color: _mode == 'all' ? p.accent : p.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              'single': Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Text(
                  'Single'.localized(context),
                  style: TextStyle(
                    color: _mode == 'single' ? p.accent : p.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              'two-way': Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Text(
                  'Two-Way'.localized(context),
                  style: TextStyle(
                    color: _mode == 'two-way' ? p.accent : p.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              'media': Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Text(
                  'Media'.localized(context),
                  style: TextStyle(
                    color: _mode == 'media' ? p.accent : p.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            },
            onValueChanged: (val) {
              if (val != null) {
                HapticFeedback.selectionClick();
                setState(() => _mode = val);
              }
            },
          ),
          const SizedBox(height: 20),

          // Section 2: Active Categories
          if (widget.categories.isNotEmpty) ...[
            Text(
              'CATEGORIES'.localized(context),
              style: TextStyle(
                color: p.text3,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _FilterChip(
                    p: p,
                    label: 'All Categories'.localized(context),
                    isSelected: _category == null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _category = null);
                    },
                  ),
                  for (final cat in widget.categories) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      p: p,
                      label: cat,
                      color: getCategoryMeta(cat, p).color,
                      isSelected: _category?.toLowerCase() == cat.toLowerCase(),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (_category?.toLowerCase() == cat.toLowerCase()) {
                            _category = null;
                          } else {
                            _category = cat;
                          }
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Section 3: Hashtags
          if (widget.hashtags.isNotEmpty) ...[
            Text(
              'HASHTAGS'.localized(context),
              style: TextStyle(
                color: p.text3,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _FilterChip(
                    p: p,
                    label: 'All Tags'.localized(context),
                    isSelected: _hashtag == null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _hashtag = null);
                    },
                  ),
                  for (final tag in widget.hashtags) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      p: p,
                      label: tag.startsWith('#') ? tag : '#$tag',
                      isSelected: _hashtag?.toLowerCase() == tag.toLowerCase(),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (_hashtag?.toLowerCase() == tag.toLowerCase()) {
                            _hashtag = null;
                          } else {
                            _hashtag = tag;
                          }
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Section 4: Action Footer (Reset, Cancel, Apply)
          Row(
            children: [
              TextButton(
                onPressed: _reset,
                child: Text(
                  'Reset'.localized(context),
                  style: TextStyle(color: p.red, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel'.localized(context),
                  style: TextStyle(color: p.text2, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _apply,
                child: Text(
                  'Apply'.localized(context),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.p,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  final Palette p;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? p.accent;

    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.16)
              : p.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? effectiveColor
                : p.border.withValues(alpha: 0.6),
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? effectiveColor : p.text,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
