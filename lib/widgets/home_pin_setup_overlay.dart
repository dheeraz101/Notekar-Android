import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class PinSetupWidget extends StatefulWidget {
  const PinSetupWidget({super.key, required this.p});

  final Palette p;

  @override
  State<PinSetupWidget> createState() => _PinSetupWidgetState();
}

class _PinSetupWidgetState extends State<PinSetupWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  bool _acceptedWarning = false;
  String _firstPin = '';
  bool _isConfirming = false;
  String _pin = '';

  bool _hasError = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String val) {
    if (_isCorrect) return;
    if (_pin.length >= 4) return;
    HapticFeedback.lightImpact();

    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }

    setState(() {
      _pin += val;
    });
  }

  void _onDelete() {
    if (_isCorrect) return;
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (_hasError) _hasError = false;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _onNext() {
    if (_pin.length != 4) return;
    setState(() {
      _firstPin = _pin;
      _pin = '';
      _isConfirming = true;
    });
  }

  void _onBack() {
    setState(() {
      _pin = _firstPin;
      _firstPin = '';
      _isConfirming = false;
    });
  }

  void _onSave() {
    if (_pin.length != 4) return;
    if (_pin == _firstPin) {
      setState(() {
        _isCorrect = true;
      });
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          Navigator.of(context).pop(_pin);
        }
      });
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      setState(() {
        _hasError = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final isDark = p.bg.computeLuminance() < 0.5;
    final textCol = isDark ? Colors.white : Colors.black87;
    final textCol2 = isDark ? Colors.white60 : Colors.black54;

    if (!_acceptedWarning) {
      return _buildWarningPage(p, isDark, textCol, textCol2);
    }

    final title = _isConfirming ? 'Confirm Passcode' : 'Set Passcode';
    final desc = _isConfirming
        ? 'Confirm your secure 4-digit PIN.'
        : 'Create a secure 4-digit PIN for NoteKar.';

    return Column(
      children: [
        const SizedBox(height: 36),
        Icon(
          Icons.shield_outlined,
          color: _isCorrect
              ? p.green
              : (_hasError ? p.red : (isDark ? Colors.white : Colors.black87)),
          size: 32,
        ),
        const SizedBox(height: 16),
        Text(
          title.localized(context),
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
            desc.localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isCorrect ? p.green : (_hasError ? p.red : textCol2),
              fontSize: 13,
              fontWeight: (_isCorrect || _hasError)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(height: 80),
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            double offset = 0.0;
            if (_shakeController.isAnimating) {
              offset = math.sin(_shakeController.value * math.pi * 4) * 16.0;
            }
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final active = index < _pin.length;
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
                  border: Border.all(color: borderColor, width: 1.5),
                ),
              );
            }),
          ),
        ),
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
                  const SizedBox(width: 76, height: 76),
                  _buildKeyButton('0', p, isDark),
                  // Delete Button
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _onDelete,
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
        // Full width action buttons at the bottom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildBottomButtons(p, isDark, textCol),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildWarningPage(
    Palette p,
    bool isDark,
    Color textCol,
    Color textCol2,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 3),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: p.red.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: p.red.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Icon(Icons.warning_amber_rounded, color: p.red, size: 48),
        ),
        const SizedBox(height: 32),
        Text(
          'Important Notice'.localized(context),
          style: TextStyle(
            color: textCol,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.border),
            ),
            child: Text(
              'WARNING: If you forget this passcode, your data will be permanently locked and you won\'t be able to access it. Kindly use a rememberable PIN and backup your data.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textCol2,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const Spacer(flex: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              PressableScale(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _acceptedWarning = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Accept'.localized(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PressableScale(
                onTap: () => Navigator.of(context).pop(null),
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
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBottomButtons(Palette p, bool isDark, Color textCol) {
    if (!_isConfirming) {
      if (_pin.length < 4) {
        return PressableScale(
          onTap: () => Navigator.of(context).pop(null),
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
        );
      } else {
        return Row(
          children: [
            Expanded(
              child: PressableScale(
                onTap: () => Navigator.of(context).pop(null),
                child: Container(
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
            const SizedBox(width: 16),
            Expanded(
              child: PressableScale(
                onTap: _onNext,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Next'.localized(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    } else {
      if (_pin.length < 4) {
        return PressableScale(
          onTap: _onBack,
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
                width: 1.5,
              ),
            ),
            child: Text(
              'Back'.localized(context),
              style: TextStyle(
                color: textCol,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      } else {
        return Row(
          children: [
            Expanded(
              child: PressableScale(
                onTap: _onBack,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Back'.localized(context),
                    style: TextStyle(
                      color: textCol,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PressableScale(
                onTap: _onSave,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Save'.localized(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  Widget _buildKeyButton(String digit, Palette p, bool isDark) {
    final enabled = !_isCorrect;
    final txtColor = isDark ? Colors.white : Colors.black87;

    final bgCol = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgCol),
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
