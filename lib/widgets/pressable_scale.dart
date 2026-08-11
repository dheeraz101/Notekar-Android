import 'package:flutter/material.dart';

class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.enabled = true,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled =
        widget.enabled && (widget.onTap != null || widget.onLongPress != null);
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: enabled ? widget.onTap : null,
        onLongPress: enabled ? widget.onLongPress : null,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: Duration(milliseconds: _pressed ? 80 : 140),
          curve: _pressed ? Curves.easeOutQuad : Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
