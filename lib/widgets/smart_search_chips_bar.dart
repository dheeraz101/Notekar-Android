import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/smart_search_filter.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class SmartSearchChipsBar extends StatelessWidget {
  const SmartSearchChipsBar({
    super.key,
    required this.p,
    required this.filter,
    required this.onToggleFilter,
  });

  final Palette p;
  final SmartSearchFilter filter;
  final ValueChanged<SmartFilterType> onToggleFilter;

  IconData _iconForFilter(SmartFilterType type) {
    return switch (type) {
      SmartFilterType.thisWeek => CupertinoIcons.calendar_today,
      SmartFilterType.deepworkOver2h => CupertinoIcons.timer,
      SmartFilterType.moodFocused => CupertinoIcons.sparkles,
      SmartFilterType.checkpointsDone => CupertinoIcons.checkmark_seal_fill,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: kSmartSearchChips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final def = kSmartSearchChips[index];
          final isActive = filter.isFilterActive(def.type);

          final chipColor = isActive ? p.accent : p.surface2;
          final borderColor = isActive
              ? p.accent.withValues(alpha: 0.6)
              : p.border.withValues(alpha: 0.5);
          final textColor = isActive ? Colors.white : p.text;
          final iconColor = isActive ? Colors.white : p.text2;

          return PressableScale(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggleFilter(def.type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: isActive ? 1.4 : 1.0,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: p.accent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_iconForFilter(def.type), size: 14, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    def.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 5),
                    Icon(
                      CupertinoIcons.checkmark,
                      size: 11,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
