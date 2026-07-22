import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/l10n/app_localizations.dart';

class Ripple extends StatefulWidget {
  const Ripple({super.key, required this.origin, required this.color});
  final Offset origin;
  final Color color;

  @override
  State<Ripple> createState() => _RippleState();
}

class _RippleState extends State<Ripple> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.origin.dx - 20,
      top: widget.origin.dy - 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final scale = 1 + Curves.easeOutCubic.transform(_controller.value) * 2.4;
          return RepaintBoundary(
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: (1 - _controller.value).clamp(0.0, 0.16),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.35),
                      width: 1.3,
                    ),
                    color: widget.color.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UndoToast extends StatefulWidget {
  const UndoToast({
    super.key,
    required this.p,
    required this.onUndo,
    required this.token,
  });

  final Palette p;
  final VoidCallback onUndo;
  final int token;

  @override
  State<UndoToast> createState() => _UndoToastState();
}

class _UndoToastState extends State<UndoToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant UndoToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Glass(
        p: widget.p,
        radius: 999,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, _) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (1 - _controller.value).clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.p.accent.withValues(alpha: 0.10),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Moment saved'.localized(context),
                      style: TextStyle(color: widget.p.text),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onUndo,
                      child: Text(
                        'Undo'.localized(context),
                        style: TextStyle(
                          color: widget.p.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SavedPulse extends StatefulWidget {
  const SavedPulse({
    super.key,
    required this.origin,
    required this.p,
    required this.type,
  });

  final Offset origin;
  final Palette p;
  final String type;

  @override
  State<SavedPulse> createState() => _SavedPulseState();
}

class _SavedPulseState extends State<SavedPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.origin.dx - 54,
      top: widget.origin.dy - 44, // Base position, dy offset applied inside
      width: 108,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final dy = -18 * Curves.easeOutCubic.transform(_controller.value);
          final opacity = (1 - Curves.easeOut.transform(_controller.value)).clamp(0.0, 1.0);
          final color = momentColor(widget.p, widget.type);
          return Transform.translate(
            offset: Offset(0, dy),
            child: RepaintBoundary(
              child: Opacity(
                opacity: opacity,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: color.withValues(alpha: 0.24)),
                  ),
                  child: Text(
                    _pulseLabel(widget.type, context),
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _pulseLabel(String type, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final isEs = l10n?.localeName == 'es';
  final isHi = l10n?.localeName == 'hi';

  return switch (type) {
    'in' => isEs ? 'IN guardado' : (isHi ? 'IN सहेजा गया' : 'IN saved'),
    'out' => isEs ? 'OUT guardado' : (isHi ? 'OUT सहेजा गया' : 'OUT saved'),
    'single' => isEs ? 'SINGLE guardado' : (isHi ? 'SINGLE सहेजा गया' : 'SINGLE saved'),
    _ => isEs ? 'Guardado' : (isHi ? 'सहेजा गया' : 'Saved'),
  };
}
