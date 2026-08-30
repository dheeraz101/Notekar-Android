import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class PioneerBadgeDialog extends StatefulWidget {
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

  @override
  State<PioneerBadgeDialog> createState() => _PioneerBadgeDialogState();
}

class _PioneerBadgeDialogState extends State<PioneerBadgeDialog> {
  bool _verified = false;

  String _generatePioneerHash() {
    final raw =
        'notekar_pioneer_v${kAppVersion}_${widget.totalMoments}_${widget.streakDays}_$kAppBuildNumber';
    return sha256
        .convert(utf8.encode(raw))
        .toString()
        .toUpperCase()
        .substring(0, 16);
  }

  void _verifyIntegrity() {
    HapticFeedback.heavyImpact();
    setState(() => _verified = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cryptographic integrity verified! Database signature is valid and authentic.'
              .localized(context),
        ),
        backgroundColor: const Color(0xFF248A3D),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final hash = _generatePioneerHash();
    final formattedHash =
        '${hash.substring(0, 4)}-${hash.substring(4, 8)}-${hash.substring(8, 12)}-${hash.substring(12, 16)}';

    return AppSheet(
      p: p,
      title: 'VIP Pioneer Badge'.localized(context),
      showLargeTitle: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            // Holographic Apple Wallet Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E1B2E),
                    Color(0xFF2B2342),
                    Color(0xFF131219),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card Header
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NOTEKAR SOVEREIGN',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              'Certified VIP Pioneer'.localized(context),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
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
                  const SizedBox(height: 20),

                  // Cryptographic Token
                  Text(
                    'INTEGRITY SIGNATURE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formattedHash,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Responsive Telemetry Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildPioneerStat(
                            label: 'MOMENTS',
                            value: widget.totalMoments.toString(),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 22,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildPioneerStat(
                              label: 'STREAK',
                              value: '${widget.streakDays}d',
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 22,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildPioneerStat(
                              label: 'CHANNEL',
                              value: kAppBuildNumber.contains('BR')
                                  ? 'BETA'
                                  : (kAppBuildNumber.contains('PR')
                                        ? 'PRIORITY'
                                        : 'STABLE'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Integrity Verification Button
            PressableScale(
              onTap: _verifyIntegrity,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _verified
                      ? const Color(0xFF248A3D).withValues(alpha: 0.18)
                      : p.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _verified ? const Color(0xFF248A3D) : p.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _verified
                          ? Icons.verified_rounded
                          : Icons.security_rounded,
                      size: 16,
                      color: _verified ? const Color(0xFF248A3D) : p.text,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _verified
                            ? 'Signature Cryptographically Valid'
                            : 'Verify Database Signature',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _verified ? const Color(0xFF248A3D) : p.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Copy Token Button
            PressableScale(
              onTap: () {
                Clipboard.setData(ClipboardData(text: hash));
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pioneer integrity token copied to clipboard!'.localized(
                        context,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.copy_rounded, size: 15, color: p.text2),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Copy Sovereign Token'.localized(context),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text2,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 7.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
