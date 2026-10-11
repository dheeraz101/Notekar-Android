import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/widgets/photo_lightbox_dialog.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Twitter/X style photo attachment card for the Life Ledger history timeline.
///
/// Provides responsive full-width display with bounded height, smooth rounded corners,
/// multi-photo swipe carousel support (split by '|'), inline collapse/expand chevron,
/// and tap-to-open full-screen lightbox.
class TimelineMediaAttachmentCard extends StatefulWidget {
  const TimelineMediaAttachmentCard({
    super.key,
    required this.p,
    required this.imagePath,
    required this.isCollapsed,
    this.onToggleCollapse,
    this.compact = false,
  });

  final Palette p;
  final String imagePath;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final bool compact;

  @override
  State<TimelineMediaAttachmentCard> createState() =>
      _TimelineMediaAttachmentCardState();
}

class _TimelineMediaAttachmentCardState
    extends State<TimelineMediaAttachmentCard> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  List<String> get _paths {
    return widget.imagePath
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final compact = widget.compact;
    final isCollapsed = widget.isCollapsed;
    final onToggleCollapse = widget.onToggleCollapse;
    final paths = _paths;

    if (paths.isEmpty) return const SizedBox.shrink();

    final isMulti = paths.length > 1;
    final borderRadius = BorderRadius.circular(compact ? 12 : 16);

    if (isCollapsed) {
      // Sleek icon-only collapsed horizontal preview strip
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: PressableScale(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggleCollapse?.call();
            },
            child: Container(
              height: compact ? 28 : 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: p.surface3.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(compact ? 8 : 10),
                border: Border.all(
                  color: p.border.withValues(alpha: 0.5),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMulti
                        ? CupertinoIcons.photo_on_rectangle
                        : CupertinoIcons.photo,
                    size: compact ? 13 : 14,
                    color: p.accent,
                  ),
                  if (isMulti) ...[
                    const SizedBox(width: 5),
                    Text(
                      '${paths.length}',
                      style: TextStyle(
                        color: p.text2,
                        fontSize: compact ? 11 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: compact ? 11 : 12,
                    color: p.text3,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Expanded Twitter/X Style Photo Card with generous height & full width
    final cardHeight = compact ? 180.0 : 230.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: double.infinity,
          height: cardHeight,
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: borderRadius,
            border: Border.all(
              color: p.border.withValues(alpha: 0.6),
              width: 1.0,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!isMulti)
                _buildSingleImageTile(context, paths.first, 0, paths)
              else
                PageView.builder(
                  controller: _pageController,
                  itemCount: paths.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _currentPage = i);
                  },
                  itemBuilder: (ctx, i) {
                    return _buildSingleImageTile(ctx, paths[i], i, paths);
                  },
                ),

              // Multi-Photo Page Indicator Pill
              if (isMulti)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.6,
                      ),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${paths.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

              // Top-Right Glass Collapse Button
              if (onToggleCollapse != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onToggleCollapse();
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.chevron_up,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleImageTile(
    BuildContext context,
    String path,
    int index,
    List<String> allPaths,
  ) {
    final p = widget.p;
    final resolvedFile = MediaStorageService.instance.resolveFileSync(path);

    return GestureDetector(
      onTap: () {
        if (allPaths.length > 1) {
          PhotoLightboxDialog.show(
            context,
            p: p,
            imagePaths: allPaths,
            initialIndex: index,
          );
        } else {
          PhotoLightboxDialog.show(context, p: p, imagePath: path);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Hero(
        tag: 'media_$path',
        child: resolvedFile.existsSync()
            ? Image.file(
                resolvedFile,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(p),
              )
            : FutureBuilder<File>(
                future: MediaStorageService.instance.resolveFile(path),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.existsSync()) {
                    return Image.file(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildFallback(p),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        radius: 10,
                        color: p.accent,
                      ),
                    );
                  }
                  return _buildFallback(p);
                },
              ),
      ),
    );
  }

  Widget _buildFallback(Palette p) {
    return Container(
      color: p.surface3,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.photo, size: 28, color: p.text3),
            const SizedBox(height: 6),
            Text(
              'Attached Photo',
              style: TextStyle(color: p.text3, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
