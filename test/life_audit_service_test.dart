import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/life_audit_page.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/life_audit_service.dart';
import 'package:notekar/widgets/settings_widgets.dart';

void main() {
  final p = paletteFor('dark');
  final referenceNow = DateTime(2026, 9, 8, 12, 0, 0);

  group('LifeAuditService Mathematical Calculations', () {
    test('computeConsciousHours partitions 24 hours correctly', () {
      // 10h sleep + 4h logistics = 10h conscious window
      expect(
        LifeAuditService.computeConsciousHours(
          sleepHours: 10.0,
          essentialsHours: 4.0,
        ),
        10.0,
      );

      // 8h sleep + 3h logistics = 13h conscious window
      expect(
        LifeAuditService.computeConsciousHours(
          sleepHours: 8.0,
          essentialsHours: 3.0,
        ),
        13.0,
      );

      // Clamping limits
      expect(
        LifeAuditService.computeConsciousHours(
          sleepHours: 16.0,
          essentialsHours: 10.0,
        ),
        1.0, // Minimum clamp 1.0h
      );
    });

    test(
      'Zero moments results in hasData: false, 0 wasted hours, and 0 available history across all timeframes',
      () {
        for (final tf in LifeAuditTimeframe.values) {
          final summary = LifeAuditService.calculate(
            entries: [],
            timeframe: tf,
            sleepHours: 10.0,
            essentialsHours: 4.0,
            referenceNow: referenceNow,
          );

          final expectedDays = tf.daysCount;
          expect(summary.daysCount, expectedDays);
          expect(summary.requiredDays, expectedDays);
          expect(summary.hasData, isFalse);
          expect(summary.availableHistoryDays, 0);
          expect(summary.dailyRecords, isEmpty);
          expect(summary.totalTrackedDuration, Duration.zero);
          expect(summary.totalWastedDuration, Duration.zero);
          expect(summary.intentionalityRatio, 0.0);
          expect(summary.voidRatio, 0.0);
          expect(summary.totalWakingDaysLost, 0.0);
          expect(summary.totalCelestialDaysLost, 0.0);
        }
      },
    );

    test(
      'Insufficient history sets hasData: false, 0 wasted hours, and populates partial records for available history',
      () {
        // User logged an entry 3 days ago
        final threeDaysAgo = referenceNow.subtract(const Duration(days: 2));
        final entries = [
          Moment(
            id: 1,
            timestamp: threeDaysAgo.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-06',
          ),
        ];

        // Week horizon requires 7 days, but user only has 3 days of history
        final weekSummary = LifeAuditService.calculate(
          entries: entries,
          timeframe: LifeAuditTimeframe.week,
          referenceNow: referenceNow,
        );

        expect(weekSummary.hasData, isFalse);
        expect(weekSummary.availableHistoryDays, 3);
        expect(weekSummary.requiredDays, 7);
        expect(weekSummary.totalWastedDuration, Duration.zero);
        // Partial daily records should match available history days (3 days)
        expect(weekSummary.dailyRecords.length, 3);

        // Today horizon requires 1 day, user has 3 days -> hasData is true!
        final todaySummary = LifeAuditService.calculate(
          entries: entries,
          timeframe: LifeAuditTimeframe.today,
          referenceNow: referenceNow,
        );
        expect(todaySummary.hasData, isTrue);
        expect(todaySummary.availableHistoryDays, 3);
        expect(todaySummary.requiredDays, 1);
      },
    );

    test(
      'Sufficient history across all 7 days computes full aggregate metrics',
      () {
        final eightDaysAgo = referenceNow.subtract(const Duration(days: 7));
        final entries = [
          Moment(
            id: 1,
            timestamp: eightDaysAgo.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-01',
          ),
        ];

        final weekSummary = LifeAuditService.calculate(
          entries: entries,
          timeframe: LifeAuditTimeframe.week,
          referenceNow: referenceNow,
        );

        expect(weekSummary.hasData, isTrue);
        expect(weekSummary.availableHistoryDays, 8);
        expect(weekSummary.requiredDays, 7);
        expect(weekSummary.dailyRecords.length, 7);
        expect(
          weekSummary.totalWastedDuration.inHours,
          70,
        ); // 7 days * 10h conscious
        expect(weekSummary.wakingDaysLostText, '7.0 days');
      },
    );

    test(
      'Paired Two-Way sessions reduce wasted void and increase intentionality',
      () {
        // Session 1: Today from 9:00 to 11:00 (2 hours)
        final sessionStart = referenceNow
            .subtract(const Duration(hours: 3))
            .millisecondsSinceEpoch;
        final sessionEnd = referenceNow
            .subtract(const Duration(hours: 1))
            .millisecondsSinceEpoch;

        final entries = [
          Moment(
            id: 1,
            timestamp: sessionStart,
            type: 'in',
            date: '2026-09-08',
            note: 'Morning Deep Work',
          ),
          Moment(
            id: 2,
            timestamp: sessionEnd,
            type: 'out',
            date: '2026-09-08',
            note: 'Done Deep Work',
          ),
        ];

        final summary = LifeAuditService.calculate(
          entries: entries,
          timeframe: LifeAuditTimeframe.today,
          sleepHours: 10.0,
          essentialsHours: 4.0,
          referenceNow: referenceNow,
        );

        expect(summary.totalTrackedDuration.inHours, 2);
        // 10h conscious window - 2h tracked = 8h wasted
        expect(summary.totalWastedDuration.inHours, 8);
        // 2h / 10h = 20% intentionality
        expect(summary.intentionalityRatio, 20.0);
        expect(summary.voidRatio, 80.0);
        // 8h wasted / 10h = 0.8 waking days lost
        expect(summary.totalWakingDaysLost, closeTo(0.8, 0.01));
      },
    );

    test(
      'Transcendent day (> 100% conscious capacity) caps wasted duration at 0',
      () {
        final entries = [
          // 12 hour session
          Moment(
            id: 1,
            timestamp: referenceNow
                .subtract(const Duration(hours: 12))
                .millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-08',
          ),
          Moment(
            id: 2,
            timestamp: referenceNow.millisecondsSinceEpoch,
            type: 'out',
            date: '2026-09-08',
          ),
        ];

        final summary = LifeAuditService.calculate(
          entries: entries,
          timeframe: LifeAuditTimeframe.today,
          sleepHours: 10.0,
          essentialsHours: 4.0,
          referenceNow: referenceNow,
        );

        expect(summary.totalTrackedDuration.inHours, 12);
        expect(summary.totalWastedDuration, Duration.zero);
        expect(summary.intentionalityRatio, 100.0);
        expect(summary.voidRatio, 0.0);
        expect(summary.dailyRecords.first.status, DayAuditStatus.transcendent);
        expect(summary.dailyRecords.first.overtimeDuration.inHours, 2);
      },
    );

    test('Single moments receive calibrated intentional focus credit', () {
      // 4 single moments today = 4 * 15m = 60m (1h)
      final entries = List.generate(
        4,
        (i) => Moment(
          id: i + 1,
          timestamp: referenceNow
              .subtract(Duration(hours: 4 - i))
              .millisecondsSinceEpoch,
          type: 'single',
          date: '2026-09-08',
          note: 'Focus checkpoint $i',
        ),
      );

      final summary = LifeAuditService.calculate(
        entries: entries,
        timeframe: LifeAuditTimeframe.today,
        sleepHours: 10.0,
        essentialsHours: 4.0,
        referenceNow: referenceNow,
      );

      expect(summary.totalTrackedDuration.inMinutes, 60);
      expect(
        summary.totalWastedDuration.inMinutes,
        540,
      ); // 10h - 1h = 9h (540m)
      expect(summary.intentionalityRatio, 10.0); // 1h / 10h = 10%
    });

    test(
      'Ongoing live session without out moment is credited in real time',
      () {
        final sessionStart = referenceNow
            .subtract(const Duration(minutes: 90))
            .millisecondsSinceEpoch;

        final entries = [
          Moment(
            id: 1,
            timestamp: sessionStart,
            type: 'in',
            date: '2026-09-08',
            note: 'Live coding',
          ),
        ];

        final summary = LifeAuditService.calculate(
          entries: entries,
          timeframe: LifeAuditTimeframe.today,
          sleepHours: 10.0,
          essentialsHours: 4.0,
          referenceNow: referenceNow,
        );

        expect(summary.totalTrackedDuration.inMinutes, 90);
        expect(summary.hasData, isTrue);
      },
    );
  });

  group('LifeAuditPage Widget Tests', () {
    testWidgets(
      'Renders 24-hour horizon bar, sliders, and brutal reality card',
      (tester) async {
        double currentSleep = 10.0;
        double currentEssentials = 4.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LifeAuditPage(
                  p: p,
                  entries: const [],
                  sleepHours: currentSleep,
                  essentialsHours: currentEssentials,
                  onSleepHoursChanged: (val) => currentSleep = val,
                  onEssentialsHoursChanged: (val) => currentEssentials = val,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check header and 24-hour partition
        expect(find.text('24-Hour Daily Partition'), findsOneWidget);
        expect(find.text('Conscious Window: 10.0h / day'), findsOneWidget);

        // Check sliders exist
        expect(find.text('Sleep & Rest'), findsOneWidget);
        expect(find.text('Food, Commute & Logistics'), findsOneWidget);
        expect(find.text('10.0 Hours'), findsOneWidget);
        expect(find.text('4.0 Hours'), findsOneWidget);

        // Check timeframe buttons
        expect(find.text('Today'), findsOneWidget); // Timeframe button
        expect(find.text('Week'), findsOneWidget);
        expect(find.text('Month'), findsOneWidget);
        expect(find.text('6 Weeks'), findsOneWidget);
        expect(find.text('6 Months'), findsOneWidget);
        expect(find.text('Year'), findsOneWidget);

        // Check Brutal Reality hero card for new user (0 Data Available)
        expect(find.text('THE COST OF THE VOID'), findsOneWidget);
        expect(find.text('0 DATA AVAILABLE'), findsOneWidget);
        expect(find.text('0h Lost'), findsOneWidget);
        expect(find.text('Waking Days Lost'), findsOneWidget);
        expect(find.text('Earth (24h) Days'), findsOneWidget);

        // Check empty ledger state
        expect(find.text('No Ledger History Yet'), findsOneWidget);
        expect(find.text('0 Days Recorded'), findsNWidgets(2));

        // Check Seneca Stoic quote
        expect(find.text('THE STOIC REALITY'), findsOneWidget);
        expect(find.textContaining('Seneca'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping timeframe switches audit calculation and updates UI with recorded history',
      (tester) async {
        final entriesWithHistory = [
          Moment(
            id: 1,
            timestamp: DateTime.now()
                .subtract(const Duration(days: 200))
                .millisecondsSinceEpoch,
            type: 'in',
            date: '2026-01-01',
          ),
          Moment(
            id: 2,
            timestamp:
                DateTime.now()
                    .subtract(const Duration(days: 200))
                    .millisecondsSinceEpoch +
                3600000,
            type: 'out',
            date: '2026-01-01',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LifeAuditPage(
                  p: p,
                  entries: entriesWithHistory,
                  sleepHours: 10.0,
                  essentialsHours: 4.0,
                  onSleepHoursChanged: (_) {},
                  onEssentialsHoursChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Default is Week (7 days)
        expect(find.text('7 Days Total'), findsOneWidget);

        // Tap 'Month'
        await tester.tap(find.text('Month'));
        await tester.pumpAndSettle();
        expect(find.text('30 Days Total'), findsOneWidget);

        // Tap '6 Weeks' (Half-Quarter)
        await tester.tap(find.text('6 Weeks'));
        await tester.pumpAndSettle();
        expect(find.text('45 Days Total'), findsOneWidget);

        // Tap '6 Months' (Half-Year)
        await tester.tap(find.text('6 Months'));
        await tester.pumpAndSettle();
        expect(find.text('180 Days Total'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders SettingsBetaNote in LifeAuditPage and triggers onLearnMoreBeta',
      (tester) async {
        bool betaClicked = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LifeAuditPage(
                  p: p,
                  entries: const [],
                  sleepHours: 10.0,
                  essentialsHours: 4.0,
                  onSleepHoursChanged: (_) {},
                  onEssentialsHoursChanged: (_) {},
                  onLearnMoreBeta: () => betaClicked = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final betaNoteFinder = find.byType(SettingsBetaNote);
        await tester.scrollUntilVisible(
          betaNoteFinder,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('in beta and continuously improving'),
          findsOneWidget,
        );
        expect(find.textContaining('Learn More'), findsOneWidget);
        final betaNoteWidget = tester.widget<SettingsBetaNote>(betaNoteFinder);
        betaNoteWidget.onLearnMore?.call();
        await tester.pumpAndSettle();
        expect(betaClicked, isTrue);
      },
    );
  });
}
