import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';

/// Minimalist, Apple HIG-style launch splash for NoteKar.
/// Displays a serene adaptive canvas, iconic squircle emblem, and brand typography
/// with immediate tap-to-dismiss and a silky smooth micro-fade transition.
class ZenDoodleSplash extends StatefulWidget {
  const ZenDoodleSplash({
    super.key,
    required this.p,
    required this.onComplete,
    this.displayDuration = const Duration(milliseconds: 350),
  });

  final Palette p;
  final VoidCallback onComplete;
  final Duration displayDuration;

  /// Global session flag ensuring splash only plays once per app process launch.
  static bool hasShownThisSession = false;

  @override
  State<ZenDoodleSplash> createState() => _ZenDoodleSplashState();
}

class _ZenDoodleSplashState extends State<ZenDoodleSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _opacityAnimation;
  Timer? _timer;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    ZenDoodleSplash.hasShownThisSession = true;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _timer = Timer(widget.displayDuration, _finish);
  }

  void _finish({bool immediate = false}) {
    if (_isExiting) return;
    _isExiting = true;
    _timer?.cancel();
    if (immediate) {
      if (mounted) widget.onComplete();
    } else {
      _fadeController.forward().then((_) {
        if (mounted) widget.onComplete();
      });
    }
  }

  void _skipInstantly() {
    if (_isExiting) return;
    HapticFeedback.selectionClick();
    _finish(immediate: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _skipInstantly,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ColoredBox(
          color: p.bg,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clean Apple HIG Squircle Emblem
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: p.border.withValues(alpha: p.isDark ? 0.35 : 0.6),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: p.isDark ? 0.30 : 0.07,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.asset(
                      'app_icons/black.png',
                      width: 68,
                      height: 68,
                      cacheWidth: 136,
                      cacheHeight: 136,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.asset(
                          'icon-maskable-512.png',
                          width: 68,
                          height: 68,
                          cacheWidth: 136,
                          cacheHeight: 136,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.hourglass_empty_rounded,
                            size: 34,
                            color: p.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // NoteKar Brand Name
                Text(
                  'NoteKar',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: p.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),

                // Intentionality Subtitle
                Text(
                  'Every moment intentional.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: p.text3,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
