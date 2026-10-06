import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/goals_sheet.dart';
import 'package:notekar/dialogs/personalization_setup_dialog.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/widgets/timeline_session_card.dart';
import 'package:notekar/widgets/zen_doodle_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark', accentName: 'blue');

  group('ZenDoodleSplash Tests', () {
    testWidgets(
      'renders Zen doodle splash and calls onComplete or dismisses on tap',
      (tester) async {
        ZenDoodleSplash.hasShownThisSession = false;
        bool completed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZenDoodleSplash(
                p: p,
                onComplete: () {
                  completed = true;
                },
              ),
            ),
          ),
        );

        // Verify NoteKar brand text is rendered
        expect(find.text('NoteKar'), findsOneWidget);
        expect(find.text('Every moment intentional.'), findsOneWidget);

        // Tap anywhere to skip instantly
        await tester.tap(find.byType(ZenDoodleSplash));
        await tester.pumpAndSettle();

        expect(completed, isTrue);
        expect(ZenDoodleSplash.hasShownThisSession, isTrue);
      },
    );
  });

  group('Apple HIG Goals & Pacing Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'GoalsContentView renders goals with pacing and triggers 1-tap start session',
      (tester) async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final testGoal = Goal(
          id: 'coding_goal',
          title: 'Coding',
          category: 'Code',
          mode: 'two-way',
          targetMinutes: 600,
          timeframe: GoalTimeframe.week,
          createdAt: now - 3600000,
        );

        await GoalsService.instance.saveGoal(testGoal);

        Goal? startedGoal;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 700,
                child: GoalsContentView(
                  p: p,
                  moments: [
                    Moment(
                      id: 1,
                      timestamp: now - 1800000,
                      type: 'in',
                      category: 'Code',
                      date: '2026-09-27',
                    ),
                    Moment(
                      id: 2,
                      timestamp: now,
                      type: 'out',
                      category: 'Code',
                      date: '2026-09-27',
                    ),
                  ],
                  onStartSession: (g) {
                    startedGoal = g;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check title and category pill
        expect(find.text('Coding'), findsOneWidget);
        expect(find.text('Code'), findsOneWidget);

        // Check 1-tap start button
        final startButton = find.text('Start Code');
        expect(startButton, findsOneWidget);

        await tester.tap(startButton);
        await tester.pumpAndSettle();

        expect(startedGoal, isNotNull);
        expect(startedGoal!.id, 'coding_goal');
        expect(startedGoal!.category, 'Code');
      },
    );

    testWidgets(
      'CreateOrEditGoalView Apple HIG form renders with Cupertino segmented controls',
      (tester) async {
        Goal? savedResult;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CreateOrEditGoalView(
                  p: p,
                  onSave: (g) {
                    savedResult = g;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check Apple grouped headers
        expect(find.text('GOAL TITLE'), findsOneWidget);
        expect(find.text('Target Allocation'), findsOneWidget);
        expect(find.text('TIMEFRAME'), findsOneWidget);
        expect(find.text('CATEGORY SCOPE'), findsOneWidget);

        // Enter title (<= 9 chars)
        await tester.enterText(find.byType(CupertinoTextField), 'Memoir');

        // Tap Save
        await tester.tap(find.text('Save Goal'));
        await tester.pumpAndSettle();

        expect(savedResult, isNotNull);
        expect(savedResult!.title, 'Memoir');
      },
    );

    testWidgets(
      'CreateOrEditGoalView selecting Custom Date timeframe exposes DEADLINE DATE selector',
      (tester) async {
        Goal? savedResult;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CreateOrEditGoalView(
                  p: p,
                  onSave: (g) {
                    savedResult = g;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Switch to Custom Date
        await tester.tap(find.text('Custom Date'));
        await tester.pumpAndSettle();

        expect(find.text('Target Deadline'), findsOneWidget);

        await tester.enterText(
          find.byType(CupertinoTextField),
          'Thesis Completion',
        );

        await tester.tap(find.text('Save Goal'));
        await tester.pumpAndSettle();

        expect(savedResult, isNotNull);
        expect(savedResult!.timeframe, GoalTimeframe.custom);
        expect(savedResult!.targetDate, isNotNull);
      },
    );

    testWidgets(
      'TimelineSessionCard renders goal attribution badge when matching category goal exists',
      (tester) async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final testGoal = Goal(
          id: 'focus_goal',
          title: 'Master Flutter',
          category: 'Focus',
          targetMinutes: 120,
          timeframe: GoalTimeframe.week,
          createdAt: now,
        );

        final session = TimelineSessionItem(
          inMoment: Moment(
            id: 101,
            timestamp: now - (30 * 60 * 1000), // 30 mins ago
            type: 'in',
            category: 'Focus',
            date: '2026-09-27',
          ),
          outMoment: Moment(
            id: 102,
            timestamp: now,
            type: 'out',
            category: 'Focus',
            date: '2026-09-27',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSessionCard(
                p: p,
                session: session,
                goals: [testGoal],
                onEditNote: () {},
                onDeleteSession: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify that the goal attribution pill is visible with the goal title
        expect(find.textContaining('Master Flutter'), findsOneWidget);
        expect(find.textContaining('30m'), findsWidgets);
      },
    );
  });

  group('PersonalizationSetupDialog Stepper & Landmark Chips Tests', () {
    testWidgets('renders stepper [-] [+] and landmark milestone chips', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PersonalizationSetupDialog(p: p),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify landmark chips
      expect(find.text('75y'), findsOneWidget);
      expect(find.text('80y'), findsOneWidget);
      expect(find.text('85y'), findsOneWidget);
      expect(find.text('90y'), findsOneWidget);
      expect(find.text('100y'), findsOneWidget);

      // Tap 85y milestone chip
      await tester.tap(find.text('85y'));
      await tester.pumpAndSettle();

      // Lifespan display should update to 85 Years
      expect(find.text('85 Years'), findsOneWidget);

      // Tap [+] stepper button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Should now be 86 Years
      expect(find.text('86 Years'), findsOneWidget);
    });
  });
}
