import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/life_audit_page.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/life_audit_service.dart';

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

    test('Zero moments results in 100% void loss across all timeframes', () {
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
        expect(summary.dailyRecords.length, expectedDays);
        expect(summary.totalTrackedDuration, Duration.zero);
        expect(summary.totalWastedDuration, Duration(hours: expectedDays * 10));
        expect(summary.intentionalityRatio, 0.0);
        expect(summary.voidRatio, 100.0);
        // Total waking days lost should equal the number of days evaluated
        expect(
          summary.totalWakingDaysLost,
          closeTo(expectedDays.toDouble(), 0.01),
        );
        // Celestial days lost should equal (expectedDays * 10) / 24
        expect(
          summary.totalCelestialDaysLost,
          closeTo((expectedDays * 10) / 24.0, 0.01),
        );
      }
    });

    test('Multi-horizon breakdown handles 6 weeks and 6 months accurately', () {
      final halfQuarterSummary = LifeAuditService.calculate(
        entries: [],
        timeframe: LifeAuditTimeframe.halfQuarter,
        sleepHours: 10.0,
        essentialsHours: 4.0,
        referenceNow: referenceNow,
      );
      expect(halfQuarterSummary.daysCount, 45);
      expect(halfQuarterSummary.totalConsciousWindow.inHours, 450);

      final halfYearSummary = LifeAuditService.calculate(
        entries: [],
        timeframe: LifeAuditTimeframe.halfYear,
        sleepHours: 10.0,
        essentialsHours: 4.0,
        referenceNow: referenceNow,
      );
      expect(halfYearSummary.daysCount, 180);
      expect(halfYearSummary.totalConsciousWindow.inHours, 1800);
    });

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
        expect(
          find.text('Today'),
          findsNWidgets(2),
        ); // Timeframe button + ledger item
        expect(find.text('Week'), findsOneWidget);
        expect(find.text('Month'), findsOneWidget);
        expect(find.text('6 Weeks'), findsOneWidget);
        expect(find.text('6 Months'), findsOneWidget);
        expect(find.text('Year'), findsOneWidget);

        // Check Brutal Reality hero card
        expect(find.text('THE COST OF THE VOID'), findsOneWidget);
        expect(find.text('Waking Days Lost'), findsOneWidget);
        expect(find.text('Earth (24h) Days'), findsOneWidget);

        // Check Seneca Stoic quote
        expect(find.text('THE STOIC REALITY'), findsOneWidget);
        expect(find.textContaining('Seneca'), findsOneWidget);
      },
    );

    testWidgets('Tapping timeframe switches audit calculation and updates UI', (
      tester,
    ) async {
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
    });
  });
}
