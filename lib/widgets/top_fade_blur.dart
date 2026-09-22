import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';

/// An Apple HIG-grade progressive gradient frosted top bar blur.
///
/// Rather than an abrupt rectangular header or hard line, this creates
/// a smooth frosted glass ramp where content dissolves gracefully as it
/// scrolls underneath the status bar.
class TopFadeBlur extends StatelessWidget {
  const TopFadeBlur({
    super.key,
    required this.p,
    this.fadeHeight = 84.0,
    this.blurSigma = 24.0,
    this.enabled = true,
  });

  final Palette p;
  final double fadeHeight;
  final double blurSigma;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final totalHeight = statusBarHeight + fadeHeight;
    final isLight = p.name == 'light';

    final scrimBase = isLight ? Colors.white : Colors.black;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: totalHeight,
      child: IgnorePointer(
        child: Stack(
          children: [
            // Progressive blur layer: Masked with an ease-out gradient
            // so blur strength transitions smoothly into nothingness
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black87,
                      Colors.black38,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.45, 0.78, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurSigma,
                    sigmaY: blurSigma,
                  ),
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
            ),
            // Readability scrim: A non-linear gradient protecting status bar glyphs
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scrimBase.withValues(alpha: isLight ? 0.65 : 0.55),
                      scrimBase.withValues(alpha: isLight ? 0.35 : 0.28),
                      scrimBase.withValues(alpha: isLight ? 0.08 : 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.40, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
