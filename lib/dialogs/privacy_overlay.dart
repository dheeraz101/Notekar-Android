import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class PrivacyLockOverlay extends StatefulWidget {
  const PrivacyLockOverlay({
    super.key,
    required this.p,
    required this.onUnlock,
    required this.isSystemLockAvailable,
    this.customPin,
    required this.failedAttempts,
    required this.lockoutUntil,
    required this.onUnlockSuccess,
    required this.onUnlockFailed,
    required this.enableTranslucency,
    required this.reduceMotion,
  });

  final Palette p;
  final VoidCallback onUnlock;
  final bool isSystemLockAvailable;
  final String? customPin;
  final int failedAttempts;
  final int lockoutUntil;
  final VoidCallback onUnlockSuccess;
  final VoidCallback onUnlockFailed;
  final bool enableTranslucency;
  final bool reduceMotion;

  @override
  State<PrivacyLockOverlay> createState() => _PrivacyLockOverlayState();
}

class _PrivacyLockOverlayState extends State<PrivacyLockOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  String _enteredPin = '';
  Timer? _lockoutTimer;
  int _secondsRemaining = 0;

  bool _hasError = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _checkLockout();
  }

  @override
  void didUpdateWidget(PrivacyLockOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lockoutUntil != oldWidget.lockoutUntil) {
      _checkLockout();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  String _getSubtitleText() {
    if (_secondsRemaining > 0) {
      return 'Too many failed attempts.';
    }
    if (_isCorrect) {
      return 'Access Granted';
    }
    if (_hasError && widget.failedAttempts > 0) {
      final remaining = 5 - widget.failedAttempts;
      if (remaining > 0) {
        if (remaining == 1) {
          return 'Incorrect passcode. 1 try remaining before lockout.';
        }
        return 'Incorrect passcode. $remaining tries remaining before lockout.';
      }
    }
    return 'NoteKar is locked. Confirm your 4-digit PIN.';
  }

  void _checkLockout() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final until = widget.lockoutUntil;
    if (until > now) {
      setState(() {
        _secondsRemaining = ((until - now) / 1000).ceil();
      });
      _lockoutTimer?.cancel();
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        final currentNow = DateTime.now().millisecondsSinceEpoch;
        if (currentNow >= until) {
          timer.cancel();
          setState(() {
            _secondsRemaining = 0;
          });
        } else {
          setState(() {
            _secondsRemaining = ((until - currentNow) / 1000).ceil();
          });
        }
      });
    } else {
      _secondsRemaining = 0;
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode('${pin}notekar_salt_secure_2026');
    return sha256.convert(bytes).toString();
  }

  void _onKeyPress(String val) {
    if (_secondsRemaining > 0 || _isCorrect) return;
    if (_enteredPin.length >= 4) return;
    HapticFeedback.lightImpact();

    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }

    setState(() {
      _enteredPin += val;
    });

    if (_enteredPin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        final hashedEntered = _hashPin(_enteredPin);
        if (hashedEntered == widget.customPin) {
          setState(() {
            _isCorrect = true;
          });
          HapticFeedback.mediumImpact();
          Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) {
              widget.onUnlockSuccess();
            }
          });
        } else {
          HapticFeedback.heavyImpact();
          _shakeController.forward(from: 0.0);
          setState(() {
            _hasError = true;
            _enteredPin = '';
          });
          widget.onUnlockFailed();
        }
      });
    }
  }

  void _onDelete() {
    if (_secondsRemaining > 0 || _isCorrect) return;
    if (_enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (_hasError) _hasError = false;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final isDark = p.bg.computeLuminance() < 0.5;

    // Detect if glass effects are allowed (not low end, translucency enabled, motion enabled)
    final useGlass = widget.enableTranslucency &&
        AdaptiveEngine().supportsBlur &&
        !widget.reduceMotion;

    if (useGlass) {
      final overlayBgColor = isDark
          ? Colors.black.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.6);

      return Positioned.fill(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Material(
              color: overlayBgColor,
              child: SafeArea(
                child: widget.isSystemLockAvailable
                    ? _buildSystemLockLayout(p, isDark)
                    : _buildCustomPinLayout(p, isDark),
              ),
            ),
          ),
        ),
      );
    } else {
      // Solid background fallback for low-end devices or when translucency is disabled
      return Positioned.fill(
        child: Material(
          color: p.bg,
          child: SafeArea(
            child: widget.isSystemLockAvailable
                ? _buildSystemLockLayout(p, isDark)
                : _buildCustomPinLayout(p, isDark),
          ),
        ),
      );
    }
  }

  Widget _buildSystemLockLayout(Palette p, bool isDark) {
    final textCol = isDark ? Colors.white : Colors.black87;
    final textCol2 = isDark ? Colors.white70 : Colors.black54;

    return Column(
      children: [
        const Spacer(flex: 3),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.4 + (_pulseController.value * 0.6),
              child: child,
            );
          },
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Icon(Icons.lock_rounded, color: p.accent, size: 36),
          ),
        ),
        const SizedBox(height: spacing32),
        Text(
          'Private by default',
          style: TextStyle(
            color: textCol,
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: spacing12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacing48),
          child: Text(
            'Your moments stay hidden until you unlock NoteKar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textCol2,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.45,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const Spacer(flex: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacing48),
          child: PressableScale(
            onTap: widget.onUnlock,
            child: Container(
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Unlock NoteKar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildCustomPinLayout(Palette p, bool isDark) {
    final textCol = isDark ? Colors.white : Colors.black87;
    final textCol2 = isDark ? Colors.white60 : Colors.black54;

    return Column(
      children: [
        const SizedBox(height: 36),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.5 + (_pulseController.value * 0.5),
              child: child,
            );
          },
          child: Icon(
            Icons.lock_rounded,
            color: _isCorrect
                ? p.green
                : (_hasError ? p.red : (isDark ? Colors.white : Colors.black87)),
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enter Passcode'.localized(context),
          style: TextStyle(
            color: textCol,
            fontSize: 21,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _getSubtitleText().localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondsRemaining > 0
                  ? p.red
                  : (_isCorrect
                      ? p.green
                      : (_hasError ? p.red : textCol2)),
              fontSize: 13,
              fontWeight: (_secondsRemaining > 0 || _isCorrect || _hasError)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(height: 28),
        if (_secondsRemaining > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: p.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.red.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Try again in $_secondsRemaining seconds'.localized(context),
              style: TextStyle(
                color: p.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ] else ...[
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              double offset = 0.0;
              if (_shakeController.isAnimating) {
                offset = math.sin(_shakeController.value * math.pi * 4) * 16.0;
              }
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final active = index < _enteredPin.length;
                Color dotColor = Colors.transparent;
                Color borderColor = textCol.withValues(alpha: 0.6);

                if (_isCorrect) {
                  dotColor = p.green;
                  borderColor = p.green;
                } else if (_hasError) {
                  dotColor = Colors.transparent;
                  borderColor = p.red;
                } else if (active) {
                  dotColor = textCol;
                  borderColor = textCol;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(
                      color: borderColor,
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
        const Spacer(),
        // Moved the numbers upward
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKeyButton('1', p, isDark),
                  _buildKeyButton('2', p, isDark),
                  _buildKeyButton('3', p, isDark),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKeyButton('4', p, isDark),
                  _buildKeyButton('5', p, isDark),
                  _buildKeyButton('6', p, isDark),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKeyButton('7', p, isDark),
                  _buildKeyButton('8', p, isDark),
                  _buildKeyButton('9', p, isDark),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left: Bio switch shortcut or empty space
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: widget.isSystemLockAvailable
                        ? Material(
                            color: Colors.transparent,
                            child: IconButton(
                              onPressed: widget.onUnlock,
                              icon: Icon(
                                Icons.fingerprint_rounded,
                                color: textCol.withValues(alpha: 0.8),
                                size: 28,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  _buildKeyButton('0', p, isDark),
                  // Delete Button
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _secondsRemaining > 0 ? null : _onDelete,
                        customBorder: const CircleBorder(),
                        child: Center(
                          child: Icon(
                            Icons.backspace_outlined,
                            color: textCol.withValues(alpha: 0.8),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        // Full fledged Cancel Button at the bottom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: PressableScale(
            onTap: () => SystemNavigator.pop(),
            child: Container(
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.red,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Cancel'.localized(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildKeyButton(String digit, Palette p, bool isDark) {
    final enabled = _secondsRemaining <= 0 && !_isCorrect;
    final txtColor = isDark ? Colors.white : Colors.black87;

    final bgCol = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgCol,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? () => _onKeyPress(digit) : null,
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                color: txtColor.withValues(alpha: enabled ? 1.0 : 0.25),
                fontSize: 32,
                fontWeight: FontWeight.w300,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
