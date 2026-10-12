import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/project.dart';
import 'package:notekar/services/goals_service.dart';

/// Compatibility facade managing projects by delegating directly to the unified [GoalsService].
///
/// Ensures short-term initiatives, milestones, and project sessions are 100% synchronized
/// with NoteKar's Apple HIG Targets and Goals engine with zero split-brain or data loss.
class ProjectService {
  ProjectService._();

  static final ProjectService instance = ProjectService._();

  final ValueNotifier<List<Project>> projectsNotifier =
      ValueNotifier<List<Project>>([]);

  bool _isInitialized = false;

  Project _goalToProject(Goal g) {
    return Project(
      id: g.id,
      title: g.title,
      description: g.description,
      category: g.category,
      targetMinutes: g.targetMinutes,
      deadline: g.targetDate,
      createdAt: g.createdAt,
      isCompleted: g.isCompleted,
      completedAt: g.completedAt,
      linkedGoalId: g.id,
      colorHex: g.colorHex,
      milestones: g.milestones
          .map(
            (m) => ProjectMilestone(
              id: m.id,
              title: m.title,
              isCompleted: m.isCompleted,
              completedAt: m.completedAt,
            ),
          )
          .toList(),
    );
  }

  Goal _projectToGoal(Project p) {
    return Goal(
      id: p.id,
      title: p.title,
      description: p.description,
      category: p.category,
      mode: 'two-way',
      targetMinutes: p.targetMinutes,
      timeframe: p.deadline != null ? GoalTimeframe.custom : GoalTimeframe.none,
      targetDate: p.deadline,
      createdAt: p.createdAt,
      isCompleted: p.isCompleted,
      completedAt: p.completedAt,
      colorHex: p.colorHex,
      milestones: p.milestones
          .map(
            (m) => GoalMilestone(
              id: m.id,
              title: m.title,
              isCompleted: m.isCompleted,
              completedAt: m.completedAt,
            ),
          )
          .toList(),
    );
  }

  /// Ensures projects are loaded into memory and [projectsNotifier] is primed.
  Future<List<Project>> ensureInitialized() async {
    if (!_isInitialized) {
      final list = await getProjects();
      projectsNotifier.value = list;
      _isInitialized = true;
      return list;
    }
    return projectsNotifier.value;
  }

  /// Retrieves all configured projects from the unified [GoalsService].
  Future<List<Project>> getProjects() async {
    final goals = await GoalsService.instance.getGoals();
    final list = goals.map(_goalToProject).toList();
    projectsNotifier.value = List.unmodifiable(list);
    return list;
  }

  /// Saves or updates a project within the unified [GoalsService].
  Future<void> saveProject(Project project) async {
    final goal = _projectToGoal(project);
    await GoalsService.instance.saveGoal(goal);
    await getProjects();
  }

  /// Deletes a project by ID from the unified [GoalsService].
  Future<void> deleteProject(String id) async {
    await GoalsService.instance.deleteGoal(id);
    await getProjects();
  }

  /// Toggles the completion status of a project.
  Future<void> toggleProjectCompletion(String id) async {
    final goals = await GoalsService.instance.getGoals();
    final idx = goals.indexWhere((g) => g.id == id);
    if (idx >= 0) {
      final current = goals[idx];
      final newStatus = !current.isCompleted;
      await GoalsService.instance.saveGoal(
        current.copyWith(
          isCompleted: newStatus,
          completedAt: newStatus ? DateTime.now().millisecondsSinceEpoch : null,
        ),
      );
      await getProjects();
    }
  }

  /// Toggles the completion status of a milestone within a project.
  Future<void> toggleMilestone(String projectId, String milestoneId) async {
    await GoalsService.instance.toggleMilestone(projectId, milestoneId);
    await getProjects();
  }

  /// Adds a new milestone to an existing project.
  Future<void> addMilestone(String projectId, String title) async {
    await GoalsService.instance.addMilestone(projectId, title);
    await getProjects();
  }

  /// Deletes a milestone from a project.
  Future<void> deleteMilestone(String projectId, String milestoneId) async {
    await GoalsService.instance.deleteMilestone(projectId, milestoneId);
    await getProjects();
  }
}
