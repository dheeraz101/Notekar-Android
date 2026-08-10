import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/shareable_milestone_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/sobriety_milestones.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class SobrietyCompanionSettingsPage extends StatelessWidget {
  const SobrietyCompanionSettingsPage({
    super.key,
    required this.p,
    required this.enableSobrietyMode,
    required this.sobrietyResetType,
    required this.sobrietyCustomStartMs,
    required this.sobrietyMilestoneTheme,
    required this.onEnableSobrietyModeChanged,
    required this.onSobrietyResetTypeChanged,
    required this.onSobrietyCustomStartMsChanged,
    required this.onOpenCategory,
    required this.onSelectStartDate,
  });

  final Palette p;
  final bool enableSobrietyMode;
  final String sobrietyResetType;
  final int? sobrietyCustomStartMs;
  final String sobrietyMilestoneTheme;

  final ValueChanged<bool> onEnableSobrietyModeChanged;
  final ValueChanged<String> onSobrietyResetTypeChanged;
  final ValueChanged<int?> onSobrietyCustomStartMsChanged;
  final void Function(String category, {required String parent}) onOpenCategory;
  final Future<DateTime?> Function(BuildContext context, DateTime initial)
  onSelectStartDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Privacy-first streak tracking and relapse diary. All data stays on your device. Existing logs are never altered.'
                  .localized(context),
        ),
        SettingsGroup(
          p: p,
          title: 'Streak Mode'.localized(context),
          children: [
            SettingsSwitchRow(
              p: p,
              icon: Icons.self_improvement_rounded,
              title: 'Enable Sobriety Mode'.localized(context),
              subtitle:
                  'Adds a clean streak card to your home screen and adapts home screen widgets.'
                      .localized(context),
              color: p.orange,
              value: enableSobrietyMode,
              onChanged: onEnableSobrietyModeChanged,
            ),
          ],
        ),
        if (enableSobrietyMode) ...[
          SettingsPageDescription(
            p: p,
            text:
                'Your home screen will show a live streak card with milestone badges. The home widget will adapt to show RESET and DIARY buttons.'
                    .localized(context),
          ),
          const SizedBox(height: 12),
          SettingsGroup(
            p: p,
            title: 'Streak Reset Logic'.localized(context),
            children: [
              SettingsSwitchRow(
                p: p,
                icon: Icons.restart_alt_rounded,
                title: 'Reset on Relapse Tag Only'.localized(context),
                subtitle:
                    'Only moments tagged #relapse reset the streak. Turn off to reset on any new log.'
                        .localized(context),
                color: p.orange,
                value: sobrietyResetType == 'relapse',
                onChanged: (value) {
                  onSobrietyResetTypeChanged(value ? 'relapse' : 'any');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingsGroup(
            p: p,
            title: 'Trigger Diary'.localized(context),
            children: [
              SettingsRow(
                p: p,
                icon: Icons.analytics_rounded,
                title: 'Trigger Analysis'.localized(context),
                subtitle:
                    'View your relapse pattern insights, top moods, and peak vulnerability windows.'
                        .localized(context),
                color: p.orange,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: p.text3,
                  size: 20,
                ),
                onTap: () => onOpenCategory(
                  'Trigger Analysis',
                  parent: 'Sobriety Companion',
                ),
              ),
            ],
          ),
          SettingsPageDescription(
            p: p,
            text:
                'When logging a moment with Sobriety Mode on, you can tag mood (Bored, Anxious, Lonely...) and trigger (Social Media, Late Night...). These are stored as hashtags in the note for full backwards compatibility.'
                    .localized(context),
          ),
          const SizedBox(height: 12),
          SettingsGroup(
            p: p,
            title: 'Custom Start Date'.localized(context),
            children: [
              SettingsRow(
                p: p,
                icon: Icons.calendar_today_rounded,
                title: 'Set Sobriety Start Date'.localized(context),
                subtitle: sobrietyCustomStartMs != null
                    ? '${"From".localized(context)} ${datePretty(sobrietyCustomStartMs!)} ${"at".localized(context)} ${timeOnly(sobrietyCustomStartMs!).substring(0, 5)}'
                    : 'Not set: using last log or relapse tag'.localized(
                        context,
                      ),
                color: p.orange,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sobrietyCustomStartMs != null)
                      GestureDetector(
                        onTap: () {
                          onSobrietyCustomStartMsChanged(null);
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: p.text3,
                          size: 18,
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: p.text3, size: 20),
                  ],
                ),
                onTap: () async {
                  final now = DateTime.now();
                  final initialDateTime = sobrietyCustomStartMs != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                          sobrietyCustomStartMs!,
                        )
                      : now.subtract(const Duration(days: 7));
                  final picked = await onSelectStartDate(
                    context,
                    initialDateTime,
                  );
                  if (picked != null) {
                    onSobrietyCustomStartMsChanged(
                      picked.millisecondsSinceEpoch,
                    );
                  }
                },
              ),
            ],
          ),
          SettingsPageDescription(
            p: p,
            text:
                'Were you already clean before installing? Set your actual start date here. This overrides automatic detection from your logs.'
                    .localized(context),
          ),
          const SizedBox(height: 12),
          SettingsGroup(
            p: p,
            title: 'Milestone Theme'.localized(context),
            children: [
              SettingsRow(
                p: p,
                icon: Icons.palette_rounded,
                title: 'Theme Style'.localized(context),
                subtitle: () {
                  final t = kMilestoneThemes.firstWhere(
                    (t) => t.id == sobrietyMilestoneTheme,
                    orElse: () => kMilestoneThemes.first,
                  );
                  return '${t.emoji} ${t.name.localized(context)}: ${t.description.localized(context)}';
                }(),
                color: p.orange,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: p.text3,
                  size: 20,
                ),
                onTap: () => onOpenCategory(
                  'Milestone Theme',
                  parent: 'Sobriety Companion',
                ),
              ),
              SettingsRow(
                p: p,
                icon: Icons.emoji_events_rounded,
                title: 'View All Milestones'.localized(context),
                subtitle:
                    'See all 21 milestones with descriptions from day 1 to 10 years.'
                        .localized(context),
                color: p.orange,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: p.text3,
                  size: 20,
                ),
                onTap: () =>
                    onOpenCategory('Milestones', parent: 'Sobriety Companion'),
              ),
            ],
          ),
        ],
        const SizedBox(height: spacing48),
      ],
    );
  }
}

class TriggerAnalysisPage extends StatelessWidget {
  const TriggerAnalysisPage({
    super.key,
    required this.p,
    required this.entries,
  });

  final Palette p;
  final List<Moment> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Offline analysis of your logged relapse moments. No data leaves your device.'
                  .localized(context),
        ),
        _buildSobrietyAnalyticsCard(context),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildSobrietyAnalyticsCard(BuildContext context) {
    final relapseMoments = entries
        .where((e) => e.note.contains('#relapse'))
        .toList();
    if (relapseMoments.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
        padding: const EdgeInsets.all(spacing16),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
        ),
        child: Column(
          children: [
            Icon(Icons.spa_rounded, color: p.accent, size: 28),
            const SizedBox(height: 8),
            Text(
              'No relapses recorded yet!'.localized(context),
              style: TextStyle(
                color: p.text,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your clean streak is active and running.'.localized(context),
              style: TextStyle(color: p.text2, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final Map<String, int> triggerCounts = {};
    final Map<String, int> moodCounts = {};
    final Map<int, int> hourCounts = {};

    for (var m in relapseMoments) {
      final note = m.note;
      final triggerMatch = RegExp(r'#trigger:(\w+)').firstMatch(note);
      if (triggerMatch != null) {
        final t = triggerMatch.group(1)!;
        triggerCounts[t] = (triggerCounts[t] ?? 0) + 1;
      }
      final moodMatch = RegExp(r'#mood:(\w+)').firstMatch(note);
      if (moodMatch != null) {
        final md = moodMatch.group(1)!;
        moodCounts[md] = (moodCounts[md] ?? 0) + 1;
      }
      final dt = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
      final hour = dt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    String topTrigger = 'None';
    int maxTriggerCount = 0;
    triggerCounts.forEach((k, v) {
      if (v > maxTriggerCount) {
        maxTriggerCount = v;
        topTrigger = k.replaceAll('_', ' ').toUpperCase();
      }
    });

    String topMood = 'None';
    int maxMoodCount = 0;
    moodCounts.forEach((k, v) {
      if (v > maxMoodCount) {
        maxMoodCount = v;
        topMood = k.toUpperCase();
      }
    });

    final Map<String, int> rangeCounts = {
      'Morning': 0,
      'Afternoon': 0,
      'Evening': 0,
      'Night': 0,
    };
    hourCounts.forEach((h, count) {
      if (h >= 5 && h < 12) {
        rangeCounts['Morning'] = rangeCounts['Morning']! + count;
      } else if (h >= 12 && h < 17) {
        rangeCounts['Afternoon'] = rangeCounts['Afternoon']! + count;
      } else if (h >= 17 && h < 21) {
        rangeCounts['Evening'] = rangeCounts['Evening']! + count;
      } else {
        rangeCounts['Night'] = rangeCounts['Night']! + count;
      }
    });

    String peakTimeRange = 'Night';
    int maxRangeCount = 0;
    rangeCounts.forEach((k, v) {
      if (v > maxRangeCount) {
        maxRangeCount = v;
        peakTimeRange = k;
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing8,
      ),
      padding: const EdgeInsets.all(spacing16),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: p.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sobriety Trigger Analysis'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  'Total Relapses',
                  '${relapseMoments.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(context, 'Top Trigger', topTrigger),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildMetricTile(context, 'Top Mood', topMood)),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context,
                  'Peak Risk Window',
                  peakTimeRange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.localized(context).toUpperCase(),
            style: TextStyle(
              color: p.text2,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.localized(context),
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class MilestoneThemePage extends StatelessWidget {
  const MilestoneThemePage({
    super.key,
    required this.p,
    required this.sobrietyMilestoneTheme,
    required this.onThemeChanged,
  });

  final Palette p;
  final String sobrietyMilestoneTheme;
  final ValueChanged<String> onThemeChanged;

  IconData _getThemeIcon(String id) {
    return switch (id) {
      'science' => CupertinoIcons.lab_flask,
      'warrior' => CupertinoIcons.shield,
      'navy' => CupertinoIcons.compass,
      'clan' => CupertinoIcons.flag,
      'ancient' => CupertinoIcons.calendar,
      'samurai' => CupertinoIcons.shield_fill,
      'space' => CupertinoIcons.paperplane,
      'kingdom' => CupertinoIcons.person_2,
      'monk' => CupertinoIcons.person,
      'phoenix' => CupertinoIcons.flame,
      'animals' => CupertinoIcons.paw,
      'pokemon' || 'jjk' => CupertinoIcons.bolt,
      'onepiece' || 'bleach' => CupertinoIcons.exclamationmark_shield,
      'naruto' || 'vinland' || 'demonslayer' => CupertinoIcons.waveform,
      'ben10' => CupertinoIcons.time,
      'aot' => CupertinoIcons.square_grid_2x2,
      'mha' || 'fma' || 'dbz' => CupertinoIcons.infinite,
      'codegeass' || 'deathnote' => CupertinoIcons.eye,
      'gintama' || 'hxh' => CupertinoIcons.sportscourt,
      'sololeveling' || 'starwars' => CupertinoIcons.sparkles,
      'rpg' || 'tech' => CupertinoIcons.hammer,
      'chess' => CupertinoIcons.gamecontroller,
      _ => CupertinoIcons.star,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Choose the narrative style for your milestone names. Each theme is psychologically curated to match a different self-image and motivation style.'
                  .localized(context),
        ),
        SettingsGroup(
          p: p,
          children: [
            for (final theme in kMilestoneThemes)
              SettingsRow(
                p: p,
                icon: _getThemeIcon(theme.id),
                title: theme.name,
                subtitle: theme.description,
                color: p.orange,
                trailing: sobrietyMilestoneTheme == theme.id
                    ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                    : const SizedBox.shrink(),
                onTap: () => onThemeChanged(theme.id),
              ),
          ],
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}

class MilestonesPage extends StatelessWidget {
  const MilestonesPage({
    super.key,
    required this.p,
    required this.sobrietyMilestoneTheme,
    required this.entries,
    required this.sobrietyCustomStartMs,
    required this.sobrietyResetType,
  });

  final Palette p;
  final String sobrietyMilestoneTheme;
  final List<Moment> entries;
  final int? sobrietyCustomStartMs;
  final String sobrietyResetType;

  Duration _getSobrietyDuration() {
    if (sobrietyCustomStartMs != null) {
      final diff = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(sobrietyCustomStartMs!),
      );
      return diff.isNegative ? Duration.zero : diff;
    }
    if (entries.isEmpty) return Duration.zero;
    DateTime? resetTime;
    if (sobrietyResetType == 'relapse') {
      final relapseMoments = entries.where(
        (e) => e.note.contains('#relapse') && !e.note.contains('#shielded'),
      );
      if (relapseMoments.isEmpty) {
        final minTimestamp = entries
            .map((e) => e.timestamp)
            .reduce((a, b) => a < b ? a : b);
        resetTime = DateTime.fromMillisecondsSinceEpoch(minTimestamp);
      } else {
        final maxTimestamp = relapseMoments
            .map((e) => e.timestamp)
            .reduce((a, b) => a > b ? a : b);
        resetTime = DateTime.fromMillisecondsSinceEpoch(maxTimestamp);
      }
    } else {
      final maxTimestamp = entries
          .map((e) => e.timestamp)
          .reduce((a, b) => a > b ? a : b);
      resetTime = DateTime.fromMillisecondsSinceEpoch(maxTimestamp);
    }
    final diff = DateTime.now().difference(resetTime);
    return diff.isNegative ? Duration.zero : diff;
  }

  void _showMilestoneDetails(
    BuildContext context,
    SobrietyMilestoneEntry milestone,
  ) {
    final theme = sobrietyMilestoneTheme;
    final name = getMilestoneName(milestone, theme);
    final flavor = getMilestoneFlavor(milestone, theme);

    showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close details',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => AppSheet(
        p: p,
        title: 'Milestone Peak'.localized(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: p.orange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.terrain_rounded, color: p.orange, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Target: ${milestone.dayLabel}'.localized(context),
                        style: TextStyle(
                          color: p.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Neuroscience & Growth'.localized(context),
              style: TextStyle(
                color: p.text2,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              milestone.whyItMatters.localized(context),
              style: TextStyle(color: p.text, fontSize: 13, height: 1.45),
            ),
            if (flavor.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Theme Description'.localized(context),
                style: TextStyle(
                  color: p.text2,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                flavor.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: p.text,
                        side: BorderSide(color: p.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showGeneralDialog<void>(
                          context: context,
                          barrierColor: Colors.black.withValues(alpha: 0.42),
                          barrierDismissible: true,
                          barrierLabel: 'Share Milestone',
                          transitionDuration: const Duration(milliseconds: 150),
                          pageBuilder: (_, _, _) => ShareableMilestoneSheet(
                            p: p,
                            milestoneTitle: name,
                            dayLabel: milestone.dayLabel,
                            streakDays: _getSobrietyDuration().inDays,
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.share, size: 16),
                      label: Text(
                        'Share Card'.localized(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: p.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Dismiss'.localized(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = _getSobrietyDuration();
    final unlockedCount = kSobrietyMilestones
        .where((m) => duration.inDays >= m.days)
        .length;

    double getCenterX(int index, double width) {
      final rem = index % 3;
      if (rem == 0) return width / 2;
      if (rem == 1) return width * 0.25;
      return width * 0.75;
    }

    double getCenterY(int index) {
      return index * 130.0 + 64.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Climb the sobriety mountain peaks. Tap any peak to discover its physical growth timeline and psychological rewards.'
                  .localized(context),
        ),
        const SizedBox(height: spacing12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final totalHeight = kSobrietyMilestones.length * 130.0 + 80.0;
            return SizedBox(
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _TrailConnectorPainter(
                        p: p,
                        count: kSobrietyMilestones.length,
                        unlockedCount: unlockedCount,
                      ),
                    ),
                  ),
                  for (int i = 0; i < kSobrietyMilestones.length; i++) ...[
                    (() {
                      final milestone = kSobrietyMilestones[i];
                      final unlocked = duration.inDays >= milestone.days;
                      final isCurrentNext = i == unlockedCount;
                      final cx = getCenterX(i, width);
                      final cy = getCenterY(i);
                      final nodeWidth = isCurrentNext ? 76.0 : 64.0;

                      return Positioned(
                        left: cx - 60.0,
                        top: cy - nodeWidth / 2,
                        child: Container(
                          width: 120,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _showMilestoneDetails(context, milestone),
                                child: Container(
                                  width: nodeWidth,
                                  height: nodeWidth,
                                  decoration: BoxDecoration(
                                    color: unlocked ? p.orange : p.surface3,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isCurrentNext
                                          ? p.orange
                                          : (unlocked ? p.orange : p.border),
                                      width: isCurrentNext ? 4 : 2,
                                    ),
                                    boxShadow: unlocked
                                        ? [
                                            BoxShadow(
                                              color: p.orange.withValues(
                                                alpha: 0.35,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: unlocked
                                      ? Text(
                                          milestone.days >= 365
                                              ? '${(milestone.days / 365).round()}Y'
                                              : '${milestone.days}d',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        )
                                      : (isCurrentNext
                                            ? Icon(
                                                Icons.star_rounded,
                                                color: p.orange,
                                                size: 24,
                                              )
                                            : Icon(
                                                Icons.lock_rounded,
                                                color: p.text3,
                                                size: 18,
                                              )),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 100,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: p.surface2.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: p.border.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  getMilestoneName(
                                    milestone,
                                    sobrietyMilestoneTheme,
                                  ),
                                  style: TextStyle(
                                    color: unlocked ? p.text : p.text3,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }()),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}

class _TrailConnectorPainter extends CustomPainter {
  _TrailConnectorPainter({
    required this.p,
    required this.count,
    required this.unlockedCount,
  });

  final Palette p;
  final int count;
  final int unlockedCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paintActive = Paint()
      ..color = p.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final paintInactive = Paint()
      ..color = p.border.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    double getCenterX(int index, double width) {
      final rem = index % 3;
      if (rem == 0) return width / 2;
      if (rem == 1) return width * 0.25;
      return width * 0.75;
    }

    double getCenterY(int index) {
      return index * 130.0 + 64.0;
    }

    for (int i = 0; i < count - 1; i++) {
      final x1 = getCenterX(i, size.width);
      final y1 = getCenterY(i);
      final x2 = getCenterX(i + 1, size.width);
      final y2 = getCenterY(i + 1);

      final path = Path()
        ..moveTo(x1, y1)
        ..cubicTo(x1, (y1 + y2) / 2, x2, (y1 + y2) / 2, x2, y2);

      final active = i < unlockedCount - 1;
      canvas.drawPath(path, active ? paintActive : paintInactive);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailConnectorPainter oldDelegate) =>
      oldDelegate.unlockedCount != unlockedCount || oldDelegate.p != p;
}
