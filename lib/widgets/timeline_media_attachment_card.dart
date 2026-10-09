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
/// inline collapse/expand chevron, and tap-to-open full-screen lightbox.
class TimelineMediaAttachmentCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final resolvedFile = MediaStorageService.instance.resolveFileSync(
      imagePath,
    );
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
                    CupertinoIcons.photo,
                    size: compact ? 13 : 14,
                    color: p.accent,
                  ),
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
              // Photo Image with Lightbox Tap Trigger
              GestureDetector(
                onTap: () {
                  PhotoLightboxDialog.show(context, p: p, imagePath: imagePath);
                },
                behavior: HitTestBehavior.opaque,
                child: Hero(
                  tag: 'media_$imagePath',
                  child: resolvedFile.existsSync()
                      ? Image.file(
                          resolvedFile,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildFallback(p),
                        )
                      : FutureBuilder<File>(
                          future: MediaStorageService.instance.resolveFile(
                            imagePath,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data!.existsSync()) {
                              return Image.file(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _buildFallback(p),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
              ),

              // Top-Right Glass Collapse Button
              if (onToggleCollapse != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onToggleCollapse!();
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
