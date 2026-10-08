import 'package:flutter/material.dart';
import 'package:notekar/dialogs/personalization_setup_dialog.dart';
import 'package:notekar/dialogs/sunday_dispatch_sheet.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/dashboard_metrics_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/widgets/digital_wellbeing_card.dart';
import 'package:notekar/widgets/executive_dashboard_widgets.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Executive Intelligence Hub Screen
/// Surfaces NoteKar's flagship analytics engine: Activity Ring, Time-Slot Bias,
/// Daily 7-day Rhythm, Focus Category breakdowns, 90-day Activity Grid,
/// and Memento Mori Life Horizon.
class ExecutiveIntelligenceHubScreen extends StatefulWidget {
  const ExecutiveIntelligenceHubScreen({
    super.key,
    this.initialTimeframe = DashboardTimeframe.week,
  });

  final DashboardTimeframe initialTimeframe;

  static Route<void> route({
    DashboardTimeframe initialTimeframe = DashboardTimeframe.week,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          ExecutiveIntelligenceHubScreen(initialTimeframe: initialTimeframe),
    );
  }

  @override
  State<ExecutiveIntelligenceHubScreen> createState() =>
      _ExecutiveIntelligenceHubScreenState();
}

class _ExecutiveIntelligenceHubScreenState
    extends State<ExecutiveIntelligenceHubScreen> {
  late DashboardTimeframe _selectedTimeframe;
  final _repo = MomentRepository();
  List<Moment> _moments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTimeframe = widget.initialTimeframe;
    _loadMoments();
  }

  Future<void> _loadMoments() async {
    setState(() => _isLoading = true);
    final moments = _repo.getAllMoments();
    if (mounted) {
      setState(() {
        _moments = moments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final now = DateTime.now();
    final todayKey = dateKey(now);
    final todayMoments = _moments.where((m) => m.date == todayKey).toList();
    final todaySections = buildTimelineDaySections(todayMoments);
    final todayTrackedDuration = todaySections.isNotEmpty
        ? todaySections.first.totalTrackedDuration
        : Duration.zero;

    final dashboardData = DashboardMetricsService.calculate(
      entries: _moments,
      timeframe: _selectedTimeframe,
      p: p,
    );

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context, p),

            // Timeframe Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TimeframeSegmentedControl(
                p: p,
                selected: _selectedTimeframe,
                onChanged: (tf) => setState(() => _selectedTimeframe = tf),
              ),
            ),

            // Analytics Body
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(p.accent),
                        strokeWidth: 2.0,
                      ),
                    )
                  : RefreshIndicator(
                      color: p.accent,
                      backgroundColor: p.surface2,
                      onRefresh: _loadMoments,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 8.0,
                          bottom: 40.0,
                        ),
                        children: [
                          // 1. Hero Activity Ring & Pace
                          HeroActivityRingCard(p: p, data: dashboardData),
                          const SizedBox(height: 12),

                          // 2. Digital Wellbeing & Reality Ratio (Screen Time vs. Conscious Focus)
                          DigitalWellbeingCard(
                            p: p,
                            todayTrackedDuration: todayTrackedDuration,
                            todayMomentsCount: todayMoments.length,
                          ),
                          const SizedBox(height: 12),

                          // 3. Intelligent Time Slot Bias
                          IntelligentTimeSlotBiasCard(
                            p: p,
                            data: dashboardData.timeSlotBias,
                          ),
                          const SizedBox(height: 12),

                          // 3. 7-Day Rhythm
                          DailyRhythmBarChart(
                            p: p,
                            data: dashboardData.dailyRhythm,
                          ),
                          const SizedBox(height: 12),

                          // 4. Focus Category Breakdown
                          FocusTagBreakdownCard(
                            p: p,
                            data: dashboardData.focusBreakdown,
                          ),
                          const SizedBox(height: 12),

                          // 5. 90-Day Activity Heatmap & Habit Half-Life
                          YearlyActivityGridCard(
                            p: p,
                            stats: dashboardData.gridStats,
                          ),
                          const SizedBox(height: 12),

                          // 6. Memento Mori Life Horizon
                          MementoMoriLifeHorizonCard(
                            p: p,
                            entries: _moments,
                            timeframe: _selectedTimeframe,
                            onConfigure: () async {
                              await PersonalizationSetupDialog.show(
                                context,
                                p: p,
                                onSaved: () => setState(() {}),
                              );
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Palette p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          PressableScale(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.surface2,
                border: Border.all(
                  color: p.border.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: p.text,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EXECUTIVE INTELLIGENCE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: p.text3,
                  ),
                ),
                Text(
                  'Dashboard & Patterns',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: p.text,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Weekly Dispatch'.localized(context),
            child: PressableScale(
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => SundayDispatchSheet(p: p, entries: _moments),
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.surface2,
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Icon(Icons.article_rounded, size: 17, color: p.text2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PressableScale(
            onTap: _loadMoments,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.surface2,
                border: Border.all(
                  color: p.border.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Icon(Icons.refresh_rounded, size: 18, color: p.text2),
            ),
          ),
        ],
      ),
    );
  }
}
