import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:notekar/utils/l10n_utils.dart';

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

  static const releases = [
    (
      version: '4.0.5',
      date: 'July 22, 2026',
      highlights: [
        'Dedicated Language selector supporting English, Hindi, and Spanish with full l10n support.',
        'Recently Deleted (Trash Bin) view with individual restore and 30-day auto-purge policy.',
        'Optimum contrast-adjusted accent colors dynamically matching Light/Dark/AMOLED themes.',
        'Hardened Factory Reset & Clear Data logic covering trash moments and locale preferences.',
        'Ultra-premium iOS 26 style snappy category transitions with synchronized header cross-fades.',
      ],
      items: [
        'Added: Dedicated Language selection settings page for English, Hindi, and Spanish translation support.',
        'Added: Onboarding welcome sheet language selector for smooth initial setup.',
        'Added: Recently Deleted trash bin section with individual restore, empty trash, and restore all actions.',
        'Added: 30-day auto-purge policy banner for trash bin contents.',
        'Fixed: Dynamic contrast-adjusted accent colors for Light, Dark, and AMOLED themes.',
        'Fixed: Snappy navigation transitions (180ms) with synchronized header title cross-fades.',
        'Fixed: Hardened Factory Reset to purge preferences, active/trash databases, and reset active locales.',
        'Fixed: Redesigned Check for Updates card to be minimal, neutral-colored, and match the iOS 26 style.',
        'Fixed: Localized settings search results indexing and matching for Spanish and Hindi keywords.',
        'Fixed: Localized Guides and Help FAQ items to match the user\'s selected interface language.',
      ],
    ),
    (
      version: '4.0.4',
      date: 'July 20, 2026',
      highlights: [
        'A complete visual overhaul with an iOS-inspired design and fluid adaptive transitions.',
        'Hardened data security with enhanced backup resilience and diagnostic logging.',
        'Next-generation App Widgets and a redesigned, lightning-fast Settings Search.',
        'A centralized Update Center and integrated feedback system to build a better NoteKar.',
        'Intelligent accessibility including global text scaling and high-contrast support.',
      ],
      items: [
        'Modular Refactor: Re-architected core components for improved performance scaling.',
        'Adaptive Engine: Refined intelligence for smoother cross-device UI transitions.',
        'Data Layer: Implemented diagnostic logging and SHA-256 validation for backup integrity.',
        'App Widgets: Rebuilt Android widgets with modern layouts and optimized RemoteViews.',
        'Settings Search: Overhauled search with cached indexing and improved query matching.',
        'Feedback System: Integrated direct support routing with diagnostic attachment support.',
        'Layout: Standardized global padding and standardized typography across all modules.',
        'UX Hardening: Optimized state management for History, Note Input, and Calendar flows.',
        'Build Integrity: Final build 13 with legal compliance integration and stability patches.',
      ],
    ),
    (
      version: '4.0.3',
      date: 'June 17, 2026',
      highlights: [
        'Backup validation before import, with safer checks for damaged JSON and oversized files.',
        'New backup import preview with total counts and settings restoration details.',
        'Crash-safer startup sequencing and timeline profiling markers.',
        'Cached search and calendar lookups for smoother performance.',
      ],
      items: [
        'Moved the app line to 4.0.3 build 12 for the backup and performance hardening release.',
        'Added backup validation before import, with safer checks for damaged JSON, invalid moments, oversized files, and unsupported data.',
        'Added a backup import preview with total moments, notes, export date, new moments, duplicates skipped, and settings to restore.',
        'Made backup import crash-safer by validating and persisting the merge before updating visible app state.',
        'Improved startup sequencing so first paint, App Lock, and non-critical checks are staged more smoothly.',
        'Added timeline profiling markers for startup and backup import work.',
        'Cached Settings search, note search, and calendar date lookups for smoother repeated use.',
        'Added focused tests for backup validation, corrupted files, duplicate handling, and dry-run summaries.',
      ],
    ),

    (
      version: '4.0.2',
      date: 'June 12, 2026',
      highlights: [
        'Optional home menu icon motion tied to Reduce Motion.',
        'Dependency-aware Settings behavior for clearer guidance.',
        'Refined bottom sheets and swipe-delete polish.',
      ],
      items: [
        'Moved the app line to 4.0.2 build 11 for the polish release.',
        'Made home menu icon motion optional, disabled by default, and tied it to Reduce Motion.',
        'Added dependency-aware Settings behavior so unavailable controls explain what must be enabled first.',
        'Refined History and Settings bottom sheets, History delete feedback, and swipe-delete polish.',
        'Fixed App Lock immediate timing so Android screen-lock confirmation does not loop inside the app.',
        'Added clearer feedback while Android applies launcher icon changes.',
      ],
    ),

    (
      version: '4.0.1',
      date: 'June 1, 2026',
      highlights: [
        'Polish release with home menu icon motion options.',
        'Dependency-aware settings and refined bottom sheets.',
      ],
      items: [
        'Moved the app line to 4.0.1 build 11 for the polish release.',
        'Made home menu icon motion optional, disabled by default, and tied it to Reduce Motion.',
        'Added dependency-aware Settings behavior so unavailable controls explain what must be enabled first.',
        'Refined History and Settings bottom sheets, History delete feedback, and swipe-delete polish.',
        'Fixed App Lock immediate timing so Android screen-lock confirmation does not loop inside the app.',
        'Added clearer feedback while Android applies launcher icon changes.',
      ],
    ),
    (
      version: '4.0.0',
      date: 'June 1, 2026',
      highlights: [
        'Major redesign with clearer top-level Settings sections.',
        'Real Android app icon switching support.',
        'Improved Privacy & Security with App Lock enhancements.',
        'Note validation and visible character counter.',
      ],
      items: [
        'Moved the app line to 4.0.0 build 9 for the final release package.',
        'Reduced Settings to clearer top-level sections: Personalization, Logging, Privacy & Security, Data & Backup, Updates, and Advanced.',
        'Added real Android app icon switching with Default, Black, Blue, Gold, Green, Orange, and Red launcher icons.',
        'Moved App Lock under Privacy & Security with background-only lock timing and clearer Android screen-lock wording.',
        'Added note validation, a visible character counter, full-note viewing from History, and smoother History scroll-to-top behavior.',
        'Cleaned Backup & Export by moving passive backup status cards into a second-level Backup Status page.',
        'Polished release privacy and security behavior by avoiding clipboard fallback for failed exports and requiring HTTPS for remote notice links.',
      ],
    ),
    (
      version: '3.6.0',
      date: 'May 27, 2026',
      highlights: [
        'Restored compact History cards for faster scanning.',
        'Accessibility improvements for Quick Actions.',
      ],
      items: [
        'Moved the app line to 3.6.0 build 8 for the next release wave.',
        'Restored compact History to the denser 3.0.0-style cards for faster scanning.',
        'Kept History as a simple normal / compact switch instead of splitting it into more modes.',
        'Moved Quick Actions out of Privacy and into Accessibility so launcher shortcuts sit with interaction controls.',
        'Kept the calmer action-color dots, haptic style, backup reminder, and privacy lock work from the previous polish pass.',
      ],
    ),
    (
      version: '3.5.0',
      date: 'May 27, 2026',
      highlights: [
        'Theme-aware bottom navigation surface.',
        'Curated Action Color support (Blue, Green, Purple, etc.).',
        'Privacy Lock using Android system credentials.',
        'Expanded Android app shortcuts.',
      ],
      items: [
        'Moved the app line to 3.5.0 build 7 for the next release cycle.',
        'Added a theme-aware bottom navigation surface so the home toolbar follows Light, Dark, and AMOLED themes more naturally.',
        'Fixed Larger Text so it respects Android text scaling and never shrinks text when the system font is already larger.',
        'Added curated Action Color support with Blue, Green, Purple, Pink, Orange, and Graphite accents while keeping destructive, success, and warning colors intentional.',
        'Added Haptic Style, compact History, Auto Backup Reminder, Data Health, and Quick Actions controls.',
        'Added Privacy Lock using Android system credentials, with guidance to add a system lock before enabling it.',
        'Expanded Android app shortcuts to Single, IN, OUT, and Note actions.',
        'Simplified Accessibility by replacing duplicate haptics switches with Off, Light, and Standard haptic styles.',
      ],
    ),
    (
      version: '3.0.0',
      date: 'May 27, 2026',
      highlights: [
        'Complete Settings reshuffle for better clarity.',
        'Dedicated Reset page with Factory Reset flow.',
        'Privacy page with local-storage and data-use transparency.',
        'Backup import merge logic instead of replace.',
      ],
      items: [
        'Moved the current app line to 3.0.0 build 6 with refreshed What\'s New and changelog entries.',
        'Reshuffled Settings into clearer categories: Display, Capture, Moments, Backup & Export, Updates & Notices, Privacy & Security, Accessibility, Reset, and Diagnostics.',
        'Moved all reset actions into a dedicated Reset page with Reset Settings Only, Reset All Data, Factory Reset, and a guidance note.',
        'Added a full-screen Factory Reset flow with real progress, a calm completion state, and a Start button before the welcome setup appears.',
        'Made Settings navigation stack-aware, so nested pages go back to their previous section before closing the sheet.',
        'Improved offline-first startup by delaying network notice checks until the app has loaded and connectivity is known.',
        'Refined History with true compact rows, a scroll-to-top control, smoother delete removal, better swipe-delete background, and Single moments in duration selection.',
        'Changed backup import to merge new moments with existing local history instead of replacing the current device data.',
        'Added a dedicated Privacy page with local-storage details, limited network-use notes, no analytics/telemetry disclosure, and planned encryption/Drive backup guidance.',
        'Cleaned Diagnostics with clearer labels, copyable support details, and Android backup visibility.',
        'Fixed welcome theme selection, removed duplicate Minimal Clock controls, and kept Show Seconds as the single clock display setting.',
        'Added Note-Focused Hold so long press can be reserved for moments that include context.',
        'Reduced noisy setting-change notification pills while keeping meaningful feedback for updates, exports, connectivity, and errors.',
        'Refined Settings row alignment so icons sit with titles, and restored compact History card radius to avoid red swipe background peeking through.',
      ],
    ),
    (
      version: '2.5.0',
      date: 'May 27, 2026',
      highlights: [
        'Preparation for major release wave.',
        'Documented planned release files and security approach.',
      ],
      items: [
        'Prepared the 2.5.0 release notes and Android release folder structure without building APKs.',
        'Kept the app version aligned for the next release step and preserved the 2.0.0 release history.',
        'Documented the planned release files and SHA-256 packaging approach for the Android APK release.',
      ],
    ),
    (
      version: '2.0.0',
      date: 'May 26, 2026',
      highlights: [
        'iOS-inspired Android redesign with grouped Settings.',
        'GitHub Releases update checks and remote notices.',
        'Accessibility and customization options for haptics and motion.',
      ],
      items: [
        'Introduced the iOS-inspired Android redesign with grouped Settings pages, cleaner sheets, refined toolbar controls, and calmer colors.',
        'Added GitHub Releases update checks, remote GitHub notice support, notification routing actions, What\'s New, and Changelog pages.',
        'Added accessibility and customization options for haptics, motion, larger text, high contrast, compact history, button labels, and large controls.',
        'Improved Android backup visibility, export shortcuts, backup import, diagnostics, typed reset confirmation, and release metadata.',
        'Refined history filters, section headers, swipe-delete visuals, note indicators, and compact review controls.',
      ],
    ),
    (
      version: '1.0.0',
      date: 'May 25, 2026',
      highlights: [
        'Native Android launch with private offline storage.',
        'Note capture, history filters, and backup import.',
      ],
      items: [
        'Launched the native Android rewrite with private offline moment storage.',
        'Added Single and Two-Way logging, note capture, history filters, exports, and backup import.',
        'Added settings for themes, default startup mode, and tap delay control.',
      ],
    ),
  ];

  @override
  State<ChangelogDialog> createState() => _ChangelogDialogState();
}

class ChangelogSettingsPage extends StatefulWidget {
  const ChangelogSettingsPage({
    super.key,
    required this.p,
    required this.latestOnly,
  });

  final Palette p;
  final bool latestOnly;

  @override
  State<ChangelogSettingsPage> createState() => _ChangelogSettingsPageState();
}

class _ChangelogSettingsPageState extends State<ChangelogSettingsPage> {
  final Set<int> _expanded = {0};

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final visible = widget.latestOnly
        ? ChangelogDialog.releases.take(1).toList()
        : ChangelogDialog.releases;
    if (widget.latestOnly) {
      return _WhatsNewPanel(p: p, release: visible.first);
    }
    return Column(
      children: [
        for (var index = 0; index < visible.length; index++)
          ChangelogReleaseCard(
            p: p,
            release: visible[index],
            isLatest: index == 0,
            expanded: _expanded.contains(index),
            onTap: () => setState(() {
              if (_expanded.contains(index)) {
                _expanded.remove(index);
              } else {
                _expanded.add(index);
              }
            }),
          ),
      ],
    );
  }
}

class _ChangelogItemRow extends StatelessWidget {
  const _ChangelogItemRow({
    required this.p,
    required this.text,
    required this.isLatest,
  });

  final Palette p;
  final String text;
  final bool isLatest;

  ({IconData icon, Color color}) _getItemStyle() {
    final lower = text.trim().toLowerCase();
    if (lower.startsWith('add') || lower.startsWith('added') || lower.startsWith('new') || lower.startsWith('create')) {
      return (icon: Icons.add_rounded, color: p.green);
    }
    if (lower.startsWith('delete') || lower.startsWith('deleted') || lower.startsWith('remove')) {
      return (icon: Icons.remove_rounded, color: p.red);
    }
    if (lower.startsWith('fix') || lower.startsWith('fixed') || lower.startsWith('patch') || lower.startsWith('resolve')) {
      return (icon: Icons.auto_awesome_rounded, color: p.orange);
    }
    if (lower.startsWith('update') || lower.startsWith('refactor') || lower.startsWith('improve') || lower.startsWith('moved')) {
      return (icon: Icons.published_with_changes_rounded, color: p.accent);
    }
    return (icon: Icons.check_rounded, color: p.accent);
  }

  @override
  Widget build(BuildContext context) {
    final style = _getItemStyle();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              style.icon,
              color: style.color,
              size: 11,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.text2,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChangelogReleaseCard extends StatelessWidget {
  const ChangelogReleaseCard({
    super.key,
    required this.p,
    required this.release,
    required this.isLatest,
    required this.expanded,
    required this.onTap,
  });

  final Palette p;
  final ({String date, List<String> items, List<String> highlights, String version}) release;
  final bool isLatest;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          PressableScale(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      color: isLatest
                          ? p.accent.withValues(alpha: 0.14)
                          : p.surface3,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      isLatest
                          ? Icons.auto_awesome_rounded
                          : Icons.article_rounded,
                      color: isLatest ? p.accent : p.text2,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Version ${release.version}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (isLatest) ...[
                              const SizedBox(width: 8),
                              SettingsStatusPill(
                                p: p,
                                label: 'LATEST',
                                color: p.accent,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          release.date,
                          style: TextStyle(
                            color: p.text3,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: p.text3.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(color: p.border, height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      for (final item in release.items)
                        _ChangelogItemRow(
                          p: p,
                          text: item,
                          isLatest: isLatest,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}


class _ChangelogDialogState extends State<ChangelogDialog> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final visible = widget.latestOnly
        ? ChangelogDialog.releases.take(1).toList()
        : ChangelogDialog.releases;
    final maxHeight = math.min(MediaQuery.sizeOf(context).height * 0.62, 520.0);
    return AppSheet(
      p: p,
      title: widget.latestOnly ? "What's New" : 'Changelog',
      blur: widget.blur,
      largeText: widget.largeText,
      removeBottomPadding: true,
      child: SizedBox(
        width: 410,
        height: maxHeight,
        child: widget.latestOnly
            ? _WhatsNewPanel(p: p, release: visible.first)
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final release = visible[index];
                  final expanded = _expanded.contains(index);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: p.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (expanded) {
                                _expanded.remove(index);
                              } else {
                                _expanded.add(index);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? p.accent.withValues(alpha: 0.14)
                                        : p.surface3,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    index == 0
                                        ? Icons.auto_awesome_rounded
                                        : Icons.article_rounded,
                                    color: index == 0 ? p.accent : p.text2,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Version ${release.version}',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: p.text,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          if (index == 0) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: p.accent.withValues(
                                                  alpha: 0.14,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                'New',
                                                style: TextStyle(
                                                  color: p.accent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        release.date,
                                        style: TextStyle(
                                          color: p.text3,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: expanded ? 0.25 : 0,
                                  duration: const Duration(milliseconds: 160),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: p.text3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: Column(
                              children: [
                                Divider(color: p.border, height: 1),
                                const SizedBox(height: 10),
                                for (final item in release.items)
                                  _ChangelogItemRow(
                                    p: p,
                                    text: item,
                                    isLatest: index == 0,
                                  ),
                              ],
                            ),
                          ),
                          crossFadeState: expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 180),
                          sizeCurve: Curves.easeOutCubic,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _WhatsNewPanel extends StatelessWidget {
  const _WhatsNewPanel({required this.p, required this.release});

  final Palette p;
  final ({String date, List<String> items, List<String> highlights, String version}) release;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      primary: false,
      physics: const BouncingScrollPhysics(),
      children: [
        // iOS 26 Hero Header Card
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: p.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's New in NoteKar".localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        SettingsStatusPill(
                          p: p,
                          label: 'v${release.version}',
                          color: p.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          release.date,
                          style: TextStyle(
                            color: p.text3,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // iOS 26 Feature Cards List
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            for (var i = 0; i < release.highlights.length; i++) ...[
              Builder(
                builder: (context) {
                  final text = release.highlights[i];
                  
                  String headline = '';
                  String body = text;
                  if (text.contains(' with ')) {
                    final parts = text.split(' with ');
                    headline = parts.first;
                    body = 'With ${parts.sublist(1).join(' with ')}';
                  } else if (text.contains(' including ')) {
                    final parts = text.split(' including ');
                    headline = parts.first;
                    body = 'Including ${parts.sublist(1).join(' including ')}';
                  } else if (text.contains(' and ')) {
                    final parts = text.split(' and ');
                    headline = parts.first;
                    body = 'And ${parts.sublist(1).join(' and ')}';
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: p.accent.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                            border: Border.all(color: p.accent.withValues(alpha: 0.25)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (headline.isNotEmpty) ...[
                                Text(
                                  headline,
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                body,
                                style: TextStyle(
                                  color: headline.isNotEmpty ? p.text2 : p.text,
                                  fontSize: 13,
                                  height: 1.35,
                                  fontWeight: headline.isNotEmpty ? FontWeight.w400 : FontWeight.w500,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
