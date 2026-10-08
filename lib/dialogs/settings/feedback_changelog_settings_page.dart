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
    version: '7.5.7',
    date: 'October 04, 2026',
    edition: 'High-Performance Engine & Fault Isolation',
    badgeColor: Color(0xFFFF9F0A),
    innovations: [
      (
        title: 'Concurrency Engine (Isolates)',
        category: 'PERFORMANCE ARCHITECTURE',
        headline: 'Locked 120fps. Zero UI Thread Jank.',
        desc:
            'Heavy analytical computations across Life Audit and Executive Dashboard metrics are now executed on background threads via Dart 3 Isolate.run, guaranteeing buttery-smooth 120fps scrolling even with tens of thousands of notes.',
        icon: CupertinoIcons.bolt,
        badgeColor: Color(0xFF0A84FF),
        specs:
            'Isolate.run · LifeAuditService.calculateAsync · DashboardMetricsService.calculateAsync · Zero-Copy Ports',
      ),
      (
        title: 'High-Performance Search Indexing',
        category: 'SEARCH & RETRIEVAL',
        headline: 'Sub-Millisecond Inverted Token Index.',
        desc:
            'Replaced O(N) linear scans with a dedicated in-memory inverted token index, prefix trie autocomplete, and instant hashtag and category intersection lookups with relevance scoring.',
        icon: CupertinoIcons.search,
        badgeColor: Color(0xFF34C759),
        specs:
            'Inverted Token Index · Prefix Trie · Set Intersections · Candidate Relevance Scoring',
      ),
      (
        title: 'Circuit Breaker Fault Isolation',
        category: 'RELIABILITY & RESILIENCE',
        headline: 'Fail-Safe Architecture. Zero Cascading Crashes.',
        desc:
            'Implemented an automated 3-strike circuit breaker mechanism across subsystem boundaries (Digital Wellbeing, Analytics, MethodChannels) that gracefully trips on unhandled exceptions and includes manual resets in Diagnostics and God Mode.',
        icon: CupertinoIcons.bolt_fill,
        badgeColor: Color(0xFFFF2D55),
        specs:
            'CircuitBreakerService · 3-Strike Threshold · God Mode Overrides · Diagnostics Status',
      ),
      (
        title: 'Secondary Indices & Binary Range Slicing',
        category: 'STORAGE ENGINE EVOLUTION',
        headline: 'O(1) Lookups. O(log N) Date Slicing.',
        desc:
            'MomentRepository now features in-memory secondary indices for O(1) ID lookups and binary range slicing that queries date intervals in O(log N) without full table scans, backed by encrypted Hive storage.',
        icon: CupertinoIcons.square_stack_3d_up,
        badgeColor: Color(0xFFAF52DE),
        specs:
            'Secondary ID Index · Binary Range Slicing · Incremental Updates · Hive AES Cipher',
      ),
      (
        title: 'Guaranteed Daily Maintenance Scheduler',
        category: 'BACKGROUND LIFECYCLE',
        headline: 'OS-Level Alarms. Automated Local Resilience.',
        desc:
            'Native Android AlarmManager schedules exact midnight maintenance (ACTION_DAILY_MAINTENANCE) to generate rolling snapshots, purge expired trash, and compact databases while the user sleeps.',
        icon: CupertinoIcons.clock,
        badgeColor: Color(0xFFFF9500),
        specs:
            'AlarmManager.RTC_WAKEUP · Rolling Snapshots · 30-Day Trash Auto-Purge · Storage Compaction',
      ),
      (
        title: 'Life Audit in History & Infinite Scroll Retention',
        category: 'USER EXPERIENCE',
        headline: 'Direct Ledger Access. Preserved Scroll State.',
        desc:
            'Life Audit & Horizon ledger is now directly accessible from the History sheet action menu, and PageStorageKey integration ensures timeline scroll position is preserved across sheet state toggles.',
        icon: CupertinoIcons.graph_circle,
        badgeColor: Color(0xFF5856D6),
        specs:
            'History Actions · PageStorageKey · In-Sheet Life Audit Router · Seamless Multi-Horizons',
      ),
      (
        title: 'Native State Controller Decoupling',
        category: 'SYSTEM FOUNDATION',
        headline: 'Single Source of Truth. Synchronized IPC.',
        desc:
            'Decoupled global state management into SettingsController with InheritedNotifier and synchronized Android Kotlin background service pause state with Flutter foreground listeners.',
        icon: CupertinoIcons.slider_horizontal_3,
        badgeColor: Color(0xFF007AFF),
        specs:
            'SettingsController · InheritedNotifier · SharedPreferences Sync · Android IPC Alignment',
      ),
    ],
    items: [
      '• Concurrency engine, inverted search indexing, circuit breaker fault isolation, and secondary indices.',
      '+ Concurrency Engine: LifeAuditService and DashboardMetricsService computeAsync offloaded to background isolates',
      '+ High-Performance Search: Inverted token index and O(K) hashtag autocomplete in SearchIndexService',
      '+ Storage Engine Evolution: O(1) ID lookups and O(log N) binary range queries in MomentRepository',
      '+ Circuit Breaker Service: 3-strike failure isolation with manual resets in Diagnostics & God Mode',
      '+ History & Life Audit: Direct Life Audit action sheet route and PageStorageKey scroll preservation',
      '+ Guaranteed OS Maintenance: Android AlarmManager midnight maintenance trigger (ACTION_DAILY_MAINTENANCE)',
      '+ State Decoupling: Native SettingsController migration and synchronized Android Kotlin-Flutter pause state',
      '+ Settings Search Indexing: Indexed routing for Fault Isolation, Floating Timer Pill, and Acoustic Feedback',
      '* All 243 automated unit and widget test suites passing with zero lints and 100% offline privacy',
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
