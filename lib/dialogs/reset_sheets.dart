import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

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

class FactoryResetOverlay extends StatelessWidget {
  const FactoryResetOverlay({
    super.key,
    required this.p,
    required this.progress,
    required this.complete,
    required this.status,
    required this.onStart,
  });

  final Palette p;
  final double progress;
  final bool complete;
  final String status;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: p.bg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacing32, vertical: spacing32),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: complete
                        ? p.green.withValues(alpha: 0.14)
                        : p.accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    complete ? Icons.check_rounded : Icons.restart_alt_rounded,
                    color: complete ? p.green : p.accent,
                    size: 34,
                  ),
                ),
                const SizedBox(height: spacing24),
                Text(
                  complete ? 'Ready to Start' : 'Resetting NoteKar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: spacing8),
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.text2, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: spacing24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: progress.clamp(0, 1),
                    backgroundColor: p.surface3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      complete ? p.green : p.accent,
                    ),
                  ),
                ),
                const SizedBox(height: spacing8),
                Text(
                  '${(progress.clamp(0, 1) * 100).round()}%',
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  opacity: complete ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: complete ? onStart : null,
                    child: const Text('Start'),
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
