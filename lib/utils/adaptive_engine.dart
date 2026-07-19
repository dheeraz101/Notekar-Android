import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PerformanceTier {
  low,
  balanced,
  high,
}

class AdaptiveEngine {
  static final AdaptiveEngine _instance = AdaptiveEngine._internal();
  factory AdaptiveEngine() => _instance;
  AdaptiveEngine._internal();

  PerformanceTier _tier = PerformanceTier.balanced;
  int _ramGb = 0;
  int _processors = 0;
  String _model = 'Unknown';
  String _osVersion = 'Unknown';
  bool? _cachedSensorAvailable;

  PerformanceTier get tier => _tier;
  int get ramGb => _ramGb;
  int get processors => _processors;
  String get model => _model;
  String get osVersion => _osVersion;

  bool get isLowEnd => _tier == PerformanceTier.low;
  bool get supportsBlur => _tier != PerformanceTier.low;
  bool get supportsAdvancedAnimations => _tier == PerformanceTier.high;
  bool? get cachedSensorAvailable => _cachedSensorAvailable;

  Future<void> initialize({SharedPreferences? prefs}) async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final deviceInfo = DeviceInfoPlugin();

    // Try to load cached RAM and sensor state
    _ramGb = effectivePrefs.getInt('device_total_ram_gb') ?? 0;
    _cachedSensorAvailable = effectivePrefs.getBool('device_sensor_available');
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _model = '${androidInfo.manufacturer} ${androidInfo.model}';
      _osVersion = 'Android ${androidInfo.version.release}';
      _processors = Platform.numberOfProcessors;
      
      // If RAM is not cached, detect it
      if (_ramGb == 0) {
        _ramGb = await _detectAndroidRam();
        await effectivePrefs.setInt('device_total_ram_gb', _ramGb);
      }

      // Intelligent Heuristic for Android
      // We consider RAM < 4GB OR cores <= 4 as "Low"
      // Balanced: RAM 4-6GB
      // High: RAM > 6GB AND 8+ cores
      final isWeakRam = _ramGb > 0 && _ramGb < 4;
      final isWeakCPU = _processors <= 4;
      final isStrongRam = _ramGb >= 7; // Usually 8GB devices report ~7.5GB
      final isStrongCPU = _processors >= 8;
      final isModernSDK = androidInfo.version.sdkInt >= 33;

      if (isWeakRam || isWeakCPU || androidInfo.version.sdkInt < 29) {
        _tier = PerformanceTier.low;
      } else if (isStrongRam && isStrongCPU && isModernSDK) {
        _tier = PerformanceTier.high;
      } else {
        _tier = PerformanceTier.balanced;
      }
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _model = iosInfo.utsname.machine;
      _osVersion = 'iOS ${iosInfo.systemVersion}';
      _processors = Platform.numberOfProcessors;
      
      // iOS Heuristic (Simplified as iOS RAM is harder to get but OS is optimized)
      if (_processors <= 2) {
        _tier = PerformanceTier.low;
        _ramGb = 2;
      } else if (_processors >= 6) {
        _tier = PerformanceTier.high;
        _ramGb = 6;
      } else {
        _tier = PerformanceTier.balanced;
        _ramGb = 4;
      }
    }
  }

  Future<int> _detectAndroidRam() async {
    try {
      final file = File('/proc/meminfo');
      if (await file.exists()) {
        final lines = await file.readAsLines();
        for (final line in lines) {
          if (line.startsWith('MemTotal:')) {
            // Format: MemTotal:        7765188 kB
            final match = RegExp(r'(\d+)').firstMatch(line);
            if (match != null) {
              final kb = int.parse(match.group(1)!);
              // Convert to GB: (KB / 1024 / 1024) and round up/down
              return (kb / (1024 * 1024)).round();
            }
          }
        }
      }
    } catch (_) {}
    return 0;
  }

  String get healthStatus {
    return switch (_tier) {
      PerformanceTier.low => 'Low',
      PerformanceTier.balanced => 'Smooth',
      PerformanceTier.high => 'Fast',
    };
  }

  String get tierLabel {
    return switch (_tier) {
      PerformanceTier.low => 'Power Saver',
      PerformanceTier.balanced => 'Balanced',
      PerformanceTier.high => 'Optimal',
    };
  }

  String get optimizationSummary {
    return switch (_tier) {
      PerformanceTier.low => 'Visual effects and background blur are disabled to ensure smooth performance.',
      PerformanceTier.balanced => 'Standard visual effects enabled. Background blur optimized for efficiency.',
      PerformanceTier.high => 'All premium visual effects and high-fidelity animations are enabled.',
    };
  }
}
