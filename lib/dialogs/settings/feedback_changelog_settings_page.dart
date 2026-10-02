import 'package:flutter/material.dart';
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
    version: '7.5.6',
    date: 'October 02, 2026',
    edition: 'Dynamic Momentum & Digital Wellbeing',
    badgeColor: Color(0xFFFF9F0A),
    innovations: [
      (
        title: 'Dynamic Momentum Capsule',
        category: 'MINIMALIST CANVAS',
        headline: 'Pure Canvas. Seamless Momentum.',
        desc:
            'Today\'s Momentum card now opens seamlessly from inside the top dynamic pill upon tap, keeping your home screen pure, minimal, and completely distraction-free.',
        icon: Icons.speed_rounded,
        badgeColor: Color(0xFF0A84FF),
        specs:
            'DynamicHeaderCapsule · Live Duration · Streak Flame · 1-Tap Hub Link',
      ),
      (
        title: 'Android Digital Wellbeing',
        category: 'INTENTIONALITY INTELLIGENCE',
        headline: 'Smart Buckets. Intentionality Delta.',
        desc:
            'Opt-in native integration with Android UsageStatsManager groups device screen time into generic categories to reveal your Intentionality Reality Delta with 100% offline privacy.',
        icon: Icons.pie_chart_outline_rounded,
        badgeColor: Color(0xFF34C759),
        specs:
            'Smart Buckets · UsageStatsManager · Reality Delta · Zero Telemetry',
      ),
      (
        title: 'Data Safety & Recovery Shield',
        category: 'DATA RESILIENCE',
        headline: 'Automated Snapshots. Forgiving Streaks.',
        desc:
            'Hive database corruption now automatically triggers a timestamped local backup before recovery. Streak Guardian grace-day logic no longer penalizes users permanently after a relapse.',
        icon: Icons.shield_rounded,
        badgeColor: Color(0xFFFF9F0A),
        specs:
            'Emergency Auto-Snapshots · Relapse Reset · Streak Shield Recovery',
      ),
      (
        title: 'Flagship Apple HIG Goals Engine',
        category: 'GOALS & SENSORY',
        headline: 'Pacing Metrics. Doodle Splash. 1-Tap Start.',
        desc:
            'Rebuilt goals system featuring pacing indicators, Cupertino segmented controls, WhatsApp-style dark mode doodle splash with official NoteKar emblem, and acoustic swipe-to-delete sounds.',
        icon: Icons.track_changes_rounded,
        badgeColor: Color(0xFFAF52DE),
        specs:
            'Pacing Indicators · Doodle Splash · Monogram Emblem · Acoustic Feedback',
      ),
      (
        title: 'Platform Security & Receiver Hardening',
        category: 'PLATFORM SECURITY',
        headline: 'Signature Permissions. Anti-Spoofing.',
        desc:
            'Exported Android broadcast receivers are now secured with signature-level permissions, preventing unauthorized apps or malicious background intents from injecting fake data.',
        icon: Icons.security_rounded,
        badgeColor: Color(0xFFFF2D55),
        specs:
            'Signature Permissions · IPC Protection · Anti-Spoofing Architecture',
      ),
      (
        title: 'Authentic Analytics & Design Tokens',
        category: 'SYSTEM ARCHITECTURE',
        headline: 'True Durations. Systematic Design Tokens.',
        desc:
            'Purged fabricated 15-minute durations on single taps, fixed 12 PM noon risk radar display, decomposed 12,000+ lines of god classes, and introduced systematic NkTokens design tokens.',
        icon: Icons.insights_rounded,
        badgeColor: Color(0xFF5856D6),
        specs:
            'NkTokens · God-Class Deconstruction · True Analytics · Noon Fix',
      ),
      (
        title: 'Personal Identity & Memento Mori',
        category: 'LIFE AWARENESS',
        headline: 'Profile Avatars. Memento Mori Horizon.',
        desc:
            'Personalize NoteKar with a custom profile avatar, user alias, and an interactive Memento Mori Life Horizon card showing exact lifespan percentage, weeks lived, and remaining seasons.',
        icon: Icons.person_rounded,
        badgeColor: Color(0xFF0A84FF),
        specs:
            'Profile Avatar · Lifespan Metrics · Dedicated Cupertino DOB Picker',
      ),
      (
        title: 'Plus Notes & Journaling',
        category: 'NOTE ARCHITECTURE',
        headline: 'Unrestricted Canvas. Seamless History Editing.',
        desc:
            'Dedicated long-form writing canvas with top-left Plus button, combined with full history editing parity and customizable quick hashtags.',
        icon: Icons.note_add_rounded,
        badgeColor: Color(0xFFFF9F0A),
        specs:
            'Unrestricted Canvas · Plus Button · History Note Parity · Custom Tags',
      ),
      (
        title: 'Resilient Home Widgets',
        category: 'ANDROID SUBSYSTEM',
        headline: 'RemoteViews Restored. Zero Crash Guarantee.',
        desc:
            'Sobriety and Life Audit launcher widgets completely revitalized with FrameLayout layouts, initial placement sizing fixes, graceful zero-states, and direct settings deep-linking.',
        icon: Icons.widgets_rounded,
        badgeColor: Color(0xFF34C759),
        specs: 'FrameLayout RemoteViews · Deep Linking · Zero-State Support',
      ),
      (
        title: 'Life Audit & The Void',
        category: 'EXISTENTIAL COMPASS',
        headline: 'Every Second Accounted. The Void Revealed.',
        desc:
            'Uncompromising 24-hour conscious partition architecture confronting the cost of unaccounted time across 6 multi-horizons from today to a full solar year.',
        icon: Icons.auto_graph_rounded,
        badgeColor: Color(0xFFFF9500),
        specs: '24h Partitions · 6 Horizons · Seneca Reality Colophon',
      ),
      (
        title: 'Spatial Bebas Neue Clock',
        category: 'SPATIAL HARMONY',
        headline: 'Optical Midpoint. Authentic Tall Type.',
        desc:
            'Chronometer face is mathematically centered within the usable viewport, paired with authentic, bundled open-source Bebas Neue tall numerals.',
        icon: Icons.schedule_rounded,
        badgeColor: Color(0xFF0A84FF),
        specs: 'Usable Viewport Centered · Bebas Neue 144pt · Tabular Figures',
      ),
      (
        title: 'Two-Way Session Continuity',
        category: 'STATE ENGINE',
        headline: 'Unbroken Focus. Zero State Loss.',
        desc:
            'Switch dynamically between Single and Two-Way modes mid-session without resetting stopwatch clocks, losing elapsed intervals, or dropping note state.',
        icon: Icons.sync_alt_rounded,
        badgeColor: Color(0xFF34C759),
        specs: 'Live Continuity · Seamless Transition · Dual Timer Guard',
      ),
      (
        title: 'WhatsApp-Grade Note Input',
        category: 'TEXT ENGINE',
        headline: 'Typing on Glass. Zero Latency.',
        desc:
            'Re-engineered note dialogue with sentence auto-capitalization, composition truncation guards, and decoupled character state updates for zero input lag.',
        icon: Icons.edit_note_rounded,
        badgeColor: Color(0xFFAF52DE),
        specs: 'Zero Input Lag · Composition Safe · Sentences Capped',
      ),
      (
        title: 'Smart Onboarding & 7 Locales',
        category: 'SYSTEM ARCHITECTURE',
        headline: 'Contextual Discovery. Global Reach.',
        desc:
            'Feature tours unified into onboarding, standalone unseen cards for updating users, and comprehensive 7-language offline localizations.',
        icon: Icons.translate_rounded,
        badgeColor: Color(0xFFFF2D55),
        specs: '7 Offline Locales · Unseen Update Cards · Devanagari Type',
      ),
    ],
    highlights: [
      (
        title: 'Dynamic Momentum Capsule',
        desc:
            'Today\'s Momentum card opens seamlessly inside the top pill, keeping the home canvas pure and distraction-free.',
        icon: Icons.speed_rounded,
        tag: 'Capture',
      ),
      (
        title: 'Android Digital Wellbeing',
        desc:
            'Opt-in Smart Buckets and Intentionality Reality Delta dashboard comparing focus to total screen time.',
        icon: Icons.pie_chart_outline_rounded,
        tag: 'Wellbeing',
      ),
      (
        title: 'Data Safety & Recovery',
        desc:
            'Automated corrupted-box snapshots prevent data loss; streak grace shields restore cleanly upon new streaks.',
        icon: Icons.shield_rounded,
        tag: 'Safety',
      ),
      (
        title: 'Apple HIG Goals Engine',
        desc:
            'Pacing metrics, squircle launch splash, Zen doodle animation, and 1-tap session launching.',
        icon: Icons.track_changes_rounded,
        tag: 'Goals',
      ),
      (
        title: 'Platform Security Hardening',
        desc:
            'Secured broadcast receivers with signature permissions against external intent spoofing.',
        icon: Icons.security_rounded,
        tag: 'Security',
      ),
      (
        title: 'Authentic Analytics Engine',
        desc:
            'Purged fabricated durations, accurate cross-boundary sessions, and corrected 12 PM noon risk radar display.',
        icon: Icons.insights_rounded,
        tag: 'Analytics',
      ),
    ],
    items: [
      '• Dynamic momentum capsule, Android Digital Wellbeing, Apple HIG goals, and core data resilience.',
      '+ Dynamic Momentum Capsule: Today\'s Momentum embedded inside DynamicHeaderCapsule with live progress',
      '+ Android Digital Wellbeing: Smart Buckets and Intentionality Reality Delta dashboard',
      '+ Apple HIG Goals Engine: Pacing metrics, Cupertino segmented controls, and 1-tap session launch',
      '+ Squircle Splash & Zen Doodle: Liquid splash transition with fluid doodle animation',
      '+ Corrupted-Box Snapshots: Automatic database backup before repair to eliminate silent data loss',
      '+ Streak Guardian Repair: Fixed permanent shield lockout on relapse, restoring streak forgiveness',
      '+ Platform Security: Exported broadcast receivers protected with signature-level permissions',
      '+ God-Class Deconstruction: Split 12,000+ lines into modular lifecycle delegates and NkTokens',
      '+ Authentic Analytics: Purged fabricated 15m single tap durations for true session integrity',
      '+ Noon Risk Radar Fix: Corrected "12 AM" display for 12:00 PM noon time blocks',
      '* All 234 automated unit and widget test suites passing with zero lints and 100% offline privacy',
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
                      Icons.auto_awesome_rounded,
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
                  Icon(Icons.calendar_today_rounded, size: 12, color: p.text3),
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
                Icons.format_quote_rounded,
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
                Icon(Icons.history_edu_rounded, color: p.accent, size: 18),
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
