import 'dart:async';

import 'package:flutter/services.dart';
import 'package:notekar/utils/adaptive_engine.dart';

/// Intelligent Device Health & Battery Adaptation Manager.
///
/// Connects canvas animations, waveforms, and shaders directly to Android's
/// PowerManager.isPowerSaveMode, battery capacity, and charging status.
class DeviceHealthManager {
  DeviceHealthManager._();

  static final DeviceHealthManager instance = DeviceHealthManager._();

  static const _fileChannel = MethodChannel('notekar/files');

  bool _isPowerSaveMode = false;
  int _batteryLevel = 100;
  bool _isPluggedIn = false;
  bool _isInitialized = false;

  // Manual override for testing and debugging
  bool? _forceThrottled;

  bool get isPowerSaveMode => _isPowerSaveMode;

  int get batteryLevel => _batteryLevel;

  bool get isPluggedIn => _isPluggedIn;

  bool get isInitialized => _isInitialized;

  /// Whether the chipset is considered low-end by hardware heuristics.
  bool get isLowEndChipset => AdaptiveEngine().isLowEnd;

  /// Whether canvas and physics animations should be throttled down to static vector representations.
  /// Triggered on:
  /// - Low-end chipsets
  /// - Battery saver mode enabled (PowerManager.isPowerSaveMode)
  /// - Battery below 20% while unplugged
  bool get shouldThrottle {
    if (_forceThrottled != null) return _forceThrottled!;
    if (isLowEndChipset) return true;
    if (_isPowerSaveMode) return true;
    if (!_isPluggedIn && _batteryLevel < 20) return true;
    return false;
  }

  /// Target FPS:
  /// - Flagship / Plugged In: 120 FPS high-precision physics simulation
  /// - Balanced: 60 FPS
  /// - Battery Saver / Low-End: 0 (Static vector curve with zero timer ticks)
  int get targetFps {
    if (shouldThrottle) return 0;
    if (_isPluggedIn || AdaptiveEngine().tier == PerformanceTier.high) {
      return 120;
    }
    return 60;
  }

  /// Whether subtle shader glows should be rendered.
  bool get enableGlowShader =>
      !shouldThrottle && AdaptiveEngine().tier == PerformanceTier.high;

  /// Refreshes device battery telemetry from native Android platform channel.
  Future<void> refresh() async {
    try {
      final powerSave =
          await _fileChannel.invokeMethod<bool>('isPowerSaveMode') ?? false;
      final battery =
          await _fileChannel.invokeMethod<int>('getBatteryLevel') ?? 100;
      final plugged =
          await _fileChannel.invokeMethod<bool>('isPluggedIn') ?? false;

      _isPowerSaveMode = powerSave;
      _batteryLevel = battery;
      _isPluggedIn = plugged;
      _isInitialized = true;
    } catch (_) {
      // In tests or unsupported platforms, fallback gracefully
      _isInitialized = true;
    }
  }

  /// Initializes device battery telemetry from native Android platform channel.
  Future<void> initialize() async {
    if (_isInitialized) return;
    await refresh();
  }

  /// For unit testing: set simulated battery state.
  void setSimulatedState({
    required bool isPowerSaveMode,
    required int batteryLevel,
    required bool isPluggedIn,
  }) {
    _isPowerSaveMode = isPowerSaveMode;
    _batteryLevel = batteryLevel;
    _isPluggedIn = isPluggedIn;
    _forceThrottled = null;
    _isInitialized = true;
  }

  /// For testing: force throttled state on or off.
  void setForceThrottled(bool? throttled) {
    _forceThrottled = throttled;
  }
}
