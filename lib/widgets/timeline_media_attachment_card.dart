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
      // Sleek 34dp collapsed horizontal preview strip
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
        child: PressableScale(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggleCollapse?.call();
          },
          child: Container(
            height: compact ? 30 : 34,
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
              children: [
                Icon(
                  CupertinoIcons.photo,
                  size: compact ? 13 : 14,
                  color: p.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Photo attached',
                  style: TextStyle(
                    color: p.text,
                    fontSize: compact ? 11.5 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '•',
                  style: TextStyle(color: p.text3, fontSize: compact ? 10 : 11),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tap to expand',
                    style: TextStyle(
                      color: p.text2,
                      fontSize: compact ? 11 : 11.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: compact ? 12 : 13,
                  color: p.text3,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Expanded Twitter/X Style Photo Card
    final cardHeight = compact ? 130.0 : 190.0;

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.chevron_up,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Collapse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
