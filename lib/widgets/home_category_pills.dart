import 'package:flutter/cupertino.dart' show CupertinoIcons;
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
  });

  final Palette p;
  final List<String> categories;
  final String activeCategory;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onAddCategory;
  final VoidCallback? onManageCategories;

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
          PressableScale(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelectCategory('All');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: isAllSelected
                    ? p.surface3
                    : p.surface2.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isAllSelected
                      ? p.text.withValues(alpha: 0.25)
                      : p.border.withValues(alpha: 0.4),
                  width: isAllSelected ? 1.2 : 0.8,
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
            ),
            const SizedBox(width: 6),
          ],

          // Add Category "+" Pill
          PressableScale(
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
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.plus, size: 13, color: p.accent),
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
  });

  final Palette p;
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = getCategoryMeta(category, p);

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? meta.color.withValues(alpha: 0.16)
              : p.surface2.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? meta.color.withValues(alpha: 0.5)
                : p.border.withValues(alpha: 0.4),
            width: isSelected ? 1.2 : 0.8,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: meta.color.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(meta.icon, size: 13, color: isSelected ? meta.color : p.text3),
            const SizedBox(width: 5),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? meta.color : p.text2,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
