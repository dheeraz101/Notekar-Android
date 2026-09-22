import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';

/// An Apple HIG-grade progressive gradient frosted top bar blur.
///
/// Rather than an abrupt rectangular header or hard line, this creates
/// a smooth frosted glass ramp where content dissolves gracefully as it
/// scrolls underneath the status bar.
///
/// Engineered with strict hardware boundary safety (`ClipRect`) to prevent
/// Vulkan/Impeller framebuffer crashes and GPU green-screen artifacts on Android.
class TopFadeBlur extends StatelessWidget {
  const TopFadeBlur({
    super.key,
    required this.p,
    this.fadeHeight = 84.0,
    this.blurSigma = 20.0,
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

    return IgnorePointer(
      child: SizedBox(
        height: totalHeight,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scrimBase.withValues(alpha: isLight ? 0.72 : 0.65),
                    scrimBase.withValues(alpha: isLight ? 0.38 : 0.30),
                    scrimBase.withValues(alpha: isLight ? 0.10 : 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.42, 0.78, 1.0],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
