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
    this.imagePaths,
    this.initialIndex = 0,
    this.imageBytes,
    this.assetPath,
    this.title = 'Photo',
  });

  final Palette p;
  final String? imagePath;
  final List<String>? imagePaths;
  final int initialIndex;
  final Uint8List? imageBytes;
  final String? assetPath;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    String? imagePath,
    List<String>? imagePaths,
    int initialIndex = 0,
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
        imagePaths: imagePaths,
        initialIndex: initialIndex,
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
  late final PageController _pageController;
  late int _currentIndex;
  final Map<int, File> _resolvedFiles = {};
  bool _isLoading = true;

  List<String> get _effectivePaths {
    if (widget.imagePaths != null && widget.imagePaths!.isNotEmpty) {
      return widget.imagePaths!;
    }
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      return [widget.imagePath!];
    }
    return const [];
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _resolveImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _resolveImages() async {
    if (widget.imageBytes != null || widget.assetPath != null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final paths = _effectivePaths;
    for (int i = 0; i < paths.length; i++) {
      try {
        final file = await MediaStorageService.instance.resolveFile(paths[i]);
        if (mounted) {
          _resolvedFiles[i] = file;
        }
      } catch (e) {
        debugPrint('Error resolving image $i: $e');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSingleImage(int index, Palette p) {
    if (widget.imageBytes != null) {
      return Image.memory(
        widget.imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildError(p, null),
      );
    }
    if (widget.assetPath != null) {
      return Image.asset(
        widget.assetPath!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildError(p, null),
      );
    }
    final file = _resolvedFiles[index];
    final path = index < _effectivePaths.length ? _effectivePaths[index] : null;
    if (file != null && file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildError(p, path),
      );
    }
    return _buildError(p, path);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final paths = _effectivePaths;
    final isMulti = paths.length > 1;

    final displayTitle = isMulti
        ? '${_currentIndex + 1} of ${paths.length}'
        : widget.title;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered Zoomable Photo(s)
            Center(
              child: _isLoading
                  ? CupertinoActivityIndicator(radius: 14, color: p.accent)
                  : isMulti
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: paths.length,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _currentIndex = i);
                      },
                      itemBuilder: (ctx, i) {
                        return InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 4.5,
                          clipBehavior: Clip.none,
                          child: Center(child: _buildSingleImage(i, p)),
                        );
                      },
                    )
                  : InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.5,
                      clipBehavior: Clip.none,
                      child: Center(child: _buildSingleImage(0, p)),
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
                        Icon(
                          isMulti
                              ? CupertinoIcons.photo_on_rectangle
                              : CupertinoIcons.photo,
                          size: 14,
                          color: p.text2,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          displayTitle,
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

            // Multi-Photo Bottom Dot Indicator
            if (isMulti)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(paths.length, (i) {
                        final active = i == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 16 : 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Palette p, String? path) {
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
