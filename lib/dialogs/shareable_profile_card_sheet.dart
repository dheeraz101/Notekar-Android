import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  // Base Pass Body
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF161922), Color(0xFF0C0E14)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Apple Wallet Pass Top Header
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
                                    color: p.accent.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: p.accent.withValues(alpha: 0.45),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.hourglass_bottom_rounded,
                                        color: p.accent,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'MEMENTO MORI PASS',
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
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Avatar & Cardholder Information
                        Row(
                          children: [
                            profile.buildAvatarWidget(p: p, size: 68),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
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
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.verified_rounded,
                                        color: p.accent,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    horizon.hasDob
                                        ? 'Age ${horizon.ageYears} • ${horizon.targetYears}y Life Horizon'
                                        : '${horizon.targetYears}y Life Horizon',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
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
                        const SizedBox(height: 20),

                        // Wallet Field Grid (Life Clock & Waking Weeks)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            fontSize: 24,
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
                                              alpha: 0.65,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'WAKING WEEKS AHEAD',
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
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            fontFeatures: [
                                              FontFeature.tabularFigures(),
                                            ],
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        Text(
                                          '${(horizon.remainingYears).toStringAsFixed(1)} yrs left',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.65,
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
                              // Horizon Bar
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

                        // Perforated Seam Divider
                        Row(
                          children: [
                            for (int i = 0; i < 28; i++) ...[
                              Expanded(
                                child: Container(
                                  height: 1.2,
                                  color: i.isEven
                                      ? Colors.white.withValues(alpha: 0.18)
                                      : Colors.transparent,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Barcode & Cryptographic Sovereign Footer
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Minimalist Apple Wallet style Barcode Glyph
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (int i = 0; i < 18; i++)
                                    Container(
                                      width: (i % 3 == 0) ? 2.5 : 1.2,
                                      height: 22,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 1.0,
                                      ),
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '100% PRIVATE • LOCAL REPOSITORY',
                                    style: TextStyle(
                                      color: p.green,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.7,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '"We waste a lot of life." — Seneca',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 10.5,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TEMPORAL IDENTITY PASS',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              'NoteKar',
                              style: TextStyle(
                                color: p.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sleek Prismatic Holographic Foil Sheen Overlay
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: const Alignment(-1.2, -0.9),
                            end: const Alignment(1.2, 0.9),
                            colors: [
                              Colors.cyan.withValues(alpha: 0.07),
                              Colors.transparent,
                              Colors.purpleAccent.withValues(alpha: 0.09),
                              Colors.transparent,
                              Colors.amberAccent.withValues(alpha: 0.08),
                              Colors.tealAccent.withValues(alpha: 0.06),
                            ],
                            stops: const [0.0, 0.28, 0.50, 0.72, 0.88, 1.0],
                          ),
                        ),
                      ),
                    ),
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
                          Icons.share_rounded,
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
