import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';
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
    version: '7.5.14E1',
    date: 'November 08, 2026',
    edition: 'Classic iOS Switches, Habit Countdown & Merge Persistence',
    badgeColor: Color(0xFFFF9F0A),
    innovations: [
      (
        title: 'Classic iOS Custom Switch Toggles',
        category: 'PRECISION CONTROLS & APPLE HIG',
        headline: 'Tactile 62×32 Geometry. +10px Fluid Kinetic Stretch.',
        desc:
            'Restored the beloved classic iOS toggle geometry from commit 7.5.11 (62×32 track, 34×28 pill thumb, +10px fluid mechanical stretch, soft drop shadow, and official Apple HIG "|" and "O" accessibility indicators). Tapping anywhere on the settings row fluidly elongates the thumb, and switch states strictly mirror parent permissions with zero desynchronization or stuck visuals on cancelled PIN prompts.',
        icon: CupertinoIcons.switch_camera,
        badgeColor: Color(0xFF007AFF),
        specs:
            '62x32 Track · 34x28 Thumb · +10px Stretch · "|" & "O" Accessibility Markings · App Lock Desync Protection',
      ),
      (
        title: 'Habit Live Sessions & Reverse Countdown',
        category: 'HABIT TRACKING & CHECKPOINTS',
        headline: 'Intentional Time Horizons. Reverse Chronometer Flow.',
        desc:
            'Start live sessions from routine habits with 15m, 30m, 45m, or custom duration targets. The home screen chronometer counts down in reverse towards completion, accompanied by a dedicated Apple HIG stop action, high-contrast canvas text rendering, and automatic return to neutral default mode when the session concludes.',
        icon: CupertinoIcons.timer,
        badgeColor: Color(0xFFFF9500),
        specs:
            'Reverse Countdown Chronometer · Target Durations · Dedicated Stop Control · Dynamic Text Contrast · Canvas Auto-Reset',
      ),
      (
        title: 'Permanent Session Merging & Mode Switching',
        category: 'TIMELINE & SESSION MANAGEMENT',
        headline: 'Seamless Pairing. 100% Database Persistence.',
        desc:
            'Merge standalone timestamps into structured IN/OUT focus sessions directly from your History timeline. Merged sessions now persist permanently in SQLite across sheet reloads and restarts, with instant reclassification to Work, Deep Focus, or General Mode without reverting or breaking pairing.',
        icon: CupertinoIcons.arrow_merge,
        badgeColor: Color(0xFF34C759),
        specs:
            'Permanent SQLite Persistence · Direct Mode Reassignment · General Mode Support · Session Pairing Integrity',
      ),
      (
        title: 'Hierarchical Settings Navigation & Predictive Back',
        category: 'NAVIGATION ARCHITECTURE',
        headline: 'Ancestral Stack Memory. Intuitive Parent Navigation.',
        desc:
            'Deeply nested settings subpages now remember their lineage. Swiping from the screen edge or tapping the back button ascends smoothly to the immediate parent category (e.g. Moments, App Lock, Developer Options) rather than abruptly collapsing to root settings, fully integrated with Android 14/15 predictive back gestures.',
        icon: CupertinoIcons.arrow_left_to_line,
        badgeColor: Color(0xFFAF52DE),
        specs:
            '3-Tier Category Stack · Predictive Back Peek · Canonical Ancestor Resolution · Rapid Double-Tap Handling',
      ),
      (
        title: 'Apple HIG & BitChord Precision Design System',
        category: 'DESIGN SYSTEM & TYPOGRAPHY',
        headline: 'Continuous Squircles. Minimal Elevated Surfaces.',
        desc:
            'Deep visual refinement featuring continuous 60.7% squircle corner smoothing, positive SF Pro micro-typography tracking (+0.05 to +0.2), redesigned full-width Data Safety and App Permissions cards, and sleek minimal Content Rating scorecard badges.',
        icon: CupertinoIcons.sparkles,
        badgeColor: Color(0xFFFF2D55),
        specs:
            '60.7% Continuous Squircles · Positive Tracking · Full-Width Hero Cards · Minimal Status Capsules',
      ),
      (
        title: '1-Month Beta Milestone & Gated Experimental Builds',
        category: 'RELEASE TRACKS & MILESTONES',
        headline: '30-Day Testing Milestone. Bleeding-Edge Access.',
        desc:
            'Dedicated beta testers who use NoteKar continuously for 30 days receive an authentic Apple HIG milestone popup unlocking early access to Developer Experiments. Testers with God Mode unlocked can also reveal experimental builds instantly with a single tap.',
        icon: CupertinoIcons.rosette,
        badgeColor: Color(0xFFFFD700),
        specs:
            '30-Day Beta Milestone · Apple HIG Modal Notification · God Mode Direct Unlock · Developer Experiments Track',
      ),
      (
        title: 'Timeline Rich Markdown & Expandable Notes',
        category: 'NOTE TAKING & MULTIMEDIA',
        headline: 'Expressive Formatting. Show More / Show Less Cards.',
        desc:
            'Express ideas naturally with inline bold, italic, code blocks, blockquotes, and bulleted lists rendered directly on timeline cards. Extended thoughts feature an intuitive "Show more / Show less" expansion toggle and debounced 120Hz audio scrubbers.',
        icon: CupertinoIcons.doc_text,
        badgeColor: Color(0xFF5856D6),
        specs:
            'Inline Markdown Engine · Expandable Note Cards · Debounced Audio Seeking · High-Performance Repaint Boundaries',
      ),
      (
        title: 'Hardened Zero-Knowledge Vault (100k PBKDF2 Iterations)',
        category: 'SECURITY & ENCRYPTION',
        headline: 'Military-Grade Key Derivation. Continuous Draft Protection.',
        desc:
            'Vault key derivation upgraded to OWASP-standard 100,000 PBKDF2 iterations for impenetrable on-device encryption. Note drafts now auto-save continuously to prevent lost reflections, paired with dynamic recent-apps window obfuscation.',
        icon: CupertinoIcons.lock_shield_fill,
        badgeColor: Color(0xFF30B0C7),
        specs:
            '100,000 PBKDF2 Iterations · Note Draft Auto-Saving · PopScope Discard Guard · Dynamic Recents Obfuscation',
      ),
    ],
    items: [
      '• Classic iOS Switches, Habit Live Countdown, Merge Persistence & Apple HIG Architecture',
      '+ Classic iOS Switch Toggles: Restored 62x32 custom switch with +10px mechanical stretch, Apple HIG "|" and "O" markings, and row-touch stretch',
      '+ Habit Live Sessions & Countdown: Target duration mode (15m, 30m, 45m) with reverse chronometer, dedicated Stop action, and default auto-reset',
      '+ Permanent Session Merging: Merged IN/OUT sessions persist permanently across sheet reloads; reassign session modes directly in History',
      '+ Hierarchical Navigation: Swiping back in deep settings subpages ascends to the immediate parent category instead of root',
      '+ Apple HIG Design Polish: Minimal Data Safety hero card, full-width App Permissions status card, and clean Content Rating badges',
      '+ Gated Developer Experiments: 30-day continuous beta milestone unlock notification, plus 1-tap God Mode tester access',
      '+ Timeline Rich Markdown: Inline formatting for bold, italic, code, quotes, and bullet lists with "Show more / Show less" expansion',
      '+ Zero-Knowledge Vault Hardening: Key derivation hardened to 100,000 PBKDF2 iterations, note draft auto-saving, and discard protection',
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
              icon: CupertinoIcons.ant,
              title: 'Report a Bug'.localized(context),
              subtitle: "Something isn't working as expected.".localized(
                context,
              ),
              color: p.red,
              onTap: () => onOpenGithubIssue('bug'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.sparkles,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),

        // 1. Apple Keynote Hero Event Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: rel.badgeColor.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: rel.badgeColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: rel.badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: rel.badgeColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.sparkles,
                      size: 12,
                      color: rel.badgeColor,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'KEYNOTE RELEASE'.localized(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: rel.badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'v${rel.version} Update'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rel.edition.localized(context),
                style: TextStyle(
                  color: rel.badgeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'NoteKar has revisioned itself. Moving beyond a minimalist clicker, NoteKar elevates into an existential compass: accounting for finite human conscious hours, confronting the cost of the unaccounted void, and perfecting sensory chronometer craft.'
                    .localized(context),
                style: TextStyle(
                  color: p.text2,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(CupertinoIcons.calendar, size: 12, color: p.text3),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '${rel.date.localized(context)} · ${'Production'.localized(context)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing20),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
          child: Text(
            'MAJOR INNOVATIONS'.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),

        const SizedBox(height: spacing4),

        // 2. Keynote Innovation Cards
        for (final inv in rel.innovations)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: p.border.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: inv.badgeColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(inv.icon, color: inv.badgeColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inv.category.localized(context),
                              style: TextStyle(
                                color: inv.badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              inv.title.localized(context),
                              style: TextStyle(
                                color: p.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    inv.headline.localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    inv.desc.localized(context),
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface3.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: p.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      inv.specs.localized(context),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: spacing16),

        // 3. Craftsmanship Philosophy Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: p.border.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Icon(
                CupertinoIcons.quote_bubble,
                color: p.accent.withValues(alpha: 0.7),
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                '"Details matter, it’s worth waiting to get it right."'
                    .localized(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.text,
                  fontSize: 13.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'TIMELESS CRAFT'.localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing16),

        // 4. View Full Technical Changelog Button
        PressableScale(
          onTap: () => _openWebChangelog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.book_fill, color: p.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'View Full Technical Changelog'.localized(context),
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
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
              icon: CupertinoIcons.clock_fill,
              title: 'Full Release Archive on Web'.localized(context),
              subtitle: 'Browse all historical versions and beta releases.'
                  .localized(context),
              color: p.accent,
              trailing: Icon(
                CupertinoIcons.chevron_forward,
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
    IconData iconData = CupertinoIcons.circle_fill;
    double iconSize = 6;
    Color iconColor = p.accent;
    Color iconBg = p.accent.withValues(alpha: 0.12);

    if (trimmed.startsWith('+') || trimmed.toLowerCase().startsWith('add')) {
      text = trimmed.startsWith('+') ? trimmed.substring(1).trim() : trimmed;
      iconData = CupertinoIcons.plus;
      iconSize = 13;
      iconColor = const Color(0xFF30D158);
      iconBg = const Color(0xFF30D158).withValues(alpha: 0.15);
    } else if (trimmed.startsWith('-') ||
        trimmed.toLowerCase().startsWith('remove')) {
      text = trimmed.startsWith('-') ? trimmed.substring(1).trim() : trimmed;
      iconData = CupertinoIcons.minus;
      iconSize = 13;
      iconColor = const Color(0xFFFF453A);
      iconBg = const Color(0xFFFF453A).withValues(alpha: 0.15);
    } else if (trimmed.startsWith('!') ||
        trimmed.toLowerCase().startsWith('fix') ||
        trimmed.toLowerCase().startsWith('resolve')) {
      text = trimmed.startsWith('!') ? trimmed.substring(1).trim() : trimmed;
      iconData = CupertinoIcons.wrench;
      iconSize = 13;
      iconColor = const Color(0xFF0A84FF);
      iconBg = const Color(0xFF0A84FF).withValues(alpha: 0.15);
    } else if (trimmed.startsWith('*') ||
        trimmed.toLowerCase().startsWith('refine') ||
        trimmed.toLowerCase().startsWith('optimize') ||
        trimmed.toLowerCase().startsWith('update')) {
      text = trimmed.startsWith('*') ? trimmed.substring(1).trim() : trimmed;
      iconData = CupertinoIcons.star_fill;
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
