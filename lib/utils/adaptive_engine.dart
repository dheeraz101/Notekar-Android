import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

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

  PerformanceTier get tier => _tier;
  int get ramGb => _ramGb;
  int get processors => _processors;
  String get model => _model;
  String get osVersion => _osVersion;

  bool get isLowEnd => _tier == PerformanceTier.low;
  bool get supportsBlur => _tier != PerformanceTier.low;
  bool get supportsAdvancedAnimations => _tier == PerformanceTier.high;

  Future<void> initialize() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _model = '${androidInfo.manufacturer} ${androidInfo.model}';
      _osVersion = 'Android ${androidInfo.version.release}';
      _processors = Platform.numberOfProcessors;
      
      // On Android, we can estimate RAM (this is a heuristic)
      // High-end usually has 8GB+, Balanced 4-6GB, Low < 4GB.
      // Since device_info_plus doesn't give exact RAM on all Android versions easily without extra code,
      // we'll use processors and OS version as primary indicators for now.
      if (_processors <= 4 || androidInfo.version.sdkInt < 29) {
        _tier = PerformanceTier.low;
      } else if (_processors >= 8) {
        _tier = PerformanceTier.high;
      } else {
        _tier = PerformanceTier.balanced;
      }
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _model = iosInfo.utsname.machine;
      _osVersion = 'iOS ${iosInfo.systemVersion}';
      _processors = Platform.numberOfProcessors;
      
      // iOS is generally more optimized, but older models (like iPhone 8) might be "Balanced"
      if (_processors <= 2) {
        _tier = PerformanceTier.low;
      } else if (_processors >= 6) {
        _tier = PerformanceTier.high;
      } else {
        _tier = PerformanceTier.balanced;
      }
    }
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
