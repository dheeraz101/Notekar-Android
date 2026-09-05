import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/dashboard_metrics_service.dart';
import 'package:notekar/widgets/executive_dashboard_widgets.dart';

void main() {
  final p = paletteFor('dark');

  group('Executive Dashboard Analytical Engine Tests', () {
    test('Calculates accurate metrics, time-slot bias, and peak slot', () {
      final now = DateTime.now();
      final evening1 = DateTime(now.year, now.month, now.day, 18, 0); // 6 PM
      final evening2 = DateTime(
        now.year,
        now.month,
        now.day,
        19,
        30,
      ); // 7:30 PM
      final morning = DateTime(now.year, now.month, now.day, 8, 30); // 8:30 AM

      final entries = [
        Moment(
          id: 1,
          timestamp: evening1.millisecondsSinceEpoch,
          type: 'in',
          date: dateKey(now),
          note: '#work Rust compiler backend',
        ),
        Moment(
          id: 2,
          timestamp: evening2.millisecondsSinceEpoch,
          type: 'out',
          date: dateKey(now),
          note: '',
        ),
        Moment(
          id: 3,
          timestamp: morning.millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(now),
          note: 'Hydration #health',
        ),
      ];

      final data = DashboardMetricsService.calculate(
        entries: entries,
        timeframe: DashboardTimeframe.today,
        p: p,
      );

      expect(data.totalMoments, 3);
      expect(data.totalTracked.inMinutes, 90); // 1h 30m
      expect(data.formattedTotalTracked, '1h 30m');

      // Time Slot Bias
      expect(data.timeSlotBias.peakSlotName, 'Evening');
      expect(
        data.timeSlotBias.slots.firstWhere((s) => s.name == 'Evening').isPeak,
        isTrue,
      );
      expect(data.timeSlotBias.headline, contains('Evening'));

      // Daily Rhythm
      expect(data.dailyRhythm.days.length, 7);

      // Focus Breakdown
      expect(data.focusBreakdown.categories.isNotEmpty, isTrue);
      expect(
        data.focusBreakdown.categories.any((c) => c.name == '#work'),
        isTrue,
      );
    });

    test('Computes streaks and active days across 90-day window', () {
      final now = DateTime.now();
      final todayKey = dateKey(now);
      final yesterdayKey = dateKey(now.subtract(const Duration(days: 1)));

      final entries = [
        Moment(
          id: 1,
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: todayKey,
          note: '',
        ),
        Moment(
          id: 2,
          timestamp: now
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
          type: 'single',
          date: yesterdayKey,
          note: '',
        ),
      ];

      final data = DashboardMetricsService.calculate(
        entries: entries,
        timeframe: DashboardTimeframe.all,
        p: p,
      );

      expect(data.gridStats.currentStreak, 2);
      expect(data.gridStats.longestStreak, greaterThanOrEqualTo(2));
      expect(data.gridStats.activeDaysCount, 2);
    });
  });

  group('Executive Dashboard Widgets Rendering Tests', () {
    testWidgets(
      'TimeframeSegmentedControl triggers onChanged when tab is tapped',
      (tester) async {
        DashboardTimeframe selected = DashboardTimeframe.today;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return TimeframeSegmentedControl(
                    p: p,
                    selected: selected,
                    onChanged: (tf) => setState(() => selected = tf),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Week'), findsOneWidget);
        expect(find.text('Month'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);

        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();
        expect(selected, DashboardTimeframe.week);
      },
    );

    testWidgets(
      'HeroActivityRingCard and IntelligentTimeSlotBiasCard render with proper HIG hierarchy',
      (tester) async {
        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: DateTime(
              now.year,
              now.month,
              now.day,
              18,
              0,
            ).millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(now),
            note: '#study Machine learning course',
          ),
          Moment(
            id: 2,
            timestamp: DateTime(
              now.year,
              now.month,
              now.day,
              20,
              0,
            ).millisecondsSinceEpoch,
            type: 'out',
            date: dateKey(now),
            note: '',
          ),
        ];

        final data = DashboardMetricsService.calculate(
          entries: entries,
          timeframe: DashboardTimeframe.today,
          p: p,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    HeroActivityRingCard(p: p, data: data),
                    IntelligentTimeSlotBiasCard(p: p, data: data.timeSlotBias),
                    DailyRhythmBarChart(p: p, data: data.dailyRhythm),
                    YearlyActivityGridCard(p: p, stats: data.gridStats),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Total Tracked: '), findsOneWidget);
        expect(find.text('2h'), findsNWidgets(2));
        expect(find.text('Time-Slot Intelligence'), findsOneWidget);
        expect(find.text('★ EVENING'), findsOneWidget);
        expect(find.text('Daily Rhythm (Mon – Sun)'), findsOneWidget);
        expect(find.text('Activity Grid'), findsOneWidget);
        expect(find.text('(Last 90 Days)'), findsOneWidget);
        expect(find.text('Current Streak'), findsOneWidget);
        expect(find.text('Longest Streak'), findsOneWidget);

        // Verify that the second pill (pace/trend) is positioned downward below the first pill (logs)
        final logsPillFinder = find.text('2 logs');
        final pacePillFinder = find.text(data.paceText);
        expect(logsPillFinder, findsOneWidget);
        expect(pacePillFinder, findsOneWidget);
        final logsBottom = tester.getBottomLeft(logsPillFinder).dy;
        final paceTop = tester.getTopLeft(pacePillFinder).dy;
        expect(
          paceTop,
          greaterThanOrEqualTo(logsBottom),
          reason: 'Pace pill should be moved downward below the logs pill',
        );
      },
    );

    testWidgets(
      'HeroActivityRingCard renders downward pace pill with long text without overflow',
      (tester) async {
        final mockData = ExecutiveDashboardData(
          timeframe: DashboardTimeframe.today,
          totalTracked: const Duration(hours: 14, minutes: 30),
          totalMoments: 10001,
          paceText: 'Active tracking (10001 logs)',
          paceIsPositive: true,
          activityRingRatio: 0.85,
          timeSlotBias: const TimeSlotBiasData(
            headline: 'Consistent bias',
            peakSlotName: 'Morning',
            slots: [],
          ),
          dailyRhythm: const DailyRhythmData(days: [], comparisonText: ''),
          focusBreakdown: const FocusBreakdownData(categories: []),
          gridStats: const ActivityGridStats(
            longestStreak: 20,
            currentStreak: 12,
            activeDaysCount: 45,
            totalDaysCount: 90,
            dayIntensities: {},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HeroActivityRingCard(p: p, data: mockData),
            ),
          ),
        );

        expect(find.text('10001 logs'), findsOneWidget);
        expect(find.text('Active tracking (10001 logs)'), findsOneWidget);

        final logsBottom = tester.getBottomLeft(find.text('10001 logs')).dy;
        final paceTop = tester
            .getTopLeft(find.text('Active tracking (10001 logs)'))
            .dy;
        expect(paceTop, greaterThanOrEqualTo(logsBottom));
      },
    );
  });
}
