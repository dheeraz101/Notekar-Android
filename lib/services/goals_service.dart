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

  /// Retrieves all configured goals, seeding high-utility defaults if empty.
  Future<List<Goal>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      final defaultGoals = _createDefaultGoals();
      await _persistGoals(defaultGoals);
      return defaultGoals;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .map((item) => Goal.fromJson(item as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return _createDefaultGoals();
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
      case GoalTimeframe.none:
        final createdDt = DateTime.fromMillisecondsSinceEpoch(goal.createdAt);
        startWindow = DateTime(createdDt.year, createdDt.month, createdDt.day);
        endWindow = DateTime.fromMillisecondsSinceEpoch(8640000000000000);
    }

    final startMs = startWindow.millisecondsSinceEpoch;
    final endMs = endWindow.millisecondsSinceEpoch;

    // Filter moments within timeframe
    final timeFiltered = moments.where((m) {
      return m.timestamp >= startMs && m.timestamp < endMs;
    }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int trackedMs = 0;
    int sessionCount = 0;
    int singleCount = 0;

    // Evaluate sessions (in/out pairs)
    Moment? currentIn;
    for (final m in timeFiltered) {
      if (m.type == 'in') {
        currentIn = m;
      } else if (m.type == 'out' && currentIn != null) {
        if (_matchesCriteria(currentIn, goal, isSession: true)) {
          final sessionDur = math.max(0, m.timestamp - currentIn.timestamp);
          trackedMs += sessionDur;
          sessionCount++;
        }
        currentIn = null;
      } else if (m.type == 'single') {
        if (_matchesCriteria(m, goal, isSession: false)) {
          // Default intentional single moment contribution: 15 minutes
          trackedMs += 15 * 60 * 1000;
          singleCount++;
        }
      }
    }

    // Account for ongoing live session if active
    if (currentIn != null &&
        _matchesCriteria(currentIn, goal, isSession: true)) {
      final ongoingDur = math.max(
        0,
        now.millisecondsSinceEpoch - currentIn.timestamp,
      );
      trackedMs += ongoingDur;
      sessionCount++;
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
      final matches = cat == targetCat || note.contains('#$targetCat');
      if (!matches) return false;
    }

    return true;
  }

  List<Goal> _createDefaultGoals() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      Goal(
        id: 'goal_deep_work',
        title: 'Deep Work Focus',
        category: null,
        mode: 'two-way',
        targetMinutes: 1200, // 20 hours
        timeframe: GoalTimeframe.week,
        createdAt: now,
      ),
      Goal(
        id: 'goal_health',
        title: 'Physical Health & Fitness',
        category: 'Health',
        mode: null,
        targetMinutes: 300, // 5 hours
        timeframe: GoalTimeframe.week,
        createdAt: now,
      ),
    ];
  }

  Future<void> _persistGoals(List<Goal> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }
}
