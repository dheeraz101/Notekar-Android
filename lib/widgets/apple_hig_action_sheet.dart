import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Single item descriptor in an [AppleHigActionSheet].
class AppleHigActionItem {
  const AppleHigActionItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.color,
    this.isDestructive = false,
    this.isSelected = false,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final bool isDestructive;
  final bool isSelected;
  final VoidCallback onTap;
}

/// Authentic Apple HIG styled Floating Action Sheet for NoteKar.
///
/// Features true iOS floating card architecture:
/// - Grouped actions in a top floating translucent frosted card with 16pt radius.
/// - Standalone Cancel button in a bottom floating translucent card.
/// - Transparent margin between cards and edges, floating over modal backdrop.
/// - Native iOS haptics, dividers, and typography.
class AppleHigActionSheet extends StatelessWidget {
  const AppleHigActionSheet({
    super.key,
    required this.p,
    required this.title,
    this.subtitle,
    required this.actions,
    this.cancelLabel = 'Cancel',
  });

  final Palette p;
  final String title;
  final String? subtitle;
  final List<AppleHigActionItem> actions;
  final String cancelLabel;

  /// Convenience presenter for the Apple HIG Action Sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required Palette p,
    required String title,
    String? subtitle,
    required List<AppleHigActionItem> actions,
    String cancelLabel = 'Cancel',
  }) {
    HapticFeedback.lightImpact();
    return showCupertinoModalPopup<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (ctx) => AppleHigActionSheet(
        p: p,
        title: title,
        subtitle: subtitle,
        actions: actions,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final cardBg = p.isDark
        ? (p.name == 'amoled'
              ? const Color(0xF01C1C1E)
              : const Color(0xE8252528))
        : Colors.white.withValues(alpha: 0.94);
    final borderColor = p.border.withValues(alpha: p.isDark ? 0.35 : 0.45);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          0,
          12,
          math.max(10.0, bottomInset > 0 ? bottomInset : 10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Floating Card: Header (Title/Subtitle) + Action Items
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 0.6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title.localized(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                              ),
                            ),
                            if (subtitle != null &&
                                subtitle!.trim().isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                subtitle!.localized(context),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: p.subtext,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Divider(
                        height: 0.6,
                        thickness: 0.6,
                        color: p.border.withValues(
                          alpha: p.isDark ? 0.3 : 0.35,
                        ),
                      ),

                      // Actions List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: actions.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 0.6,
                          thickness: 0.6,
                          indent: 52,
                          endIndent: 12,
                          color: p.border.withValues(
                            alpha: p.isDark ? 0.25 : 0.35,
                          ),
                        ),
                        itemBuilder: (ctx, index) {
                          final item = actions[index];
                          final itemColor = item.isDestructive
                              ? p.red
                              : (item.color ??
                                    (item.isSelected ? p.accent : p.text));

                          return PressableScale(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(ctx);
                              item.onTap();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12.5,
                              ),
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  // Leading Icon in Tinted Circle Badge
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: (item.color ?? p.accent)
                                          .withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 16,
                                      color: itemColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Title & Subtitle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.title.localized(context),
                                          style: TextStyle(
                                            color: itemColor,
                                            fontSize: 15,
                                            fontWeight: item.isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                          ),
                                        ),
                                        if (item.subtitle != null) ...[
                                          const SizedBox(height: 1),
                                          Text(
                                            item.subtitle!.localized(context),
                                            style: TextStyle(
                                              color: p.subtext,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Trailing check indicator
                                  if (item.isSelected)
                                    Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: p.accent,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Bottom Floating Card: Standalone Cancel Action
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 0.6),
                  ),
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      child: Text(
                        cancelLabel.localized(context),
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
