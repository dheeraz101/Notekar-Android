import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoAlertDialog,
        CupertinoDialogAction,
        CupertinoTextField,
        CupertinoTheme,
        CupertinoThemeData,
        showCupertinoDialog;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/backup_dialogs.dart';
import 'package:notekar/dialogs/changelog_dialog.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/manual_entry_dialog.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/dialogs/privacy_overlay.dart';
import 'package:notekar/dialogs/recently_deleted_dialog.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/settings_dialog.dart';
import 'package:notekar/dialogs/smart_trim_sheet.dart';
import 'package:notekar/dialogs/time_reflection_sheet.dart';
import 'package:notekar/dialogs/urge_surfing_dialog.dart';
import 'package:notekar/main.dart';
import 'package:notekar/models/backup_models.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/sobriety_milestones.dart';
import 'package:notekar/screens/executive_intelligence_hub_screen.dart';
import 'package:notekar/screens/welcome_screen.dart';
import 'package:notekar/services/digital_wellbeing_service.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/backup_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/life_audit_service.dart';
import 'package:notekar/utils/migration_import_service.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/utils/streak_guardian_service.dart';
import 'package:notekar/utils/tag_migration_service.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/utils/update_service.dart';
import 'package:notekar/widgets/clock_face.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/dynamic_header_capsule.dart';
import 'package:notekar/widgets/feedback_widgets.dart';
import 'package:notekar/widgets/home_coachmark_tooltip.dart';
import 'package:notekar/widgets/home_minimal_toolbar_capsule.dart';
import 'package:notekar/widgets/home_pin_setup_overlay.dart';
import 'package:notekar/widgets/home_sobriety_streak_card.dart';
import 'package:notekar/widgets/milestone_celebration_dialog.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/toolbar.dart';
import 'package:notekar/widgets/top_fade_blur.dart';
import 'package:notekar/widgets/zen_doodle_splash.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home/home_backup_lifecycle.dart';

part 'home/home_reset_lifecycle.dart';

class NoteKarHome extends StatefulWidget {
  const NoteKarHome({super.key, this.preloadedPrefs});

  final SharedPreferences? preloadedPrefs;

  @override
  State<NoteKarHome> createState() => _NoteKarHomeState();
}

class _NoteKarHomeState extends State<NoteKarHome>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  void update(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  static const _welcomeSeenKey = 'notekar.welcomeSeen';
  static const _lastSeenVersionKey = 'notekar.lastSeenVersion';
  static const _fileChannel = MethodChannel('notekar/files');

  final _logger = AppLogger();
  final _repository = MomentRepository();
  final _updateService = UpdateService();
  final _categoryService = CategoryService();
  List<String> _categories = ['Work', 'Deep Focus'];
  String _activeCategory = 'All';

  SharedPreferences? _prefs;
  Timer? _undoTimer;

  Timer? _updateStatusResetTimer;

  String _theme = 'dark';
  String _defaultMode = 'two-way';
  String _mode = 'two-way';
  String _inout = 'in';
  String _locale = 'system';
  int? _sessionStart;
  bool _isPaused = false;
  int? _pausedAt;
  int _tapDelay = 0;
  bool _remoteNotices = false;
  bool _reduceMotion = false;
  bool _haptics = true;
  String _hapticStyle = 'standard';
  bool _acousticFeedback = true;
  String _accentColor = 'blue';
  String _appIconStyle = 'default';
  String _csvDelimiter = ',';
  String _historyDensity = 'comfortable';
  bool _privacyLock = false;
  bool _privacyUnlocked = false;
  String _privacyLockType = 'system';
  bool _systemLockAvailable = true;
  int _backupReminderDays = 0;
  int? _lastBackupAt;
  bool _largeText = false;
  bool _highContrast = false;

  bool _confirmDelete = false;
  bool _showSeconds = true;
  bool _highlightSeconds = true;
  bool _use24HourFormat = true;
  String _clockFont = 'BebasNeue';
  bool _buttonLabels = true;
  bool _largeControls = false;
  bool _homeMenuPill = true;
  bool _homeMenuAnimations = false;
  bool _enableTranslucency = false;
  bool _extendedDuration = false;
  bool _minimalMomentOptions = false;
  bool _useNumbersInSingle = false;
  bool _resetSingleDaily = false;
  bool _countOnSave = false;
  String? _lastSingleCount;
  bool _startupComplete = false;
  bool _splashDismissed = ZenDoodleSplash.hasShownThisSession;
  bool _hasTappedBefore = false;
  Map<String, dynamic>? _pendingTap;
  String? _pendingShortcutAction;
  bool _floatingTimerEnabled = false;
  bool _enableNoteOnClick = false;
  bool _enableSobrietyMode = false;
  String _sobrietyResetType = 'any';
  DateTime? _sobrietyCustomStart;
  String _sobrietyMilestoneTheme = 'science';
  bool _showHistoryText = true;
  bool _headerExpanded = false;
  String _toolbarAppearance = 'standard';
  int _streakShields = 0;
  bool _showLastSavedHint = true;
  int _privacyLockDelayMinutes = 0;
  DateTime? _privacyPausedAt;
  DateTime? _privacyAuthGraceUntil;
  bool _privacyAuthInFlight = false;
  OverlayEntry? _privacyOverlayEntry;
  bool _appIconChangeInFlight = false;
  bool _startupChecksStarted = false;
  String _updateStatus = 'v$appVersion - Check for available updates';
  AppUpdateInfo? _latestUpdateInfo;
  DateTime? _lastBackPressTime;
  bool _checkingUpdates = false;
  int? _lastUpdateCheckedAt;
  int? _lastNoticeOpenCheckAt;
  int _lastTapTime = 0;
  bool _isSaving = false;
  int? _lastId;
  int _nextId = 1;
  final ValueNotifier<List<Moment>> _entriesNotifier = ValueNotifier([]);

  List<Moment> get _entries => _entriesNotifier.value;

  set _entries(List<Moment> val) {
    _entriesNotifier.value = val;
  }

  final ValueNotifier<List<Moment>> _trashNotifier = ValueNotifier([]);
  bool _factoryResetVisible = false;
  bool _factoryResetComplete = false;
  double _factoryResetProgress = 0;
  String _factoryResetText = 'Preparing NoteKar...';
  String _factoryResetSubText = '';
  IconData _factoryResetIcon = Icons.settings_suggest_rounded;
  SharedPreferences? _factoryResetWelcomePrefs;
  Moment? _lastDeletedPreview;
  Offset? _lastTapPosition;
  String _lastSavedType = 'single';
  int _rippleToken = 0;
  int _savedPulseToken = 0;
  double _horizontalSwipeDelta = 0.0;
  bool _horologyDetentFired = false;

  List<Goal> _cachedGoals = [];

  String? get _activeGoalTitle {
    if (_cachedGoals.isEmpty) return null;
    final match =
        _cachedGoals.where((g) => g.category == _activeCategory).firstOrNull ??
        _cachedGoals.where((g) => g.title == _activeCategory).firstOrNull;
    if (match != null) {
      return match.title.length > 9 ? match.title.substring(0, 9) : match.title;
    }
    final first = _cachedGoals.first;
    return first.title.length > 9 ? first.title.substring(0, 9) : first.title;
  }

  void _onNextGoal() {
    if (_cachedGoals.isEmpty) return;
    final currentIndex = _cachedGoals.indexWhere(
      (g) => g.category == _activeCategory || g.title == _activeCategory,
    );
    final nextIndex = currentIndex < 0
        ? 0
        : (currentIndex + 1) % _cachedGoals.length;
    final nextGoal = _cachedGoals[nextIndex];
    unawaited(_setActiveCategory(nextGoal.category ?? nextGoal.title));
    _showToast(nextGoal.title, withHaptic: false);
  }

  void _onPrevGoal() {
    if (_cachedGoals.isEmpty) return;
    final currentIndex = _cachedGoals.indexWhere(
      (g) => g.category == _activeCategory || g.title == _activeCategory,
    );
    final prevIndex = currentIndex < 0
        ? _cachedGoals.length - 1
        : (currentIndex - 1 + _cachedGoals.length) % _cachedGoals.length;
    final prevGoal = _cachedGoals[prevIndex];
    unawaited(_setActiveCategory(prevGoal.category ?? prevGoal.title));
    _showToast(prevGoal.title, withHaptic: false);
  }

  StreamSubscription<AccelerometerEvent>? _motionSub;
  final ValueNotifier<Offset> _motion = ValueNotifier(Offset.zero);

  int _lastMotionMs = 0;
  bool _adaptiveModeColor = false;

  Color? get _activeAdaptiveColor {
    if (!_adaptiveModeColor) return null;
    final base = paletteFor(
      _theme,
      highContrast: _highContrast,
      accentName: _accentColor,
    );
    if (_activeCategory != 'All') {
      return getCategoryMeta(_activeCategory, base).color;
    }
    final isSessionActive =
        _mode == 'two-way' && (_sessionStart != null || _inout == 'out');
    if (isSessionActive) {
      return base.green;
    }
    return null;
  }

  Palette get p {
    final base = paletteFor(
      _theme,
      highContrast: _highContrast,
      accentName: _accentColor,
    );
    final adaptive = _activeAdaptiveColor;
    if (adaptive != null) {
      final lum = adaptive.computeLuminance();
      final contrastClock = lum > 0.45
          ? const Color(0xFF000000)
          : const Color(0xFFFFFFFF);
      return base.copyWith(
        bg: adaptive,
        clock: contrastClock,
        accent: adaptive,
      );
    }
    return base;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _entriesNotifier.addListener(_updateStreakShields);
    _setupMethodChannelHandlers();
    _load();
  }

  void _setupMethodChannelHandlers() {
    _fileChannel.setMethodCallHandler((call) async {
      if (call.method == 'onBackgroundLogRecorded') {
        if (_prefs != null) {
          await _prefs!.reload();
          await _syncBackgroundLogs(_prefs!);
          final savedInOut = _prefs!.getString('m-inout');
          final savedSes = _prefs!.getInt('m-ses');
          final savedPaused = _prefs!.getBool('m-paused') ?? false;
          final savedPausedAt = _prefs!.getInt('m-paused-at');
          if (mounted) {
            setState(() {
              if (savedInOut != null) _inout = savedInOut;
              _sessionStart = savedSes;
              _isPaused = savedPaused;
              _pausedAt = savedPausedAt;
            });
          }
        }
      } else if (call.method == 'onModeChanged') {
        final newMode = call.arguments as String?;
        if (newMode != null && mounted) {
          _setMode(newMode);
        }
      }
    });
  }

  @override
  void dispose() {
    _undoTimer?.cancel();
    _privacyOverlayEntry?.remove();
    _privacyOverlayEntry = null;
    _motionSub?.cancel();
    _motion.dispose();
    _updateStatusResetTimer?.cancel();
    _entriesNotifier.removeListener(_updateStreakShields);
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
    // Startup content/walkthrough check is now deferred to postFrameCallback in _load()
  }

  Future<bool> _canUseMotionSensor() async {
    final cached = AdaptiveEngine().cachedSensorAvailable;
    if (cached != null) return cached;

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

      final available = await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );

      unawaited(_prefs?.setBool('device_sensor_available', available));
      return available;
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
      unawaited(DigitalWellbeingService.instance.checkPermission());
      if (_prefs != null) {
        unawaited(() async {
          await _prefs!.reload();
          await _syncBackgroundLogs(_prefs!);
          final savedMode = _prefs!.getString('m-mode');
          final savedInOut = _prefs!.getString('m-inout');
          final savedSes = _prefs!.getInt('m-ses');
          final savedPaused = _prefs!.getBool('m-paused') ?? false;
          final savedPausedAt = _prefs!.getInt('m-paused-at');
          if (mounted) {
            setState(() {
              if (savedMode != null) _mode = savedMode;
              if (savedInOut != null) _inout = savedInOut;
              _sessionStart = savedSes;
              _isPaused = savedPaused;
              _pausedAt = savedPausedAt;
            });
          }
        }());
      }

      if (_startupComplete) {
        _startMotionIfNeeded();
      }

      if (_remoteNotices) {
        unawaited(_checkRemoteNoticeOnOpen());
      }

      if (_prefs?.getBool('auto_delete_update_cache') ?? false) {
        unawaited(_updateService.clearCachedBuilds());
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

      if (_privacyLock) {
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
        builder: (_) => MediaQuery(
          data: _largeText ? largerTextQuery(context) : MediaQuery.of(context),
          child: PrivacyLockOverlay(
            p: p,
            onUnlock: () => unawaited(_unlockPrivacyLock()),
            isSystemLockAvailable:
                _systemLockAvailable && _privacyLockType == 'system',
            customPin: _prefs?.getString('m-custom-pin'),
            failedAttempts: _prefs?.getInt('m-failed-attempts') ?? 0,
            lockoutUntil: _prefs?.getInt('m-lockout-until') ?? 0,
            onUnlockSuccess: _handleUnlockSuccess,
            onUnlockFailed: _handleUnlockFailed,
            enableTranslucency: _enableTranslucency,
            reduceMotion: _reduceMotion,
          ),
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
    final prefs =
        widget.preloadedPrefs ?? await SharedPreferences.getInstance();

    final initialCategories = await _categoryService.getCategories(
      prefs: prefs,
    );
    final initialActiveCategory = await _categoryService.getActiveCategory(
      prefs: prefs,
    );
    await UserProfileService().loadProfile(prefs: prefs);

    // Phase 1: Load non-DB settings instantly so the UI can paint immediately
    setState(() {
      _prefs = prefs;
      _categories = initialCategories;
      _activeCategory = initialActiveCategory;
      _hasTappedBefore = prefs.getBool('notekar.has_tapped_before') ?? false;
      _floatingTimerEnabled = prefs.getBool('floating_timer_enabled') ?? false;
      _enableNoteOnClick = prefs.getBool('enable_note_on_click') ?? false;
      _enableSobrietyMode = prefs.getBool('enable_sobriety_mode') ?? false;
      _sobrietyResetType = prefs.getString('sobriety_reset_type') ?? 'any';
      final customStartMs = prefs.getInt('sobriety_custom_start_ms');
      _sobrietyCustomStart = customStartMs != null
          ? DateTime.fromMillisecondsSinceEpoch(customStartMs)
          : null;
      _sobrietyMilestoneTheme =
          prefs.getString('sobriety_milestone_theme') ?? 'science';
      _theme = prefs.getString('m-theme') ?? 'dark';
      _defaultMode = prefs.getString('m-default-mode') ?? 'two-way';
      _sessionStart = prefs.getInt('m-ses');
      _isPaused = prefs.getBool('m-paused') ?? false;
      _pausedAt = prefs.getInt('m-paused-at');
      if (_sessionStart != null) {
        _mode = 'two-way';
      } else {
        _isPaused = false;
        _pausedAt = null;
        if (_defaultMode == 'single') {
          _mode = 'single';
        } else if (_defaultMode == 'two-way') {
          _mode = 'two-way';
        } else {
          // 'last-used'
          _mode = prefs.getString('m-mode') ?? 'two-way';
        }
      }
      _inout = prefs.getString('m-inout') ?? 'in';
      _tapDelay = prefs.getInt('m-delay') ?? 0;
      _remoteNotices = prefs.getBool('m-remote-notices') ?? false;
      _reduceMotion = prefs.getBool('m-reduce-motion') ?? false;
      _haptics = prefs.getBool('m-haptics') ?? true;
      _hapticStyle =
          prefs.getString('m-haptic-style') ?? (_haptics ? 'standard' : 'off');
      _haptics = _hapticStyle != 'off';
      _acousticFeedback = prefs.getBool('m-acoustic-feedback') ?? true;
      AppSound.setEnabled(_acousticFeedback);
      _accentColor = prefs.getString('m-accent-color') ?? 'blue';
      final savedAppIconStyle =
          prefs.getString('m-app-icon-style') ?? 'default';
      _appIconStyle = isAppIconStyle(savedAppIconStyle)
          ? savedAppIconStyle
          : 'default';
      _csvDelimiter = prefs.getString('m-csv-delimiter') ?? ',';

      _privacyLock = prefs.getBool('m-privacy-lock') ?? false;
      _privacyLockType = prefs.getString('m-privacy-lock-type') ?? 'system';
      _backupReminderDays = prefs.getInt('m-backup-reminder-days') ?? 0;
      _lastBackupAt = prefs.getInt('m-last-backup-at');
      _largeText = prefs.getBool('m-large-text') ?? false;
      _highContrast = prefs.getBool('m-high-contrast') ?? false;

      _confirmDelete = prefs.getBool('m-confirm-delete') ?? false;
      _adaptiveModeColor =
          prefs.getBool('m-adaptive-color') ??
          prefs.getBool('adaptive_mode_color') ??
          false;
      _showSeconds = prefs.getBool('m-show-seconds') ?? true;
      setGlobalShowSeconds(_showSeconds);
      _highlightSeconds = prefs.getBool('m-highlight-seconds') ?? true;
      _use24HourFormat = prefs.getBool('m-use-24-hour') ?? true;
      setGlobalUse24Hour(_use24HourFormat);
      _clockFont = prefs.getString('m-clock-font') ?? 'BebasNeue';
      _buttonLabels = prefs.getBool('m-button-labels') ?? false;
      _largeControls = prefs.getBool('m-large-controls') ?? false;
      _homeMenuPill = prefs.getBool('m-home-menu-pill') ?? true;
      _homeMenuAnimations = prefs.getBool('m-home-menu-animations') ?? false;
      _enableTranslucency = prefs.getBool('m-translucency') ?? false;
      _extendedDuration = prefs.getBool('m-extended-duration') ?? false;
      _minimalMomentOptions =
          prefs.getBool('m-minimal-moment-options') ?? false;
      _useNumbersInSingle = prefs.getBool('m-use-numbers-in-single') ?? false;
      _resetSingleDaily = prefs.getBool('m-reset-single-daily') ?? false;
      _countOnSave = prefs.getBool('m-count-on-save') ?? false;
      _showHistoryText = prefs.getBool('m-show-history-text') ?? true;
      _toolbarAppearance = prefs.getString('toolbar_appearance') ?? 'standard';
      _showLastSavedHint = prefs.getBool('m-show-last-saved-hint') ?? true;
      _privacyLockDelayMinutes = prefs.getInt('m-privacy-lock-delay') ?? 0;
      _updateStatus = prefs.getString('m-update-status') ?? _updateStatus;
      _lastUpdateCheckedAt = prefs.getInt('m-last-update-check');
      final savedInfo = prefs.getString('m-latest-update-info');
      if (savedInfo != null) {
        try {
          final info = AppUpdateInfo.fromJson(
            jsonDecode(savedInfo) as Map<String, dynamic>,
          );
          if (_updateService.isUpdateAvailable(info.version, appVersion)) {
            _latestUpdateInfo = info;
          } else {
            prefs.remove('m-latest-update-info');
            _updateStatus = 'v$appVersion - Check for available updates';
            prefs.setString('m-update-status', _updateStatus);
          }
        } catch (_) {}
      }
      _locale = prefs.getString('m-locale') ?? 'system';
    });

    _applySystemUiStyle();

    // Early check for lockscreen reflection alarm
    try {
      final earlyAction = await _fileChannel.invokeMethod<String>(
        'getLaunchAction',
      );
      if (earlyAction == 'reflection') {
        final isLocked =
            await _fileChannel.invokeMethod<bool>('isDeviceLocked') ?? false;
        if (mounted) {
          await _showStandaloneMindfulness(isLocked: isLocked);
          if (isLocked) {
            await _fileChannel.invokeMethod<void>('closeLockscreenActivity');
            return;
          }
        }
      }
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final welcomeSeen = prefs.getBool(_welcomeSeenKey) ?? false;
      final lastSeenVersion = prefs.getString(_lastSeenVersionKey) ?? '';
      final appIconsWalkthroughSeen =
          prefs.getBool('notekar.appIconsWalkthroughSeen_v9') ?? false;
      final singleNumberingWalkthroughSeen =
          prefs.getBool('notekar.singleNumberingWalkthroughSeen_v7') ?? false;

      final isVersionUpgrade =
          lastSeenVersion.isNotEmpty && lastSeenVersion != appVersion;

      if (!welcomeSeen ||
          isVersionUpgrade ||
          !appIconsWalkthroughSeen ||
          !singleNumberingWalkthroughSeen) {
        if (mounted) {
          await _showWelcomeIfNeeded(prefs);
        }
      }

      // Initialize MomentRepository and load database entries
      await _repository.initialize(preloadedPrefs: prefs);
      await TagMigrationService.migrateIfNeeded();
      await TagService.instance.load();
      final migrated = await _repository.migrateLegacyData();
      final entries = _repository.getAllMoments();
      final trash = _repository.getTrashMoments();
      final nextId = _repository.getNextId();

      if (!mounted) return;

      if (migrated.isNotEmpty) {
        _logger.info(
          'Merging ${migrated.length} migrated entries into active list',
        );
      }

      if (entries.isNotEmpty) {
        _hasTappedBefore = true;
        unawaited(prefs.setBool('notekar.has_tapped_before', true));
      }

      final goals = await GoalsService.instance.getGoals();

      setState(() {
        _entries = entries;
        _trashNotifier.value = trash;
        _cachedGoals = goals;
        _nextId = nextId;
        _startupComplete = true; // DB operations ready
      });
      unawaited(_updateStreakShields());
      unawaited(_evaluateStreakGuardian(entries));

      final wasCorrupted =
          prefs.getBool(MomentRepository.keyCorruptedFlag) ?? false;
      final recoveredFromSnapshot =
          prefs.getBool(MomentRepository.keyRecoveredFromSnapshot) ?? false;
      if (wasCorrupted) {
        unawaited(prefs.remove(MomentRepository.keyCorruptedFlag));
        unawaited(prefs.remove(MomentRepository.keyRecoveredFromSnapshot));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showCorruptionNotificationDialog(recoveredFromSnapshot);
        });
      }

      // Run quick actions and notifications check
      _initQuickActions();
      await _syncBackgroundLogs(prefs);
      unawaited(_checkSystemLockAvailability());
      try {
        unawaited(_updateAndroidWidget());
      } catch (e, stack) {
        _logger.error('Failed to update widget on load', e, stack);
      }

      if (_homeMenuAnimations) {
        try {
          unawaited(_restoreMotionAfterStartup(prefs));
        } catch (e, stack) {
          _logger.warn('Failed to restore motion after startup', e, stack);
        }
      }

      if (_privacyLock) {
        _syncPrivacyOverlay();
        unawaited(_unlockAfterFirstPaint(prefs));
      } else {
        unawaited(_runStartupChecks(prefs));
      }

      // Process any taps that occurred while the database was loading
      if (_pendingTap != null) {
        await _processPendingTap();
      }

      if (_pendingShortcutAction != null) {
        final action = _pendingShortcutAction!;
        _pendingShortcutAction = null;
        _executeShortcutAction(action);
      }
    });

    startupTask.finish();
  }

  Future<void> _processPendingTap() async {
    final pending = _pendingTap;
    if (pending == null) return;
    _pendingTap = null;

    await _logEntry(
      note: pending['note'] as String?,
      position: pending['position'] as Offset?,
      forcedType: pending['forcedType'] as String?,
      timestamp: pending['timestamp'] as int?,
    );
  }

  void _initQuickActions() {
    const quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if (!mounted) return;
      if (!_startupComplete || (_privacyLock && !_privacyUnlocked)) {
        _pendingShortcutAction = shortcutType;
        return;
      }
      _executeShortcutAction(shortcutType);
    });
    _updateDynamicShortcuts();
  }

  void _executeShortcutAction(String shortcutType) {
    if (shortcutType == 'quick_session') {
      if (_mode != 'two-way') {
        _setMode('two-way');
      }
      unawaited(_logEntry(forcedType: 'in'));
    } else if (shortcutType == 'quick_session_end') {
      unawaited(_logEntry(forcedType: 'out'));
    } else if (shortcutType == 'log_past_moment') {
      unawaited(_openManualEntry());
    } else if (shortcutType == 'open_search') {
      unawaited(_openSettings(initialCategory: 'Search Notes'));
    }
  }

  void _updateDynamicShortcuts() {
    try {
      const quickActions = QuickActions();
      final items = <ShortcutItem>[];

      // Shortcut 1: Quick Session (Starts timer immediately)
      if (_mode == 'two-way' && (_sessionStart != null || _inout == 'out')) {
        items.add(
          const ShortcutItem(
            type: 'quick_session_end',
            localizedTitle: 'End Session',
            icon: 'ic_launcher',
          ),
        );
      } else {
        items.add(
          const ShortcutItem(
            type: 'quick_session',
            localizedTitle: 'Quick Session',
            icon: 'ic_launcher',
          ),
        );
      }

      // Shortcut 2: Log Past Moment (Opens manual entry)
      items.add(
        const ShortcutItem(
          type: 'log_past_moment',
          localizedTitle: 'Log Past Moment',
          icon: 'ic_launcher',
        ),
      );

      // Shortcut 3: Search (Opens History search)
      items.add(
        const ShortcutItem(
          type: 'open_search',
          localizedTitle: 'Search',
          icon: 'ic_launcher',
        ),
      );

      quickActions.setShortcutItems(items);
    } catch (_) {}
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
    try {
      unawaited(_handlePendingLaunchAction());
    } catch (e, stack) {
      _logger.error('Failed to handle pending launch action', e, stack);
    }

    if (prefs.getBool('m-remote-notices') ?? false) {
      try {
        unawaited(_checkRemoteNoticeOnOpen());
      } catch (e, stack) {
        _logger.warn('Failed to check remote notices on startup', e, stack);
      }
    }
    startupTask.finish();
  }

  void _maybeShowBackupReminder() {
    if (!mounted || _backupReminderDays <= 0 || _entries.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final int baselineTs;

    if (_lastBackupAt != null) {
      baselineTs = _lastBackupAt!;
    } else {
      // If never backed up, use the timestamp of the oldest moment.
      // This prevents annoying reminders for new users or fresh imports.
      baselineTs = _entries.map((e) => e.timestamp).reduce(math.min);
    }

    final age = now.difference(DateTime.fromMillisecondsSinceEpoch(baselineTs));
    if (age.inDays < _backupReminderDays) {
      return;
    }

    final today = dateKey(now);
    if (_prefs?.getString('m-last-backup-reminder-day') == today) return;
    _prefs?.setString('m-last-backup-reminder-day', today);
    _showToast('Backup reminder: export a fresh backup soon', warning: true);
  }

  Future<void> _saveEntry(Moment entry) async {
    await _repository.saveMoment(entry);
    setState(() => _nextId = _repository.getNextId());
  }

  Future<void> _deleteStoredEntry(int id) async {
    await _repository.deleteMoment(id);
    _trashNotifier.value = _repository.getTrashMoments();
    setState(() => _nextId = _repository.getNextId());
  }

  Future<void> _clearStoredEntries() async {
    await _repository.clearAll();
    _trashNotifier.value = _repository.getTrashMoments();
    setState(() {
      _entries = [];
      _nextId = _repository.getNextId();
    });
  }

  Future<void> _replaceStoredEntries(List<Moment> entries) async {
    await _repository.replaceAll(entries);
    setState(() => _nextId = _repository.getNextId());
  }

  Future<void> _saveSetting(String key, Object value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    if (value is String) await prefs.setString(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is bool) await prefs.setBool(key, value);
  }

  Future<void> _showWelcomeIfNeeded(SharedPreferences prefs) async {
    final welcomeSeen = prefs.getBool(_welcomeSeenKey) ?? false;

    if (!welcomeSeen) {
      // 1. New Users: Show full onboarding flow with all pages
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WelcomeScreen(
            p: p,
            theme: _theme,
            defaultMode: _defaultMode,
            currentLocale: _locale,
            appIconStyle: _appIconStyle,
            useNumbersInSingle: _useNumbersInSingle,
            resetSingleDaily: _resetSingleDaily,
            countOnSave: _countOnSave,
            enableSobrietyMode: _enableSobrietyMode,
            sobrietyMilestoneTheme: _sobrietyMilestoneTheme,

            onAppIconStyle: (value) async {
              setState(() => _appIconStyle = value);
              await _setAppIconStyle(value, showToast: false);
            },
            onLocaleChanged: (value) {
              NoteKarApp.of(context)?.setLocale(value);
              setState(() => _locale = value);
            },
            onTheme: (value) {
              NoteKarApp.of(context)?.setTheme(value);
              setState(() => _theme = value);
              _saveSetting('m-theme', value);
              _applySystemUiStyle();
            },
            onDefaultMode: (value) {
              setState(() => _defaultMode = value);
              _saveSetting('m-default-mode', value);
            },
            onUseNumbersInSingle: (value) {
              setState(() => _useNumbersInSingle = value);
              _saveSetting('m-use-numbers-in-single', value);
            },
            onResetSingleDaily: (value) {
              setState(() => _resetSingleDaily = value);
              _saveSetting('m-reset-single-daily', value);
            },
            onCountOnSave: (value) {
              setState(() => _countOnSave = value);
              _saveSetting('m-count-on-save', value);
            },
            onSobrietyMode: (value) {
              setState(() => _enableSobrietyMode = value);
              _prefs?.setBool('enable_sobriety_mode', value);
            },
            onSobrietyMilestoneTheme: (value) {
              setState(() => _sobrietyMilestoneTheme = value);
              _prefs?.setString('sobriety_milestone_theme', value);
            },

            pages: const [
              'welcome',
              'language',
              'features',
              'permissions',
              'security',
            ],
          ),
        ),
      );
      if (mounted) {
        setState(() {
          _useNumbersInSingle =
              prefs.getBool('m-use-numbers-in-single') ?? _useNumbersInSingle;
          _resetSingleDaily =
              prefs.getBool('m-reset-single-daily') ?? _resetSingleDaily;
          _countOnSave = prefs.getBool('m-count-on-save') ?? _countOnSave;
          _enableSobrietyMode =
              prefs.getBool('enable_sobriety_mode') ?? _enableSobrietyMode;
          _sobrietyMilestoneTheme =
              prefs.getString('sobriety_milestone_theme') ??
              _sobrietyMilestoneTheme;

          _historyDensity =
              prefs.getString('m-history-density') ?? _historyDensity;
          _appIconStyle = prefs.getString('m-app-icon-style') ?? _appIconStyle;
        });
      }
      await prefs.setBool(_welcomeSeenKey, true);
      await prefs.setString(_lastSeenVersionKey, appVersion);
      await prefs.setBool('notekar.remindersWalkthroughSeen', true);
      await prefs.setBool('notekar.securityWalkthroughSeen_v5', true);
      await prefs.setBool('notekar.networkWalkthroughSeen_v5', true);
      await prefs.setBool('notekar.sobrietyWalkthroughSeen_v6', true);
      await prefs.setBool('notekar.singleNumberingWalkthroughSeen_v7', true);
      await prefs.setBool('notekar.appIconsWalkthroughSeen_v9', true);
      await prefs.setBool('notekar.mindfulnessWalkthroughSeen_v10', true);
      await prefs.setBool('notekar.lifeAuditIntroSeen_v11', true);
      await prefs.setBool('notekar.historyRedesignTourSeen_v11', true);
      await prefs.setBool('notekar.dashboardRedesignTourSeen_v11', true);
    } else {
      // 2. Upgraded Users: Keep their workflow uninterrupted; silently record feature tour version flags
      await prefs.setBool('notekar.lifeAuditIntroSeen_v11', true);
      await prefs.setBool('notekar.historyRedesignTourSeen_v11', true);
      await prefs.setBool('notekar.dashboardRedesignTourSeen_v11', true);
      await prefs.setString(_lastSeenVersionKey, appVersion);
      await prefs.setBool('notekar.appIconsWalkthroughSeen_v9', true);
      await prefs.setBool('notekar.securityWalkthroughSeen_v5', true);
      await prefs.setBool('notekar.remindersWalkthroughSeen', true);
      await prefs.setBool('notekar.networkWalkthroughSeen_v5', true);
      await prefs.setBool('notekar.sobrietyWalkthroughSeen_v6', true);
      await prefs.setBool('notekar.singleNumberingWalkthroughSeen_v7', true);
      await prefs.setBool('notekar.mindfulnessWalkthroughSeen_v10', true);
    }
  }

  Future<void> _logEntry({
    String? note,
    List<String>? tags,
    Offset? position,
    String? forcedType,
    int? timestamp,
  }) async {
    if (_isSaving) return;
    _isSaving = true;

    final now = timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.now();
    final reminderTitle = 'Logging Reminder'.localized(context);
    final reminderBody = 'Time to log a moment!'.localized(context);
    var type = forcedType ?? 'single';
    final oldInOut = _inout;
    final oldSessionStart = _sessionStart;

    if (forcedType == null && _mode == 'two-way') {
      type = _inout;
      if (_inout == 'in') {
        _sessionStart = now.millisecondsSinceEpoch;
        _inout = 'out';
        _isPaused = false;
        _pausedAt = null;
        unawaited(_prefs?.setBool('m-paused', false));
        unawaited(_prefs?.remove('m-paused-at'));
      } else {
        if (_isPaused && _pausedAt != null) {
          final pausedTurnMs = now.millisecondsSinceEpoch - _pausedAt!;
          final adjustedStart =
              (_sessionStart ?? now.millisecondsSinceEpoch) + pausedTurnMs;
          final inMoment = _entries.where((e) => e.type == 'in').firstOrNull;
          if (inMoment != null) {
            final updatedIn = inMoment.copyWith(timestamp: adjustedStart);
            unawaited(_repository.saveMoment(updatedIn));
          }
        }
        _sessionStart = null;
        _inout = 'in';
        _isPaused = false;
        _pausedAt = null;
        unawaited(_prefs?.setBool('m-paused', false));
        unawaited(_prefs?.remove('m-paused-at'));
      }
    } else if (forcedType != null) {
      if (forcedType == 'in') {
        _sessionStart = now.millisecondsSinceEpoch;
        _inout = 'out';
        _isPaused = false;
        _pausedAt = null;
        unawaited(_prefs?.setBool('m-paused', false));
        unawaited(_prefs?.remove('m-paused-at'));
      } else if (forcedType == 'out') {
        if (_isPaused && _pausedAt != null) {
          final pausedTurnMs = now.millisecondsSinceEpoch - _pausedAt!;
          final adjustedStart =
              (_sessionStart ?? now.millisecondsSinceEpoch) + pausedTurnMs;
          final inMoment = _entries.where((e) => e.type == 'in').firstOrNull;
          if (inMoment != null) {
            final updatedIn = inMoment.copyWith(timestamp: adjustedStart);
            unawaited(_repository.saveMoment(updatedIn));
          }
        }
        _sessionStart = null;
        _inout = 'in';
        _isPaused = false;
        _pausedAt = null;
        unawaited(_prefs?.setBool('m-paused', false));
        unawaited(_prefs?.remove('m-paused-at'));
      }
    }

    String? singleCount;
    if (_countOnSave && type == 'single') {
      int count = 0;
      if (_resetSingleDaily) {
        final todayKey = dateKey(now);
        count = _entries
            .where((e) => e.type == 'single' && e.date == todayKey)
            .length;
      } else {
        count = _entries.where((e) => e.type == 'single').length;
      }
      singleCount = (count % 100).toString().padLeft(2, '0');
    }

    // Save to queue if DB is not ready yet
    if (!_startupComplete) {
      // Trigger optimistic UI animations (ripple and pulse) immediately
      setState(() {
        _lastTapTime = now.millisecondsSinceEpoch;
        _lastTapPosition = position;
        _lastSavedType = type;
        _lastSingleCount = singleCount;
        _rippleToken++;
        _savedPulseToken++;
      });
      NotekarHaptics.save(_hapticStyle, type);
      if (_acousticFeedback) {
        AppSound.click();
      }

      _pendingTap = {
        'note': note?.trim() ?? '',
        'position': position,
        'forcedType': forcedType,
        'timestamp': now.millisecondsSinceEpoch,
      };

      // Rollback session state until DB load completes and actual log executes
      _inout = oldInOut;
      _sessionStart = oldSessionStart;

      _isSaving = false;
      return;
    }

    DateTime effectiveNow = now;
    if (type == 'out' && oldSessionStart != null && mounted) {
      final sessionStartDt = DateTime.fromMillisecondsSinceEpoch(
        oldSessionStart,
      );
      final sessionDuration = now.difference(sessionStartDt);
      if (sessionDuration.inMinutes >= 180) {
        final p = paletteFor(
          _theme,
          highContrast: _highContrast,
          accentName: _accentColor,
        );
        final trimmed = await showSmartTrimSheet(
          context,
          p: p,
          startDateTime: sessionStartDt,
          originalEndDateTime: now,
          category: _activeCategory,
          blur: !_reduceMotion && _enableTranslucency,
          largeText: _largeText,
        );
        if (trimmed != null) {
          effectiveNow = trimmed;
        }
      }
    }

    final isGodModeTrigger =
        (note?.toLowerCase().contains('#godmode') ?? false);
    final finalNoteText = isGodModeTrigger
        ? '⚡ Reward Unlocked: #godmode • Sovereign Access Granted'
        : (note?.trim() ?? '');

    final resolvedCategory =
        _activeCategory != 'All' && _activeCategory.trim().isNotEmpty
        ? _activeCategory.trim()
        : null;

    final entry = Moment(
      id: _nextId,
      timestamp: effectiveNow.millisecondsSinceEpoch,
      type: type,
      date: dateKey(effectiveNow),
      note: finalNoteText,
      category: resolvedCategory,
      tags: tags ?? const [],
    );

    _hasTappedBefore = true;
    unawaited(_prefs?.setBool('notekar.has_tapped_before', true));

    // Optimistic UI Update
    setState(() {
      _entries = [entry, ..._entries];
      _nextId++;
      _lastId = entry.id;
      _lastDeletedPreview = null;
      _lastTapTime = effectiveNow.millisecondsSinceEpoch;
      _lastTapPosition = position;
      _lastSavedType = type;
      _lastSingleCount = singleCount;
      _rippleToken++;
      _savedPulseToken++;
    });

    NotekarHaptics.save(_hapticStyle, type);
    if (_acousticFeedback) {
      AppSound.click();
    }

    try {
      if (_mode == 'two-way' || type == 'in' || type == 'out') {
        if (_sessionStart != null) {
          await _saveSetting('m-ses', _sessionStart!);
        } else {
          await _prefs?.remove('m-ses');
        }
        await _saveSetting('m-inout', _inout);
      }
      await _repository.saveMoment(entry);
      if (_prefs?.getBool('reminder_inactivity_enabled') ?? false) {
        final intervalMinutes =
            _prefs?.getInt('reminder_inactivity_interval_mins') ?? 240;
        unawaited(
          _fileChannel.invokeMethod('scheduleReminder', {
            'id': 'reminder_inactivity',
            'type': 'inactivity',
            'intervalMinutes': intervalMinutes,
            'title': reminderTitle,
            'body': reminderBody,
          }),
        );
      }
      unawaited(_updateAndroidWidget());
      _updateDynamicShortcuts();
      _showUndo();

      if (isGodModeTrigger) {
        await _prefs?.setBool('god_mode_unlocked', true);
        if (mounted) {
          showGodModeUnlockCelebrationDialog(
            context: context,
            p: p,
            onOpenGodMode: () {
              _openSettings(initialCategory: 'God Mode');
            },
          );
        }
      }

      if (_enableSobrietyMode && (note?.contains('#relapse') ?? false)) {
        if (_streakShields > 0) {
          HapticFeedback.heavyImpact();
          await Future<void>.delayed(const Duration(milliseconds: 120));
          HapticFeedback.heavyImpact();
          _showToast('🛡️ Streak Shield Deployed! Clean streak protected.');
          final newShields = math.max(0, _streakShields - 1);
          await _prefs?.setInt('streak_shields', newShields);
          if (mounted) setState(() => _streakShields = newShields);
        }
      }

      if (_mode == 'two-way' && type == 'out') {
        Future.delayed(const Duration(milliseconds: 320), () {
          if (mounted) {
            _openNoteForLastCapture();
          }
        });
      }
    } catch (e, stack) {
      _logger.error('Failed to log entry', e, stack);
      // Rollback
      if (mounted) {
        setState(() {
          _entries.removeWhere((m) => m.id == entry.id);
          _nextId--;
          _lastId = null;
          _inout = oldInOut;
          _sessionStart = oldSessionStart;
        });
        _showToast('Storage error: Moment not saved', warning: true);
      }
    } finally {
      _isSaving = false;
    }
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
    if (_headerExpanded) {
      setState(() => _headerExpanded = false);
      return;
    }
    if (_isDelayBlocked()) return;
    if (_enableNoteOnClick) {
      unawaited(_openNote(position: details.globalPosition));
    } else {
      unawaited(_logEntry(position: details.globalPosition));
    }
  }

  Widget _buildMinimalToolbarCapsule(Palette palette, double bottomInset) {
    final isSessionActive =
        _mode == 'two-way' && (_sessionStart != null || _inout == 'out');
    return HomeMinimalToolbarCapsule(
      palette: palette,
      mode: _mode,
      enableTranslucency: _enableTranslucency,
      onToggleMode: _toggleMode,
      onOpenHistory: _openHistory,
      onOpenSettings: _openSettings,
      isSessionActive: isSessionActive,
      isPaused: _isPaused,
      onTogglePause: _togglePauseResumeSession,
    );
  }

  void _setMode(String targetMode) {
    if (_mode == targetMode) return;
    setState(() {
      _mode = targetMode;
    });
    _saveSetting('m-mode', _mode);
    NotekarHaptics.selection(_hapticStyle);
    _showToast(
      _mode == 'two-way' ? 'Two-Way Mode' : 'Single Mode',
      withHaptic: false,
    );
    unawaited(_updateAndroidWidget());
    _updateDynamicShortcuts();
  }

  void _toggleMode() {
    _setMode(_mode == 'two-way' ? 'single' : 'two-way');
  }

  void _showToast(String text, {bool warning = false, bool withHaptic = true}) {
    if (withHaptic) {
      if (warning) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
    }
    showIosPillToast(
      context: context,
      p: p,
      message: text.localized(context),
      icon: warning ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
    );
  }

  Future<void> _setActiveCategory(String category) async {
    setState(() {
      _activeCategory = category;
    });
    _applySystemUiStyle();
    await _categoryService.setActiveCategory(category, prefs: _prefs);
    if (category != 'All') {
      _showToast('$category Mode', withHaptic: false);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();
    Color selectedColor = CategoryService.appleHigColors[0];

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: p.name == 'light' ? Brightness.light : Brightness.dark,
          primaryColor: p.accent,
        ),
        child: StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return CupertinoAlertDialog(
              title: Text('New Mode / Category'.localized(ctx)),
              content: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoTextField(
                      controller: textController,
                      autofocus: true,
                      placeholder: 'Category Name (e.g. Study, Gym)',
                      placeholderStyle: TextStyle(color: p.text3),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 15,
                      inputFormatters: [LengthLimitingTextInputFormatter(15)],
                      style: TextStyle(color: p.text),
                      decoration: BoxDecoration(
                        color: p.name == 'light'
                            ? const Color(0xFFE5E5EA)
                            : (p.name == 'amoled'
                                  ? const Color(0xFF161616)
                                  : p.surface3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final col in CategoryService.appleHigColors) ...[
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setDialogState(() => selectedColor = col);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: col,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor == col
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: selectedColor == col
                                      ? [
                                          BoxShadow(
                                            color: col.withValues(alpha: 0.5),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: selectedColor == col
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Cancel'.localized(ctx)),
                  onPressed: () => Navigator.pop(ctx, false),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Create'.localized(ctx)),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (created == true) {
      final name = textController.text.trim();
      if (name.isNotEmpty) {
        final success = await _categoryService.addCategory(
          name,
          color: selectedColor,
          prefs: _prefs,
        );
        if (success) {
          final updated = await _categoryService.getCategories(prefs: _prefs);
          setState(() {
            _categories = updated;
          });
          await _setActiveCategory(name);
          _showToast('$name added');
        }
      }
    }
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
    _updateDynamicShortcuts();
  }

  Future<void> _openNoteForLastCapture() async {
    final id = _lastId;
    if (id == null) return;
    final entry = _entries.where((item) => item.id == id).firstOrNull;
    if (entry == null) return;

    String initialNote = entry.note;
    Moment? matchingIn;
    if (_mode == 'two-way' && entry.type == 'out') {
      matchingIn = _entries
          .where(
            (item) => item.type == 'in' && item.timestamp <= entry.timestamp,
          )
          .firstOrNull;
      if (initialNote.isEmpty && matchingIn != null) {
        initialNote = matchingIn.note;
      }
    }

    NotekarHaptics.light(_hapticStyle);
    final result = await showGeneralDialog<NoteResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close note',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => NoteDialog(
        p: p,
        initialNote: initialNote,
        title: initialNote.isNotEmpty ? 'Edit Note' : 'Add Note',
        blur:
            _enableTranslucency &&
            AdaptiveEngine().supportsBlur &&
            !_reduceMotion,
        largeText: _largeText,
      ),
    );

    if (result != null) {
      await _updateMomentNote(entry.id, result.note, result.tags);
      if (matchingIn != null) {
        await _updateMomentNote(matchingIn.id, result.note, result.tags);
      }
      _showToast(initialNote.isNotEmpty ? 'Note updated' : 'Note added');
    }
  }

  Future<void> _deleteEntry(int id) async {
    final entry = _entries.where((item) => item.id == id).firstOrNull;
    if (entry == null) return;
    setState(() {
      _entries = _entries.where((item) => item.id != id).toList();
      _lastDeletedPreview = null;
      if (_lastId == id) _lastId = null;
    });
    await _deleteStoredEntry(id);
    unawaited(_updateAndroidWidget());
  }

  Future<void> _restoreEntry(Moment entry) async {
    if (_entries.any((item) => item.id == entry.id)) return;
    setState(() {
      _entries = [entry, ..._entries]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _lastDeletedPreview = null;
      if (_nextId <= entry.id) _nextId = entry.id + 1;
      if (_mode == 'two-way' && _entries.first.id == entry.id) {
        if (entry.type == 'out') {
          _inout = 'in';
          _sessionStart = null;
        } else if (entry.type == 'in') {
          _inout = 'out';
          _sessionStart = entry.timestamp;
        }
      }
    });
    if (_mode == 'two-way' && _entries.first.id == entry.id) {
      if (_sessionStart == null) {
        await _prefs?.remove('m-ses');
      } else {
        await _saveSetting('m-ses', _sessionStart!);
      }
      await _saveSetting('m-inout', _inout);
    }
    await _saveEntry(entry);
    unawaited(_updateAndroidWidget());
  }

  Future<void> _updateMomentNote(
    int id,
    String note, [
    List<String>? tags,
  ]) async {
    final index = _entries.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final oldMoment = _entries[index];
    final effectiveTags =
        tags ??
        NoteTagExtractor.extractHashtags(
          note,
        ).map((t) => t.replaceFirst('#', '').toLowerCase()).toList();

    final updatedMoment = oldMoment.copyWith(
      note: note.trim(),
      tags: effectiveTags,
    );

    setState(() {
      final updatedEntries = List<Moment>.from(_entries);
      updatedEntries[index] = updatedMoment;
      _entries = updatedEntries;
    });

    await _saveEntry(updatedMoment);
  }

  Future<void> _updateAndroidWidget() async {
    final now = DateTime.now();
    final today = dateKey(now);

    final todayCount = _entries.where((entry) => entry.date == today).length;

    final latest = _entries.isEmpty ? null : _entries.first;

    // Serialize last 10 moments for widget history stack
    final historyList = _entries.take(10).map((e) {
      final cleanNote = e.note
          .replaceAll('\r', '')
          .replaceAll('\n', ' ')
          .replaceAll('|', '—')
          .trim();
      return '${e.timestamp}|${e.type}|$cleanNote';
    }).toList();

    final duration = _getSobrietyDuration();
    final streakDays = _formatSobrietyStreak(duration);
    final milestoneInfo = _getMilestoneInfo(duration);
    final nextMilestone = (milestoneInfo['nextLabel'] ?? '') as String;
    final remaining = (milestoneInfo['remaining'] ?? '') as String;
    final streakMilestone = nextMilestone.isNotEmpty
        ? '$nextMilestone ($remaining)'
        : 'All Achieved!';

    final latestRelapse = _getLatestRelapseTime();
    final lastRelapseTime = latestRelapse != null
        ? timeOnly(latestRelapse.millisecondsSinceEpoch)
        : '';

    final todayAudit = LifeAuditService.calculate(
      entries: _entries,
      timeframe: LifeAuditTimeframe.today,
    );

    try {
      await _fileChannel.invokeMethod<void>('updateWidgetState', {
        'todayCount': todayCount,
        'mode': _mode,
        'nextAction': _mode == 'two-way' ? _inout : 'single',
        'lastType': latest?.type ?? '',
        'lastTimestamp': latest?.timestamp ?? 0,
        'hasMoments': latest != null,
        'historyList': historyList,
        'sobrietyEnabled': _enableSobrietyMode,
        'streakDays': streakDays,
        'streakMilestone': streakMilestone,
        'lastRelapseTime': lastRelapseTime,
        'activeCategory': _activeCategory,
        'isPaused': _isPaused,
        'pausedAt': _pausedAt ?? 0,
        'focusRatio': todayAudit.intentionalityRatio.round().clamp(0, 100),
        'totalTracked': todayAudit.formattedTotalTracked,
        'totalWasted': todayAudit.formattedTotalWasted,
      });
    } catch (_) {
      // Widget updates must never affect logging.
    }
  }

  Future<void> _syncBackgroundLogs(SharedPreferences prefs) async {
    await prefs.reload();
    final pendingCount = prefs.getInt('pending_count') ?? 0;
    if (pendingCount <= 0) return;

    _logger.info('Syncing $pendingCount background logs from native widget...');

    final List<Moment> newEntries = [];
    int nextId = _repository.getNextId();

    for (int i = 0; i < pendingCount; i++) {
      final logStr = prefs.getString('log_$i');
      if (logStr != null && logStr.contains('|')) {
        final parts = logStr.split('|');
        if (parts.length >= 2) {
          final timestamp =
              int.tryParse(parts[0]) ?? DateTime.now().millisecondsSinceEpoch;
          final type = parts[1]; // 'in', 'out', or 'single'
          final note = parts.length > 2 ? parts[2] : '';

          final entry = Moment(
            id: nextId++,
            timestamp: timestamp,
            date: dateKey(DateTime.fromMillisecondsSinceEpoch(timestamp)),
            type: type,
            note: note,
          );
          newEntries.add(entry);
        }
      }
    }

    // Save all new entries to repository
    for (final entry in newEntries) {
      await _repository.saveMoment(entry);
      if (_mode == 'two-way') {
        if (entry.type == 'in') {
          _inout = 'out';
          _sessionStart = entry.timestamp;
          _isPaused = false;
          _pausedAt = null;
          await prefs.setString('m-inout', 'out');
          await prefs.setInt('m-ses', entry.timestamp);
          await prefs.setBool('m-paused', false);
          await prefs.remove('m-paused-at');
        } else if (entry.type == 'out') {
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
    }

    // Clear SharedPreferences queue keys
    for (int i = 0; i < pendingCount; i++) {
      await prefs.remove('log_$i');
    }
    await prefs.remove('pending_count');

    // Reload the full list from Hive to refresh states
    final updatedEntries = _repository.getAllMoments();
    if (mounted) {
      setState(() {
        _entries = updatedEntries;
        _nextId = nextId;
      });
    }

    // Update native widget UI
    unawaited(_updateAndroidWidget());
    _updateDynamicShortcuts();
  }

  Future<void> _startGoalSession({
    required String? category,
    String mode = 'two-way',
  }) async {
    if (category != null && category.isNotEmpty) {
      await _setActiveCategory(category);
    }
    if (_mode != mode) {
      setState(() => _mode = mode);
      await _saveSetting('m-mode', mode);
    }
    if (_mode == 'two-way') {
      if (_inout == 'out') {
        _showToast('Switched to ${category ?? 'Goal'} session');
      } else {
        await _logEntry(forcedType: 'in');
        _showToast('Started ${category ?? 'Goal'} session');
      }
    } else {
      await _logEntry(forcedType: 'single');
      _showToast('Moment logged for ${category ?? 'Goal'}');
    }
    _cachedGoals = await GoalsService.instance.getGoals();
    if (mounted) setState(() {});
  }

  Future<void> _stopGoalSession() async {
    if (_mode == 'two-way' && (_sessionStart != null || _inout == 'out')) {
      await _logEntry(forcedType: 'out');
    }
  }

  Future<void> _togglePauseResumeSession() async {
    if (_mode != 'two-way' || _sessionStart == null || _inout != 'out') return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    if (!_isPaused) {
      setState(() {
        _isPaused = true;
        _pausedAt = nowMs;
      });
      await _saveSetting('m-paused', true);
      await _saveSetting('m-paused-at', nowMs);
      NotekarHaptics.selection(_hapticStyle);
      _showToast('Session paused');
    } else {
      final pausedTurnMs = _pausedAt != null ? (nowMs - _pausedAt!) : 0;
      final newStart = (_sessionStart ?? nowMs) + pausedTurnMs;
      setState(() {
        _isPaused = false;
        _pausedAt = null;
        _sessionStart = newStart;
      });
      await _saveSetting('m-paused', false);
      await _prefs?.remove('m-paused-at');
      await _saveSetting('m-ses', newStart);

      final inMoment = _entries.where((e) => e.type == 'in').firstOrNull;
      if (inMoment != null) {
        final updatedIn = inMoment.copyWith(timestamp: newStart);
        await _repository.saveMoment(updatedIn);
      }

      NotekarHaptics.light(_hapticStyle);
    }
    _updateDynamicShortcuts();
    unawaited(_updateAndroidWidget());
  }

  Future<void> _toggleFloatingTimer(bool enabled) async {
    if (enabled) {
      final canDraw =
          await _fileChannel.invokeMethod<bool>('canDrawOverlays') ?? false;
      if (!canDraw) {
        await _fileChannel.invokeMethod<void>('requestOverlayPermission');
        if (!mounted) return;
        _showToast(
          'Grant "Display over other apps" permission to show floating timer'
              .localized(context),
          warning: true,
        );
        return;
      }
      await _fileChannel.invokeMethod<void>('startFloatingTimer');
    } else {
      await _fileChannel.invokeMethod<void>('stopFloatingTimer');
    }
    if (!mounted) return;
    setState(() => _floatingTimerEnabled = enabled);
    await _saveSetting('floating_timer_enabled', enabled);
    if (!mounted) return;
    final isActive = _mode == 'two-way' && _sessionStart != null;
    final message = enabled
        ? (isActive
              ? 'Floating Timer enabled'
              : 'Floating Timer enabled (will show during active session)')
        : 'Floating Timer disabled';
    _showToast(message.localized(context));
  }

  Future<String?> _showModeSelectorSheet() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      builder: (ctx) => AppSheet(
        p: p,
        title: 'Select Mode'.localized(ctx),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final cat in _categories) ...[
                    PressableScale(
                      onTap: () => Navigator.pop(ctx, cat),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cat == _activeCategory
                              ? p.accent.withValues(alpha: 0.12)
                              : p.surface3,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cat == _activeCategory
                                ? p.accent.withValues(alpha: 0.4)
                                : p.border.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: getCategoryMeta(cat, p).color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (cat == _activeCategory)
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: p.accent,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openNote({
    Offset? position,
    String? initialText,
    String? hintText,
    String? title,
    String? forcedType,
  }) async {
    if (!_startupComplete) {
      _showToast('Loading database...', warning: true);
      return;
    }
    if (_isDelayBlocked()) return;

    if (_mode == 'two-way' && _inout != 'out' && forcedType == null) {
      final selectedCat = await _showModeSelectorSheet();
      if (selectedCat == null) return;
      await _setActiveCategory(selectedCat);
      forcedType = 'in';
    }

    if (!mounted) return;
    NotekarHaptics.light(_hapticStyle);
    final result = await showGeneralDialog<NoteResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close note',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => NoteDialog(
        p: p,
        initialNote: initialText ?? '',
        title: title ?? 'Add Note',
        hintText: hintText,
        blur:
            _enableTranslucency &&
            AdaptiveEngine().supportsBlur &&
            !_reduceMotion,
        largeText: _largeText,
      ),
    );
    if (result != null) {
      unawaited(
        _logEntry(
          forcedType: forcedType,
          note: result.note.isEmpty ? null : result.note,
          tags: result.tags,
          position: position,
        ),
      );
    }
  }

  void _collapseHeaderIfExpanded() {
    if (_headerExpanded) {
      setState(() => _headerExpanded = false);
    }
  }

  Duration _computeTodayTrackedDuration() {
    final now = DateTime.now();
    final todayKey = dateKey(now);
    final todayMoments = _entries.where((m) => m.date == todayKey).toList();
    final sections = buildTimelineDaySections(todayMoments);
    var dur = sections.isNotEmpty
        ? sections.first.totalTrackedDuration
        : Duration.zero;
    if (_mode == 'two-way' && _sessionStart != null) {
      final elapsed = now.millisecondsSinceEpoch - _sessionStart!;
      if (elapsed > 0) dur += Duration(milliseconds: elapsed);
    }
    return dur;
  }

  int _computeTodayMomentsCount() {
    final todayKey = dateKey(DateTime.now());
    return _entries.where((m) => m.date == todayKey).length;
  }

  Future<void> _openIntelligenceHub() async {
    _collapseHeaderIfExpanded();
    if (!_startupComplete) {
      _showToast('Loading database...', warning: true);
      return;
    }
    await Navigator.of(context).push(ExecutiveIntelligenceHubScreen.route());
  }

  void _showCorruptionNotificationDialog(bool recoveredFromSnapshot) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext ctx) => CupertinoAlertDialog(
        title: const Text('Database Safety Notice'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            recoveredFromSnapshot
                ? 'A database storage anomaly was safely isolated. NoteKar automatically restored your moments from the rolling snapshot!'
                : 'A database anomaly was safely isolated. The corrupted files were preserved in corrupted_backups/ on disk to prevent data loss.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openHistory() async {
    _collapseHeaderIfExpanded();
    if (!_startupComplete) {
      _showToast('Loading database...', warning: true);
      return;
    }
    final result = await showModalBottomSheet<dynamic>(
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
      builder: (sheetContext) => HistoryDialog(
        p: p,
        entries: _entries,
        compactRows: _historyDensity == 'compact',
        largeText: _largeText,
        minimalMomentOptions: _minimalMomentOptions,
        useNumbersInSingle: _useNumbersInSingle,
        resetSingleDaily: _resetSingleDaily,
        activeCategory: _activeCategory,
        isSessionRunning: _mode == 'two-way' && _sessionStart != null,
        onStopSession: () {
          Navigator.pop(sheetContext, {'action': 'stop_goal_session'});
        },
        blur:
            _enableTranslucency &&
            AdaptiveEngine().supportsBlur &&
            !_reduceMotion,
        onDelete: _deleteEntry,
        onRestore: _restoreEntry,
        onUpdateNote: _updateMomentNote,
        onUpdateNoteWithTags: _updateMomentNote,
        confirmDelete: _confirmDelete,
        onDuration: _showDuration,
        onOpenTrash: _showRecentlyDeleted,
        onClearAll: _clearStoredEntries,
        onOpenSearchNotes: () {
          Navigator.pop(sheetContext, 'search_notes');
        },
        onOpenManualEntry: ({prefilledStartTime, prefilledEndTime}) {
          Navigator.pop(sheetContext, {
            'action': 'manual_entry',
            'start': prefilledStartTime,
            'end': prefilledEndTime,
          });
        },
        onClaimRest: _claimRestGap,
        onEndLiveSession: (inMomentId, outEntry) async {
          await _restoreEntry(outEntry);
          if (_sessionStart != null) {
            setState(() {
              _inout = 'in';
              _sessionStart = null;
            });
            await _prefs?.remove('m-ses');
            await _saveSetting('m-inout', 'in');
          }
          unawaited(_updateAndroidWidget());
        },
        onRestoreLiveSession: (inMoment) async {
          setState(() {
            _inout = 'out';
            _sessionStart = inMoment.timestamp;
          });
          await _saveSetting('m-ses', _sessionStart!);
          await _saveSetting('m-inout', 'out');
          unawaited(_updateAndroidWidget());
        },
      ),
    );
    if (result == 'search_notes' && mounted) {
      await _openSettings(initialCategory: 'Search Notes');
    } else if (result == 'manual_entry' && mounted) {
      await _openManualEntry();
    } else if (result is Map && result['action'] == 'manual_entry' && mounted) {
      await _openManualEntry(
        prefilledStartTime: result['start'] as DateTime?,
        prefilledEndTime: result['end'] as DateTime?,
      );
    } else if (result is Map &&
        result['action'] == 'start_goal_session' &&
        mounted) {
      final targetCat = result['category'] as String?;
      final targetMode = result['mode'] as String? ?? 'two-way';
      await _startGoalSession(category: targetCat, mode: targetMode);
    } else if (result is Map &&
        result['action'] == 'stop_goal_session' &&
        mounted) {
      await _stopGoalSession();
    } else if (result is Map &&
        result['action'] == 'manual_entry_goal' &&
        mounted) {
      final goal = result['goal'] as Goal?;
      await _openManualEntry(
        initialGoal: goal,
        initialCategory: goal?.category,
      );
    }
    _cachedGoals = await GoalsService.instance.getGoals();
    if (mounted) setState(() {});
  }

  Future<void> _openManualEntry({
    DateTime? prefilledStartTime,
    DateTime? prefilledEndTime,
    Goal? initialGoal,
    String? initialCategory,
  }) async {
    if (!_startupComplete) {
      _showToast('Loading database...', warning: true);
      return;
    }
    final result = await showModalBottomSheet<ManualEntryResult>(
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
      builder: (ctx) => ManualEntryDialog(
        p: p,
        categories: _categories,
        initialCategory:
            initialCategory ?? initialGoal?.category ?? _activeCategory,
        initialGoal: initialGoal,
        prefilledStartTime: prefilledStartTime,
        prefilledEndTime: prefilledEndTime,
      ),
    );

    if (result == null || !mounted) return;

    if (result.isSession && result.endDateTime != null) {
      final startMs = result.startDateTime.millisecondsSinceEpoch;
      var endMs = result.endDateTime!.millisecondsSinceEpoch;
      if (endMs <= startMs) {
        endMs = startMs + 60000;
      }
      final endDt = DateTime.fromMillisecondsSinceEpoch(endMs);

      // Create IN and OUT moments for the session
      final inMoment = Moment(
        id: _nextId,
        timestamp: startMs,
        type: 'in',
        date: dateKey(result.startDateTime),
        note: result.note,
        tags: result.tags,
        category: result.category,
      );
      final outMoment = Moment(
        id: _nextId + 1,
        timestamp: endMs,
        type: 'out',
        date: dateKey(endDt),
        note: '',
        tags: const [],
        category: result.category,
      );

      _nextId += 2;
      await _repository.saveMoment(inMoment);
      await _repository.saveMoment(outMoment);

      setState(() {
        _entries = [outMoment, inMoment, ..._entries]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
      _showToast('Session logged manually');
    } else {
      // Single moment
      final moment = Moment(
        id: _nextId,
        timestamp: result.startDateTime.millisecondsSinceEpoch,
        type: 'single',
        date: dateKey(result.startDateTime),
        note: result.note,
        tags: result.tags,
        category: result.category,
      );
      _nextId++;
      await _repository.saveMoment(moment);

      setState(() {
        _entries = [moment, ..._entries]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
      _showToast('Moment logged manually');
    }

    _cachedGoals = await GoalsService.instance.getGoals();
    if (mounted) setState(() {});
    unawaited(_updateAndroidWidget());
  }

  Future<void> _claimRestGap(DateTime start, DateTime end) async {
    final startMoment = Moment(
      id: _nextId++,
      timestamp: start.millisecondsSinceEpoch,
      type: 'in',
      date: dateKey(start),
      note: 'Rest & Recovery',
      category: 'Rest',
      tags: const ['rest'],
    );
    final endMoment = Moment(
      id: _nextId++,
      timestamp: end.millisecondsSinceEpoch,
      type: 'out',
      date: dateKey(end),
      note: 'Rest & Recovery',
      category: 'Rest',
      tags: const ['rest'],
    );
    setState(() {
      _entries = [endMoment, startMoment, ..._entries]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _lastId = endMoment.id;
    });
    await _repository.saveMoment(startMoment);
    await _repository.saveMoment(endMoment);
    unawaited(_updateAndroidWidget());
    if (mounted) {
      _showToast('🌿 Rest & Recovery logged');
    }
  }

  Future<void> _evaluateStreakGuardian(List<Moment> moments) async {
    try {
      final status = await StreakGuardianService().evaluateStreak(moments);
      if (status.graceAppliedToday && mounted) {
        _showToast('🌿 Mindful rest day honored • Streak protected');
      }
    } catch (e) {
      _logger.warn('StreakGuardian check skipped: $e');
    }
  }

  Future<void> _showRecentlyDeleted() async {
    final p = paletteFor(
      _theme,
      highContrast: _highContrast,
      accentName: _accentColor,
    );
    final trashEntries = _repository.getTrashMoments();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => RecentlyDeletedDialog(
        p: p,
        trashEntries: trashEntries,
        blur:
            _enableTranslucency &&
            AdaptiveEngine().supportsBlur &&
            !_reduceMotion,
        onRestoreMoment: (id) async {
          await _repository.restoreTrashMoment(id);
          setState(() {
            _entries = _repository.getAllMoments();
          });
        },
        onRestoreAll: () async {
          await _repository.restoreAllTrash();
          setState(() {
            _entries = _repository.getAllMoments();
          });
        },
        onDeletePermanent: (id) async {
          await _repository.permanentlyDeleteTrashMoment(id);
        },
        onClearTrash: () async {
          await _repository.clearTrash();
        },
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openUrgeSurfing() async {
    showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Urge Surfing',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, _, _) => UrgeSurfingDialog(p: p),
    );
  }

  Future<void> _openSettings({String? initialCategory}) async {
    if (!_startupComplete) {
      _showToast('Loading database...', warning: true);
      return;
    }
    final trash = _repository.getTrashMoments();
    _trashNotifier.value = trash;
    final lastDeletedPreview = trash.isNotEmpty
        ? 'Last deleted: ${timeOnly(trash.first.timestamp)}${trash.first.note.isNotEmpty ? ' - ${trash.first.note}' : ''}'
        : 'No moments deleted';

    final result = await showModalBottomSheet<dynamic>(
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
        initialCategory: initialCategory,
        activeCategory: _activeCategory,
        isSessionRunning: _mode == 'two-way' && _sessionStart != null,
        floatingTimerEnabled: _floatingTimerEnabled,
        onFloatingTimerChanged: _toggleFloatingTimer,
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

        confirmDelete: _confirmDelete,
        soundEffects: _acousticFeedback,
        showSeconds: _showSeconds,
        highlightSeconds: _highlightSeconds,
        use24Hour: _use24HourFormat,
        clockFont: _clockFont,
        onClockFontChanged: (value) {
          setState(() => _clockFont = value);
          _saveSetting('m-clock-font', value);
        },
        buttonLabels: _buttonLabels,
        largeControls: _largeControls,
        homeMenuPill: _homeMenuPill,
        homeMenuAnimations: _homeMenuAnimations,
        showHistoryText: _showHistoryText,
        showLastSavedHint: _showLastSavedHint,
        extendedDuration: _extendedDuration,
        enableTranslucency: _enableTranslucency,
        minimalMomentOptions: _minimalMomentOptions,
        useNumbersInSingle: _useNumbersInSingle,
        resetSingleDaily: _resetSingleDaily,
        countOnSave: _countOnSave,
        privacyLockDelayMinutes: _privacyLockDelayMinutes,
        isSystemLockAvailable: _systemLockAvailable,
        privacyLockType: _privacyLockType,
        onPrivacyLockTypeChanged: _setPrivacyLockType,
        updateStatus: _updateStatus,
        updateInfo: _latestUpdateInfo,
        checkingUpdates: _checkingUpdates,
        lastUpdateCheckedAt: _lastUpdateCheckedAt,
        entriesNotifier: _entriesNotifier,
        lastSavedAt: _entries.isEmpty
            ? null
            : _entries.map((entry) => entry.timestamp).reduce(math.max),
        blur:
            _enableTranslucency &&
            AdaptiveEngine().supportsBlur &&
            !_reduceMotion,
        lastDeletedPreview: lastDeletedPreview,
        trashEntriesNotifier: _trashNotifier,
        onTheme: (value) {
          NoteKarApp.of(context)?.setTheme(value);
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
          NoteKarApp.of(context)?.setAccent(value);
          setState(() => _accentColor = value);
          _saveSetting('m-accent-color', value);
        },
        onAdaptiveColorChanged: (value) {
          setState(() => _adaptiveModeColor = value);
          _saveSetting('m-adaptive-color', value);
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
        onSoundEffects: (value) {
          setState(() => _acousticFeedback = value);
          _saveSetting('m-acoustic-feedback', value);
          AppSound.setEnabled(value);
        },
        onHistoryDensity: (value) {
          setState(() {
            _historyDensity = value;
          });
          _saveSetting('m-history-density', value);
        },
        onPrivacyLock: _setPrivacyLock,
        onResetPrivacyPin: _resetPrivacyPin,
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
          NoteKarApp.of(context)?.setHighContrast(value);
          setState(() => _highContrast = value);
          _prefs?.setBool('m-high-contrast', value);
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
        onUse24Hour: (value) {
          setState(() => _use24HourFormat = value);
          setGlobalUse24Hour(value);
          _prefs?.setBool('m-use-24-hour', value);
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
        onMinimalMomentOptions: (value) {
          setState(() => _minimalMomentOptions = value);
          _prefs?.setBool('m-minimal-moment-options', value);
        },
        onUseNumbersInSingle: (value) {
          setState(() => _useNumbersInSingle = value);
          _prefs?.setBool('m-use-numbers-in-single', value);
        },
        onResetSingleDaily: (value) {
          setState(() => _resetSingleDaily = value);
          _prefs?.setBool('m-reset-single-daily', value);
        },
        onCountOnSave: (value) {
          setState(() => _countOnSave = value);
          _prefs?.setBool('m-count-on-save', value);
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
        onRestoreBackupFromString: _restoreBackupFromString,
        onSaveQuickBackup: _createQuickLocalBackup,
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
            largeText: _largeText,
            blur:
                _enableTranslucency &&
                AdaptiveEngine().supportsBlur &&
                !_reduceMotion,
          ),
        ),
        onReset: _resetAll,
        onFactoryReset: _factoryReset,
        onResetSettings: _resetSettingsOnly,
        onRestoreSettings: _restoreSettings,
        onFeedback: _showToast,
        onOpenTrash: _showRecentlyDeleted,
        onRestoreTrashMoment: (id) async {
          await _repository.restoreTrashMoment(id);
          setState(() {
            _entries = _repository.getAllMoments();
          });
        },
        onRestoreAllTrash: () async {
          await _repository.restoreAllTrash();
          setState(() {
            _entries = _repository.getAllMoments();
          });
        },
        onDeleteTrashPermanent: (id) async {
          await _repository.permanentlyDeleteTrashMoment(id);
        },
        onClearTrash: () async {
          await _repository.clearTrash();
        },
        currentLocale: _locale,
        onLocaleChanged: (value) {
          NoteKarApp.of(context)?.setLocale(value);
          setState(() => _locale = value);
        },
        onSobrietyModeChanged: (value) {
          setState(() => _enableSobrietyMode = value);
        },
        onTriggerUrlScheme: _handleIncomingUrlScheme,
      ),
    );

    if (mounted) {
      final refreshedCats = await _categoryService.getCategories(prefs: _prefs);
      setState(() {
        _categories = refreshedCats;
        _enableNoteOnClick = _prefs?.getBool('enable_note_on_click') ?? false;
        _enableSobrietyMode = _prefs?.getBool('enable_sobriety_mode') ?? false;
        _sobrietyResetType = _prefs?.getString('sobriety_reset_type') ?? 'any';
        final customStartMs = _prefs?.getInt('sobriety_custom_start_ms');
        _sobrietyCustomStart = customStartMs != null
            ? DateTime.fromMillisecondsSinceEpoch(customStartMs)
            : null;
        _sobrietyMilestoneTheme =
            _prefs?.getString('sobriety_milestone_theme') ?? 'science';
      });
      unawaited(_updateAndroidWidget());
      unawaited(_updateStreakShields());
    }

    if (result == 'log') {
      Future.delayed(const Duration(milliseconds: 200), () {
        _logEntry();
      });
    } else if (result is Map &&
        result['action'] == 'start_goal_session' &&
        mounted) {
      final targetCat = result['category'] as String?;
      final targetMode = result['mode'] as String? ?? 'two-way';
      await _startGoalSession(category: targetCat, mode: targetMode);
    } else if (result is Map &&
        result['action'] == 'stop_goal_session' &&
        mounted) {
      await _stopGoalSession();
    } else if (result is Map &&
        result['action'] == 'manual_entry_goal' &&
        mounted) {
      final goal = result['goal'] as Goal?;
      await _openManualEntry(
        initialGoal: goal,
        initialCategory: goal?.category,
      );
    }
    _cachedGoals = await GoalsService.instance.getGoals();
    if (mounted) setState(() {});
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
        largeText: _largeText,
        blur:
            _enableTranslucency &&
            AdaptiveEngine().supportsBlur &&
            !_reduceMotion,
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
        largeText: _largeText,
        blur:
            _enableTranslucency &&
            AdaptiveEngine().supportsBlur &&
            !_reduceMotion,
      ),
    );
  }

  Future<void> _handlePendingLaunchAction() async {
    Map<dynamic, dynamic>? payload;
    String? action;
    try {
      final rawPayload = await _fileChannel.invokeMethod<dynamic>(
        'getLaunchPayload',
      );
      if (rawPayload is Map) {
        payload = rawPayload;
        action = payload['action']?.toString();
      } else {
        action = await _fileChannel.invokeMethod<String>('getLaunchAction');
      }
    } catch (e, stack) {
      _logger.warn('Failed to get launch action/payload', e, stack);
      return;
    }
    if (!mounted || action == null || action.trim().isEmpty) return;
    if (_privacyLock && !_privacyUnlocked) {
      final unlocked = await _unlockPrivacyLock();
      if (!unlocked) return;
    }

    final note = (payload?['note'] as String?)?.trim() ?? '';
    final typeParam = (payload?['type'] as String?)?.trim().toLowerCase();
    final pageParam = (payload?['page'] as String?)?.trim().toLowerCase();

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
        await _openNote(initialText: note.isNotEmpty ? note : null);
      case 'log_with_note':
        await _openNote(
          forcedType: 'single',
          title: 'What happened?',
          hintText: 'What happened?',
          initialText: note.isNotEmpty ? note : null,
        );
      case 'share':
        await _openNote(initialText: note.isNotEmpty ? note : null);
      case 'moment':
      case 'single':
        if (!_isDelayBlocked()) {
          unawaited(
            _logEntry(
              forcedType: 'single',
              note: note.isNotEmpty ? note : null,
            ),
          );
        }
      case 'log':
        if (!_isDelayBlocked()) {
          final targetType = typeParam ?? 'single';
          if (targetType == 'in' || targetType == 'out') {
            setState(() {
              _mode = 'two-way';
              _inout = targetType;
            });
          }
          unawaited(
            _logEntry(
              forcedType: targetType,
              note: note.isNotEmpty ? note : null,
            ),
          );
        }
      case 'in':
        if (!_isDelayBlocked()) {
          setState(() {
            _mode = 'two-way';
            _inout = 'in';
          });
          unawaited(
            _logEntry(forcedType: 'in', note: note.isNotEmpty ? note : null),
          );
        }
      case 'out':
        if (!_isDelayBlocked()) {
          setState(() {
            _mode = 'two-way';
            _inout = 'out';
          });
          unawaited(
            _logEntry(forcedType: 'out', note: note.isNotEmpty ? note : null),
          );
        }
      case 'open':
        if (pageParam == 'history') {
          await _openHistory();
        } else if (pageParam == 'settings') {
          await _openSettings();
        } else if (pageParam == 'stats') {
          await _openSettings(initialCategory: 'Stats');
        } else if (pageParam == 'sobriety') {
          await _openSettings(initialCategory: 'Sobriety Tracker');
        } else if (pageParam == 'life-audit' ||
            pageParam == 'lifeaudit' ||
            pageParam == 'audit') {
          await _openSettings(initialCategory: 'Life Audit');
        } else if (pageParam == 'integrations') {
          await _openSettings(initialCategory: 'Integrations & Automation');
        }
      case 'sobriety':
        await _openSettings(initialCategory: 'Sobriety Tracker');
      case 'life-audit':
      case 'lifeaudit':
      case 'audit':
        await _openSettings(initialCategory: 'Life Audit');
      case 'reflection':
      case 'reflect':
        final isLocked =
            await _fileChannel.invokeMethod<bool>('isDeviceLocked') ?? false;
        await _showStandaloneMindfulness(isLocked: isLocked);
        if (isLocked) {
          await _fileChannel.invokeMethod<void>('closeLockscreenActivity');
        }
      case 'updates':
      case 'releases':
        await _openExternalLink(githubReleases);
    }
  }

  Future<void> _handleIncomingUrlScheme(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'notekar') return;
    final action = uri.host.isNotEmpty
        ? uri.host
        : uri.pathSegments.firstOrNull;
    if (action == null || action.isEmpty) return;
    final note =
        uri.queryParameters['note'] ??
        uri.queryParameters['text'] ??
        uri.queryParameters['msg'] ??
        '';
    final typeParam = uri.queryParameters['type']?.toLowerCase();
    final pageParam = uri.queryParameters['page']?.toLowerCase();

    switch (action.toLowerCase()) {
      case 'log':
        final type = typeParam == 'in'
            ? 'in'
            : (typeParam == 'out'
                  ? 'out'
                  : (typeParam == 'note' ? 'note' : 'single'));
        if (type == 'in' || type == 'out') {
          setState(() {
            _mode = 'two-way';
            _inout = type;
          });
        }
        unawaited(
          _logEntry(forcedType: type, note: note.isNotEmpty ? note : null),
        );
      case 'in':
        setState(() {
          _mode = 'two-way';
          _inout = 'in';
        });
        unawaited(
          _logEntry(forcedType: 'in', note: note.isNotEmpty ? note : null),
        );
      case 'out':
        setState(() {
          _mode = 'two-way';
          _inout = 'out';
        });
        unawaited(
          _logEntry(forcedType: 'out', note: note.isNotEmpty ? note : null),
        );
      case 'note':
        await _openNote(initialText: note.isNotEmpty ? note : null);
      case 'open':
        if (pageParam == 'history') {
          await _openHistory();
        } else if (pageParam == 'settings') {
          await _openSettings();
        } else if (pageParam == 'stats') {
          await _openSettings(initialCategory: 'Stats');
        } else if (pageParam == 'sobriety') {
          await _openSettings(initialCategory: 'Sobriety Tracker');
        } else if (pageParam == 'life-audit' ||
            pageParam == 'lifeaudit' ||
            pageParam == 'audit') {
          await _openSettings(initialCategory: 'Life Audit');
        } else if (pageParam == 'integrations') {
          await _openSettings(initialCategory: 'Integrations & Automation');
        }
      case 'sobriety':
        await _openSettings(initialCategory: 'Sobriety Tracker');
      case 'life-audit':
      case 'lifeaudit':
      case 'audit':
        await _openSettings(initialCategory: 'Life Audit');
      case 'reflect':
      case 'reflection':
        await _showStandaloneMindfulness();
      case 'history':
        await _openHistory();
      case 'settings':
        await _openSettings();
      case 'stats':
        await _openSettings(initialCategory: 'Stats');
      default:
        _showToast('URL Scheme triggered: $action');
    }
  }

  Future<void> _showStandaloneMindfulness({bool isLocked = false}) async {
    if (!mounted) return;
    final intervalMins =
        _prefs?.getInt('reminder_reflection_interval_mins') ?? 60;
    final message = _prefs?.getString('reminder_reflection_body') ?? '';
    final sound = _prefs?.getBool('reminder_reflection_sound') ?? true;

    await showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: !isLocked,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, _, _) => Scaffold(
        backgroundColor: Colors.black,
        body: TimeReflectionSheet(
          p: p,
          intervalMinutes: intervalMins,
          customMessage: message,
          playSound: sound,
          onLogMoment: () {
            if (!_isDelayBlocked()) unawaited(_logEntry());
          },
        ),
      ),
    );
  }

  Future<void> _openExternalLink(String url) async {
    if (!mounted) return;
    await openExternalLinkSafely(context, p: p, url: url);
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
    } catch (e, stack) {
      _logger.error('Failed to configure remote notices', e, stack);
      if (mounted) {
        _showToast(
          value ? 'Could not turn on app notices' : 'App notices off',
          warning: value,
        );
      }
      return;
    }
    if (mounted) {
      // Immediate visual feedback from the switch is enough.
    }
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
    } catch (e, stack) {
      _logger.warn('Failed to check remote notices on open', e, stack);
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

  Future<({String status, AppUpdateInfo? info})> _checkForUpdates() async {
    final started = DateTime.now();
    setState(() {
      _checkingUpdates = true;
      _updateStatus = 'Checking for updates...';
    });
    try {
      final trackBeta = _prefs?.getBool('m-update-track-beta') ?? false;
      final latest = await _updateService.fetchLatestVersion(
        trackBeta: trackBeta,
      );

      final elapsed = DateTime.now().difference(started);
      if (elapsed < const Duration(seconds: 5)) {
        await Future<void>.delayed(const Duration(seconds: 5) - elapsed);
      }

      if (latest == null) {
        final status = 'Could not check updates';
        _setUpdateStatus(status);
        return (status: status, info: null);
      }
      if (_updateService.isUpdateAvailable(latest.version, appVersion)) {
        final status = 'Update available: v${latest.version}';
        _lastUpdateCheckedAt = DateTime.now().millisecondsSinceEpoch;
        await _prefs?.setInt('m-last-update-check', _lastUpdateCheckedAt!);
        setState(() {
          _latestUpdateInfo = latest;
        });
        await _prefs?.setString(
          'm-latest-update-info',
          jsonEncode(latest.toJson()),
        );
        _setUpdateStatus(status);
        return (status: status, info: latest);
      } else if (mounted) {
        final status = 'You are up to date';
        _lastUpdateCheckedAt = DateTime.now().millisecondsSinceEpoch;
        await _prefs?.setInt('m-last-update-check', _lastUpdateCheckedAt!);
        setState(() {
          _latestUpdateInfo = null;
        });
        await _prefs?.remove('m-latest-update-info');
        _setUpdateStatus(status);
        _scheduleUpdateStatusReset();
        return (status: status, info: null);
      }
    } catch (_) {
      final status = 'Update check failed';
      _setUpdateStatus(status);
      return (status: status, info: null);
    } finally {
      if (mounted) setState(() => _checkingUpdates = false);
    }
    return (status: _updateStatus, info: _latestUpdateInfo);
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

  Future<void> _checkSystemLockAvailability() async {
    final available = await _canUsePrivacyLock();
    if (mounted) {
      setState(() {
        _systemLockAvailable = available;
        if (!available) {
          if (_privacyLock && _privacyLockType == 'system') {
            _privacyLock = false;
            _privacyUnlocked = false;
            unawaited(_prefs?.setBool('m-privacy-lock', false));
            _showToast(
              'App Lock disabled because device screen lock was removed.'
                  .localized(context),
              warning: true,
            );
          }
          _privacyLockType = 'custom_pin';
        }
      });
      _syncPrivacyOverlay();
    }
  }

  Future<bool> _showSetupCustomPinDialog() async {
    final pin = await showGeneralDialog<String>(
      context: context,
      barrierColor: Colors.black,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: p.bg,
          body: SafeArea(child: PinSetupWidget(p: p)),
        );
      },
    );
    if (pin == null || pin.length != 4) return false;

    await _prefs?.setString('m-custom-pin', _hashPin(pin));
    if (!mounted) return false;
    _showToast('In-App PIN set successfully.'.localized(context));
    return true;
  }

  Future<void> _resetPrivacyPin() async {
    await _showSetupCustomPinDialog();
  }

  Future<bool> _setPrivacyLockType(String type) async {
    if (type == 'system') {
      final oldType = _privacyLockType;
      _privacyLockType = 'system';
      final unlocked = await _unlockPrivacyLock();
      if (!unlocked) {
        _privacyLockType = oldType;
        return false;
      }
      setState(() {
        _privacyLockType = 'system';
      });
      await _prefs?.setString('m-privacy-lock-type', 'system');
      if (!mounted) return false;
      _showToast('System Lock enabled'.localized(context));
      return true;
    } else {
      final customPinSet = await _showSetupCustomPinDialog();
      if (!customPinSet) {
        setState(() {
          if (_systemLockAvailable) {
            _privacyLockType = 'system';
            unawaited(_prefs?.setString('m-privacy-lock-type', 'system'));
          } else {
            _privacyLock = false;
            _privacyUnlocked = false;
            unawaited(_prefs?.setBool('m-privacy-lock', false));
          }
        });
        _syncPrivacyOverlay();
        return false;
      }
      setState(() {
        _privacyLockType = 'custom_pin';
      });
      await _prefs?.setString('m-privacy-lock-type', 'custom_pin');
      return true;
    }
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
      final customPinSet = await _showSetupCustomPinDialog();
      if (!customPinSet) {
        setState(() {
          _privacyLock = false;
          _privacyUnlocked = false;
        });
        _syncPrivacyOverlay();
        await _prefs?.setBool('m-privacy-lock', false);
        return false;
      }
      setState(() {
        _privacyLock = true;
        _privacyLockType = 'custom_pin';
        _systemLockAvailable = false;
      });
      _syncPrivacyOverlay();
      await _prefs?.setBool('m-privacy-lock', true);
      await _prefs?.setString('m-privacy-lock-type', 'custom_pin');
      return true;
    }
    if (_privacyLockType == 'system') {
      final unlocked = await _unlockPrivacyLock();
      if (!unlocked) return false;
      setState(() {
        _privacyLock = true;
        _systemLockAvailable = true;
      });
      _syncPrivacyOverlay();
      await _prefs?.setBool('m-privacy-lock', true);
      return true;
    } else {
      final customPinSet = await _showSetupCustomPinDialog();
      if (!customPinSet) {
        setState(() {
          _privacyLock = false;
          _privacyUnlocked = false;
        });
        _syncPrivacyOverlay();
        await _prefs?.setBool('m-privacy-lock', false);
        return false;
      }
      setState(() {
        _privacyLock = true;
        _privacyLockType = 'custom_pin';
        _systemLockAvailable = true;
      });
      _syncPrivacyOverlay();
      await _prefs?.setBool('m-privacy-lock', true);
      await _prefs?.setString('m-privacy-lock-type', 'custom_pin');
      return true;
    }
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
    if (!_systemLockAvailable || _privacyLockType == 'custom_pin') {
      return false;
    }
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
        if (ok && _pendingShortcutAction != null) {
          final action = _pendingShortcutAction!;
          _pendingShortcutAction = null;
          _executeShortcutAction(action);
        }
      }
      if (!ok && mounted) {
        _showToast(
          'App Lock stays off until you confirm your Android screen lock.'
              .localized(context),
          warning: true,
        );
      }
      return ok;
    } catch (_) {
      if (mounted) {
        _showToast(
          'App Lock needs a device screen lock'.localized(context),
          warning: true,
        );
      }
      return false;
    } finally {
      _privacyAuthInFlight = false;
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode('${pin}notekar_salt_secure_2026');
    return sha256.convert(bytes).toString();
  }

  void _handleUnlockSuccess() {
    unawaited(_prefs?.setInt('m-failed-attempts', 0));
    unawaited(_prefs?.setInt('m-lockout-until', 0));
    if (mounted) {
      setState(() {
        _privacyUnlocked = true;
      });
      _syncPrivacyOverlay();
      if (_prefs != null && !_startupChecksStarted) {
        unawaited(_runStartupChecks(_prefs!));
      }
      if (_pendingShortcutAction != null) {
        final action = _pendingShortcutAction!;
        _pendingShortcutAction = null;
        _executeShortcutAction(action);
      }
    }
  }

  void _handleUnlockFailed() {
    final attempts = (_prefs?.getInt('m-failed-attempts') ?? 0) + 1;
    unawaited(_prefs?.setInt('m-failed-attempts', attempts));

    int lockoutSec = 0;
    if (attempts >= 5) {
      if (attempts == 5) {
        lockoutSec = 30;
      } else if (attempts == 6) {
        lockoutSec = 60;
      } else if (attempts == 7) {
        lockoutSec = 120;
      } else {
        lockoutSec = 300; // 5 minutes
      }

      final lockoutUntil =
          DateTime.now().millisecondsSinceEpoch + (lockoutSec * 1000);
      unawaited(_prefs?.setInt('m-lockout-until', lockoutUntil));
    }

    if (mounted) {
      setState(() {});
      _syncPrivacyOverlay();
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
    } catch (e, stack) {
      _logger.error('Failed to set app icon style', e, stack);
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

  DateTime? _getLatestRelapseTime() {
    if (_entries.isEmpty) return null;
    if (_sobrietyResetType == 'relapse') {
      final relapseMoments = _entries.where(
        (e) => e.note.contains('#relapse') && !e.note.contains('#shielded'),
      );
      if (relapseMoments.isEmpty) {
        final minTimestamp = _entries.map((e) => e.timestamp).reduce(math.min);
        return DateTime.fromMillisecondsSinceEpoch(minTimestamp);
      }
      final maxTimestamp = relapseMoments
          .map((e) => e.timestamp)
          .reduce(math.max);
      return DateTime.fromMillisecondsSinceEpoch(maxTimestamp);
    } else {
      final maxTimestamp = _entries.map((e) => e.timestamp).reduce(math.max);
      return DateTime.fromMillisecondsSinceEpoch(maxTimestamp);
    }
  }

  Future<void> _updateStreakShields() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final duration = _getSobrietyDuration();
    final streakDays = duration.inDays;

    // Default 1 shield when shields are uninitialized!
    if (!prefs.containsKey('streak_shields')) {
      await prefs.setInt('streak_shields', 1);
      await prefs.setInt('last_shield_granted_threshold', 0);
    }

    final currentShields = prefs.getInt('streak_shields') ?? 1;
    final lastGrantedThreshold =
        prefs.getInt('last_shield_granted_threshold') ?? 0;

    // Reset granted threshold on reset
    if (streakDays == 0 && lastGrantedThreshold > 0) {
      await prefs.setInt('last_shield_granted_threshold', 0);
    }

    // Earn 1 shield for every 30 days of streak!
    final earnedShieldsCount = (streakDays / 30).floor();

    if (earnedShieldsCount > lastGrantedThreshold) {
      final newShieldsCount =
          currentShields + (earnedShieldsCount - lastGrantedThreshold);
      await prefs.setInt('streak_shields', newShieldsCount);
      await prefs.setInt('last_shield_granted_threshold', earnedShieldsCount);

      // Sensory feedback double-pulse and toast!
      NotekarHaptics.successDouble(_hapticStyle);
      _showToast(
        '🛡️ Shield Earned! You got a Streak Shield for protecting your progress.',
      );
    }

    if (mounted) {
      setState(() {
        _streakShields = prefs.getInt('streak_shields') ?? 1;
      });
    }
  }

  Duration _getSobrietyDuration() {
    // Custom start date takes precedence over log-based calculation.
    if (_sobrietyCustomStart != null) {
      final diff = DateTime.now().difference(_sobrietyCustomStart!);
      return diff.isNegative ? Duration.zero : diff;
    }
    final resetTime = _getLatestRelapseTime();
    if (resetTime == null) return Duration.zero;
    final diff = DateTime.now().difference(resetTime);
    return diff.isNegative ? Duration.zero : diff;
  }

  String _formatSobrietyStreak(Duration duration) {
    if (duration == Duration.zero) return '0h Clean';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    if (days == 0) {
      if (hours == 0) {
        return '$minutes mins Clean';
      }
      return '${hours}h ${minutes}m Clean';
    }
    return '${days}d ${hours}h Clean';
  }

  Map<String, dynamic> _getMilestoneInfo(Duration duration) {
    final result = getMilestoneProgress(duration);
    final theme = _sobrietyMilestoneTheme;
    final currentName = result.current != null
        ? getMilestoneName(result.current!, theme)
        : 'None';
    final nextLabel = result.next != null
        ? result.next!.dayLabel
        : 'All Achieved!';
    return {
      'current': currentName,
      'next': result.next != null
          ? getMilestoneName(result.next!, theme)
          : 'None',
      'nextLabel': nextLabel,
      'progress': result.progress,
      'remaining': result.remainingLabel,
    };
  }

  Widget _buildSobrietyStreakCard(Palette palette) {
    return HomeSobrietyStreakCard(
      duration: _getSobrietyDuration(),
      milestoneTheme: _sobrietyMilestoneTheme,
      streakShields: _streakShields,
      onTapMilestone: (milestone, streakDays) {
        showMilestoneUnlockDialog(
          context: context,
          p: palette,
          milestone: milestone,
          themeId: _sobrietyMilestoneTheme,
          streakDays: streakDays,
          streakShields: _streakShields,
        );
      },
      onTapSettings: () => _openSettings(initialCategory: 'Sobriety Companion'),
      onOpenUrgeSurfing: _openUrgeSurfing,
    );
  }

  void _applySystemUiStyle() {
    final light = _theme == 'light';
    final adaptive = _activeAdaptiveColor;
    final bool isDarkIcons;
    if (adaptive != null) {
      isDarkIcons = adaptive.computeLuminance() > 0.45;
    } else {
      isDarkIcons = light;
    }

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: isDarkIcons
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarIconBrightness: isDarkIcons
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
        title: 'Time Between Moments'.localized(context),
        largeText: _largeText,
        blur:
            _enableTranslucency &&
            AdaptiveEngine().supportsBlur &&
            !_reduceMotion,
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
              child: Text('Okay'.localized(context)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = p;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final lastSaved = _lastId != null;

    Widget body = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      color: palette.bg,
      child: Stack(
        children: [
          // Fluid Spatial Gestures: Swipe Up on lower third to smoothly pull up Life Ledger (History)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.sizeOf(context).height * 0.33,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (_) => _collapseHeaderIfExpanded(),
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < -260) {
                  _openHistory();
                }
              },
            ),
          ),
          // Ergonomic Safety Zone: Tap target bounded vertically to the clock band, full width edge-to-edge
          Positioned(
            top: MediaQuery.paddingOf(context).top + 144,
            bottom: MediaQuery.paddingOf(context).bottom + 85,
            left: 0,
            right: 0,
            child: Semantics(
              label: _mode == 'single'
                  ? 'Log a new moment'
                  : (_inout == 'in' ? 'Start session' : 'End session'),
              hint:
                  'Double tap to record, long press to add note, swipe horizontally to switch mode',
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _collapseHeaderIfExpanded(),
                onTapUp: _handleTap,
                onLongPress: _openNote,
                onHorizontalDragStart: (_) {
                  _collapseHeaderIfExpanded();
                  _horizontalSwipeDelta = 0;
                  _horologyDetentFired = false;
                },
                onHorizontalDragUpdate: (details) {
                  _horizontalSwipeDelta += details.delta.dx;
                  // 50% threshold detent: fires right as swipe crosses 50% mark simulating mechanical watch crown click
                  if (!_horologyDetentFired &&
                      _horizontalSwipeDelta.abs() >= 30.0) {
                    HapticFeedback.selectionClick();
                    _horologyDetentFired = true;
                  }
                },
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity.abs() > 200 ||
                      _horizontalSwipeDelta.abs() >= 60.0) {
                    _toggleMode();
                  }
                  _horizontalSwipeDelta = 0;
                  _horologyDetentFired = false;
                },
                onHorizontalDragCancel: () {
                  _horizontalSwipeDelta = 0;
                  _horologyDetentFired = false;
                },
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.paddingOf(context).top + 64,
            bottom: MediaQuery.paddingOf(context).bottom + 76,
            left: spacing24,
            right: spacing24,
            child: IgnorePointer(
              child: Center(
                child: RepaintBoundary(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      LiveClockFace(
                        p: palette,
                        pulseToken: _savedPulseToken,
                        pulseType: _lastSavedType,
                        showSeconds: _showSeconds,
                        highlightSeconds: _highlightSeconds,
                        use24HourFormat: _use24HourFormat,
                        sessionStart: _mode == 'two-way' ? _sessionStart : null,
                        isPaused: _isPaused,
                        pausedAt: _pausedAt,
                        fontFamily: _clockFont,
                      ),
                      if (_startupComplete &&
                          _entries.isEmpty &&
                          !_hasTappedBefore)
                        Positioned(
                          bottom: -72,
                          // Positioned elegantly below the clock face with arrow pointing up
                          child: CoachmarkTooltip(p: palette),
                        ),
                    ],
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
                    color: momentColor(palette, _lastSavedType),
                  ),
                  SavedPulse(
                    key: ValueKey(_savedPulseToken),
                    origin: _lastTapPosition!,
                    p: palette,
                    type: _lastSavedType,
                    pulseCount: _countOnSave && _lastSavedType == 'single'
                        ? _lastSingleCount
                        : null,
                  ),
                ],
              ),
            ),

          // Progressive Frosted Top Bar Blur (Apple HIG TopFadeBlur)
          if (_enableTranslucency &&
              AdaptiveEngine().supportsBlur &&
              !_reduceMotion)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TopFadeBlur(p: palette),
            ),

          // Dynamic Header Capsule (Dynamic Island-inspired)
          Positioned(
            top: spacing16 + MediaQuery.paddingOf(context).top,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_enableSobrietyMode) ...[
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: !_headerExpanded
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: spacing16,
                            ),
                            child: _buildSobrietyStreakCard(palette),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (!_headerExpanded) const SizedBox(height: spacing8),
                ],
                DynamicHeaderCapsule(
                  p: palette,
                  entries: _entries,
                  categories: _categories,
                  activeCategory: _activeCategory,
                  isExpanded: _headerExpanded,
                  mode: _mode,
                  onModeChanged: _setMode,
                  onExpansionChanged: (expanded) {
                    setState(() => _headerExpanded = expanded);
                  },
                  onSelectCategory: _setActiveCategory,
                  onAddCategory: _showAddCategoryDialog,
                  onManageCategories: () =>
                      unawaited(_openSettings(initialCategory: 'Modes')),
                  onLongPressCategory: (cat) =>
                      unawaited(_openSettings(initialCategory: 'Mode: $cat')),
                  blur:
                      _enableTranslucency &&
                      AdaptiveEngine().supportsBlur &&
                      !_reduceMotion,
                  trackedDuration: _computeTodayTrackedDuration(),
                  momentsCount: _computeTodayMomentsCount(),
                  currentStreak: StreakGuardianService.calculateStreak(
                    _entries.map((e) => e.date).toSet(),
                  ),
                  bankedGraceDays:
                      _prefs?.getInt('notekar.streak_grace_banked') ?? 1,
                  isSessionOngoing:
                      _mode == 'two-way' &&
                      (_sessionStart != null || _inout == 'out'),
                  onOpenIntelligenceHub: _openIntelligenceHub,
                ),
              ],
            ),
          ),
          if (lastSaved && _showLastSavedHint)
            Positioned(
              left: 0,
              right: 0,
              bottom: 102 + bottomInset,
              child: Builder(
                builder: (context) {
                  final lastEntry = _lastId != null
                      ? _entries.where((e) => e.id == _lastId).firstOrNull
                      : null;
                  String? message;
                  String noteLabel = '+ Note';
                  if (lastEntry != null) {
                    if (_mode == 'single') {
                      message = 'Moment saved';
                      if (lastEntry.note.isNotEmpty) noteLabel = 'Edit Note';
                    } else {
                      if (lastEntry.type == 'in') {
                        message = 'Session started';
                        if (lastEntry.note.isNotEmpty) noteLabel = 'Edit Note';
                      } else {
                        message = 'Session ended';
                        final matchingIn = _entries
                            .where(
                              (e) =>
                                  e.type == 'in' &&
                                  e.timestamp <= lastEntry.timestamp,
                            )
                            .firstOrNull;
                        final hasNote =
                            lastEntry.note.isNotEmpty ||
                            (matchingIn != null && matchingIn.note.isNotEmpty);
                        if (hasNote) noteLabel = 'Edit Note';
                      }
                    }
                  }
                  return UndoToast(
                    p: palette,
                    onUndo: _undoLast,
                    token: _lastId ?? 0,
                    message: message,
                    onAddNote: _openNoteForLastCapture,
                    noteLabel: noteLabel,
                  );
                },
              ),
            ),
          if (_toolbarAppearance == 'standard')
            Positioned(
              left: spacing16,
              right: spacing16,
              bottom: spacing16 + bottomInset,
              child: RepaintBoundary(
                child: Toolbar(
                  p: palette,
                  mode: _mode,
                  onMode: _toggleMode,
                  onHistory: _openHistory,
                  onSettings: _openSettings,
                  showLabels: _buttonLabels,
                  largeControls: _largeControls,
                  showBackgroundPill: _homeMenuPill,
                  animateIcons: _homeMenuAnimations && !_reduceMotion,
                  motionNotifier: _motion,
                  showHistoryText: _showHistoryText,
                  lastTimestamp: _mode == 'two-way' && _sessionStart != null
                      ? formatTimeShort(DateTime.now().millisecondsSinceEpoch)
                      : (_entries.isNotEmpty
                            ? formatTimeShort(_entries.first.timestamp)
                            : null),
                  blur:
                      _enableTranslucency &&
                      AdaptiveEngine().supportsBlur &&
                      !_reduceMotion,
                  isSessionActive: _mode == 'two-way' && _sessionStart != null,
                  activeGoalTitle: _activeGoalTitle,
                  onNextGoal: _cachedGoals.isNotEmpty ? _onNextGoal : null,
                  onPrevGoal: _cachedGoals.isNotEmpty ? _onPrevGoal : null,
                  enableGoalSwitcher: true,
                ),
              ),
            )
          else if (_toolbarAppearance == 'minimal_capsule')
            Positioned(
              left: 0,
              right: 0,
              bottom: spacing16 + bottomInset,
              child: Center(
                child: _buildMinimalToolbarCapsule(palette, bottomInset),
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset + 8,
              child: Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.text3.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
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
                    'deleted ${_lastDeletedPreview!.type} moment'.localized(
                      context,
                    ),
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
              subStatus: _factoryResetSubText,
              icon: _factoryResetIcon,
              onStart: _finishFactoryResetOverlay,
            ),
          if (_privacyLock && !_privacyUnlocked)
            PrivacyLockOverlay(
              p: palette,
              onUnlock: () => unawaited(_unlockPrivacyLock()),
              isSystemLockAvailable:
                  _systemLockAvailable && _privacyLockType == 'system',
              customPin: _prefs?.getString('m-custom-pin'),
              failedAttempts: _prefs?.getInt('m-failed-attempts') ?? 0,
              lockoutUntil: _prefs?.getInt('m-lockout-until') ?? 0,
              onUnlockSuccess: _handleUnlockSuccess,
              onUnlockFailed: _handleUnlockFailed,
              enableTranslucency: _enableTranslucency,
              reduceMotion: _reduceMotion,
            ),
          if (!_splashDismissed)
            Positioned.fill(
              child: ZenDoodleSplash(
                p: palette,
                onComplete: () {
                  if (mounted) {
                    setState(() => _splashDismissed = true);
                  }
                },
              ),
            ),
        ],
      ),
    );

    if (_largeText) {
      body = MediaQuery(data: largerTextQuery(context), child: body);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          _showToast('Press back again to exit');
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: palette.bg,
        resizeToAvoidBottomInset: false,
        body: body,
      ),
    );
  }
}
