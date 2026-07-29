import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/history_analytics_card.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class SettingsDashboardPage extends StatelessWidget {
  const SettingsDashboardPage({
    super.key,
    required this.p,
    required this.entries,
    required this.enableSobrietyMode,
    required this.onLogNow,
    required this.onLearnMoreBeta,
  });

  final Palette p;
  final List<Moment> entries;
  final bool enableSobrietyMode;
  final VoidCallback onLogNow;
  final VoidCallback onLearnMoreBeta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Live activity tracking dashboard featuring real-time metric analysis, habit tracking grids, activity trends, and correlation intelligence calculated from your moments.'
                  .localized(context),
        ),
        AnomalyAlertCard(p: p, entries: entries, onLogNow: onLogNow),
        if (entries.isNotEmpty &&
            DateTime.now()
                    .difference(
                      DateTime.fromMillisecondsSinceEpoch(
                        entries.first.timestamp,
                      ),
                    )
                    .inHours >=
                48)
          const SizedBox(height: 6),
        if (enableSobrietyMode) ...[
          _buildSobrietyAnalyticsCard(context),
          const SizedBox(height: 6),
        ],
        _buildDashboardSectionHeader('Real-time Metrics'),
        ActivitySummaryCard(p: p, entries: entries),
        const SizedBox(height: 8),
        _buildDashboardSectionHeader('Habit Frequency & Trends'),
        ActivityTrendsCard(p: p, entries: entries),
        const SizedBox(height: 6),
        ActivityHeatmapCard(p: p, entries: entries),
        const SizedBox(height: 8),
        _buildDashboardSectionHeader('Correlation Intelligence'),
        IntelligentInsightsCard(p: p, entries: entries),
        SettingsBetaNote(
          p: p,
          text: 'The current features on this page are under Beta stage.'
              .localized(context),
          onLearnMore: onLearnMoreBeta,
        ),
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

  Widget _buildDashboardSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 16, bottom: 6),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, color: p.accent, size: 15),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: p.text3,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
