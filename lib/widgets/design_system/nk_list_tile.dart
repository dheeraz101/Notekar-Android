import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/pressable_scale.dart';

enum NkTrailingKind { chevron, externalLink, popup, custom, none }

/// Standardized List Tile component for NoteKar.
///
/// Unifies and replaces [SettingsRow] and [HigRow].
/// Ensures minimum 48dp touch target, squircle icon containers,
/// and consistent typography hierarchy.
class NkListTile extends StatelessWidget {
  const NkListTile({
    super.key,
    required this.p,
    required this.title,
    this.subtitle,
    this.status,
    this.icon,
    this.iconColor,
    this.customIcon,
    this.trailing,
    this.trailingKind = NkTrailingKind.chevron,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.destructive = false,
  });

  final Palette p;
  final String title;
  final String? subtitle;
  final String? status;
  final IconData? icon;
  final Color? iconColor;
  final Widget? customIcon;
  final Widget? trailing;
  final NkTrailingKind trailingKind;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = destructive ? p.red : (iconColor ?? p.accent);
    final hasIcon = icon != null || customIcon != null;

    Widget? effectiveTrailing;
    if (trailing != null) {
      effectiveTrailing = trailing;
    } else {
      switch (trailingKind) {
        case NkTrailingKind.chevron:
          effectiveTrailing = Icon(
            Icons.chevron_right_rounded,
            size: 15.0,
            color: p.text3.withValues(alpha: 0.6),
          );
          break;
        case NkTrailingKind.externalLink:
          effectiveTrailing = Icon(
            Icons.open_in_new_rounded,
            size: 15.0,
            color: p.text3.withValues(alpha: 0.6),
          );
          break;
        case NkTrailingKind.popup:
          effectiveTrailing = Icon(
            Icons.info_outline_rounded,
            size: 16.0,
            color: p.text3.withValues(alpha: 0.6),
          );
          break;
        case NkTrailingKind.custom:
        case NkTrailingKind.none:
          effectiveTrailing = null;
          break;
      }
    }

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
        child: Row(
          children: [
            if (hasIcon) ...[
              customIcon ??
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: effectiveIconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 18.0, color: effectiveIconColor),
                  ),
              const SizedBox(width: 14.0),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: destructive ? p.red : p.text,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (status != null && status!.trim().isNotEmpty) ...[
              const SizedBox(width: 10.0),
              Flexible(
                child: Text(
                  status!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
            if (effectiveTrailing != null) ...[
              const SizedBox(width: 8.0),
              effectiveTrailing,
            ],
          ],
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return PressableScale(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      child: content,
    );
  }
}

/// Standardized Switch Tile component for NoteKar.
///
/// Unifies and replaces [SettingsSwitchRow] and [HigSwitchRow].
class NkSwitchTile extends StatelessWidget {
  const NkSwitchTile({
    super.key,
    required this.p,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.customIcon,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final Palette p;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? customIcon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? p.accent;
    final hasIcon = icon != null || customIcon != null;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48.0),
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              if (hasIcon) ...[
                customIcon ??
                    Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: effectiveIconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 18.0, color: effectiveIconColor),
                    ),
                const SizedBox(width: 14.0),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: enabled ? p.text : p.text3,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text3,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Switch.adaptive(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeThumbColor: p.accent,
                activeTrackColor: p.accent.withValues(alpha: 0.4),
                inactiveThumbColor: p.text3,
                inactiveTrackColor: p.surface3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
