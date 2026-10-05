import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Standard Apple HIG Inset Grouped Section Header & Footer.
class HigSectionHeader extends StatelessWidget {
  const HigSectionHeader({
    super.key,
    required this.p,
    required this.title,
    this.actionText,
    this.onAction,
  });

  final Palette p;
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 18, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.localized(context).toUpperCase(),
            style: TextStyle(
              color: p.text3,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          if (actionText != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionText!.localized(context),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Standard Apple HIG Section Footer note explaining functionality.
class HigSectionFooter extends StatelessWidget {
  const HigSectionFooter({super.key, required this.p, required this.text});

  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 6, bottom: 12),
      child: Text(
        text.localized(context),
        style: TextStyle(
          color: p.text3,
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          height: 1.35,
        ),
      ),
    );
  }
}

/// Apple HIG Inset Grouped Card container with rounded corners and dividers.
class HigGroupedCard extends StatelessWidget {
  const HigGroupedCard({
    super.key,
    required this.p,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
  });

  final Palette p;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final dividedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      dividedChildren.add(children[i]);
      if (i < children.length - 1) {
        dividedChildren.add(
          Padding(
            padding: const EdgeInsets.only(left: 54),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: p.border.withValues(alpha: 0.35),
            ),
          ),
        );
      }
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: p.border.withValues(alpha: 0.5), width: 0.6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: dividedChildren),
    );
  }
}

/// Standard Apple HIG Row with iOS-style rounded icon squircle, title, subtitle, status, and chevron.
class HigRow extends StatelessWidget {
  const HigRow({
    super.key,
    required this.p,
    required this.title,
    this.subtitle,
    this.status,
    this.icon,
    this.iconColor,
    this.customIcon,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  final Palette p;
  final String title;
  final String? subtitle;
  final String? status;
  final IconData? icon;
  final Color? iconColor;
  final Widget? customIcon;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? p.accent;

    Widget iconWidget;
    if (customIcon != null) {
      iconWidget = customIcon!;
    } else if (icon != null) {
      iconWidget = Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: effectiveIconColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 17, color: Colors.white),
      );
    } else {
      iconWidget = const SizedBox(width: 8);
    }

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: Colors.transparent,
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.localized(context),
                  style: TextStyle(
                    color: p.text,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!.localized(context),
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status != null) ...[
            const SizedBox(width: 8),
            Text(
              status!.localized(context),
              style: TextStyle(
                color: p.text3,
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          if (showChevron && onTap != null) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 15,
              color: p.text3.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return PressableScale(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Standard Apple HIG Switch Row.
class HigSwitchRow extends StatelessWidget {
  const HigSwitchRow({
    super.key,
    required this.p,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.value,
    required this.onChanged,
  });

  final Palette p;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return HigRow(
      p: p,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      showChevron: false,
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: p.accent,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }
}
