import 'package:flutter/material.dart';

/// Represents a pre-configured quick-log habit checkpoint (e.g. Waking Up, Breakfast, Bedtime).
class CheckpointPreset {
  const CheckpointPreset({
    required this.id,
    required this.label,
    required this.emoji,
    this.targetMinuteOfDay,
    this.category = 'Routine',
    this.iconCodePoint,
  });

  final String id;
  final String label;
  final String emoji;
  final int? targetMinuteOfDay; // Minutes from midnight (e.g. 8:00 AM -> 480)
  final String category;
  final int? iconCodePoint;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'emoji': emoji,
    'targetMinuteOfDay': targetMinuteOfDay,
    'category': category,
    'iconCodePoint': iconCodePoint,
  };

  factory CheckpointPreset.fromJson(Map<String, dynamic> json) {
    return CheckpointPreset(
      id: json['id'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String? ?? '📍',
      targetMinuteOfDay: json['targetMinuteOfDay'] as int?,
      category: json['category'] as String? ?? 'Routine',
      iconCodePoint: json['iconCodePoint'] as int?,
    );
  }

  CheckpointPreset copyWith({
    String? id,
    String? label,
    String? emoji,
    int? targetMinuteOfDay,
    String? category,
    int? iconCodePoint,
  }) {
    return CheckpointPreset(
      id: id ?? this.id,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      targetMinuteOfDay: targetMinuteOfDay ?? this.targetMinuteOfDay,
      category: category ?? this.category,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  String get formattedTargetTime {
    if (targetMinuteOfDay == null) return '';
    final h = (targetMinuteOfDay! ~/ 60) % 24;
    final m = targetMinuteOfDay! % 60;
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final mStr = m.toString().padLeft(2, '0');
    return '$h12:$mStr $ampm';
  }
}

/// Statistical consistency metrics for a checkpoint habit.
class CheckpointStats {
  const CheckpointStats({
    required this.presetId,
    required this.totalLoggedCount,
    required this.meanMinuteOfDay,
    required this.stdDevMinutes,
    required this.consistencyScore,
    required this.streakDays,
    required this.completedLast7Days,
    this.earliestMinuteOfDay,
    this.latestMinuteOfDay,
  });

  final String presetId;
  final int totalLoggedCount;
  final double meanMinuteOfDay;
  final double stdDevMinutes;
  final int consistencyScore; // 0 to 100
  final int streakDays;
  final int completedLast7Days;
  final int? earliestMinuteOfDay;
  final int? latestMinuteOfDay;

  String get formattedMeanTime {
    if (totalLoggedCount == 0) return 'No logs yet';
    final totalMins = meanMinuteOfDay.round();
    final h = (totalMins ~/ 60) % 24;
    final m = totalMins % 60;
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final mStr = m.toString().padLeft(2, '0');
    return '$h12:$mStr $ampm';
  }

  String get formattedVariance {
    if (totalLoggedCount <= 1) return '±0m';
    final mins = stdDevMinutes.round();
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return '±${h}h ${m}m';
    }
    return '±${mins}m';
  }

  String get consistencyLevel {
    if (consistencyScore >= 85) return 'Optimal Consistency';
    if (consistencyScore >= 70) return 'Moderate Consistency';
    if (consistencyScore >= 50) return 'Variable Rhythm';
    return 'Erratic Timing';
  }

  Color get consistencyColor {
    if (consistencyScore >= 85) return const Color(0xFF30D158);
    if (consistencyScore >= 70) return const Color(0xFF0A84FF);
    if (consistencyScore >= 50) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF453A);
  }
}
