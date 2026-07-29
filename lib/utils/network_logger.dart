import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NetworkLogEntry {
  final String url;
  final String method;
  final int statusCode;
  final DateTime timestamp;
  final String purpose;
  final String size;

  NetworkLogEntry({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.timestamp,
    required this.purpose,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'method': method,
    'statusCode': statusCode,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'purpose': purpose,
    'size': size,
  };

  factory NetworkLogEntry.fromJson(Map<String, dynamic> json) =>
      NetworkLogEntry(
        url: (json['url'] as String?) ?? '',
        method: (json['method'] as String?) ?? 'GET',
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (json['timestamp'] as num?)?.toInt() ??
              DateTime.now().millisecondsSinceEpoch,
        ),
        purpose: (json['purpose'] as String?) ?? '',
        size: (json['size'] as String?) ?? 'Unknown',
      );
}

class NetworkLogger {
  static const String _key = 'notekar_network_logs';

  static Future<List<NetworkLogEntry>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List<dynamic> decoded = json.decode(jsonStr) as List<dynamic>;
      return decoded
          .map(
            (e) => NetworkLogEntry.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> log({
    required String url,
    required String method,
    required int statusCode,
    required String purpose,
    required String size,
  }) async {
    try {
      final logs = await getLogs();
      final entry = NetworkLogEntry(
        url: url,
        method: method,
        statusCode: statusCode,
        timestamp: DateTime.now(),
        purpose: purpose,
        size: size,
      );
      logs.insert(0, entry);
      if (logs.length > 50) {
        logs.removeRange(50, logs.length);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        json.encode(logs.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  static Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
