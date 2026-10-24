import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom HorizontalDragGestureRecognizer that ONLY accepts touches originating from the left edge.
/// By rejecting pointers where event.localPosition.dx > edgeWidth in addAllowedPointer(),
/// it never participates in Flutter's gesture arena for non-edge touches, leaving all
/// horizontal carousels, docks, and child drag recognizers completely unhindered.
class _EdgeDragGestureRecognizer extends HorizontalDragGestureRecognizer {
  _EdgeDragGestureRecognizer();

  double edgeWidth = 40.0;
  bool enabled = true;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (enabled && event.localPosition.dx <= edgeWidth) {
      super.addAllowedPointer(event);
    }
  }
}

/// Interactive Apple HIG / Android 14/15 predictive back peek gesture wrapper.
///
/// Wraps nested pages with a responsive gesture detector that captures edge swipes
/// starting from the left edge (dx <= 40). Smoothly scales the view down (1.0 -> 0.92)
/// and translates horizontally with rounded corner card elevation.
/// When dragged beyond the threshold (>80px or velocity > 300), triggers a haptic
/// click and pops the view. If released earlier, smoothly springs back into place.
class PredictiveBackPeek extends StatefulWidget {
  const PredictiveBackPeek({
    super.key,
    required this.child,
    required this.onPop,
    this.enabled = true,
    this.edgeWidth = 40.0,
    this.popThreshold = 80.0,
    this.velocityThreshold = 300.0,
  });

  final Widget child;
  final VoidCallback onPop;
  final bool enabled;
  final double edgeWidth;
  final double popThreshold;
  final double velocityThreshold;

  @override
  State<PredictiveBackPeek> createState() => _PredictiveBackPeekState();
}

class _PredictiveBackPeekState extends State<PredictiveBackPeek>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _translateAnim;

  bool _isDragging = false;
  double _dragDistance = 0.0;
  bool _hapticTriggered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.0).animate(_animController);
    _translateAnim = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    if (details.localPosition.dx <= widget.edgeWidth) {
      _isDragging = true;
      _dragDistance = 0.0;
      _hapticTriggered = false;
      _animController.stop();
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragDistance = math.max(0.0, _dragDistance + details.delta.dx);
      if (_dragDistance >= widget.popThreshold && !_hapticTriggered) {
        _hapticTriggered = true;
        HapticFeedback.selectionClick();
      } else if (_dragDistance < widget.popThreshold && _hapticTriggered) {
        _hapticTriggered = false;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0.0;
    final shouldPop =
        _dragDistance >= widget.popThreshold ||
        velocity >= widget.velocityThreshold;

    if (shouldPop) {
      if (!_hapticTriggered) {
        HapticFeedback.selectionClick();
      }
      widget.onPop();
      _dragDistance = 0.0;
      _hapticTriggered = false;
    } else {
      // Spring back to 1.0 scale and 0.0 translation
      final currentTranslate = _dragDistance * 0.45;
      final progress = (_dragDistance / 160.0).clamp(0.0, 1.0);
      final currentScale = 1.0 - (0.08 * progress);

      _scaleAnim = Tween<double>(begin: currentScale, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _translateAnim = Tween<double>(begin: currentTranslate, end: 0.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );

      _animController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _dragDistance = 0.0;
            _hapticTriggered = false;
          });
        }
      });
    }
  }

  void _onHorizontalDragCancel() {
    if (!_isDragging) return;
    _isDragging = false;
    setState(() {
      _dragDistance = 0.0;
      _hapticTriggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final progress = (_dragDistance / 160.0).clamp(0.0, 1.0);
        final scale = _isDragging
            ? (1.0 - (0.08 * progress))
            : _scaleAnim.value;
        final translateX = _isDragging
            ? (_dragDistance * 0.45)
            : _translateAnim.value;
        final borderRadius = _isDragging ? (14.0 * progress) : 0.0;

        return RawGestureDetector(
          behavior: HitTestBehavior.translucent,
          gestures: <Type, GestureRecognizerFactory>{
            _EdgeDragGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                  _EdgeDragGestureRecognizer
                >(() => _EdgeDragGestureRecognizer(), (
                  _EdgeDragGestureRecognizer instance,
                ) {
                  instance
                    ..edgeWidth = widget.edgeWidth
                    ..enabled = widget.enabled
                    ..onStart = _onHorizontalDragStart
                    ..onUpdate = _onHorizontalDragUpdate
                    ..onEnd = _onHorizontalDragEnd
                    ..onCancel = _onHorizontalDragCancel;
                }),
          },
          child: Transform.translate(
            offset: Offset(translateX, 0.0),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
