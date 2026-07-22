import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';

class ResetAllConfirmSheet extends StatefulWidget {
  const ResetAllConfirmSheet({
    super.key,
    required this.p,
    required this.title,
    required this.message,
  });

  final Palette p;
  final String title;
  final String message;

  @override
  State<ResetAllConfirmSheet> createState() => _ResetAllConfirmSheetState();
}

class _ResetAllConfirmSheetState extends State<ResetAllConfirmSheet> {
  final _controller = TextEditingController();
  bool _canReset = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return AppSheet(
      p: p,
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.red.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.warning_amber_rounded, color: p.red, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: spacing16),
          TextField(
            controller: _controller,
            onChanged: (value) => setState(() {
              _canReset = value.trim().toUpperCase() == 'RESET';
            }),
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(color: p.text),
            decoration: InputDecoration(
              hintText: 'RESET',
              hintStyle: TextStyle(color: p.text3),
              filled: true,
              fillColor: p.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.accent),
              ),
            ),
          ),
          const SizedBox(height: spacing20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.text,
                      side: BorderSide(color: p.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _canReset ? p.red : p.surface3,
                      foregroundColor: _canReset ? Colors.white : p.text3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: _canReset
                        ? () => Navigator.pop(context, true)
                        : null,
                    child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FactoryResetOverlay extends StatefulWidget {
  const FactoryResetOverlay({
    super.key,
    required this.p,
    required this.progress,
    required this.complete,
    required this.status,
    required this.subStatus,
    required this.icon,
    required this.onStart,
  });

  final Palette p;
  final double progress;
  final bool complete;
  final String status;
  final String subStatus;
  final IconData icon;
  final VoidCallback onStart;

  @override
  State<FactoryResetOverlay> createState() => _FactoryResetOverlayState();
}

class _FactoryResetOverlayState extends State<FactoryResetOverlay> {
  bool _triggered = false;

  @override
  void didUpdateWidget(FactoryResetOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.complete && !_triggered) {
      _triggered = true;
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          widget.onStart();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF0A0A0C), // Pure ultra-dark grey screen for premium look
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Rotating/Loading Step Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  widget.icon,
                  key: ValueKey<IconData>(widget.icon),
                  color: widget.complete ? widget.p.green : Colors.white,
                  size: 64,
                ),
              ),
              const Spacer(flex: 2),
              // Thin iOS progress bar
              SizedBox(
                width: 250,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: widget.progress.clamp(0, 1),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.complete ? widget.p.green : widget.p.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Main System status text
                    Text(
                      widget.status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Detailed sub-status text
                    Text(
                      widget.subStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // Security Trust Note
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'NoteKar respects your privacy. All data removal operations occur locally on your device and cannot be undone.'.localized(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class AppIconApplyingDialog extends StatelessWidget {
  const AppIconApplyingDialog({super.key, required this.p});

  final Palette p;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 250,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      color: p.accent,
                      backgroundColor: p.surface3,
                    ),
                    Icon(Icons.apps_rounded, color: p.accent, size: 23),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Applying app icon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Please wait while Android refreshes NoteKar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.text2, fontSize: 13, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionConfirmSheet extends StatelessWidget {
  const ActionConfirmSheet({
    super.key,
    required this.p,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.isDestructive = false,
    this.icon,
  });

  final Palette p;
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDestructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? p.red : p.accent;
    return AppSheet(
      p: p,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon ?? Icons.info_outline_rounded, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: spacing24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.text,
                      side: BorderSide(color: p.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
