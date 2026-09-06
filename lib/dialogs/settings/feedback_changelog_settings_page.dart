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

  static const historicalReleases = [
    (
      version: '7.3.1',
      date: 'September 06, 2026',
      edition: 'Life Ledger Timeline & Executive Intelligence Hub',
      items: [
        '+ Add Life Ledger continuous session cards with emerald start nodes and crimson end nodes',
        '+ Add 1-tap inline live session end button in History to terminate tracking immediately',
        '+ Add Executive Intelligence Hub with grounded Daily Rhythm chart and 90-day intensity grid',
        '+ Add standalone interactive onboarding tour pages for History and Dashboard',
        '+ Add 2-digit sequential single moment numbering (00–99) with daily midnight reset',
        '* Geometrically lock calendar day cell baselines so dates with activity dots never jitter',
        '* Reposition Dashboard hero card pace and trend badges to eliminate horizontal clipping',
        '! Fix calendar icon chip in History to immediately open MomentCalendarDialog on first tap',
      ],
    ),
    (
      version: '7.3.0',
      date: 'August 30, 2026',
      edition: 'Sovereign God Mode & Apple HIG Evolution',
      items: [
        '+ Add sovereign God Mode suite with secret theme palettes, gravity sandbox & VIP badge',
        '+ Add Apple HIG Dynamic Island pill toasts with frosted glass translucency',
        '+ Add local Tasker / MacroDroid broadcast automation API via ACTION_LOG_MOMENT',
        '+ Eliminate RTC_WAKEUP battery drain for routine logging reminders (zero-wake Doze)',
        '+ Add full offline historical changelog archive with dynamic GitHub releases sync',
        '* Optimize R8 and ProGuard compiler rules with build caching for faster startup',
        '! Safeguard database initialization when revoking God Mode to prevent preference desynchronization',
      ],
    ),
    (
      version: '7.2.0',
      date: 'August 23, 2026',
      edition: 'Mindfulness, Integrations & Battery Evolution',
      items: [
        '+ Add notekar:// custom URL scheme support for instant logging, Two-Way tracking, and navigation',
        '+ Add Android text selection context menu ("Log in NoteKar") via ProcessTextActivity',
        '+ Add Android Share Target (ACTION_SEND text/plain) for instant quote capturing',
        '+ Add MarkdownSyncService for Obsidian and Logseq date-grouped journal sync',
        '+ Add CalendarSyncService for RFC 5545 .ics Two-Way session export to Google/Outlook Calendar',
        '+ Add dedicated "Integrations & Automation" settings page with copyable templates and live test triggers',
        '+ Add hourly time reflection alarms with mindful breathing prompts waking over lockscreen',
        '* Eliminate RTC_WAKEUP battery drain for routine logging reminders',
        '* Wrap animated widgets in RepaintBoundary for smooth 120 FPS rendering',
      ],
    ),
    (
      version: '7.1.0',
      date: 'August 21, 2026',
      edition: 'Global Localization Edition',
      items: [
        '+ Add French, German, Japanese, Russian localization and dynamic pattern translation',
        '+ Add localized numerals and currency symbols across the app',
        '* Preserve Apple HIG typography in English and normalize toolbar buttons',
        '* Standardize toolbar button icon containers & fix settings description placement',
      ],
    ),
    (
      version: '7.0.0',
      date: 'August 15, 2026',
      edition: 'Apple HIG Luxury Redesign',
      items: [
        '+ Complete Apple HIG & iOS UI redesign upgrade with Dynamic Island pill toasts',
        '+ Modernized App Icon suite featuring 8 custom branded logo editions',
        '+ Sobriety milestones card exporter with native Android share sheet & confetti',
        '* 2-digit single numbering mode (01, 02...), daily reset, and directional badges',
        '+ Complete local database backup manager with individual Restore and Delete options',
      ],
    ),
  ];

  Future<void> _openWebChangelog(BuildContext context) async {
    HapticFeedback.selectionClick();
    try {
      const channel = MethodChannel('notekar/files');
      await channel.invokeMethod<void>('openUrl', {'url': webChangelogUrl});
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: webChangelogUrl));
      if (context.mounted) {
        showIosPillToast(
          context: context,
          p: p,
          message: 'Link copied to clipboard'.localized(context),
          icon: Icons.copy_rounded,
        );
      }
    }
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

        // Changelog List Group with expressive badges
        SettingsGroup(
          p: p,
          title: 'Detailed Additions & Fixes'.localized(context).toUpperCase(),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final item in rel.items)
                    _buildExpressiveRow(context, item),
                ],
              ),
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

        // Historical Releases
        for (final rel in historicalReleases) ...[
          const SizedBox(height: spacing12),
          SettingsGroup(
            p: p,
            title: 'v${rel.version} — ${rel.edition}'.localized(context),
            description: rel.date.localized(context),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final item in rel.items)
                      _buildExpressiveRow(context, item),
                  ],
                ),
              ),
            ],
          ),
        ],

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
