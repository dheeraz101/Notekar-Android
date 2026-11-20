import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';

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
    final effectiveBlur = blur && AdaptiveEngine().supportsBlur;
    final resolvedRadius = borderRadius ?? BorderRadius.circular(radius);
    final bgLum = p.bg.computeLuminance();
    final isDarkBg = bgLum < 0.45;
    final isLight = !p.isDark && !isDarkBg;
    final isAmoled = p.name == 'amoled';

    // Base surface tint tuned for physical translucency
    final baseSurface = isLight ? const Color(0xFFFFFFFF) : p.surface;

    final effectiveAlpha = effectiveBlur ? (isLight ? 0.72 : 0.68) : 1.0;
    final surfaceColor = baseSurface.withValues(
      alpha: (opacity * effectiveAlpha).clamp(0.0, 1.0),
    );

    // Apple Liquid Glass specular rim gradient:
    // Light strikes from the top, creating a crisp highlight that tapers
    // into ambient border tint at the bottom. In light mode, enforce crisp
    // #D1D1D6 border definition so surfaces never blend into light canvas.
    final topHighlightColor = isLight
        ? const Color(0xFFD1D1D6).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: isAmoled ? 0.12 : 0.18);

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: resolvedRadius,
        gradient: (effectiveBlur && showSpecularHighlight)
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  surfaceColor.withValues(
                    alpha: (surfaceColor.a * (isLight ? 1.04 : 1.08)).clamp(
                      0.0,
                      1.0,
                    ),
                  ),
                  surfaceColor.withValues(
                    alpha: (surfaceColor.a * (isLight ? 0.96 : 0.94)).clamp(
                      0.0,
                      1.0,
                    ),
                  ),
                ],
              )
            : null,
        border: Border.all(
          color: isLight
              ? const Color(0xFFD1D1D6).withValues(alpha: 0.85)
              : ((effectiveBlur && showSpecularHighlight)
                    ? topHighlightColor
                    : p.border.withValues(alpha: opacity * p.border.a)),
          width: isLight ? 0.8 : 0.5,
        ),
        boxShadow: (isAmoled && !effectiveBlur) || p.name == 'eink'
            ? null
            : [
                // Soft restrained ambient depth shadow
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isLight ? 0.12 : (isAmoled ? 0.20 : 0.25),
                  ),
                  blurRadius: effectiveBlur ? 20 : 16,
                  spreadRadius: effectiveBlur ? -1 : 0,
                  offset: const Offset(0, 4),
                ),
                if (!isLight && effectiveBlur && !isAmoled)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    spreadRadius: -1,
                    offset: const Offset(0, 2),
                  ),
                if (isLight)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
              ],
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (effectiveBlur) {
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
