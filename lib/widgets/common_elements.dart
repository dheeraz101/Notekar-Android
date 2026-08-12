import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class ChipButton extends StatelessWidget {
  const ChipButton({
    super.key,
    required this.p,
    this.label,
    this.icon,
    this.semanticLabel,
    required this.active,
    required this.onTap,
    this.onLongPress,
  });

  final Palette p;
  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? p.surface3 : p.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? p.accent : p.border),
          boxShadow: active ? selectedGlow(p.accent) : null,
        ),
        child: icon == null
            ? Text(
                label ?? '',
                style: TextStyle(
                  color: active ? p.text : p.text2,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              )
            : Icon(
                icon,
                color: active ? p.text : p.text2,
                size: 17,
                semanticLabel: semanticLabel,
              ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.p, required this.text});

  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        spacing8,
        spacing24,
        spacing8,
        spacing8,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: p.text3,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
  });

  final String text;
  final String? query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final q = query?.trim();
    if (q == null || q.isEmpty) {
      return Text(text, style: baseStyle);
    }
    final lower = text.toLowerCase();
    final index = lower.indexOf(q.toLowerCase());
    if (index < 0) return Text(text, style: baseStyle);
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + q.length),
            style: highlightStyle,
          ),
          TextSpan(text: text.substring(index + q.length)),
        ],
      ),
    );
  }
}

class SettingsStatusPill extends StatelessWidget {
  const SettingsStatusPill({
    super.key,
    required this.p,
    required this.label,
    required this.color,
  });

  final Palette p;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String cleanLabel = label.trim().toUpperCase();
    IconData? typeIcon;
    if (cleanLabel == 'IN') {
      typeIcon = Icons.south_west_rounded;
    } else if (cleanLabel == 'OUT') {
      typeIcon = Icons.north_east_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (typeIcon != null) ...[
            Icon(typeIcon, color: color, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPageNote extends StatelessWidget {
  const SettingsPageNote({super.key, required this.p, required this.text});

  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              Icons.info_outline_rounded,
              color: p.text3.withValues(alpha: 0.6),
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.text3,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagnosticRow extends StatelessWidget {
  const DiagnosticRow({
    super.key,
    required this.p,
    required this.label,
    required this.value,
  });

  final Palette p;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing12,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: spacing12),
            Expanded(
              flex: 5,
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.text2, fontSize: 13, height: 1.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HIGEmptyState extends StatelessWidget {
  const HIGEmptyState({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 32 : 44),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 56 : 72,
              color: p.text3.withValues(alpha: 0.25),
            ),
            SizedBox(height: compact ? 16 : 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: compact ? 18 : 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text3,
                fontSize: compact ? 14 : 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? 20 : 28),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SliverStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  SliverStickyHeaderDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverStickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class HIGShimmerLoader extends StatefulWidget {
  const HIGShimmerLoader({
    super.key,
    required this.p,
    this.height = 60,
    this.count = 3,
    this.radius = 24,
  });

  final Palette p;
  final double height;
  final int count;
  final double radius;

  @override
  State<HIGShimmerLoader> createState() => _HIGShimmerLoaderState();
}

class _HIGShimmerLoaderState extends State<HIGShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.20,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            for (int i = 0; i < widget.count; i++) ...[
              Container(
                height: widget.height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.p.surface3.withValues(alpha: _animation.value),
                  borderRadius: BorderRadius.circular(widget.radius),
                  border: Border.all(
                    color: widget.p.border.withValues(alpha: 0.3),
                  ),
                ),
              ),
              if (i < widget.count - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

/// Shows an Apple iOS-style Dynamic Pill Toast Notification floating at the top of the screen.
void showIosPillToast({
  required BuildContext context,
  required Palette p,
  required String message,
  IconData icon = Icons.check_circle_rounded,
  Duration duration = const Duration(milliseconds: 2000),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return _IosPillToastWidget(
        p: p,
        message: message,
        icon: icon,
        onDismiss: () => entry.remove(),
        duration: duration,
      );
    },
  );

  overlay.insert(entry);
}

class _IosPillToastWidget extends StatefulWidget {
  const _IosPillToastWidget({
    required this.p,
    required this.message,
    required this.icon,
    required this.onDismiss,
    required this.duration,
  });

  final Palette p;
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;
  final Duration duration;

  @override
  State<_IosPillToastWidget> createState() => _IosPillToastWidgetState();
}

class _IosPillToastWidgetState extends State<_IosPillToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final p = widget.p;

    return Positioned(
      top: topInset + 12,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: p.name == 'amoled'
                          ? Colors.black
                          : (p.name == 'light'
                                ? const Color(0xF01C1C1E)
                                : p.surface2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: p.accent, size: 18),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
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
