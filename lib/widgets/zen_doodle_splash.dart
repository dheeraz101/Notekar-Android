import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';

/// Instant, elegant single-screen splash for NoteKar with WhatsApp-style doodle background
/// and the official NoteKar logo. Instant dismiss on tap or after display duration.
class ZenDoodleSplash extends StatefulWidget {
  const ZenDoodleSplash({
    super.key,
    required this.p,
    required this.onComplete,
    this.displayDuration = const Duration(milliseconds: 900),
  });

  final Palette p;
  final VoidCallback onComplete;
  final Duration displayDuration;

  /// Global session flag ensuring splash only plays once per app process launch.
  static bool hasShownThisSession = false;

  @override
  State<ZenDoodleSplash> createState() => _ZenDoodleSplashState();
}

class _ZenDoodleSplashState extends State<ZenDoodleSplash> {
  Timer? _timer;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    ZenDoodleSplash.hasShownThisSession = true;

    _timer = Timer(widget.displayDuration, _finish);
  }

  void _finish() {
    if (_isExiting) return;
    _isExiting = true;
    _timer?.cancel();
    if (mounted) {
      widget.onComplete();
    }
  }

  void _skipInstantly() {
    if (_isExiting) return;
    HapticFeedback.selectionClick();
    _finish();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _skipInstantly,
      child: ColoredBox(
        color: const Color(0xFF0C0F14), // Dark WhatsApp-style charcoal base
        child: Stack(
          fit: StackFit.expand,
          children: [
            // WhatsApp-style Doodle Pattern Background Wallpaper
            Image.asset(
              'assets/images/whatsapp_doodle_wallpaper.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),

            // Subtle radial vignette overlay to gently soften the background behind center logo
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    const Color(0xFF0C0F14).withValues(alpha: 0.40),
                    const Color(0xFF0C0F14).withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),

            // Center: Authentic NoteKar Logo Badge and Brand Typography
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Official NoteKar Squircle Badge with Ambient Glow
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A22),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: p.accent.withValues(alpha: 0.20),
                          blurRadius: 36,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Image.asset(
                        'app_icons/black.png',
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(23),
                          child: Image.asset(
                            'icon-maskable-512.png',
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.hourglass_empty_rounded,
                              size: 48,
                              color: p.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // NoteKar Brand Name
                  const Text(
                    'NoteKar',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Intentionality Subtitle
                  Text(
                    'Every moment intentional.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Brand Anchor (WhatsApp / Meta style)
            Positioned(
              bottom: 32 + MediaQuery.paddingOf(context).bottom,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'from',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'DIGITALSURAKSHA',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
