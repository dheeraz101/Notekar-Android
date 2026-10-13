import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';

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

/// Authentic Apple HIG styled Action Sheet for NoteKar.
///
/// Built on Flutter's official [CupertinoActionSheet] matching iOS Human Interface Guidelines:
/// - Floating rounded action cards over blurred modal backdrop.
/// - Centered actions with Cupertino icons and typography.
/// - Standalone floating Cancel action.
/// - Adaptive light and dark iOS frosted materials.
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
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: p.isDark ? Brightness.dark : Brightness.light,
        primaryColor: p.accent,
      ),
      child: CupertinoActionSheet(
        title: Text(
          title.localized(context),
          style: TextStyle(
            color: p.text,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        message: subtitle != null && subtitle!.trim().isNotEmpty
            ? Text(
                subtitle!.localized(context),
                style: TextStyle(color: p.text3, fontSize: 12),
              )
            : null,
        actions: actions.map((item) {
          final itemColor = item.isDestructive
              ? CupertinoColors.destructiveRed
              : (item.color ?? (item.isSelected ? p.accent : p.text));

          return CupertinoActionSheetAction(
            isDestructiveAction: item.isDestructive,
            isDefaultAction: item.isSelected,
            onPressed: () {
              Navigator.pop(context);
              item.onTap();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.isSelected) ...[
                  Icon(Icons.check_rounded, size: 16, color: p.accent),
                  const SizedBox(width: 8),
                ],
                Icon(item.icon, size: 20, color: itemColor),
                const SizedBox(width: 10),
                Text(
                  item.title.localized(context),
                  style: TextStyle(
                    color: itemColor,
                    fontSize: 16,
                    fontWeight: item.isSelected
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelLabel.localized(context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
