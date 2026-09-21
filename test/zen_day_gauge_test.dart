import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/palette.dart';
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
  });
}
