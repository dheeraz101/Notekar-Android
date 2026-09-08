import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/daily_wisdom_service.dart';
import 'package:notekar/utils/dashboard_metrics_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/life_audit_service.dart';
import 'package:notekar/utils/risk_radar_service.dart';
import 'package:notekar/utils/user_rank_service.dart';
import 'package:notekar/widgets/executive_dashboard_widgets.dart';
import 'package:notekar/widgets/history_analytics_card.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDashboardPage extends StatefulWidget {
  const SettingsDashboardPage({
    super.key,
    required this.p,
    required this.entries,
    required this.enableSobrietyMode,
    required this.onLogNow,
    required this.onLearnMoreBeta,
    this.onOpenLifeAudit,
  });

  final Palette p;
  final List<Moment> entries;
  final bool enableSobrietyMode;
  final VoidCallback onLogNow;
  final VoidCallback onLearnMoreBeta;
  final VoidCallback? onOpenLifeAudit;

  @override
  State<SettingsDashboardPage> createState() => _SettingsDashboardPageState();
}

class _SettingsDashboardPageState extends State<SettingsDashboardPage> {
  DashboardTimeframe _timeframe = DashboardTimeframe.week;

  Palette get p => widget.p;

  List<Moment> get entries => widget.entries;

  bool get enableSobrietyMode => widget.enableSobrietyMode;

  @override
  Widget build(BuildContext context) {
    final dashboardData = DashboardMetricsService.calculate(
      entries: entries,
      timeframe: _timeframe,
      p: p,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Executive activity intelligence hub featuring time-slot rhythm, focus tag distribution, connected session durations, and 90-day consistency matrix.'
                  .localized(context),
        ),
        TimeframeSegmentedControl(
          p: p,
          selected: _timeframe,
          onChanged: (tf) => setState(() => _timeframe = tf),
        ),
        _buildLifeNarrativeCard(context, dashboardData),
        AnomalyAlertCard(p: p, entries: entries, onLogNow: widget.onLogNow),
        _buildLifeAuditCard(context),
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
        HeroActivityRingCard(p: p, data: dashboardData),
        IntelligentTimeSlotBiasCard(p: p, data: dashboardData.timeSlotBias),
        DailyRhythmBarChart(p: p, data: dashboardData.dailyRhythm),
        FocusTagBreakdownCard(p: p, data: dashboardData.focusBreakdown),
        YearlyActivityGridCard(p: p, stats: dashboardData.gridStats),
        SettingsBetaNote(p: p, onLearnMore: widget.onLearnMoreBeta),
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
        borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar_rounded, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Intelligent Risk Radar'.localized(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildLifeNarrativeCard(
    BuildContext context,
    ExecutiveDashboardData data,
  ) {
    final narrative = _computeLifeNarrative(context, data);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface2.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: p.accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'THE STORY OF YOUR TIME'.localized(context),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            narrative,
            style: TextStyle(
              color: p.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  String _computeLifeNarrative(
    BuildContext context,
    ExecutiveDashboardData data,
  ) {
    if (data.totalMoments == 0 && data.totalTracked.inMinutes == 0) {
      return 'Your timeline is serene and clear. Begin a session or record your next moment to watch your story unfold.'
          .localized(context);
    }

    final periodLabel = switch (data.timeframe) {
      DashboardTimeframe.today => 'Today',
      DashboardTimeframe.week => 'This week',
      DashboardTimeframe.month => 'This month',
      DashboardTimeframe.all => 'Across all logged history',
    }.localized(context);

    final parts = <String>[];
    if (data.totalTracked.inMinutes > 0 && data.totalMoments > 0) {
      parts.add(
        '$periodLabel, you dedicated ${data.formattedTotalTracked} of focused attention across ${data.totalMoments} ${data.totalMoments == 1 ? 'entry' : 'entries'}.'
            .localized(context),
      );
    } else if (data.totalTracked.inMinutes > 0) {
      parts.add(
        '$periodLabel, you logged ${data.formattedTotalTracked} of focused flow.'
            .localized(context),
      );
    } else {
      parts.add(
        '$periodLabel, you captured ${data.totalMoments} distinct ${data.totalMoments == 1 ? 'moment' : 'moments'}.'
            .localized(context),
      );
    }

    if (data.timeSlotBias.peakSlotName != 'None') {
      final slot = data.timeSlotBias.peakSlotName.toLowerCase();
      parts.add(
        'Your energy and momentum peaked in the $slot.'.localized(context),
      );
    }

    if (data.focusBreakdown.categories.isNotEmpty) {
      final topCat = data.focusBreakdown.categories.first;
      if (topCat.percentage >= 25 && topCat.name != 'General') {
        parts.add(
          'Primary intention centered on ${topCat.name} (${topCat.percentage}% of attention).'
              .localized(context),
        );
      }
    }

    if (data.gridStats.currentStreak > 1) {
      parts.add(
        '${data.gridStats.currentStreak}-day continuous focus streak active.'
            .localized(context),
      );
    }

    return parts.join(' ');
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

  Widget _buildLifeAuditCard(BuildContext context) {
    final auditTimeframe = switch (_timeframe) {
      DashboardTimeframe.today => LifeAuditTimeframe.today,
      DashboardTimeframe.week => LifeAuditTimeframe.week,
      DashboardTimeframe.month => LifeAuditTimeframe.month,
      DashboardTimeframe.all => LifeAuditTimeframe.year,
    };

    final summary = LifeAuditService.calculate(
      entries: entries,
      timeframe: auditTimeframe,
    );

    final hasData = summary.hasData;
    final wasted = hasData ? summary.formattedTotalWasted : '0h';
    final wakingLost = hasData ? summary.wakingDaysLostText : '0 days';
    final isSevere = hasData && (summary.intentionalityRatio < 40.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: widget.onOpenLifeAudit,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSevere
                  ? p.red.withValues(alpha: 0.35)
                  : p.border.withValues(alpha: 0.5),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.timelapse_rounded,
                          size: 17,
                          color: isSevere
                              ? p.red
                              : (hasData ? p.orange : p.accent),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Life Audit'.localized(context).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSevere
                                  ? p.red
                                  : (hasData ? p.orange : p.accent),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Audit'.localized(context),
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: p.accent,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        hasData
                            ? '$wasted ${'Lost'.localized(context)}'
                            : '0h ${'Lost'.localized(context)}',
                        maxLines: 1,
                        style: TextStyle(
                          color: isSevere ? p.red : p.text,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (hasData ? (isSevere ? p.red : p.orange) : p.accent)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          hasData
                              ? '$wakingLost ${'waking days void'.localized(context)}'
                              : '0 Data Available'.localized(context),
                          maxLines: 1,
                          style: TextStyle(
                            color: hasData
                                ? (isSevere ? p.red : p.orange)
                                : p.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hasData
                    ? 'Based on your daily conscious window ($wasted unaccounted for). Tap to customize sleep, logistics, and explore multi-horizon mortality statistics.'
                          .localized(context)
                    : (entries.isEmpty
                          ? 'No sessions logged yet. Tap to configure your daily conscious window and begin tracking.'
                                .localized(context)
                          : 'Awaiting ${summary.requiredDays} days of history (${summary.availableHistoryDays} recorded). Tap to inspect available ledger and multi-horizon audits.'
                                .localized(context)),
                style: TextStyle(color: p.text2, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
