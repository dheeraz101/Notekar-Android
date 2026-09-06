import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class FeedbackChangelogSettingsPage extends StatelessWidget {
  const FeedbackChangelogSettingsPage({
    super.key,
    required this.p,
    required this.subCategory, // 'Feedback', "What's New", 'Changelog'
    required this.onOpenGithubIssue,
  });

  final Palette p;
  final String subCategory;
  final ValueChanged<String> onOpenGithubIssue;

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

  Future<void> _openWebChangelog(BuildContext context) async {
    HapticFeedback.selectionClick();
    await openExternalLinkSafely(context, p: p, url: webChangelogUrl);
  }

  @override
  Widget build(BuildContext context) {
    if (subCategory == 'Feedback') {
      return _buildFeedback(context);
    } else if (subCategory == "What's New") {
      return _buildWhatsNew(context);
    } else if (subCategory == 'Changelog') {
      return _buildChangelog(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildFeedback(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.bug_report_rounded,
              title: 'Report a Bug'.localized(context),
              subtitle: "Something isn't working as expected.".localized(
                context,
              ),
              color: p.red,
              onTap: () => onOpenGithubIssue('bug'),
            ),
            SettingsRow(
              p: p,
              icon: Icons.auto_awesome_rounded,
              title: 'Request a Feature'.localized(context),
              subtitle: 'Suggest a new idea or improvement.'.localized(context),
              color: p.accent,
              onTap: () => onOpenGithubIssue('feature'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'Select an option to open GitHub and submit a structured issue. Your device specifications will be prefilled automatically.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildWhatsNew(BuildContext context) {
    final rel = latestRelease;
    return Column(
      children: [
        const SizedBox(height: spacing8),

        // Version Banner Group
        SettingsGroup(
          p: p,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: rel.badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: rel.badgeColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: rel.badgeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'v${rel.version} Update'.localized(context),
                              style: TextStyle(
                                color: p.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              rel.date.localized(context),
                              style: TextStyle(color: p.text3, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rel.edition.localized(context),
                          style: TextStyle(
                            color: rel.badgeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: spacing12),

        // Highlights Group
        SettingsGroup(
          p: p,
          title: 'Major Innovations'.localized(context).toUpperCase(),
          children: [
            for (final h in rel.highlights)
              SettingsRow(
                p: p,
                icon: h.icon,
                title: h.title.localized(context),
                subtitle: h.desc.localized(context),
                status: h.tag.localized(context),
                color: p.accent,
              ),
          ],
        ),

        const SizedBox(height: spacing12),

        SettingsPageDescription(
          p: p,
          text:
              'What’s New highlights recent innovations and design evolutions introduced in NoteKar.'
                  .localized(context),
        ),

        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildChangelog(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),

        // Current Version Changelog
        SettingsGroup(
          p: p,
          title: 'v${latestRelease.version} — ${latestRelease.edition}'
              .localized(context),
          description: latestRelease.date.localized(context),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final item in latestRelease.items)
                    _buildExpressiveRow(context, item),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: spacing12),

        // Web Archive Link for older releases
        SettingsGroup(
          p: p,
          children: [
            SettingsRow(
              p: p,
              icon: Icons.history_rounded,
              title: 'Full Release Archive on Web'.localized(context),
              subtitle: 'Browse all historical versions and beta releases.'
                  .localized(context),
              color: p.accent,
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: p.text3,
              ),
              onTap: () => _openWebChangelog(context),
            ),
          ],
        ),

        SettingsPageDescription(
          p: p,
          text:
              'Older changelogs are hosted on the official website to maintain NoteKar’s minimal app footprint.'
                  .localized(context),
        ),

        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildExpressiveRow(BuildContext context, String item) {
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
}
