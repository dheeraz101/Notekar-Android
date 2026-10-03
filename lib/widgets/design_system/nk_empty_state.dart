import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/design_system/nk_button.dart';

/// Standardized Empty State component for NoteKar.
///
/// Used across History, Goals, Search, Trash Bin, and Activity Tags.
/// Replaces inconsistent custom ad-hoc empty views.
class NkEmptyState extends StatelessWidget {
  const NkEmptyState({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    String? description,
    String? subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  }) : description = description ?? subtitle ?? '';

  final Palette p;
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? p.accent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 30.0, color: effectiveColor),
            ),
            const SizedBox(height: 18.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text3,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                height: 1.4,
                fontFamily: 'Inter',
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20.0),
              NkButton.secondary(
                p: p,
                label: actionLabel!,
                size: NkButtonSize.small,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
