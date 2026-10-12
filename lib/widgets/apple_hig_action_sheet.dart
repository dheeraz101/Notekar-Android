import 'dart:ui';

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

/// Premium Apple HIG styled Action Sheet for NoteKar.
///
/// Features frosted glassmorphism, 28pt rounded top squircles, drag handle,
/// inset grouped action rows with tinted circular badges, and haptics.
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
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      useSafeArea: true,
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: p.surface1.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: p.border.withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: p.subtext.withAlpha(90),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title & Subtitle Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      title.localized(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!.localized(context),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.subtext,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Grouped Actions Card
              Container(
                decoration: BoxDecoration(
                  color: p.surface2.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: actions.length,
                  separatorBuilder: (_, index) => Divider(
                    height: 1,
                    indent: 52,
                    endIndent: 12,
                    color: p.border.withValues(alpha: 0.4),
                  ),
                  itemBuilder: (ctx, index) {
                    final item = actions[index];
                    final itemColor = item.isDestructive
                        ? p.red
                        : (item.color ?? (item.isSelected ? p.accent : p.text));

                    return PressableScale(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(ctx);
                        item.onTap();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Left Circular Icon Badge
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (item.color ?? p.accent).withValues(
                                  alpha: 0.14,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                size: 16,
                                color: itemColor,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Text Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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

                            // Trailing Selection Mark
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
              ),
              const SizedBox(height: 12),

              // Cancel Button Pill
              PressableScale(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.surface2.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: p.border.withValues(alpha: 0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    cancelLabel.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
