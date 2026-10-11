import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:notekar/models/project.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing short-term initiatives, milestones, and project sessions in NoteKar.
class ProjectService {
  ProjectService._();

  static final ProjectService instance = ProjectService._();

  static const String _storageKey = 'notekar_projects_list_v1';

  final ValueNotifier<List<Project>> projectsNotifier =
      ValueNotifier<List<Project>>([]);

  bool _isInitialized = false;

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

  /// Retrieves all configured projects from persistent storage.
  Future<List<Project>> getProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .map((item) => Project.fromJson(item as Map<String, dynamic>))
          .toList();
      projectsNotifier.value = list;
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Saves or updates a project.
  Future<void> saveProject(Project project) async {
    final list = await getProjects();
    final idx = list.indexWhere((p) => p.id == project.id);
    if (idx >= 0) {
      list[idx] = project;
    } else {
      list.insert(0, project);
    }
    await _persistProjects(list);
  }

  /// Deletes a project by ID.
  Future<void> deleteProject(String id) async {
    final list = await getProjects();
    list.removeWhere((p) => p.id == id);
    await _persistProjects(list);
  }

  /// Toggles the completion status of a project.
  Future<void> toggleProjectCompletion(String id) async {
    final list = await getProjects();
    final idx = list.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      final current = list[idx];
      final newStatus = !current.isCompleted;
      list[idx] = current.copyWith(
        isCompleted: newStatus,
        completedAt: newStatus ? DateTime.now().millisecondsSinceEpoch : null,
      );
      await _persistProjects(list);
    }
  }

  /// Toggles the completion status of a milestone within a project.
  Future<void> toggleMilestone(String projectId, String milestoneId) async {
    final list = await getProjects();
    final pIdx = list.indexWhere((p) => p.id == projectId);
    if (pIdx < 0) return;

    final project = list[pIdx];
    final updatedMilestones = project.milestones.map((m) {
      if (m.id == milestoneId) {
        final newCompleted = !m.isCompleted;
        return m.copyWith(
          isCompleted: newCompleted,
          completedAt: newCompleted
              ? DateTime.now().millisecondsSinceEpoch
              : null,
        );
      }
      return m;
    }).toList();

    // If all milestones are completed, auto-mark project completed if user has milestones
    final allMilestonesDone =
        updatedMilestones.isNotEmpty &&
        updatedMilestones.every((m) => m.isCompleted);

    list[pIdx] = project.copyWith(
      milestones: updatedMilestones,
      isCompleted: allMilestonesDone ? true : project.isCompleted,
      completedAt: allMilestonesDone && project.completedAt == null
          ? DateTime.now().millisecondsSinceEpoch
          : project.completedAt,
    );

    await _persistProjects(list);
  }

  /// Adds a new milestone to an existing project.
  Future<void> addMilestone(String projectId, String title) async {
    final list = await getProjects();
    final pIdx = list.indexWhere((p) => p.id == projectId);
    if (pIdx < 0) return;

    final project = list[pIdx];
    final newMilestone = ProjectMilestone(
      id: 'ms_${DateTime.now().millisecondsSinceEpoch}_${project.milestones.length}',
      title: title.trim(),
    );

    list[pIdx] = project.copyWith(
      milestones: [...project.milestones, newMilestone],
    );

    await _persistProjects(list);
  }

  /// Deletes a milestone from a project.
  Future<void> deleteMilestone(String projectId, String milestoneId) async {
    final list = await getProjects();
    final pIdx = list.indexWhere((p) => p.id == projectId);
    if (pIdx < 0) return;

    final project = list[pIdx];
    final updatedMilestones = project.milestones
        .where((m) => m.id != milestoneId)
        .toList();

    list[pIdx] = project.copyWith(milestones: updatedMilestones);
    await _persistProjects(list);
  }

  Future<void> _persistProjects(List<Project> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
    projectsNotifier.value = List.unmodifiable(list);
  }
}
