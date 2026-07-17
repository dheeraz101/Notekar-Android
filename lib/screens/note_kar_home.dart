import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/backup_dialogs.dart';
import 'package:notekar/dialogs/changelog_dialog.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/dialogs/privacy_overlay.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/settings_dialog.dart';
import 'package:notekar/dialogs/welcome_sheet.dart';
import 'package:notekar/models/backup_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/backup_utils.dart';
import 'package:notekar/widgets/clock_face.dart';
import 'package:notekar/widgets/feedback_widgets.dart';
import 'package:notekar/widgets/toolbar.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteKarHome extends StatefulWidget {
  const NoteKarHome({super.key});

  @override
  State<NoteKarHome> createState() => _NoteKarHomeState();
}

class _NoteKarHomeState extends State<NoteKarHome>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const _storageEntries = 'notekar.entries';
  static const _entryBoxName = 'notekar_entries_v1';
  static const _welcomeSeenKey = 'notekar.welcomeSeen';
  static const _lastSeenVersionKey = 'notekar.lastSeenVersion';
  static const _fileChannel = MethodChannel('notekar/files');

  SharedPreferences? _prefs;
  Box<dynamic>? _entryBox;
  Timer? _undoTimer;
  Timer? _toastTimer;

  Timer? _updateStatusResetTimer;

  String _theme = 'dark';
  String _defaultMode = 'two-way';
  String _mode = 'two-way';
  String _inout = 'in';
  int? _sessionStart;
  int _tapDelay = 0;
  bool _remoteNotices = false;
  bool _reduceMotion = false;
  bool _haptics = true;
  String _hapticStyle = 'standard';
  String _accentColor = 'blue';
  String _appIconStyle = 'default';
  String _historyDensity = 'comfortable';
  bool _privacyLock = false;
  bool _privacyUnlocked = false;
  int _backupReminderDays = 0;
  int? _lastBackupAt;
  bool _largeText = false;
  bool _highContrast = false;
  bool _compactHistory = false;
  bool _confirmDelete = false;
  bool _showSeconds = true;
  bool _highlightSeconds = true;
  bool _buttonLabels = false;
  bool _largeControls = false;
  bool _homeMenuPill = true;
  bool _homeMenuAnimations = false;
  bool _enableTranslucency = AdaptiveEngine().supportsBlur;
  bool _extendedDuration = false;
  bool _startupComplete = false;
  bool _showHistoryText = true;
  bool _showLastSavedHint = true;
  bool _requireLongPressNote = false;
  int _privacyLockDelayMinutes = 0;
  DateTime? _privacyPausedAt;
  DateTime? _privacyAuthGraceUntil;
  bool _privacyAuthInFlight = false;
  OverlayEntry? _privacyOverlayEntry;
  bool _appIconChangeInFlight = false;
  bool _startupChecksStarted = false;
  String _updateStatus = 'v$appVersion - Check for available updates';
  bool _checkingUpdates = false;
  int? _lastUpdateCheckedAt;
  int? _lastNoticeOpenCheckAt;
  int _lastTapTime = 0;
  int? _lastId;
  int _nextId = 1;
  List<Moment> _entries = [];
  String? _toast;
  bool _toastVisible = false;
  bool _toastWarning = false;
  bool _factoryResetVisible = false;
  bool _factoryResetComplete = false;
  double _factoryResetProgress = 0;
  String _factoryResetText = 'Preparing NoteKar...';
  SharedPreferences? _factoryResetWelcomePrefs;
  Moment? _lastDeletedPreview;
  Offset? _lastTapPosition;
  String _lastSavedType = 'single';
  int _rippleToken = 0;
  int _savedPulseToken = 0;

  StreamSubscription<AccelerometerEvent>? _motionSub;
  final ValueNotifier<Offset> _motion = ValueNotifier(Offset.zero);

  int _lastMotionMs = 0;

  Palette get p => paletteFor(
    _theme,
    highContrast: _highContrast,
    accentName: _accentColor,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    _undoTimer?.cancel();
    _toastTimer?.cancel();
    _privacyOverlayEntry?.remove();
    _privacyOverlayEntry = null;
    _motionSub?.cancel();
    _motion.dispose();
    _updateStatusResetTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _restoreMotionAfterStartup(SharedPreferences prefs) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted || !_homeMenuAnimations) return;

    final available = await _canUseMotionSensor();

    if (!mounted) return;

    if (available) {
      _startMotionIfNeeded();
      return;
    }

    setState(() => _homeMenuAnimations = false);
    _motion.value = Offset.zero;

    await prefs.setBool('m-home-menu-animations', false);
  }

  Future<void> _showStartupContent(SharedPreferences prefs) async {
    final welcomeSeen = prefs.getBool(_welcomeSeenKey) ?? false;

    if (!welcomeSeen) {
      // Welcome sheet is now triggered directly in _load() for speed.
      await prefs.setString(_lastSeenVersionKey, appVersion);
      return;
    }

    await _showWhatsNewIfNeeded(prefs);
  }

  Future<bool> _canUseMotionSensor() async {
    final completer = Completer<bool>();
    StreamSubscription<AccelerometerEvent>? probe;

    try {
      probe =
          accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 100),
          ).listen(
            (_) {
              if (!completer.isCompleted) {
                completer.complete(true);
              }
            },
            onError: (_) {
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            },
            cancelOnError: true,
          );

      return await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    } finally {
      await probe?.cancel();
    }
  }

  Future<bool> _setHomeMenuMotion(bool value) async {
    if (!value) {
      await _motionSub?.cancel();
      _motionSub = null;

      if (mounted) setState(() => _homeMenuAnimations = false);

      _motion.value = Offset.zero;

      await _prefs?.setBool('m-home-menu-animations', false);
      return true;
    }

    if (_reduceMotion) {
      _showToast('Turn off Reduced Motion first', warning: true);
      return false;
    }

    final available = await _canUseMotionSensor();

    if (!available) {
      if (mounted) setState(() => _homeMenuAnimations = false);

      _motion.value = Offset.zero;

      await _prefs?.setBool('m-home-menu-animations', false);
      _showToast('Motion sensor unavailable', warning: true);
      return false;
    }

    if (mounted) {
      setState(() => _homeMenuAnimations = true);
    }

    await _prefs?.setBool('m-home-menu-animations', true);
    _startMotionIfNeeded();
    return true;
  }

  void _startMotionIfNeeded() {
    if (_reduceMotion || !_homeMenuAnimations) {
      _motionSub?.cancel();
      _motionSub = null;
      _motion.value = Offset.zero;
      return;
    }

    if (_motionSub != null) return;

    _motionSub =
        accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 100),
        ).listen(
          (event) {
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - _lastMotionMs < 100) return;
            _lastMotionMs = now;

            final targetX = (event.x / 9.8).clamp(-1.0, 1.0);
            final targetY = (event.y / 9.8).clamp(-1.0, 1.0);

            if (!mounted) return;

            final current = _motion.value;

            final nextX = current.dx + (targetX - current.dx) * 0.20;
            final nextY = current.dy + (targetY - current.dy) * 0.20;

            if ((nextX - current.dx).abs() < 0.003 &&
                (nextY - current.dy).abs() < 0.003) {
              return;
            }

            _motion.value = Offset(nextX, nextY);
          },
          onError: (_) {
            _motionSub?.cancel();
            _motionSub = null;
          },
        );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_startupComplete) {
        _startMotionIfNeeded();
      }

      if (_remoteNotices) {
        unawaited(_checkRemoteNoticeOnOpen());
      }

      if (_shouldLockOnResume()) {
        setState(() => _privacyUnlocked = false);
        _syncPrivacyOverlay();
      }
      _privacyPausedAt = null;
      unawaited(_resumeAfterPrivacyCheck());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _motionSub?.cancel();
      _motionSub = null;

      if (_isPrivacyAuthGraceActive()) return;

      if (_privacyLock && _privacyLockDelayMinutes == 0) {
        if (mounted) {
          setState(() => _privacyUnlocked = false);
        } else {
          _privacyUnlocked = false;
        }
        _syncPrivacyOverlay();
        if (_privacyAuthInFlight) return;
      }

      if (_privacyAuthInFlight) return;

      _privacyPausedAt ??= DateTime.now();
    }
  }

  Future<void> _resumeAfterPrivacyCheck() async {
    if (_privacyLock && !_privacyUnlocked) {
      _syncPrivacyOverlay();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      final unlocked = await _unlockPrivacyLock();
      if (!unlocked) return;
    }
    await _handlePendingLaunchAction();
  }

  void _syncPrivacyOverlay() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final shouldShow = _privacyLock && !_privacyUnlocked;
      if (!shouldShow) {
        _privacyOverlayEntry?.remove();
        _privacyOverlayEntry = null;
        return;
      }
      if (_privacyOverlayEntry != null) {
        _privacyOverlayEntry!.markNeedsBuild();
        return;
      }
      final overlay = Overlay.of(context, rootOverlay: true);
      _privacyOverlayEntry = OverlayEntry(
        builder: (_) => PrivacyLockOverlay(
          p: p,
          onUnlock: () => unawaited(_unlockPrivacyLock()),
        ),
      );
      overlay.insert(_privacyOverlayEntry!);
    });
  }

  bool _shouldLockOnResume() {
    if (!_privacyLock || !_privacyUnlocked) return false;
    if (_isPrivacyAuthGraceActive()) return false;
    if (_privacyLockDelayMinutes <= 0) return true;
    final pausedAt = _privacyPausedAt;
    if (pausedAt == null) return false;
    return DateTime.now().difference(pausedAt) >=
        Duration(minutes: _privacyLockDelayMinutes);
  }

  bool _isPrivacyAuthGraceActive() {
    final graceUntil = _privacyAuthGraceUntil;
    return graceUntil != null && DateTime.now().isBefore(graceUntil);
  }

  Future<void> _load() async {
    final startupTask = developer.TimelineTask()..start('notekar.startup.load');

    // 1. Prioritize SharedPreferences to identify first-run users ASAP.
    final prefs = await SharedPreferences.getInstance();
    final welcomeSeen = prefs.getBool(_welcomeSeenKey) ?? false;

    if (!welcomeSeen) {
      // Trigger welcome flow immediately before heavy Hive initialization.
      if (mounted) {
        unawaited(_showWelcomeIfNeeded(prefs));
      }
    }

    // 2. Initialize Hive and load entries in parallel/subsequently.
    await _initHive();
    final entryBox = await Hive.openBox<dynamic>(_entryBoxName);
    final entries = await _loadEntries(entryBox, prefs);
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (!mounted) {
      startupTask.finish();
      return;
    }

    setState(() {
      _prefs = prefs;
      _entryBox = entryBox;
      _entries = entries;
      _nextId =
          prefs.getInt('notekar.nextId') ??
          (entries.isEmpty ? 1 : entries.map((e) => e.id).reduce(math.max) + 1);
      _theme = prefs.getString('m-theme') ?? 'dark';
      _defaultMode = prefs.getString('m-default-mode') ?? 'two-way';
      _mode = _defaultMode;
      _inout = prefs.getString('m-inout') ?? 'in';
      _sessionStart = prefs.getInt('m-ses');
      _tapDelay = prefs.getInt('m-delay') ?? 0;
      _remoteNotices = prefs.getBool('m-remote-notices') ?? false;
      _reduceMotion = prefs.getBool('m-reduce-motion') ?? false;
      _haptics = prefs.getBool('m-haptics') ?? true;
      _hapticStyle =
          prefs.getString('m-haptic-style') ?? (_haptics ? 'standard' : 'off');
      _haptics = _hapticStyle != 'off';
      _accentColor = prefs.getString('m-accent-color') ?? 'blue';
      final savedAppIconStyle =
          prefs.getString('m-app-icon-style') ?? 'default';
      _appIconStyle = isAppIconStyle(savedAppIconStyle)
          ? savedAppIconStyle
          : 'default';
      final savedCompact = prefs.getBool('m-compact-history') ?? false;
      _historyDensity = savedCompact ? 'compact' : 'comfortable';
      _privacyLock = prefs.getBool('m-privacy-lock') ?? false;
      _backupReminderDays = prefs.getInt('m-backup-reminder-days') ?? 0;
      _lastBackupAt = prefs.getInt('m-last-backup-at');
      _largeText = prefs.getBool('m-large-text') ?? false;
      _highContrast = prefs.getBool('m-high-contrast') ?? false;
      _compactHistory = savedCompact;
      _confirmDelete = prefs.getBool('m-confirm-delete') ?? false;
      _showSeconds = prefs.getBool('m-show-seconds') ?? true;
      _highlightSeconds = prefs.getBool('m-highlight-seconds') ?? true;
      _buttonLabels = prefs.getBool('m-button-labels') ?? false;
      _largeControls = prefs.getBool('m-large-controls') ?? false;
      _homeMenuPill = prefs.getBool('m-home-menu-pill') ?? true;
      _homeMenuAnimations = prefs.getBool('m-home-menu-animations') ?? false;
      _enableTranslucency = prefs.getBool('m-translucency') ?? true;
      _extendedDuration = prefs.getBool('m-extended-duration') ?? false;
      _showHistoryText = prefs.getBool('m-show-history-text') ?? true;
      _showLastSavedHint = prefs.getBool('m-show-last-saved-hint') ?? true;
      _requireLongPressNote =
          prefs.getBool('m-require-long-press-note') ?? false;
      _privacyLockDelayMinutes = prefs.getInt('m-privacy-lock-delay') ?? 0;
      _updateStatus = prefs.getString('m-update-status') ?? _updateStatus;
      _lastUpdateCheckedAt = prefs.getInt('m-last-update-check');
    });

    _applySystemUiStyle();
    unawaited(_updateAndroidWidget());

    if (_homeMenuAnimations) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_restoreMotionAfterStartup(prefs));
      });
    }

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) _startupComplete = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_privacyLock) {
        _syncPrivacyOverlay();
        unawaited(_unlockAfterFirstPaint(prefs));
        return;
      }
      if (prefs.getBool(_welcomeSeenKey) ?? false) {
        unawaited(_runStartupChecks(prefs));
      }
    });
    startupTask.finish();
  }

  Future<void> _unlockAfterFirstPaint(SharedPreferences prefs) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted || !_privacyLock || _privacyUnlocked) return;
    final unlocked = await _unlockPrivacyLock();
    if (unlocked) {
      unawaited(_runStartupChecks(prefs));
    }
  }

  Future<void> _runStartupChecks(SharedPreferences prefs) async {
    if (_startupChecksStarted) return;
    if (_privacyLock && !_privacyUnlocked) return;

    final welcomeSeen = prefs.getBool(_welcomeSeenKey) ?? false;

    // Remove artificial delay for first-run or after factory reset.
    if (welcomeSeen) {
      await Future<void>.delayed(const Duration(milliseconds: 260));
    }

    if (!mounted) return;
    _startupChecksStarted = true;
    final startupTask = developer.TimelineTask()
      ..start('notekar.startup.deferred_checks');

    // Apply app icon only when explicitly changed by the user.
    await _showStartupContent(prefs);
    if (!mounted) {
      startupTask.finish();
      return;
    }

    _maybeShowBackupReminder();
    unawaited(_handlePendingLaunchAction());

    if (prefs.getBool('m-remote-notices') ?? false) {
      unawaited(_checkRemoteNoticeOnOpen());
    }
    startupTask.finish();
  }

  void _maybeShowBackupReminder() {
    if (!mounted || _backupReminderDays <= 0 || _entries.isEmpty) {
      return;
    }
    if (_lastBackupAt != null) {
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(_lastBackupAt!),
      );
      if (age.inDays < _backupReminderDays) return;
    }
    final today = dateKey(DateTime.now());
    if (_prefs?.getString('m-last-backup-reminder-day') == today) return;
    _prefs?.setString('m-last-backup-reminder-day', today);
    _showToast('Backup reminder: export a fresh backup soon', warning: true);
  }

  Future<void> _initHive() async {
    try {
      final dataDir = await _fileChannel.invokeMethod<String>('appDataDir');
      Hive.init(dataDir ?? Directory.systemTemp.path);
    } catch (_) {
      Hive.init(Directory.systemTemp.path);
    }
  }

  Future<List<Moment>> _loadEntries(
    Box<dynamic> entryBox,
    SharedPreferences prefs,
  ) async {
    if (entryBox.isNotEmpty) {
      return entryBox.values
          .whereType<Map>()
          .map((item) => Moment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    final legacyRows = prefs.getString(_storageEntries);
    if (legacyRows == null) return <Moment>[];
    final entries = (jsonDecode(legacyRows) as List)
        .map((item) => Moment.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    for (final entry in entries) {
      await entryBox.put(entry.id, entry.toJson());
    }
    await prefs.remove(_storageEntries);
    return entries;
  }

  Future<void> _saveEntry(Moment entry) async {
    await _entryBox?.put(entry.id, entry.toJson());
    await _prefs?.setInt('notekar.nextId', _nextId);
  }

  Future<void> _deleteStoredEntry(int id) async {
    await _entryBox?.delete(id);
    await _prefs?.setInt('notekar.nextId', _nextId);
  }

  Future<void> _clearStoredEntries() async {
    await _entryBox?.clear();
    await _prefs?.setInt('notekar.nextId', _nextId);
  }

  Future<void> _replaceStoredEntries(List<Moment> entries) async {
    final entryBox = _entryBox;
    if (entryBox == null) return;
    await entryBox.clear();
    for (final entry in entries) {
      await entryBox.put(entry.id, entry.toJson());
    }
    await _prefs?.setInt('notekar.nextId', _nextId);
  }

  Future<void> _saveSetting(String key, Object value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    if (value is String) await prefs.setString(key, value);
    if (value is int) await prefs.setInt(key, value);
  }

  Future<void> _showWelcomeIfNeeded(SharedPreferences prefs) async {
    if (prefs.getBool(_welcomeSeenKey) ?? false) return;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 170),
        reverseDuration: Duration(milliseconds: 130),
      ),
      builder: (_) => WelcomeSheet(
        p: p,
        theme: _theme,
        defaultMode: _defaultMode,
        blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion,
        onTheme: (value) {
          setState(() => _theme = value);
          _saveSetting('m-theme', value);
          _applySystemUiStyle();
        },
        onDefaultMode: (value) {
          setState(() => _defaultMode = value);
          _saveSetting('m-default-mode', value);
        },
      ),
    );
    await prefs.setBool(_welcomeSeenKey, true);
  }

  Future<void> _showWhatsNewIfNeeded(SharedPreferences prefs) async {
    if (prefs.getString(_lastSeenVersionKey) == appVersion) return;
    if (!(prefs.getBool(_welcomeSeenKey) ?? false)) {
      await prefs.setString(_lastSeenVersionKey, appVersion);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showGeneralDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.42),
        barrierDismissible: true,
        barrierLabel: 'Close what is new',
        transitionDuration: const Duration(milliseconds: 120),
        pageBuilder: (_, _, _) => ChangelogDialog(p: p, latestOnly: true),
      );
      await prefs.setString(_lastSeenVersionKey, appVersion);
    });
  }

  Future<void> _logEntry({String? note, Offset? position}) async {
    final now = DateTime.now();
    var type = 'single';
    if (_mode == 'two-way') {
      type = _inout;
      if (_inout == 'in') {
        _sessionStart = now.millisecondsSinceEpoch;
        _inout = 'out';
        await _saveSetting('m-ses', _sessionStart!);
      } else {
        _sessionStart = null;
        _inout = 'in';
        await _prefs?.remove('m-ses');
      }
      await _saveSetting('m-inout', _inout);
    }
    final entry = Moment(
      id: _nextId++,
      timestamp: now.millisecondsSinceEpoch,
      type: type,
      date: dateKey(now),
      note: note?.trim() ?? '',
    );
    setState(() {
      _entries = [entry, ..._entries];
      _lastId = entry.id;
      _lastDeletedPreview = null;
      _lastTapTime = now.millisecondsSinceEpoch;
      _lastTapPosition = position;
      _lastSavedType = type;
      _rippleToken++;
      _savedPulseToken++;
    });
    if (type == 'out') {
      _haptic(HapticFeedback.mediumImpact);
      Future<void>.delayed(
        const Duration(milliseconds: 70),
        () => _haptic(HapticFeedback.lightImpact),
      );
    } else if (type == 'in') {
      _haptic(HapticFeedback.mediumImpact);
    } else {
      _haptic(HapticFeedback.lightImpact);
    }
    unawaited(_saveEntry(entry));
    unawaited(_updateAndroidWidget());
    _showUndo();
  }

  bool _isDelayBlocked() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    if (ms - _lastTapTime < _tapDelay * 1000) {
      _showToast('Wait ${delayLabel(_tapDelay)} between taps', warning: true);
      return true;
    }
    return false;
  }

  void _handleTap(TapUpDetails details) {
    if (_isDelayBlocked()) return;
    unawaited(_logEntry(position: details.globalPosition));
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == 'two-way' ? 'single' : 'two-way';
      if (_mode == 'single') {
        _inout = 'in';
        _sessionStart = null;
      }
    });
    _saveSetting('m-mode', _mode);
    if (_mode == 'single') {
      _prefs?.remove('m-inout');
      _prefs?.remove('m-ses');
    }
    _haptic(HapticFeedback.selectionClick);
    _showToast(_mode == 'two-way' ? 'Two-Way Mode' : 'Single Mode');
    unawaited(_updateAndroidWidget());
  }

  void _showToast(String text, {bool warning = false}) {
    _toastTimer?.cancel();
    setState(() {
      _toast = text;
      _toastVisible = true;
      _toastWarning = warning;
    });
    _toastTimer = Timer(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      setState(() => _toastVisible = false);
      _toastTimer = Timer(const Duration(milliseconds: 180), () {
        if (mounted && !_toastVisible) {
          setState(() {
            _toast = null;
            _toastWarning = false;
          });
        }
      });
    });
  }

  void _showUndo() {
    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) setState(() => _lastId = null);
    });
  }

  Future<void> _undoLast() async {
    final id = _lastId;
    if (id == null) return;
    final entry = _entries.where((item) => item.id == id).firstOrNull;
    if (entry == null) return;
    setState(() {
      _entries = _entries.where((item) => item.id != id).toList();
      _lastId = null;
      if (_mode == 'two-way') {
        if (entry.type == 'in') {
          _inout = 'in';
          _sessionStart = null;
        } else {
          _inout = 'out';
          _sessionStart = _entries
              .where((item) => item.type == 'in')
              .map((item) => item.timestamp)
              .firstOrNull;
        }
      }
    });
    if (_sessionStart == null) {
      await _prefs?.remove('m-ses');
    } else {
      await _saveSetting('m-ses', _sessionStart!);
    }
    await _saveSetting('m-inout', _inout);
    unawaited(_deleteStoredEntry(id));
    unawaited(_updateAndroidWidget());
  }

  Future<void> _deleteEntry(int id) async {
    final entry = _entries.where((item) => item.id == id).firstOrNull;
    if (entry == null) return;
    setState(() {
      _entries = _entries.where((item) => item.id != id).toList();
      _lastDeletedPreview = null;
      if (_lastId == id) _lastId = null;
    });
    unawaited(_deleteStoredEntry(id));
    unawaited(_updateAndroidWidget());
  }

  Future<void> _restoreEntry(Moment entry) async {
    if (_entries.any((item) => item.id == entry.id)) return;
    setState(() {
      _entries = [entry, ..._entries]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _lastDeletedPreview = null;
      if (_nextId <= entry.id) _nextId = entry.id + 1;
    });
    await _saveEntry(entry);
    unawaited(_updateAndroidWidget());
  }

  Future<void> _updateMomentNote(int id, String note) async {
    final index = _entries.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final oldMoment = _entries[index];
    final updatedMoment = Moment(
      id: oldMoment.id,
      timestamp: oldMoment.timestamp,
      type: oldMoment.type,
      date: oldMoment.date,
      note: note.trim(),
    );

    setState(() {
      final updatedEntries = List<Moment>.from(_entries);
      updatedEntries[index] = updatedMoment;
      _entries = updatedEntries;
    });

    await _saveEntry(updatedMoment);
  }

  Future<void> _resetAll() async {
    setState(() {
      _entries = [];
      _lastId = null;
      _lastDeletedPreview = null;
      _inout = 'in';
      _sessionStart = null;
    });

    await _prefs?.remove('m-inout');
    await _prefs?.remove('m-ses');
    unawaited(_clearStoredEntries());
    unawaited(_updateAndroidWidget());
  }

  Future<void> _factoryReset() async {
    final prefs = _prefs;
    final started = DateTime.now();
    setState(() {
      _factoryResetVisible = true;
      _factoryResetComplete = false;
      _factoryResetProgress = 0.08;
      _factoryResetText = 'Preparing a fresh start...';
      _factoryResetWelcomePrefs = prefs;
      _entries = [];
      _lastId = null;
      _lastDeletedPreview = null;
      _lastTapPosition = null;
      _theme = 'dark';
      _defaultMode = 'two-way';
      _mode = 'two-way';
      _inout = 'in';
      _sessionStart = null;
      _tapDelay = 0;
      _accentColor = 'blue';
      _appIconStyle = 'default';
      _hapticStyle = 'standard';
      _historyDensity = 'comfortable';
      _privacyLock = false;
      _privacyUnlocked = false;
      _backupReminderDays = 0;
      _lastBackupAt = null;
      _remoteNotices = false;
      _reduceMotion = false;
      _haptics = true;
      _largeText = false;
      _highContrast = false;
      _compactHistory = false;
      _confirmDelete = false;
      _showSeconds = true;
      _highlightSeconds = true;
      _buttonLabels = false;
      _largeControls = false;
      _homeMenuPill = true;
      _homeMenuAnimations = false;
      _showHistoryText = true;
      _showLastSavedHint = true;
      _requireLongPressNote = false;
      _extendedDuration = false;
      _enableTranslucency = true;
      _privacyLockDelayMinutes = 0;
      _updateStatus = 'v$appVersion - Check for available updates';
      _lastUpdateCheckedAt = null;
      _nextId = 1;
    });
    _applySystemUiStyle();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (mounted) {
      setState(() {
        _factoryResetProgress = 0.22;
        _factoryResetText = 'Clearing moments and notes...';
      });
    }
    await _clearStoredEntries();
    if (prefs != null) {
      var done = 0;
      for (final key in [
        'notekar.nextId',
        _welcomeSeenKey,
        _lastSeenVersionKey,
        'm-theme',
        'm-default-mode',
        'm-mode',
        'm-inout',
        'm-ses',
        'm-delay',
        'm-accent-color',
        'm-app-icon-style',
        'm-haptic-style',
        'm-history-density',
        'm-privacy-lock',
        'm-backup-reminder-days',
        'm-last-backup-at',
        'm-last-backup-reminder-day',
        'm-remote-notices',
        'm-reduce-motion',
        'm-haptics',
        'm-reduced-haptics',
        'm-large-text',
        'm-high-contrast',
        'm-compact-history',
        'm-confirm-delete',
        'm-show-seconds',
        'm-highlight-seconds',
        'm-button-labels',
        'm-large-controls',
        'm-home-menu-pill',
        'm-home-menu-animations',
        'm-show-history-text',
        'm-show-last-saved-hint',
        'm-require-long-press-note',
        'm-extended-duration',
        'm-translucency',
        'm-privacy-lock-delay',
        'm-update-status',
        'm-last-update-check',
      ]) {
        await prefs.remove(key);
        done++;
        if (mounted && done % 4 == 0) {
          setState(() {
            _factoryResetProgress = math.min(0.82, 0.22 + (done / 24) * 0.55);
            _factoryResetText = 'Restoring default settings...';
          });
        }
      }
      try {
        if (mounted) {
          setState(() {
            _factoryResetProgress = 0.86;
            _factoryResetText = 'Turning off remote notices...';
          });
        }
        await _fileChannel.invokeMethod<void>('configureRemoteNotices', {
          'enabled': false,
          'feedUrl': notificationFeed,
        });
      } catch (_) {}
    }
    final elapsed = DateTime.now().difference(started);
    if (elapsed < const Duration(seconds: 5)) {
      if (mounted) {
        setState(() {
          _factoryResetProgress = 0.94;
          _factoryResetText = 'Finishing reset...';
        });
      }
      await Future<void>.delayed(const Duration(seconds: 5) - elapsed);
    }
    if (mounted) {
      setState(() {
        _factoryResetProgress = 1;
        _factoryResetComplete = true;
        _factoryResetText = 'NoteKar is ready for a fresh start.';
      });
    }
    unawaited(_updateAndroidWidget());
  }

  Future<void> _finishFactoryResetOverlay() async {
    final prefs = _factoryResetWelcomePrefs;
    setState(() => _factoryResetVisible = false);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (mounted && prefs != null) await _showWelcomeIfNeeded(prefs);
  }

  Future<void> _resetSettingsOnly() async {
    setState(() {
      _theme = 'dark';
      _defaultMode = 'two-way';
      _tapDelay = 0;
      _accentColor = 'blue';
      _appIconStyle = 'default';
      _hapticStyle = 'standard';
      _historyDensity = 'comfortable';
      _privacyLock = false;
      _backupReminderDays = 0;
      _remoteNotices = false;
      _reduceMotion = false;
      _haptics = true;
      _largeText = false;
      _highContrast = false;
      _compactHistory = false;
      _confirmDelete = false;
      _showSeconds = true;
      _highlightSeconds = true;
      _buttonLabels = false;
      _largeControls = false;
      _homeMenuPill = true;
      _homeMenuAnimations = false;
      _showHistoryText = true;
      _showLastSavedHint = true;
      _requireLongPressNote = false;
      _extendedDuration = false;
      _enableTranslucency = true;
      _privacyLockDelayMinutes = 0;
    });
    await _prefs?.setString('m-theme', _theme);
    await _prefs?.setString('m-default-mode', _defaultMode);
    await _prefs?.setInt('m-delay', _tapDelay);
    await _prefs?.setString('m-accent-color', _accentColor);
    await _prefs?.setString('m-app-icon-style', _appIconStyle);
    await _prefs?.setString('m-haptic-style', _hapticStyle);
    await _prefs?.setString('m-history-density', _historyDensity);
    await _prefs?.setBool('m-privacy-lock', _privacyLock);
    await _prefs?.setInt('m-backup-reminder-days', _backupReminderDays);
    await _prefs?.setBool('m-remote-notices', _remoteNotices);
    await _prefs?.setBool('m-reduce-motion', _reduceMotion);
    await _prefs?.setBool('m-haptics', _haptics);
    await _prefs?.remove('m-reduced-haptics');
    await _prefs?.setBool('m-large-text', _largeText);
    await _prefs?.setBool('m-high-contrast', _highContrast);
    await _prefs?.setBool('m-compact-history', _compactHistory);
    await _prefs?.setBool('m-confirm-delete', _confirmDelete);
    await _prefs?.setBool('m-show-seconds', _showSeconds);
    await _prefs?.setBool('m-highlight-seconds', _highlightSeconds);
    await _prefs?.setBool('m-button-labels', _buttonLabels);
    await _prefs?.setBool('m-large-controls', _largeControls);
    await _prefs?.setBool('m-home-menu-pill', _homeMenuPill);
    await _prefs?.setBool('m-home-menu-animations', _homeMenuAnimations);
    await _prefs?.setBool('m-show-history-text', _showHistoryText);
    await _prefs?.setBool('m-show-last-saved-hint', _showLastSavedHint);
    await _prefs?.setBool('m-require-long-press-note', _requireLongPressNote);
    await _prefs?.setBool('m-extended-duration', _extendedDuration);
    await _prefs?.setBool('m-translucency', _enableTranslucency);
    await _prefs?.setInt('m-privacy-lock-delay', _privacyLockDelayMinutes);
    try {
      await _fileChannel.invokeMethod<void>('configureRemoteNotices', {
        'enabled': false,
        'feedUrl': notificationFeed,
      });
    } catch (_) {}
    _applySystemUiStyle();
  }

  Future<void> _restoreSettings(Map<String, Object> snapshot) async {
    setState(() {
      _theme = snapshot['theme'] as String;
      _defaultMode = snapshot['defaultMode'] as String;
      _tapDelay = snapshot['tapDelay'] as int;
      _accentColor = snapshot['accentColor'] as String;
      _appIconStyle = snapshot['appIconStyle'] as String;
      _hapticStyle = snapshot['hapticStyle'] as String;
      _historyDensity = snapshot['historyDensity'] as String;
      _privacyLock = snapshot['privacyLock'] as bool;
      _backupReminderDays = snapshot['backupReminderDays'] as int;
      _remoteNotices = snapshot['remoteNotices'] as bool;
      _reduceMotion = snapshot['reduceMotion'] as bool;
      _haptics = _hapticStyle != 'off';
      _largeText = snapshot['largeText'] as bool;
      _highContrast = snapshot['highContrast'] as bool;
      _compactHistory = snapshot['compactHistory'] as bool;
      _confirmDelete = snapshot['confirmDelete'] as bool;
      _showSeconds = snapshot['showSeconds'] as bool;
      _highlightSeconds = snapshot['highlightSeconds'] as bool;
      _buttonLabels = snapshot['buttonLabels'] as bool;
      _largeControls = snapshot['largeControls'] as bool;
      _homeMenuPill = snapshot['homeMenuPill'] as bool;
      _homeMenuAnimations = snapshot['homeMenuAnimations'] as bool;
      _showHistoryText = snapshot['showHistoryText'] as bool;
      _showLastSavedHint = snapshot['showLastSavedHint'] as bool;
      _requireLongPressNote = snapshot['requireLongPressNote'] as bool;
      _extendedDuration = snapshot['extendedDuration'] as bool? ?? false;
      _enableTranslucency = snapshot['enableTranslucency'] as bool? ?? true;
      _privacyLockDelayMinutes = snapshot['privacyLockDelayMinutes'] as int;
    });
    await _prefs?.setString('m-theme', _theme);
    await _prefs?.setString('m-default-mode', _defaultMode);
    await _prefs?.setInt('m-delay', _tapDelay);
    await _prefs?.setString('m-accent-color', _accentColor);
    await _prefs?.setString('m-app-icon-style', _appIconStyle);
    await _prefs?.setString('m-haptic-style', _hapticStyle);
    await _prefs?.setString('m-history-density', _historyDensity);
    await _prefs?.setBool('m-privacy-lock', _privacyLock);
    await _prefs?.setInt('m-backup-reminder-days', _backupReminderDays);
    await _prefs?.setBool('m-remote-notices', _remoteNotices);
    await _prefs?.setBool('m-reduce-motion', _reduceMotion);
    await _prefs?.setBool('m-haptics', _haptics);
    await _prefs?.remove('m-reduced-haptics');
    await _prefs?.setBool('m-large-text', _largeText);
    await _prefs?.setBool('m-high-contrast', _highContrast);
    await _prefs?.setBool('m-compact-history', _compactHistory);
    await _prefs?.setBool('m-confirm-delete', _confirmDelete);
    await _prefs?.setBool('m-show-seconds', _showSeconds);
    await _prefs?.setBool('m-highlight-seconds', _highlightSeconds);
    await _prefs?.setBool('m-button-labels', _buttonLabels);
    await _prefs?.setBool('m-large-controls', _largeControls);
    await _prefs?.setBool('m-home-menu-pill', _homeMenuPill);
    await _prefs?.setBool('m-home-menu-animations', _homeMenuAnimations);
    await _prefs?.setBool('m-show-history-text', _showHistoryText);
    await _prefs?.setBool('m-show-last-saved-hint', _showLastSavedHint);
    await _prefs?.setBool('m-require-long-press-note', _requireLongPressNote);
    await _prefs?.setBool('m-extended-duration', _extendedDuration);
    await _prefs?.setBool('m-translucency', _enableTranslucency);
    await _prefs?.setInt('m-privacy-lock-delay', _privacyLockDelayMinutes);
    _applySystemUiStyle();
    _showToast('Settings restored');
    unawaited(_updateAndroidWidget());
  }

  Future<void> _updateAndroidWidget() async {
    final now = DateTime.now();
    final today = dateKey(now);

    final todayCount = _entries.where((entry) => entry.date == today).length;

    final latest = _entries.isEmpty ? null : _entries.first;

    try {
      await _fileChannel.invokeMethod<void>('updateWidgetState', {
        'todayCount': todayCount,
        'mode': _mode,
        'nextAction': _mode == 'two-way' ? _inout : 'single',
        'lastType': latest?.type ?? '',
        'lastTimestamp': latest?.timestamp ?? 0,
        'hasMoments': latest != null,
      });
    } catch (_) {
      // Widget updates must never affect logging.
    }
  }

  Future<void> _openNote() async {
    if (_isDelayBlocked()) return;
    _haptic(HapticFeedback.lightImpact);
    final note = await showGeneralDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close note',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) =>
          NoteDialog(p: p, blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion),
    );
    if (note != null) {
      if (_requireLongPressNote && note.trim().isEmpty) {
        _showToast('Add a note to save', warning: true);
        return;
      }
      unawaited(_logEntry(note: note.isEmpty ? null : note));
    }
  }

  Future<void> _openHistory() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 180),
        reverseDuration: Duration(milliseconds: 170),
      ),
      builder: (_) => HistoryDialog(
        p: p,
        entries: _entries,
        compactRows: _compactHistory,
        largeText: _largeText,
        blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion,
        onDelete: _deleteEntry,
        onRestore: _restoreEntry,
        onUpdateNote: _updateMomentNote,
        confirmDelete: _confirmDelete,
        onDuration: _showDuration,
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 180),
        reverseDuration: Duration(milliseconds: 170),
      ),
      builder: (_) => SettingsDialog(
        p: p,
        theme: _theme,
        defaultMode: _defaultMode,
        tapDelay: _tapDelay,
        accentColor: _accentColor,
        appIconStyle: _appIconStyle,
        hapticStyle: _hapticStyle,
        historyDensity: _historyDensity,
        privacyLock: _privacyLock,
        backupReminderDays: _backupReminderDays,
        lastBackupAt: _lastBackupAt,
        remoteNotices: _remoteNotices,
        reduceMotion: _reduceMotion,
        largeText: _largeText,
        highContrast: _highContrast,
        compactHistory: _compactHistory,
        confirmDelete: _confirmDelete,
        showSeconds: _showSeconds,
        highlightSeconds: _highlightSeconds,
        buttonLabels: _buttonLabels,
        largeControls: _largeControls,
        homeMenuPill: _homeMenuPill,
        homeMenuAnimations: _homeMenuAnimations,
        showHistoryText: _showHistoryText,
        showLastSavedHint: _showLastSavedHint,
        requireLongPressNote: _requireLongPressNote,
        extendedDuration: _extendedDuration,
        enableTranslucency: _enableTranslucency,
        privacyLockDelayMinutes: _privacyLockDelayMinutes,
        updateStatus: _updateStatus,
        checkingUpdates: _checkingUpdates,
        lastUpdateCheckedAt: _lastUpdateCheckedAt,
        entries: _entries,
        lastSavedAt: _entries.isEmpty
            ? null
            : _entries.map((entry) => entry.timestamp).reduce(math.max),
        blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion,
        onTheme: (value) {
          setState(() => _theme = value);
          _saveSetting('m-theme', value);
          _applySystemUiStyle();
        },
        onDefaultMode: (value) {
          setState(() {
            _defaultMode = value;
          });
          _saveSetting('m-default-mode', value);
        },
        onDelay: (value) {
          setState(() => _tapDelay = value);
          _saveSetting('m-delay', value);
        },
        onAccentColor: (value) {
          setState(() => _accentColor = value);
          _saveSetting('m-accent-color', value);
        },
        onAppIconStyle: (value) async {
          setState(() => _appIconStyle = value);
          await _saveSetting('m-app-icon-style', value);
          await _setAppIconStyle(value);
        },
        onHapticStyle: (value) {
          setState(() {
            _hapticStyle = value;
            _haptics = value != 'off';
          });
          _saveSetting('m-haptic-style', value);
          _prefs?.setBool('m-haptics', value != 'off');
        },
        onHistoryDensity: (value) {
          setState(() {
            _historyDensity = value;
            _compactHistory = value != 'comfortable';
          });
          _saveSetting('m-history-density', value);
          _prefs?.setBool('m-compact-history', value != 'comfortable');
        },
        onPrivacyLock: _setPrivacyLock,
        onBackupReminderDays: (value) {
          setState(() => _backupReminderDays = value);
          _prefs?.setInt('m-backup-reminder-days', value);
        },
        onRemoteNotices: _setRemoteNotices,
        onReduceMotion: (value) {
          setState(() {
            _reduceMotion = value;
            if (value) _homeMenuAnimations = false;
          });
          _prefs?.setBool('m-reduce-motion', value);
          if (value) _prefs?.setBool('m-home-menu-animations', false);
          _startMotionIfNeeded();
        },
        onLargeText: (value) {
          setState(() => _largeText = value);
          _prefs?.setBool('m-large-text', value);
        },
        onHighContrast: (value) {
          setState(() => _highContrast = value);
          _prefs?.setBool('m-high-contrast', value);
        },
        onCompactHistory: (value) {
          setState(() => _compactHistory = value);
          _prefs?.setBool('m-compact-history', value);
        },
        onConfirmDelete: (value) {
          setState(() => _confirmDelete = value);
          _prefs?.setBool('m-confirm-delete', value);
        },
        onShowSeconds: (value) {
          setState(() {
            _showSeconds = value;
            if (!value) _highlightSeconds = false;
          });
          _prefs?.setBool('m-show-seconds', value);
          if (!value) _prefs?.setBool('m-highlight-seconds', false);
        },
        onHighlightSeconds: (value) {
          if (!_showSeconds) {
            _showToast('Enable Show Seconds first', warning: true);
            return;
          }
          setState(() => _highlightSeconds = value);
          _prefs?.setBool('m-highlight-seconds', value);
        },
        onButtonLabels: (value) {
          setState(() => _buttonLabels = value);
          _prefs?.setBool('m-button-labels', value);
        },
        onLargeControls: (value) {
          setState(() => _largeControls = value);
          _prefs?.setBool('m-large-controls', value);
        },
        onHomeMenuPill: (value) {
          setState(() => _homeMenuPill = value);
          _prefs?.setBool('m-home-menu-pill', value);
        },
        onHomeMenuAnimations: _setHomeMenuMotion,
        onShowHistoryText: (value) {
          setState(() => _showHistoryText = value);
          _prefs?.setBool('m-show-history-text', value);
        },
        onShowLastSavedHint: (value) {
          setState(() => _showLastSavedHint = value);
          _prefs?.setBool('m-show-last-saved-hint', value);
        },
        onRequireLongPressNote: (value) {
          setState(() => _requireLongPressNote = value);
          _prefs?.setBool('m-require-long-press-note', value);
        },
        onExtendedDuration: (value) {
          setState(() => _extendedDuration = value);
          _prefs?.setBool('m-extended-duration', value);
        },
        onTranslucency: (value) {
          setState(() => _enableTranslucency = value);
          _prefs?.setBool('m-translucency', value);
        },
        onPrivacyLockDelay: (value) {
          setState(() => _privacyLockDelayMinutes = value);
          _prefs?.setInt('m-privacy-lock-delay', value);
        },
        onExportCsv: () => _exportFile(
          fileName: 'notekar-moments-${exportDateStamp()}.csv',
          content: _csvExport(),
          mimeType: 'text/csv',
        ),
        onExportRecentCsv: () => _exportFile(
          fileName: 'notekar-recent-7-days-${exportDateStamp()}.csv',
          content: _csvExport(
            since: DateTime.now().subtract(const Duration(days: 7)),
          ),
          mimeType: 'text/csv',
        ),
        onExportJson: () => _exportFile(
          fileName: 'notekar-moments-${exportDateStamp()}.json',
          content: _jsonExport(),
          mimeType: 'application/json',
        ),
        onExportBackup: _exportBackupFile,
        onImportBackup: _importBackupFile,
        onCheckUpdates: _checkForUpdates,
        onOpenLink: _openExternalLink,
        onShowChangelog: (latestOnly) => showGeneralDialog<void>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.42),
          barrierDismissible: true,
          barrierLabel: latestOnly ? 'Close what is new' : 'Close changelog',
          transitionDuration: const Duration(milliseconds: 120),
          pageBuilder: (_, _, _) => ChangelogDialog(
            p: p,
            latestOnly: latestOnly,
            blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion,
          ),
        ),
        onReset: _resetAll,
        onFactoryReset: _factoryReset,
        onResetSettings: _resetSettingsOnly,
        onRestoreSettings: _restoreSettings,
        onFeedback: _showToast,
      ),
    );
  }

  Future<void> _openWhatsNew() async {
    await showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close what is new',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ChangelogDialog(
        p: p,
        latestOnly: true,
        blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion,
      ),
    );
  }

  Future<void> _openChangelog() async {
    await showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close changelog',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ChangelogDialog(
        p: p,
        blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion,
      ),
    );
  }

  Future<void> _handlePendingLaunchAction() async {
    String? action;
    try {
      action = await _fileChannel.invokeMethod<String>('getLaunchAction');
    } catch (_) {
      return;
    }
    if (!mounted || action == null || action.trim().isEmpty) return;
    if (_privacyLock && !_privacyUnlocked) {
      final unlocked = await _unlockPrivacyLock();
      if (!unlocked) return;
    }
    switch (action.trim().toLowerCase()) {
      case 'history':
        await _openHistory();
      case 'settings':
        await _openSettings();
      case 'whats-new':
      case 'whatsnew':
        await _openWhatsNew();
      case 'changelog':
        await _openChangelog();
      case 'note':
        await _openNote();
      case 'moment':
      case 'single':
        if (!_isDelayBlocked()) unawaited(_logEntry());
      case 'in':
        if (!_isDelayBlocked()) {
          setState(() {
            _mode = 'two-way';
            _inout = 'in';
          });
          unawaited(_logEntry());
        }
      case 'out':
        if (!_isDelayBlocked()) {
          setState(() {
            _mode = 'two-way';
            _inout = 'out';
          });
          unawaited(_logEntry());
        }
      case 'updates':
      case 'releases':
        await _openExternalLink(githubReleases);
    }
  }

  Future<void> _openExternalLink(String url) async {
    try {
      await _fileChannel.invokeMethod<void>('openUrl', {'url': url});
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) _showToast('Link copied');
    }
  }

  Future<void> _setRemoteNotices(bool value) async {
    if (value) {
      final granted = await _requestNotifications();
      if (!granted) {
        _showToast('Notification permission needed', warning: true);
        return;
      }
    }
    setState(() => _remoteNotices = value);
    await _prefs?.setBool('m-remote-notices', value);
    try {
      await _fileChannel.invokeMethod<void>('configureRemoteNotices', {
        'enabled': value,
        'feedUrl': notificationFeed,
      });
      if (value) {
        await _fileChannel.invokeMethod<void>('checkRemoteNoticesNow');
      }
    } catch (_) {
      if (mounted) {
        _showToast(
          value ? 'Could not turn on app notices' : 'App notices off',
          warning: value,
        );
      }
      return;
    }
    if (mounted) {
      _showToast(value ? 'App notices on' : 'App notices off');
    }
  }

  void _haptic(Future<void> Function() feedback) {
    if (_hapticStyle == 'off') return;
    if (_hapticStyle == 'light') {
      HapticFeedback.selectionClick();
      return;
    }
    feedback();
  }

  Future<void> _checkRemoteNoticeOnOpen() async {
    if (!_remoteNotices) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCheck = _lastNoticeOpenCheckAt;

    // Avoid repeated checks caused by dialogs, permissions, or rapid resume events.
    if (lastCheck != null &&
        now - lastCheck < const Duration(minutes: 1).inMilliseconds) {
      return;
    }

    _lastNoticeOpenCheckAt = now;

    try {
      await _fileChannel.invokeMethod<void>('checkRemoteNoticesNow');
    } catch (_) {
      // Offline and network failures are expected.
      // They must never interrupt NoteKar.
    }
  }

  Future<bool> _requestNotifications() async {
    try {
      final granted = await _fileChannel.invokeMethod<bool>(
        'requestNotificationPermission',
      );
      return granted ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<String> _checkForUpdates() async {
    setState(() {
      _checkingUpdates = true;
      _updateStatus = 'Checking for updates...';
    });
    _showToast('Checking for updates...');
    try {
      final latest = await _fetchLatestRelease();
      if (latest == null) {
        final status = 'Could not check updates';
        _setUpdateStatus(status);
        if (mounted) _showToast('Could not check updates', warning: true);
        return status;
      }
      if (isNewerVersion(latest, appVersion)) {
        final status = 'Update available: v$latest';
        _lastUpdateCheckedAt = DateTime.now().millisecondsSinceEpoch;
        await _prefs?.setInt('m-last-update-check', _lastUpdateCheckedAt!);
        _setUpdateStatus(status);
        if (mounted) _showToast('Update $latest available');
        return status;
      } else if (mounted) {
        final status = 'You are up to date';
        _lastUpdateCheckedAt = DateTime.now().millisecondsSinceEpoch;
        await _prefs?.setInt('m-last-update-check', _lastUpdateCheckedAt!);
        _setUpdateStatus(status);
        _showToast('You are up to date');
        _scheduleUpdateStatusReset();
        return status;
      }
    } catch (_) {
      final status = 'Update check failed';
      _setUpdateStatus(status);
      if (mounted) _showToast('Update check failed', warning: true);
      return status;
    } finally {
      if (mounted) setState(() => _checkingUpdates = false);
    }
    return _updateStatus;
  }

  void _setUpdateStatus(String value) {
    _updateStatusResetTimer?.cancel();
    setState(() => _updateStatus = value);
    _prefs?.setString('m-update-status', value);
  }

  void _scheduleUpdateStatusReset() {
    _updateStatusResetTimer?.cancel();
    _updateStatusResetTimer = Timer(const Duration(minutes: 1), () {
      if (!mounted) return;
      _setUpdateStatus('v$appVersion - Check for available updates');
    });
  }

  Future<String?> _fetchLatestRelease() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(
        Uri.parse(
          'https://api.github.com/repos/dheeraz101/Notekar/releases/latest',
        ),
      );
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$appVersion');
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body);
      if (data is! Map) return null;
      final tag = (data['tag_name'] as String?) ?? (data['name'] as String?);
      return tag?.replaceFirst(RegExp(r'^[vV]'), '').trim();
    } finally {
      client.close(force: true);
    }
  }

  Future<bool> _exportFile({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    try {
      await _fileChannel.invokeMethod<String>('saveTextFile', {
        'fileName': fileName,
        'content': content,
        'mimeType': mimeType,
      });

      if (mounted) _showToast('Export saved to Downloads');
      return true;
    } catch (_) {
      if (mounted) _showToast('Export failed. Try again.', warning: true);
      return false;
    }
  }

  Future<void> _exportBackupFile() async {
    final ok = await _exportFile(
      fileName: 'notekar-backup-${exportDateStamp()}.json',
      content: _backupExport(),
      mimeType: 'application/json',
    );

    if (!ok) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() => _lastBackupAt = now);
    await _prefs?.setInt('m-last-backup-at', now);
  }


  Future<bool> _setPrivacyLock(bool value) async {
    if (!value) {
      setState(() {
        _privacyLock = false;
        _privacyUnlocked = false;
      });
      _syncPrivacyOverlay();
      await _prefs?.setBool('m-privacy-lock', false);
      return true;
    }
    final available = await _canUsePrivacyLock();
    if (!available) {
      _showToast(
        'Add a screen lock in Android settings to turn on App Lock',
        warning: true,
      );
      return false;
    }
    final unlocked = await _unlockPrivacyLock();
    if (!unlocked) return false;
    setState(() => _privacyLock = true);
    _syncPrivacyOverlay();
    await _prefs?.setBool('m-privacy-lock', true);
    return true;
  }

  Future<bool> _canUsePrivacyLock() async {
    try {
      return await _fileChannel.invokeMethod<bool>('canUsePrivacyLock') ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _unlockPrivacyLock() async {
    if (_privacyAuthInFlight) return _privacyUnlocked;
    _privacyAuthInFlight = true;
    try {
      final ok =
          await _fileChannel.invokeMethod<bool>('authenticatePrivacyLock') ??
          false;
      if (ok) {
        _privacyPausedAt = null;
        _privacyAuthGraceUntil = DateTime.now().add(const Duration(seconds: 2));
      }
      if (mounted) {
        setState(() => _privacyUnlocked = ok);
        _syncPrivacyOverlay();
        if (ok && _prefs != null && !_startupChecksStarted) {
          unawaited(_runStartupChecks(_prefs!));
        }
      }
      if (!ok && mounted) {
        _showToast(
          'App Lock stays off until you confirm your Android screen lock.',
          warning: true,
        );
      }
      return ok;
    } catch (_) {
      if (mounted) {
        _showToast('App Lock needs a device screen lock', warning: true);
      }
      return false;
    } finally {
      _privacyAuthInFlight = false;
    }
  }

  Future<void> _setAppIconStyle(String style, {bool showToast = true}) async {
    if (_appIconChangeInFlight) return;
    _appIconChangeInFlight = true;
    if (mounted && showToast) {
      unawaited(
        showGeneralDialog<void>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.56),
          barrierDismissible: false,
          barrierLabel: 'Applying app icon',
          transitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (_, _, _) => AppIconApplyingDialog(p: p),
          transitionBuilder: (_, animation, _, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
    try {
      await _fileChannel.invokeMethod<void>('setAppIconStyle', {
        'style': style,
      });
      if (showToast) {
        await Future<void>.delayed(const Duration(milliseconds: 2200));
      }
      if (mounted && showToast) _showToast('App icon changed');
    } catch (_) {
      if (mounted && showToast) {
        _showToast('App icon could not be changed', warning: true);
      }
    } finally {
      if (mounted && showToast) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }
      _appIconChangeInFlight = false;
    }
  }

  Future<void> _importBackupFile() async {
    String? content;

    try {
      content = await _fileChannel.invokeMethod<String>('openTextFile', {
        'mimeType': 'application/json',
      });
    } catch (_) {
      _showToast('Could not open backup file', warning: true);
      return;
    }

    if (content == null || content.trim().isEmpty) {
      _showToast('Import cancelled', warning: true);
      return;
    }

    try {
      final importTask = developer.TimelineTask()
        ..start('notekar.backup_import');
      final validation = developer.Timeline.timeSync(
        'notekar.backup_import.validate',
        () => validateNoteKarBackupContent(content!),
      );
      if (!validation.isValid) {
        importTask.finish();
        _showToast(validation.error ?? 'Invalid backup file', warning: true);
        return;
      }

      final imported = validation.entries;
      final dryRun = buildBackupDryRunSummary(
        validation: validation,
        existingEntries: _entries,
      );
      if (imported.isEmpty) {
        importTask.finish();
        if (_entries.isNotEmpty) {
          _showToast('Backup has no new moments', warning: true);
        } else {
          _showToast('This backup contains no moments', warning: true);
        }
        return;
      }

      final confirmed = await _confirmBackupImport(dryRun);
      if (confirmed != true) {
        importTask.finish();
        _showToast('Import cancelled');
        return;
      }

      final settings = validation.settings;

      final importedTheme = settings['theme'] as String?;
      final importedDefaultMode = settings['defaultMode'] as String?;
      final importedAccentColor = settings['accentColor'] as String?;
      final importedAppIconStyle = settings['appIconStyle'] as String?;
      final importedHapticStyle = settings['hapticStyle'] as String?;
      final importedHistoryDensity = settings['historyDensity'] as String?;
      final importedBackupReminderDays = settings['backupReminderDays'];
      final importedHomeMenuAnimations = settings['homeMenuAnimations'];
      final importedTapDelay = settings['tapDelay'];

      final nextTheme =
          (importedTheme == 'dark' ||
              importedTheme == 'light' ||
              importedTheme == 'amoled')
          ? importedTheme!
          : _theme;
      final nextDefaultMode =
          (importedDefaultMode == 'single' || importedDefaultMode == 'two-way')
          ? importedDefaultMode!
          : _defaultMode;
      final nextTapDelay =
          importedTapDelay is num &&
              delayValues.contains(importedTapDelay.toInt())
          ? importedTapDelay.toInt()
          : _tapDelay;
      final nextAccentColor = accentOptions.contains(importedAccentColor)
          ? importedAccentColor!
          : _accentColor;
      final nextAppIconStyle = isAppIconStyle(importedAppIconStyle)
          ? importedAppIconStyle!
          : _appIconStyle;
      final nextHapticStyle =
          ['off', 'light', 'standard'].contains(importedHapticStyle)
          ? importedHapticStyle!
          : _hapticStyle;
      final nextHistoryDensity =
          ['comfortable', 'compact'].contains(importedHistoryDensity)
          ? importedHistoryDensity == 'compact'
                ? 'compact'
                : 'comfortable'
          : _historyDensity;
      final nextBackupReminderDays =
          importedBackupReminderDays is num &&
              [0, 7, 14, 30].contains(importedBackupReminderDays.toInt())
          ? importedBackupReminderDays.toInt()
          : _backupReminderDays;
      final nextHomeMenuAnimations = importedHomeMenuAnimations is bool
          ? importedHomeMenuAnimations
          : _homeMenuAnimations;

      var nextId = math.max(
        _nextId,
        _entries.isEmpty
            ? 1
            : _entries.map((entry) => entry.id).reduce(math.max) + 1,
      );

      final existingKeys = _entries
          .map((entry) => '${entry.timestamp}|${entry.type}|${entry.note}')
          .toSet();

      final merged = List<Moment>.from(_entries);
      var addedCount = 0;

      for (final entry in imported) {
        final key = '${entry.timestamp}|${entry.type}|${entry.note}';
        if (existingKeys.contains(key)) continue;

        existingKeys.add(key);
        merged.add(
          Moment(
            id: nextId++,
            timestamp: entry.timestamp,
            type: entry.type,
            date: entry.date,
            note: entry.note,
          ),
        );
        addedCount++;
      }

      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final oldNextId = _nextId;
      _nextId = nextId;
      final persistTask = developer.TimelineTask()
        ..start('notekar.backup_import.persist');
      try {
        await _replaceStoredEntries(merged);
        await _saveSetting('m-theme', nextTheme);
        await _saveSetting('m-default-mode', nextDefaultMode);
        await _saveSetting('m-mode', nextDefaultMode);
        await _saveSetting('m-delay', nextTapDelay);
        await _saveSetting('m-accent-color', nextAccentColor);
        await _saveSetting('m-app-icon-style', nextAppIconStyle);
        await _saveSetting('m-haptic-style', nextHapticStyle);
        await _saveSetting('m-history-density', nextHistoryDensity);
        await _prefs?.setInt('m-backup-reminder-days', nextBackupReminderDays);
        await _prefs?.setBool('m-home-menu-animations', nextHomeMenuAnimations);
        await _prefs?.remove('m-inout');
        await _prefs?.remove('m-ses');
      } catch (_) {
        _nextId = oldNextId;
        importTask.finish();
        _showToast(
          'Import stopped safely. Your current data was not changed.',
          warning: true,
        );
        return;
      } finally {
        persistTask.finish();
      }

      setState(() {
        _entries = merged;
        _nextId = nextId;
        _lastId = null;
        _lastDeletedPreview = null;
        _theme = nextTheme;
        _defaultMode = nextDefaultMode;
        _mode = nextDefaultMode;
        _tapDelay = nextTapDelay;
        _accentColor = nextAccentColor;
        _appIconStyle = nextAppIconStyle;
        _hapticStyle = nextHapticStyle;
        _haptics = _hapticStyle != 'off';
        _historyDensity = nextHistoryDensity;
        _compactHistory = _historyDensity == 'compact';
        _backupReminderDays = nextBackupReminderDays;
        _homeMenuAnimations = nextHomeMenuAnimations;
        _inout = 'in';
        _sessionStart = null;
      });

      if (_homeMenuAnimations) {
        final motionAvailable = await _canUseMotionSensor();

        if (motionAvailable) {
          _startMotionIfNeeded();
        } else {
          if (mounted) setState(() => _homeMenuAnimations = false);

          _motion.value = Offset.zero;

          await _prefs?.setBool('m-home-menu-animations', false);
          _showToast('Motion sensor unavailable', warning: true);
        }
      }

      _showToast(
        addedCount == 0
            ? 'Backup has no new moments'
            : 'Imported $addedCount new moments',
        warning: addedCount == 0,
      );
      importTask.finish();
      unawaited(_updateAndroidWidget());
    } catch (_) {
      _showToast(
        'Import failed. The backup file looks damaged.',
        warning: true,
      );
    }
  }

  Future<bool?> _confirmBackupImport(BackupDryRunSummary summary) {
    return showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close backup preview',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => BackupImportPreviewDialog(
        p: p,
        summary: summary,
        blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion,
      ),
    );
  }

  void _applySystemUiStyle() {
    final palette = p;
    final light = _theme == 'light';

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: palette.surface,
        systemNavigationBarDividerColor: palette.border,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: light ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness: light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  void _showDuration(Moment a, Moment b) {
    final start = math.min(a.timestamp, b.timestamp);
    final end = math.max(a.timestamp, b.timestamp);
    final duration = Duration(milliseconds: end - start);
    showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close duration',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => AppSheet(
        p: p,
        title: 'Time Between Moments',
        blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${timeOnly(start)} - ${timeOnly(end)}',
              style: TextStyle(color: p.text2),
            ),
            const SizedBox(height: 10),
            Text(
              durationLabel(duration, extended: _extendedDuration),
              style: TextStyle(
                color: p.text,
                fontSize: 44,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Okay'),
            ),
          ],
        ),
      ),
    );
  }

  String _csvExport({DateTime? since}) {
    final exportedAt = DateTime.now().toIso8601String();
    final buffer = StringBuffer(
      'app,version,exported_at,id,timestamp,iso,date,time,type,note\n',
    );
    final rows =
        _entries
            .where(
              (entry) =>
                  since == null ||
                  DateTime.fromMillisecondsSinceEpoch(
                    entry.timestamp,
                  ).isAfter(since),
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (final e in rows) {
      final iso = DateTime.fromMillisecondsSinceEpoch(
        e.timestamp,
      ).toIso8601String();
      buffer.writeln(
        '"NoteKar","$appVersion","$exportedAt",${e.id},${e.timestamp},'
        '"$iso","${e.date}","${timeOnly(e.timestamp)}","${e.type}",'
        '"${e.note.replaceAll('"', '""')}"',
      );
    }
    return buffer.toString();
  }

  String _jsonExport() {
    final rows = [..._entries]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'NoteKar',
      'version': appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'entries': rows
          .map(
            (e) => {
              ...e.toJson(),
              'iso': DateTime.fromMillisecondsSinceEpoch(
                e.timestamp,
              ).toIso8601String(),
            },
          )
          .toList(),
    });
  }

  String _backupExport() {
    final rows = [..._entries]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'NoteKar',
      'kind': 'backup',
      'version': appVersion,
      'build': appBuildNumber,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': {
        'theme': _theme,
        'defaultMode': _defaultMode,
        'tapDelay': _tapDelay,
        'accentColor': _accentColor,
        'appIconStyle': _appIconStyle,
        'hapticStyle': _hapticStyle,
        'historyDensity': _historyDensity,
        'backupReminderDays': _backupReminderDays,
        'homeMenuPill': _homeMenuPill,
        'homeMenuAnimations': _homeMenuAnimations,
        'showHistoryText': _showHistoryText,
        'privacyLockDelayMinutes': _privacyLockDelayMinutes,
      },
      'entries': rows
          .map(
            (e) => {
              ...e.toJson(),
              'iso': DateTime.fromMillisecondsSinceEpoch(
                e.timestamp,
              ).toIso8601String(),
            },
          )
          .toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = p;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final lastSaved = _lastId != null;

    return Scaffold(
      backgroundColor: palette.bg,
      resizeToAvoidBottomInset: false,
      body: ColoredBox(
        color: palette.bg,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                color: palette.bg,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: _handleTap,
                  onLongPress: _openNote,
                ),
              ),
            ),
            IgnorePointer(
              child: Center(
                child: RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: spacing24,
                      right: spacing24,
                      bottom: 104 + bottomInset,
                    ),
                    child: LiveClockFace(
                      p: palette,
                      pulseToken: _savedPulseToken,
                      pulseType: _lastSavedType,
                      showSeconds: _showSeconds,
                      highlightSeconds: _highlightSeconds,
                    ),
                  ),
                ),
              ),
            ),
            if (_lastTapPosition != null && !_reduceMotion)
              IgnorePointer(
                child: Stack(
                  children: [
                    Ripple(
                      key: ValueKey(_rippleToken),
                      origin: _lastTapPosition!,
                      color: palette.accent,
                    ),
                    SavedPulse(
                      key: ValueKey(_savedPulseToken),
                      origin: _lastTapPosition!,
                      p: palette,
                      type: _lastSavedType,
                    ),
                  ],
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              top: MediaQuery.paddingOf(context).top + spacing16,
              left: spacing16,
              right: spacing16,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _toastVisible ? 1 : 0,
                  duration: Duration(milliseconds: _toastVisible ? 120 : 170),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: _toastWarning ? palette.red : palette.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _toastWarning ? palette.red : palette.border,
                          ),
                          boxShadow: palette.name == 'amoled'
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                        ),
                        child: Text(
                          _toast ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _toastWarning ? Colors.white : palette.text,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (lastSaved && _showLastSavedHint)
              Positioned(
                left: 0,
                right: 0,
                bottom: 102 + bottomInset,
                child: UndoToast(
                  p: palette,
                  onUndo: _undoLast,
                  token: _lastId ?? 0,
                ),
              ),
            Positioned(
              left: spacing16,
              right: spacing16,
              bottom: spacing16 + bottomInset,
              child: RepaintBoundary(
                child: ValueListenableBuilder<Offset>(
                  valueListenable: _motion,
                  builder: (context, motion, _) {
                    return Toolbar(
                      p: palette,
                      mode: _mode,
                      onMode: _toggleMode,
                      onHistory: _openHistory,
                      onSettings: _openSettings,
                      showLabels: _buttonLabels,
                      largeControls: _largeControls,
                      showBackgroundPill: _homeMenuPill,
                      animateIcons: _homeMenuAnimations && !_reduceMotion,
                      motionX: motion.dx,
                      motionY: motion.dy,
                      showHistoryText: _showHistoryText,
                      blur: _enableTranslucency && AdaptiveEngine().supportsBlur && !_reduceMotion,
                    );
                  },
                ),
              ),
            ),
            if (_lastDeletedPreview != null)
              Positioned(
                left: spacing16,
                right: spacing16,
                top: MediaQuery.paddingOf(context).top + 72,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: spacing16,
                      vertical: spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: palette.border),
                    ),
                    child: Text(
                      'Deleted ${_lastDeletedPreview!.type.toUpperCase()} moment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.text2,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            if (_factoryResetVisible)
              FactoryResetOverlay(
                p: palette,
                progress: _factoryResetProgress,
                complete: _factoryResetComplete,
                status: _factoryResetText,
                onStart: _finishFactoryResetOverlay,
              ),
            if (_privacyLock && !_privacyUnlocked)
              PrivacyLockOverlay(
                p: palette,
                onUnlock: () => unawaited(_unlockPrivacyLock()),
              ),
          ],
        ),
      ),
    );
  }
}
