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

  List<Goal> _loadGoalsFromPrefs(SharedPreferences prefs) {
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

  /// Retrieves all configured user goals. Does not seed dummy defaults.
  Future<List<Goal>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('notekar_projects_list_v1')) {
      await autoMigrateLegacyProjects();
    }
    return _loadGoalsFromPrefs(prefs);
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

  /// Toggles a milestone within a goal.
  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    final list = await getGoals();
    final idx = list.indexWhere((g) => g.id == goalId);
    if (idx < 0) return;

    final goal = list[idx];
    final updatedMilestones = goal.milestones.map((m) {
      if (m.id == milestoneId) {
        final nextState = !m.isCompleted;
        return m.copyWith(
          isCompleted: nextState,
          completedAt: nextState ? DateTime.now().millisecondsSinceEpoch : null,
        );
      }
      return m;
    }).toList();

    final allDone =
        updatedMilestones.isNotEmpty &&
        updatedMilestones.every((m) => m.isCompleted);

    list[idx] = goal.copyWith(
      milestones: updatedMilestones,
      isCompleted: allDone,
      completedAt: allDone ? DateTime.now().millisecondsSinceEpoch : null,
    );
    await _persistGoals(list);
  }

  /// Adds a milestone to a goal.
  Future<void> addMilestone(String goalId, String title) async {
    if (title.trim().isEmpty) return;
    final list = await getGoals();
    final idx = list.indexWhere((g) => g.id == goalId);
    if (idx < 0) return;

    final goal = list[idx];
    final newMilestone = GoalMilestone(
      id: 'ms_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
    );
    list[idx] = goal.copyWith(
      milestones: [...goal.milestones, newMilestone],
      isCompleted: false,
    );
    await _persistGoals(list);
  }

  /// Deletes a milestone from a goal.
  Future<void> deleteMilestone(String goalId, String milestoneId) async {
    final list = await getGoals();
    final idx = list.indexWhere((g) => g.id == goalId);
    if (idx < 0) return;

    final goal = list[idx];
    final updated = goal.milestones.where((m) => m.id != milestoneId).toList();
    list[idx] = goal.copyWith(milestones: updated);
    await _persistGoals(list);
  }

  /// Automatically migrates legacy projects into unified Goals without data loss.
  Future<void> autoMigrateLegacyProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('notekar_projects_list_v1');
    if (raw == null || raw.isEmpty) {
      await prefs.remove('notekar_projects_list_v1');
      return;
    }

    // Immediately remove key from SharedPreferences so re-entrant calls are impossible
    await prefs.remove('notekar_projects_list_v1');

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      if (decoded.isEmpty) return;

      final currentGoals = _loadGoalsFromPrefs(prefs);
      bool modified = false;

      for (final item in decoded) {
        final map = item as Map<String, dynamic>;
        final id = map['id'] as String;
        if (!currentGoals.any((g) => g.id == id)) {
          final rawMilestones = map['milestones'] as List<dynamic>?;
          final milestones = rawMilestones != null
              ? rawMilestones
                    .map(
                      (m) => GoalMilestone.fromJson(m as Map<String, dynamic>),
                    )
                    .toList()
              : const <GoalMilestone>[];

          final goal = Goal(
            id: id,
            title: map['title'] as String? ?? 'Project',
            description: map['description'] as String? ?? '',
            category: map['category'] as String?,
            targetMinutes: (map['targetMinutes'] as num?)?.toInt() ?? 0,
            timeframe: map['deadline'] != null
                ? GoalTimeframe.custom
                : GoalTimeframe.none,
            targetDate: (map['deadline'] as num?)?.toInt(),
            createdAt:
                (map['createdAt'] as num?)?.toInt() ??
                DateTime.now().millisecondsSinceEpoch,
            isCompleted: map['isCompleted'] as bool? ?? false,
            completedAt: (map['completedAt'] as num?)?.toInt(),
            milestones: milestones,
            colorHex: map['colorHex'] as String?,
          );
          currentGoals.add(goal);
          modified = true;
        }
      }

      if (modified) {
        await _persistGoals(currentGoals);
      }
    } catch (_) {}
  }

  /// Computes real-time progress and remaining deficit against logged moments.
  GoalProgress calculateProgress(
    Goal goal,
    List<Moment> moments, {
    DateTime? referenceNow,
  }) {
    final now = referenceNow ?? DateTime.now();
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
    // 1. If moment explicitly has a goalId, it only matches that exact goal
    final mGoalId = m.effectiveGoalId;
    if (mGoalId != null && mGoalId.isNotEmpty) {
      return mGoalId == goal.id;
    }

    // 2. Explicit tag for another goal
    final otherGoalTag = m.tags.any(
      (t) => t.startsWith('goal:') && t != 'goal:${goal.id}',
    );
    if (otherGoalTag) {
      return false;
    }

    // 3. Explicit tag for this goal
    if (m.tags.contains('goal:${goal.id}') ||
        m.tags.contains('#goal_${goal.id}')) {
      return true;
    }

    // 4. For time-bounded goals (week, month, etc.) with "All Categories",
    // only sessions explicitly started for this goal count (handled above).
    // This prevents a newly created weekly/monthly goal from instantly completing.
    final isAllCategories =
        goal.category == null ||
        goal.category!.trim().isEmpty ||
        goal.category!.toLowerCase() == 'all';

    if (goal.timeframe != GoalTimeframe.none && isAllCategories) {
      return false;
    }

    // 5. For time-bounded goals with a specific category, moments created before
    // the goal was created must not count towards the goal.
    if (goal.timeframe != GoalTimeframe.none && m.timestamp < goal.createdAt) {
      return false;
    }

    // 6. If goal has no category and timeframe is none (all-time), all moments count
    if (isAllCategories) {
      return true;
    }

    // 7. Match by specific category, tag, or hashtag note
    final cat = goal.category!.trim().toLowerCase();
    final mCat = (m.category ?? '').trim().toLowerCase();
    if (mCat == cat) return true;
    if (m.tags.any((t) {
      final tl = t.trim().toLowerCase();
      return tl == cat || tl == '#$cat';
    })) {
      return true;
    }
    if (m.note.toLowerCase().contains('#$cat')) return true;

    return false;
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
