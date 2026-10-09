import 'dart:convert';
import 'dart:math' as math;

import 'package:notekar/models/goal.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/services/universal_interval_ledger.dart';
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

    // Filter moments relevant to THIS specific goal
    final goalMoments = moments
        .where((m) => _matchesCriteria(m, goal))
        .toList();

    // Reconstruct canonical intervals using UniversalIntervalLedger (handles multi-track state and midnight slicing)
    final intervals = UniversalIntervalLedger.reconstructAndSlice(
      goalMoments,
      referenceNow: now,
    );

    int trackedMs = 0;
    int archivedMs = 0;
    int sessionCount = 0;
    int singleCount = 0;

    for (final it in intervals) {
      if (it.isSession) {
        if (it.startMs >= startMs && it.endMs <= endMs) {
          trackedMs += it.durationMs;
          sessionCount++;
        } else {
          // Bounded overlap with evaluation window
          final overlapStart = math.max(startMs, it.startMs);
          final overlapEnd = math.min(endMs, it.endMs);
          if (overlapEnd > overlapStart) {
            trackedMs += (overlapEnd - overlapStart);
            sessionCount++;
          }
          if (it.endMs <= startMs) {
            archivedMs += it.durationMs;
          }
        }
      } else {
        if (it.startMs >= startMs && it.startMs < endMs) {
          singleCount++;
        } else if (it.startMs < startMs) {
          archivedMs += 15 * 60 * 1000;
        }
      }
    }

    final trackedMinutes = (trackedMs / (1000 * 60)).round();
    final archivedMinutes = (archivedMs / (1000 * 60)).round();

    return GoalProgress(
      goal: goal,
      trackedMinutes: trackedMinutes,
      sessionCount: sessionCount,
      singleCount: singleCount,
      archivedMinutes: archivedMinutes,
    );
  }

  /// Determines whether a moment attributes to this goal.
  bool _matchesCriteria(Moment m, Goal goal) {
    // 1. Strict explicit goal ID match
    final mGoalId = m.effectiveGoalId;
    if (mGoalId != null && mGoalId.isNotEmpty) {
      return mGoalId == goal.id;
    }

    // 2. Explicit tag match
    if (m.tags.contains('goal:${goal.id}') ||
        m.tags.contains('#goal_${goal.id}')) {
      return true;
    }

    // 3. Category match fallback for existing un-tagged historical moments
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

  /// One-time migration attributing historical moments to matching user goals.
  Future<int> migrateHistoricalMomentsToGoals(
    List<Moment> moments, {
    Future<void> Function(Moment updated)? onSaveMoment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    const migrationKey = 'notekar_goals_migrated_v2';
    if (prefs.getBool(migrationKey) ?? false) {
      return 0;
    }

    final goals = await getGoals();
    if (goals.isEmpty || moments.isEmpty) {
      await prefs.setBool(migrationKey, true);
      return 0;
    }

    int migratedCount = 0;
    for (final m in moments) {
      if (m.effectiveGoalId != null) continue;
      for (final g in goals) {
        if (!g.isArchived && g.category != null && g.category!.isNotEmpty) {
          final cat = g.category!.toLowerCase();
          final mCat = m.category?.toLowerCase() ?? '';
          if (cat == mCat ||
              m.tags.any((t) => t.toLowerCase() == cat) ||
              m.note.toLowerCase().contains('#$cat')) {
            m.goalId = g.id;
            if (!m.tags.contains('goal:${g.id}')) {
              m.tags = [...m.tags, 'goal:${g.id}'];
            }
            if (onSaveMoment != null) {
              await onSaveMoment(m);
            }
            migratedCount++;
            break;
          }
        }
      }
    }

    await prefs.setBool(migrationKey, true);
    return migratedCount;
  }

  Future<void> _persistGoals(List<Goal> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }
}
