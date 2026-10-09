import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/utils/app_logger.dart';

/// Service managing audio recording and playback via platform MethodChannels,
/// with mock simulation fallback for headless unit/widget testing environments.
class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  static AudioService get instance => _instance;
  AudioService._internal();

  final _logger = AppLogger();
  static const MethodChannel _channel = MethodChannel('notekar/files');

  // --- Recording State ---
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  Duration get recordingDuration => _recordingDuration;

  // --- Playback State ---
  String? _currentPlayingPath;
  String? get currentPlayingPath => _currentPlayingPath;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  Duration _totalDuration = Duration.zero;
  Duration get totalDuration => _totalDuration;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  Timer? _playbackPollTimer;

  // --- Recording Actions ---

  Future<Map<String, dynamic>?> startRecording() async {
    try {
      _stopPlaybackPoll();
      _isPlaying = false;

      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'startAudioRecording',
      );
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _recordingDuration = Duration.zero;
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (_recordingStartTime != null) {
          _recordingDuration = DateTime.now().difference(_recordingStartTime!);
          notifyListeners();
        }
      });
      notifyListeners();
      return res != null ? Map<String, dynamic>.from(res) : null;
    } catch (e, stack) {
      _logger.warn(
        'Platform recording not available, running fallback simulation',
        e,
        stack,
      );
      // Mock simulation for test/desktop environments
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _recordingDuration = Duration.zero;
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (_recordingStartTime != null) {
          _recordingDuration = DateTime.now().difference(_recordingStartTime!);
          notifyListeners();
        }
      });
      notifyListeners();
      return {
        'filePath': 'voice/voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
        'simulated': true,
      };
    }
  }

  Future<Map<String, dynamic>?> stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _isRecording = false;

    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'stopAudioRecording',
      );
      notifyListeners();
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
    } catch (e, stack) {
      _logger.warn('Platform stop recording error, falling back', e, stack);
    }

    final durationMs = _recordingDuration.inMilliseconds.clamp(1000, 3600000);
    notifyListeners();
    return {
      'filePath': 'voice/voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
      'durationMs': durationMs,
      'simulated': true,
    };
  }

  Future<void> cancelRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _isRecording = false;
    _recordingDuration = Duration.zero;
    try {
      await _channel.invokeMethod('cancelAudioRecording');
    } catch (_) {}
    notifyListeners();
  }

  // --- Playback Actions ---

  Future<void> play(
    String path, {
    double speed = 1.0,
    Duration? fallbackDuration,
  }) async {
    _playbackSpeed = speed;
    if (_currentPlayingPath == path && !_isPlaying) {
      return resume();
    }

    _currentPlayingPath = path;
    _currentPosition = Duration.zero;
    _totalDuration = fallbackDuration ?? const Duration(seconds: 15);

    try {
      final file = await MediaStorageService.instance.resolveFile(path);
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'playAudio',
        {'path': file.path, 'speed': speed},
      );

      if (res != null) {
        final durationMs = (res['durationMs'] as num?)?.toInt() ?? 0;
        if (durationMs > 0) {
          _totalDuration = Duration(milliseconds: durationMs);
        }
      }
      _isPlaying = true;
      _startPlaybackPoll();
      notifyListeners();
    } catch (e, stack) {
      _logger.warn('Platform playAudio fallback', e, stack);
      // Simulation for testing/desktop
      _isPlaying = true;
      _startPlaybackPoll();
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _channel.invokeMethod('pauseAudio');
    } catch (_) {}
    _isPlaying = false;
    _stopPlaybackPoll();
    notifyListeners();
  }

  Future<void> resume() async {
    try {
      await _channel.invokeMethod('resumeAudio');
    } catch (_) {}
    _isPlaying = true;
    _startPlaybackPoll();
    notifyListeners();
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopAudio');
    } catch (_) {}
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _stopPlaybackPoll();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    _currentPosition = position;
    try {
      await _channel.invokeMethod('seekAudio', {
        'positionMs': position.inMilliseconds,
      });
    } catch (_) {}
    notifyListeners();
  }

  Future<void> cyclePlaybackSpeed() async {
    double nextSpeed = 1.0;
    if ((_playbackSpeed - 1.0).abs() < 0.05) {
      nextSpeed = 1.5;
    } else if ((_playbackSpeed - 1.5).abs() < 0.05) {
      nextSpeed = 2.0;
    } else {
      nextSpeed = 1.0;
    }
    _playbackSpeed = nextSpeed;
    notifyListeners();
    try {
      await _channel.invokeMethod('setAudioSpeed', {'speed': nextSpeed});
    } catch (_) {}
  }

  void _startPlaybackPoll() {
    _playbackPollTimer?.cancel();
    _playbackPollTimer = Timer.periodic(const Duration(milliseconds: 250), (
      _,
    ) async {
      try {
        final state = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'getAudioPlaybackState',
        );
        if (state != null) {
          final isPlayingNow = state['isPlaying'] as bool? ?? false;
          final posMs = (state['positionMs'] as num?)?.toInt() ?? 0;
          final durMs = (state['durationMs'] as num?)?.toInt() ?? 0;

          _isPlaying = isPlayingNow;
          _currentPosition = Duration(milliseconds: posMs);
          if (durMs > 0) {
            _totalDuration = Duration(milliseconds: durMs);
          }

          if (!_isPlaying &&
              _currentPosition >= _totalDuration &&
              _totalDuration > Duration.zero) {
            // Finished playing
            _currentPosition = Duration.zero;
            _stopPlaybackPoll();
          }
          notifyListeners();
          return;
        }
      } catch (_) {}

      // In simulation mode (e.g. tests or unsupported platform)
      if (_isPlaying) {
        final stepMs = (250 * _playbackSpeed).toInt();
        final newPos = _currentPosition + Duration(milliseconds: stepMs);
        if (newPos >= _totalDuration) {
          _isPlaying = false;
          _currentPosition = Duration.zero;
          _stopPlaybackPoll();
        } else {
          _currentPosition = newPos;
        }
        notifyListeners();
      }
    });
  }

  void _stopPlaybackPoll() {
    _playbackPollTimer?.cancel();
    _playbackPollTimer = null;
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackPollTimer?.cancel();
    super.dispose();
  }
}
