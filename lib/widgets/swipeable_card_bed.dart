import 'package:flutter/material.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';

/// An Apple-grade physical swipeable card that reveals a true bed of color
/// directly underneath the sliding card.
///
/// Unlike Flutter's [Dismissible] which clips the background to a straight
/// vertical line (leaving empty gaps where rounded corners curve),
/// [SwipeableCardBed] layers the sliding card over a solid bed that shares
/// the exact same [borderRadius].
class SwipeableCardBed extends StatefulWidget {
  const SwipeableCardBed({
    super.key,
    required this.child,
    required this.borderRadius,
    this.deleteColor,
    this.editColor,
    this.deleteLabel = 'Delete',
    this.editLabel = 'Note',
    this.actionIconSize = 22,
    this.actionFontSize = 13,
    this.onDelete,
    this.onEdit,
    this.enabled = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color? deleteColor;
  final Color? editColor;
  final String deleteLabel;
  final String editLabel;
  final double actionIconSize;
  final double actionFontSize;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool enabled;

  @override
  State<SwipeableCardBed> createState() => SwipeableCardBedState();
}

class SwipeableCardBedState extends State<SwipeableCardBed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _animation;
  double _dx = 0.0;
  bool _isDragging = false;
  bool _thresholdMet = false;

  static const double _threshold = 72.0;
  static const double _maxDrag = 130.0;

  /// Exposed for testing
  double get currentOffset => _dx;

  bool get isThresholdMet => _thresholdMet;

  bool get isDragging => _isDragging;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 260),
        )..addListener(() {
          if (!mounted) return;
          if (_animation != null) {
            setState(() {
              _dx = _animation!.value;
            });
          }
        });
  }

  @override
  void didUpdateWidget(covariant SwipeableCardBed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && oldWidget.enabled && _dx != 0) {
      _dx = 0;
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    _controller.stop();
    _isDragging = true;
    _thresholdMet = false;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;

    double newDx = _dx + details.primaryDelta!;

    // Restrict direction if callbacks are null
    if (widget.onEdit == null && newDx > 0) {
      newDx = 0;
    }
    if (widget.onDelete == null && newDx < 0) {
      newDx = 0;
    }

    // Rubber-band resistance past max drag
    if (newDx < -_maxDrag) {
      final overflow = -_maxDrag - newDx;
      newDx = -_maxDrag - (overflow * 0.25);
    } else if (newDx > _maxDrag) {
      final overflow = newDx - _maxDrag;
      newDx = _maxDrag + (overflow * 0.25);
    }

    final crossed = newDx.abs() >= _threshold;
    if (crossed && !_thresholdMet) {
      _thresholdMet = true;
      AppHaptics.selection();
    } else if (!crossed && _thresholdMet) {
      _thresholdMet = false;
      AppHaptics.selection();
    }

    setState(() {
      _dx = newDx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0.0;
    final fastLeftFling = velocity < -350 && widget.onDelete != null;
    final fastRightFling = velocity > 350 && widget.onEdit != null;

    final shouldTrigger = _thresholdMet || fastLeftFling || fastRightFling;

    if (shouldTrigger) {
      if ((_dx < 0 || fastLeftFling) && widget.onDelete != null) {
        AppHaptics.heavy();
        widget.onDelete?.call();
      } else if ((_dx > 0 || fastRightFling) && widget.onEdit != null) {
        AppHaptics.light();
        widget.onEdit?.call();
      }
    }

    _animateBack();
  }

  void _onHorizontalDragCancel() {
    if (!widget.enabled) return;
    _isDragging = false;
    _animateBack();
  }

  void _animateBack() {
    _thresholdMet = false;
    _animation = Tween<double>(
      begin: _dx,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0.0);
  }

  Widget _buildDeleteAction(BuildContext context) {
    final progress = (_dx.abs() / _threshold).clamp(0.0, 1.0);
    return Opacity(
      opacity: (progress * 1.5).clamp(0.0, 1.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.deleteLabel.localized(context),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: widget.actionFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: widget.actionIconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildEditAction(BuildContext context) {
    final progress = (_dx.abs() / _threshold).clamp(0.0, 1.0);
    return Opacity(
      opacity: (progress * 1.5).clamp(0.0, 1.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_note_rounded,
            color: Colors.white,
            size: widget.actionIconSize,
          ),
          const SizedBox(width: 8),
          Text(
            widget.editLabel.localized(context),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: widget.actionFontSize,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final isDelete = _dx < 0;
    final bedColor = isDelete
        ? (widget.deleteColor ?? const Color(0xFFFF3B30))
        : (widget.editColor ?? const Color(0xFF007AFF));

    final isVisible = _dx != 0 || _isDragging || _controller.isAnimating;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragCancel: _onHorizontalDragCancel,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Layer 0: True Bed of Color directly beneath the card
            if (isVisible)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: bedColor,
                    borderRadius: widget.borderRadius,
                  ),
                  alignment: isDelete
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: isDelete
                      ? _buildDeleteAction(context)
                      : _buildEditAction(context),
                ),
              ),

            // Layer 1: Foreground Card translating smoothly over the bed
            Transform.translate(offset: Offset(_dx, 0), child: widget.child),
          ],
        ),
      ),
    );
  }
}
