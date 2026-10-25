import 'dart:convert';

/// Represents an exported or scanned NoteKar peer's temporal life horizon profile.
class PeerProfile {
  const PeerProfile({
    required this.name,
    this.dob = '',
    required this.targetYears,
    required this.ageYears,
    required this.lifeClockFormatted,
    required this.lifeClockTimeOfDay,
    required this.remainingWeeks,
    required this.livedPercentage,
    required this.timestamp,
  });

  final String name;
  final String dob;
  final int targetYears;
  final double ageYears;
  final String lifeClockFormatted;
  final String lifeClockTimeOfDay;
  final int remainingWeeks;
  final double livedPercentage;
  final int timestamp;

  Map<String, dynamic> toJson() => {
    'v': 1,
    'name': name,
    'dob': dob,
    'target': targetYears,
    'age': double.parse(ageYears.toStringAsFixed(1)),
    'clock': lifeClockFormatted,
    'phase': lifeClockTimeOfDay,
    'weeks': remainingWeeks,
    'lived': double.parse(livedPercentage.toStringAsFixed(3)),
    'ts': timestamp,
  };

  factory PeerProfile.fromJson(Map<String, dynamic> json) {
    return PeerProfile(
      name: (json['name'] as String?)?.trim() ?? 'Explorer',
      dob: (json['dob'] as String?) ?? '',
      targetYears: (json['target'] as num?)?.toInt() ?? 80,
      ageYears: (json['age'] as num?)?.toDouble() ?? 25.0,
      lifeClockFormatted: (json['clock'] as String?) ?? '08:00',
      lifeClockTimeOfDay: (json['phase'] as String?) ?? 'Morning',
      remainingWeeks: (json['weeks'] as num?)?.toInt() ?? 2800,
      livedPercentage: (json['lived'] as num?)?.toDouble() ?? 0.312,
      timestamp:
          (json['ts'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Compact QR code payload string.
  /// Formatted as standard URI: notekar://peer?v=1&name=...
  String toQrPayload() {
    final uri = Uri(
      scheme: 'notekar',
      host: 'peer',
      queryParameters: {
        'v': '1',
        'n': name,
        'd': dob,
        't': targetYears.toString(),
        'a': ageYears.toStringAsFixed(1),
        'c': lifeClockFormatted,
        'p': lifeClockTimeOfDay,
        'w': remainingWeeks.toString(),
        'l': livedPercentage.toStringAsFixed(3),
        's': timestamp.toString(),
      },
    );
    return uri.toString();
  }

  /// Parses a QR payload string (either notekar:// URI or JSON object).
  static PeerProfile? fromQrPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // 1. Try URI parsing
    if (trimmed.startsWith('notekar://peer')) {
      try {
        final uri = Uri.parse(trimmed);
        final q = uri.queryParameters;
        return PeerProfile(
          name: q['n']?.trim().isNotEmpty == true ? q['n']!.trim() : 'Explorer',
          dob: q['d'] ?? '',
          targetYears: int.tryParse(q['t'] ?? '80') ?? 80,
          ageYears: double.tryParse(q['a'] ?? '25') ?? 25.0,
          lifeClockFormatted: q['c'] ?? '08:00',
          lifeClockTimeOfDay: q['p'] ?? 'Morning',
          remainingWeeks: int.tryParse(q['w'] ?? '2800') ?? 2800,
          livedPercentage: double.tryParse(q['l'] ?? '0.312') ?? 0.312,
          timestamp:
              int.tryParse(q['s'] ?? '') ??
              DateTime.now().millisecondsSinceEpoch,
        );
      } catch (_) {}
    }

    // 2. Try JSON parsing
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final decoded = jsonDecode(trimmed) as Map<String, dynamic>;
        return PeerProfile.fromJson(decoded);
      } catch (_) {}
    }

    return null;
  }
}
