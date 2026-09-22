import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    required this.p,
    required this.mode,
    required this.onMode,
    required this.onHistory,
    required this.onSettings,
    required this.showLabels,
    required this.largeControls,
    required this.showBackgroundPill,
    required this.animateIcons,
    this.motionNotifier,
    this.motionX = 0,
    this.motionY = 0,
    required this.showHistoryText,
    this.lastTimestamp,
    this.blur = false,
  });

  final Palette p;
  final String mode;
  final VoidCallback onMode;
  final VoidCallback onHistory;
  final VoidCallback onSettings;
  final bool showLabels;
  final bool largeControls;
  final bool showBackgroundPill;
  final bool animateIcons;
  final ValueNotifier<Offset>? motionNotifier;
  final double motionX;
  final double motionY;
  final bool showHistoryText;
  final String? lastTimestamp;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final historyLabel = lastTimestamp ?? 'History';
    if (showLabels) {
      final labeledRow = Padding(
        padding: EdgeInsets.all(showBackgroundPill ? spacing8 : 0),
        child: SizedBox(
          width: math.min(MediaQuery.sizeOf(context).width - spacing48, 318),
          child: Row(
            children: [
              Expanded(
                child: TextToolButton(
                  p: p,
                  label: mode == 'single' ? 'Single' : 'Two-Way',
                  blur: blur,
                  onTap: onMode,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextToolButton(
                  p: p,
                  label: showHistoryText ? historyLabel : '',
                  icon: showHistoryText ? null : CupertinoIcons.clock,
                  blur: blur,
                  onTap: onHistory,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextToolButton(
                  p: p,
                  label: 'Settings',
                  blur: blur,
                  onTap: onSettings,
                ),
              ),
            ],
          ),
        ),
      );
      final content = showBackgroundPill
          ? (blur
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: DecoratedBox(
                        decoration: _bottomNavDecoration(p, blur),
                        child: labeledRow,
                      ),
                    ),
                  )
                : DecoratedBox(
                    decoration: _bottomNavDecoration(p, blur),
                    child: labeledRow,
                  ))
          : labeledRow;

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: content,
        ),
      );
    }
    final iconRow = Padding(
      padding: EdgeInsets.all(showBackgroundPill ? spacing8 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModeToolButton(
            p: p,
            mode: mode,
            large: largeControls,
            blur: blur,
            motionNotifier: animateIcons ? motionNotifier : null,
            motionX: animateIcons ? motionX : 0,
            motionY: animateIcons ? motionY : 0,
            onTap: onMode,
          ),
          const SizedBox(width: spacing8),
          PressableScale(
            onTap: onHistory,
            child: Glass(
              p: p,
              blur: blur,
              radius: 999,
              padding: EdgeInsets.only(
                left: showHistoryText ? (largeControls ? 10 : 8) : 0,
                right: showHistoryText ? spacing16 : 0,
              ),
              child: SizedBox(
                width: showHistoryText ? null : (largeControls ? 56 : 48),
                height: largeControls ? 56 : 48,
                child: showHistoryText
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: largeControls ? 36 : 32,
                            height: largeControls ? 36 : 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: p.surface3,
                              shape: BoxShape.circle,
                            ),
                            child: AnimatedHomeIcon(
                              icon: CupertinoIcons.clock,
                              color: p.text,
                              size: largeControls ? 20 : 18,
                              motionNotifier: animateIcons
                                  ? motionNotifier
                                  : null,
                              motionX: animateIcons ? motionX : 0,
                              motionY: animateIcons ? motionY : 0,
                            ),
                          ),
                          const SizedBox(width: spacing8),
                          Text(
                            historyLabel,
                            style: TextStyle(
                              color: p.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      )
                    : Center(
                        child: Container(
                          width: largeControls ? 36 : 32,
                          height: largeControls ? 36 : 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.surface3,
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedHomeIcon(
                            icon: CupertinoIcons.clock,
                            color: p.text,
                            size: largeControls ? 20 : 18,
                            motionNotifier: animateIcons
                                ? motionNotifier
                                : null,
                            motionX: animateIcons ? motionX : 0,
                            motionY: animateIcons ? motionY : 0,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: spacing8),
          CircleToolButton(
            p: p,
            icon: CupertinoIcons.settings,
            color: p.text,
            label: showLabels ? 'Settings' : null,
            size: largeControls ? 56 : 48,
            blur: blur,
            motionNotifier: animateIcons ? motionNotifier : null,
            motionX: animateIcons ? motionX : 0,
            motionY: animateIcons ? motionY : 0,
            onTap: onSettings,
          ),
        ],
      ),
    );

    final content = showBackgroundPill
        ? (blur
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: DecoratedBox(
                      decoration: _bottomNavDecoration(p, blur),
                      child: iconRow,
                    ),
                  ),
                )
              : DecoratedBox(
                  decoration: _bottomNavDecoration(p, blur),
                  child: iconRow,
                ))
        : iconRow;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: content,
      ),
    );
  }
}

BoxDecoration _bottomNavDecoration(Palette p, bool blur) {
  final isLight = p.name == 'light';
  final isAmoled = p.name == 'amoled';

  final surfaceColor = isLight
      ? const Color(0xFFFFFFFF).withValues(alpha: blur ? 0.72 : 0.95)
      : (isAmoled
            ? const Color(0xFF000000).withValues(alpha: blur ? 0.85 : 0.98)
            : const Color(0xFF1C1C1E).withValues(alpha: blur ? 0.70 : 0.94));

  final topRimColor = isLight
      ? Colors.white.withValues(alpha: 0.65)
      : Colors.white.withValues(alpha: isAmoled ? 0.18 : 0.24);

  return BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(
      color: blur ? topRimColor : p.border.withValues(alpha: 0.6),
      width: 0.6,
    ),
    boxShadow: (isAmoled && !blur)
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.35),
              blurRadius: blur ? 28 : 18,
              spreadRadius: blur ? -3 : -1,
              offset: const Offset(0, 8),
            ),
          ],
  );
}

enum HomeIconAnimationKind { spin, sway, breathe }

class HomeIconAnimation {
  const HomeIconAnimation.spin({required this.turns, required this.durationMs})
    : kind = HomeIconAnimationKind.spin;

  const HomeIconAnimation.sway({required this.durationMs})
    : kind = HomeIconAnimationKind.sway,
      turns = 0.035;

  const HomeIconAnimation.breathe({required this.durationMs})
    : kind = HomeIconAnimationKind.breathe,
      turns = 0;

  final HomeIconAnimationKind kind;
  final double turns;
  final int durationMs;
}

class AnimatedHomeIcon extends StatefulWidget {
  const AnimatedHomeIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    this.motionNotifier,
    this.motionX = 0,
    this.motionY = 0,
  });

  final IconData icon;
  final Color color;
  final double size;
  final ValueNotifier<Offset>? motionNotifier;
  final double motionX;
  final double motionY;

  @override
  State<AnimatedHomeIcon> createState() => _AnimatedHomeIconState();
}

class _AnimatedHomeIconState extends State<AnimatedHomeIcon> {
  double _displayAngle = 0;

  double _targetAngle(double x, double y) {
    final strength = math.sqrt(x * x + y * y);

    if (strength < 0.10) {
      return 0;
    }

    return math.atan2(-x, y);
  }

  double _nearestEquivalentAngle(double current, double target) {
    var adjusted = target;

    while (adjusted - current > math.pi) {
      adjusted -= math.pi * 2;
    }

    while (adjusted - current < -math.pi) {
      adjusted += math.pi * 2;
    }

    return adjusted;
  }

  Widget _buildRotated(double x, double y, Widget iconChild) {
    final target = _nearestEquivalentAngle(_displayAngle, _targetAngle(x, y));

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _displayAngle, end: target),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      onEnd: () {
        _displayAngle = target;
      },
      builder: (context, angle, child) {
        _displayAngle = angle;

        return Transform.rotate(
          angle: angle,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: iconChild,
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconChild = RepaintBoundary(
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );

    if (widget.motionNotifier != null) {
      return ValueListenableBuilder<Offset>(
        valueListenable: widget.motionNotifier!,
        builder: (context, motion, _) {
          return _buildRotated(motion.dx, motion.dy, iconChild);
        },
      );
    }

    return _buildRotated(widget.motionX, widget.motionY, iconChild);
  }
}

class TextToolButton extends StatelessWidget {
  const TextToolButton({
    super.key,
    required this.p,
    required this.label,
    required this.onTap,
    this.icon,
    this.blur = false,
  });

  final Palette p;
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Glass(
        p: p,
        blur: blur,
        radius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Center(
          child: icon == null
              ? Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Icon(icon, color: p.text, size: 18),
        ),
      ),
    );
  }
}

class CircleToolButton extends StatelessWidget {
  const CircleToolButton({
    super.key,
    required this.p,
    required this.icon,
    required this.color,
    this.label,
    this.size = 48,
    this.animation,
    this.motionNotifier,
    this.motionX = 0,
    this.motionY = 0,
    required this.onTap,
    this.blur = false,
  });

  final Palette p;
  final IconData icon;
  final Color color;
  final String? label;
  final double size;
  final HomeIconAnimation? animation;
  final ValueNotifier<Offset>? motionNotifier;
  final VoidCallback onTap;
  final double motionX;
  final double motionY;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final isLarge = size >= 54;
    final innerSize = isLarge ? 36.0 : 32.0;
    return PressableScale(
      onTap: onTap,
      child: Glass(
        p: p,
        blur: blur,
        radius: 999,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: label == null ? size : size + 22,
          height: size,
          child: label == null
              ? Center(
                  child: Container(
                    width: innerSize,
                    height: innerSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.surface3,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedHomeIcon(
                      icon: icon,
                      color: color,
                      size: isLarge ? 20 : 18,
                      motionNotifier: motionNotifier,
                      motionX: motionX,
                      motionY: motionY,
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: innerSize,
                      height: innerSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.surface3,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedHomeIcon(
                        icon: icon,
                        color: color,
                        size: isLarge ? 20 : 18,
                        motionNotifier: motionNotifier,
                        motionX: motionX,
                        motionY: motionY,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label!,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ModeToolButton extends StatelessWidget {
  const ModeToolButton({
    super.key,
    required this.p,
    required this.mode,
    required this.large,
    this.animation,
    this.motionNotifier,
    this.motionX = 0,
    this.motionY = 0,
    required this.onTap,
    this.blur = false,
  });

  final Palette p;
  final String mode;
  final bool large;
  final HomeIconAnimation? animation;
  final ValueNotifier<Offset>? motionNotifier;
  final double motionX;
  final double motionY;
  final VoidCallback onTap;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final single = mode == 'single';
    final color = p.text;
    final size = large ? 56.0 : 48.0;
    final innerSize = large ? 36.0 : 32.0;
    return PressableScale(
      onTap: onTap,
      child: Glass(
        p: p,
        blur: blur,
        radius: 999,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Container(
              width: innerSize,
              height: innerSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.surface3,
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final inAnimation =
                      Tween<Offset>(
                        begin: single
                            ? const Offset(0.0, 0.25)
                            : const Offset(0.0, -0.25),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                  return SlideTransition(
                    position: inAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.85,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<bool>(single),
                  child: AnimatedHomeIcon(
                    icon: single
                        ? CupertinoIcons.arrow_up
                        : CupertinoIcons.arrow_up_arrow_down,
                    color: color,
                    size: large ? 20 : 18,
                    motionNotifier: motionNotifier,
                    motionX: motionX,
                    motionY: motionY,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
