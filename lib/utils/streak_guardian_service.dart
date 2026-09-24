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
    this.isVacationActive = false,
    this.vacationStartDate,
    this.vacationEndDate,
    this.restDays = const [],
  });

  final int currentStreak;
  final int bankedGraceDays;
  final bool graceAppliedToday;
  final String? lastGraceDate;
  final bool isVacationActive;
  final String? vacationStartDate;
  final String? vacationEndDate;
  final List<int> restDays;
}

/// Ethical, non-punitive streak guardian that protects user momentum.
/// Features:
/// 1. Banked Grace / Sabbath Days (1 per 14 active days, max 2)
/// 2. Vacation Mode: Neutral window where streak pauses without penalty
/// 3. Sabbath / Rest-Days: Configurable weekly recovery days (e.g. Sunday) that never break streak
class StreakGuardianService {
  factory StreakGuardianService() => _instance;

  StreakGuardianService._internal();

  static final StreakGuardianService _instance =
      StreakGuardianService._internal();

  static const String _keyBankedGrace = 'notekar.streak_grace_banked';
  static const String _keyLastGraceDate = 'notekar.streak_last_grace_date';
  static const String _keyHighestEarnedMilestone =
      'notekar.streak_last_earned_threshold';
  static const String _keyVacationStart = 'notekar.streak_vacation_start';
  static const String _keyVacationEnd = 'notekar.streak_vacation_end';
  static const String _keyRestDays = 'notekar.streak_rest_days';

  /// Save vacation window dates (YYYY-MM-DD format)
  Future<void> setVacationRange(DateTime? start, DateTime? end) async {
    final prefs = await SharedPreferences.getInstance();
    if (start != null && end != null) {
      await prefs.setString(_keyVacationStart, dateKey(start));
      await prefs.setString(_keyVacationEnd, dateKey(end));
    } else {
      await prefs.remove(_keyVacationStart);
      await prefs.remove(_keyVacationEnd);
    }
  }

  /// Save weekly rest days (1 = Monday, ..., 7 = Sunday)
  Future<void> setRestDays(List<int> weekdays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRestDays, weekdays.join(','));
  }

  /// Evaluates streaks against moment entries, factoring in vacation neutrality,
  /// rest days, and banked grace days.
  Future<StreakGuardianStatus> evaluateStreak(List<Moment> moments) async {
    final prefs = await SharedPreferences.getInstance();
    int banked = prefs.getInt(_keyBankedGrace) ?? 1; // 1 starter welcome grace
    String? lastGraceDate = prefs.getString(_keyLastGraceDate);
    final lastEarnedThreshold = prefs.getInt(_keyHighestEarnedMilestone) ?? 0;

    final vacStartStr = prefs.getString(_keyVacationStart);
    final vacEndStr = prefs.getString(_keyVacationEnd);
    final restDaysStr = prefs.getString(_keyRestDays);
    final restDays = restDaysStr != null && restDaysStr.isNotEmpty
        ? restDaysStr
              .split(',')
              .map((s) => int.tryParse(s.trim()))
              .whereType<int>()
              .toList()
        : <int>[];

    final now = DateTime.now();
    final todayKey = dateKey(now);
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayKey = dateKey(yesterday);
    final twoDaysAgoKey = dateKey(now.subtract(const Duration(days: 2)));

    // Group moments by date
    final activeDates = <String>{};
    for (final m in moments) {
      activeDates.add(m.date);
    }

    // Check if current date is inside vacation
    bool isVacationActive = false;
    if (vacStartStr != null && vacEndStr != null) {
      final startDt = DateTime.tryParse(vacStartStr);
      final endDt = DateTime.tryParse(vacEndStr);
      if (startDt != null && endDt != null) {
        final curOnlyDate = DateTime(now.year, now.month, now.day);
        isVacationActive =
            (curOnlyDate.isAfter(startDt.subtract(const Duration(days: 1))) &&
            curOnlyDate.isBefore(endDt.add(const Duration(days: 1))));
      }
    }

    // Helper to check if a specific day is neutral
    bool isDateNeutral(DateTime dt) {
      // 1. Rest day
      if (restDays.contains(dt.weekday)) return true;

      // 2. Vacation day
      if (vacStartStr != null && vacEndStr != null) {
        final startDt = DateTime.tryParse(vacStartStr);
        final endDt = DateTime.tryParse(vacEndStr);
        if (startDt != null && endDt != null) {
          final target = DateTime(dt.year, dt.month, dt.day);
          if (target.isAfter(startDt.subtract(const Duration(days: 1))) &&
              target.isBefore(endDt.add(const Duration(days: 1)))) {
            return true;
          }
        }
      }
      return false;
    }

    // Check if grace was already applied for yesterday
    bool graceApplied = (lastGraceDate == yesterdayKey);

    // If yesterday had no moments, but day before had moments, and yesterday was neither graced nor neutral
    final hadYesterday = activeDates.contains(yesterdayKey);
    final hadTwoDaysAgo = activeDates.contains(twoDaysAgoKey);
    final yesterdayIsNeutral = isDateNeutral(yesterday);

    if (!hadYesterday &&
        !yesterdayIsNeutral &&
        hadTwoDaysAgo &&
        !graceApplied &&
        banked > 0) {
      // Automatically deploy 1 grace day to protect streak
      banked = math.max(0, banked - 1);
      lastGraceDate = yesterdayKey;
      graceApplied = true;
      await prefs.setInt(_keyBankedGrace, banked);
      await prefs.setString(_keyLastGraceDate, yesterdayKey);
    }

    // Calculate unbroken streak factoring in active dates, neutral days, and grace date
    int streak = 0;
    var checkDate = activeDates.contains(todayKey)
        ? now
        : (isDateNeutral(now) ? now : now.subtract(const Duration(days: 1)));

    while (true) {
      final key = dateKey(checkDate);
      final isNeutral = isDateNeutral(checkDate);

      if (activeDates.contains(key) || key == lastGraceDate || isNeutral) {
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
      isVacationActive: isVacationActive,
      vacationStartDate: vacStartStr,
      vacationEndDate: vacEndStr,
      restDays: restDays,
    );
  }

  /// Synchronous streak calculation taking optional grace date and neutral rest days into account.
  static int calculateStreak(
    Set<String> activeDates, {
    String? protectedGraceDate,
    DateTime? referenceDate,
    List<int> restDays = const [],
  }) {
    final now = referenceDate ?? DateTime.now();
    final todayKey = dateKey(now);

    int streak = 0;
    var checkDate = activeDates.contains(todayKey)
        ? now
        : now.subtract(const Duration(days: 1));

    while (true) {
      final key = dateKey(checkDate);
      final isRestDay = restDays.contains(checkDate.weekday);

      if (activeDates.contains(key) ||
          (protectedGraceDate != null && key == protectedGraceDate) ||
          isRestDay) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
