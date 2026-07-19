import 'dart:developer' as developer;

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final List<String> _logs = [];
  static const int _maxLogs = 100;

  void info(String message) {
    _log('INFO', message);
  }

  void warn(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARN', message, error, stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] [$level] $message${error != null ? ': $error' : ''}';
    
    _logs.add(logEntry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    developer.log(
      message,
      name: 'notekar',
      level: _levelToInt(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _levelToInt(String level) {
    return switch (level) {
      'INFO' => 800,
      'WARN' => 900,
      'ERROR' => 1000,
      _ => 0,
    };
  }

  String get diagnosticLogs => _logs.join('\n');
}
