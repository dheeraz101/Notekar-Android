import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/widgets/glass.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Apple HIG full-screen Photo Lightbox with interactive pan/zoom
/// and dark translucent backdrop.
class PhotoLightboxDialog extends StatefulWidget {
  const PhotoLightboxDialog({
    super.key,
    required this.p,
    this.imagePath,
    this.imageBytes,
    this.assetPath,
    this.title = 'Photo',
  });

  final Palette p;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String? assetPath;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    String? imagePath,
    Uint8List? imageBytes,
    String? assetPath,
    String title = 'Photo',
  }) {
    HapticFeedback.lightImpact();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss photo',
      barrierColor: Colors.black.withValues(alpha: 0.88),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => PhotoLightboxDialog(
        p: p,
        imagePath: imagePath,
        imageBytes: imageBytes,
        assetPath: assetPath,
        title: title,
      ),
    );
  }

  @override
  State<PhotoLightboxDialog> createState() => _PhotoLightboxDialogState();
}

class _PhotoLightboxDialogState extends State<PhotoLightboxDialog> {
  File? _resolvedFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  Future<void> _resolveImage() async {
    if (widget.imageBytes != null || widget.assetPath != null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      final file = await MediaStorageService.instance.resolveFile(
        widget.imagePath!,
      );
      if (mounted) {
        setState(() {
          _resolvedFile = file;
          _isLoading = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    Widget imageWidget;
    if (widget.imageBytes != null) {
      imageWidget = Image.memory(
        widget.imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildError(p),
      );
    } else if (widget.assetPath != null) {
      imageWidget = Image.asset(
        widget.assetPath!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildError(p),
      );
    } else if (_resolvedFile != null && _resolvedFile!.existsSync()) {
      imageWidget = Image.file(
        _resolvedFile!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildError(p),
      );
    } else {
      imageWidget = _buildError(p);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered Zoomable Photo
            Center(
              child: _isLoading
                  ? CupertinoActivityIndicator(radius: 14, color: p.accent)
                  : InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.5,
                      clipBehavior: Clip.none,
                      child: imageWidget,
                    ),
            ),

            // Top Bar
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title pill
                  Glass(
                    p: p,
                    radius: 20,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.photo, size: 14, color: p.text2),
                        const SizedBox(width: 6),
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
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

  Widget _buildError(Palette p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 36,
            color: p.orange,
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to load photo',
            style: TextStyle(color: p.text, fontWeight: FontWeight.w700),
          ),
          if (widget.imagePath != null && widget.imagePath!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.imagePath!,
              style: TextStyle(color: p.text3, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
