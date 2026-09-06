import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/settings/settings_dashboard_page.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/clock_face.dart';
import 'package:notekar/widgets/home_coachmark_tooltip.dart';
import 'package:notekar/widgets/home_top_insights_pill.dart';
import 'package:notekar/widgets/timeline_session_card.dart';
import 'package:notekar/widgets/timeline_single_tile.dart';

void main() {
  final p = paletteFor('dark');

  group('Steve Jobs Interaction & Sensory Tests', () {
    testWidgets(
      'HomeTopInsightsPill generates natural-language narrative for active session',
      (tester) async {
        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: now.millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(now),
            note: 'Focus block',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeTopInsightsPill(p: p, entries: entries, onTap: () {}),
            ),
          ),
        );

        expect(
          find.text('Active session in flow • Tap to inspect'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'SettingsDashboardPage displays "THE STORY OF YOUR TIME" editorial synthesis card',
      (tester) async {
        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: now
                .subtract(const Duration(hours: 2))
                .millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(now),
            note: '#code Deep architecture session',
          ),
          Moment(
            id: 2,
            timestamp: now
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch,
            type: 'out',
            date: dateKey(now),
            note: '',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SettingsDashboardPage(
                  p: p,
                  entries: entries,
                  enableSobrietyMode: false,
                  onLogNow: () {},
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check for "THE STORY OF YOUR TIME" editorial headline
        expect(find.text('THE STORY OF YOUR TIME'), findsOneWidget);
        // Narrative should mention 1h of focused attention and entries
        expect(
          find.textContaining('dedicated 1h of focused attention'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'HistoryDialog supports inline lens density toggle button in sticky header',
      (tester) async {
        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: now.millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(now),
            note: 'First moment',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryDialog(
                p: p,
                entries: entries,
                compactRows: false,
                largeText: false,
                minimalMomentOptions: false,
                confirmDelete: false,
                onDelete: (_) async {},
                onRestore: (_) async {},
                onUpdateNote: (_, _) async {},
                onDuration: (_, _) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Density toggle button with tooltip 'Compact view'
        final toggleFinder = find.byTooltip('Compact view');
        expect(toggleFinder, findsOneWidget);

        // Tap inline density toggle to switch to compact
        await tester.tap(toggleFinder);
        await tester.pumpAndSettle();

        // Now tooltip should update to 'Comfortable view'
        expect(find.byTooltip('Comfortable view'), findsOneWidget);
      },
    );

    testWidgets(
      'TimelineSingleTile triggers swipe-to-delete with tactile feedback',
      (tester) async {
        final now = DateTime.now();
        final moment = Moment(
          id: 42,
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(now),
          note: 'Moment to dismiss',
        );

        bool deleteCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSingleTile(
                p: p,
                moment: moment,
                onEditNote: () {},
                onDelete: () {
                  deleteCalled = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Delete'), findsNothing);

        // Drag left to reveal secondary delete background and trigger callback
        await tester.drag(
          find.byType(TimelineSingleTile),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(deleteCalled, isTrue);
      },
    );

    testWidgets(
      'TimelineSessionCard triggers swipe-to-delete for connected sessions',
      (tester) async {
        final now = DateTime.now();
        final session = TimelineSessionItem(
          inMoment: Moment(
            id: 1,
            timestamp: now
                .subtract(const Duration(minutes: 45))
                .millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(now),
            note: 'Design review',
          ),
          outMoment: Moment(
            id: 2,
            timestamp: now.millisecondsSinceEpoch,
            type: 'out',
            date: dateKey(now),
            note: '',
          ),
        );

        bool deleteSessionCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSessionCard(
                p: p,
                session: session,
                onEditNote: () {},
                onDeleteSession: () {
                  deleteSessionCalled = true;
                },
              ),
            ),
          ),
        );

        // Drag left to trigger onDeleteSession
        await tester.drag(
          find.byType(TimelineSessionCard),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(deleteSessionCalled, isTrue);
      },
    );

    testWidgets('ClockFace renders with spring bounce scale elasticity', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockFace(
              now: DateTime.now(),
              p: p,
              pulseToken: 0,
              pulseType: 'save',
              minimal: false,
              showSeconds: true,
              highlightSeconds: true,
            ),
          ),
        ),
      );

      // Finds AnimatedScale with spring physics
      expect(find.byType(AnimatedScale), findsOneWidget);
      final animatedScale = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );
      expect(animatedScale.curve, Curves.easeOutBack);
      expect(animatedScale.scale, 1.0);
    });

    testWidgets(
      'HomeCoachmarkTooltip renders serene epiphany prompt on first install',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CoachmarkTooltip(p: p)),
          ),
        );

        expect(
          find.text('Tap anywhere to begin. Hold to add a note.'),
          findsOneWidget,
        );
      },
    );
  });
}
