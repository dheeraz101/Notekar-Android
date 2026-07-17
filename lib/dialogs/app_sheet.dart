import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/glass.dart';

class AppSheet extends StatefulWidget {
  const AppSheet({
    super.key,
    required this.p,
    required this.title,
    required this.child,
    this.docked = false,
    this.blur = false,
    this.controller,
    this.showLargeTitle = false,
    this.headerExtra,
  });

  final Palette p;
  final String title;
  final Widget child;
  final bool docked;
  final bool blur;
  final ScrollController? controller;
  final bool showLargeTitle;
  final Widget? headerExtra;

  @override
  State<AppSheet> createState() => _AppSheetState();
}

class _AppSheetState extends State<AppSheet> {
  double _titleOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null && widget.showLargeTitle) {
      widget.controller!.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final offset = widget.controller!.offset;
    // Faster transition for the small title
    final newOpacity = (offset / 30).clamp(0.0, 1.0);
    if (newOpacity != _titleOpacity) {
      setState(() => _titleOpacity = newOpacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final content = GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 650) {
          Navigator.maybePop(context);
        }
      },
      child: Glass(
        p: p,
        blur: widget.blur,
        radius: widget.docked ? 24 : 24,
        borderRadius: widget.docked
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : null,
        padding: EdgeInsets.fromLTRB(
          spacing16,
          spacing8,
          spacing16,
          widget.docked ? spacing12 : spacing16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.docked ? 720 : 460,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: spacing8),
                decoration: BoxDecoration(
                  color: p.text3.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: widget.showLargeTitle ? _titleOpacity : 1.0,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: p.text2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spacing4),
              widget.child,
            ],
          ),
        ),
      ),
    );
    if (widget.docked) {
      return Padding(padding: const EdgeInsets.only(top: 8), child: content);
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: content,
    );
  }
}

class AppSheetLargeTitle extends StatelessWidget {
  const AppSheetLargeTitle({
    super.key,
    required this.p,
    required this.title,
    this.extra,
    this.scrollController,
  });

  final Palette p;
  final String title;
  final Widget? extra;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: scrollController ?? ScrollController(),
          builder: (context, _) {
            final offset = scrollController?.hasClients == true ? scrollController!.offset : 0.0;
            final opacity = (1.0 - (offset / 40)).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: spacing16),
                child: Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            );
          },
        ),
        if (extra != null) ...[
          extra!,
          const SizedBox(height: spacing16),
        ],
      ],
    );
  }
}
