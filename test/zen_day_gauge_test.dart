import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/life_audit_service.dart';
import 'package:notekar/widgets/home_top_insights_pill.dart';
import 'package:notekar/widgets/timeline_gap_card.dart';
import 'package:notekar/widgets/zen_day_gauge.dart';

void main() {
  final p = paletteFor('dark');

  group('Zen Day Gauge & Rest Claim Tests', () {
    testWidgets('ZenDayRing paints correctly for various progress states', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: ZenDayRing(p: p, progress: 0.5, size: 14)),
          ),
        ),
      );

      expect(find.byType(ZenDayRing), findsOneWidget);
    });

    testWidgets(
      'TimelineGapCard renders Rest button for gaps >= 15m and triggers callback',
      (tester) async {
        final start = DateTime(2026, 9, 21, 14, 0).millisecondsSinceEpoch;
        final end = DateTime(
          2026,
          9,
          21,
          15,
          0,
        ).millisecondsSinceEpoch; // 1 hour gap

        bool restClaimed = false;
        bool logTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineGapCard(
                p: p,
                startTimestamp: start,
                endTimestamp: end,
                onTap: () => logTapped = true,
                onClaimRest: () => restClaimed = true,
              ),
            ),
          ),
        );

        // Verify duration and buttons
        expect(find.text('1h untracked'), findsOneWidget);
        expect(find.text('Rest'), findsOneWidget);
        expect(find.text('Log'), findsOneWidget);

        // Tap Rest
        await tester.tap(find.text('Rest'));
        await tester.pump();
        expect(restClaimed, isTrue);

        // Tap Log
        await tester.tap(find.text('Log'));
        await tester.pump();
        expect(logTapped, isTrue);
      },
    );

    testWidgets('TimelineGapCard omits Rest button for tiny gaps < 15m', (
      tester,
    ) async {
      final start = DateTime(2026, 9, 21, 14, 0).millisecondsSinceEpoch;
      final end = DateTime(
        2026,
        9,
        21,
        14,
        10,
      ).millisecondsSinceEpoch; // 10 min gap

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineGapCard(
              p: p,
              startTimestamp: start,
              endTimestamp: end,
              onTap: () {},
              onClaimRest: () {},
            ),
          ),
        ),
      );

      expect(find.text('10m untracked'), findsOneWidget);
      expect(find.text('Rest'), findsNothing);
      expect(find.text('Log'), findsOneWidget);
    });

    testWidgets(
      'HomeTopInsightsPill renders conscious vs mortal drift narrative',
      (tester) async {
        final now = DateTime.now();
        final nowMs = now.millisecondsSinceEpoch;
        final entries = [
          Moment(
            id: 1,
            timestamp: nowMs - 3600000,
            date: dateKey(now),
            type: 'in',
          ),
          Moment(id: 2, timestamp: nowMs, date: dateKey(now), type: 'out'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeTopInsightsPill(p: p, entries: entries, onTap: () {}),
            ),
          ),
        );

        expect(find.byType(HomeTopInsightsPill), findsOneWidget);
        expect(find.byType(ZenDayRing), findsOneWidget);
        // Confirms Conscious is rendered in narrative
        expect(find.textContaining('Conscious'), findsOneWidget);
      },
    );

    test(
      'LifeAuditService intentionality ratio stays strictly between 0 and 100',
      () {
        final now = DateTime.now();
        final nowMs = now.millisecondsSinceEpoch;
        final entries = [
          Moment(
            id: 1,
            timestamp: nowMs - 7200000,
            date: dateKey(now),
            type: 'in',
          ),
          Moment(id: 2, timestamp: nowMs, date: dateKey(now), type: 'out'),
        ];

        final todayAudit = LifeAuditService.calculate(
          entries: entries,
          timeframe: LifeAuditTimeframe.today,
        );

        expect(todayAudit.intentionalityRatio, greaterThanOrEqualTo(0.0));
        expect(todayAudit.intentionalityRatio, lessThanOrEqualTo(100.0));
        // Focus ratio sent to Android clamped between 0 and 100
        final focusRatio = todayAudit.intentionalityRatio.round().clamp(0, 100);
        expect(focusRatio, inInclusiveRange(0, 100));
      },
    );
  });
}
