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
    version: '7.5.12',
    date: 'November 01, 2026',
    edition: 'Quick Settings Tile, Canvas Habits & Apple HIG Surgery',
    badgeColor: Color(0xFFFF9F0A),
    innovations: [
      (
        title: 'Quick Settings Notification Tile',
        category: 'SYSTEM OVERLAY & CONVENIENCE',
        headline: 'Instant Bubble Toggle. Zero App Open Required.',
        desc:
            'Control your floating timer overlay directly from Android\'s system status bar Quick Settings shade. Tap the NoteKar tile anytime to reveal or hide the floating bubble without switching away from your current activity.',
        icon: CupertinoIcons.bell_fill,
        badgeColor: Color(0xFF34C759),
        specs:
            'Quick Settings TileService · Background Broadcast Receiver · 1-Tap Overlay Toggle · System Shade Integration',
      ),
      (
        title: 'Interactive Bubble Dismissal Target',
        category: 'GESTURAL OVERLAYS & CONTROLS',
        headline: 'Bottom "✕" Drop Target. Drag-to-Dismiss.',
        desc:
            'Drag the floating bubble to the bottom of the screen to reveal an animated "✕" dismissal drop-target. Releasing dismisses the bubble cleanly, while the Quick Settings Tile or home widget instantly brings it back.',
        icon: CupertinoIcons.xmark_circle_fill,
        badgeColor: Color(0xFFFF3B30),
        specs:
            'Bottom Screen Drop Target · Magnetic Snapping · Haptic Drag Feedback · Quick Re-summoning',
      ),
      (
        title: 'Canvas Habit Creator & Editor',
        category: 'HABIT TRACKING & CHECKPOINTS',
        headline: 'Interactive Authoring. Emoji Selector & Cadence.',
        desc:
            'Add and customize habits directly on the home canvas. Tap "+ Add Habit" to open the Apple HIG habit creator with custom emoji selection, custom cadence intervals, and deletion confirmation safeguards.',
        icon: CupertinoIcons.add_circled_solid,
        badgeColor: Color(0xFF007AFF),
        specs:
            'AddEditHabitSheet · Emoji Customization · Cadence Intervals · Core Preset Protection · Deletion Alerts',
      ),
      (
        title: 'Media Symmetry in Note Previews',
        category: 'MULTIMODAL NOTE REVIEWS',
        headline: 'Inline Audio Playback. Instant Photo Lightbox.',
        desc:
            'Reviewing logged moments now supports rich multimedia directly in the NotePreviewSheet modal. Listen to audio memos via TimelineVoicePlayerPill with real-time progress and inspect photo moments seamlessly.',
        icon: CupertinoIcons.waveform,
        badgeColor: Color(0xFFAF52DE),
        specs:
            'TimelineVoicePlayerPill Integration · Photo Attachment Cards · Swipe-to-Navigate · Full Media Symmetry',
      ),
      (
        title: 'Sovereign App Permissions Dashboard',
        category: 'SECURITY & HARDWARE CAPABILITIES',
        headline: '7 Device Capabilities. Zero Telemetry Guarantee.',
        desc:
            'Inspect microphone, camera, notification, overlay, exact alarm, battery optimization, and usage access capabilities in real-time. Full-width decoupled titles and monospace chips prevent truncation, paired with iOS "Enable ›" action pills.',
        icon: CupertinoIcons.lock_shield_fill,
        badgeColor: Color(0xFFFF9500),
        specs:
            'AppPermissionsSettingsPage · Decoupled Titles · Monospace Identifier Chips · iOS Action Pills · Zero Data Leakage',
      ),
      (
        title: 'Global Content Rating Disclosures',
        category: 'FAMILY SAFETY & CERTIFICATIONS',
        headline: 'IARC 3+ Rated. 0/5 Mature Topics Scorecard.',
        desc:
            'Official ratings across global certification bodies (IARC Everyone, ESRB Everyone, PEGI 3, and USK 0). Features a 0/5 mature topics scorecard with Apple soft-tinted squircle glyph badges (softIcon: true).',
        icon: CupertinoIcons.checkmark_shield_fill,
        badgeColor: Color(0xFF30D158),
        specs:
            'ContentRatingSettingsPage · IARC 3+ Certification · Soft-Tinted Squircles · 0/5 Mature Topics Scorecard',
      ),
      (
        title: 'Data Safety Sovereignty Nutrition Card',
        category: 'STORE COMPLIANCE & PRIVACY',
        headline: 'Google Play Disclosures. 100% On-Device Nutrition.',
        desc:
            'Redesigned top disclosure card in a continuous 24pt squircle with whisper-thin borders and 20x20 circular checkmark pills. Verifies 0 KB data collection, zero third-party sharing, and local Isar database encryption.',
        icon: CupertinoIcons.shield_fill,
        badgeColor: Color(0xFF5856D6),
        specs:
            'DataSafetySettingsPage · 24pt Continuous Squircle · 20x20 Checkmark Badges · Isar DB Verification',
      ),
      (
        title: 'Apple HIG Visual Surgery & Typography',
        category: 'ERGONOMICS & DESIGN EXCELLENCE',
        headline: '44pt Touch Targets. Zero Text Truncation.',
        desc:
            'Comprehensive design surgery across NoteKar. Checkpoints bar touch targets reinforced to Apple 44pt minimum, responsive App Icons header withstanding 200% accessibility scaling, and optical SF Pro typography.',
        icon: CupertinoIcons.sparkles,
        badgeColor: Color(0xFFFF2D55),
        specs:
            '44pt Touch Targets · Responsive Icon Header Wrap · Clamped Text Scaler · Zero Truncation · WCAG AA Contrast',
      ),
    ],
    items: [
      '• Quick Settings Tile, Canvas Habits, Media Symmetry, App Permissions & Global Content Rating.',
      '+ Quick Settings Tile: Added FloatingBubbleTileService to toggle floating timer bubble directly from Android notification shade',
      '+ Interactive Bubble Dismissal: Bottom screen "✕" drop-target dismissal with drag-to-delete gesture and quick re-summon via tile or widget',
      '+ Canvas Habit Creator: Added AddEditHabitSheet with custom emoji picker, interval cadences, and deletion confirmation safeguards',
      '+ Media Symmetry: TimelineVoicePlayerPill audio playback and TimelineMediaAttachmentCard photo previews inside NotePreviewSheet',
      '+ App Permissions Dashboard: Added AppPermissionsSettingsPage inspecting all 7 device permissions with decoupled full-width titles and monospace chips',
      '+ Content Rating Disclosures: Added ContentRatingSettingsPage with IARC 3+, ESRB E, PEGI 3, USK 0 certifications and 0/5 mature topics scorecard',
      '+ Data Safety Nutrition Card: Redesigned DataSafetySettingsPage top card with 24pt squircle curvature, 20x20 checkmark pills, and Isar local encryption disclosures',
      '+ App Icons Header: Redesigned AppIconsSettingsPage instruction card with responsive adaptive Wrap header supporting up to 200% font scaling',
      '+ Touch Target Enforcement: Checkpoints quick bar touch targets reinforced to Apple HIG 44pt minimum',
      '+ Pre-commit Code Quality: 100% codebase formatted with dart format, 0 analyzer issues, and 422 passing automated tests',
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
