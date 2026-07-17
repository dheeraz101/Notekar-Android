import 'dart:math' as math;
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
    required this.motionX,
    required this.motionY,
    required this.showHistoryText,
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
  final double motionX;
  final double motionY;
  final bool showHistoryText;
  final bool blur;

  @override
  Widget build(BuildContext context) {
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
                  label: showHistoryText ? 'History' : '',
                  icon: showHistoryText ? null : Icons.history_rounded,
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
      return Center(
        child: showBackgroundPill
            ? DecoratedBox(
                decoration: _bottomNavDecoration(p, blur),
                child: labeledRow,
              )
            : labeledRow,
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
              padding: EdgeInsets.symmetric(
                horizontal: showHistoryText ? spacing24 : 0,
                vertical: largeControls ? spacing16 : spacing12,
              ),
              child: showHistoryText
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedHomeIcon(
                          icon: Icons.history_rounded,
                          color: p.text,
                          size: 20,
                          motionX: animateIcons ? motionX : 0,
                          motionY: animateIcons ? motionY : 0,
                        ),
                        const SizedBox(width: spacing8),
                        Text(
                          'History',
                          style: TextStyle(
                            color: p.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: largeControls ? 64 : 56,
                      height: largeControls ? 32 : 24,
                      child: AnimatedHomeIcon(
                        icon: Icons.history_rounded,
                        color: p.text,
                        size: 21,
                        motionX: animateIcons ? motionX : 0,
                        motionY: animateIcons ? motionY : 0,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: spacing8),
          CircleToolButton(
            p: p,
            icon: Icons.settings_rounded,
            color: p.text,
            label: showLabels ? 'Settings' : null,
            size: largeControls ? 64 : 56,
            blur: blur,
            motionX: animateIcons ? motionX : 0,
            motionY: animateIcons ? motionY : 0,
            onTap: onSettings,
          ),
        ],
      ),
    );
    return Center(
      child: showBackgroundPill
          ? DecoratedBox(
              decoration: _bottomNavDecoration(p, blur), child: iconRow)
          : iconRow,
    );
  }
}

BoxDecoration _bottomNavDecoration(Palette p, bool blur) {
  final surfaceColor = p.name == 'light'
      ? const Color(0xFFF2F2F7)
      : p.surface.withValues(alpha: p.name == 'amoled' ? 0.96 : 0.94);
  return BoxDecoration(
    color: blur ? surfaceColor.withValues(alpha: 0.65) : surfaceColor,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: p.border),
    boxShadow: (p.name == 'amoled' || blur)
        ? null
        : [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: p.name == 'light' ? 0.08 : 0.20),
              blurRadius: 14,
              offset: const Offset(0, 6),
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
    this.motionX = 0,
    this.motionY = 0,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double motionX;
  final double motionY;

  @override
  State<AnimatedHomeIcon> createState() => _AnimatedHomeIconState();
}

class _AnimatedHomeIconState extends State<AnimatedHomeIcon> {
  double _displayAngle = 0;

  double _targetAngle() {
    final strength = math.sqrt(
      widget.motionX * widget.motionX + widget.motionY * widget.motionY,
    );

    if (strength < 0.10) {
      return 0;
    }

    return math.atan2(-widget.motionX, widget.motionY);
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

  @override
  Widget build(BuildContext context) {
    final target = _nearestEquivalentAngle(_displayAngle, _targetAngle());

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
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
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
    this.size = 54,
    this.animation,
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
  final VoidCallback onTap;
  final double motionX;
  final double motionY;
  final bool blur;

  @override
  Widget build(BuildContext context) {
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
              ? AnimatedHomeIcon(
                  icon: icon,
                  color: color,
                  size: 23,
                  motionX: motionX,
                  motionY: motionY,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedHomeIcon(
                      icon: icon,
                      color: color,
                      size: 21,
                      motionX: motionX,
                      motionY: motionY,
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
    this.motionX = 0,
    this.motionY = 0,
    required this.onTap,
    this.blur = false,
  });

  final Palette p;
  final String mode;
  final bool large;
  final HomeIconAnimation? animation;
  final double motionX;
  final double motionY;
  final VoidCallback onTap;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final single = mode == 'single';
    final color = p.text;
    return PressableScale(
      onTap: onTap,
      child: Glass(
        p: p,
        blur: blur,
        radius: 999,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: large ? 11 : 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: large ? 36 : 32,
              height: large ? 36 : 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.surface3,
                shape: BoxShape.circle,
              ),
              child: AnimatedHomeIcon(
                icon: single
                    ? Icons.arrow_upward_rounded
                    : Icons.swap_vert_rounded,
                color: color,
                size: large ? 21 : 19,
                motionX: motionX,
                motionY: motionY,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
