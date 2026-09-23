import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';

/// An Apple Liquid Glass-inspired surface container.
///
/// Implements physical specular highlights along the top bevel,
/// convex surface lighting gradients, and diffuse multi-stop ambient
/// depth shadows off dark OLED backgrounds.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.p,
    required this.child,
    this.radius = 20,
    this.borderRadius,
    this.padding = const EdgeInsets.all(12),
    this.blur = false,
    this.opacity = 1.0,
    this.showSpecularHighlight = true,
  });

  final Palette p;
  final Widget child;
  final double radius;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsets padding;
  final bool blur;
  final double opacity;
  final bool showSpecularHighlight;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius ?? BorderRadius.circular(radius);
    final isLight = p.name == 'light';
    final isAmoled = p.name == 'amoled';

    // Base surface tint tuned for physical translucency
    final baseSurface = isLight ? const Color(0xFFFFFFFF) : p.surface;

    final effectiveAlpha = blur ? (isLight ? 0.72 : 0.68) : 1.0;
    final surfaceColor = baseSurface.withValues(
      alpha: (opacity * effectiveAlpha).clamp(0.0, 1.0),
    );

    // Apple Liquid Glass specular rim gradient:
    // Light strikes from the top, creating a crisp white hairline highlight
    // that tapers into ambient border tint at the bottom.
    final topHighlightColor = isLight
        ? Colors.white.withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: isAmoled ? 0.16 : 0.22);

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: resolvedRadius,
        gradient: (blur && showSpecularHighlight)
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  surfaceColor.withValues(
                    alpha: (surfaceColor.a * (isLight ? 1.08 : 1.15)).clamp(
                      0.0,
                      1.0,
                    ),
                  ),
                  surfaceColor.withValues(
                    alpha: (surfaceColor.a * (isLight ? 0.94 : 0.92)).clamp(
                      0.0,
                      1.0,
                    ),
                  ),
                ],
              )
            : null,
        border: Border.all(
          color: (blur && showSpecularHighlight)
              ? topHighlightColor
              : p.border.withValues(alpha: opacity * p.border.a),
          width: 0.6,
        ),
        boxShadow: (isAmoled && !blur)
            ? null
            : [
                // Soft diffuse ambient depth shadow
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isLight ? 0.06 : (isAmoled ? 0.25 : 0.35),
                  ),
                  blurRadius: blur ? 28 : 20,
                  spreadRadius: blur ? -3 : -2,
                  offset: const Offset(0, 8),
                ),
                if (!isLight && blur)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 10,
                    spreadRadius: -1,
                    offset: const Offset(0, 3),
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
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: content,
        ),
      );
    }

    return Material(type: MaterialType.transparency, child: content);
  }
}
