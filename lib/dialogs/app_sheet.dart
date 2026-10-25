import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/scroll_state_preserver.dart';
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
    this.scrollLeadingAction,
    this.trailingAction,
    this.largeText = false,
    this.removeBottomPadding = false,
    this.onTitleTap,
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
  final Widget? scrollLeadingAction;
  final Widget? trailingAction;
  final bool largeText;
  final bool removeBottomPadding;
  final VoidCallback? onTitleTap;

  @override
  State<AppSheet> createState() => _AppSheetState();
}

class _AppSheetState extends State<AppSheet> {
  double _titleOpacity = 0.0;
  double _leadingOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null && widget.showLargeTitle) {
      widget.controller!.addListener(_onScroll);
      _onScroll();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onScroll();
    });
  }

  @override
  void didUpdateWidget(AppSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the controller or showLargeTitle changes (e.g. returning to root settings),
    // swap listeners and sync opacity immediately.
    if (widget.controller != oldWidget.controller ||
        widget.showLargeTitle != oldWidget.showLargeTitle) {
      oldWidget.controller?.removeListener(_onScroll);
      if (widget.controller != null && widget.showLargeTitle) {
        widget.controller!.addListener(_onScroll);
      }
      _onScroll();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onScroll();
      });
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    double offset = 0.0;
    if (widget.controller?.hasClients == true) {
      offset = widget.controller!.offset;
    } else {
      offset = AppScrollState.get('settings_root');
      if (offset == 0.0 && widget.controller != null) {
        offset = widget.controller!.initialScrollOffset;
      }
    }
    _updateWithOffset(offset);
  }

  void _updateWithOffset(double offset) {
    // Small title is invisible until we scroll past the large title area (~45px)
    // Then fades in rapidly over the next 20px.
    final newTitleOpacity = ((offset - 45) / 20).clamp(0.0, 1.0);
    // Profile circle fades in only once the main profile card has scrolled completely away (>190px).
    // When scrolled up and profile card is visible enough (offset <= 190), top circle is strictly 0.0 (hidden).
    final newLeadingOpacity = offset <= 190.0
        ? 0.0
        : ((offset - 190.0) / 30.0).clamp(0.0, 1.0);

    if (newTitleOpacity != _titleOpacity ||
        newLeadingOpacity != _leadingOpacity) {
      setState(() {
        _titleOpacity = newTitleOpacity;
        _leadingOpacity = newLeadingOpacity;
      });
    }
  }

  void _handleTitleTap(BuildContext context) {
    if (widget.onTitleTap != null) {
      widget.onTitleTap!();
      return;
    }
    if (widget.controller?.hasClients == true) {
      widget.controller!.animateTo(
        0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
      return;
    }
    final primary = PrimaryScrollController.maybeOf(context);
    if (primary?.hasClients == true) {
      primary!.animateTo(
        0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
      return;
    }
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable?.position.hasContentDimensions == true) {
      scrollable!.position.animateTo(
        0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
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
        radius: widget.docked ? 38 : 32,
        borderRadius: widget.docked
            ? const BorderRadius.vertical(top: Radius.circular(38))
            : null,
        padding: EdgeInsets.fromLTRB(
          12.0,
          spacing8,
          12.0,
          widget.removeBottomPadding
              ? MediaQuery.paddingOf(context).bottom
              : (widget.docked
                    ? MediaQuery.paddingOf(context).bottom + spacing16
                    : spacing16),
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
              () {
                final hasLeading =
                    widget.onBack != null ||
                    widget.leadingAction != null ||
                    widget.scrollLeadingAction != null;
                final hasTrailingAction = widget.trailingAction != null;
                final leadingWidth = hasLeading ? 40.0 : 0.0;
                final trailingWidth = 40.0 + (hasTrailingAction ? 40.0 : 0.0);
                final symmetricalMargin =
                    (leadingWidth > trailingWidth
                        ? leadingWidth
                        : trailingWidth) +
                    12.0;
                final horizontalPadding = symmetricalMargin > 88.0
                    ? symmetricalMargin
                    : 88.0;

                return SizedBox(
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
                        Positioned(left: 0, child: widget.leadingAction!)
                      else if (widget.scrollLeadingAction != null)
                        Positioned(
                          left: 0,
                          child: IgnorePointer(
                            ignoring:
                                widget.showLargeTitle &&
                                _leadingOpacity <= 0.05,
                            child: Opacity(
                              opacity: widget.showLargeTitle
                                  ? _leadingOpacity
                                  : 1.0,
                              child: widget.scrollLeadingAction!,
                            ),
                          ),
                        ),
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: Opacity(
                              opacity: widget.showLargeTitle
                                  ? _titleOpacity
                                  : 1.0,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: FittedBox(
                                  key: ValueKey<String>(widget.title),
                                  fit: BoxFit.scaleDown,
                                  child: PressableScale(
                                    onTap: () => _handleTitleTap(context),
                                    child: Text(
                                      widget.title.localized(context),
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
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }(),
              const SizedBox(height: spacing20),
              Flexible(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (widget.showLargeTitle &&
                        notification.metrics.axis == Axis.vertical) {
                      _updateWithOffset(notification.metrics.pixels);
                    }
                    return false;
                  },
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.largeText) {
      content = MediaQuery(data: largerTextQuery(context), child: content);
    }

    if (widget.docked) {
      final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
      return AnimatedPadding(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + 10,
          bottom: bottomInset,
        ),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: content,
      );
    }
    return AnimatedPadding(
      padding:
          MediaQuery.viewInsetsOf(context) + const EdgeInsets.all(spacing16),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Center(
        child: Material(type: MaterialType.transparency, child: content),
      ),
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
      onTap: () {
        HapticFeedback.selectionClick();
        NotekarHaptics.selection('standard');
        onTap();
      },
      child: SizedBox(
        width: 44,
        height: 44,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.surface3,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: p.text2, size: 22),
          ),
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
    this.onTap,
  });

  final Palette p;
  final String title;
  final Widget? extra;
  final ScrollController? scrollController;
  final VoidCallback? onTap;

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    if (scrollController?.hasClients == true) {
      scrollController!.animateTo(
        0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
      return;
    }
    final primary = PrimaryScrollController.maybeOf(context);
    if (primary?.hasClients == true) {
      primary!.animateTo(
        0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
      return;
    }
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable?.position.hasContentDimensions == true) {
      scrollable!.position.animateTo(
        0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: scrollController ?? ScrollController(),
          builder: (context, _) {
            final offset = scrollController?.hasClients == true
                ? scrollController!.offset
                : (scrollController != null
                      ? AppScrollState.get('settings_root')
                      : 0.0);
            // Large title fades out slightly before the small title starts appearing
            final opacity = (1.0 - (offset / 40)).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: spacing16),
                child: PressableScale(
                  onTap: () => _handleTap(context),
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
              ),
            );
          },
        ),
        if (extra != null) ...[extra!, const SizedBox(height: spacing16)],
      ],
    );
  }
}
