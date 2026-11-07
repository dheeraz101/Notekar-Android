import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangelogDialog extends StatefulWidget {
  const ChangelogDialog({
    super.key,
    required this.p,
    this.latestOnly = false,
    this.blur = false,
    this.largeText = false,
  });

  final Palette p;
  final bool latestOnly;
  final bool blur;
  final bool largeText;

  static const String webChangelogUrl =
      'https://notekarapp.vercel.app/changelog.html';

  static const latestRelease = (
    version: '7.5.13',
    date: 'November 07, 2026',
    edition:
        'Classic iOS Switches, Hierarchical Navigation & Apple HIG Architecture',
    badgeColor: Color(0xFFFF9F0A),
    highlights: [
      (
        title: 'Classic iOS Custom Switch Toggles',
        desc:
            'Restored authentic custom iOS switch (commit 9a166b26) with 62x32 track, 34x28 white pill thumb, fluid +10px mechanical stretch, drop shadow, and Apple HIG Accessibility indicators ("|" and "O").',
        icon: Icons.toggle_on_rounded,
        tag: 'Controls',
      ),
      (
        title: 'Hierarchical Settings Back-Navigation',
        desc:
            'Full 3-tier navigation stack and canonical parent resolution. Swiping back or tapping Back ascends to the immediate parent category rather than popping all the way back to root settings.',
        icon: Icons.account_tree_rounded,
        tag: 'Navigation',
      ),
      (
        title: 'Apple HIG & BitChord Precision Architecture',
        desc:
            'Continuous squircle tokens with 60.7% corner smoothing, positive SF Pro micro-typography tracking (+0.05 to +0.2), lifted pill segmented controls, and de-pilled action buttons.',
        icon: Icons.auto_awesome_rounded,
        tag: 'Design',
      ),
      (
        title: 'Routine Habit Checkpoints & Custom Categories',
        desc:
            'Edit or delete any habit checkpoint (including default routines) with confirmation safeguards. Create custom categories with dedicated color palettes and emojis with instant moment migration.',
        icon: Icons.playlist_add_check_rounded,
        tag: 'Habits',
      ),
      (
        title: 'Timeline Rich Markdown & Expandable Notes',
        desc:
            'Formatted bold, italic, code, blockquotes, and bullet lists rendered directly on timeline cards with inline "Show more / Show less" expansion toggle and debounced audio scrubbing.',
        icon: Icons.notes_rounded,
        tag: 'Timeline',
      ),
      (
        title: 'Zero-Knowledge Vault 100k Hardening',
        desc:
            'Upgraded key derivation to OWASP-standard 100,000 PBKDF2 iterations, note composer draft auto-saving with discard protection, and dynamic window obfuscation.',
        icon: Icons.lock_outline_rounded,
        tag: 'Security',
      ),
      (
        title: 'Android 14/15 Parity: Predictive Back & Themed Icons',
        desc:
            'Predictive Back gesture support across modal sheets and Material You themed adaptive monochrome launcher icons (android:roundIcon) for dynamic system theming.',
        icon: Icons.android_rounded,
        tag: 'Platform',
      ),
      (
        title: 'Universal Ledger & Analytics Performance',
        desc:
            'Duration-weighted time-slot bias with cross-midnight interval slicing and GPU-accelerated annual activity heatmap CustomPainter replacing 425 nested widgets.',
        icon: Icons.analytics_rounded,
        tag: 'Analytics',
      ),
    ],
    items: [
      'Classic iOS Switches, Hierarchical Navigation, Apple HIG Architecture & 505 Micro-Improvements.',
      '+ Classic iOS Switch Toggles: Restored 62x32 custom switch with +10px mechanical stretch, Apple HIG "|" and "O" markings, and velocity fling snapping',
      '+ Hierarchical Settings Back-Navigation: 3-tier navigation stack ensuring swipe-back and back buttons ascend to the immediate parent page',
      '+ Apple HIG & BitChord Precision Design System: Continuous squircle tokens (60.7% smoothing), SF Pro tracking physics, and lifted pill segmented controls',
      '+ Routine Habit Checkpoints: Universal habit deletion, inline editing, and dynamic custom category authoring with color palettes and emoji pickers',
      '+ Timeline Rich Markdown & Expandable Notes: Formatted inline markdown rendering and "Show more / Show less" expandable note cards',
      '+ Zero-Knowledge Vault Hardening: Upgraded key derivation to OWASP-standard 100,000 PBKDF2 iterations and note composer draft auto-saving',
      '+ Android 14/15 System Parity: Predictive Back gesture support across modal sheets and Material You themed adaptive monochrome launcher icons',
      '+ 120Hz Parallax Motion: Hardware-synced Vsync Ticker parallax tilt smoothing with lifecycle backgrounding pause',
      '+ System Overlay Recovery: Auto-detects floating bubble permission grant upon returning from Android system settings',
      '+ Universal Ledger & Analytics: Duration-weighted time-slot bias with cross-midnight interval slicing and GPU heatmap CustomPainter',
      '+ Bug Fixes: Fixed duplicate PopScope invocation, predictive edge swipe threshold, controlled switch reconciliation, and bulletin modal dismissal',
    ],
  );

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    bool latestOnly = false,
    bool blur = false,
    bool largeText = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => ChangelogDialog(
        p: p,
        latestOnly: latestOnly,
        blur: blur,
        largeText: largeText,
      ),
    );
  }

  @override
  State<ChangelogDialog> createState() => _ChangelogDialogState();
}

class _ChangelogDialogState extends State<ChangelogDialog> {
  List<String> _currentItems = ChangelogDialog.latestRelease.items;

  @override
  void initState() {
    super.initState();
    _fetchRemoteChangelog();
  }

  Future<void> _fetchRemoteChangelog() async {
    try {
      final res = await http
          .get(
            Uri.parse(
              'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/main/versions/changelog.json',
            ),
          )
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
        if (data.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final userChannel = prefs.getString('m-update-channel') ?? 'stable';

          Map<String, dynamic>? selectedRelease;
          for (final item in data) {
            if (item is! Map<String, dynamic>) continue;
            final channel = (item['channel'] as String? ?? 'stable')
                .toLowerCase();
            final isExp =
                item['isExperiment'] == true ||
                (item['version'] as String? ?? '').contains(
                  RegExp(r'[Ee]\d+'),
                ) ||
                channel == 'experiment';
            final isBeta =
                item['isBeta'] == true ||
                channel == 'beta' ||
                (item['version'] as String? ?? '').toLowerCase().contains(
                  'beta',
                );

            final bool eligible;
            if (userChannel == 'experiment') {
              eligible = true;
            } else if (userChannel == 'beta') {
              eligible = !isExp;
            } else {
              eligible = !isExp && !isBeta;
            }

            if (eligible) {
              selectedRelease = item;
              break;
            }
          }

          if (selectedRelease != null) {
            final items = (selectedRelease['fullChangelog'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList();
            if (items != null && items.isNotEmpty && mounted) {
              setState(() {
                _currentItems = items;
              });
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _openWebChangelog() async {
    HapticFeedback.selectionClick();
    await openExternalLinkSafely(
      context,
      p: widget.p,
      url: ChangelogDialog.webChangelogUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final title = widget.latestOnly
        ? "What's New".localized(context)
        : 'Release Notes'.localized(context);

    return AppSheet(
      p: p,
      title: title,
      largeText: widget.largeText,
      blur: widget.blur,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Personalized Version Hero Card
          _buildHeroCard(context, p),

          const SizedBox(height: 18),

          // High-Impact Highlights Matrix
          for (final h in ChangelogDialog.latestRelease.highlights) ...[
            _buildHighlightCard(context, p, h),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 14),

          // Detailed Release Items with Expressive Bullet Icons (Exclusive to full changelog)
          if (!widget.latestOnly) ...[
            SettingsGroup(
              p: p,
              title: 'Version Highlights & Changes'
                  .localized(context)
                  .toUpperCase(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final item in _currentItems)
                        _buildChangelogItem(context, p, item),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // Web Archive Callout Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: p.accent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Release History'.localized(context),
                        style: TextStyle(
                          color: p.text,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Explore all past versions and updates on our website.'
                            .localized(context),
                        style: TextStyle(color: p.text3, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _openWebChangelog,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View Web'.localized(context),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Primary Done Button
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text('Got It'.localized(context)),
            style: FilledButton.styleFrom(
              backgroundColor: p.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, Palette p) {
    final rel = ChangelogDialog.latestRelease;
    final isExp = rel.version.contains(RegExp(r'[Ee]\d+'));
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rel.badgeColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: rel.badgeColor.withValues(alpha: 0.12),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: rel.badgeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: rel.badgeColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExp
                          ? Icons.science_rounded
                          : Icons.auto_awesome_rounded,
                      size: 14,
                      color: rel.badgeColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'v${rel.version}'.localized(context),
                      style: TextStyle(
                        color: rel.badgeColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                rel.date.localized(context),
                style: TextStyle(color: p.text3, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rel.edition.localized(context),
            style: TextStyle(
              color: p.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(
    BuildContext context,
    Palette p,
    ({String title, String desc, IconData icon, String tag}) item,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.accent.withValues(alpha: 0.25)),
            ),
            child: Icon(item.icon, color: p.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title.localized(context),
                        style: TextStyle(
                          color: p.text,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        item.tag.localized(context),
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.desc.localized(context),
                  style: TextStyle(color: p.text2, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogItem(BuildContext context, Palette p, String item) {
    var trimmed = item.trim();
    if (trimmed.startsWith('•')) {
      trimmed = trimmed.substring(1).trim();
    }
    String text = trimmed;
    IconData iconData = Icons.circle;
    double iconSize = 6;
    Color iconColor = p.accent;
    Color iconBg = p.accent.withValues(alpha: 0.12);

    if (trimmed.startsWith('+') || trimmed.toLowerCase().startsWith('add')) {
      text = trimmed.startsWith('+') ? trimmed.substring(1).trim() : trimmed;
      iconData = Icons.add_rounded;
      iconSize = 13;
      iconColor = const Color(0xFF30D158);
      iconBg = const Color(0xFF30D158).withValues(alpha: 0.15);
    } else if (trimmed.startsWith('-') ||
        trimmed.toLowerCase().startsWith('remove')) {
      text = trimmed.startsWith('-') ? trimmed.substring(1).trim() : trimmed;
      iconData = Icons.remove_rounded;
      iconSize = 13;
      iconColor = const Color(0xFFFF453A);
      iconBg = const Color(0xFFFF453A).withValues(alpha: 0.15);
    } else if (trimmed.startsWith('!') ||
        trimmed.toLowerCase().startsWith('fix') ||
        trimmed.toLowerCase().startsWith('resolve')) {
      text = trimmed.startsWith('!') ? trimmed.substring(1).trim() : trimmed;
      iconData = Icons.build_circle_outlined;
      iconSize = 13;
      iconColor = const Color(0xFF0A84FF);
      iconBg = const Color(0xFF0A84FF).withValues(alpha: 0.15);
    } else if (trimmed.startsWith('*') ||
        trimmed.toLowerCase().startsWith('refine') ||
        trimmed.toLowerCase().startsWith('optimize') ||
        trimmed.toLowerCase().startsWith('update')) {
      text = trimmed.startsWith('*') ? trimmed.substring(1).trim() : trimmed;
      iconData = Icons.star_rounded;
      iconSize = 14;
      iconColor = const Color(0xFFFF9F0A);
      iconBg = const Color(0xFFFF9F0A).withValues(alpha: 0.15);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(iconData, size: iconSize, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.localized(context),
              style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
