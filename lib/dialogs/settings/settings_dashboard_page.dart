import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/daily_wisdom_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/risk_radar_service.dart';
import 'package:notekar/utils/user_rank_service.dart';
import 'package:notekar/widgets/activity_heatmap_widget.dart';
import 'package:notekar/widgets/history_analytics_card.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          _buildDailyWisdomCard(context),
        if (enableSobrietyMode) ...[
          _buildUserRankCard(context),
          _buildSobrietyAnalyticsCard(context),
          _buildRiskRadarCard(context),
          const SizedBox(height: 6),
        ],
        _buildDashboardSectionHeader('Real-time Metrics'),
        ActivitySummaryCard(p: p, entries: entries),
        const SizedBox(height: 8),
        _buildDashboardSectionHeader('Habit Frequency & Trends'),
        RepaintBoundary(
          child: ActivityTrendsCard(p: p, entries: entries),
        ),
        const SizedBox(height: 6),
        RepaintBoundary(
          child: ActivityHeatmapWidget(p: p, entries: entries),
        ),
        const SizedBox(height: 6),
        RepaintBoundary(
          child: ActivityHeatmapCard(p: p, entries: entries),
        ),
        const SizedBox(height: 8),
        _buildDashboardSectionHeader('Correlation Intelligence'),
        RepaintBoundary(
          child: IntelligentInsightsCard(p: p, entries: entries),
        ),
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

    String peakTimeRange = 'None';
    int maxRangeCount = 0;
    rangeCounts.forEach((k, v) {
      if (v > maxRangeCount) {
        maxRangeCount = v;
        peakTimeRange = k;
      }
    });

    final totalRelapses = relapseMoments.length;
    final totalEntries = entries.length;
    final double successRate = totalEntries == 0
        ? 100.0
        : ((totalEntries - totalRelapses) / totalEntries) * 100;
    final successRateString = '${successRate.toStringAsFixed(1)}%';

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: p.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: p.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sobriety Trigger Analysis'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
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
                  '$totalRelapses',
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  'Overall Success',
                  successRateString,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FutureBuilder<int>(
                  future: SharedPreferences.getInstance().then(
                    (prefs) => prefs.getInt('streak_shields') ?? 1,
                  ),
                  builder: (context, snapshot) {
                    final shields = snapshot.data ?? 0;
                    return _buildMetricTile(
                      context,
                      'Streak Shields',
                      shields > 0 ? '$shields Active' : 'None',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskRadarCard(BuildContext context) {
    final radar = RiskRadarService.analyze(entries);
    final isHigh = radar.riskLevel == 'High';
    final cardColor = isHigh
        ? p.red.withValues(alpha: 0.08)
        : p.orange.withValues(alpha: 0.08);
    final accentColor = isHigh ? p.red : p.orange;

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar_rounded, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Intelligent Risk Radar'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${radar.riskLevel} Risk (${radar.riskScore}%)',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            radar.alertMessage.localized(context),
            style: TextStyle(
              color: p.text,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankCard(BuildContext context) {
    final streakDays = _calculateStreakDays();
    final rank = UserRankService.calculateRank(streakDays, entries.length);

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [p.accent.withValues(alpha: 0.12), p.surface2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: p.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rank Level ${rank.rankLevel}'.toUpperCase(),
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rank.rankTitle,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${rank.currentXp} XP',
                style: TextStyle(
                  color: p.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: rank.progressPercent,
              minHeight: 6,
              backgroundColor: p.surface3,
              color: p.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyWisdomCard(BuildContext context) {
    final wisdom = DailyWisdomService.getTodayWisdom();

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface2.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: p.orange, size: 16),
              const SizedBox(width: 6),
              Text(
                'Daily Neuroscience Insight'.localized(context),
                style: TextStyle(
                  color: p.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${wisdom.quote}"',
            style: TextStyle(
              color: p.text,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— ${wisdom.author} (${wisdom.category})',
            style: TextStyle(
              color: p.text3,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreakDays() {
    if (entries.isEmpty) return 0;
    int? maxRelapseTs;
    int minTs = entries.first.timestamp;

    for (final e in entries) {
      if (e.timestamp < minTs) minTs = e.timestamp;
      if (e.note.contains('#relapse') && !e.note.contains('#shielded')) {
        if (maxRelapseTs == null || e.timestamp > maxRelapseTs) {
          maxRelapseTs = e.timestamp;
        }
      }
    }

    final resetTime = DateTime.fromMillisecondsSinceEpoch(
      maxRelapseTs ?? minTs,
    );
    final diff = DateTime.now().difference(resetTime);
    return diff.isNegative ? 0 : diff.inDays;
  }

  Widget _buildMetricTile(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.localized(context).toUpperCase(),
            style: TextStyle(
              color: p.text3,
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
