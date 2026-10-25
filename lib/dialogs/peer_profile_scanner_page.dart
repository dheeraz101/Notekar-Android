import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/peer_profile.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Full-screen Apple HIG QR Code Scanner for scanning NoteKar Horizon Passes.
class PeerProfileScannerPage extends StatefulWidget {
  const PeerProfileScannerPage({super.key, required this.p});

  final Palette p;

  static Future<PeerProfile?> show(BuildContext context, {required Palette p}) {
    return Navigator.of(context).push<PeerProfile>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => PeerProfileScannerPage(p: p),
      ),
    );
  }

  @override
  State<PeerProfileScannerPage> createState() => _PeerProfileScannerPageState();
}

enum _ScanFeedback { none, success, failed }

class _PeerProfileScannerPageState extends State<PeerProfileScannerPage>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _laserController;
  bool _hasScanned = false;
  bool _torchEnabled = false;
  _ScanFeedback _feedback = _ScanFeedback.none;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned || _feedback != _ScanFeedback.none) return;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        final profile = PeerProfile.fromQrPayload(rawValue);
        if (profile != null) {
          _hasScanned = true;
          HapticFeedback.heavyImpact();
          setState(() => _feedback = _ScanFeedback.success);
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted) {
              Navigator.of(context).pop(profile);
            }
          });
          return;
        }
      }
    }

    // If barcodes detected but none valid NoteKar QR
    if (capture.barcodes.isNotEmpty &&
        !_hasScanned &&
        _feedback == _ScanFeedback.none) {
      HapticFeedback.mediumImpact();
      setState(() => _feedback = _ScanFeedback.failed);
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) {
          setState(() => _feedback = _ScanFeedback.none);
        }
      });
    }
  }

  void _showInvalidCodeDialog() {
    if (_hasScanned) return;
    _hasScanned = true;
    HapticFeedback.mediumImpact();
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Unrecognized Pass'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'The scanned code is not a valid NoteKar Temporal Horizon Pass. Please ensure the QR code was generated from NoteKar.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _hasScanned = false);
            },
            child: const Text('Try Again'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final capture = await _scannerController.analyzeImage(file.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        for (final barcode in capture.barcodes) {
          final rawValue = barcode.rawValue;
          if (rawValue != null) {
            final profile = PeerProfile.fromQrPayload(rawValue);
            if (profile != null) {
              if (mounted) {
                HapticFeedback.heavyImpact();
                setState(() => _feedback = _ScanFeedback.success);
                await Future.delayed(const Duration(milliseconds: 650));
                if (mounted) {
                  Navigator.of(context).pop(profile);
                  return;
                }
              }
            }
          }
        }
      }
      if (mounted) {
        HapticFeedback.mediumImpact();
        setState(() => _feedback = _ScanFeedback.failed);
        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) setState(() => _feedback = _ScanFeedback.none);
      }
    } catch (_) {
      if (mounted) {
        HapticFeedback.mediumImpact();
        setState(() => _feedback = _ScanFeedback.failed);
        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) setState(() => _feedback = _ScanFeedback.none);
      }
    }
  }

  Future<void> _enterCodeManually() async {
    final textController = TextEditingController();
    final profile = await showCupertinoDialog<PeerProfile>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Enter Horizon Pass Code'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: textController,
            placeholder: 'Paste notekar://peer or pass data',
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final parsed = PeerProfile.fromQrPayload(textController.text);
              Navigator.of(ctx).pop(parsed);
            },
            child: const Text('Inspect'),
          ),
        ],
      ),
    );

    if (profile != null && mounted) {
      HapticFeedback.heavyImpact();
      Navigator.of(context).pop(profile);
    } else if (textController.text.trim().isNotEmpty && mounted) {
      _showInvalidCodeDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Viewfinder
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.camera_fill,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Camera Unavailable',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can import a pass screenshot from your photo library or enter the pass data directly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Apple Vignette Mask Overlay with Animated Moving Laser Line
          AnimatedBuilder(
            animation: _laserController,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final reticleSize = math.min(
                    constraints.maxWidth * 0.72,
                    280.0,
                  );
                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _ReticleOverlayPainter(
                      reticleSize: reticleSize,
                      accentColor: const Color(
                        0xFF34C759,
                      ), // Vibrant laser green
                      laserProgress: _laserController.value,
                    ),
                  );
                },
              );
            },
          ),

          // 2b. Visual Scan Feedback Indicator (Checkmark on success / Red X on failed)
          if (_feedback != _ScanFeedback.none)
            Center(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.65, end: 1.0),
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: _feedback == _ScanFeedback.success
                          ? const Color(0xFF152A1C).withValues(alpha: 0.94)
                          : const Color(0xFF2E1515).withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: _feedback == _ScanFeedback.success
                            ? const Color(0xFF34C759).withValues(alpha: 0.8)
                            : const Color(0xFFFF3B30).withValues(alpha: 0.8),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_feedback == _ScanFeedback.success
                                      ? const Color(0xFF34C759)
                                      : const Color(0xFFFF3B30))
                                  .withValues(alpha: 0.45),
                          blurRadius: 36,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _feedback == _ScanFeedback.success
                                ? const Color(0xFF34C759)
                                : const Color(0xFFFF3B30),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_feedback == _ScanFeedback.success
                                            ? const Color(0xFF34C759)
                                            : const Color(0xFFFF3B30))
                                        .withValues(alpha: 0.6),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _feedback == _ScanFeedback.success
                                ? CupertinoIcons.checkmark_alt
                                : CupertinoIcons.xmark,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _feedback == _ScanFeedback.success
                              ? 'Pass Verified'
                              : 'Scan Failed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (_feedback == _ScanFeedback.failed) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Unrecognized QR Code',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 3. Top Navigation & Torch Controls
          Positioned(
            top: topPadding + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dismiss Button
                PressableScale(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                // Title Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.qrcode_viewfinder,
                        color: p.accent,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Scan Horizon Pass',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Torch Toggle
                PressableScale(
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await _scannerController.toggleTorch();
                    setState(() => _torchEnabled = !_torchEnabled);
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _torchEnabled
                          ? p.accent
                          : Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      _torchEnabled
                          ? Icons.flashlight_on_rounded
                          : Icons.flashlight_off_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Alternate Input Actions
          Positioned(
            bottom: bottomPadding + 28,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Align NoteKar Horizon QR code within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Import from Photos
                    PressableScale(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.photo_fill_on_rectangle_fill,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Photo Library',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Manual Paste
                    PressableScale(
                      onTap: _enterCodeManually,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.keyboard,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Paste Code',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReticleOverlayPainter extends CustomPainter {
  const _ReticleOverlayPainter({
    required this.reticleSize,
    required this.accentColor,
    required this.laserProgress,
  });

  final double reticleSize;
  final Color accentColor;
  final double laserProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 24;

    final reticleRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: reticleSize,
      height: reticleSize,
    );

    // Darkened vignette background cutout
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(reticleRect, const Radius.circular(24)),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      bgPath,
      Paint()..color = Colors.black.withValues(alpha: 0.65),
    );

    // Glowing reticle frame
    final framePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(reticleRect, const Radius.circular(24)),
      framePaint,
    );

    // Corner brackets
    final cornerLength = 28.0;
    final cornerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final r = reticleRect;
    // Top-Left
    canvas.drawLine(
      Offset(r.left, r.top + cornerLength),
      Offset(r.left, r.top + 8),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(r.left + 8, r.top),
      Offset(r.left + cornerLength, r.top),
      cornerPaint,
    );

    // Top-Right
    canvas.drawLine(
      Offset(r.right, r.top + cornerLength),
      Offset(r.right, r.top + 8),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(r.right - 8, r.top),
      Offset(r.right - cornerLength, r.top),
      cornerPaint,
    );

    // Bottom-Left
    canvas.drawLine(
      Offset(r.left, r.bottom - cornerLength),
      Offset(r.left, r.bottom - 8),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(r.left + 8, r.bottom),
      Offset(r.left + cornerLength, r.bottom),
      cornerPaint,
    );

    // Bottom-Right
    canvas.drawLine(
      Offset(r.right, r.bottom - cornerLength),
      Offset(r.right, r.bottom - 8),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(r.right - 8, r.bottom),
      Offset(r.right - cornerLength, r.bottom),
      cornerPaint,
    );

    // Animated scanning laser sweep
    final laserY = r.top + 12 + (laserProgress * (reticleSize - 24));
    final laserPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accentColor.withValues(alpha: 0.0),
          accentColor,
          accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(r.left, laserY - 1, reticleSize, 2))
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(r.left + 8, laserY),
      Offset(r.right - 8, laserY),
      laserPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ReticleOverlayPainter oldDelegate) {
    return oldDelegate.laserProgress != laserProgress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.reticleSize != reticleSize;
  }
}
