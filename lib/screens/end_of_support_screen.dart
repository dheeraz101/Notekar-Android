import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Full-screen Apple HIG End of Support (EOS) Card.
/// Presented when NoteKar has not received an update for 365+ days,
/// thanking the user and reassuring offline sovereignty.
class EndOfSupportScreen extends StatelessWidget {
  const EndOfSupportScreen({super.key, required this.p, this.onDismiss});

  final Palette p;
  final VoidCallback? onDismiss;

  static Route<void> route({required Palette p, VoidCallback? onDismiss}) {
    return CupertinoPageRoute<void>(
      builder: (_) => EndOfSupportScreen(p: p, onDismiss: onDismiss),
    );
  }

  static Future<void> open(
    BuildContext context, {
    required Palette p,
    VoidCallback? onDismiss,
  }) {
    HapticFeedback.mediumImpact();
    return Navigator.of(context).push<void>(route(p: p, onDismiss: onDismiss));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wb_twilight_rounded,
                          size: 13,
                          color: Color(0xFFFF9500),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'END OF SUPPORT'.localized(context),
                          style: const TextStyle(
                            color: Color(0xFFFF9500),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PressableScale(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onDismiss?.call();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: p.surface2,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 14,
                        color: p.text2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Sunset / Heart Shield Icon
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF9500).withValues(alpha: 0.22),
                            const Color(0xFFFF2D55).withValues(alpha: 0.12),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF9500).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF9500,
                            ).withValues(alpha: 0.25),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 42,
                        color: Color(0xFFFF9500),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Headline
                    Text(
                      'Thank You for Trying NoteKar'.localized(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      'NoteKar has reached its End of Support milestone. No new updates or releases are scheduled for this version. Your offline workspace remains yours forever.'
                          .localized(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 14,
                        height: 1.45,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Highlight Cards
                    _buildFeatureCard(
                      context,
                      icon: CupertinoIcons.lock_shield_fill,
                      iconColor: const Color(0xFF34C759),
                      title: '100% Offline & Sovereign'.localized(context),
                      description:
                          'All your notes, timers, voice memos, and images remain permanently on your device. NoteKar requires zero servers and will never lock you out.'
                              .localized(context),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context,
                      icon: CupertinoIcons.archivebox_fill,
                      iconColor: const Color(0xFF0A84FF),
                      title: 'Data Export & Safety'.localized(context),
                      description:
                          'You can export your complete timeline data anytime via Settings > Backup & Export to JSON or CSV without restrictions.'
                              .localized(context),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context,
                      icon: CupertinoIcons.sparkles,
                      iconColor: const Color(0xFFAF52DE),
                      title: 'Open Source Community'.localized(context),
                      description:
                          'NoteKar is open-source. Anyone in the community can inspect, fork, or build their own releases from the public GitHub repository.'
                              .localized(context),
                    ),
                    const SizedBox(height: 24),

                    // External Links Group
                    Container(
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildLinkTile(
                            context,
                            icon:
                                CupertinoIcons.chevron_left_slash_chevron_right,
                            iconColor: p.accent,
                            title: 'GitHub Repository'.localized(context),
                            subtitle: 'Explore source code and releases'
                                .localized(context),
                            onTap: () => openExternalLinkSafely(
                              context,
                              p: p,
                              url: githubRepo,
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.6,
                            color: p.border.withValues(alpha: 0.5),
                          ),
                          _buildLinkTile(
                            context,
                            icon: CupertinoIcons.heart_fill,
                            iconColor: const Color(0xFFFF2D55),
                            title: 'Support the Developer'.localized(context),
                            subtitle:
                                'Show appreciation or sponsor future tools'
                                    .localized(context),
                            onTap: () => openExternalLinkSafely(
                              context,
                              p: p,
                              url: 'https://github.com/dheeraz101',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned Bottom Dock
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: p.surface.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: p.border.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
              ),
              child: PressableScale(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onDismiss?.call();
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 52,
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
                  alignment: Alignment.center,
                  child: Text(
                    'Continue to NoteKar'.localized(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: p.text2, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: p.text3, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_forward, color: p.text3, size: 16),
          ],
        ),
      ),
    );
  }
}
