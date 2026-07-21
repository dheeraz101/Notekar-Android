import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

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
    this.onBack,
    this.leadingAction,
    this.trailingAction,
    this.largeText = false,
    this.removeBottomPadding = false,
  });

  final Palette p;
  final String title;
  final Widget child;
  final bool docked;
  final bool blur;
  final ScrollController? controller;
  final bool showLargeTitle;
  final VoidCallback? onBack;
  final Widget? leadingAction;
  final Widget? trailingAction;
  final bool largeText;
  final bool removeBottomPadding;

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
  void didUpdateWidget(AppSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the controller changes (e.g. returning to root settings), 
    // swap listeners and sync opacity immediately.
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onScroll);
      if (widget.controller != null && widget.showLargeTitle) {
        widget.controller!.addListener(_onScroll);
        // Instant sync prevents the "ghost/flicker" effect
        _onScroll();
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final offset = widget.controller?.hasClients == true ? widget.controller!.offset : 0.0;
    // Small title is invisible until we scroll past the large title area (~45px)
    // Then fades in rapidly over the next 20px.
    final newOpacity = ((offset - 45) / 20).clamp(0.0, 1.0);
    if (newOpacity != _titleOpacity) {
      setState(() => _titleOpacity = newOpacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    Widget content = GestureDetector(
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
          widget.removeBottomPadding
              ? MediaQuery.paddingOf(context).bottom
              : (widget.docked ? MediaQuery.paddingOf(context).bottom + spacing16 : spacing16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.docked ? 720 : 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The Drag Handle
              Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: spacing8),
                decoration: BoxDecoration(
                  color: p.text3.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              // Header Area (Stack for absolute horizontal centering)
              SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.onBack != null)
                      Positioned(
                        left: 0,
                        child: _HeaderCircleButton(
                          p: p,
                          icon: Icons.chevron_left_rounded,
                          onTap: widget.onBack!,
                        ),
                      )
                    else if (widget.leadingAction != null)
                      Positioned(
                        left: 0,
                        child: widget.leadingAction!,
                      ),
                    Positioned.fill(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Opacity(
                            opacity: widget.showLargeTitle ? _titleOpacity : 1.0,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: FittedBox(
                                key: ValueKey<String>(widget.title),
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.title,
                                  maxLines: 1,
                                  softWrap: false,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.trailingAction != null) ...[
                            widget.trailingAction!,
                            const SizedBox(width: 8),
                          ],
                          _HeaderCircleButton(
                            p: p,
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: spacing20),
              widget.child,
            ],
          ),
        ),
      ),
    );

    if (widget.largeText) {
      content = MediaQuery(
        data: largerTextQuery(context),
        child: content,
      );
    }

    if (widget.docked) {
      return Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 10),
        child: content,
      );
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(spacing16),
      child: content,
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.p,
    required this.icon,
    required this.onTap,
  });

  final Palette p;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: p.surface3,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: p.text2,
          size: 22,
        ),
      ),
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
            // Large title fades out slightly before the small title starts appearing
            final opacity = (1.0 - (offset / 40)).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: spacing16),
                child: Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
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
