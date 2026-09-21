import 'dart:math' as math;

import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakGuardianStatus {
  const StreakGuardianStatus({
    required this.currentStreak,
    required this.bankedGraceDays,
    required this.graceAppliedToday,
    required this.lastGraceDate,
  });

  final int currentStreak;
  final int bankedGraceDays;
  final bool graceAppliedToday;
  final String? lastGraceDate;
}

/// Ethical, non-punitive streak guardian that protects user momentum.
/// Automatically banks 1 Sabbath / Grace Day per 14 active days (max 2),
/// preventing accidental despair and app abandonment after sickness or travel.
class StreakGuardianService {
  factory StreakGuardianService() => _instance;

  StreakGuardianService._internal();

  static final StreakGuardianService _instance =
      StreakGuardianService._internal();

  static const String _keyBankedGrace = 'notekar.streak_grace_banked';
  static const String _keyLastGraceDate = 'notekar.streak_last_grace_date';
  static const String _keyHighestEarnedMilestone =
      'notekar.streak_last_earned_threshold';

  /// Evaluates streaks against moment entries, automatically absorbing missed days
  /// if the user has earned grace days.
  Future<StreakGuardianStatus> evaluateStreak(List<Moment> moments) async {
    final prefs = await SharedPreferences.getInstance();
    int banked = prefs.getInt(_keyBankedGrace) ?? 1; // 1 starter welcome grace
    String? lastGraceDate = prefs.getString(_keyLastGraceDate);
    final lastEarnedThreshold = prefs.getInt(_keyHighestEarnedMilestone) ?? 0;

    final now = DateTime.now();
    final todayKey = dateKey(now);
    final yesterdayKey = dateKey(now.subtract(const Duration(days: 1)));
    final twoDaysAgoKey = dateKey(now.subtract(const Duration(days: 2)));

    // Group moments by date
    final activeDates = <String>{};
    for (final m in moments) {
      activeDates.add(m.date);
    }

    // Check if grace was already applied for yesterday
    bool graceApplied = (lastGraceDate == yesterdayKey);

    // If yesterday had no moments, but day before yesterday had moments and yesterday was not graced
    final hadYesterday = activeDates.contains(yesterdayKey);
    final hadTwoDaysAgo = activeDates.contains(twoDaysAgoKey);

    if (!hadYesterday && hadTwoDaysAgo && !graceApplied && banked > 0) {
      // Automatically deploy 1 grace day to protect streak
      banked = math.max(0, banked - 1);
      lastGraceDate = yesterdayKey;
      graceApplied = true;
      await prefs.setInt(_keyBankedGrace, banked);
      await prefs.setString(_keyLastGraceDate, yesterdayKey);
    }

    // Calculate unbroken streak factoring in active dates and lastGraceDate
    int streak = 0;
    var checkDate = activeDates.contains(todayKey)
        ? now
        : now.subtract(const Duration(days: 1));

    while (true) {
      final key = dateKey(checkDate);
      if (activeDates.contains(key) || key == lastGraceDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Bank new grace days for every 14 days of streak (max 2 banked)
    final earnedGraceTotal = (streak / 14).floor();
    if (earnedGraceTotal > lastEarnedThreshold) {
      banked = math.min(2, banked + (earnedGraceTotal - lastEarnedThreshold));
      await prefs.setInt(_keyBankedGrace, banked);
      await prefs.setInt(_keyHighestEarnedMilestone, earnedGraceTotal);
    }

    return StreakGuardianStatus(
      currentStreak: streak,
      bankedGraceDays: banked,
      graceAppliedToday: graceApplied,
      lastGraceDate: lastGraceDate,
    );
  }

  /// Synchronous streak calculation taking an optional grace date into account.
  static int calculateStreak(
    Set<String> activeDates, {
    String? protectedGraceDate,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final todayKey = dateKey(now);

    int streak = 0;
    var checkDate = activeDates.contains(todayKey)
        ? now
        : now.subtract(const Duration(days: 1));

    while (true) {
      final key = dateKey(checkDate);
      if (activeDates.contains(key) ||
          (protectedGraceDate != null && key == protectedGraceDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
