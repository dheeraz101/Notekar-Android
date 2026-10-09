import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Flagship Goals Engine Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Goal model serialization roundtrip', () {
      final goal = Goal(
        id: 'test_goal_1',
        title: 'Deep Work',
        category: 'Work',
        mode: 'two-way',
        targetMinutes: 600,
        timeframe: GoalTimeframe.week,
        createdAt: 1700000000000,
      );

      final json = goal.toJson();
      final revived = Goal.fromJson(json);

      expect(revived.id, 'test_goal_1');
      expect(revived.title, 'Deep Work');
      expect(revived.category, 'Work');
      expect(revived.mode, 'two-way');
      expect(revived.targetMinutes, 600);
      expect(revived.timeframe, GoalTimeframe.week);
      expect(revived.createdAt, 1700000000000);
      expect(revived.isArchived, false);
    });

    test('GoalsService starts empty without dummy seed goals', () async {
      final goals = await GoalsService.instance.getGoals();
      expect(goals.isEmpty, isTrue);
    });

    test('GoalsService save, archive, and delete lifecycle', () async {
      final service = GoalsService.instance;
      final newGoal = Goal(
        id: 'custom_goal',
        title: 'Morning Yoga',
        category: 'Health',
        targetMinutes: 180,
        timeframe: GoalTimeframe.week,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await service.saveGoal(newGoal);
      var list = await service.getGoals();
      expect(list.any((g) => g.id == 'custom_goal'), isTrue);

      await service.toggleArchiveGoal('custom_goal');
      list = await service.getGoals();
      final archived = list.firstWhere((g) => g.id == 'custom_goal');
      expect(archived.isArchived, isTrue);

      await service.deleteGoal('custom_goal');
      list = await service.getGoals();
      expect(list.any((g) => g.id == 'custom_goal'), isFalse);
    });

    test(
      'Goal progress calculation computes tracked time and deficit correctly',
      () {
        final service = GoalsService.instance;
        final now = DateTime.now();
        final nowMs = now.millisecondsSinceEpoch;

        final goal = Goal(
          id: 'eval_goal',
          title: 'Coding Sprint',
          category: 'Code',
          mode: 'two-way',
          targetMinutes: 120, // 2 hours
          timeframe: GoalTimeframe.none, // all-time
          createdAt: nowMs - 86400000,
        );

        // Create a 1-hour session matching category 'Code'
        final moments = [
          Moment(
            id: 1,
            timestamp: nowMs - 3600000,
            type: 'in',
            category: 'Code',
            date: '2026-09-25',
          ),
          Moment(
            id: 2,
            timestamp: nowMs,
            type: 'out',
            category: 'Code',
            date: '2026-09-25',
          ),
        ];

        final progress = service.calculateProgress(goal, moments);
        expect(progress.trackedMinutes, 60);
        expect(progress.remainingMinutes, 60);
        expect(progress.ratio, closeTo(0.5, 0.05));
        expect(progress.isCompleted, isFalse);
        expect(progress.trackedFormatted, '1h');
        expect(progress.targetFormatted, '2h');
        expect(progress.remainingFormatted, '1h');
      },
    );

    test('Goal progress completes when tracked reaches or exceeds target', () {
      final service = GoalsService.instance;
      final now = DateTime.now();
      final nowMs = now.millisecondsSinceEpoch;

      final goal = Goal(
        id: 'eval_goal_2',
        title: 'Quick Reading',
        category: 'Study',
        targetMinutes: 30,
        timeframe: GoalTimeframe.none,
        createdAt: nowMs - 86400000,
      );

      // Create a 30-minute session matching 'Study'
      final moments = [
        Moment(
          id: 10,
          timestamp: nowMs - 30 * 60 * 1000,
          type: 'in',
          category: 'Study',
          date: '2026-09-25',
        ),
        Moment(
          id: 11,
          timestamp: nowMs,
          type: 'out',
          category: 'Study',
          date: '2026-09-25',
        ),
      ];

      final progress = service.calculateProgress(goal, moments);
      expect(progress.trackedMinutes, 30);
      expect(progress.remainingMinutes, 0);
      expect(progress.ratio, 1.0);
      expect(progress.isCompleted, isTrue);
    });

    test(
      'GoalTimeframe.none only evaluates moments from creation day onwards',
      () {
        final service = GoalsService.instance;
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final yesterday = todayStart.subtract(const Duration(days: 1));

        final goal = Goal(
          id: 'all_time_goal',
          title: 'Future Mastery',
          targetMinutes: 120, // 2h
          timeframe: GoalTimeframe.none,
          createdAt: todayStart.millisecondsSinceEpoch + 1000,
        );

        final moments = [
          // Session logged yesterday retroactively (counted for all-time goals)
          Moment(
            id: 1,
            timestamp: yesterday.millisecondsSinceEpoch + 3600000,
            type: 'in',
            category: 'Work',
            date: 'yesterday',
          ),
          Moment(
            id: 2,
            timestamp: yesterday.millisecondsSinceEpoch + 5400000, // 30m
            type: 'out',
            category: 'Work',
            date: 'yesterday',
          ),
          // Session logged today
          Moment(
            id: 3,
            timestamp: todayStart.millisecondsSinceEpoch + 7200000,
            type: 'in',
            category: 'Work',
            date: 'today',
          ),
          Moment(
            id: 4,
            timestamp: todayStart.millisecondsSinceEpoch + 9000000, // 30m
            type: 'out',
            category: 'Work',
            date: 'today',
          ),
        ];

        final progress = service.calculateProgress(goal, moments);
        // Both sessions (30m + 30m = 60m) are counted for all-time
        expect(progress.trackedMinutes, 60);
        expect(progress.remainingMinutes, 60);
        expect(progress.isCompleted, isFalse);
      },
    );

    test('GoalProgress daily pacing calculations', () {
      final goal = Goal(
        id: 'pacing_goal',
        title: 'Weekly Sprint',
        targetMinutes: 700,
        timeframe: GoalTimeframe.week,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      final progress = GoalProgress(
        goal: goal,
        trackedMinutes: 0,
        sessionCount: 0,
        singleCount: 0,
      );

      expect(progress.daysRemainingInTimeframe, greaterThan(0));
      expect(progress.daysRemainingInTimeframe, lessThanOrEqualTo(7));
      expect(progress.dailyPaceMinutes, greaterThan(0));
      expect(progress.dailyPaceFormatted, isNotEmpty);
      expect(progress.pacingDescription, contains('left this week'));
    });

    test('Goal with dailyTargetMinutes roundtrip and copyWith', () {
      final goal = Goal(
        id: 'daily_alloc_1',
        title: 'Daily Fit',
        category: 'Gym',
        targetMinutes: 1800, // 30 hours in month
        dailyTargetMinutes: 60, // 1h / day
        timeframe: GoalTimeframe.month,
        createdAt: 1700000000000,
      );

      final json = goal.toJson();
      expect(json['dailyTargetMinutes'], 60);

      final revived = Goal.fromJson(json);
      expect(revived.dailyTargetMinutes, 60);

      final updated = revived.copyWith(dailyTargetMinutes: 90);
      expect(updated.dailyTargetMinutes, 90);
      expect(updated.targetMinutes, 1800);
    });

    test('GoalProgress surplus calculation and extra hours celebration', () {
      final goal = Goal(
        id: 'surplus_goal',
        title: 'Sprint',
        targetMinutes: 120, // 2h
        timeframe: GoalTimeframe.week,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Tracked 180m against 120m target -> 60m surplus (1.0h extra)
      final progress = GoalProgress(
        goal: goal,
        trackedMinutes: 180,
        sessionCount: 2,
        singleCount: 0,
      );

      expect(progress.isCompleted, isTrue);
      expect(progress.surplusMinutes, 60);
      expect(progress.surplusFormatted, '1h');
      expect(
        progress.pacingDescription,
        contains('Target achieved! (+1h extra logged 🎉)'),
      );
    });

    test('GoalsService matches moments by hashtag #category in tags', () {
      final service = GoalsService.instance;
      final now = DateTime.now();
      final nowMs = now.millisecondsSinceEpoch;

      final goal = Goal(
        id: 'tag_match_goal',
        title: 'Gym Goal',
        category: 'Gym',
        targetMinutes: 60,
        timeframe: GoalTimeframe.none,
        createdAt: nowMs,
      );

      // Moment with category General but with tag #gym
      final moments = [
        Moment(
          id: 10,
          timestamp: nowMs - 1800000,
          type: 'in',
          category: 'General',
          tags: const ['gym', 'cardio'],
          date: '2026-09-25',
        ),
        Moment(
          id: 11,
          timestamp: nowMs,
          type: 'out',
          category: 'General',
          tags: const ['gym', 'cardio'],
          date: '2026-09-25',
        ),
      ];

      final progress = service.calculateProgress(goal, moments);
      expect(progress.trackedMinutes, 30);
      expect(progress.sessionCount, 1);
    });

    test(
      'GoalsService includes moments logged before goal.createdAt for timeframe none',
      () {
        final service = GoalsService.instance;
        final now = DateTime.now();
        final nowMs = now.millisecondsSinceEpoch;

        // Goal created today
        final goal = Goal(
          id: 'past_moments_goal',
          title: 'Old Goal',
          category: 'Study',
          targetMinutes: 120,
          timeframe: GoalTimeframe.none,
          createdAt: nowMs,
        );

        // Moment logged yesterday (before goal.createdAt)
        final moments = [
          Moment(
            id: 20,
            timestamp: nowMs - (86400000 + 3600000),
            type: 'in',
            category: 'Study',
            date: '2026-09-24',
          ),
          Moment(
            id: 21,
            timestamp: nowMs - 86400000,
            type: 'out',
            category: 'Study',
            date: '2026-09-24',
          ),
        ];

        final progress = service.calculateProgress(goal, moments);
        expect(progress.trackedMinutes, 60);
        expect(progress.sessionCount, 1);
      },
    );
  });
}
