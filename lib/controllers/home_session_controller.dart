import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/utils/streak_guardian_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Decoupled, reactive controller managing home session state, tap operations,
/// and real-time daily momentum calculations.
class HomeSessionController extends ChangeNotifier {
  HomeSessionController({required this.repo, required this.prefs}) {
    _loadInitialState();
  }

  final MomentRepository repo;
  final SharedPreferences prefs;

  String _mode = 'two-way';
  String _inout = 'in';
  int? _sessionStart;
  bool _isPaused = false;
  int? _pausedAt;
  String _activeCategory = 'All';
  List<Moment> _recentMoments = [];
  Duration _todayTrackedDuration = Duration.zero;
  int _todayMomentsCount = 0;
  StreakGuardianStatus? _streakStatus;
  bool _isLoading = true;

  // Getters
  String get mode => _mode;

  String get inout => _inout;

  int? get sessionStart => _sessionStart;

  bool get isPaused => _isPaused;

  int? get pausedAt => _pausedAt;

  String get activeCategory => _activeCategory;

  List<Moment> get recentMoments => _recentMoments;

  Duration get todayTrackedDuration => _todayTrackedDuration;

  int get todayMomentsCount => _todayMomentsCount;

  StreakGuardianStatus? get streakStatus => _streakStatus;

  bool get isLoading => _isLoading;

  bool get isSessionActive => _mode == 'two-way' && _inout == 'out';

  void _loadInitialState() {
    _mode = prefs.getString('mode') ?? 'two-way';
    _inout = prefs.getString('m-inout') ?? 'in';
    final ses = prefs.getInt('m-ses');
    if (ses != null && ses > 0) {
      _sessionStart = ses;
    }
    _isPaused = prefs.getBool('m-paused') ?? false;
    _pausedAt = prefs.getInt('m-paused-at');
    if (_sessionStart == null) {
      _isPaused = false;
      _pausedAt = null;
    }
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final allMoments = repo.getAllMoments();
    _recentMoments = allMoments.take(20).toList();

    // Compute today's metrics
    final now = DateTime.now();
    final todayKey = dateKey(now);
    final todayMoments = allMoments.where((m) => m.date == todayKey).toList();
    _todayMomentsCount = todayMoments.length;

    final sections = buildTimelineDaySections(todayMoments);
    if (sections.isNotEmpty) {
      _todayTrackedDuration = sections.first.totalTrackedDuration;
    } else {
      _todayTrackedDuration = Duration.zero;
    }

    // Add active session elapsed time if currently IN
    if (isSessionActive && _sessionStart != null) {
      final elapsed = now.millisecondsSinceEpoch - _sessionStart!;
      if (elapsed > 0) {
        _todayTrackedDuration += Duration(milliseconds: elapsed);
      }
    }

    _streakStatus = await StreakGuardianService().evaluateStreak(allMoments);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setMode(String newMode) async {
    if (_mode == newMode) return;
    _mode = newMode;
    await prefs.setString('mode', newMode);
    notifyListeners();
  }

  Future<void> setActiveCategory(String cat) async {
    _activeCategory = cat;
    notifyListeners();
  }

  Future<void> pauseSession() async {
    if (!isSessionActive || _isPaused) return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _isPaused = true;
    _pausedAt = nowMs;
    await prefs.setBool('m-paused', true);
    await prefs.setInt('m-paused-at', nowMs);
    notifyListeners();
  }

  Future<void> resumeSession() async {
    if (!isSessionActive || !_isPaused || _pausedAt == null) return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final pauseDuration = nowMs - _pausedAt!;
    _sessionStart = (_sessionStart ?? nowMs) + pauseDuration;
    _isPaused = false;
    _pausedAt = null;
    await prefs.setBool('m-paused', false);
    await prefs.remove('m-paused-at');
    await prefs.setInt('m-ses', _sessionStart!);
    notifyListeners();
  }

  /// Records a timestamp tap (single or two-way IN/OUT).
  Future<Moment> recordTap({String note = '', String? category}) async {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    final nowDateKey = dateKey(now);
    final chosenCategory = (category != null && category.isNotEmpty)
        ? category
        : (_activeCategory != 'All' ? _activeCategory : null);

    final String type;
    if (_mode == 'single') {
      type = 'single';
    } else {
      type = _inout;
      if (_inout == 'in') {
        _inout = 'out';
        _sessionStart = nowMs;
        _isPaused = false;
        _pausedAt = null;
        await prefs.setString('m-inout', 'out');
        await prefs.setInt('m-ses', nowMs);
        await prefs.setBool('m-paused', false);
        await prefs.remove('m-paused-at');
      } else {
        if (_isPaused && _pausedAt != null) {
          final pauseDuration = nowMs - _pausedAt!;
          _sessionStart = (_sessionStart ?? nowMs) + pauseDuration;
        }
        _inout = 'in';
        _sessionStart = null;
        _isPaused = false;
        _pausedAt = null;
        await prefs.setString('m-inout', 'in');
        await prefs.remove('m-ses');
        await prefs.setBool('m-paused', false);
        await prefs.remove('m-paused-at');
      }
    }

    final newMoment = Moment(
      id: repo.getNextId(),
      timestamp: nowMs,
      type: type,
      date: nowDateKey,
      note: note,
      category: chosenCategory,
    );

    await repo.saveMoment(newMoment);
    await refresh();
    return newMoment;
  }
}
