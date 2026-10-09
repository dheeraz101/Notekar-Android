import 'dart:convert';
import 'dart:math' as math;

import 'package:notekar/models/goal.dart';
import 'package:notekar/models/moment.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing goal configuration and real-time progress calculations.
class GoalsService {
  GoalsService._();
  static final GoalsService instance = GoalsService._();

  static const String _storageKey = 'notekar_goals_list_v1';

  /// Retrieves all configured user goals. Does not seed dummy defaults.
  Future<List<Goal>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .map((item) => Goal.fromJson(item as Map<String, dynamic>))
          .where(
            (g) => g.id != 'goal_deep_work_weekly' && g.id != 'goal_health',
          )
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Saves or updates a goal.
  Future<void> saveGoal(Goal goal) async {
    final list = await getGoals();
    final idx = list.indexWhere((g) => g.id == goal.id);
    if (idx >= 0) {
      list[idx] = goal;
    } else {
      list.insert(0, goal);
    }
    await _persistGoals(list);
  }

  /// Deletes a goal by ID.
  Future<void> deleteGoal(String id) async {
    final list = await getGoals();
    list.removeWhere((g) => g.id == id);
    await _persistGoals(list);
  }

  /// Toggles archived state for a goal.
  Future<void> toggleArchiveGoal(String id) async {
    final list = await getGoals();
    final idx = list.indexWhere((g) => g.id == id);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(isArchived: !list[idx].isArchived);
      await _persistGoals(list);
    }
  }

  /// Computes real-time progress and remaining deficit against logged moments.
  GoalProgress calculateProgress(Goal goal, List<Moment> moments) {
    final now = DateTime.now();
    final DateTime startWindow;
    final DateTime endWindow;

    switch (goal.timeframe) {
      case GoalTimeframe.week:
        final monday = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        startWindow = monday;
        endWindow = monday.add(const Duration(days: 7));
      case GoalTimeframe.month:
        startWindow = DateTime(now.year, now.month, 1);
        endWindow = DateTime(now.year, now.month + 1, 1);
      case GoalTimeframe.year:
        startWindow = DateTime(now.year, 1, 1);
        endWindow = DateTime(now.year + 1, 1, 1);
      case GoalTimeframe.custom:
        startWindow = DateTime(2000, 1, 1);
        if (goal.targetDate != null) {
          final targetDt = DateTime.fromMillisecondsSinceEpoch(
            goal.targetDate!,
          );
          endWindow = DateTime(
            targetDt.year,
            targetDt.month,
            targetDt.day,
            23,
            59,
            59,
            999,
          );
        } else {
          endWindow = DateTime.fromMillisecondsSinceEpoch(8640000000000000);
        }
      case GoalTimeframe.none:
        startWindow = DateTime(2000, 1, 1);
        endWindow = DateTime.fromMillisecondsSinceEpoch(8640000000000000);
    }

    final startMs = startWindow.millisecondsSinceEpoch;
    final endMs = endWindow.millisecondsSinceEpoch;

    final chronoSorted = List<Moment>.from(moments)
      ..sort((a, b) {
        final cmp = a.timestamp.compareTo(b.timestamp);
        if (cmp != 0) return cmp;
        if (a.type == 'in' && b.type != 'in') return -1;
        if (b.type == 'in' && a.type != 'in') return 1;
        return a.id.compareTo(b.id);
      });

    int trackedMs = 0;
    int sessionCount = 0;
    int singleCount = 0;

    Moment? currentIn;
    for (final m in chronoSorted) {
      if (m.type == 'in') {
        if (currentIn != null &&
            _matchesCriteria(currentIn, goal, isSession: true)) {
          // Account for unclosed previous session interrupted by new IN
          final sStart = currentIn.timestamp;
          final sEnd = m.timestamp;
          final overlapStart = math.max(startMs, sStart);
          final overlapEnd = math.min(endMs, sEnd);
          if (overlapEnd > overlapStart) {
            trackedMs += (overlapEnd - overlapStart);
            sessionCount++;
          }
        }
        currentIn = m;
      } else if (m.type == 'out') {
        if (currentIn != null) {
          if (_matchesCriteria(currentIn, goal, isSession: true)) {
            final sStart = currentIn.timestamp;
            final sEnd = m.timestamp;
            final overlapStart = math.max(startMs, sStart);
            final overlapEnd = math.min(endMs, sEnd);
            if (overlapEnd > overlapStart) {
              trackedMs += (overlapEnd - overlapStart);
              sessionCount++;
            }
          }
          currentIn = null;
        }
      } else if (m.type == 'single') {
        if (m.timestamp >= startMs && m.timestamp < endMs) {
          if (_matchesCriteria(m, goal, isSession: false)) {
            singleCount++;
          }
        }
      }
    }

    // Account for ongoing live session if active
    if (currentIn != null &&
        _matchesCriteria(currentIn, goal, isSession: true)) {
      final sStart = currentIn.timestamp;
      final sEnd = now.millisecondsSinceEpoch;
      final overlapStart = math.max(startMs, sStart);
      final overlapEnd = math.min(endMs, sEnd);
      if (overlapEnd > overlapStart) {
        trackedMs += (overlapEnd - overlapStart);
        sessionCount++;
      }
    }

    final trackedMinutes = (trackedMs / (1000 * 60)).round();

    return GoalProgress(
      goal: goal,
      trackedMinutes: trackedMinutes,
      sessionCount: sessionCount,
      singleCount: singleCount,
    );
  }

  bool _matchesCriteria(Moment m, Goal goal, {required bool isSession}) {
    // Mode filter
    if (goal.mode != null && goal.mode!.isNotEmpty) {
      if (goal.mode == 'two-way' && !isSession) return false;
      if (goal.mode == 'single' && isSession) return false;
    }

    // Category filter
    if (goal.category != null && goal.category!.isNotEmpty) {
      final targetCat = goal.category!.toLowerCase();
      final cat = m.category?.toLowerCase() ?? '';
      final note = m.note.toLowerCase();
      final inTags = m.tags.any((t) {
        final tl = t.toLowerCase();
        return tl == targetCat || tl == '#$targetCat';
      });
      final matches =
          cat == targetCat || note.contains('#$targetCat') || inTags;
      if (!matches) return false;
    }

    return true;
  }

  Future<void> _persistGoals(List<Goal> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }
}
