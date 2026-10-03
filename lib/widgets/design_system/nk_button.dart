import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/theme/app_tokens.dart';
import 'package:notekar/widgets/pressable_scale.dart';

enum NkButtonVariant { primary, secondary, ghost, destructive }

enum NkButtonSize { regular, small }

/// Standardized Button component for NoteKar.
///
/// Unifies buttons across dialogs, sheets, and forms with consistent
/// touch targets, contrast ratios, and feedback.
class NkButton extends StatelessWidget {
  const NkButton({
    super.key,
    required this.p,
    required this.label,
    this.icon,
    this.variant = NkButtonVariant.primary,
    this.size = NkButtonSize.regular,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
  });

  const NkButton.primary({
    super.key,
    required this.p,
    required this.label,
    this.icon,
    this.size = NkButtonSize.regular,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = NkButtonVariant.primary;

  const NkButton.secondary({
    super.key,
    required this.p,
    required this.label,
    this.icon,
    this.size = NkButtonSize.regular,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = NkButtonVariant.secondary;

  const NkButton.ghost({
    super.key,
    required this.p,
    required this.label,
    this.icon,
    this.size = NkButtonSize.regular,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = NkButtonVariant.ghost;

  const NkButton.destructive({
    super.key,
    required this.p,
    required this.label,
    this.icon,
    this.size = NkButtonSize.regular,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = NkButtonVariant.destructive;

  final Palette p;
  final String label;
  final IconData? icon;
  final NkButtonVariant variant;
  final NkButtonSize size;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final isSmall = size == NkButtonSize.small;

    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    switch (variant) {
      case NkButtonVariant.primary:
        backgroundColor = isEnabled
            ? p.accent
            : p.accent.withValues(alpha: 0.4);
        foregroundColor = Colors.white;
        border = null;
        break;
      case NkButtonVariant.secondary:
        backgroundColor = p.surface3;
        foregroundColor = isEnabled ? p.text : p.text3;
        border = Border.all(color: p.border.withValues(alpha: 0.5), width: 0.8);
        break;
      case NkButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? p.accent : p.text3;
        border = null;
        break;
      case NkButtonVariant.destructive:
        backgroundColor = isEnabled
            ? p.red.withValues(alpha: 0.15)
            : p.surface3;
        foregroundColor = isEnabled ? p.red : p.text3;
        border = Border.all(
          color: isEnabled ? p.red.withValues(alpha: 0.4) : p.border,
          width: 0.8,
        );
        break;
    }

    final double verticalPadding = isSmall ? 8.0 : 12.0;
    final double horizontalPadding = isSmall ? 14.0 : 20.0;
    final double fontSize = isSmall ? 13.0 : 15.0;

    Widget buttonContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16.0,
            height: 16.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation(foregroundColor),
            ),
          ),
          const SizedBox(width: 8.0),
        ] else if (icon != null) ...[
          Icon(icon, size: isSmall ? 15.0 : 17.0, color: foregroundColor),
          const SizedBox(width: 6.0),
        ],
        Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );

    return PressableScale(
      onTap: isEnabled ? onPressed : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: isSmall ? 36.0 : 48.0,
          minWidth: isSmall ? 48.0 : 72.0,
        ),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: NkTokens.radii.pill,
            border: border,
          ),
          alignment: Alignment.center,
          child: buttonContent,
        ),
      ),
    );
  }
}
