import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';

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
      version: '4.0.3',
      date: 'June 17, 2026',
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
      items: [
        'Prepared the 2.5.0 release notes and Android release folder structure without building APKs.',
        'Kept the app version aligned for the next release step and preserved the 2.0.0 release history.',
        'Documented the planned release files and SHA-256 packaging approach for the Android APK release.',
      ],
    ),
    (
      version: '2.0.0',
      date: 'May 26, 2026',
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
        const SizedBox(height: spacing64),
      ],
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
  final ({String date, List<String> items, String version}) release;
  final bool isLatest;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          PressableScale(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isLatest
                          ? p.accent.withValues(alpha: 0.12)
                          : p.surface3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isLatest
                          ? Icons.auto_awesome_rounded
                          : Icons.article_rounded,
                      color: isLatest ? p.accent : p.text2,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 11),
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
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (isLatest) ...[
                              const SizedBox(width: 8),
                              SettingsStatusPill(
                                p: p,
                                label: 'New',
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(Icons.chevron_right_rounded, color: p.text3),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: p.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: p.text2,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                      borderRadius: BorderRadius.circular(16),
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
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 9),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: p.accent,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              color: p.text2,
                                              fontSize: 13,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
  final ({String date, List<String> items, String version}) release;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      primary: false,
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: p.accent,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's New",
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'NoteKar ${release.version}',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latest Android changes, fixes, and polish for this build.',
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final item in release.items)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded, color: p.accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: spacing64),
      ],
    );
  }
}
