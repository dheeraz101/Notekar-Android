import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/changelog_dialog.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/home_top_insights_pill.dart';
import 'package:notekar/widgets/toolbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark');

  group('HomeTopInsightsPill Widget Tests', () {
    testWidgets('Renders empty prompt when no moments exist and handles tap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTopInsightsPill(
              p: p,
              entries: const [],
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Activity Insights • Tap to explore'), findsOneWidget);
      await tester.tap(find.byType(HomeTopInsightsPill));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('Calculates evening time slot bias correctly for moments', (
      tester,
    ) async {
      // Create moments at 7:00 PM (19:00 - Evening slot)
      final eveningTimestamp = DateTime(
        2026,
        9,
        5,
        19,
        0,
      ).millisecondsSinceEpoch;
      final moments = [
        Moment(
          id: 1,
          timestamp: eveningTimestamp,
          type: 'single',
          date: '2026-09-05',
        ),
        Moment(
          id: 2,
          timestamp: eveningTimestamp + 60000,
          type: 'single',
          date: '2026-09-05',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTopInsightsPill(p: p, entries: moments, onTap: () {}),
          ),
        ),
      );

      expect(find.text('Evening (5–10 PM) • 100%'), findsOneWidget);
    });
  });

  group('Toolbar Last Timestamp Tests', () {
    testWidgets('Displays lastTimestamp instead of History when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              p: p,
              mode: 'two-way',
              onMode: () {},
              onHistory: () {},
              onSettings: () {},
              showLabels: true,
              largeControls: false,
              showBackgroundPill: true,
              animateIcons: false,
              motionX: 0,
              motionY: 0,
              showHistoryText: true,
              lastTimestamp: '19:45',
            ),
          ),
        ),
      );

      expect(find.text('19:45'), findsOneWidget);
      expect(find.text('History'), findsNothing);
    });

    testWidgets('Falls back to History when lastTimestamp is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              p: p,
              mode: 'two-way',
              onMode: () {},
              onHistory: () {},
              onSettings: () {},
              showLabels: true,
              largeControls: false,
              showBackgroundPill: true,
              animateIcons: false,
              motionX: 0,
              motionY: 0,
              showHistoryText: true,
              lastTimestamp: null,
            ),
          ),
        ),
      );

      expect(find.text('History'), findsOneWidget);
    });
  });

  group("What's New Separation Tests", () {
    testWidgets(
      'Omits detailed bullet changelog items when latestOnly is true',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ChangelogDialog(p: p, latestOnly: true),
              ),
            ),
          ),
        );

        // What's New title should appear
        expect(find.text("What's New"), findsOneWidget);
        // Detailed section header should NOT appear
        expect(find.text('VERSION HIGHLIGHTS & CHANGES'), findsNothing);
        // Web archive callout should appear
        expect(find.text('Full Release History'), findsOneWidget);
      },
    );

    testWidgets('Shows detailed changelog items when latestOnly is false', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ChangelogDialog(p: p, latestOnly: false),
            ),
          ),
        ),
      );

      // Release Notes title should appear
      expect(find.text('Release Notes'), findsOneWidget);
      // Detailed section header SHOULD appear
      expect(find.text('VERSION HIGHLIGHTS & CHANGES'), findsOneWidget);
    });
  });
}
