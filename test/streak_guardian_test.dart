import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/streak_guardian_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StreakGuardianService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'maintains active streak when moments exist for consecutive days',
      () async {
        final now = DateTime.now();
        final moments = [
          Moment(
            id: 1,
            timestamp: now.millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(now),
          ),
          Moment(
            id: 2,
            timestamp: now
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(now.subtract(const Duration(days: 1))),
          ),
          Moment(
            id: 3,
            timestamp: now
                .subtract(const Duration(days: 2))
                .millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(now.subtract(const Duration(days: 2))),
          ),
        ];

        final status = await StreakGuardianService().evaluateStreak(moments);
        expect(status.currentStreak, equals(3));
        expect(status.graceAppliedToday, isFalse);
      },
    );

    test(
      'automatically deploys a banked grace day to protect streak if yesterday was missed',
      () async {
        final now = DateTime.now();
        // Missed yesterday, but logged 2 days ago and today
        final moments = [
          Moment(
            id: 1,
            timestamp: now.millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(now),
          ),
          Moment(
            id: 2,
            timestamp: now
                .subtract(const Duration(days: 2))
                .millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(now.subtract(const Duration(days: 2))),
          ),
        ];

        final status = await StreakGuardianService().evaluateStreak(moments);
        expect(status.graceAppliedToday, isTrue);
        // Streak includes today (1), graced yesterday (2), and two days ago (3)
        expect(status.currentStreak, equals(3));
        expect(status.bankedGraceDays, equals(0)); // 1 used from default 1
      },
    );

    test('calculateStreak static helper respects protectedGraceDate', () {
      final now = DateTime.now();
      final todayKey = dateKey(now);
      final yesterdayKey = dateKey(now.subtract(const Duration(days: 1)));
      final twoDaysAgoKey = dateKey(now.subtract(const Duration(days: 2)));

      final activeDates = {todayKey, twoDaysAgoKey};

      // Without grace date, streak is just 1 (breaks at yesterday)
      final streakWithoutGrace = StreakGuardianService.calculateStreak(
        activeDates,
      );
      expect(streakWithoutGrace, equals(1));

      // With protectedGraceDate bridging yesterday, streak continues to 3
      final streakWithGrace = StreakGuardianService.calculateStreak(
        activeDates,
        protectedGraceDate: yesterdayKey,
      );
      expect(streakWithGrace, equals(3));
    });
  });
}
