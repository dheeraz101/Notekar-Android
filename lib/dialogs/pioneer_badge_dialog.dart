import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class PioneerBadgeDialog extends StatelessWidget {
  const PioneerBadgeDialog({
    super.key,
    required this.p,
    required this.totalMoments,
    required this.streakDays,
  });

  final Palette p;
  final int totalMoments;
  final int streakDays;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required int totalMoments,
    required int streakDays,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => PioneerBadgeDialog(
        p: p,
        totalMoments: totalMoments,
        streakDays: streakDays,
      ),
    );
  }

  String _generatePioneerHash() {
    final raw = 'notekar_sovereign_pioneer_${kAppVersion}_$kAppBuildNumber';
    return sha256
        .convert(utf8.encode(raw))
        .toString()
        .toUpperCase()
        .substring(0, 24);
  }

  @override
  Widget build(BuildContext context) {
    final hash = _generatePioneerHash();
    final formattedHash =
        '${hash.substring(0, 4)}-${hash.substring(4, 8)}-${hash.substring(8, 12)}-${hash.substring(12, 16)}';

    return AppSheet(
      p: p,
      title: 'VIP Pioneer Credentials'.localized(context),
      showLargeTitle: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // Holographic Apple Wallet Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1F1C2C),
                    Color(0xFF2C2541),
                    Color(0xFF14131A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NOTEKAR SOVEREIGN',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Certified VIP Pioneer'.localized(context),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(
                              0xFFFFD700,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'v$kAppVersion',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Cryptographic Hash Display
                  Text(
                    'CRYPTOGRAPHIC TOKEN',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedHash,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Telemetry Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPioneerStat(
                        label: 'LIFETIME MOMENTS',
                        value: totalMoments.toString(),
                      ),
                      _buildPioneerStat(
                        label: 'CLEAN STREAK',
                        value: '$streakDays Days',
                      ),
                      _buildPioneerStat(
                        label: 'BUILD CHANNEL',
                        value: kAppBuildNumber.contains('BR')
                            ? 'BETA'
                            : (kAppBuildNumber.contains('PR')
                                  ? 'PRIORITY'
                                  : 'STABLE'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Copy Token Action Button
            PressableScale(
              onTap: () {
                Clipboard.setData(ClipboardData(text: hash));
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cryptographic Pioneer Token copied to clipboard!'
                          .localized(context),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.copy_rounded, size: 16, color: p.text),
                    const SizedBox(width: 8),
                    Text(
                      'Copy Sovereign Token'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPioneerStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
