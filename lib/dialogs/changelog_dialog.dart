import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/settings_widgets.dart';

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
    version: '7.3.2',
    date: 'September 06, 2026',
    edition: 'Life Ledger Density & iOS Dialog Architecture',
    badgeColor: Color(0xFF0A84FF),
    highlights: [
      (
        title: 'Compact History Timeline',
        desc:
            'Ultra-dense timeline layout presenting 2x–3x more moments with scaled rail markers and micro duration badges.',
        icon: Icons.view_agenda_rounded,
        tag: 'Timeline',
      ),
      (
        title: 'Standardized iOS Dialogs',
        desc:
            'All multi-choice alerts upgraded to native CupertinoAlertDialog standard with zero button label truncation.',
        icon: Icons.chat_bubble_outline_rounded,
        tag: 'Apple HIG',
      ),
      (
        title: 'Life Ledger Session Pairing',
        desc:
            'Intelligently pairs Two-Way IN/OUT intervals into unified session cards with 1-tap inline live session ending.',
        icon: Icons.timeline_rounded,
        tag: 'Sessions',
      ),
      (
        title: 'Executive Intelligence Hub',
        desc:
            'Grounded Daily Rhythm hourly charts, 90-day activity intensity grid, and responsive time-scope habit analytics.',
        icon: Icons.insights_rounded,
        tag: 'Analytics',
      ),
    ],
    items: [
      '+ Add high-density Compact History Mode for TimelineSessionCard and TimelineSingleTile',
      '+ Automatically suppress empty note placeholder boxes in compact mode to maximize vertical density',
      '+ Standardize all 2+ option confirmation popups to native CupertinoAlertDialog via showCupertinoDialog',
      '+ Upgrade External Navigation warning to native Cupertino alert with verified domain badges and link preview',
      '+ Upgrade Network Warning modal to Cupertino alert with animated check toggle and download size indicators',
      '+ Unify Trash Bin, Backup Deletion, and Feature Conflict dialogs under Apple HIG action stacking rules',
      '+ Add Life Ledger continuous session cards with emerald start nodes, crimson end nodes, and duration connectors',
      '+ Add 1-tap live session end button to stop active tracking immediately from inside History',
      '+ Add Executive Intelligence Hub with Daily Rhythm bar chart and rolling 90-day activity intensity matrix',
      '+ Add standalone onboarding tour walkthrough pages for the History Timeline and Dashboard Hub',
      '* Geometrically lock calendar day cell baselines so dates with event activity dots never shift upward',
      '* Reposition Dashboard hero card pace and trend badges to eliminate horizontal text truncation',
      '! Ensure history calendar chip immediately launches MomentCalendarDialog on first tap',
      '* Full automated test coverage across compact timeline cards and Cupertino confirmation alerts',
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
          final first = data.first as Map<String, dynamic>;
          final items = (first['fullChangelog'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();
          if (items != null && items.isNotEmpty && mounted) {
            setState(() {
              _currentItems = items;
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _openWebChangelog() async {
    HapticFeedback.selectionClick();
    try {
      const channel = MethodChannel('notekar/files');
      await channel.invokeMethod<void>('openUrl', {
        'url': ChangelogDialog.webChangelogUrl,
      });
    } catch (_) {
      await Clipboard.setData(
        const ClipboardData(text: ChangelogDialog.webChangelogUrl),
      );
      if (mounted) {
        showIosPillToast(
          context: context,
          p: widget.p,
          message: 'Link copied to clipboard'.localized(context),
          icon: Icons.copy_rounded,
        );
      }
    }
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

  Widget _buildChangelogItem(BuildContext context, Palette p, String item) {
    final trimmed = item.trim();
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

  Widget _buildHeroCard(BuildContext context, Palette p) {
    final rel = ChangelogDialog.latestRelease;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(24),
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
                      Icons.auto_awesome_rounded,
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
}
