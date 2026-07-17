import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NoteKarApp());
}

class LiveClockFace extends StatefulWidget {
  const LiveClockFace({
    super.key,
    required this.p,
    required this.pulseToken,
    required this.pulseType,
    required this.showSeconds,
    required this.highlightSeconds,
  });

  final Palette p;
  final int pulseToken;
  final String pulseType;
  final bool showSeconds;
  final bool highlightSeconds;

  @override
  State<LiveClockFace> createState() => _LiveClockFaceState();
}

class _LiveClockFaceState extends State<LiveClockFace> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scheduleNextTick();
  }

  void _scheduleNextTick() {
    _timer?.cancel();

    final now = DateTime.now();
    final millisecondsUntilNextSecond = 1000 - now.millisecond;

    _timer = Timer(Duration(milliseconds: millisecondsUntilNextSecond), () {
      if (!mounted) return;

      setState(() => _now = DateTime.now());
      _scheduleNextTick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClockFace(
      now: _now,
      p: widget.p,
      pulseToken: widget.pulseToken,
      pulseType: widget.pulseType,
      minimal: false,
      showSeconds: widget.showSeconds,
      highlightSeconds: widget.highlightSeconds,
    );
  }
}

class NoteKarApp extends StatelessWidget {
  const NoteKarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteKar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A84FF),
          brightness: Brightness.dark,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0A84FF),
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0A84FF),
          ),
        ),
        fontFamily: 'Roboto',
        splashFactory: NoSplash.splashFactory,
      ),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final clampedScaler = media.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.25,
        );

        return MediaQuery(
          data: media.copyWith(textScaler: clampedScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const NoteKarHome(),
    );
  }
}

class Moment {
  Moment({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.date,
    this.note = '',
  });

  final int id;
  final int timestamp;
  final String type;
  final String date;
  final String note;

  factory Moment.fromJson(Map<String, dynamic> json) {
    return Moment(
      id: (json['id'] as num).toInt(),
      timestamp: (json['timestamp'] as num).toInt(),
      type: (json['type'] as String?) ?? 'single',
      date: (json['date'] as String?) ?? _dateKey(DateTime.now()),
      note: (json['note'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'type': type,
    'date': date,
    'note': note,
  };
}

class _HistoryListItem {
  const _HistoryListItem.header(this.label) : moment = null;
  const _HistoryListItem.moment(this.moment) : label = null;

  final String? label;
  final Moment? moment;
}

class BackupValidationResult {
  const BackupValidationResult.valid({
    required this.entries,
    required this.settings,
    required this.exportedAt,
  }) : error = null;

  const BackupValidationResult.invalid(this.error)
    : entries = const [],
      settings = const {},
      exportedAt = null;

  final String? error;
  final List<Moment> entries;
  final Map<String, dynamic> settings;
  final DateTime? exportedAt;

  bool get isValid => error == null;
}

class BackupDryRunSummary {
  const BackupDryRunSummary({
    required this.backupMoments,
    required this.backupNotes,
    required this.newMoments,
    required this.duplicatesSkipped,
    required this.settingsToRestore,
    required this.exportedAt,
  });

  final int backupMoments;
  final int backupNotes;
  final int newMoments;
  final int duplicatesSkipped;
  final int settingsToRestore;
  final DateTime? exportedAt;
}

BackupValidationResult validateNoteKarBackupContent(String content) {
  if (content.length > 10 * 1024 * 1024) {
    return const BackupValidationResult.invalid(
      'Backup is too large to import safely',
    );
  }

  Object? decoded;
  try {
    decoded = jsonDecode(content);
  } catch (_) {
    return const BackupValidationResult.invalid('Backup is not valid JSON');
  }

  if (decoded is! Map) {
    return const BackupValidationResult.invalid('Invalid backup file');
  }

  final data = Map<String, dynamic>.from(decoded);
  if (data['app'] != 'NoteKar') {
    return const BackupValidationResult.invalid('This is not a NoteKar backup');
  }

  final kind = data['kind'];
  if (kind != null && kind != 'backup') {
    return const BackupValidationResult.invalid(
      'This file is not a backup export',
    );
  }

  final rawEntries = data['entries'];
  if (rawEntries is! List) {
    return const BackupValidationResult.invalid(
      'This file does not contain NoteKar moments',
    );
  }

  if (rawEntries.length > 50000) {
    return const BackupValidationResult.invalid(
      'Backup has too many moments to import safely',
    );
  }

  final imported = <Moment>[];
  final now = DateTime.now().millisecondsSinceEpoch;
  final maxFuture = now + const Duration(days: 366).inMilliseconds;

  for (var i = 0; i < rawEntries.length; i++) {
    final row = rawEntries[i];
    if (row is! Map) {
      return BackupValidationResult.invalid(
        'Backup has damaged moment data near item ${i + 1}',
      );
    }

    final item = Map<String, dynamic>.from(row);
    final timestampValue = item['timestamp'];
    if (timestampValue is! num ||
        !timestampValue.isFinite ||
        timestampValue <= 0 ||
        timestampValue > maxFuture) {
      return BackupValidationResult.invalid(
        'Backup has an invalid moment time near item ${i + 1}',
      );
    }

    final type = item['type'] is String ? item['type'] as String : 'single';
    if (!{'single', 'in', 'out'}.contains(type)) {
      return BackupValidationResult.invalid(
        'Backup has an unknown moment type near item ${i + 1}',
      );
    }

    final noteValue = item['note'];
    if (noteValue != null && noteValue is! String) {
      return BackupValidationResult.invalid(
        'Backup has an invalid note near item ${i + 1}',
      );
    }

    final note = (noteValue as String? ?? '').trim();
    if (note.length > 1000) {
      return BackupValidationResult.invalid(
        'Backup has a note that is too long near item ${i + 1}',
      );
    }

    final timestamp = timestampValue.toInt();
    imported.add(
      Moment(
        id: i + 1,
        timestamp: timestamp,
        type: type,
        date: _dateKey(DateTime.fromMillisecondsSinceEpoch(timestamp)),
        note: note,
      ),
    );
  }

  imported.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  final settings = data['settings'] is Map
      ? Map<String, dynamic>.from(data['settings'] as Map)
      : <String, dynamic>{};
  final exportedAt = data['exportedAt'] is String
      ? DateTime.tryParse(data['exportedAt'] as String)
      : null;

  return BackupValidationResult.valid(
    entries: imported,
    settings: settings,
    exportedAt: exportedAt,
  );
}

BackupDryRunSummary buildBackupDryRunSummary({
  required BackupValidationResult validation,
  required List<Moment> existingEntries,
}) {
  final existingKeys = existingEntries
      .map((entry) => '${entry.timestamp}|${entry.type}|${entry.note}')
      .toSet();
  var newMoments = 0;
  var duplicates = 0;

  for (final entry in validation.entries) {
    final key = '${entry.timestamp}|${entry.type}|${entry.note}';
    if (existingKeys.contains(key)) {
      duplicates++;
    } else {
      existingKeys.add(key);
      newMoments++;
    }
  }

  return BackupDryRunSummary(
    backupMoments: validation.entries.length,
    backupNotes: validation.entries
        .where((entry) => entry.note.isNotEmpty)
        .length,
    newMoments: newMoments,
    duplicatesSkipped: duplicates,
    settingsToRestore: _restorableBackupSettingsCount(validation.settings),
    exportedAt: validation.exportedAt,
  );
}

int _restorableBackupSettingsCount(Map<String, dynamic> settings) {
  var count = 0;
  if (['dark', 'light', 'amoled'].contains(settings['theme'])) count++;
  if (['single', 'two-way'].contains(settings['defaultMode'])) count++;
  final tapDelay = settings['tapDelay'];
  if (tapDelay is num &&
      _NoteKarHomeState._delayValues.contains(tapDelay.toInt())) {
    count++;
  }
  if (_NoteKarHomeState._accentOptions.contains(settings['accentColor'])) {
    count++;
  }
  if (_isAppIconStyle(settings['appIconStyle'] as String?)) count++;
  if (['off', 'light', 'standard'].contains(settings['hapticStyle'])) count++;
  if (['comfortable', 'compact'].contains(settings['historyDensity'])) count++;
  final backupDays = settings['backupReminderDays'];
  if (backupDays is num && [0, 7, 14, 30].contains(backupDays.toInt())) {
    count++;
  }
  if (settings['homeMenuAnimations'] is bool) count++;
  return count;
}

class Palette {
  Palette({
    required this.name,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.text,
    required this.text2,
    required this.text3,
    required this.clock,
    required this.accent,
    required this.green,
    required this.orange,
    required this.red,
  });

  final String name;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color text;
  final Color text2;
  final Color text3;
  final Color clock;
  final Color accent;
  final Color green;
  final Color orange;
  final Color red;
}

class NoteKarHome extends StatefulWidget {
  const NoteKarHome({super.key});

  @override
  State<NoteKarHome> createState() => _NoteKarHomeState();
}

class _NoteKarHomeState extends State<NoteKarHome>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const _appVersion = '4.0.3';
  static const _appBuildNumber = '12';
  static const _appBuildDate = '2026-06-17';
  static const _officialSite = 'https://notekarapp.vercel.app';
  static const _githubRepo = 'https://github.com/dheeraz101/Notekar';
  static const _githubReleases =
      'https://github.com/dheeraz101/Notekar/releases';
  static const _supportEmail = 'mailto:yabp.ub8ke@aleeas.com';
  static const _notificationFeed =
      'https://raw.githubusercontent.com/dheeraz101/NotekarN/refs/heads/main/notification.json';
  static const _delayValues = [0, 5, 10, 15, 20, 30, 60];
  static const _accentOptions = [
    'blue',
    'green',
    'purple',
    'pink',
    'orange',
    'graphite',
    'teal',
    'mint',
    'cyan',
    'indigo',
    'violet',
    'lavender',
    'rose',
    'coral',
    'amber',
    'sand',
    'sage',
    'olive',
    'slate',
    'brown',
  ];
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
  String _updateStatus = 'v$_appVersion - Check for available updates';
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

  Palette get p => _paletteFor(
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
      await _showWelcomeIfNeeded(prefs);

      await prefs.setString(_lastSeenVersionKey, _appVersion);

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
    await _initHive();
    final entryBox = await Hive.openBox<dynamic>(_entryBoxName);
    final prefs = await SharedPreferences.getInstance();
    final entries = await _loadEntries(entryBox, prefs);
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (!mounted) return;
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
      _appIconStyle = _isAppIconStyle(savedAppIconStyle)
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
      unawaited(_runStartupChecks(prefs));
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
    _startupChecksStarted = true;
    final startupTask = developer.TimelineTask()
      ..start('notekar.startup.deferred_checks');

    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) {
      startupTask.finish();
      return;
    }

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
    final today = _dateKey(DateTime.now());
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    });
  }

  Future<void> _showWhatsNewIfNeeded(SharedPreferences prefs) async {
    if (prefs.getString(_lastSeenVersionKey) == _appVersion) return;
    if (!(prefs.getBool(_welcomeSeenKey) ?? false)) {
      await prefs.setString(_lastSeenVersionKey, _appVersion);
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
      await prefs.setString(_lastSeenVersionKey, _appVersion);
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
      date: _dateKey(now),
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
      _showToast('Wait ${_delayLabel(_tapDelay)} between taps', warning: true);
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
      _privacyLockDelayMinutes = 0;
      _updateStatus = 'v$_appVersion - Check for available updates';
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
          'feedUrl': _notificationFeed,
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
    await _prefs?.setInt('m-privacy-lock-delay', _privacyLockDelayMinutes);
    try {
      await _fileChannel.invokeMethod<void>('configureRemoteNotices', {
        'enabled': false,
        'feedUrl': _notificationFeed,
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
    await _prefs?.setInt('m-privacy-lock-delay', _privacyLockDelayMinutes);
    _applySystemUiStyle();
    _showToast('Settings restored');
    unawaited(_updateAndroidWidget());
  }

  Future<void> _updateAndroidWidget() async {
    final now = DateTime.now();
    final today = _dateKey(now);

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
      pageBuilder: (_, _, _) => NoteDialog(p: p),
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
        historyDensity: _historyDensity,
        largeText: _largeText,
        onDelete: _deleteEntry,
        onRestore: _restoreEntry,
        onUpdateNote: _updateMomentNote,
        confirmDelete: _confirmDelete,
        onDuration: _showDuration,
        onFeedback: _showToast,
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
        privacyLockDelayMinutes: _privacyLockDelayMinutes,
        updateStatus: _updateStatus,
        checkingUpdates: _checkingUpdates,
        lastUpdateCheckedAt: _lastUpdateCheckedAt,
        entries: _entries,
        lastSavedAt: _entries.isEmpty
            ? null
            : _entries.map((entry) => entry.timestamp).reduce(math.max),
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
        onPrivacyLockDelay: (value) {
          setState(() => _privacyLockDelayMinutes = value);
          _prefs?.setInt('m-privacy-lock-delay', value);
        },
        onExportCsv: () => _exportFile(
          fileName: 'notekar-moments-${_exportDateStamp()}.csv',
          content: _csvExport(),
          mimeType: 'text/csv',
        ),
        onExportRecentCsv: () => _exportFile(
          fileName: 'notekar-recent-7-days-${_exportDateStamp()}.csv',
          content: _csvExport(
            since: DateTime.now().subtract(const Duration(days: 7)),
          ),
          mimeType: 'text/csv',
        ),
        onExportJson: () => _exportFile(
          fileName: 'notekar-moments-${_exportDateStamp()}.json',
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
          pageBuilder: (_, _, _) =>
              ChangelogDialog(p: p, latestOnly: latestOnly),
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
      pageBuilder: (_, _, _) => ChangelogDialog(p: p, latestOnly: true),
    );
  }

  Future<void> _openChangelog() async {
    await showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close changelog',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ChangelogDialog(p: p),
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
        await _openExternalLink(_githubReleases);
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
        'feedUrl': _notificationFeed,
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
      if (_isNewerVersion(latest, _appVersion)) {
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
      _setUpdateStatus('v$_appVersion - Check for available updates');
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
      request.headers.set(HttpHeaders.userAgentHeader, 'NoteKar/$_appVersion');
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
      fileName: 'notekar-backup-${_exportDateStamp()}.json',
      content: _backupExport(),
      mimeType: 'application/json',
    );

    if (!ok) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() => _lastBackupAt = now);
    await _prefs?.setInt('m-last-backup-at', now);
  }

  BackupValidationResult _validateBackupContent(String content) {
    return validateNoteKarBackupContent(content);
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
        () => _validateBackupContent(content!),
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
              _delayValues.contains(importedTapDelay.toInt())
          ? importedTapDelay.toInt()
          : _tapDelay;
      final nextAccentColor = _accentOptions.contains(importedAccentColor)
          ? importedAccentColor!
          : _accentColor;
      final nextAppIconStyle = _isAppIconStyle(importedAppIconStyle)
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
      pageBuilder: (_, _, _) =>
          BackupImportPreviewDialog(p: p, summary: summary),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_timeOnly(start)} - ${_timeOnly(end)}',
              style: TextStyle(color: p.text2),
            ),
            const SizedBox(height: 10),
            Text(
              _durationLabel(duration),
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
        '"NoteKar","$_appVersion","$exportedAt",${e.id},${e.timestamp},'
        '"$iso","${e.date}","${_timeOnly(e.timestamp)}","${e.type}",'
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
      'version': _appVersion,
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
      'version': _appVersion,
      'build': _appBuildNumber,
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
                      left: 26,
                      right: 26,
                      bottom: 100 + bottomInset,
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
              top: MediaQuery.paddingOf(context).top + 14,
              left: 14,
              right: 14,
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
              left: 18,
              right: 18,
              bottom: 18 + bottomInset,
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
                    );
                  },
                ),
              ),
            ),
            if (_lastDeletedPreview != null)
              Positioned(
                left: 20,
                right: 20,
                top: MediaQuery.paddingOf(context).top + 68,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
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

class PrivacyLockOverlay extends StatelessWidget {
  const PrivacyLockOverlay({
    super.key,
    required this.p,
    required this.onUnlock,
  });

  final Palette p;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: p.bg,
        child: DefaultTextStyle(
          style: TextStyle(
            color: p.text,
            decoration: TextDecoration.none,
            fontFamily: 'Roboto',
          ),
          child: ColoredBox(
            color: p.bg,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.surface2,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.border),
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            color: p.accent,
                            size: 23,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Private by default',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your moments stay hidden until you unlock NoteKar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 13,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        PressableScale(
                          onTap: onUnlock,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: p.accent,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: _selectedGlow(p.accent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_open_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Unlock NoteKar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FactoryResetOverlay extends StatelessWidget {
  const FactoryResetOverlay({
    super.key,
    required this.p,
    required this.progress,
    required this.complete,
    required this.status,
    required this.onStart,
  });

  final Palette p;
  final double progress;
  final bool complete;
  final String status;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: p.bg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: complete
                        ? p.green.withValues(alpha: 0.14)
                        : p.accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    complete ? Icons.check_rounded : Icons.restart_alt_rounded,
                    color: complete ? p.green : p.accent,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  complete ? 'Ready to Start' : 'Resetting NoteKar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.text2, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: progress.clamp(0, 1),
                    backgroundColor: p.surface3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      complete ? p.green : p.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(progress.clamp(0, 1) * 100).round()}%',
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  opacity: complete ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: complete ? onStart : null,
                    child: const Text('Start'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClockFace extends StatefulWidget {
  const ClockFace({
    super.key,
    required this.now,
    required this.p,
    required this.pulseToken,
    required this.pulseType,
    required this.minimal,
    required this.showSeconds,
    required this.highlightSeconds,
  });

  final DateTime now;
  final Palette p;
  final int pulseToken;
  final String pulseType;
  final bool minimal;
  final bool showSeconds;
  final bool highlightSeconds;

  @override
  State<ClockFace> createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace> {
  bool _bright = false;
  Timer? _timer;

  @override
  void didUpdateWidget(covariant ClockFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulseToken != widget.pulseToken) {
      _timer?.cancel();
      setState(() => _bright = true);
      _timer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _bright = false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hm =
        '${widget.now.hour.toString().padLeft(2, '0')}:${widget.now.minute.toString().padLeft(2, '0')}';
    final sec = '.${widget.now.second.toString().padLeft(2, '0')}';
    final actionColor = widget.p.accent;
    final clockColor = _bright
        ? actionColor.withValues(alpha: widget.p.name == 'light' ? 0.70 : 0.58)
        : widget.p.clock;
    final secondsColor = widget.highlightSeconds ? widget.p.text3 : clockColor;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            hm,
            style: TextStyle(
              color: clockColor,
              fontSize: 116,
              fontWeight: FontWeight.w200,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (!widget.minimal && widget.showSeconds)
            Text(
              sec,
              style: TextStyle(
                color: _bright
                    ? actionColor.withValues(alpha: 0.75)
                    : secondsColor,
                fontSize: 42,
                fontWeight: FontWeight.w200,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    required this.p,
    required this.mode,
    required this.onMode,
    required this.onHistory,
    required this.onSettings,
    required this.showLabels,
    required this.largeControls,
    required this.showBackgroundPill,
    required this.animateIcons,
    required this.motionX,
    required this.motionY,
    required this.showHistoryText,
  });

  final Palette p;
  final String mode;
  final VoidCallback onMode;
  final VoidCallback onHistory;
  final VoidCallback onSettings;
  final bool showLabels;
  final bool largeControls;
  final bool showBackgroundPill;
  final bool animateIcons;
  final double motionX;
  final double motionY;
  final bool showHistoryText;

  @override
  Widget build(BuildContext context) {
    if (showLabels) {
      final labeledRow = Padding(
        padding: EdgeInsets.all(showBackgroundPill ? 6 : 0),
        child: SizedBox(
          width: math.min(MediaQuery.sizeOf(context).width - 48, 318),
          child: Row(
            children: [
              Expanded(
                child: TextToolButton(
                  p: p,
                  label: mode == 'single' ? 'Single' : 'Two-Way',
                  onTap: onMode,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextToolButton(
                  p: p,
                  label: showHistoryText ? 'History' : '',
                  icon: showHistoryText ? null : Icons.history_rounded,
                  onTap: onHistory,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextToolButton(
                  p: p,
                  label: 'Settings',
                  onTap: onSettings,
                ),
              ),
            ],
          ),
        ),
      );
      return Center(
        child: showBackgroundPill
            ? DecoratedBox(
                decoration: _bottomNavDecoration(p),
                child: labeledRow,
              )
            : labeledRow,
      );
    }
    final iconRow = Padding(
      padding: EdgeInsets.all(showBackgroundPill ? 6 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModeToolButton(
            p: p,
            mode: mode,
            large: largeControls,
            motionX: animateIcons ? motionX : 0,
            motionY: animateIcons ? motionY : 0,
            onTap: onMode,
          ),
          const SizedBox(width: 8),
          PressableScale(
            onTap: onHistory,
            child: Glass(
              p: p,
              radius: 999,
              padding: EdgeInsets.symmetric(
                horizontal: showHistoryText ? 22 : 0,
                vertical: largeControls ? 16 : 15,
              ),
              child: showHistoryText
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedHomeIcon(
                          icon: Icons.history_rounded,
                          color: p.text,
                          size: 20,
                          motionX: animateIcons ? motionX : 0,
                          motionY: animateIcons ? motionY : 0,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'History',
                          style: TextStyle(
                            color: p.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: largeControls ? 62 : 54,
                      height: largeControls ? 30 : 24,
                      child: AnimatedHomeIcon(
                        icon: Icons.history_rounded,
                        color: p.text,
                        size: 21,
                        motionX: animateIcons ? motionX : 0,
                        motionY: animateIcons ? motionY : 0,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          CircleToolButton(
            p: p,
            icon: Icons.settings_rounded,
            color: p.text,
            label: showLabels ? 'Settings' : null,
            size: largeControls ? 62 : 54,
            motionX: animateIcons ? motionX : 0,
            motionY: animateIcons ? motionY : 0,
            onTap: onSettings,
          ),
        ],
      ),
    );
    return Center(
      child: showBackgroundPill
          ? DecoratedBox(decoration: _bottomNavDecoration(p), child: iconRow)
          : iconRow,
    );
  }
}

BoxDecoration _bottomNavDecoration(Palette p) {
  return BoxDecoration(
    color: p.name == 'light'
        ? const Color(0xFFF2F2F7)
        : p.surface.withValues(alpha: p.name == 'amoled' ? 0.96 : 0.94),
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: p.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: p.name == 'light' ? 0.08 : 0.20),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

enum HomeIconAnimationKind { spin, sway, breathe }

class HomeIconAnimation {
  const HomeIconAnimation.spin({required this.turns, required this.durationMs})
    : kind = HomeIconAnimationKind.spin;
  const HomeIconAnimation.sway({required this.durationMs})
    : kind = HomeIconAnimationKind.sway,
      turns = 0.035;
  const HomeIconAnimation.breathe({required this.durationMs})
    : kind = HomeIconAnimationKind.breathe,
      turns = 0;

  final HomeIconAnimationKind kind;
  final double turns;
  final int durationMs;
}

class AnimatedHomeIcon extends StatefulWidget {
  const AnimatedHomeIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    this.motionX = 0,
    this.motionY = 0,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double motionX;
  final double motionY;

  @override
  State<AnimatedHomeIcon> createState() => _AnimatedHomeIconState();
}

class _AnimatedHomeIconState extends State<AnimatedHomeIcon> {
  double _displayAngle = 0;

  double _targetAngle() {
    final strength = math.sqrt(
      widget.motionX * widget.motionX + widget.motionY * widget.motionY,
    );

    if (strength < 0.10) {
      return 0;
    }

    return math.atan2(-widget.motionX, widget.motionY);
  }

  double _nearestEquivalentAngle(double current, double target) {
    var adjusted = target;

    while (adjusted - current > math.pi) {
      adjusted -= math.pi * 2;
    }

    while (adjusted - current < -math.pi) {
      adjusted += math.pi * 2;
    }

    return adjusted;
  }

  @override
  Widget build(BuildContext context) {
    final target = _nearestEquivalentAngle(_displayAngle, _targetAngle());

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _displayAngle, end: target),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      onEnd: () {
        _displayAngle = target;
      },
      builder: (context, angle, child) {
        _displayAngle = angle;

        return Transform.rotate(
          angle: angle,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}

class TextToolButton extends StatelessWidget {
  const TextToolButton({
    super.key,
    required this.p,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final Palette p;
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Glass(
        p: p,
        radius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Center(
          child: icon == null
              ? Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Icon(icon, color: p.text, size: 18),
        ),
      ),
    );
  }
}

class CircleToolButton extends StatelessWidget {
  const CircleToolButton({
    super.key,
    required this.p,
    required this.icon,
    required this.color,
    this.label,
    this.size = 54,
    this.animation,
    this.motionX = 0,
    this.motionY = 0,
    required this.onTap,
  });

  final Palette p;
  final IconData icon;
  final Color color;
  final String? label;
  final double size;
  final HomeIconAnimation? animation;
  final VoidCallback onTap;
  final double motionX;
  final double motionY;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Glass(
        p: p,
        radius: 999,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: label == null ? size : size + 22,
          height: size,
          child: label == null
              ? AnimatedHomeIcon(
                  icon: icon,
                  color: color,
                  size: 23,
                  motionX: motionX,
                  motionY: motionY,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedHomeIcon(
                      icon: icon,
                      color: color,
                      size: 21,
                      motionX: motionX,
                      motionY: motionY,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label!,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ModeToolButton extends StatelessWidget {
  const ModeToolButton({
    super.key,
    required this.p,
    required this.mode,
    required this.large,
    this.animation,
    this.motionX = 0,
    this.motionY = 0,
    required this.onTap,
  });

  final Palette p;
  final String mode;
  final bool large;
  final HomeIconAnimation? animation;
  final double motionX;
  final double motionY;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final single = mode == 'single';
    final color = p.text;
    return PressableScale(
      onTap: onTap,
      child: Glass(
        p: p,
        radius: 999,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: large ? 11 : 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: large ? 36 : 32,
              height: large ? 36 : 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.surface3,
                shape: BoxShape.circle,
              ),
              child: AnimatedHomeIcon(
                icon: single
                    ? Icons.arrow_upward_rounded
                    : Icons.swap_vert_rounded,
                color: color,
                size: large ? 21 : 19,
                motionX: motionX,
                motionY: motionY,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryDialog extends StatefulWidget {
  const HistoryDialog({
    super.key,
    required this.p,
    required this.entries,
    required this.compactRows,
    required this.historyDensity,
    required this.largeText,
    required this.confirmDelete,
    required this.onDelete,
    required this.onRestore,
    required this.onUpdateNote,
    required this.onDuration,
    required this.onFeedback,
  });

  final Palette p;
  final List<Moment> entries;
  final bool compactRows;
  final String historyDensity;
  final bool largeText;
  final bool confirmDelete;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(Moment entry) onRestore;
  final Future<void> Function(int id, String note) onUpdateNote;
  final void Function(Moment a, Moment b) onDuration;
  final ValueChanged<String> onFeedback;

  @override
  State<HistoryDialog> createState() => _HistoryDialogState();
}

class _NoticePill extends StatelessWidget {
  const _NoticePill({
    required this.p,
    required this.label,
    required this.color,
    this.onTap,
  });

  final Palette p;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      enabled: onTap != null,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: onTap == null ? p.text2 : color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HistoryDialogState extends State<HistoryDialog> {
  static const _pageSize = 100;
  String _filter = 'all';
  String? _selectedDateKey;
  final List<Moment> _selected = [];
  late List<Moment> _entries;
  late Set<String> _availableDateKeys;
  String? _notice;
  VoidCallback? _noticeUndo;
  Timer? _noticeTimer;
  int _visibleCount = _pageSize;
  int? _pendingDeleteId;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _entries = List<Moment>.from(widget.entries);
    _availableDateKeys = _entries.map((entry) => entry.date).toSet();
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _showNotice(String text, {VoidCallback? onUndo}) {
    _noticeTimer?.cancel();
    setState(() {
      _notice = text;
      _noticeUndo = onUndo;
    });
    _noticeTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _notice = null;
          _noticeUndo = null;
        });
      }
    });
  }

  List<Moment> get _allRows {
    final today = _dateKey(DateTime.now());
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _entries.where((e) {
      if (_filter == 'today') return e.date == today;
      if (_filter == 'week') {
        return DateTime.fromMillisecondsSinceEpoch(
          e.timestamp,
        ).isAfter(weekAgo);
      }
      if (_filter == 'date') return e.date == _selectedDateKey;
      if (_filter == 'in') return e.type == 'in';
      if (_filter == 'out') return e.type == 'out';
      if (_filter == 'single') return e.type == 'single';
      if (_filter == 'notes') return e.note.isNotEmpty;
      return true;
    }).toList();
  }

  List<Moment> get _rows => _allRows.take(_visibleCount).toList();

  List<_HistoryListItem> get _items {
    final items = <_HistoryListItem>[];
    String? lastLabel;
    for (final row in _rows) {
      final label = _historySectionLabel(row.timestamp);
      if (label != lastLabel) {
        items.add(_HistoryListItem.header(label));
        lastLabel = label;
      }
      items.add(_HistoryListItem.moment(row));
    }
    return items;
  }

  bool get _hasOlderRows => _visibleCount < _allRows.length;

  String get _emptyMessage {
    return switch (_filter) {
      'today' => 'No moments today.\nTap the screen to save your first one.',
      'week' => 'No moments this week.\nYour recent logs will appear here.',
      'date' => 'No moments on this date.\nChoose another day with a dot.',
      'in' => 'No IN moments yet.\nTwo-Way mode will create them.',
      'out' => 'No OUT moments yet.\nFinish a Two-Way pair to see one.',
      'single' =>
        'No Single moments yet.\nSwitch mode when you need one-shot logs.',
      'notes' => 'No notes yet.\nLong press the screen to save a note.',
      _ => 'No moments yet.\nTap to save a moment. Long press to add a note.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final sheet = AppSheet(
      p: widget.p,
      title: 'History',
      docked: true,
      child: SizedBox(
        width: 430,
        height: math.min(MediaQuery.sizeOf(context).height * 0.64, 560),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final f in const [
                          'all',
                          'date',
                          'today',
                          'week',
                          'in',
                          'out',
                          'single',
                          'notes',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChipButton(
                              p: widget.p,
                              label: f == 'single'
                                  ? null
                                  : f == 'date' && _selectedDateKey != null
                                  ? _compactDateLabel(_selectedDateKey!)
                                  : f == 'date'
                                  ? 'Select Date'
                                  : _filterLabel(f),
                              icon: f == 'single'
                                  ? Icons.arrow_upward_rounded
                                  : null,
                              active: _filter == f,
                              onTap: f == 'date'
                                  ? _openDateFilter
                                  : () => setState(() {
                                      _filter = f;
                                      _visibleCount = _pageSize;
                                    }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PressableScale(
                  onTap: () {
                    if (!_scrollController.hasClients) return;
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.fastEaseInToSlowEaseOut,
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.p.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.p.border),
                    ),
                    child: Icon(
                      Icons.keyboard_double_arrow_up_rounded,
                      color: widget.p.text2,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: _selected.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.p.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: widget.p.accent.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Text(
                          'Selected ${_selected.length} of 2 for duration',
                          style: TextStyle(
                            color: widget.p.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _rows.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _emptyMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: widget.p.text2,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: widget.p.accent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Start Logging'),
                          ),
                        ],
                      ),
                    )
                  : Builder(
                      builder: (_) {
                        final items = _items;
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: items.length + (_hasOlderRows ? 1 : 0),
                          itemBuilder: (_, index) {
                            if (index >= items.length) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  bottom: 8,
                                ),
                                child: PressableScale(
                                  onTap: () => setState(() {
                                    _visibleCount += _pageSize;
                                  }),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.p.surface2,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: widget.p.border,
                                      ),
                                    ),
                                    child: Text(
                                      'Load older moments',
                                      style: TextStyle(
                                        color: widget.p.accent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            final item = items[index];
                            if (item.label != null) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                                child: Text(
                                  item.label!,
                                  style: TextStyle(
                                    color: widget.p.text3,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              );
                            }
                            final entry = item.moment!;
                            final selected = _selected.any(
                              (item) => item.id == entry.id,
                            );
                            return Padding(
                              key: ValueKey(entry.id),
                              padding: EdgeInsets.only(
                                bottom: widget.compactRows ? 3 : 8,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.p.red,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Dismissible(
                                  key: ValueKey('dismiss-${entry.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 18),
                                    color: widget.p.red,
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (_) async {
                                    _removeEntry(entry);
                                    return false;
                                  },
                                  onDismissed: (_) => _dismissEntry(entry),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? widget.p.surface3
                                          : widget.p.surface2,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: RepaintBoundary(
                                      child: MomentTile(
                                        p: widget.p,
                                        entry: entry,
                                        selected: selected,
                                        compact: widget.compactRows,
                                        onLongPress: () =>
                                            _showMomentDetails(entry),
                                        onTap: () {
                                          setState(() {
                                            if (selected) {
                                              _selected.removeWhere(
                                                (item) => item.id == entry.id,
                                              );
                                            } else {
                                              if (_selected.length == 2) {
                                                _selected.removeAt(0);
                                              }
                                              _selected.add(entry);
                                            }
                                          });
                                          if (_selected.length == 2) {
                                            widget.onDuration(
                                              _selected[0],
                                              _selected[1],
                                            );
                                            setState(() => _selected.clear());
                                          }
                                        },
                                        onDelete: () => _removeEntry(entry),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: _notice == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: MediaQuery.paddingOf(context).bottom + 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _NoticePill(
                            p: widget.p,
                            label: _notice!,
                            color: _noticeUndo == null
                                ? widget.p.red
                                : widget.p.accent,
                          ),
                          if (_noticeUndo != null) ...[
                            const SizedBox(width: 8),
                            _NoticePill(
                              p: widget.p,
                              label: 'Undo',
                              color: widget.p.accent,
                              onTap: _noticeUndo,
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
    if (!widget.largeText) return sheet;
    return MediaQuery(data: _largerTextQuery(context), child: sheet);
  }

  void _removeEntry(Moment entry) {
    if (widget.confirmDelete && _pendingDeleteId != entry.id) {
      setState(() => _pendingDeleteId = entry.id);
      _showNotice('Tap delete again to confirm');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _entries = _entries.where((item) => item.id != entry.id).toList();
      _availableDateKeys = _entries.map((item) => item.date).toSet();
      _selected.removeWhere((item) => item.id == entry.id);
      _pendingDeleteId = null;
    });
    _showNotice('Moment removed', onUndo: () => _restoreRemovedEntry(entry));
    unawaited(widget.onDelete(entry.id));
  }

  Future<void> _openDateFilter() async {
    if (_entries.isEmpty) {
      _showNotice('No moments to pick from');
      return;
    }
    final latest = _selectedDateKey == null
        ? DateTime.fromMillisecondsSinceEpoch(_entries.first.timestamp)
        : _dateFromKey(_selectedDateKey!);
    final picked = await showGeneralDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close calendar',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => MomentCalendarDialog(
        p: widget.p,
        availableDateKeys: _availableDateKeys,
        initialDate: latest,
      ),
    );
    if (picked == null) return;
    setState(() {
      _selectedDateKey = _dateKey(picked);
      _filter = 'date';
      _visibleCount = _pageSize;
    });
  }

  void _dismissEntry(Moment entry) {
    HapticFeedback.mediumImpact();
    setState(() {
      _entries = _entries.where((item) => item.id != entry.id).toList();
      _availableDateKeys = _entries.map((item) => item.date).toSet();
      _selected.removeWhere((item) => item.id == entry.id);
      _pendingDeleteId = null;
    });
    _showNotice('Moment removed', onUndo: () => _restoreRemovedEntry(entry));
    unawaited(widget.onDelete(entry.id));
  }

  void _restoreRemovedEntry(Moment entry) {
    _noticeTimer?.cancel();
    setState(() {
      if (!_entries.any((item) => item.id == entry.id)) {
        _entries = [entry, ..._entries]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _availableDateKeys = _entries.map((item) => item.date).toSet();
      }
      _notice = null;
      _noticeUndo = null;
      _pendingDeleteId = null;
    });
    unawaited(widget.onRestore(entry));
  }

  Future<void> _updateEntryNote(Moment entry, String note) async {
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index < 0) return;

    final updated = Moment(
      id: entry.id,
      timestamp: entry.timestamp,
      type: entry.type,
      date: entry.date,
      note: note.trim(),
    );

    setState(() {
      _entries[index] = updated;

      final selectedIndex = _selected.indexWhere((item) => item.id == entry.id);

      if (selectedIndex >= 0) {
        _selected[selectedIndex] = updated;
      }
    });

    await widget.onUpdateNote(entry.id, updated.note);
  }

  Future<void> _showMomentDetails(Moment entry) async {
    HapticFeedback.selectionClick();

    await showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close moment actions',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => MomentActionsDialog(
        p: widget.p,
        entry: entry,
        confirmDelete: widget.confirmDelete,
        onAddOrEditNote: () async {
          Navigator.pop(context);

          final note = await showGeneralDialog<String>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.42),
            barrierDismissible: true,
            barrierLabel: 'Close note editor',
            transitionDuration: const Duration(milliseconds: 120),
            pageBuilder: (_, _, _) => NoteDialog(
              p: widget.p,
              initialNote: entry.note,
              title: entry.note.trim().isEmpty ? 'Add Note' : 'Edit Note',
              saveLabel: entry.note.trim().isEmpty ? 'Add Note' : 'Save',
              allowEmpty: false,
            ),
          );

          if (note == null) return;

          await _updateEntryNote(entry, note);
          _showNotice(
            entry.note.trim().isEmpty ? 'Note added' : 'Note updated',
          );
        },
        onDeleteNote: entry.note.trim().isEmpty
            ? null
            : () async {
                Navigator.pop(context);
                final previous = entry.note;
                await _updateEntryNote(entry, '');
                _showNotice(
                  'Note deleted',
                  onUndo: () {
                    unawaited(_updateEntryNote(entry, previous));
                    _showNotice('Note restored');
                  },
                );
              },
        onDeleteMoment: () {
          Navigator.pop(context);
          _removeEntry(entry);
        },
      ),
    );
  }
}

class MomentActionsDialog extends StatefulWidget {
  const MomentActionsDialog({
    super.key,
    required this.p,
    required this.entry,
    required this.confirmDelete,
    required this.onAddOrEditNote,
    required this.onDeleteMoment,
    this.onDeleteNote,
  });

  final Palette p;
  final Moment entry;
  final bool confirmDelete;
  final VoidCallback onAddOrEditNote;
  final VoidCallback? onDeleteNote;
  final VoidCallback onDeleteMoment;

  @override
  State<MomentActionsDialog> createState() => _MomentActionsDialogState();
}

class _MomentActionsDialogState extends State<MomentActionsDialog> {
  String? _pendingAction;

  void _confirmOrRun(String action, VoidCallback callback) {
    if (!widget.confirmDelete || _pendingAction == action) {
      callback();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _pendingAction = action);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final entry = widget.entry;
    final hasNote = entry.note.trim().isNotEmpty;

    return AppSheet(
      p: p,
      title: 'Moment Options',
      child: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SettingsStatusPill(
                  p: p,
                  label: entry.type.toUpperCase(),
                  color: _momentColor(p, entry.type),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_datePretty(entry.timestamp)} at '
                    '${_timeOnly(entry.timestamp)}',
                    style: TextStyle(color: p.text2, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (hasNote) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    entry.note,
                    style: TextStyle(color: p.text, height: 1.45),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: MomentOptionPill(
                    p: p,
                    icon: hasNote
                        ? Icons.edit_note_rounded
                        : Icons.note_add_rounded,
                    label: hasNote ? 'Edit Note' : 'Add Note',
                    color: p.accent,
                    onTap: widget.onAddOrEditNote,
                  ),
                ),
                if (widget.onDeleteNote != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: MomentOptionPill(
                      p: p,
                      icon: Icons.comments_disabled_rounded,
                      label: _pendingAction == 'note'
                          ? 'Confirm'
                          : 'Delete Note',
                      color: p.orange,
                      onTap: () => _confirmOrRun('note', widget.onDeleteNote!),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            MomentOptionPill(
              p: p,
              icon: Icons.delete_outline_rounded,
              label: _pendingAction == 'moment' ? 'Confirm' : 'Delete Moment',
              color: p.red,
              fullWidth: true,
              onTap: () => _confirmOrRun('moment', widget.onDeleteMoment),
            ),
          ],
        ),
      ),
    );
  }
}

class MomentOptionPill extends StatelessWidget {
  const MomentOptionPill({
    super.key,
    required this.p,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  final Palette p;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteSearchDialog extends StatefulWidget {
  const NoteSearchDialog({
    super.key,
    required this.p,
    required this.entries,
    required this.compactRows,
  });

  final Palette p;
  final List<Moment> entries;
  final bool compactRows;

  @override
  State<NoteSearchDialog> createState() => _NoteSearchDialogState();
}

class _NoteSearchDialogState extends State<NoteSearchDialog> {
  @override
  Widget build(BuildContext context) {
    return AppSheet(
      p: widget.p,
      title: 'Search Notes',
      child: SizedBox(
        width: 430,
        height: math.min(MediaQuery.sizeOf(context).height * 0.68, 590),
        child: NoteSearchContent(
          p: widget.p,
          entries: widget.entries,
          compactRows: widget.compactRows,
        ),
      ),
    );
  }
}

class NoteSearchContent extends StatefulWidget {
  const NoteSearchContent({
    super.key,
    required this.p,
    required this.entries,
    required this.compactRows,
    this.height,
  });

  final Palette p;
  final List<Moment> entries;
  final bool compactRows;
  final double? height;

  @override
  State<NoteSearchContent> createState() => _NoteSearchContentState();
}

class _NoteSearchRow {
  const _NoteSearchRow({required this.entry, required this.searchText});

  final Moment entry;
  final String searchText;
}

class _NoteSearchContentState extends State<NoteSearchContent> {
  static const _pageSize = 100;
  final _controller = TextEditingController();
  int _visibleCount = _pageSize;
  String _query = '';
  late List<_NoteSearchRow> _searchRows;

  @override
  void initState() {
    super.initState();
    _searchRows = _buildSearchRows(widget.entries);
  }

  @override
  void didUpdateWidget(covariant NoteSearchContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.entries, widget.entries)) {
      _searchRows = _buildSearchRows(widget.entries);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Moment> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _searchRows.map((row) => row.entry).toList();
    return _searchRows
        .where((row) => row.searchText.contains(q))
        .map((row) => row.entry)
        .toList();
  }

  List<_NoteSearchRow> _buildSearchRows(List<Moment> entries) {
    return entries
        .where((entry) => entry.note.trim().isNotEmpty)
        .map(
          (entry) => _NoteSearchRow(
            entry: entry,
            searchText:
                '${entry.note} ${_datePretty(entry.timestamp)} '
                        '${_timeOnly(entry.timestamp)} ${entry.type}'
                    .toLowerCase(),
          ),
        )
        .toList();
  }

  List<Moment> get _visibleRows => _matches.take(_visibleCount).toList();

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;
    final hasOlderRows = _visibleCount < _matches.length;

    final content = Column(
      children: [
        SearchNotesBox(
          p: widget.p,
          controller: _controller,
          onChanged: (value) => setState(() {
            _query = value;
            _visibleCount = _pageSize;
          }),
          onClear: () => setState(() {
            _controller.clear();
            _query = '';
            _visibleCount = _pageSize;
          }),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    _query.trim().isEmpty
                        ? 'No notes yet.'
                        : 'No notes match your search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: widget.p.text2, height: 1.4),
                  ),
                )
              : ListView.builder(
                  itemCount: rows.length + (hasOlderRows ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index >= rows.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: PressableScale(
                          onTap: () => setState(() {
                            _visibleCount += _pageSize;
                          }),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: widget.p.surface2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: widget.p.border),
                            ),
                            child: Text(
                              'Load older notes',
                              style: TextStyle(
                                color: widget.p.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final entry = rows[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: widget.compactRows ? 5 : 9,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: widget.p.surface2,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: widget.p.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SettingsStatusPill(
                                  p: widget.p,
                                  label: entry.type.toUpperCase(),
                                  color: _momentColor(widget.p, entry.type),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_datePretty(entry.timestamp)} at '
                                    '${_timeOnly(entry.timestamp)}',
                                    style: TextStyle(
                                      color: widget.p.text3,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Text(
                              entry.note,
                              style: TextStyle(
                                color: widget.p.text,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
    if (widget.height == null) return content;
    return SizedBox(height: widget.height, child: content);
  }
}

class SearchNotesBox extends StatelessWidget {
  const SearchNotesBox({
    super.key,
    required this.p,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final Palette p;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        style: TextStyle(color: p.text, fontSize: 14),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: p.text3, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, color: p.text3, size: 18),
                ),
          hintText: 'Search notes',
          hintStyle: TextStyle(color: p.text3),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

class BackupImportPreviewDialog extends StatelessWidget {
  const BackupImportPreviewDialog({
    super.key,
    required this.p,
    required this.summary,
  });

  final Palette p;
  final BackupDryRunSummary summary;

  @override
  Widget build(BuildContext context) {
    final exported = summary.exportedAt == null
        ? 'Unknown date'
        : _datePretty(summary.exportedAt!.millisecondsSinceEpoch);

    return AppSheet(
      p: p,
      title: 'Review Backup',
      child: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsGroup(
              p: p,
              children: [
                BackupPreviewRow(
                  p: p,
                  label: 'Backup contains',
                  value:
                      '${summary.backupMoments} moments - ${summary.backupNotes} notes',
                  icon: Icons.backup_rounded,
                  color: p.accent,
                ),
                BackupPreviewRow(
                  p: p,
                  label: 'Exported',
                  value: exported,
                  icon: Icons.calendar_month_rounded,
                  color: p.green,
                ),
                BackupPreviewRow(
                  p: p,
                  label: 'New moments',
                  value: '${summary.newMoments}',
                  icon: Icons.add_circle_outline_rounded,
                  color: p.accent,
                ),
                BackupPreviewRow(
                  p: p,
                  label: 'Duplicates skipped',
                  value: '${summary.duplicatesSkipped}',
                  icon: Icons.filter_alt_off_rounded,
                  color: p.orange,
                ),
                BackupPreviewRow(
                  p: p,
                  label: 'Settings to restore',
                  value: '${summary.settingsToRestore}',
                  icon: Icons.tune_rounded,
                  color: p.green,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Import merges new moments into this device. Existing moments stay in place.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed:
                        summary.newMoments == 0 &&
                            summary.settingsToRestore == 0
                        ? null
                        : () => Navigator.pop(context, true),
                    child: const Text('Import'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BackupPreviewRow extends StatelessWidget {
  const BackupPreviewRow({
    super.key,
    required this.p,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final Palette p;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: p.text2,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MomentCalendarDialog extends StatefulWidget {
  const MomentCalendarDialog({
    super.key,
    required this.p,
    required this.availableDateKeys,
    required this.initialDate,
  });

  final Palette p;
  final Set<String> availableDateKeys;
  final DateTime initialDate;

  @override
  State<MomentCalendarDialog> createState() => _MomentCalendarDialogState();
}

class _MomentCalendarDialogState extends State<MomentCalendarDialog> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_month.year, _month.month);
    final leading = first.weekday % 7;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final cells = leading + days;
    final rowCount = (cells / 7).ceil();

    return AppSheet(
      p: widget.p,
      title: 'Select Date',
      child: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month - 1);
                  }),
                  icon: Icon(Icons.chevron_left_rounded, color: widget.p.text2),
                ),
                Expanded(
                  child: Text(
                    _monthLabel(_month),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.p.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month + 1);
                  }),
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: widget.p.text2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final label in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.p.text3,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: rowCount * 46,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: 46,
                ),
                itemCount: rowCount * 7,
                itemBuilder: (_, index) {
                  final day = index - leading + 1;
                  if (day < 1 || day > days) return const SizedBox.shrink();
                  final date = DateTime(_month.year, _month.month, day);
                  final key = _dateKey(date);
                  final available = widget.availableDateKeys.contains(key);
                  final selected = key == _dateKey(widget.initialDate);
                  return Padding(
                    padding: const EdgeInsets.all(3),
                    child: PressableScale(
                      enabled: available,
                      onTap: available
                          ? () => Navigator.pop(context, date)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: available
                              ? widget.p.surface2
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: available
                                ? widget.p.border
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                color: selected
                                    ? widget.p.accent
                                    : available
                                    ? widget.p.text
                                    : widget.p.text3.withValues(alpha: 0.42),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: available
                                    ? widget.p.accent
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.p,
    required this.theme,
    required this.defaultMode,
    required this.tapDelay,
    required this.accentColor,
    required this.appIconStyle,
    required this.hapticStyle,
    required this.historyDensity,
    required this.privacyLock,
    required this.backupReminderDays,
    required this.lastBackupAt,
    required this.remoteNotices,
    required this.reduceMotion,
    required this.largeText,
    required this.highContrast,
    required this.compactHistory,
    required this.confirmDelete,
    required this.showSeconds,
    required this.highlightSeconds,
    required this.buttonLabels,
    required this.largeControls,
    required this.homeMenuPill,
    required this.homeMenuAnimations,
    required this.showHistoryText,
    required this.showLastSavedHint,
    required this.requireLongPressNote,
    required this.privacyLockDelayMinutes,
    required this.updateStatus,
    required this.checkingUpdates,
    required this.lastUpdateCheckedAt,
    required this.entries,
    required this.lastSavedAt,
    required this.onTheme,
    required this.onDefaultMode,
    required this.onDelay,
    required this.onAccentColor,
    required this.onAppIconStyle,
    required this.onHapticStyle,
    required this.onHistoryDensity,
    required this.onPrivacyLock,
    required this.onBackupReminderDays,
    required this.onRemoteNotices,
    required this.onReduceMotion,
    required this.onLargeText,
    required this.onHighContrast,
    required this.onCompactHistory,
    required this.onConfirmDelete,
    required this.onShowSeconds,
    required this.onHighlightSeconds,
    required this.onButtonLabels,
    required this.onLargeControls,
    required this.onHomeMenuPill,
    required this.onHomeMenuAnimations,
    required this.onShowHistoryText,
    required this.onShowLastSavedHint,
    required this.onRequireLongPressNote,
    required this.onPrivacyLockDelay,
    required this.onExportCsv,
    required this.onExportRecentCsv,
    required this.onExportJson,
    required this.onExportBackup,
    required this.onImportBackup,
    required this.onCheckUpdates,
    required this.onOpenLink,
    required this.onShowChangelog,
    required this.onReset,
    required this.onFactoryReset,
    required this.onResetSettings,
    required this.onRestoreSettings,
    required this.onFeedback,
  });

  final Palette p;
  final String theme;
  final String defaultMode;
  final int tapDelay;
  final String accentColor;
  final String appIconStyle;
  final String hapticStyle;
  final String historyDensity;
  final bool privacyLock;
  final int backupReminderDays;
  final int? lastBackupAt;
  final bool remoteNotices;
  final bool reduceMotion;
  final bool largeText;
  final bool highContrast;
  final bool compactHistory;
  final bool confirmDelete;
  final bool showSeconds;
  final bool highlightSeconds;
  final bool buttonLabels;
  final bool largeControls;
  final bool homeMenuPill;
  final bool homeMenuAnimations;
  final bool showHistoryText;
  final bool showLastSavedHint;
  final bool requireLongPressNote;
  final int privacyLockDelayMinutes;
  final String updateStatus;
  final bool checkingUpdates;
  final int? lastUpdateCheckedAt;
  final List<Moment> entries;
  final int? lastSavedAt;
  final ValueChanged<String> onTheme;
  final ValueChanged<String> onDefaultMode;
  final ValueChanged<int> onDelay;
  final ValueChanged<String> onAccentColor;
  final Future<void> Function(String value) onAppIconStyle;
  final ValueChanged<String> onHapticStyle;
  final ValueChanged<String> onHistoryDensity;
  final Future<bool> Function(bool value) onPrivacyLock;
  final ValueChanged<int> onBackupReminderDays;
  final ValueChanged<bool> onRemoteNotices;
  final ValueChanged<bool> onReduceMotion;
  final ValueChanged<bool> onLargeText;
  final ValueChanged<bool> onHighContrast;
  final ValueChanged<bool> onCompactHistory;
  final ValueChanged<bool> onConfirmDelete;
  final ValueChanged<bool> onShowSeconds;
  final ValueChanged<bool> onHighlightSeconds;
  final ValueChanged<bool> onButtonLabels;
  final ValueChanged<bool> onLargeControls;
  final ValueChanged<bool> onHomeMenuPill;
  final Future<bool> Function(bool) onHomeMenuAnimations;
  final ValueChanged<bool> onShowHistoryText;
  final ValueChanged<bool> onShowLastSavedHint;
  final ValueChanged<bool> onRequireLongPressNote;
  final ValueChanged<int> onPrivacyLockDelay;
  final Future<void> Function() onExportCsv;
  final Future<void> Function() onExportRecentCsv;
  final Future<void> Function() onExportJson;
  final Future<void> Function() onExportBackup;
  final Future<void> Function() onImportBackup;
  final Future<String> Function() onCheckUpdates;
  final ValueChanged<String> onOpenLink;
  final ValueChanged<bool> onShowChangelog;
  final Future<void> Function() onReset;
  final Future<void> Function() onFactoryReset;
  final Future<void> Function() onResetSettings;
  final Future<void> Function(Map<String, Object> snapshot) onRestoreSettings;
  final ValueChanged<String> onFeedback;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late String theme;
  late String defaultMode;
  late int tapDelay;
  late String accentColor;
  late String appIconStyle;
  late String hapticStyle;
  late String historyDensity;
  late bool privacyLock;
  late int backupReminderDays;
  late bool remoteNotices;
  late bool reduceMotion;
  late bool largeText;
  late bool highContrast;
  late bool compactHistory;
  late bool confirmDelete;
  late bool showSeconds;
  late bool highlightSeconds;
  late bool buttonLabels;
  late bool largeControls;
  late bool homeMenuPill;
  late bool homeMenuAnimations;
  late bool showHistoryText;
  late bool showLastSavedHint;
  late bool requireLongPressNote;
  late int privacyLockDelayMinutes;
  late String updateStatus;
  late bool checkingUpdates;
  final List<String> _categoryStack = [];
  String? exportState;
  Timer? _exportStateTimer;
  final _settingsSearchController = TextEditingController();
  final _settingsScrollController = ScrollController();
  String _settingsQuery = '';
  List<
    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
    })
  >?
  _settingsSearchRowsCache;

  @override
  void initState() {
    super.initState();
    theme = widget.theme;
    defaultMode = widget.defaultMode;
    tapDelay = widget.tapDelay;
    accentColor = widget.accentColor;
    appIconStyle = widget.appIconStyle;
    hapticStyle = widget.hapticStyle;
    historyDensity = widget.historyDensity;
    privacyLock = widget.privacyLock;
    backupReminderDays = widget.backupReminderDays;
    remoteNotices = widget.remoteNotices;
    reduceMotion = widget.reduceMotion;
    largeText = widget.largeText;
    highContrast = widget.highContrast;
    compactHistory = widget.compactHistory;
    confirmDelete = widget.confirmDelete;
    showSeconds = widget.showSeconds;
    highlightSeconds = widget.highlightSeconds;
    buttonLabels = widget.buttonLabels;
    largeControls = widget.largeControls;
    homeMenuPill = widget.homeMenuPill;
    homeMenuAnimations = widget.homeMenuAnimations;
    showHistoryText = widget.showHistoryText;
    showLastSavedHint = widget.showLastSavedHint;
    requireLongPressNote = widget.requireLongPressNote;
    privacyLockDelayMinutes = widget.privacyLockDelayMinutes;
    updateStatus = widget.updateStatus;
    checkingUpdates = widget.checkingUpdates;
  }

  @override
  void dispose() {
    _exportStateTimer?.cancel();
    _settingsSearchController.dispose();
    _settingsScrollController.dispose();
    super.dispose();
  }

  Map<String, Object> _settingsSnapshot() => {
    'theme': theme,
    'defaultMode': defaultMode,
    'tapDelay': tapDelay,
    'accentColor': accentColor,
    'appIconStyle': appIconStyle,
    'hapticStyle': hapticStyle,
    'historyDensity': historyDensity,
    'privacyLock': privacyLock,
    'backupReminderDays': backupReminderDays,
    'remoteNotices': remoteNotices,
    'reduceMotion': reduceMotion,
    'largeText': largeText,
    'highContrast': highContrast,
    'compactHistory': compactHistory,
    'confirmDelete': confirmDelete,
    'showSeconds': showSeconds,
    'highlightSeconds': highlightSeconds,
    'buttonLabels': buttonLabels,
    'largeControls': largeControls,
    'homeMenuPill': homeMenuPill,
    'homeMenuAnimations': homeMenuAnimations,
    'showHistoryText': showHistoryText,
    'showLastSavedHint': showLastSavedHint,
    'requireLongPressNote': requireLongPressNote,
    'privacyLockDelayMinutes': privacyLockDelayMinutes,
  };

  String? get category => _categoryStack.isEmpty ? null : _categoryStack.last;

  String get _backLabel {
    if (_categoryStack.length >= 2) {
      return _categoryStack[_categoryStack.length - 2];
    }
    return 'Settings';
  }

  void _jumpSettingsTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_settingsScrollController.hasClients) return;
      _settingsScrollController.jumpTo(0);
    });
  }

  void _openCategory(String next, {String? parent}) {
    setState(() {
      if (parent != null && _categoryStack.lastOrNull != parent) {
        _categoryStack
          ..clear()
          ..add(parent);
      }
      if (_categoryStack.lastOrNull != next) _categoryStack.add(next);
      _settingsQuery = '';
      _settingsSearchController.clear();
    });
    _jumpSettingsTop();
  }

  bool _popCategory() {
    if (_categoryStack.isEmpty) return false;
    setState(() => _categoryStack.removeLast());
    _jumpSettingsTop();
    return true;
  }

  Future<void> _runExport(String label, Future<void> Function() action) async {
    _exportStateTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() => exportState = '$label exporting...');
    await action();
    if (!mounted) return;
    setState(() => exportState = '$label exported');
    _exportStateTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => exportState = null);
    });
  }

  Future<void> _runImport() async {
    _exportStateTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() => exportState = 'Import opening...');
    try {
      await widget.onImportBackup();
      if (!mounted) return;
      setState(() => exportState = 'Import complete');
    } catch (_) {
      if (!mounted) return;
      setState(() => exportState = 'Import failed');
    }
    _exportStateTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => exportState = null);
    });
  }

  Future<void> _confirmResetSettings() async {
    final snapshot = _settingsSnapshot();
    final yes = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close reset settings',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => AppSheet(
        p: _paletteFor(
          theme,
          highContrast: highContrast,
          accentName: accentColor,
        ),
        title: 'Reset Settings',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Restore NoteKar preferences to their defaults. Your moments, notes, backups, and exports stay untouched.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _paletteFor(
                  theme,
                  highContrast: highContrast,
                  accentName: accentColor,
                ).text2,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (yes == true) {
      await widget.onResetSettings();
      if (!mounted) return;
      setState(() {
        theme = 'dark';
        defaultMode = 'two-way';
        tapDelay = 0;
        accentColor = 'blue';
        appIconStyle = 'default';
        hapticStyle = 'standard';
        historyDensity = 'comfortable';
        privacyLock = false;
        backupReminderDays = 0;
        remoteNotices = false;
        reduceMotion = false;
        largeText = false;
        highContrast = false;
        compactHistory = false;
        confirmDelete = false;
        showSeconds = true;
        highlightSeconds = true;
        buttonLabels = false;
        largeControls = false;
        homeMenuPill = true;
        homeMenuAnimations = false;
        showHistoryText = true;
        showLastSavedHint = true;
        requireLongPressNote = false;
        privacyLockDelayMinutes = 0;
      });
      await _showResetSettingsUndo(snapshot);
    }
  }

  Future<void> _showResetSettingsUndo(Map<String, Object> snapshot) async {
    final p = _paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );
    final undo = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      barrierDismissible: true,
      barrierLabel: 'Close settings reset',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => AppSheet(
        p: p,
        title: 'Settings Reset',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your preferences are back to the default setup. Moments and notes were not changed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Undo'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (undo == true) {
      await widget.onRestoreSettings(snapshot);
      if (!mounted) return;
      setState(() {
        theme = snapshot['theme'] as String;
        defaultMode = snapshot['defaultMode'] as String;
        tapDelay = snapshot['tapDelay'] as int;
        accentColor = snapshot['accentColor'] as String;
        appIconStyle = snapshot['appIconStyle'] as String;
        hapticStyle = snapshot['hapticStyle'] as String;
        historyDensity = snapshot['historyDensity'] as String;
        privacyLock = snapshot['privacyLock'] as bool;
        backupReminderDays = snapshot['backupReminderDays'] as int;
        remoteNotices = snapshot['remoteNotices'] as bool;
        reduceMotion = snapshot['reduceMotion'] as bool;
        largeText = snapshot['largeText'] as bool;
        highContrast = snapshot['highContrast'] as bool;
        compactHistory = snapshot['compactHistory'] as bool;
        confirmDelete = snapshot['confirmDelete'] as bool;
        showSeconds = snapshot['showSeconds'] as bool;
        highlightSeconds = snapshot['highlightSeconds'] as bool;
        buttonLabels = snapshot['buttonLabels'] as bool;
        largeControls = snapshot['largeControls'] as bool;
        homeMenuPill = snapshot['homeMenuPill'] as bool;
        homeMenuAnimations = snapshot['homeMenuAnimations'] as bool;
        showHistoryText = snapshot['showHistoryText'] as bool;
        showLastSavedHint = snapshot['showLastSavedHint'] as bool;
        requireLongPressNote = snapshot['requireLongPressNote'] as bool;
        privacyLockDelayMinutes = snapshot['privacyLockDelayMinutes'] as int;
      });
    }
  }

  String? get _availableVersion {
    final match = RegExp(
      r'v?(\d+(?:\.\d+){0,2}(?:\+\d+)?)',
    ).allMatches(updateStatus).lastOrNull;
    return match?.group(1);
  }

  bool get _updateAvailable {
    if (!updateStatus.toLowerCase().contains('available')) return false;
    final version = _availableVersion;
    if (version == null) return false;
    return _isNewerVersion(version, _NoteKarHomeState._appVersion);
  }

  bool get _upToDate => updateStatus.toLowerCase().contains('up to date');

  String get _updateTitle => _updateAvailable
      ? 'Install Update'
      : _upToDate
      ? "You're Up to Date"
      : 'Check for Update';

  String get _updateSubtitle {
    if (_updateAvailable) return 'Install latest builds from GitHub';
    if (checkingUpdates) return 'Checking GitHub Releases...';
    if (_upToDate) return 'NoteKar is already on the latest build.';
    return 'Current version v${_NoteKarHomeState._appVersion}';
  }

  String get _backupAgeLine {
    if (widget.lastBackupAt == null) return 'not created yet';
    return _relativeAge(widget.lastBackupAt!);
  }

  String get _backupReminderSubtitle {
    if (backupReminderDays == 0) {
      return 'No reminder. Back up whenever you choose.';
    }
    return 'A local reminder appears after $backupReminderDays days without a backup.';
  }

  String get _privacyLockSubtitle {
    if (privacyLock) {
      return 'App Lock is on. NoteKar locks ${_privacyLockDelayLabel(privacyLockDelayMinutes).toLowerCase()} after you leave.';
    }
    return 'Use your Android screen lock before NoteKar opens, with timing controls below.';
  }

  String get _dataHealthStatus {
    if (widget.entries.isEmpty) return 'Empty';
    if (widget.lastBackupAt == null) return 'Backup';
    if (backupReminderDays == 0) return 'Local';
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(widget.lastBackupAt!),
    );
    return age.inDays >= backupReminderDays ? 'Due' : 'Good';
  }

  List<
    ({
      String title,
      String subtitle,
      String category,
      IconData icon,
      List<String> keywords,
    })
  >
  get _settingsSearchResults {
    final query = _settingsQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final rows = _settingsSearchRowsCache ??=
        <
          ({
            String title,
            String subtitle,
            String category,
            IconData icon,
            List<String> keywords,
          })
        >[
          (
            title: 'Display',
            subtitle: 'Theme, clock, toolbar, labels, large controls',
            category: 'Display',
            icon: Icons.color_lens_rounded,
            keywords: [
              'look',
              'ui',
              'color',
              'dark',
              'light',
              'amoled',
              'home',
            ],
          ),
          (
            title: 'Show Seconds',
            subtitle: 'Show or hide seconds on the clock',
            category: 'Display',
            icon: Icons.more_time_rounded,
            keywords: ['clock', 'time', 'second', 'seconds'],
          ),
          (
            title: 'Highlight Seconds',
            subtitle: 'Control whether seconds use a separate clock color',
            category: 'Display',
            icon: Icons.highlight_rounded,
            keywords: ['clock', 'time', 'second', 'seconds', 'highlight'],
          ),
          (
            title: 'Button Labels',
            subtitle: 'Text-only toolbar buttons',
            category: 'Display',
            icon: Icons.label_rounded,
            keywords: ['toolbar', 'buttons', 'text', 'icons'],
          ),
          (
            title: 'Live Icon Motion',
            subtitle: 'Use gentle phone-tilt motion for home icons',
            category: 'Display',
            icon: Icons.motion_photos_auto_rounded,
            keywords: ['toolbar', 'menu', 'animation', 'motion', 'icons'],
          ),
          (
            title: 'Accent Color',
            subtitle: 'Choose the color used for buttons, highlights',
            category: 'Personalization',
            icon: Icons.palette_rounded,
            keywords: [
              'accent',
              'blue',
              'green',
              'purple',
              'pink',
              'orange',
              'graphite',
              'teal',
              'mint',
              'cyan',
              'indigo',
              'violet',
              'lavender',
              'rose',
              'coral',
              'amber',
              'sand',
              'sage',
              'olive',
              'slate',
              'brown',
            ],
          ),
          (
            title: 'App Icons',
            subtitle: 'Default plus black, blue, gold, green, orange, and red',
            category: 'App Icons',
            icon: Icons.apps_rounded,
            keywords: ['icon', 'launcher', 'app icon', 'black', 'gold', 'red'],
          ),
          (
            title: 'Capture',
            subtitle: 'Default mode, tap delay, and note-focused hold',
            category: 'Capture',
            icon: Icons.touch_app_rounded,
            keywords: [
              'tap',
              'save',
              'mode',
              'single',
              'two way',
              'delay',
              'note',
              'long press',
              'hold',
            ],
          ),
          (
            title: 'Moments',
            subtitle: 'History density, confirm delete, moments',
            category: 'Moments',
            icon: Icons.history_rounded,
            keywords: [
              'moments',
              'logs',
              'records',
              'delete',
              'compact',
              'density',
            ],
          ),
          (
            title: 'Updates',
            subtitle: 'Check for update, remote notices, changelog',
            category: 'Updates',
            icon: Icons.system_update_alt_rounded,
            keywords: ['update', 'github', 'release', 'notification', 'notice'],
          ),
          (
            title: "What's New",
            subtitle: 'Latest release highlights',
            category: "What's New",
            icon: Icons.new_releases_rounded,
            keywords: ['new', 'latest', 'release', 'features'],
          ),
          (
            title: 'Changelog',
            subtitle: 'Release history and fixes',
            category: 'Changelog',
            icon: Icons.article_rounded,
            keywords: ['changes', 'release notes', 'version', 'history'],
          ),
          (
            title: 'Backup & Export',
            subtitle: 'CSV, JSON, backup reminder, import, Android backup',
            category: 'Backup & Export',
            icon: Icons.backup_rounded,
            keywords: [
              'csv',
              'json',
              'download',
              'restore',
              'import',
              'file',
              'reminder',
              'health',
            ],
          ),
          (
            title: 'Backup Status',
            subtitle: 'Android backup, health, encryption, and Drive plans',
            category: 'Backup Status',
            icon: Icons.health_and_safety_rounded,
            keywords: [
              'android backup',
              'backup health',
              'data health',
              'encrypted backup',
              'google drive',
              'drive backup',
            ],
          ),
          (
            title: 'Privacy & Security',
            subtitle: 'Local storage, network use, and data safety',
            category: 'Privacy & Security',
            icon: Icons.verified_user_rounded,
            keywords: [
              'private',
              'security',
              'safe',
              'secure',
              'encryption',
              'tracking',
              'analytics',
              'data',
              'policy',
              'drive',
              'google',
              'lock',
              'biometric',
              'password',
              'pin',
            ],
          ),
          (
            title: 'App Lock',
            subtitle: 'Screen lock and lock timing',
            category: 'App Lock',
            icon: Icons.lock_rounded,
            keywords: [
              'privacy lock',
              'app lock',
              'screen lock',
              'biometric',
              'pin',
              'password',
              'lock timing',
            ],
          ),
          (
            title: 'Accessibility',
            subtitle: 'Haptic style, motion, larger text, high contrast',
            category: 'Accessibility',
            icon: Icons.accessibility_new_rounded,
            keywords: [
              'haptic',
              'vibration',
              'motion',
              'text',
              'contrast',
              'large',
              'quick action',
              'shortcut',
            ],
          ),
          (
            title: 'Diagnostics',
            subtitle: 'Version, storage, backup, update status',
            category: 'Diagnostics',
            icon: Icons.monitor_heart_rounded,
            keywords: ['debug', 'support', 'info', 'bug', 'copy'],
          ),
          (
            title: 'Reset All Data',
            subtitle: 'Erase every moment and note',
            category: 'Reset',
            icon: Icons.delete_outline_rounded,
            keywords: ['clear', 'erase', 'delete everything', 'factory reset'],
          ),
          (
            title: 'Factory Reset',
            subtitle: 'Erase data and settings, then show welcome',
            category: 'Reset',
            icon: Icons.restart_alt_rounded,
            keywords: ['fresh start', 'welcome', 'reset app', 'new app'],
          ),
          (
            title: 'Reset Settings Only',
            subtitle: 'Restore preferences and keep moments',
            category: 'Reset',
            icon: Icons.tune_rounded,
            keywords: ['preferences', 'defaults', 'settings reset'],
          ),
          (
            title: 'Guides',
            subtitle: 'Learn taps, notes, history, and backups',
            category: 'Help & Guides',
            icon: Icons.menu_book_rounded,
            keywords: [
              'guide',
              'help',
              'how to',
              'tap',
              'hold',
              'long press',
              'note',
              'history',
              'duration',
              'time between',
              'backup',
            ],
          ),
          (
            title: 'Help',
            subtitle:
                'Fix updates, backups, notices, motion, and common issues',
            category: 'Help',
            icon: Icons.help_outline_rounded,
            keywords: [
              'help',
              'problem',
              'issue',
              'offline',
              'internet',
              'github',
              'update failed',
              'backup',
              'import',
              'notification',
              'notice',
              'sensor',
              'motion',
              'app lock',
              'data missing',
            ],
          ),
        ];
    return rows
        .where(
          (row) =>
              row.title.toLowerCase().contains(query) ||
              row.subtitle.toLowerCase().contains(query) ||
              row.category.toLowerCase().contains(query) ||
              row.keywords.any((keyword) => keyword.contains(query)),
        )
        .toList();
  }

  Widget _diagnosticsPage(Palette p, List<Moment> entries, int todayCount) {
    final latest = entries.isEmpty
        ? 'No moments yet'
        : _relativeAge(
            entries.map((entry) => entry.timestamp).reduce(math.max),
          );
    final lastChecked = widget.lastUpdateCheckedAt == null
        ? 'Not checked yet'
        : _relativeAge(widget.lastUpdateCheckedAt!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          p: p,
          children: [
            DiagnosticRow(
              p: p,
              label: 'App Version',
              value:
                  'v${_NoteKarHomeState._appVersion} (${_NoteKarHomeState._appBuildNumber})',
            ),
            DiagnosticRow(
              p: p,
              label: 'Build Date',
              value: _NoteKarHomeState._appBuildDate,
            ),
            DiagnosticRow(
              p: p,
              label: 'Moments',
              value: '${entries.length} total - $todayCount today',
            ),
            DiagnosticRow(
              p: p,
              label: 'Storage',
              value: 'Saved privately on this device',
            ),
            DiagnosticRow(
              p: p,
              label: 'Android Backup',
              value: 'Enabled for system transfer and Google backup',
            ),
            DiagnosticRow(p: p, label: 'Updates', value: _updateSubtitle),
            DiagnosticRow(p: p, label: 'Last Update Check', value: lastChecked),
            DiagnosticRow(
              p: p,
              label: 'App Notices',
              value: remoteNotices ? 'Enabled' : 'Disabled',
            ),
            DiagnosticRow(p: p, label: 'Last Moment', value: latest),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: p.accent,
            minimumSize: const Size.fromHeight(44),
          ),
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: _diagnosticsText(entries, todayCount, latest),
              ),
            );
            widget.onFeedback('Diagnostics copied');
          },
          child: const Text('Copy Diagnostics'),
        ),
      ],
    );
  }

  String _diagnosticsText(List<Moment> entries, int todayCount, String latest) {
    return [
      'NoteKar diagnostics',
      'Version: v${_NoteKarHomeState._appVersion} (${_NoteKarHomeState._appBuildNumber})',
      'Build date: ${_NoteKarHomeState._appBuildDate}',
      'Moments: ${entries.length} total, $todayCount today',
      'Storage: local offline storage',
      'Android backup: configured',
      'Updates: $_updateSubtitle',
      'Last update check: ${widget.lastUpdateCheckedAt == null ? 'Not checked yet' : _relativeAge(widget.lastUpdateCheckedAt!)}',
      'App notices: ${remoteNotices ? 'Enabled' : 'Disabled'}',
      'Last moment: $latest',
    ].join('\n');
  }

  Widget _appLockPage(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          p: p,
          children: [
            SettingsSwitchRow(
              p: p,
              icon: Icons.lock_rounded,
              title: 'App Lock',
              subtitle: _privacyLockSubtitle,
              color: p.accent,
              value: privacyLock,
              onChanged: (value) async {
                if (!value) {
                  await widget.onPrivacyLock(false);
                  if (mounted) setState(() => privacyLock = false);
                  return;
                }
                final changed = await widget.onPrivacyLock(true);
                if (changed && mounted) {
                  setState(() => privacyLock = true);
                }
              },
            ),
          ],
        ),
        if (privacyLock) ...[
          const SizedBox(height: 10),
          SegmentedSetting(
            key: ValueKey('privacy-delay-$privacyLockDelayMinutes-${p.name}'),
            p: p,
            title: 'When to Lock (minutes)',
            subtitle:
                'Now locks as soon as NoteKar leaves focus. Delays wait in the background.',
            value: '$privacyLockDelayMinutes',
            values: const {'0': 'Now', '1': '1', '5': '5', '10': '10'},
            status: _privacyLockDelayLabel(privacyLockDelayMinutes),
            onChanged: (value) {
              final minutes = int.tryParse(value) ?? 0;
              if (minutes == privacyLockDelayMinutes) return;
              HapticFeedback.selectionClick();
              setState(() => privacyLockDelayMinutes = minutes);
              widget.onPrivacyLockDelay(minutes);
            },
          ),
        ],
        SettingsPageNote(
          p: p,
          text:
              'App Lock uses your Android screen lock. With Now selected, Recents and the notification panel are treated as leaving NoteKar, so the overlay hides your page before you return.',
        ),
      ],
    );
  }

  Widget _appIconsPage(Palette p) {
    const icons = {
      'default': ('Default', 'icon-maskable-512.png'),
      'black': ('Black', 'app_icons/black.png'),
      'blue': ('Blue', 'app_icons/blue.png'),
      'gold': ('Gold', 'app_icons/gold.png'),
      'green': ('Green', 'app_icons/green.png'),
      'orange': ('Orange', 'app_icons/orange.png'),
      'red': ('Red', 'app_icons/red.png'),
    };
    return SettingsGroup(
      p: p,
      showDividers: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.35,
            children: [
              for (final icon in icons.entries)
                AppIconChoice(
                  p: p,
                  label: icon.value.$1,
                  asset: icon.value.$2,
                  active: appIconStyle == icon.key,
                  onTap: () {
                    if (icon.key == appIconStyle) return;
                    HapticFeedback.selectionClick();
                    setState(() => appIconStyle = icon.key);
                    unawaited(widget.onAppIconStyle(icon.key));
                  },
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: SettingsPageNote(
            p: p,
            text:
                'App Icons change the Android launcher icon. Default uses the current colored NoteKar icon.',
          ),
        ),
      ],
    );
  }

  Future<void> _confirmResetAll(Palette p) async {
    final yes = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close reset',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ResetAllConfirmSheet(
        p: p,
        title: 'Reset All Data',
        message:
            'This deletes every saved moment and note from this device. Settings stay the same. Export or create a backup first if you may need this history later. Type RESET to continue.',
      ),
    );
    if (yes == true) {
      await widget.onReset();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _confirmFactoryReset(Palette p) async {
    final yes = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close factory reset',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => ResetAllConfirmSheet(
        p: p,
        title: 'Factory Reset',
        message:
            'This returns NoteKar to a fresh local state by deleting moments, notes, and settings. Export or create a backup first if there is anything you may need later. Type RESET to continue.',
      ),
    );
    if (yes == true) {
      if (mounted) Navigator.pop(context);
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 220), () {
          widget.onFactoryReset();
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _paletteFor(
      theme,
      highContrast: highContrast,
      accentName: accentColor,
    );
    final entries = widget.entries;
    final today = _dateKey(DateTime.now());
    final todayCount = entries.where((e) => e.date == today).length;
    final delayIndex = _NoteKarHomeState._delayValues.indexOf(tapDelay);
    bool show(String name) => category == name;
    final sheet = PopScope(
      canPop: _categoryStack.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _popCategory();
      },
      child: AppSheet(
        p: p,
        title: category ?? 'Settings',
        docked: true,
        child: SizedBox(
          width: 430,
          height: math.min(MediaQuery.sizeOf(context).height * 0.68, 620),
          child: ListView(
            controller: _settingsScrollController,
            children: [
              if (category != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PressableScale(
                    onTap: _popCategory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: p.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chevron_left_rounded,
                            color: p.text,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _backLabel,
                            style: TextStyle(
                              color: p.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (category == null) ...[
                SettingsSearchBox(
                  p: p,
                  controller: _settingsSearchController,
                  onChanged: (value) => setState(() => _settingsQuery = value),
                  onClear: () => setState(() {
                    _settingsQuery = '';
                    _settingsSearchController.clear();
                  }),
                ),
                if (_settingsQuery.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SettingsGroup(
                    p: p,
                    children: [
                      for (final result in _settingsSearchResults)
                        SettingsRow(
                          p: p,
                          icon: result.icon,
                          title: result.title,
                          subtitle: result.subtitle,
                          highlight: _settingsQuery,
                          color:
                              result.title == 'Reset All Data' ||
                                  result.title == 'Factory Reset'
                              ? p.red
                              : p.accent,
                          onTap: () {
                            if (result.title == 'Reset All Data') {
                              unawaited(_confirmResetAll(p));
                              return;
                            }
                            if (result.title == 'Factory Reset') {
                              unawaited(_confirmFactoryReset(p));
                              return;
                            }
                            if (result.title == 'Reset Settings Only') {
                              unawaited(_confirmResetSettings());
                              return;
                            }
                            _openCategory(result.category);
                          },
                        ),
                      if (_settingsSearchResults.isEmpty)
                        SettingsRow(
                          p: p,
                          icon: Icons.search_off_rounded,
                          title: 'No Results',
                          subtitle:
                              'Try theme, backup, delay, privacy, reset, or notes',
                          color: p.text2,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.tune_rounded,
                      title: 'Personalization',
                      subtitle: 'Theme, toolbar, action color, and app icons',
                      color: p.accent,
                      onTap: () => _openCategory('Personalization'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.bolt_rounded,
                      title: 'Logging',
                      subtitle: 'Capture behavior, tap delay, and history',
                      color: p.green,
                      onTap: () => _openCategory('Logging'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.verified_user_rounded,
                      title: 'Privacy & Security',
                      subtitle: 'Local data, network use, and screen lock',
                      color: p.green,
                      onTap: () => _openCategory('Privacy & Security'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.backup_rounded,
                      title: 'Data & Backup',
                      subtitle: 'Export, import, reminders, and data health',
                      color: p.green,
                      onTap: () => _openCategory('Data & Backup'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.system_update_alt_rounded,
                      title: 'Updates',
                      subtitle: _updateSubtitle,
                      color: p.accent,
                      onTap: () => _openCategory('Updates'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.menu_book_rounded,
                      title: 'Help & Guides',
                      subtitle: 'Learn logging, notes, history, and backups',
                      color: p.accent,
                      onTap: () => _openCategory('Help & Guides'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.tune_rounded,
                      title: 'Advanced',
                      subtitle: 'Accessibility, diagnostics, and reset',
                      color: p.orange,
                      onTap: () => _openCategory('Advanced'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SettingsAboutBlock(
                  p: p,
                  onEmailTap: () =>
                      widget.onOpenLink(_NoteKarHomeState._supportEmail),
                  onGitHubTap: () =>
                      widget.onOpenLink(_NoteKarHomeState._githubRepo),
                  onVersionLongPress: () =>
                      widget.onOpenLink(_NoteKarHomeState._officialSite),
                ),
              ],
              if (show('Personalization')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.color_lens_rounded,
                      title: 'Display',
                      subtitle: 'Theme, clock, motion, and toolbar',
                      color: p.accent,
                      onTap: () =>
                          _openCategory('Display', parent: 'Personalization'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.palette_rounded,
                      title: 'Accent Color',
                      subtitle: 'Choose colors for buttons and highlights',
                      color: p.accent,
                      onTap: () => _openCategory(
                        'Accent Color',
                        parent: 'Personalization',
                      ),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.apps_rounded,
                      title: 'App Icons',
                      subtitle: 'Choose the Android launcher icon',
                      color: p.accent,
                      onTap: () =>
                          _openCategory('App Icons', parent: 'Personalization'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Personalization keeps the app feeling yours without changing saved moments.',
                ),
              ],
              if (show('Display')) ...[
                SettingsGroup(
                  p: p,
                  showDividers: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ThemeChoice(
                              p: p,
                              label: 'Dark',
                              active: theme == 'dark',
                              color: Colors.black,
                              onTap: () {
                                if (theme == 'dark') return;
                                HapticFeedback.selectionClick();
                                setState(() => theme = 'dark');
                                widget.onTheme('dark');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ThemeChoice(
                              p: p,
                              label: 'Light',
                              active: theme == 'light',
                              color: const Color(0xFFF2F2F7),
                              onTap: () {
                                if (theme == 'light') return;
                                HapticFeedback.selectionClick();
                                setState(() => theme = 'light');
                                widget.onTheme('light');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ThemeChoice(
                              p: p,
                              label: 'AMOLED',
                              active: theme == 'amoled',
                              color: Colors.black,
                              onTap: () {
                                if (theme == 'amoled') return;
                                HapticFeedback.selectionClick();
                                setState(() => theme = 'amoled');
                                widget.onTheme('amoled');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.more_time_rounded,
                      title: 'Show Seconds',
                      subtitle: 'Show the seconds beside the main time',
                      color: p.accent,
                      value: showSeconds,
                      onChanged: (value) {
                        setState(() => showSeconds = value);
                        widget.onShowSeconds(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.highlight_rounded,
                      title: 'Highlight Seconds',
                      subtitle: 'Use a softer separate color for seconds',
                      color: p.accent,
                      value: showSeconds && highlightSeconds,
                      enabled: showSeconds,
                      disabledMessage: 'Enable Show Seconds first',
                      onDisabledTap: widget.onFeedback,
                      onChanged: (value) {
                        if (!showSeconds) return;
                        setState(() => highlightSeconds = value);
                        widget.onHighlightSeconds(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.label_rounded,
                      title: 'Button Labels',
                      subtitle: 'Use compact text buttons in the toolbar',
                      color: p.green,
                      value: buttonLabels,
                      onChanged: (value) {
                        setState(() => buttonLabels = value);
                        widget.onButtonLabels(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.touch_app_rounded,
                      title: 'Large Controls',
                      subtitle: 'Increase toolbar touch targets',
                      color: p.orange,
                      value: largeControls,
                      onChanged: (value) {
                        setState(() => largeControls = value);
                        widget.onLargeControls(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.blur_on_rounded,
                      title: 'Toolbar Backplate',
                      subtitle:
                          'Keep the floating capsule behind home controls',
                      color: p.accent,
                      value: homeMenuPill,
                      onChanged: (value) {
                        setState(() => homeMenuPill = value);
                        widget.onHomeMenuPill(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.motion_photos_auto_rounded,
                      title: 'Live Icon Motion',
                      subtitle: buttonLabels
                          ? 'Turn off Button Labels to see icon motion'
                          : reduceMotion
                          ? 'Turn off Reduced Motion to use phone-tilt motion'
                          : 'Use gentle phone-tilt motion for home icons',
                      color: p.accent,
                      value: !reduceMotion && homeMenuAnimations,
                      enabled: !reduceMotion,
                      disabledMessage: 'Disable Reduce Motion first',
                      onDisabledTap: widget.onFeedback,
                      onChanged: (value) async {
                        if (reduceMotion) return;

                        final applied = await widget.onHomeMenuAnimations(
                          value,
                        );

                        if (!mounted) return;

                        setState(() {
                          homeMenuAnimations = applied ? value : false;
                        });
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.history_rounded,
                      title: 'History Text',
                      subtitle: 'Show the History label in the home menu',
                      color: p.green,
                      value: showHistoryText,
                      onChanged: (value) {
                        setState(() => showHistoryText = value);
                        widget.onShowHistoryText(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.tips_and_updates_rounded,
                      title: 'Last Saved Hint',
                      subtitle: 'Keep the quick undo hint after each save',
                      color: p.accent,
                      value: showLastSavedHint,
                      onChanged: (value) {
                        setState(() => showLastSavedHint = value);
                        widget.onShowLastSavedHint(value);
                      },
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Display is personal. These choices change the interface only; your saved moments and notes stay exactly where they are.',
                ),
              ],
              if (show('Accent Color')) ...[
                ColorChoiceSetting(
                  p: p,
                  title: 'Accent Color',
                  subtitle:
                      'Choose the color used for buttons, highlights, and saved feedback.',
                  value: accentColor,
                  onChanged: (value) {
                    if (value == accentColor) return;
                    HapticFeedback.selectionClick();
                    setState(() => accentColor = value);
                    widget.onAccentColor(value);
                  },
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Accent Color changes interface highlights only. It does not change or classify saved moments.',
                ),
              ],
              if (show('App Icons')) _appIconsPage(p),
              if (show('Logging')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.touch_app_rounded,
                      title: 'Capture',
                      subtitle: 'Startup mode, tap delay, and notes',
                      color: p.green,
                      onTap: () => _openCategory('Capture', parent: 'Logging'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.history_rounded,
                      title: 'Moments',
                      subtitle: 'History density, delete safety, and totals',
                      color: p.orange,
                      onTap: () => _openCategory('Moments', parent: 'Logging'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Logging controls how moments are captured and how history is reviewed.',
                ),
              ],
              if (show('Capture')) ...[
                SegmentedSetting(
                  key: ValueKey('mode-$defaultMode-${p.name}'),
                  p: p,
                  title: 'Startup Mode',
                  subtitle: 'Choose the mode NoteKar opens with.',
                  value: defaultMode,
                  values: const {'single': 'Single', 'two-way': 'Two-Way'},
                  onChanged: (value) {
                    if (value == defaultMode) return;
                    HapticFeedback.selectionClick();
                    setState(() => defaultMode = value);
                    widget.onDefaultMode(value);
                  },
                ),
                const SizedBox(height: 10),
                Glass(
                  p: p,
                  radius: 12,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tap Delay',
                                  style: TextStyle(
                                    color: p.text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Set the minimum time between saved taps',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: p.text2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SettingsStatusPill(
                            p: p,
                            label: _delayLabel(tapDelay),
                            color: p.accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          DelayStepButton(
                            key: ValueKey('delay-minus-$tapDelay-${p.name}'),
                            p: p,
                            icon: Icons.remove_rounded,
                            enabled: (delayIndex < 0 ? 0 : delayIndex) > 0,
                            onTap: () {
                              final current = delayIndex < 0 ? 0 : delayIndex;
                              final next = _NoteKarHomeState
                                  ._delayValues[math.max(0, current - 1)];
                              HapticFeedback.selectionClick();
                              setState(() => tapDelay = next);
                              widget.onDelay(next);
                            },
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: p.accent,
                                    inactiveTrackColor: p.surface3,
                                    thumbColor: Colors.white,
                                    overlayColor: p.accent.withValues(
                                      alpha: 0.12,
                                    ),
                                    trackHeight: 5,
                                    tickMarkShape:
                                        SliderTickMarkShape.noTickMark,
                                  ),
                                  child: Slider(
                                    key: ValueKey(
                                      'delay-slider-$tapDelay-${p.name}',
                                    ),
                                    min: 0,
                                    max: 6,
                                    divisions: 6,
                                    value: (delayIndex < 0 ? 0 : delayIndex)
                                        .toDouble(),
                                    onChanged: (value) {
                                      final next = _NoteKarHomeState
                                          ._delayValues[value.round()];
                                      if (next == tapDelay) return;
                                      HapticFeedback.selectionClick();
                                      setState(() => tapDelay = next);
                                      widget.onDelay(next);
                                    },
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(0, -4),
                                  child: SliderScale(
                                    p: p,
                                    activeValue: tapDelay,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DelayStepButton(
                            key: ValueKey('delay-plus-$tapDelay-${p.name}'),
                            p: p,
                            icon: Icons.add_rounded,
                            enabled:
                                (delayIndex < 0 ? 0 : delayIndex) <
                                _NoteKarHomeState._delayValues.length - 1,
                            onTap: () {
                              final current = delayIndex < 0 ? 0 : delayIndex;
                              final next =
                                  _NoteKarHomeState._delayValues[math.min(
                                    _NoteKarHomeState._delayValues.length - 1,
                                    current + 1,
                                  )];
                              HapticFeedback.selectionClick();
                              setState(() => tapDelay = next);
                              widget.onDelay(next);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.edit_note_rounded,
                      title: 'Require Note on Hold',
                      subtitle:
                          'Long press opens notes. Empty notes will not be saved.',
                      color: p.orange,
                      value: requireLongPressNote,
                      onChanged: (value) {
                        setState(() => requireLongPressNote = value);
                        widget.onRequireLongPressNote(value);
                      },
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Capture controls how moments are saved. Startup mode applies next launch; tap delay and note-focused hold apply right away.',
                ),
              ],
              if (show('Moments')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.view_agenda_rounded,
                      title: 'Compact History',
                      subtitle:
                          'Use denser rows for faster scanning and less scrolling',
                      color: p.accent,
                      value: compactHistory,
                      onChanged: (value) {
                        setState(() {
                          compactHistory = value;
                          historyDensity = value ? 'compact' : 'comfortable';
                        });
                        widget.onCompactHistory(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.delete_sweep_rounded,
                      title: 'Confirm Delete',
                      subtitle: 'Ask before deleting a saved moment',
                      color: p.red,
                      value: confirmDelete,
                      onChanged: (value) {
                        setState(() => confirmDelete = value);
                        widget.onConfirmDelete(value);
                      },
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.insights_rounded,
                      title: 'Moments',
                      subtitle: '${entries.length} total - $todayCount today',
                      color: p.orange,
                      status: '$todayCount today',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.search_rounded,
                      title: 'Search Notes',
                      subtitle: 'Find saved notes by text, date, time, or type',
                      color: p.accent,
                      status:
                          '${entries.where((e) => e.note.isNotEmpty).length} notes',
                      onTap: () =>
                          _openCategory('Search Notes', parent: 'Moments'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Moments are stored locally for quick review. Compact rows help with scanning; confirmation helps avoid accidental deletes.',
                ),
              ],
              if (show('Search Notes')) ...[
                NoteSearchContent(
                  p: p,
                  entries: entries,
                  compactRows: compactHistory,
                  height: math.min(
                    MediaQuery.sizeOf(context).height * 0.56,
                    500,
                  ),
                ),
              ],
              if (show('Guides')) ...[
                SettingsGroup(
                  p: p,
                  showDividers: true,
                  children: [
                    GuideRow(
                      p: p,
                      icon: Icons.touch_app_rounded,
                      title: 'Save a Moment',
                      text:
                          'Tap the home screen once to save the current time.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.compare_arrows_rounded,
                      title: 'Two-Way Mode',
                      text:
                          'First tap saves In. The next tap saves Out and completes the pair.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.radio_button_checked_rounded,
                      title: 'Single Mode',
                      text: 'Every tap saves one standalone moment.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.note_add_rounded,
                      title: 'Add a Note',
                      text:
                          'Touch and hold the home screen to write a note before saving.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.history_rounded,
                      title: 'Review History',
                      text:
                          'Open History to review moments, use Select Date for a calendar day, or filter by Today and This Week.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.search_rounded,
                      title: 'Search Notes',
                      text:
                          'Open Settings, then Logging, Moments, Search Notes to find note text by words, date, time, or type.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.timer_rounded,
                      title: 'Time Between Moments',
                      text:
                          'Select one moment, then another, to calculate the time between them.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.subject_rounded,
                      title: 'Manage Moment Notes',
                      text:
                          'Touch and hold any history moment to add, read, edit, or delete its note. Deleted notes and moments show an Undo pill.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.lock_rounded,
                      title: 'App Lock Timing',
                      text:
                          'Immediate App Lock covers NoteKar in Recents and when the notification shade sends the app inactive.',
                    ),
                    GuideRow(
                      p: p,
                      icon: Icons.backup_rounded,
                      title: 'Back Up Data',
                      text:
                          'Export a backup before resetting, changing phones, or testing a new build.',
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'NoteKar stores moments privately on this device. Backups are files you control.',
                ),
              ],
              if (show('Help')) ...[
                SettingsGroup(
                  p: p,
                  showDividers: true,
                  children: [
                    HelpRow(
                      p: p,
                      question: 'Update check failed',
                      answer:
                          'First confirm that your phone is connected to the internet. '
                          'If other websites work, GitHub may be unavailable or limiting requests. '
                          'Wait a few minutes and try again.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'App Notices are not appearing',
                      answer:
                          'Confirm App Notices are enabled and Android notification permission '
                          'is allowed. Battery restrictions or background limits may delay checks. '
                          'Opening NoteKar while online also triggers a notice check.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'NoteKar is offline',
                      answer:
                          'Logging, History, notes, settings, and local backups work without internet. '
                          'Only update checks, external links, and App Notices require a connection.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'Backup import found no new moments',
                      answer:
                          'The backup was read correctly, but its moments already exist on this device. '
                          'NoteKar skips duplicates instead of adding them again.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'Backup import failed',
                      answer:
                          'Make sure you selected a NoteKar JSON backup that was not renamed, '
                          'manually edited, or damaged. Try exporting a fresh backup.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'Live Icon Motion will not turn on',
                      answer:
                          'Turn off Reduced Motion first. If NoteKar reports that the motion sensor '
                          'is unavailable, the phone does not provide a usable accelerometer stream.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'Live Icon Motion looks slow or delayed',
                      answer:
                          'The movement is intentionally smoothed to prevent jitter. Lower-end phones '
                          'may also reduce animation performance when many screens are open.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'App Lock will not turn on',
                      answer:
                          'Add a PIN, password, pattern, fingerprint, or other supported screen lock '
                          'in Android settings, then try again.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'App Lock appears after the notification panel',
                      answer:
                          'If App Lock is set to Immediately, opening Recents or pulling down the notification panel counts as leaving NoteKar. The lock overlay hides your moments before you return.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'The app icon did not change immediately',
                      answer:
                          'Some Android launchers cache icons. Return to the home screen, wait briefly, '
                          'or restart the launcher or phone.',
                    ),
                    HelpRow(
                      p: p,
                      question: 'A moment was saved accidentally',
                      answer:
                          'Use Undo immediately after saving, or remove it from History. '
                          'You can enable Confirm Delete for extra protection.',
                    ),
                    HelpRow(
                      p: p,
                      question:
                          'My data disappeared after clearing app storage',
                      answer:
                          'NoteKar stores data locally. Clearing Android app storage deletes that local data. '
                          'Restore it using a backup file if one was exported earlier.',
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'NoteKar is offline-first. Internet-related failures should never block logging or access to saved history.',
                ),
              ],
              if (show('Updates')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: checkingUpdates
                          ? Icons.sync_rounded
                          : _updateAvailable
                          ? Icons.download_rounded
                          : Icons.system_update_alt_rounded,
                      title: _updateTitle,
                      subtitle: _updateSubtitle,
                      color: p.accent,
                      status: 'v${_NoteKarHomeState._appVersion}',
                      onTap: () async {
                        if (_updateAvailable) {
                          widget.onOpenLink(_NoteKarHomeState._githubReleases);
                          return;
                        }
                        setState(() {
                          checkingUpdates = true;
                          updateStatus = 'Checking for updates...';
                        });
                        final status = await widget.onCheckUpdates();
                        if (mounted) {
                          setState(() {
                            updateStatus = status;
                            checkingUpdates = false;
                          });
                        }
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.notifications_active_rounded,
                      title: 'App Notices',
                      subtitle: 'Allow occasional release and app notices',
                      color: p.accent,
                      value: remoteNotices,
                      onChanged: (value) {
                        setState(() => remoteNotices = value);
                        widget.onRemoteNotices(value);
                      },
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.new_releases_rounded,
                      title: "What's New",
                      subtitle: 'See highlights from the latest release',
                      color: p.orange,
                      status: 'New',
                      onTap: () =>
                          _openCategory("What's New", parent: 'Updates'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.article_rounded,
                      title: 'Changelog',
                      subtitle: 'Read release history and fixes',
                      color: p.green,
                      status: 'v${_NoteKarHomeState._appVersion}',
                      onTap: () =>
                          _openCategory('Changelog', parent: 'Updates'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Updates and notices are optional network checks. NoteKar keeps working offline even when these checks are unavailable.',
                ),
              ],
              if (show('Data & Backup')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.backup_rounded,
                      title: 'Backup & Export',
                      subtitle: 'CSV, JSON, import, and backup reminders',
                      color: p.green,
                      onTap: () => _openCategory(
                        'Backup & Export',
                        parent: 'Data & Backup',
                      ),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.health_and_safety_rounded,
                      title: 'Backup Status',
                      subtitle: 'Android backup, health, and planned options',
                      color: p.accent,
                      onTap: () => _openCategory(
                        'Backup Status',
                        parent: 'Data & Backup',
                      ),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Data & Backup is where you move, restore, and protect saved history.',
                ),
              ],
              if (show('Backup & Export')) ...[
                SegmentedSetting(
                  key: ValueKey(
                    'backup-reminder-$backupReminderDays-${p.name}',
                  ),
                  p: p,
                  title: 'Backup Reminder (days)',
                  subtitle: _backupReminderSubtitle,
                  value: '$backupReminderDays',
                  values: const {'0': 'Off', '7': '7', '14': '14', '30': '30'},
                  onChanged: (value) {
                    final days = int.tryParse(value) ?? 0;
                    if (days == backupReminderDays) return;
                    HapticFeedback.selectionClick();
                    setState(() => backupReminderDays = days);
                    widget.onBackupReminderDays(days);
                  },
                ),
                const SizedBox(height: 10),
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.description_rounded,
                      title: 'Export CSV',
                      subtitle: exportState?.startsWith('CSV') == true
                          ? exportState!
                          : 'Save a spreadsheet-friendly copy',
                      color: p.green,
                      active: exportState?.startsWith('CSV') == true,
                      onTap: () =>
                          unawaited(_runExport('CSV', widget.onExportCsv)),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.date_range_rounded,
                      title: 'Export Last 7 Days',
                      subtitle: 'Save only recent moments as CSV',
                      color: p.green,
                      onTap: () => unawaited(
                        _runExport('Recent CSV', widget.onExportRecentCsv),
                      ),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.data_object_rounded,
                      title: 'Export JSON',
                      subtitle: exportState?.startsWith('JSON') == true
                          ? exportState!
                          : 'Save a structured developer-friendly copy',
                      color: p.accent,
                      active: exportState?.startsWith('JSON') == true,
                      onTap: () =>
                          unawaited(_runExport('JSON', widget.onExportJson)),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.backup_rounded,
                      title: 'Backup',
                      subtitle: exportState?.startsWith('Backup') == true
                          ? exportState!
                          : 'Create a portable backup file',
                      color: p.accent,
                      active: exportState?.startsWith('Backup') == true,
                      onTap: () => unawaited(
                        _runExport('Backup', widget.onExportBackup),
                      ),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.drive_folder_upload_rounded,
                      title: 'Import Backup',
                      subtitle: exportState?.startsWith('Import') == true
                          ? exportState!
                          : 'Merge a NoteKar backup into this device. Existing moments stay safe.',
                      color: p.orange,
                      active: exportState?.startsWith('Import') == true,
                      onTap: () => unawaited(_runImport()),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Exports create files you control. Imports merge into your current history so existing moments are not overwritten.',
                ),
              ],
              if (show('Backup Status')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.cloud_done_rounded,
                      title: 'Android Backup',
                      subtitle: 'Included in device transfer and Google backup',
                      color: p.green,
                      status: 'On',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.health_and_safety_rounded,
                      title: 'Data Health',
                      subtitle:
                          '${entries.length} moments - Backup $_backupAgeLine',
                      color: p.green,
                      status: _dataHealthStatus,
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.lock_rounded,
                      title: 'Encrypted Backup',
                      subtitle:
                          'Password-protected backups need a proper crypto flow before release.',
                      color: p.orange,
                      status: 'Planned',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.drive_folder_upload_rounded,
                      title: 'Google Drive Backup',
                      subtitle:
                          'Optional Drive sync needs Google sign-in and Drive permission setup.',
                      color: p.orange,
                      status: 'Planned',
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Backup Status shows what Android can already protect and which backup options still need release-ready setup.',
                ),
              ],
              if (show('Privacy & Security')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.analytics_outlined,
                      title: 'No Analytics',
                      subtitle:
                          'No analytics, ads, crash reporting, or telemetry SDKs.',
                      color: p.green,
                      status: 'None',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.wifi_rounded,
                      title: 'Network Use',
                      subtitle:
                          'Internet is only used when you check updates or enable App Notices.',
                      color: p.accent,
                      status: 'Limited',
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.lock_rounded,
                      title: 'App Lock',
                      subtitle: 'Screen lock and lock timing',
                      color: p.orange,
                      onTap: () => _openCategory(
                        'App Lock',
                        parent: 'Privacy & Security',
                      ),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Privacy & Security covers what stays on-device, when the network is used, and when NoteKar asks Android to lock.',
                ),
              ],
              if (show('Help & Guides')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.menu_book_rounded,
                      title: 'Guides',
                      subtitle:
                          'Learn logging, notes, search, App Lock, and backups',
                      color: p.accent,
                      onTap: () =>
                          _openCategory('Guides', parent: 'Help & Guides'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.help_outline_rounded,
                      title: 'Help',
                      subtitle:
                          'Solutions for updates, backups, App Lock, and common issues',
                      color: p.orange,
                      onTap: () =>
                          _openCategory('Help', parent: 'Help & Guides'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Guides explain how NoteKar works. Help covers common problems and practical fixes.',
                ),
              ],
              if (show('App Lock')) _appLockPage(p),
              if (show('Advanced')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.accessibility_new_rounded,
                      title: 'Accessibility',
                      subtitle: 'Motion, touch, text, and contrast',
                      color: p.orange,
                      onTap: () =>
                          _openCategory('Accessibility', parent: 'Advanced'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.monitor_heart_rounded,
                      title: 'Diagnostics',
                      subtitle: 'Support details and current app state',
                      color: p.accent,
                      onTap: () =>
                          _openCategory('Diagnostics', parent: 'Advanced'),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.restart_alt_rounded,
                      title: 'Reset',
                      subtitle: 'Reset settings, data, or the whole app',
                      color: p.red,
                      onTap: () => _openCategory('Reset', parent: 'Advanced'),
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Advanced groups support tools and reset controls away from everyday settings.',
                ),
              ],
              if (show('Accessibility')) ...[
                SegmentedSetting(
                  key: ValueKey('haptic-style-$hapticStyle-${p.name}'),
                  p: p,
                  title: 'Haptic Style',
                  subtitle: 'Choose how NoteKar responds to key actions',
                  value: hapticStyle,
                  values: const {
                    'off': 'Off',
                    'light': 'Light',
                    'standard': 'Standard',
                  },
                  onChanged: (value) {
                    if (value == hapticStyle) return;
                    HapticFeedback.selectionClick();
                    setState(() => hapticStyle = value);
                    widget.onHapticStyle(value);
                  },
                ),
                const SizedBox(height: 10),
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.motion_photos_off_rounded,
                      title: 'Reduced Motion',
                      subtitle: 'Use simpler feedback and fewer animations',
                      color: p.green,
                      value: reduceMotion,
                      onChanged: (value) {
                        setState(() {
                          reduceMotion = value;
                          if (value) homeMenuAnimations = false;
                        });
                        widget.onReduceMotion(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.format_size_rounded,
                      title: 'Larger Text',
                      subtitle:
                          'Makes easier to read while keeping the layout stable.',
                      color: p.orange,
                      value: largeText,
                      onChanged: (value) {
                        setState(() => largeText = value);
                        widget.onLargeText(value);
                      },
                    ),
                    SettingsSwitchRow(
                      p: p,
                      icon: Icons.contrast_rounded,
                      title: 'High Contrast',
                      subtitle: 'Increase contrast for text and controls',
                      color: p.green,
                      value: highContrast,
                      onChanged: (value) {
                        setState(() => highContrast = value);
                        widget.onHighContrast(value);
                      },
                    ),
                  ],
                ),
                SettingsPageNote(
                  p: p,
                  text:
                      'Accessibility settings are local comfort choices. Change them anytime; your saved data is not affected.',
                ),
              ],
              if (show('Reset')) ...[
                SettingsGroup(
                  p: p,
                  children: [
                    SettingsRow(
                      p: p,
                      icon: Icons.tune_rounded,
                      title: 'Reset Settings Only',
                      subtitle:
                          'Restore preferences while keeping moments and notes',
                      color: p.orange,
                      onTap: () => unawaited(_confirmResetSettings()),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.delete_outline_rounded,
                      title: 'Reset All Data',
                      subtitle: 'Erase every moment and note on this device',
                      color: p.red,
                      onTap: () => unawaited(_confirmResetAll(p)),
                    ),
                    SettingsRow(
                      p: p,
                      icon: Icons.restart_alt_rounded,
                      title: 'Factory Reset',
                      subtitle:
                          'Erase data and settings, then show welcome setup',
                      color: p.red,
                      onTap: () => unawaited(_confirmFactoryReset(p)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Reset is intentionally separate from everyday settings. Back up first before deleting moments or factory resetting the app.',
                  style: TextStyle(color: p.text2, fontSize: 12, height: 1.45),
                ),
              ],
              if (show('Diagnostics')) ...[
                _diagnosticsPage(p, entries, todayCount),
                SettingsPageNote(
                  p: p,
                  text:
                      'Diagnostics are for support and bug reports. Copying them does not send anything automatically.',
                ),
              ],
              if (show("What's New"))
                ChangelogSettingsPage(p: p, latestOnly: true),
              if (show('Changelog'))
                ChangelogSettingsPage(p: p, latestOnly: false),
            ],
          ),
        ),
      ),
    );
    if (!largeText) return sheet;
    return MediaQuery(data: _largerTextQuery(context), child: sheet);
  }
}

class ResetAllConfirmSheet extends StatefulWidget {
  const ResetAllConfirmSheet({
    super.key,
    required this.p,
    required this.title,
    required this.message,
  });

  final Palette p;
  final String title;
  final String message;

  @override
  State<ResetAllConfirmSheet> createState() => _ResetAllConfirmSheetState();
}

class _ResetAllConfirmSheetState extends State<ResetAllConfirmSheet> {
  final _controller = TextEditingController();
  bool _canReset = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return AppSheet(
      p: p,
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, height: 1.45),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            onChanged: (value) => setState(() {
              _canReset = value.trim().toUpperCase() == 'RESET';
            }),
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(color: p.text),
            decoration: InputDecoration(
              hintText: 'RESET',
              hintStyle: TextStyle(color: p.text3),
              filled: true,
              fillColor: p.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.accent),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: p.accent),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _canReset ? p.red : p.surface3,
                    foregroundColor: _canReset ? Colors.white : p.text3,
                  ),
                  onPressed: _canReset
                      ? () => Navigator.pop(context, true)
                      : null,
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WelcomeSheet extends StatefulWidget {
  const WelcomeSheet({
    super.key,
    required this.p,
    required this.theme,
    required this.defaultMode,
    required this.onTheme,
    required this.onDefaultMode,
  });

  final Palette p;
  final String theme;
  final String defaultMode;
  final ValueChanged<String> onTheme;
  final ValueChanged<String> onDefaultMode;

  @override
  State<WelcomeSheet> createState() => _WelcomeSheetState();
}

class _WelcomeSheetState extends State<WelcomeSheet> {
  late String theme;
  late String defaultMode;

  @override
  void initState() {
    super.initState();
    theme = widget.theme;
    defaultMode = widget.defaultMode;
  }

  @override
  Widget build(BuildContext context) {
    final p = _paletteFor(theme);
    return AppSheet(
      p: p,
      title: 'NoteKar',
      docked: true,
      child: SizedBox(
        width: 430,
        height: math.min(MediaQuery.sizeOf(context).height * 0.68, 560),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              'A quiet, offline-first way to mark moments the second they happen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No account. No clutter. Just fast logging, notes, history, and backup when you need them.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final option in const ['dark', 'light']) ...[
                  Expanded(
                    child: ThemeChoice(
                      p: p,
                      label: option == 'dark' ? 'Dark' : 'Light',
                      active: theme == option,
                      color: option == 'dark'
                          ? Colors.black
                          : const Color(0xFFF2F2F7),
                      onTap: () {
                        setState(() => theme = option);
                        widget.onTheme(option);
                      },
                    ),
                  ),
                  if (option == 'dark') const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 18),
            SegmentedSetting(
              p: p,
              title: 'Startup Mode',
              subtitle: 'Choose how NoteKar starts when you open it',
              value: defaultMode,
              values: const {'single': 'Single', 'two-way': 'Two-Way'},
              onChanged: (value) {
                setState(() => defaultMode = value);
                widget.onDefaultMode(value);
              },
            ),
            const SizedBox(height: 12),
            SettingsGroup(
              p: p,
              children: [
                WelcomeRow(
                  p: p,
                  icon: Icons.touch_app_rounded,
                  title: 'Tap to save',
                  text: 'Log a moment instantly from the main screen.',
                ),
                WelcomeRow(
                  p: p,
                  icon: Icons.swap_vert_rounded,
                  title: 'Track starts and stops',
                  text: 'Use Single or Two-Way mode based on your flow.',
                ),
                WelcomeRow(
                  p: p,
                  icon: Icons.edit_note_rounded,
                  title: 'Hold for notes',
                  text: 'Attach context without slowing the app down.',
                ),
                WelcomeRow(
                  p: p,
                  icon: Icons.history_rounded,
                  title: 'Review and export',
                  text: 'Filter history, compare moments, export, or backup.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Start Logging'),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeRow extends StatelessWidget {
  const WelcomeRow({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.text,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: p.text2, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NoteDialog extends StatefulWidget {
  const NoteDialog({
    super.key,
    required this.p,
    this.initialNote = '',
    this.title = 'Add Note',
    this.saveLabel = 'Save Moment',
    this.allowEmpty = true,
  });

  final Palette p;
  final String initialNote;
  final String title;
  final String saveLabel;
  final bool allowEmpty;

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  static const _maxChars = 280;
  late final TextEditingController _controller;
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      p: widget.p,
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialNote.isEmpty
                ? 'Add a short detail to this moment.'
                : 'Update the note attached to this moment.',
            style: TextStyle(color: widget.p.text2, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: _maxChars,
            maxLines: 4,
            minLines: 2,
            style: TextStyle(color: widget.p.text),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'What should this moment remember?',
              hintStyle: TextStyle(color: widget.p.text3),
              filled: true,
              fillColor: widget.p.surface3,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _showWarning ? widget.p.red : widget.p.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _showWarning ? widget.p.red : widget.p.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _showWarning ? widget.p.red : widget.p.accent,
                ),
              ),
            ),
            onChanged: (_) => setState(() => _showWarning = false),
            onSubmitted: (_) => _saveNote(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AnimatedOpacity(
                  opacity: _showWarning ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: Text(
                    'Write something to save.',
                    style: TextStyle(
                      color: widget.p.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              _CharacterCounter(
                p: widget.p,
                count: _controller.text.length,
                max: _maxChars,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.p.accent,
                  ),
                  onPressed: () {
                    if (widget.allowEmpty) {
                      Navigator.pop(context, '');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.allowEmpty ? 'Skip' : 'Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.p.accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveNote,
                  child: Text(widget.saveLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    final note = _controller.text.trim();

    if (!widget.allowEmpty && note.isEmpty) {
      HapticFeedback.selectionClick();
      setState(() => _showWarning = true);
      return;
    }

    Navigator.pop(context, note);
  }
}

class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({
    required this.p,
    required this.count,
    required this.max,
  });

  final Palette p;
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final remaining = max - count;
    final progress = (count / max).clamp(0.0, 1.0);
    final alert = remaining <= 20;
    final color = alert ? p.orange : p.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.4,
            backgroundColor: p.surface3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          alert ? '$remaining' : '$count/$max',
          style: TextStyle(
            color: alert ? color : p.text3,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    required this.p,
    required this.title,
    required this.child,
    this.docked = false,
  });

  final Palette p;
  final String title;
  final Widget child;
  final bool docked;

  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 650) {
          Navigator.maybePop(context);
        }
      },
      child: Glass(
        p: p,
        radius: docked ? 24 : 22,
        borderRadius: docked
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : null,
        padding: EdgeInsets.fromLTRB(16, 8, 16, docked ? 12 : 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: docked ? 720 : 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: p.text3,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: p.text2),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
    if (docked) {
      return Padding(padding: const EdgeInsets.only(top: 8), child: content);
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: content,
    );
  }
}

class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.p,
    required this.child,
    this.radius = 16,
    this.borderRadius,
    this.padding = const EdgeInsets.all(12),
  });

  final Palette p;
  final Widget child;
  final double radius;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius ?? BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: resolvedRadius,
        border: Border.all(color: p.border),
        boxShadow: p.name == 'amoled'
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: p.name == 'light' ? 0.08 : 0.20,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class Ripple extends StatefulWidget {
  const Ripple({super.key, required this.origin, required this.color});
  final Offset origin;
  final Color color;

  @override
  State<Ripple> createState() => _RippleState();
}

class _RippleState extends State<Ripple> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final scale = 1 + _controller.value * 2.4;
        return Positioned(
          left: widget.origin.dx - 20,
          top: widget.origin.dy - 20,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: (1 - _controller.value).clamp(0, 0.16),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.35),
                    width: 1.3,
                  ),
                  color: widget.color.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UndoToast extends StatefulWidget {
  const UndoToast({
    super.key,
    required this.p,
    required this.onUndo,
    required this.token,
  });

  final Palette p;
  final VoidCallback onUndo;
  final int token;

  @override
  State<UndoToast> createState() => _UndoToastState();
}

class _UndoToastState extends State<UndoToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant UndoToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Glass(
        p: widget.p,
        radius: 999,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, _) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (1 - _controller.value).clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.p.accent.withValues(alpha: 0.10),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Moment saved',
                      style: TextStyle(color: widget.p.text),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onUndo,
                      child: Text(
                        'Undo',
                        style: TextStyle(
                          color: widget.p.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SavedPulse extends StatefulWidget {
  const SavedPulse({
    super.key,
    required this.origin,
    required this.p,
    required this.type,
  });

  final Offset origin;
  final Palette p;
  final String type;

  @override
  State<SavedPulse> createState() => _SavedPulseState();
}

class _SavedPulseState extends State<SavedPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final dy = -18 * Curves.easeOutCubic.transform(_controller.value);
        final opacity = (1 - _controller.value).clamp(0.0, 1.0);
        final color = _pulseColor(widget.p, widget.type);
        return Positioned(
          left: widget.origin.dx - 42,
          top: widget.origin.dy - 44 + dy,
          width: 84,
          child: Opacity(
            opacity: opacity,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: color.withValues(alpha: 0.24)),
              ),
              child: Text(
                _pulseLabel(widget.type),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _pulseLabel(String type) {
  return switch (type) {
    'in' => 'IN saved',
    'out' => 'OUT saved',
    _ => 'Saved',
  };
}

Color _pulseColor(Palette p, String type) {
  return _momentColor(p, type);
}

Color _momentColor(Palette p, String type) {
  return switch (type) {
    'in' => p.green,
    'out' => p.orange,
    _ => p.accent,
  };
}

class ChipButton extends StatelessWidget {
  const ChipButton({
    super.key,
    required this.p,
    this.label,
    this.icon,
    required this.active,
    required this.onTap,
  });

  final Palette p;
  final String? label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? p.surface3 : p.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? p.accent : p.border),
          boxShadow: active ? _selectedGlow(p.accent) : null,
        ),
        child: icon == null
            ? Text(
                label ?? '',
                style: TextStyle(
                  color: active ? p.text : p.text2,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              )
            : Icon(
                icon,
                color: active ? p.text : p.text2,
                size: 17,
                semanticLabel: 'Single',
              ),
      ),
    );
  }
}

class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.onTap,
    required this.child,
    this.enabled = true,
  });

  final VoidCallback? onTap;
  final Widget child;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

List<BoxShadow> _selectedGlow(Color color) {
  return const [];
}

MediaQueryData _largerTextQuery(BuildContext context) {
  final media = MediaQuery.of(context);
  final current = media.textScaler.scale(1);
  final target = math.max(current, math.min(current * 1.12, 1.6));
  return media.copyWith(textScaler: TextScaler.linear(target));
}

class MomentTile extends StatelessWidget {
  const MomentTile({
    super.key,
    required this.p,
    required this.entry,
    required this.selected,
    required this.compact,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  final Palette p;
  final Moment entry;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = entry.type == 'out'
        ? p.orange
        : entry.type == 'single'
        ? p.accent
        : p.green;
    if (compact) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          constraints: const BoxConstraints(minHeight: 22),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: selected ? p.surface3 : p.surface2,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? p.text3.withValues(alpha: 0.32) : p.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                _timeOnly(entry.timestamp),
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (entry.note.isNotEmpty) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.text2, fontSize: 9.5),
                  ),
                ),
              ] else
                const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 18,
                  height: 18,
                ),
                padding: EdgeInsets.zero,
                onPressed: onDelete,
                icon: Icon(Icons.close_rounded, color: p.text3, size: 12),
              ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 6 : 12,
        ),
        decoration: BoxDecoration(
          color: selected ? p.surface3 : p.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? p.text3.withValues(alpha: 0.34) : p.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 28 : 38,
              height: compact ? 28 : 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: entry.type == 'single'
                  ? Icon(
                      Icons.arrow_upward_rounded,
                      color: color,
                      size: compact ? 16 : 18,
                    )
                  : Text(
                      entry.type.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            SizedBox(width: compact ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _timeOnly(entry.timestamp),
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 13 : 15,
                    ),
                  ),
                  if (!compact || entry.note.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      '${_datePretty(entry.timestamp)}'
                      '${entry.note.isEmpty ? '' : ' - ${entry.note}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: p.text2, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              visualDensity: compact
                  ? VisualDensity.compact
                  : VisualDensity.standard,
              constraints: BoxConstraints.tightFor(
                width: compact ? 32 : 40,
                height: compact ? 32 : 40,
              ),
              padding: EdgeInsets.zero,
              onPressed: onDelete,
              icon: Icon(
                Icons.close_rounded,
                color: p.text3,
                size: compact ? 18 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.p, required this.text});
  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        text,
        style: TextStyle(
          color: p.text3,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.p,
    required this.children,
    this.showDividers = true,
  });

  final Palette p;
  final List<Widget> children;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (showDividers && i != children.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: Container(height: 1, color: p.border),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsSearchBox extends StatelessWidget {
  const SettingsSearchBox({
    super.key,
    required this.p,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final Palette p;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: p.text, fontSize: 14),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: p.text3, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, color: p.text3, size: 18),
                ),
          hintText: 'Search Settings',
          hintStyle: TextStyle(color: p.text3),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
  });

  final String text;
  final String? query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final q = query?.trim();
    if (q == null || q.isEmpty) {
      return Text(text, style: baseStyle);
    }
    final lower = text.toLowerCase();
    final index = lower.indexOf(q.toLowerCase());
    if (index < 0) return Text(text, style: baseStyle);
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + q.length),
            style: highlightStyle,
          ),
          TextSpan(text: text.substring(index + q.length)),
        ],
      ),
    );
  }
}

class SettingsStatusPill extends StatelessWidget {
  const SettingsStatusPill({
    super.key,
    required this.p,
    required this.label,
    required this.color,
  });

  final Palette p;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class SettingsPageNote extends StatelessWidget {
  const SettingsPageNote({super.key, required this.p, required this.text});

  final Palette p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 2),
      child: Text(
        text,
        style: TextStyle(color: p.text2, fontSize: 12, height: 1.45),
      ),
    );
  }
}

class DiagnosticRow extends StatelessWidget {
  const DiagnosticRow({
    super.key,
    required this.p,
    required this.label,
    required this.value,
  });

  final Palette p;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.text2, fontSize: 12, height: 1.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliderScale extends StatelessWidget {
  const SliderScale({super.key, required this.p, required this.activeValue});

  final Palette p;
  final int activeValue;

  @override
  Widget build(BuildContext context) {
    final visibleLabels = {0, 10, 20, 60};
    return SizedBox(
      height: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final value in _NoteKarHomeState._delayValues)
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: value == activeValue ? p.accent : p.text3,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 11,
                      child: visibleLabels.contains(value)
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _delayLabel(value),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: value == activeValue
                                      ? p.accent
                                      : p.text3,
                                  fontSize: 8,
                                  fontWeight: value == activeValue
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DelayStepButton extends StatefulWidget {
  const DelayStepButton({
    super.key,
    required this.p,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final Palette p;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<DelayStepButton> createState() => _DelayStepButtonState();
}

class _DelayStepButtonState extends State<DelayStepButton> {
  bool _pressed = false;
  int _tapPulse = 0;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled ? widget.p.text : widget.p.text3;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: widget.enabled
          ? () => setState(() => _pressed = false)
          : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: widget.enabled
          ? () {
              setState(() => _tapPulse++);
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        curve: Curves.easeOutBack,
        duration: const Duration(milliseconds: 130),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.enabled ? widget.p.surface3 : widget.p.surface2,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.enabled
                  ? widget.p.border
                  : widget.p.border.withValues(alpha: 0.45),
            ),
          ),
          child: TweenAnimationBuilder<double>(
            key: ValueKey(_tapPulse),
            tween: Tween(begin: 1.18, end: 1),
            duration: const Duration(milliseconds: 260),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Icon(widget.icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

class ThemeChoice extends StatelessWidget {
  const ThemeChoice({
    super.key,
    required this.p,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final Palette p;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? p.surface3 : p.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? p.accent : p.border),
          boxShadow: active ? _selectedGlow(p.accent) : null,
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: p.border),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                color: active ? p.text : p.text2,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppIconApplyingDialog extends StatelessWidget {
  const AppIconApplyingDialog({super.key, required this.p});

  final Palette p;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 250,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      color: p.accent,
                      backgroundColor: p.surface3,
                    ),
                    Icon(Icons.apps_rounded, color: p.accent, size: 23),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Applying app icon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Please wait while Android refreshes NoteKar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.text2, fontSize: 13, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppIconChoice extends StatelessWidget {
  const AppIconChoice({
    super.key,
    required this.p,
    required this.label,
    required this.asset,
    required this.active,
    required this.onTap,
  });

  final Palette p;
  final String label;
  final String asset;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? p.accent.withValues(alpha: 0.12) : p.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? p.accent : p.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.surface3,
                shape: BoxShape.circle,
                border: Border.all(color: active ? p.accent : p.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Transform.scale(
                scale: 1.18,
                child: Image.asset(
                  asset,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  cacheWidth: 96,
                  cacheHeight: 96,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? p.text : p.text2,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (active) Icon(Icons.check_rounded, color: p.accent, size: 18),
          ],
        ),
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.active = false,
    this.status,
    this.statusColor,
    this.highlight,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool active;
  final String? status;
  final Color? statusColor;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      enabled: onTap != null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(9),
              ),
              child:
                  title == 'Check for Update' &&
                      subtitle.toLowerCase().contains('checking')
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      builder: (_, value, child) => Transform.rotate(
                        angle: value * math.pi * 2,
                        child: child,
                      ),
                      onEnd: () {},
                      child: Icon(icon, color: color, size: 18),
                    )
                  : Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightedText(
                    text: title,
                    query: highlight,
                    baseStyle: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w800,
                    ),
                    highlightStyle: TextStyle(
                      color: p.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: active ? color : p.text2,
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SettingsStatusPill(
                  p: p,
                  label: status!,
                  color: statusColor ?? color,
                ),
              ),
            ],
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Icon(Icons.chevron_right_rounded, color: p.text3),
              ),
          ],
        ),
      ),
    );
  }
}

class GuideRow extends StatelessWidget {
  const GuideRow({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.text,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: p.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(color: p.text2, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HelpRow extends StatelessWidget {
  const HelpRow({
    super.key,
    required this.p,
    required this.question,
    required this.answer,
  });

  final Palette p;
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        iconColor: p.accent,
        collapsedIconColor: p.text3,
        title: Text(
          question,
          style: TextStyle(
            color: p.text,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: TextStyle(color: p.text2, fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.p,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.disabledMessage,
    this.onDisabledTap,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final String? disabledMessage;
  final ValueChanged<String>? onDisabledTap;

  @override
  Widget build(BuildContext context) {
    final switchColor = p.accent;
    return PressableScale(
      onTap: () {
        if (!enabled) {
          final message = disabledMessage;
          if (message != null) onDisabledTap?.call(message);
          return;
        }
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (enabled && value ? switchColor : p.text3).withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: enabled && value ? switchColor : p.text2,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: enabled ? p.text : p.text2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: enabled ? p.text2 : p.text3,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.only(top: 3),
              width: 46,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: enabled && value ? switchColor : p.surface3,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: enabled && value ? switchColor : p.border,
                ),
              ),
              child: Align(
                alignment: enabled && value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsAboutBlock extends StatelessWidget {
  const SettingsAboutBlock({
    super.key,
    required this.p,
    required this.onEmailTap,
    required this.onGitHubTap,
    required this.onVersionLongPress,
  });

  final Palette p;
  final VoidCallback onEmailTap;
  final VoidCallback onGitHubTap;
  final VoidCallback onVersionLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          Text(
            'NoteKar',
            style: TextStyle(
              color: p.text,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Built by YABP as a small, offline-first timestamp logger for real work: quick taps, focused notes, private local storage, and exports developers can inspect.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.text2, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialCircleButton(
                p: p,
                icon: Icons.mail_rounded,
                onTap: onEmailTap,
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onLongPress: onVersionLongPress,
                child: Container(
                  height: 38,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: p.surface3,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: p.border),
                  ),
                  child: Text(
                    'v${_NoteKarHomeState._appVersion} '
                    '(${_NoteKarHomeState._appBuildNumber})',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SocialCircleButton(
                p: p,
                icon: Icons.code_rounded,
                onTap: onGitHubTap,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Build date ${_NoteKarHomeState._appBuildDate}',
            style: TextStyle(color: p.text3, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class SocialCircleButton extends StatelessWidget {
  const SocialCircleButton({
    super.key,
    required this.p,
    required this.icon,
    required this.onTap,
  });

  final Palette p;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: p.name == 'light' ? Colors.white : p.surface3,
          shape: BoxShape.circle,
          border: Border.all(color: p.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: p.name == 'light' ? 0.08 : 0.22,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: icon == Icons.code_rounded
            ? CustomPaint(painter: GitHubMarkPainter(color: p.text))
            : Icon(icon, color: p.accent, size: 18),
      ),
    );
  }
}

class GitHubMarkPainter extends CustomPainter {
  GitHubMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final scale = math.min(size.width, size.height) / 24;
    canvas.save();
    canvas.translate(
      (size.width - 24 * scale) / 2,
      (size.height - 24 * scale) / 2,
    );
    canvas.scale(scale);
    final path = Path()
      ..moveTo(9, 19)
      ..cubicTo(4.5, 20.4, 4.5, 16.4, 3, 16)
      ..moveTo(15, 22)
      ..lineTo(15, 18.5)
      ..cubicTo(15, 17.5, 14.7, 16.7, 14.1, 16.2)
      ..cubicTo(17.1, 15.9, 20.1, 14.7, 20.1, 9.4)
      ..cubicTo(20.1, 8, 19.6, 6.8, 18.7, 5.8)
      ..cubicTo(19, 4.8, 18.9, 3.6, 18.6, 2.3)
      ..cubicTo(18.6, 2.3, 17.5, 2, 15, 3.7)
      ..cubicTo(13, 3.1, 10.5, 3.1, 8.5, 3.7)
      ..cubicTo(6, 2, 4.9, 2.3, 4.9, 2.3)
      ..cubicTo(4.6, 3.6, 4.5, 4.8, 4.8, 5.8)
      ..cubicTo(3.9, 6.8, 3.4, 8, 3.4, 9.4)
      ..cubicTo(3.4, 14.7, 6.4, 15.9, 9.4, 16.2)
      ..cubicTo(8.8, 16.8, 8.5, 17.5, 8.5, 18.5)
      ..lineTo(8.5, 22);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GitHubMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class ChangelogDialog extends StatefulWidget {
  const ChangelogDialog({super.key, required this.p, this.latestOnly = false});

  final Palette p;
  final bool latestOnly;

  static const releases = [
    (
      version: '4.0.3',
      date: 'June 17, 2026',
      items: [
        'Moved the app line to 4.0.3 build 12 for the backup and performance hardening release.',
        'Added backup validation before import, with safer checks for damaged JSON, invalid moments, oversized files, and unsupported data.',
        'Added a backup import preview with total moments, notes, export date, new moments, duplicates skipped, and settings to restore.',
        'Made backup import crash-safer by validating and persisting the merge before updating visible app state.',
        'Improved startup sequencing so first paint, App Lock, and non-critical checks are staged more smoothly.',
        'Added timeline profiling markers for startup and backup import work.',
        'Cached Settings search, note search, and calendar date lookups for smoother repeated use.',
        'Added focused tests for backup validation, corrupted files, duplicate handling, and dry-run summaries.',
      ],
    ),

    (
      version: '4.0.2',
      date: 'June 12, 2026',
      items: [
        'Moved the app line to 4.0.2 build 11 for the polish release.',
        'Made home menu icon motion optional, disabled by default, and tied it to Reduce Motion.',
        'Added dependency-aware Settings behavior so unavailable controls explain what must be enabled first.',
        'Refined History and Settings bottom sheets, History delete feedback, and swipe-delete polish.',
        'Fixed App Lock immediate timing so Android screen-lock confirmation does not loop inside the app.',
        'Added clearer feedback while Android applies launcher icon changes.',
      ],
    ),

    (
      version: '4.0.1',
      date: 'June 1, 2026',
      items: [
        'Moved the app line to 4.0.1 build 11 for the polish release.',
        'Made home menu icon motion optional, disabled by default, and tied it to Reduce Motion.',
        'Added dependency-aware Settings behavior so unavailable controls explain what must be enabled first.',
        'Refined History and Settings bottom sheets, History delete feedback, and swipe-delete polish.',
        'Fixed App Lock immediate timing so Android screen-lock confirmation does not loop inside the app.',
        'Added clearer feedback while Android applies launcher icon changes.',
      ],
    ),
    (
      version: '4.0.0',
      date: 'June 1, 2026',
      items: [
        'Moved the app line to 4.0.0 build 9 for the final release package.',
        'Reduced Settings to clearer top-level sections: Personalization, Logging, Privacy & Security, Data & Backup, Updates, and Advanced.',
        'Added real Android app icon switching with Default, Black, Blue, Gold, Green, Orange, and Red launcher icons.',
        'Moved App Lock under Privacy & Security with background-only lock timing and clearer Android screen-lock wording.',
        'Added note validation, a visible character counter, full-note viewing from History, and smoother History scroll-to-top behavior.',
        'Cleaned Backup & Export by moving passive backup status cards into a second-level Backup Status page.',
        'Polished release privacy and security behavior by avoiding clipboard fallback for failed exports and requiring HTTPS for remote notice links.',
      ],
    ),
    (
      version: '3.6.0',
      date: 'May 27, 2026',
      items: [
        'Moved the app line to 3.6.0 build 8 for the next release wave.',
        'Restored compact History to the denser 3.0.0-style cards for faster scanning.',
        'Kept History as a simple normal / compact switch instead of splitting it into more modes.',
        'Moved Quick Actions out of Privacy and into Accessibility so launcher shortcuts sit with interaction controls.',
        'Kept the calmer action-color dots, haptic style, backup reminder, and privacy lock work from the previous polish pass.',
      ],
    ),
    (
      version: '3.5.0',
      date: 'May 27, 2026',
      items: [
        'Moved the app line to 3.5.0 build 7 for the next release cycle.',
        'Added a theme-aware bottom navigation surface so the home toolbar follows Light, Dark, and AMOLED themes more naturally.',
        'Fixed Larger Text so it respects Android text scaling and never shrinks text when the system font is already larger.',
        'Added curated Action Color support with Blue, Green, Purple, Pink, Orange, and Graphite accents while keeping destructive, success, and warning colors intentional.',
        'Added Haptic Style, compact History, Auto Backup Reminder, Data Health, and Quick Actions controls.',
        'Added Privacy Lock using Android system credentials, with guidance to add a system lock before enabling it.',
        'Expanded Android app shortcuts to Single, IN, OUT, and Note actions.',
        'Simplified Accessibility by replacing duplicate haptics switches with Off, Light, and Standard haptic styles.',
      ],
    ),
    (
      version: '3.0.0',
      date: 'May 27, 2026',
      items: [
        'Moved the current app line to 3.0.0 build 6 with refreshed What\'s New and changelog entries.',
        'Reshuffled Settings into clearer categories: Display, Capture, Moments, Backup & Export, Updates & Notices, Privacy & Security, Accessibility, Reset, and Diagnostics.',
        'Moved all reset actions into a dedicated Reset page with Reset Settings Only, Reset All Data, Factory Reset, and a guidance note.',
        'Added a full-screen Factory Reset flow with real progress, a calm completion state, and a Start button before the welcome setup appears.',
        'Made Settings navigation stack-aware, so nested pages go back to their previous section before closing the sheet.',
        'Improved offline-first startup by delaying network notice checks until the app has loaded and connectivity is known.',
        'Refined History with true compact rows, a scroll-to-top control, smoother delete removal, better swipe-delete background, and Single moments in duration selection.',
        'Changed backup import to merge new moments with existing local history instead of replacing the current device data.',
        'Added a dedicated Privacy page with local-storage details, limited network-use notes, no analytics/telemetry disclosure, and planned encryption/Drive backup guidance.',
        'Cleaned Diagnostics with clearer labels, copyable support details, and Android backup visibility.',
        'Fixed welcome theme selection, removed duplicate Minimal Clock controls, and kept Show Seconds as the single clock display setting.',
        'Added Note-Focused Hold so long press can be reserved for moments that include context.',
        'Reduced noisy setting-change notification pills while keeping meaningful feedback for updates, exports, connectivity, and errors.',
        'Refined Settings row alignment so icons sit with titles, and restored compact History card radius to avoid red swipe background peeking through.',
      ],
    ),
    (
      version: '2.5.0',
      date: 'May 27, 2026',
      items: [
        'Prepared the 2.5.0 release notes and Android release folder structure without building APKs.',
        'Kept the app version aligned for the next release step and preserved the 2.0.0 release history.',
        'Documented the planned release files and SHA-256 packaging approach for the Android APK release.',
      ],
    ),
    (
      version: '2.0.0',
      date: 'May 26, 2026',
      items: [
        'Introduced the iOS-inspired Android redesign with grouped Settings pages, cleaner sheets, refined toolbar controls, and calmer colors.',
        'Added GitHub Releases update checks, remote GitHub notice support, notification routing actions, What\'s New, and Changelog pages.',
        'Added accessibility and customization options for haptics, motion, larger text, high contrast, compact history, button labels, and large controls.',
        'Improved Android backup visibility, export shortcuts, backup import, diagnostics, typed reset confirmation, and release metadata.',
        'Refined history filters, section headers, swipe-delete visuals, note indicators, and compact review controls.',
      ],
    ),
    (
      version: '1.0.0',
      date: 'May 25, 2026',
      items: [
        'Launched the native Android rewrite with private offline moment storage.',
        'Added Single and Two-Way logging, note capture, history filters, exports, and backup import.',
        'Added settings for themes, default startup mode, and tap delay control.',
      ],
    ),
  ];

  @override
  State<ChangelogDialog> createState() => _ChangelogDialogState();
}

class ChangelogSettingsPage extends StatefulWidget {
  const ChangelogSettingsPage({
    super.key,
    required this.p,
    required this.latestOnly,
  });

  final Palette p;
  final bool latestOnly;

  @override
  State<ChangelogSettingsPage> createState() => _ChangelogSettingsPageState();
}

class _ChangelogSettingsPageState extends State<ChangelogSettingsPage> {
  final Set<int> _expanded = {0};

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final visible = widget.latestOnly
        ? ChangelogDialog.releases.take(1).toList()
        : ChangelogDialog.releases;
    if (widget.latestOnly) {
      return _WhatsNewPanel(p: p, release: visible.first);
    }
    return Column(
      children: [
        for (var index = 0; index < visible.length; index++)
          ChangelogReleaseCard(
            p: p,
            release: visible[index],
            isLatest: index == 0,
            expanded: _expanded.contains(index),
            onTap: () => setState(() {
              if (_expanded.contains(index)) {
                _expanded.remove(index);
              } else {
                _expanded.add(index);
              }
            }),
          ),
      ],
    );
  }
}

class ChangelogReleaseCard extends StatelessWidget {
  const ChangelogReleaseCard({
    super.key,
    required this.p,
    required this.release,
    required this.isLatest,
    required this.expanded,
    required this.onTap,
  });

  final Palette p;
  final ({String date, List<String> items, String version}) release;
  final bool isLatest;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          PressableScale(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isLatest
                          ? p.accent.withValues(alpha: 0.12)
                          : p.surface3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isLatest
                          ? Icons.auto_awesome_rounded
                          : Icons.article_rounded,
                      color: isLatest ? p.accent : p.text2,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Version ${release.version}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (isLatest) ...[
                              const SizedBox(width: 8),
                              SettingsStatusPill(
                                p: p,
                                label: 'New',
                                color: p.accent,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          release.date,
                          style: TextStyle(
                            color: p.text3,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(Icons.chevron_right_rounded, color: p.text3),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  Divider(color: p.border, height: 1),
                  const SizedBox(height: 10),
                  for (final item in release.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: p.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: p.text2,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _ChangelogDialogState extends State<ChangelogDialog> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final visible = widget.latestOnly
        ? ChangelogDialog.releases.take(1).toList()
        : ChangelogDialog.releases;
    final maxHeight = math.min(MediaQuery.sizeOf(context).height * 0.62, 520.0);
    return AppSheet(
      p: p,
      title: widget.latestOnly ? "What's New" : 'Changelog',
      child: SizedBox(
        width: 430,
        height: maxHeight,
        child: widget.latestOnly
            ? _WhatsNewPanel(p: p, release: visible.first)
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final release = visible[index];
                  final expanded = _expanded.contains(index);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: p.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (expanded) {
                                _expanded.remove(index);
                              } else {
                                _expanded.add(index);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? p.accent.withValues(alpha: 0.14)
                                        : p.surface3,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    index == 0
                                        ? Icons.auto_awesome_rounded
                                        : Icons.article_rounded,
                                    color: index == 0 ? p.accent : p.text2,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Version ${release.version}',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: p.text,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          if (index == 0) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: p.accent.withValues(
                                                  alpha: 0.14,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                'New',
                                                style: TextStyle(
                                                  color: p.accent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        release.date,
                                        style: TextStyle(
                                          color: p.text3,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: expanded ? 0.25 : 0,
                                  duration: const Duration(milliseconds: 160),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: p.text3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: Column(
                              children: [
                                Divider(color: p.border, height: 1),
                                const SizedBox(height: 10),
                                for (final item in release.items)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 9),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: p.accent,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              color: p.text2,
                                              fontSize: 13,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          crossFadeState: expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 180),
                          sizeCurve: Curves.easeOutCubic,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _WhatsNewPanel extends StatelessWidget {
  const _WhatsNewPanel({required this.p, required this.release});

  final Palette p;
  final ({String date, List<String> items, String version}) release;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      primary: false,
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: p.accent,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's New",
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'NoteKar ${release.version}',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latest Android changes, fixes, and polish for this build.',
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final item in release.items)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded, color: p.accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SegmentedSetting extends StatelessWidget {
  const SegmentedSetting({
    super.key,
    required this.p,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.values,
    required this.onChanged,
    this.status,
  });

  final Palette p;
  final String title;
  final String subtitle;
  final String value;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return Glass(
      p: p,
      radius: 12,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
                ),
              ),
              if (status != null)
                SettingsStatusPill(p: p, label: status!, color: p.accent),
            ],
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(color: p.text2, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: values.entries.map((entry) {
              final active = value == entry.key;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => onChanged(entry.key),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: active ? p.surface3 : p.surface2,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: active ? p.accent : p.border),
                        boxShadow: active ? _selectedGlow(p.accent) : null,
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: active ? p.text : p.text2,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ColorChoiceSetting extends StatelessWidget {
  const ColorChoiceSetting({
    super.key,
    required this.p,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Palette p;
  final String title;
  final String subtitle;
  final String value;
  final ValueChanged<String> onChanged;

  static const _choices = [
    ('blue', Color(0xFF0A84FF)),
    ('green', Color(0xFF30D158)),
    ('purple', Color(0xFFBF5AF2)),
    ('pink', Color(0xFFFF6B8A)),
    ('orange', Color(0xFFFF9F0A)),
    ('graphite', Color(0xFF8E8E93)),

    ('teal', Color(0xFF40C8C0)),
    ('mint', Color(0xFF63D7A5)),
    ('cyan', Color(0xFF64D2FF)),
    ('indigo', Color(0xFF7D89FF)),
    ('violet', Color(0xFFA78BFA)),
    ('lavender', Color(0xFFC4B5FD)),
    ('rose', Color(0xFFFF8FAB)),
    ('coral', Color(0xFFFF8A7A)),
    ('amber', Color(0xFFFFC857)),
    ('sand', Color(0xFFD6B86A)),
    ('sage', Color(0xFFA3B18A)),
    ('olive', Color(0xFFB6C667)),
    ('slate', Color(0xFF9BAAB3)),
    ('brown', Color(0xFFB08A78)),
  ];

  @override
  Widget build(BuildContext context) {
    return Glass(
      p: p,
      radius: 12,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: p.text, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(color: p.text2, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _choices.map((entry) {
              final key = entry.$1;
              final color = entry.$2;
              final active = value == key;

              return GestureDetector(
                onTap: () => onChanged(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? color.withValues(alpha: 0.18) : p.surface2,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? color : p.border,
                      width: active ? 2.5 : 1,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: active ? 28 : 30,
                    height: active ? 28 : 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

Palette _paletteFor(
  String theme, {
  bool highContrast = false,
  String accentName = 'blue',
}) {
  final accent = _accentColorFor(accentName, light: theme == 'light');
  if (theme == 'light') {
    return Palette(
      name: 'light',
      bg: const Color(0xFFFFFFFF),
      surface: const Color(0xFFFFFFFF),
      surface2: const Color(0xFFF7F7F7),
      surface3: const Color(0xFFEDEDED),
      border: highContrast ? const Color(0xFFB8B8B8) : const Color(0xFFE4E4E4),
      text: const Color(0xFF0F0F0F),
      text2: highContrast ? const Color(0xFF303030) : const Color(0xFF606060),
      text3: highContrast ? const Color(0xFF5D5D5D) : const Color(0xFF9A9A9A),
      clock: const Color(0xFFE9E9E9),
      accent: accent,
      green: const Color(0xFF25D366),
      orange: const Color(0xFFFF9500),
      red: const Color(0xFFFF0033),
    );
  }
  final amoled = theme == 'amoled';
  return Palette(
    name: theme,
    bg: amoled ? Colors.black : const Color(0xFF0F0F0F),
    surface: amoled ? const Color(0xFF0C0C0C) : const Color(0xFF212121),
    surface2: amoled ? const Color(0xFF151515) : const Color(0xFF2A2A2A),
    surface3: amoled ? const Color(0xFF202020) : const Color(0xFF3F3F3F),
    border: amoled
        ? (highContrast ? const Color(0xFF323232) : const Color(0xFF1F1F1F))
        : (highContrast ? const Color(0xFF666666) : const Color(0xFF343434)),
    text: const Color(0xFFF1F1F1),
    text2: highContrast ? const Color(0xFFD8D8D8) : const Color(0xFFAAAAAA),
    text3: highContrast ? const Color(0xFFAFAFAF) : const Color(0xFF717171),
    clock: amoled ? const Color(0xFF1F1F1F) : const Color(0xFF303030),
    accent: accent,
    green: const Color(0xFF30D158),
    orange: const Color(0xFFFF9F0A),
    red: const Color(0xFFFF0033),
  );
}

Color _accentColorFor(String name, {required bool light}) {
  return switch (name) {
    'green' => light ? const Color(0xFF248A3D) : const Color(0xFF30D158),
    'purple' => light ? const Color(0xFF7E57C2) : const Color(0xFFBF5AF2),
    'pink' => light ? const Color(0xFFC1466E) : const Color(0xFFFF6B8A),
    'orange' => light ? const Color(0xFFC46A00) : const Color(0xFFFF9F0A),
    'graphite' => light ? const Color(0xFF5F6368) : const Color(0xFF8E8E93),

    'teal' => light ? const Color(0xFF0A7C75) : const Color(0xFF40C8C0),
    'mint' => light ? const Color(0xFF2E7D5B) : const Color(0xFF63D7A5),
    'cyan' => light ? const Color(0xFF087EA4) : const Color(0xFF64D2FF),
    'indigo' => light ? const Color(0xFF4F5BD5) : const Color(0xFF7D89FF),
    'violet' => light ? const Color(0xFF6D5BD0) : const Color(0xFFA78BFA),
    'lavender' => light ? const Color(0xFF7B68A8) : const Color(0xFFC4B5FD),
    'rose' => light ? const Color(0xFFB43B5E) : const Color(0xFFFF8FAB),
    'coral' => light ? const Color(0xFFB85C4A) : const Color(0xFFFF8A7A),
    'amber' => light ? const Color(0xFFB7791F) : const Color(0xFFFFC857),
    'sand' => light ? const Color(0xFF8A6F3D) : const Color(0xFFD6B86A),
    'sage' => light ? const Color(0xFF5F7A61) : const Color(0xFFA3B18A),
    'olive' => light ? const Color(0xFF6B7A2F) : const Color(0xFFB6C667),
    'slate' => light ? const Color(0xFF52616B) : const Color(0xFF9BAAB3),
    'brown' => light ? const Color(0xFF795548) : const Color(0xFFB08A78),

    _ => light ? const Color(0xFF007AFF) : const Color(0xFF0A84FF),
  };
}

bool _isAppIconStyle(String? value) {
  return const {
    'default',
    'black',
    'blue',
    'gold',
    'green',
    'orange',
    'red',
  }.contains(value);
}

String _dateKey(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

DateTime _dateFromKey(String value) {
  final parts = value.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

String _compactDateLabel(String value) {
  final date = _dateFromKey(value);
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${(date.year % 100).toString().padLeft(2, '0')}';
}

String _monthLabel(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[value.month - 1]} ${value.year}';
}

String _timeOnly(int timestamp) {
  final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}:'
      '${d.second.toString().padLeft(2, '0')}';
}

String _datePretty(int timestamp) {
  final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

String _historySectionLabel(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final today = DateTime.now();
  final key = _dateKey(date);
  if (key == _dateKey(today)) return 'Today';
  if (key == _dateKey(today.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }
  return 'Earlier';
}

String _durationLabel(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m ${s}s';
  return '${s}s';
}

String _delayLabel(int value) => value == 60 ? '1m' : '${value}s';

String _privacyLockDelayLabel(int value) {
  return switch (value) {
    0 => 'Immediately',
    1 => 'After 1 Min',
    5 => 'After 5 Min',
    10 => 'After 10 Min',
    _ => 'Immediately',
  };
}

String _relativeAge(int timestamp) {
  final elapsed = DateTime.now().difference(
    DateTime.fromMillisecondsSinceEpoch(timestamp),
  );
  if (elapsed.inSeconds < 45) return 'Just now';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
  return '${elapsed.inDays}d ago';
}

String _exportDateStamp() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}-'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';
}

String _filterLabel(String value) {
  return switch (value) {
    'all' => 'All',
    'today' => 'Today',
    'week' => 'This Week',
    'in' => 'IN',
    'out' => 'OUT',
    'single' => 'Single',
    'notes' => 'Notes',
    _ => value,
  };
}

bool _isNewerVersion(String candidate, String current) {
  List<int> parts(String value) => value
      .split('+')
      .first
      .split(RegExp(r'[^0-9]+'))
      .where((part) => part.isNotEmpty)
      .map(int.parse)
      .toList();
  final a = parts(candidate);
  final b = parts(current);
  final length = math.max(a.length, b.length);
  for (var i = 0; i < length; i++) {
    final av = i < a.length ? a[i] : 0;
    final bv = i < b.length ? b[i] : 0;
    if (av != bv) return av > bv;
  }
  return false;
}
