import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

/// Apple HIG & BitChord-inspired precision switch.
///
/// Features:
/// - Mechanical thumb stretch (up to 1.16x) along the travel axis during touch-down & drag
/// - Smooth single-pass spring kinetics (220ms, Cubic(0.25, 0.9, 0.35, 1.0))
/// - Authentic Apple Green (#34C759 / #30D158) or custom accent on-track
/// - Full interactive horizontal drag + tap gesture support with velocity snapping
/// - Tactile haptic feedback strictly upon value mutation
/// - Inward-bounded thumb stretching to eliminate track-edge clipping
/// - Screen-reader accessible semantics
class NkIosSwitch extends StatefulWidget {
  const NkIosSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.enabled = true,
    this.useAppleGreen = false,
    this.enableHaptics = true,
    this.onHaptic,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final bool enabled;
  final bool useAppleGreen;
  final bool enableHaptics;
  final VoidCallback? onHaptic;

  @override
  State<NkIosSwitch> createState() => _NkIosSwitchState();
}

class _NkIosSwitchState extends State<NkIosSwitch>
    with TickerProviderStateMixin {
  late final AnimationController _positionController;
  late final CurvedAnimation _positionAnimation;

  late final AnimationController _stretchController;
  late final CurvedAnimation _stretchAnimation;

  static const double _trackWidth = 51.0;
  static const double _trackHeight = 31.0;
  static const double _thumbDiameter = 27.0;
  static const double _thumbPadding = 2.0;
  static const double _maxTravel =
      _trackWidth - _thumbDiameter - (_thumbPadding * 2); // 20.0

  bool _isDragging = false;
  double _dragStartValue = 0.0;

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
    );
    _positionAnimation = CurvedAnimation(
      parent: _positionController,
      curve: const Cubic(0.25, 0.9, 0.35, 1.0),
      reverseCurve: const Cubic(0.25, 0.9, 0.35, 1.0),
    );

    _stretchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _stretchAnimation = CurvedAnimation(
      parent: _stretchController,
      curve: Curves.easeOutQuad,
      reverseCurve: Curves.easeInQuad,
    );
  }

  @override
  void didUpdateWidget(covariant NkIosSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isDragging) {
      if (widget.value) {
        _positionController.animateTo(
          1.0,
          duration: const Duration(milliseconds: 220),
          curve: const Cubic(0.25, 0.9, 0.35, 1.0),
        );
      } else {
        _positionController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 220),
          curve: const Cubic(0.25, 0.9, 0.35, 1.0),
        );
      }
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _stretchController.dispose();
    super.dispose();
  }

  void _triggerHaptic(bool newValue) {
    if (!widget.enableHaptics) return;
    if (widget.onHaptic != null) {
      widget.onHaptic!();
      return;
    }
    if (newValue) {
      AppHaptics.toggleOn();
    } else {
      AppHaptics.toggleOff();
    }
  }

  void _handleTap() {
    if (!widget.enabled || widget.onChanged == null) return;
    final newValue = !widget.value;
    _triggerHaptic(newValue);
    _positionController.animateTo(
      newValue ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
      curve: const Cubic(0.25, 0.9, 0.35, 1.0),
    );
    widget.onChanged!(newValue);
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget.enabled || widget.onChanged == null) return;
    _stretchController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.enabled || widget.onChanged == null) return;
    _stretchController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled || widget.onChanged == null) return;
    _stretchController.reverse();
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enabled || widget.onChanged == null) return;
    _isDragging = true;
    _dragStartValue = _positionController.value;
    _stretchController.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final delta = details.primaryDelta ?? 0.0;
    _dragStartValue = (_dragStartValue + (delta / _maxTravel)).clamp(0.0, 1.0);
    _positionController.value = _dragStartValue;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;
    _stretchController.reverse();

    final velocity = details.primaryVelocity ?? 0.0;
    final bool targetValue;
    if (velocity.abs() >= 400.0) {
      targetValue = velocity > 0.0;
    } else {
      targetValue = _positionController.value >= 0.5;
    }

    _positionController.animateTo(
      targetValue ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
      curve: const Cubic(0.25, 0.9, 0.35, 1.0),
    );

    if (targetValue != widget.value) {
      _triggerHaptic(targetValue);
      widget.onChanged?.call(targetValue);
    }
  }

  void _handleDragCancel() {
    if (!_isDragging) return;
    _isDragging = false;
    _stretchController.reverse();
    _positionController.animateTo(
      widget.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
      curve: const Cubic(0.25, 0.9, 0.35, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = p.isDark;

    final onColor =
        widget.activeColor ??
        (widget.useAppleGreen
            ? (isDark ? const Color(0xFF30D158) : const Color(0xFF34C759))
            : p.accent);

    final offColor = isDark
        ? const Color(0xFF8E8E93).withValues(alpha: 0.36)
        : const Color(0xFF8E8E93).withValues(alpha: 0.22);

    return Semantics(
      toggled: widget.value,
      enabled: widget.enabled,
      onTap: (widget.enabled && widget.onChanged != null) ? _handleTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onHorizontalDragCancel: _handleDragCancel,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _positionAnimation,
                _stretchAnimation,
              ]),
              builder: (context, _) {
                final pos = _positionAnimation.value;
                final stretch = 1.0 + (_stretchAnimation.value * 0.16);
                final currentTrackColor =
                    Color.lerp(offColor, onColor, pos) ?? offColor;

                final thumbOffset = _thumbPadding + (_maxTravel * pos);

                return Opacity(
                  opacity: widget.enabled ? 1.0 : 0.45,
                  child: Container(
                    width: _trackWidth,
                    height: _trackHeight,
                    decoration: BoxDecoration(
                      color: currentTrackColor,
                      borderRadius: BorderRadius.circular(_trackHeight / 2),
                      border: Border.all(
                        color: p.border.withValues(alpha: isDark ? 0.25 : 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Transform.translate(
                          offset: Offset(thumbOffset, 0),
                          child: Transform.scale(
                            scaleX: stretch,
                            // When at left (pos <= 0.5), anchor left edge so stretch expands right (inward).
                            // When at right (pos > 0.5), anchor right edge so stretch expands left (inward).
                            alignment: pos > 0.5
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: _thumbDiameter,
                              height: _thumbDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.16),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 1.0,
                                    offset: const Offset(0, 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
