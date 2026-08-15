import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';

class ShareableMilestoneSheet extends StatefulWidget {
  const ShareableMilestoneSheet({
    super.key,
    required this.p,
    required this.milestoneTitle,
    required this.dayLabel,
    required this.streakDays,
  });

  final Palette p;
  final String milestoneTitle;
  final String dayLabel;
  final int streakDays;

  @override
  State<ShareableMilestoneSheet> createState() =>
      _ShareableMilestoneSheetState();
}

class _ShareableMilestoneSheetState extends State<ShareableMilestoneSheet> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _exportCard() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      HapticFeedback.heavyImpact();
      final shareContent =
          '🎉 ${widget.milestoneTitle}\n'
          'Target: ${widget.dayLabel} • ${widget.streakDays} Days Strong\n\n'
          'Logged with NoteKar — 100% Private, Zero Backend.';

      // Allow frame to render before capturing boundary
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData?.buffer.asUint8List();

        if (pngBytes != null) {
          try {
            await const MethodChannel(
              'notekar/files',
            ).invokeMethod<void>('shareImageBytes', {
              'title': 'Share Milestone Peak',
              'fileName': 'milestone-peak-${widget.streakDays}-days.png',
              'bytes': pngBytes,
              'text': shareContent,
            });
          } catch (_) {
            await const MethodChannel('notekar/files').invokeMethod<void>(
              'shareText',
              {'title': 'Share Milestone Peak', 'text': shareContent},
            );
          }
        } else {
          await const MethodChannel('notekar/files').invokeMethod<void>(
            'shareText',
            {'title': 'Share Milestone Peak', 'text': shareContent},
          );
        }
      } else {
        await const MethodChannel('notekar/files').invokeMethod<void>(
          'shareText',
          {'title': 'Share Milestone Peak', 'text': shareContent},
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return AppSheet(
      p: p,
      title: 'Share Milestone Peak'.localized(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [p.orange, p.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: p.orange.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.terrain_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MILESTONE ACHIEVED'.localized(context),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.milestoneTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target: ${widget.dayLabel} • ${widget.streakDays} Days Strong',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.lock_shield_fill,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'NoteKar • 100% Privacy Preserved',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _isExporting ? null : _exportCard,
              child: _isExporting
                  ? const Center(
                      child: CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 10,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.share, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Export Milestone Card'.localized(context),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
