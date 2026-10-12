import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Supported target evaluation timeframes for Apple HIG Goals Engine.
enum GoalTimeframe {
  week,
  month,
  year,
  custom,
  none;

  String get label => switch (this) {
    GoalTimeframe.week => 'Weekly',
    GoalTimeframe.month => 'Monthly',
    GoalTimeframe.year => 'Yearly',
    GoalTimeframe.custom => 'Custom Date',
    GoalTimeframe.none => 'All Time',
  };

  static GoalTimeframe fromString(String? val) {
    return switch (val) {
      'week' => GoalTimeframe.week,
      'month' => GoalTimeframe.month,
      'year' => GoalTimeframe.year,
      'custom' => GoalTimeframe.custom,
      _ => GoalTimeframe.none,
    };
  }
}

/// Represents an actionable checkpoint / milestone within a Goal or Project.
class GoalMilestone {
  const GoalMilestone({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final int? completedAt; // epoch ms

  GoalMilestone copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? completedAt,
  }) {
    return GoalMilestone(
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

  factory GoalMilestone.fromJson(Map<String, dynamic> json) => GoalMilestone(
    id: json['id'] as String? ?? UniqueKey().toString(),
    title: (json['title'] as String? ?? '').trim(),
    isCompleted: json['isCompleted'] as bool? ?? false,
    completedAt: (json['completedAt'] as num?)?.toInt(),
  );
}

/// Represents an intentional allocation target or milestone initiative in Notekar.
class Goal {
  const Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.category,
    this.mode,
    required this.targetMinutes,
    this.dailyTargetMinutes,
    this.timeframe = GoalTimeframe.week,
    this.targetDate,
    required this.createdAt,
    this.isArchived = false,
    this.isCompleted = false,
    this.completedAt,
    this.milestones = const [],
    this.colorHex,
  });

  final String id;
  final String title;
  final String description;
  final String? category; // null = all categories
  final String? mode; // 'two-way' or null = sessions
  final int targetMinutes;
  final int? dailyTargetMinutes; // Optional daily pacing target for month/year
  final GoalTimeframe timeframe;
  final int? targetDate; // epoch ms for custom target deadline
  final int createdAt; // epoch ms
  final bool isArchived;
  final bool isCompleted;
  final int? completedAt;
  final List<GoalMilestone> milestones;
  final String? colorHex;

  Duration get targetDuration => Duration(minutes: targetMinutes);
  int get targetHours => (targetMinutes / 60).round();

  bool get hasMilestones => milestones.isNotEmpty;
  int get completedMilestonesCount =>
      milestones.where((m) => m.isCompleted).length;
  double get milestoneProgress => milestones.isEmpty
      ? (isCompleted ? 1.0 : 0.0)
      : (completedMilestonesCount / milestones.length);

  bool get isProjectInitiative =>
      milestones.isNotEmpty ||
      (timeframe == GoalTimeframe.custom && targetDate != null);

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? mode,
    int? targetMinutes,
    int? dailyTargetMinutes,
    GoalTimeframe? timeframe,
    int? targetDate,
    int? createdAt,
    bool? isArchived,
    bool? isCompleted,
    int? completedAt,
    List<GoalMilestone>? milestones,
    String? colorHex,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      mode: mode ?? this.mode,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      timeframe: timeframe ?? this.timeframe,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      milestones: milestones ?? this.milestones,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'mode': mode,
    'targetMinutes': targetMinutes,
    'dailyTargetMinutes': dailyTargetMinutes,
    'timeframe': timeframe.name,
    'targetDate': targetDate,
    'createdAt': createdAt,
    'isArchived': isArchived,
    'isCompleted': isCompleted,
    'completedAt': completedAt,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    if (colorHex != null) 'colorHex': colorHex,
  };

  factory Goal.fromJson(Map<String, dynamic> json) {
    final rawMilestones = json['milestones'] as List<dynamic>?;
    final parsedMilestones = rawMilestones != null
        ? rawMilestones
              .map(
                (item) => GoalMilestone.fromJson(item as Map<String, dynamic>),
              )
              .toList()
        : const <GoalMilestone>[];

    return Goal(
      id: json['id'] as String? ?? UniqueKey().toString(),
      title: _clampTitle(json['title'] as String? ?? 'Target'),
      description: (json['description'] as String?) ?? '',
      category: json['category'] as String?,
      mode: json['mode'] as String?,
      targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 600,
      dailyTargetMinutes: (json['dailyTargetMinutes'] as num?)?.toInt(),
      timeframe: GoalTimeframe.fromString(json['timeframe'] as String?),
      targetDate: (json['targetDate'] as num?)?.toInt(),
      createdAt:
          (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      isArchived: json['isArchived'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: (json['completedAt'] as num?)?.toInt(),
      milestones: parsedMilestones,
      colorHex: json['colorHex'] as String?,
    );
  }

  static String _clampTitle(String raw) {
    final t = raw.trim();
    if (t.length <= 32) return t;
    return t.substring(0, 32);
  }
}

/// Evaluated metrics and progress state for a [Goal].
class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.trackedMinutes,
    required this.sessionCount,
    required this.singleCount,
    this.archivedMinutes = 0,
  });

  final Goal goal;
  final int trackedMinutes;
  final int sessionCount;
  final int singleCount;
  final int archivedMinutes;

  bool get hasArchivedProgress => archivedMinutes > 0;
  String get archivedFormatted => _formatMinutes(archivedMinutes);

  int get currentMinutes => trackedMinutes;
  int get targetMinutes => goal.targetMinutes;
  double get ratio => targetMinutes <= 0
      ? 1.0
      : (trackedMinutes / targetMinutes).clamp(0.0, 1.0);
  int get remainingMinutes =>
      (targetMinutes - trackedMinutes).clamp(0, targetMinutes);
  int get surplusMinutes => math.max(0, trackedMinutes - targetMinutes);
  bool get isCompleted => trackedMinutes >= targetMinutes;

  String get trackedFormatted => _formatMinutes(trackedMinutes);
  String get targetFormatted => _formatMinutes(targetMinutes);
  String get remainingFormatted => _formatMinutes(remainingMinutes);
  String get surplusFormatted => _formatMinutes(surplusMinutes);

  /// Days remaining in the evaluation timeframe (inclusive of today).
  int get daysRemainingInTimeframe {
    final now = DateTime.now();
    switch (goal.timeframe) {
      case GoalTimeframe.week:
        return math.max(1, 7 - now.weekday + 1);
      case GoalTimeframe.month:
        final lastDay = DateTime(now.year, now.month + 1, 0).day;
        return math.max(1, lastDay - now.day + 1);
      case GoalTimeframe.year:
        final isLeap =
            (now.year % 4 == 0 && now.year % 100 != 0) || (now.year % 400 == 0);
        final totalDays = isLeap ? 366 : 365;
        final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
        return math.max(1, totalDays - dayOfYear + 1);
      case GoalTimeframe.custom:
        if (goal.targetDate != null) {
          final target = DateTime.fromMillisecondsSinceEpoch(goal.targetDate!);
          final diff = DateTime(
            target.year,
            target.month,
            target.day,
          ).difference(DateTime(now.year, now.month, now.day)).inDays;
          return math.max(1, diff + 1);
        }
        return 30;
      case GoalTimeframe.none:
        return 30; // standard 30-day pace horizon for open-ended targets
    }
  }

  /// Minutes per day required to reach the target before the timeframe ends.
  int get dailyPaceMinutes {
    if (isCompleted || remainingMinutes <= 0) return 0;
    final days = daysRemainingInTimeframe;
    return (remainingMinutes / days).ceil();
  }

  /// Human formatted daily pacing required.
  String get dailyPaceFormatted => _formatMinutes(dailyPaceMinutes);

  /// Narrative pacing description.
  String get pacingDescription {
    if (isCompleted) {
      if (surplusMinutes > 0) {
        return 'Target achieved! (+$surplusFormatted extra logged 🎉)';
      }
      return 'Target achieved! 🎉';
    }
    final days = daysRemainingInTimeframe;
    switch (goal.timeframe) {
      case GoalTimeframe.week:
        return 'Need $dailyPaceFormatted/day ($days ${days == 1 ? 'day' : 'days'} left this week)';
      case GoalTimeframe.month:
        return 'Need $dailyPaceFormatted/day ($days ${days == 1 ? 'day' : 'days'} left this month)';
      case GoalTimeframe.year:
        return 'Need $dailyPaceFormatted/day ($days ${days == 1 ? 'day' : 'days'} left this year)';
      case GoalTimeframe.custom:
        return 'Need $dailyPaceFormatted/day ($days ${days == 1 ? 'day' : 'days'} left)';
      case GoalTimeframe.none:
        return 'Need $dailyPaceFormatted/day (at 30-day pace)';
    }
  }

  static String _formatMinutes(int totalMins) {
    if (totalMins <= 0) return '0m';
    final h = totalMins ~/ 60;
    final m = totalMins % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}
