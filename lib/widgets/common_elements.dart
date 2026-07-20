import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class ChipButton extends StatelessWidget {
  const ChipButton({
    super.key,
    required this.p,
    this.label,
    this.icon,
    this.semanticLabel,
    required this.active,
    required this.onTap,
    this.onLongPress,
  });

  final Palette p;
  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? p.surface3 : p.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? p.accent : p.border),
          boxShadow: active ? selectedGlow(p.accent) : null,
        ),
        child: icon == null
            ? Text(
                label ?? '',
                style: TextStyle(
                  color: active ? p.text : p.text2,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              )
            : Icon(
                icon,
                color: active ? p.text : p.text2,
                size: 17,
                semanticLabel: semanticLabel,
              ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.p, required this.text});
  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(spacing8, spacing24, spacing8, spacing8),
      child: Text(
        text,
        style: TextStyle(
          color: p.text3,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
  });

  final String text;
  final String? query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final q = query?.trim();
    if (q == null || q.isEmpty) {
      return Text(text, style: baseStyle);
    }
    final lower = text.toLowerCase();
    final index = lower.indexOf(q.toLowerCase());
    if (index < 0) return Text(text, style: baseStyle);
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + q.length),
            style: highlightStyle,
          ),
          TextSpan(text: text.substring(index + q.length)),
        ],
      ),
    );
  }
}

class SettingsStatusPill extends StatelessWidget {
  const SettingsStatusPill({
    super.key,
    required this.p,
    required this.label,
    required this.color,
  });

  final Palette p;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class SettingsPageNote extends StatelessWidget {
  const SettingsPageNote({super.key, required this.p, required this.text});

  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              Icons.info_outline_rounded,
              color: p.text3.withValues(alpha: 0.6),
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.text3,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagnosticRow extends StatelessWidget {
  const DiagnosticRow({
    super.key,
    required this.p,
    required this.label,
    required this.value,
  });

  final Palette p;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: spacing12),
            Expanded(
              flex: 5,
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.text2, fontSize: 13, height: 1.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HIGEmptyState extends StatelessWidget {
  const HIGEmptyState({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 32 : 44),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 56 : 72,
              color: p.text3.withValues(alpha: 0.25),
            ),
            SizedBox(height: compact ? 16 : 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: compact ? 18 : 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text3,
                fontSize: compact ? 14 : 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? 20 : 28),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SliverStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  SliverStickyHeaderDelegate({
    required this.child,
    required this.height,
  });

  final Widget child;
  final double height;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverStickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
