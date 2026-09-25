import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Reusable Apple-aesthetic shareable profile identity card with NoteKar branding.
class ShareableProfileCardSheet extends StatefulWidget {
  const ShareableProfileCardSheet({super.key, required this.p});

  final Palette p;

  static Future<void> show(BuildContext context, {required Palette p}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareableProfileCardSheet(p: p),
    );
  }

  @override
  State<ShareableProfileCardSheet> createState() =>
      _ShareableProfileCardSheetState();
}

class _ShareableProfileCardSheetState extends State<ShareableProfileCardSheet> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _exportCard() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      HapticFeedback.heavyImpact();
      final profile = UserProfileService();
      final hasName = profile.name.trim().isNotEmpty;
      final userName = hasName ? profile.name.trim() : 'Explorer';
      final horizon = profile.calculateLifeHorizon();

      final shareContent =
          '🧭 $userName\'s Life Horizon on NoteKar\n'
          'Age: ${horizon.hasDob ? '${horizon.ageYears}y' : 'Undisclosed'} • Target: ${horizon.targetYears}y Horizon\n'
          '${horizon.hasDob ? 'Life Clock: ${horizon.lifeClockFormatted} (${horizon.lifeClockTimeOfDay}) • ${horizon.remainingWeeks} weeks ahead\n' : ''}'
          'Logged with NoteKar — Deliberate Time & Life Horizon • 100% Private, Zero Cloud.';

      await Future<void>.delayed(const Duration(milliseconds: 120));

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
              'title': 'Share NoteKar Profile',
              'fileName': 'notekar-identity-$userName.png',
              'bytes': pngBytes,
              'text': shareContent,
            });
          } catch (_) {
            await const MethodChannel('notekar/files').invokeMethod<void>(
              'shareText',
              {'title': 'Share NoteKar Profile', 'text': shareContent},
            );
          }
        } else {
          await const MethodChannel('notekar/files').invokeMethod<void>(
            'shareText',
            {'title': 'Share NoteKar Profile', 'text': shareContent},
          );
        }
      } else {
        await const MethodChannel('notekar/files').invokeMethod<void>(
          'shareText',
          {'title': 'Share NoteKar Profile', 'text': shareContent},
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
    final profile = UserProfileService();
    final horizon = profile.calculateLifeHorizon();
    final displayName = profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'NoteKar Explorer';

    return AppSheet(
      p: p,
      title: 'Share Identity Card'.localized(context),
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
                  colors: [const Color(0xFF14171F), const Color(0xFF0A0C10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: p.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: p.accent.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.hourglass,
                                  color: p.accent,
                                  size: 12,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'MEMENTO MORI',
                                  style: TextStyle(
                                    color: p.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'NoteKar ID',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Avatar & Name Card
                  Row(
                    children: [
                      profile.buildAvatarWidget(p: p, size: 68),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              horizon.hasDob
                                  ? 'Age ${horizon.ageYears} • ${horizon.targetYears}y Life Horizon'
                                  : '${horizon.targetYears}y Life Horizon',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Hero Numbers Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '24-HOUR LIFE CLOCK',
                                    style: TextStyle(
                                      color: p.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    horizon.lifeClockFormatted,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Text(
                                    horizon.lifeClockTimeOfDay,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 52,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CONSCIOUS WEEKS AHEAD',
                                    style: TextStyle(
                                      color: p.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${horizon.remainingWeeks}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Text(
                                    '${(horizon.remainingYears).toStringAsFixed(1)} years to make history',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Sleek Horizon Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 6,
                            color: Colors.white.withValues(alpha: 0.1),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  children: [
                                    Container(
                                      width:
                                          constraints.maxWidth *
                                          horizon.livedPercentage,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [p.accent, p.orange],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Seneca Quote
                  Text(
                    '"It is not that we have a short time to live, but that we waste a lot of it." — Seneca',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom Branding Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.shield_fill,
                            size: 13,
                            color: p.green,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '100% Private • Local-Only',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'NoteKar',
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Share Button
          PressableScale(
            onTap: _exportCard,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: p.accent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isExporting
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.share,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Share Identity Card'.localized(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
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
