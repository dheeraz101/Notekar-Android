import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';

class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.p,
    required this.child,
    this.radius = 16,
    this.borderRadius,
    this.padding = const EdgeInsets.all(12),
    this.blur = false,
    this.opacity = 1.0,
  });

  final Palette p;
  final Widget child;
  final double radius;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsets padding;
  final bool blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius ?? BorderRadius.circular(radius);
    final surfaceColor = p.surface.withValues(alpha: blur ? 0.70 : 1.0);

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: opacity * surfaceColor.a),
        borderRadius: resolvedRadius,
        border: Border.all(
          color: p.border.withValues(alpha: opacity * p.border.a),
        ),
        boxShadow: (p.name == 'amoled' || blur)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: p.name == 'light' ? 0.08 : 0.20,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (blur) {
      content = ClipRRect(
        borderRadius: resolvedRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: content,
        ),
      );
    }

    return content;
  }
}
