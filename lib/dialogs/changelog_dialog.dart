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
    version: '8.0.1',
    date: 'November 20, 2026',
    edition:
        'NoteKar 8.0.1: Apple HIG Refinements, User Feedback & Asset Optimization',
    badgeColor: Color(0xFF30D158),
    highlights: [
      (
        title: 'Routine / Habits Quick Filter',
        desc:
            '1-tap Routine filter pill directly in the primary horizontal filter bar in History, allowing instantaneous isolation of all habit checkpoints with full localization.',
        icon: Icons.flag_rounded,
        tag: 'History',
      ),
      (
        title: 'Natural Forward-Time Scheduling',
        desc:
            'Selecting or increasing duration in habit sessions anchors start time and advances end time forward naturally. Dynamic boundaries eliminate Cupertino date picker assertion crashes.',
        icon: Icons.schedule_rounded,
        tag: 'Habits',
      ),
      (
        title: 'Custom Habit Duration & iOS Picker',
        desc:
            'Dedicated + custom duration pill at the end of habit duration chips opening an authentic Apple HIG bottom sheet with CupertinoTimerPicker for custom hours and minutes.',
        icon: Icons.more_time_rounded,
        tag: 'Habits',
      ),
      (
        title: 'Quick 5m & 10m Micro-Durations',
        desc:
            'Added 5m and 10m quick chips right at the start of the habit duration row ([5, 10, 15, 30, 45, 60, 90, 120]) for frictionless micro-habit logging.',
        icon: Icons.timer_outlined,
        tag: 'Habits',
      ),
      (
        title: 'High-Density Asset Optimization (~4.8MB Saved)',
        desc:
            'Optimized 8 uncompressed preset avatar JPEG images and the Diwali notice banner, cutting ~4.8MB directly from the APK bundle (-92.7% reduction) with zero decoding lag.',
        icon: Icons.compress_rounded,
        tag: 'Performance',
      ),
      (
        title: 'Resilient Multi-Hop In-App Updater',
        desc:
            'Enhanced in-app update engine supporting 10-hop GitHub AWS S3 redirects, paired with multi-manifest checksum verification and ZIP binary fallback validation.',
        icon: Icons.system_update_rounded,
        tag: 'Updates',
      ),
      (
        title: 'Dual-Key Theme & Accent Persistence',
        desc:
            'Dual-key persistence across updates with synchronous live propagation across all open sheets and screens without restart.',
        icon: Icons.palette_rounded,
        tag: 'Themes',
      ),
      (
        title: 'Light Theme High-Contrast Visibility',
        desc:
            'Apple HIG #D1D1D6 border tokens, deep graphite #1C1C1E icons/text contrast, and synchronized status bar icon brightness so controls and notifications never wash out.',
        icon: Icons.contrast_rounded,
        tag: 'Design',
      ),
      (
        title: 'Apple HIG Accessible Single Timestamp Button',
        desc:
            'Elevated "Log as single timestamp" into a prominent, high-contrast OutlinedButton with 48dp accessibility touch target.',
        icon: Icons.radio_button_checked_rounded,
        tag: 'Habits',
      ),
    ],
    items: [
      'NoteKar 8.0.1: Apple HIG Refinements, User Feedback & Asset Optimization',
      '+ Routine Filter: 1-tap Routine/Habits filter pill on History dialog',
      '+ Forward Scheduling: Natural forward duration scheduling for live sessions',
      '+ Custom Time: + pill with iOS CupertinoTimerPicker bottom sheet',
      '+ Quick Chips: 5m & 10m micro-durations at the start of habit duration row',
      '+ App Size: ~4.8MB direct APK bundle reduction via asset optimization',
      '+ In-App Updater: 10-hop S3 redirect support & multi-manifest checksum fallback',
      '+ Theme Persistence: Dual-key theme & accent persistence across updates with live propagation',
      '+ Light Mode: High-contrast #D1D1D6 borders and synchronized status bar brightness',
      '+ Single Timestamp: 48dp Apple HIG OutlinedButton for single timestamp habit logging',
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
