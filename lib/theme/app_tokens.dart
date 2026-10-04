import 'package:flutter/material.dart';

/// Centralized Design System Tokens for NoteKar.
/// Provides semantic constants for spacing, radii, touch targets, animation curves, and elevations.
class NkTokens {
  NkTokens._();

  static const spacing = NkSpacing();
  static const radii = NkRadii();
  static const touchTarget = NkTouchTarget();
  static const durations = NkDurations();
  static const curves = NkCurves();
  static const elevation = NkElevation();
}

class NkSpacing {
  const NkSpacing();

  /// 2.0 pt
  final double xxs = 2.0;

  /// 4.0 pt
  final double xs = 4.0;

  /// 8.0 pt
  final double sm = 8.0;

  /// 12.0 pt
  final double md = 12.0;

  /// 16.0 pt
  final double lg = 16.0;

  /// 20.0 pt
  final double xl = 20.0;

  /// 24.0 pt
  final double xxl = 24.0;

  /// 32.0 pt
  final double xxxl = 32.0;

  /// 48.0 pt
  final double huge = 48.0;

  // Pre-baked EdgeInsets
  EdgeInsets get insetsNone => EdgeInsets.zero;
  EdgeInsets get insetsXs => const EdgeInsets.all(4.0);
  EdgeInsets get insetsSm => const EdgeInsets.all(8.0);
  EdgeInsets get insetsMd => const EdgeInsets.all(12.0);
  EdgeInsets get insetsLg => const EdgeInsets.all(16.0);
  EdgeInsets get insetsXl => const EdgeInsets.all(20.0);
  EdgeInsets get insetsXxl => const EdgeInsets.all(24.0);

  EdgeInsets get cardPadding =>
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0);
  EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  EdgeInsets get dialogPadding =>
      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0);
  EdgeInsets get pillPadding =>
      const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0);
}

class NkRadii {
  const NkRadii();

  final double xsVal = 6.0;
  final double smVal = 8.0;
  final double mdVal = 12.0;
  final double cardVal = 28.0;
  final double sheetVal = 24.0;
  final double dialogVal = 28.0;
  final double pillVal = 999.0;

  BorderRadius get xs => BorderRadius.circular(6.0);
  BorderRadius get sm => BorderRadius.circular(8.0);
  BorderRadius get md => BorderRadius.circular(12.0);
  BorderRadius get card => BorderRadius.circular(28.0);
  BorderRadius get sheet => BorderRadius.circular(24.0);
  BorderRadius get dialog => BorderRadius.circular(28.0);
  BorderRadius get pill => BorderRadius.circular(999.0);
}

class NkTouchTarget {
  const NkTouchTarget();

  /// Standard accessibility minimum tap target: 48x48
  final double minInteractive = 48.0;

  /// Compact icon button minimum tap target: 44x44
  final double minCompact = 44.0;
}

class NkDurations {
  const NkDurations();

  /// Instant micro-feedback: 150ms
  final Duration fast = const Duration(milliseconds: 150);

  /// Standard snappy transition: 250ms
  final Duration snappy = const Duration(milliseconds: 250);

  /// Smooth layout change: 350ms
  final Duration smooth = const Duration(milliseconds: 350);

  /// Deliberate full sheet entrance: 450ms
  final Duration deliberate = const Duration(milliseconds: 450);
}

class NkCurves {
  const NkCurves();

  final Curve appleEase = Curves.easeInOutCubic;
  final Curve springSnappy = Curves.fastOutSlowIn;
  final Curve decelerate = Curves.easeOutCubic;
  final Curve bounce = Curves.elasticOut;
}

class NkElevation {
  const NkElevation();

  List<BoxShadow> cardShadow(Color shadowColor, {double opacity = 0.06}) => [
    BoxShadow(
      color: shadowColor.withValues(alpha: opacity),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  List<BoxShadow> floatingShadow(Color shadowColor, {double opacity = 0.12}) =>
      [
        BoxShadow(
          color: shadowColor.withValues(alpha: opacity),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: -2,
        ),
      ];
}
