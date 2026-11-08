import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class HomeCategoryPills extends StatelessWidget {
  const HomeCategoryPills({
    super.key,
    required this.p,
    required this.categories,
    required this.activeCategory,
    required this.onSelectCategory,
    required this.onAddCategory,
    this.onManageCategories,
    this.onLongPressCategory,
    this.onOpenFilter,
    this.isFilterActive = false,
  });

  final Palette p;
  final List<String> categories;
  final String activeCategory;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onAddCategory;
  final VoidCallback? onManageCategories;
  final void Function(String category)? onLongPressCategory;
  final VoidCallback? onOpenFilter;
  final bool isFilterActive;

  @override
  Widget build(BuildContext context) {
    final isAllSelected =
        activeCategory == 'All' || activeCategory.trim().isEmpty;

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          // "All" Pill
          Semantics(
            button: true,
            selected: isAllSelected,
            label: 'All filter',
            child: PressableScale(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelectCategory('All');
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isAllSelected
                      ? p.surface3
                      : p.surface2.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isAllSelected
                        ? p.text.withValues(alpha: 0.25)
                        : p.border.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.all_inclusive_rounded,
                      size: 13,
                      color: isAllSelected ? p.text : p.text3,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'All',
                      style: TextStyle(
                        color: isAllSelected ? p.text : p.text2,
                        fontSize: 12,
                        fontWeight: isAllSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Dynamic Category Pills
          for (final category in categories) ...[
            _CategoryPillItem(
              p: p,
              category: category,
              isSelected:
                  activeCategory.toLowerCase() == category.toLowerCase(),
              onTap: () {
                HapticFeedback.selectionClick();
                if (activeCategory.toLowerCase() == category.toLowerCase()) {
                  onSelectCategory('All');
                } else {
                  onSelectCategory(category);
                }
              },
              onLongPress: onLongPressCategory != null
                  ? () {
                      HapticFeedback.mediumImpact();
                      onLongPressCategory!(category);
                    }
                  : null,
            ),
            const SizedBox(width: 6),
          ],

          // Add Category "+" Pill
          Semantics(
            button: true,
            label: 'Add Category',
            child: PressableScale(
              onTap: () {
                HapticFeedback.lightImpact();
                onAddCategory();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: p.surface2.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 13, color: p.accent),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
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
          ),
          if (onOpenFilter != null) ...[
            const SizedBox(width: 6),
            Semantics(
              button: true,
              selected: isFilterActive,
              label: 'Filter',
              child: PressableScale(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onOpenFilter!();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isFilterActive
                        ? p.accent.withValues(alpha: 0.18)
                        : p.surface2.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isFilterActive
                          ? p.accent
                          : p.border.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 13,
                        color: isFilterActive ? p.accent : p.text3,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filter',
                        style: TextStyle(
                          color: isFilterActive ? p.accent : p.text2,
                          fontSize: 12,
                          fontWeight: isFilterActive
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryPillItem extends StatelessWidget {
  const _CategoryPillItem({
    required this.p,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  final Palette p;
  final String category;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final meta = getCategoryMeta(category, p);
    final bgLum = p.bg.computeLuminance();
    final metaLum = meta.color.computeLuminance();
    final isBgMatchingMeta = (bgLum - metaLum).abs() < 0.22;

    final Color pillTextColor;
    if (isSelected) {
      pillTextColor = isBgMatchingMeta ? p.text : meta.color;
    } else {
      pillTextColor = p.text2;
    }

    final Color pillBorderColor;
    if (isSelected) {
      pillBorderColor = isBgMatchingMeta
          ? p.text.withValues(alpha: 0.5)
          : meta.color.withValues(alpha: 0.5);
    } else {
      pillBorderColor = p.border.withValues(alpha: 0.4);
    }

    final Color pillBgColor;
    if (isSelected) {
      pillBgColor = isBgMatchingMeta
          ? p.surface3
          : meta.color.withValues(alpha: 0.16);
    } else {
      pillBgColor = p.surface2.withValues(alpha: 0.6);
    }

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$category filter',
      child: PressableScale(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: pillBgColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: pillBorderColor, width: 1.0),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: (isBgMatchingMeta ? p.text : meta.color).withValues(
                    alpha: 0.12,
                  ),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                meta.icon,
                size: 13,
                color: isSelected ? pillTextColor : p.text3,
              ),
              const SizedBox(width: 5),
              Text(
                category,
                style: TextStyle(
                  color: pillTextColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
