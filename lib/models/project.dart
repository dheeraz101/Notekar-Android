import 'package:notekar/models/moment.dart';
import 'package:notekar/services/universal_interval_ledger.dart';

/// A milestone or checkpoint within a short-term project.
class ProjectMilestone {
  const ProjectMilestone({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final int? completedAt; // epoch ms

  ProjectMilestone copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? completedAt,
  }) {
    return ProjectMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'completedAt': completedAt,
  };

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) =>
      ProjectMilestone(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] as int?,
      );
}

/// Represents a short-term initiative or milestone-driven project in NoteKar.
///
/// Distinct from long-term recurring goals (e.g., "50 hours of deep work"),
/// projects represent temporary commitments with specific milestones
/// (e.g., "Finish reading Clean Architecture", "Design Logo v2", "Learn French A1").
class Project {
  const Project({
    required this.id,
    required this.title,
    this.description = '',
    this.category,
    this.targetMinutes = 0,
    this.deadline,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
    this.milestones = const [],
    this.linkedGoalId,
    this.colorHex,
  });

  final String id;
  final String title;
  final String description;
  final String? category;
  final int targetMinutes;
  final int? deadline; // epoch ms
  final int createdAt; // epoch ms
  final bool isCompleted;
  final int? completedAt; // epoch ms
  final List<ProjectMilestone> milestones;
  final String? linkedGoalId;
  final String? colorHex;

  Duration get targetDuration => Duration(minutes: targetMinutes);

  int get targetHours => (targetMinutes / 60).round();

  int get completedMilestonesCount =>
      milestones.where((m) => m.isCompleted).length;

  double get milestoneProgress {
    if (milestones.isEmpty) return isCompleted ? 1.0 : 0.0;
    return completedMilestonesCount / milestones.length;
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? targetMinutes,
    int? deadline,
    int? createdAt,
    bool? isCompleted,
    int? completedAt,
    List<ProjectMilestone>? milestones,
    String? linkedGoalId,
    String? colorHex,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      milestones: milestones ?? this.milestones,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'targetMinutes': targetMinutes,
    'deadline': deadline,
    'createdAt': createdAt,
    'isCompleted': isCompleted,
    'completedAt': completedAt,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'linkedGoalId': linkedGoalId,
    'colorHex': colorHex,
  };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String,
    title: json['title'] as String,
    description: (json['description'] as String?) ?? '',
    category: json['category'] as String?,
    targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 0,
    deadline: json['deadline'] as int?,
    createdAt: (json['createdAt'] as num).toInt(),
    isCompleted: json['isCompleted'] as bool? ?? false,
    completedAt: json['completedAt'] as int?,
    milestones:
        (json['milestones'] as List<dynamic>?)
            ?.map((m) => ProjectMilestone.fromJson(m as Map<String, dynamic>))
            .toList() ??
        const [],
    linkedGoalId: json['linkedGoalId'] as String?,
    colorHex: json['colorHex'] as String?,
  );

  /// Computes cumulative time tracked against this project across entries.
  Duration computeTrackedDuration(List<Moment> moments) {
    try {
      final intervals = UniversalIntervalLedger.instance.computeIntervals(
        moments,
      );
      int totalMs = 0;
      for (final interval in intervals) {
        final matchesProject =
            interval.tags.contains('proj:$id') ||
            (category != null &&
                category!.trim().isNotEmpty &&
                interval.category.toLowerCase() ==
                    category!.trim().toLowerCase());
        if (matchesProject) {
          totalMs += interval.durationMs;
        }
      }
      return Duration(milliseconds: totalMs);
    } catch (_) {
      int totalMs = 0;
      final inMap = <int, Moment>{};
      for (final m in moments) {
        if (m.effectiveProjectId == id ||
            (category != null &&
                m.effectiveCategory.toLowerCase() == category!.toLowerCase())) {
          if (m.type == 'in') {
            inMap[m.id] = m;
          } else if (m.type == 'out') {
            final inMoment = inMap.remove(m.id);
            if (inMoment != null) {
              final diff = m.timestamp - inMoment.timestamp;
              if (diff > 0) totalMs += diff;
            }
          }
        }
      }
      return Duration(milliseconds: totalMs);
    }
  }
}
