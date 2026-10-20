import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing Routine Habit Checkpoint presets, fast logging,
/// and timing variance analytics.
class CheckpointService {
  CheckpointService._();

  static final CheckpointService instance = CheckpointService._();

  static const String _prefsKey = 'notekar.checkpoint_presets_v1';
  static const String _hideFromTimelineKey =
      'notekar.checkpoints_hide_from_timeline';

  List<CheckpointPreset> _presets = _defaultPresets;
  bool _hideFromTimeline = false;
  bool _initialized = false;

  static const List<CheckpointPreset> _defaultPresets = [
    CheckpointPreset(
      id: 'wake_up',
      label: 'Waking Up',
      emoji: '🌅',
      targetMinuteOfDay: 420,
      // 07:00 AM
      category: 'Routine',
    ),
    CheckpointPreset(
      id: 'bath',
      label: 'Bathing',
      emoji: '🪥',
      targetMinuteOfDay: 450,
      // 07:30 AM
      category: 'Routine',
    ),
    CheckpointPreset(
      id: 'breakfast',
      label: 'Breakfast',
      emoji: '🍳',
      targetMinuteOfDay: 510,
      // 08:30 AM
      category: 'Routine',
    ),
    CheckpointPreset(
      id: 'lunch',
      label: 'Lunch',
      emoji: '🥗',
      targetMinuteOfDay: 780,
      // 01:00 PM
      category: 'Routine',
    ),
    CheckpointPreset(
      id: 'gym',
      label: 'Workout / Gym',
      emoji: '🏋️',
      targetMinuteOfDay: 1110,
      // 06:30 PM
      category: 'Health',
    ),
    CheckpointPreset(
      id: 'prayer',
      label: 'Praying / Reflection',
      emoji: '🧘',
      targetMinuteOfDay: 1170,
      // 07:30 PM
      category: 'Routine',
    ),
    CheckpointPreset(
      id: 'dinner',
      label: 'Dinner',
      emoji: '🍽️',
      targetMinuteOfDay: 1230,
      // 08:30 PM
      category: 'Routine',
    ),
    CheckpointPreset(
      id: 'bedtime',
      label: 'Bedtime',
      emoji: '🌙',
      targetMinuteOfDay: 1380,
      // 11:00 PM
      category: 'Routine',
    ),
  ];

  List<CheckpointPreset> get presets => List.unmodifiable(_presets);

  bool get hideFromTimeline => _hideFromTimeline;

  Future<void> init({SharedPreferences? prefs}) async {
    if (_initialized && prefs == null) return;
    final sp = prefs ?? await SharedPreferences.getInstance();

    _hideFromTimeline = sp.getBool(_hideFromTimelineKey) ?? false;
    final savedJson = sp.getString(_prefsKey);
    if (savedJson != null && savedJson.trim().isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(savedJson) as List<dynamic>;
        _presets = list
            .map(
              (item) => CheckpointPreset.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing saved checkpoint presets: $e');
        }
        _presets = List.from(_defaultPresets);
      }
    } else {
      _presets = List.from(_defaultPresets);
    }
    _initialized = true;
  }

  Future<void> setHideFromTimeline(bool value) async {
    _hideFromTimeline = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_hideFromTimelineKey, value);
  }

  Future<void> savePresets(List<CheckpointPreset> updated) async {
    _presets = List.from(updated);
    final sp = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_presets.map((p) => p.toJson()).toList());
    await sp.setString(_prefsKey, jsonStr);
  }

  Future<void> addPreset(CheckpointPreset preset) async {
    final list = List<CheckpointPreset>.from(_presets);
    list.removeWhere((p) => p.id == preset.id);
    list.add(preset);
    await savePresets(list);
  }

  Future<void> deletePreset(String id) async {
    final list = List<CheckpointPreset>.from(_presets);
    list.removeWhere((p) => p.id == id);
    await savePresets(list);
  }

  Future<void> resetToDefaults() async {
    await savePresets(_defaultPresets);
  }

  /// Creates and saves a new checkpoint moment for the given preset.
  Future<Moment> logCheckpoint({
    required CheckpointPreset preset,
    DateTime? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now();
    final nextId = MomentRepository.instance.getNextId();
    final moment = Moment(
      id: nextId,
      timestamp: now.millisecondsSinceEpoch,
      type: 'single',
      date: dateKey(now),
      note: '${preset.emoji} ${preset.label}',
      category: preset.category,
      tags: ['checkpoint', 'checkpoint:${preset.id}'],
    );
    await MomentRepository.instance.saveMoment(moment);
    return moment;
  }

  /// Identifies if a moment is logged as a checkpoint.
  bool isCheckpointMoment(Moment moment) {
    if (moment.tags.contains('checkpoint')) return true;
    return moment.tags.any((t) => t.startsWith('checkpoint:'));
  }

  /// Resolves which checkpoint preset ID a moment corresponds to, if any.
  String? getCheckpointIdForMoment(Moment moment) {
    for (final tag in moment.tags) {
      if (tag.startsWith('checkpoint:')) {
        return tag.substring(11).trim();
      }
    }
    for (final p in _presets) {
      if (moment.note.contains(p.label) || moment.note.contains(p.emoji)) {
        return p.id;
      }
    }
    return null;
  }

  /// Checks if a preset habit has already been logged today.
  bool isCompletedToday(String presetId, List<Moment> moments) {
    final today = dateKey(DateTime.now());
    return moments.any((m) {
      if (m.date != today) return false;
      final cid = getCheckpointIdForMoment(m);
      return cid == presetId;
    });
  }

  /// Returns moments for a specific preset, sorted chronologically ascending.
  List<Moment> getMomentsForPreset(String presetId, List<Moment> moments) {
    final list = moments
        .where((m) => getCheckpointIdForMoment(m) == presetId)
        .toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  /// Calculates statistical consistency metrics for a checkpoint preset.
  CheckpointStats calculateStats(String presetId, List<Moment> moments) {
    final presetMoments = getMomentsForPreset(presetId, moments);
    if (presetMoments.isEmpty) {
      return CheckpointStats(
        presetId: presetId,
        totalLoggedCount: 0,
        meanMinuteOfDay: 0,
        stdDevMinutes: 0,
        consistencyScore: 0,
        streakDays: 0,
        completedLast7Days: 0,
      );
    }

    final List<int> minutesOfDayList = [];
    int? earliest;
    int? latest;

    for (final m in presetMoments) {
      final dt = DateTime.fromMillisecondsSinceEpoch(m.timestamp);
      final minOfDay = dt.hour * 60 + dt.minute;
      minutesOfDayList.add(minOfDay);
      if (earliest == null || minOfDay < earliest) earliest = minOfDay;
      if (latest == null || minOfDay > latest) latest = minOfDay;
    }

    // Calculate Mean minute of day
    final double mean =
        minutesOfDayList.reduce((a, b) => a + b) / minutesOfDayList.length;

    // Calculate Standard Deviation (Variance)
    double varianceSum = 0;
    for (final min in minutesOfDayList) {
      final diff = min - mean;
      varianceSum += diff * diff;
    }
    final double stdDev = math.sqrt(varianceSum / minutesOfDayList.length);

    // Score: 100 for stdDev <= 10 mins, scaling down to 0 for stdDev >= 120 mins
    final int score = ((120 - stdDev).clamp(0, 120) / 120 * 100).round();

    // Check last 7 days completions
    final now = DateTime.now();
    int last7DaysCount = 0;
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      final dk = dateKey(d);
      if (presetMoments.any((m) => m.date == dk)) {
        last7DaysCount++;
      }
    }

    // Check continuous streak
    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    // If today is completed, start from today, else start from yesterday
    final todayKey = dateKey(checkDate);
    final isTodayCompleted = presetMoments.any((m) => m.date == todayKey);
    if (!isTodayCompleted) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final dk = dateKey(checkDate);
      if (presetMoments.any((m) => m.date == dk)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return CheckpointStats(
      presetId: presetId,
      totalLoggedCount: presetMoments.length,
      meanMinuteOfDay: mean,
      stdDevMinutes: stdDev,
      consistencyScore: score,
      streakDays: streak,
      completedLast7Days: last7DaysCount,
      earliestMinuteOfDay: earliest,
      latestMinuteOfDay: latest,
    );
  }
}
