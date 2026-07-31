import 'package:flutter/material.dart';
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
                title: '${theme.emoji} ${theme.name}',
                subtitle: theme.description,
                color: p.orange,
                trailing: sobrietyMilestoneTheme == theme.id
                    ? Icon(Icons.check_rounded, color: p.accent, size: 20)
                    : null,
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
  });

  final Palette p;
  final String sobrietyMilestoneTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'All 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. Names shown in your current theme.'
                  .localized(context),
        ),
        SettingsGroup(
          p: p,
          children: [
            for (final milestone in kSobrietyMilestones)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: spacing16,
                  vertical: spacing12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            milestone.days.toString(),
                            style: TextStyle(
                              color: p.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'DAYS',
                            style: TextStyle(
                              color: p.orange.withValues(alpha: 0.7),
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getMilestoneName(milestone, sobrietyMilestoneTheme),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            milestone.whyItMatters,
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getMilestoneFlavor(
                              milestone,
                              sobrietyMilestoneTheme,
                            ),
                            style: TextStyle(
                              color: p.orange.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
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
        const SizedBox(height: spacing48),
      ],
    );
  }
}
