import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/goals_sheet.dart';
import 'package:notekar/dialogs/personalization_setup_dialog.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/services/project_service.dart';
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
        await tester.enterText(find.byType(CupertinoTextField).first, 'Memoir');

        // Tap Save
        await tester.ensureVisible(find.text('Save Goal'));
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
          find.byType(CupertinoTextField).first,
          'Thesis Completion',
        );

        await tester.ensureVisible(find.text('Save Goal'));
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
            timestamp: now - (30 * 60 * 1000),
            // 30 mins ago
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

    test(
      'autoMigrateLegacyProjects migrates legacy projects without recursive deadlock',
      () async {
        SharedPreferences.setMockInitialValues({
          'notekar_projects_list_v1':
              '[{"id":"proj_legacy_1","title":"Ship Feature X","description":"Critical feature","category":"Work","targetMinutes":120,"deadline":1700000000000,"createdAt":1690000000000,"isCompleted":false,"completedAt":null,"milestones":[{"id":"m1","title":"Design UI","isCompleted":true,"completedAt":1695000000000}],"colorHex":"#30D158"}]',
        });

        final goals = await GoalsService.instance.getGoals();
        expect(goals.any((g) => g.id == 'proj_legacy_1'), isTrue);
        final migrated = goals.firstWhere((g) => g.id == 'proj_legacy_1');
        expect(migrated.title, 'Ship Feature X');
        expect(migrated.milestones.length, 1);
        expect(migrated.milestones.first.title, 'Design UI');
        expect(migrated.milestones.first.isCompleted, isTrue);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.containsKey('notekar_projects_list_v1'), isFalse);
      },
    );

    test(
      'ProjectService facade seamlessly reads and mutates GoalsService',
      () async {
        SharedPreferences.setMockInitialValues({});

        final testGoal = Goal(
          id: 'proj_facade_test',
          title: 'Launch NoteKar',
          category: 'Work',
          targetMinutes: 0,
          createdAt: 1700000000000,
          milestones: const [
            GoalMilestone(
              id: 'm1',
              title: 'Prepare Assets',
              isCompleted: false,
            ),
            GoalMilestone(
              id: 'm2',
              title: 'Publish Release',
              isCompleted: false,
            ),
          ],
        );

        await GoalsService.instance.saveGoal(testGoal);

        // Verify ProjectService reads from GoalsService
        final projects = await ProjectService.instance.getProjects();
        expect(projects.any((p) => p.id == 'proj_facade_test'), isTrue);
        final p = projects.firstWhere((p) => p.id == 'proj_facade_test');
        expect(p.title, 'Launch NoteKar');
        expect(p.milestones.length, 2);

        // Toggle milestone via ProjectService facade
        await ProjectService.instance.toggleMilestone('proj_facade_test', 'm1');

        // Verify GoalsService received the change
        final updatedGoals = await GoalsService.instance.getGoals();
        final updatedGoal = updatedGoals.firstWhere(
          (g) => g.id == 'proj_facade_test',
        );
        expect(updatedGoal.milestones.first.isCompleted, isTrue);
        expect(updatedGoal.completedMilestonesCount, 1);
      },
    );

    test(
      'GoalProgress computes milestone-driven progress for pure checklist targets',
      () {
        final goal = Goal(
          id: 'checklist_goal',
          title: 'Checklist Task',
          targetMinutes: 0,
          createdAt: 1700000000000,
          milestones: const [
            GoalMilestone(id: 'm1', title: 'Step 1', isCompleted: true),
            GoalMilestone(id: 'm2', title: 'Step 2', isCompleted: false),
          ],
        );

        final progress = GoalsService.instance.calculateProgress(goal, []);
        expect(progress.targetMinutes, 0);
        expect(progress.ratio, 0.5);
        expect(progress.isCompleted, isFalse);
        expect(progress.targetFormatted, '2 checkpoints');
        expect(progress.remainingFormatted, '1 left');
        expect(progress.pacingDescription, '1 checkpoint remaining');

        final completedGoal = goal.copyWith(
          milestones: const [
            GoalMilestone(id: 'm1', title: 'Step 1', isCompleted: true),
            GoalMilestone(id: 'm2', title: 'Step 2', isCompleted: true),
          ],
        );
        final completedProgress = GoalsService.instance.calculateProgress(
          completedGoal,
          [],
        );
        expect(completedProgress.ratio, 1.0);
        expect(completedProgress.isCompleted, isTrue);
        expect(completedProgress.pacingDescription, 'Target achieved! 🎉');
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

  group('Unified Target & Project Resiliency Tests', () {
    test(
      'Milestone deletion recalculates isCompleted and completedAt accurately',
      () async {
        SharedPreferences.setMockInitialValues({});
        final g = Goal(
          id: 'g_test_ms',
          title: 'Project X',
          category: 'Work',
          targetMinutes: 0,
          createdAt: 1000,
          milestones: [
            GoalMilestone(id: 'm1', title: 'Phase 1', isCompleted: true),
            GoalMilestone(id: 'm2', title: 'Phase 2', isCompleted: false),
          ],
        );
        await GoalsService.instance.saveGoal(g);

        // Initially not all completed
        var loaded = (await GoalsService.instance.getGoals()).first;
        expect(loaded.isCompleted, isFalse);

        // Delete the incomplete milestone m2 -> remaining milestone m1 is completed
        await GoalsService.instance.deleteMilestone('g_test_ms', 'm2');
        loaded = (await GoalsService.instance.getGoals()).first;
        expect(loaded.isCompleted, isTrue);
        expect(loaded.completedAt, isNotNull);

        // Adding a new milestone marks isCompleted back to false
        await GoalsService.instance.addMilestone('g_test_ms', 'Phase 3');
        loaded = (await GoalsService.instance.getGoals()).first;
        expect(loaded.isCompleted, isFalse);
        expect(loaded.completedAt, isNull);
      },
    );

    test('Goal preserves Apple HIG color and milestone indicators', () {
      final g = Goal(
        id: 'g_styled',
        title: 'Mobile App',
        targetMinutes: 0,
        createdAt: 1000,
        colorHex: '#30B0C7',
        milestones: [
          GoalMilestone(id: 'm1', title: 'Design Mockup', isCompleted: true),
        ],
      );

      expect(g.hasMilestones, isTrue);
      expect(g.colorHex, '#30B0C7');

      final copy = g.copyWith(title: 'Mobile App v2');
      expect(copy.colorHex, '#30B0C7');
      expect(copy.hasMilestones, isTrue);
    });
  });
}
