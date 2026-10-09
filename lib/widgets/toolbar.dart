import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class Toolbar extends StatefulWidget {
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
    this.isSessionActive = false,
    this.activeGoalTitle,
    this.onNextGoal,
    this.onPrevGoal,
    this.enableGoalSwitcher = true,
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
  final bool isSessionActive;
  final String? activeGoalTitle;
  final VoidCallback? onNextGoal;
  final VoidCallback? onPrevGoal;
  final bool enableGoalSwitcher;

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -8.0,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -8.0,
          end: 6.0,
        ).chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 6.0,
          end: -3.0,
        ).chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -3.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 25,
      ),
    ]).animate(_bounceController);

    if (widget.isSessionActive &&
        widget.activeGoalTitle != null &&
        widget.enableGoalSwitcher) {
      _bounceController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant Toolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isSessionActive &&
        widget.isSessionActive &&
        widget.activeGoalTitle != null &&
        widget.enableGoalSwitcher) {
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  static String _clampTitle(String raw) {
    final t = raw.trim();
    if (t.length <= 9) return t;
    return t.substring(0, 9);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final isGoalActive =
        widget.isSessionActive &&
        widget.enableGoalSwitcher &&
        widget.activeGoalTitle != null &&
        widget.activeGoalTitle!.trim().isNotEmpty;
    final clampedGoal = isGoalActive
        ? _clampTitle(widget.activeGoalTitle!)
        : null;
    final historyLabel = clampedGoal ?? (widget.lastTimestamp ?? 'History');
    final showGoalPill = isGoalActive || widget.showHistoryText;

    if (widget.showLabels) {
      final labeledRow = Padding(
        padding: EdgeInsets.all(widget.showBackgroundPill ? spacing8 : 0),
        child: SizedBox(
          width: math.min(MediaQuery.sizeOf(context).width - spacing48, 318),
          child: Row(
            children: [
              Expanded(
                child: TextToolButton(
                  p: p,
                  label: widget.mode == 'single' ? 'Single' : 'Two-Way',
                  blur: widget.blur,
                  onTap: widget.onMode,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: isGoalActive
                      ? (details) {
                          if (details.primaryVelocity != null) {
                            if (details.primaryVelocity! < -100) {
                              HapticFeedback.selectionClick();
                              widget.onNextGoal?.call();
                            } else if (details.primaryVelocity! > 100) {
                              HapticFeedback.selectionClick();
                              widget.onPrevGoal?.call();
                            }
                          }
                        }
                      : null,
                  child: AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(_bounceAnimation.value, 0),
                      child: child,
                    ),
                    child: TextToolButton(
                      p: p,
                      label: historyLabel,
                      icon: showGoalPill ? null : Icons.access_time_rounded,
                      blur: widget.blur,
                      onTap: widget.onHistory,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextToolButton(
                  p: p,
                  label: 'Settings',
                  blur: widget.blur,
                  onTap: widget.onSettings,
                ),
              ),
            ],
          ),
        ),
      );
      final content = widget.showBackgroundPill
          ? (widget.blur
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: DecoratedBox(
                        decoration: _bottomNavDecoration(p, widget.blur),
                        child: labeledRow,
                      ),
                    ),
                  )
                : DecoratedBox(
                    decoration: _bottomNavDecoration(p, widget.blur),
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
      padding: EdgeInsets.all(widget.showBackgroundPill ? spacing8 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModeToolButton(
            p: p,
            mode: widget.mode,
            large: widget.largeControls,
            blur: widget.blur,
            motionNotifier: widget.animateIcons ? widget.motionNotifier : null,
            motionX: widget.animateIcons ? widget.motionX : 0,
            motionY: widget.animateIcons ? widget.motionY : 0,
            onTap: widget.onMode,
          ),
          const SizedBox(width: spacing8),
          GestureDetector(
            onHorizontalDragEnd: isGoalActive
                ? (details) {
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! < -100) {
                        HapticFeedback.selectionClick();
                        widget.onNextGoal?.call();
                      } else if (details.primaryVelocity! > 100) {
                        HapticFeedback.selectionClick();
                        widget.onPrevGoal?.call();
                      }
                    }
                  }
                : null,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_bounceAnimation.value, 0),
                child: child,
              ),
              child: PressableScale(
                onTap: widget.onHistory,
                child: Glass(
                  p: p,
                  blur: widget.blur,
                  radius: 999,
                  padding: EdgeInsets.only(
                    left: showGoalPill ? (widget.largeControls ? 10 : 8) : 0,
                    right: showGoalPill ? spacing16 : 0,
                  ),
                  child: SizedBox(
                    width: showGoalPill
                        ? null
                        : (widget.largeControls ? 56 : 48),
                    height: widget.largeControls ? 56 : 48,
                    child: showGoalPill
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: widget.largeControls ? 36 : 32,
                                height: widget.largeControls ? 36 : 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isGoalActive
                                      ? p.accent.withValues(alpha: 0.16)
                                      : p.surface3,
                                  shape: BoxShape.circle,
                                ),
                                child: isGoalActive
                                    ? Icon(
                                        Icons.flag_rounded,
                                        color: p.accent,
                                        size: widget.largeControls ? 18 : 16,
                                      )
                                    : AnimatedHomeIcon(
                                        icon: Icons.access_time_rounded,
                                        color: p.text,
                                        size: widget.largeControls ? 20 : 18,
                                        motionNotifier: widget.animateIcons
                                            ? widget.motionNotifier
                                            : null,
                                        motionX: widget.animateIcons
                                            ? widget.motionX
                                            : 0,
                                        motionY: widget.animateIcons
                                            ? widget.motionY
                                            : 0,
                                      ),
                              ),
                              const SizedBox(width: spacing8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: Text(
                                  historyLabel,
                                  key: ValueKey<String>(historyLabel),
                                  style: TextStyle(
                                    color: p.text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          )
                        : Center(
                            child: Container(
                              width: widget.largeControls ? 36 : 32,
                              height: widget.largeControls ? 36 : 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: p.surface3,
                                shape: BoxShape.circle,
                              ),
                              child: AnimatedHomeIcon(
                                icon: Icons.access_time_rounded,
                                color: p.text,
                                size: widget.largeControls ? 20 : 18,
                                motionNotifier: widget.animateIcons
                                    ? widget.motionNotifier
                                    : null,
                                motionX: widget.animateIcons
                                    ? widget.motionX
                                    : 0,
                                motionY: widget.animateIcons
                                    ? widget.motionY
                                    : 0,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: spacing8),
          CircleToolButton(
            p: p,
            icon: Icons.settings_rounded,
            color: p.text,
            label: widget.showLabels ? 'Settings' : null,
            size: widget.largeControls ? 56 : 48,
            blur: widget.blur,
            motionNotifier: widget.animateIcons ? widget.motionNotifier : null,
            motionX: widget.animateIcons ? widget.motionX : 0,
            motionY: widget.animateIcons ? widget.motionY : 0,
            onTap: widget.onSettings,
          ),
        ],
      ),
    );

    final content = widget.showBackgroundPill
        ? (widget.blur
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: DecoratedBox(
                      decoration: _bottomNavDecoration(p, widget.blur),
                      child: iconRow,
                    ),
                  ),
                )
              : DecoratedBox(
                  decoration: _bottomNavDecoration(p, widget.blur),
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
  final isLight = !p.isDark;
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
                        ? Icons.arrow_upward_rounded
                        : Icons.swap_vert_rounded,
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
