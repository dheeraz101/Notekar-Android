import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/theme/app_tokens.dart';

/// Centralized Inset Grouped Card container for NoteKar.
///
/// Unifies and replaces previous split implementations (`SettingsGroup`,
/// `HigGroupedCard`, and ad-hoc containers).
///
/// Standardized on:
/// - Radius: [NkRadii.card] (16pt)
/// - Surface: [Palette.surface2]
/// - Border: [Palette.border] hairline
/// - Dividers: Inset hairline dividers aligned to content text
class NkCard extends StatelessWidget {
  const NkCard({
    super.key,
    required this.p,
    required this.children,
    this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.showDividers = true,
    this.dividerIndent = 54.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
    this.padding,
    this.clipBehavior = Clip.antiAlias,
  }) : child = null;

  const NkCard.container({
    super.key,
    required this.p,
    required this.child,
    this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
    this.padding,
    this.clipBehavior = Clip.antiAlias,
  }) : children = const [],
       showDividers = false,
       dividerIndent = 54.0;

  final Palette p;
  final List<Widget> children;
  final Widget? child;
  final String? title;
  final String? description;
  final String? actionText;
  final VoidCallback? onAction;
  final bool showDividers;
  final double dividerIndent;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty &&
        child == null &&
        title == null &&
        description == null) {
      return const SizedBox.shrink();
    }

    final hasHeader = title != null || (actionText != null && onAction != null);

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader)
            Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
                right: 4.0,
                bottom: 8.0,
                top: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Text(
                      title!.toUpperCase(),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        fontFamily: 'Inter',
                      ),
                    ),
                  if (actionText != null && onAction != null)
                    GestureDetector(
                      onTap: onAction,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        actionText!,
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (children.isNotEmpty || child != null)
            Container(
              clipBehavior: clipBehavior,
              padding: padding,
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: NkTokens.radii.card,
                border: Border.all(
                  color: p.border.withValues(
                    alpha: p.name == 'amoled'
                        ? 0.6
                        : (p.name == 'light' ? 0.4 : 0.5),
                  ),
                  width: 0.6,
                ),
                boxShadow: p.name == 'light'
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child:
                  child ??
                  Builder(
                    builder: (context) {
                      if (!showDividers || children.length <= 1) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: children,
                        );
                      }

                      final dividedChildren = <Widget>[];
                      for (int i = 0; i < children.length; i++) {
                        dividedChildren.add(children[i]);
                        if (i < children.length - 1) {
                          dividedChildren.add(
                            Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: p.border.withValues(alpha: 0.4),
                              indent: dividerIndent,
                            ),
                          );
                        }
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: dividedChildren,
                      );
                    },
                  ),
            ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 6.0),
              child: Text(
                description!,
                style: TextStyle(
                  color: p.text3,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                  fontFamily: 'Inter',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
