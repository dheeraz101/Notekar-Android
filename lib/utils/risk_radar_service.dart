import 'package:notekar/models/moment.dart';

class RiskRadarResult {
  RiskRadarResult({
    required this.peakHourRange,
    required this.peakDayName,
    required this.riskScore,
    required this.riskLevel,
    required this.alertMessage,
  });

  final String peakHourRange;
  final String peakDayName;
  final int riskScore; // 0 to 100
  final String riskLevel; // 'Low', 'Moderate', 'High'
  final String alertMessage;
}

class RiskRadarService {
  static RiskRadarResult analyze(List<Moment> entries) {
    if (entries.isEmpty) {
      return RiskRadarResult(
        peakHourRange: 'None',
        peakDayName: 'None',
        riskScore: 10,
        riskLevel: 'Low',
        alertMessage: 'No logs recorded yet. Maintain clean daily habits!',
      );
    }

    // Filter relapse or trigger moments
    final relapseEntries = entries
        .where(
          (e) =>
              e.note.contains('#relapse') ||
              e.note.contains('#shielded') ||
              e.note.contains('#trigger'),
        )
        .toList();

    final targetEntries = relapseEntries.isNotEmpty ? relapseEntries : entries;

    // Hour frequencies (0-23)
    final hourCounts = List<int>.filled(24, 0);
    // Day frequencies (1-7, Mon-Sun)
    final dayCounts = List<int>.filled(8, 0);

    for (final e in targetEntries) {
      final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp);
      hourCounts[dt.hour]++;
      dayCounts[dt.weekday]++;
    }

    // Find peak hour
    int maxHour = 0;
    int maxHourCount = 0;
    for (int h = 0; h < 24; h++) {
      if (hourCounts[h] > maxHourCount) {
        maxHourCount = hourCounts[h];
        maxHour = h;
      }
    }

    // Find peak day
    int maxDay = 1;
    int maxDayCount = 0;
    for (int d = 1; d <= 7; d++) {
      if (dayCounts[d] > maxDayCount) {
        maxDayCount = dayCounts[d];
        maxDay = d;
      }
    }

    final dayNames = [
      '',
      'Mondays',
      'Tuesdays',
      'Wednesdays',
      'Thursdays',
      'Fridays',
      'Saturdays',
      'Sundays',
    ];
    final peakDayName = dayNames[maxDay];

    final startHour = maxHour;
    final endHour = (maxHour + 3) % 24;
    final formatStart = startHour == 0
        ? '12 AM'
        : (startHour > 12 ? '${startHour - 12} PM' : '$startHour AM');
    final formatEnd = endHour == 0
        ? '12 AM'
        : (endHour > 12 ? '${endHour - 12} PM' : '$endHour AM');
    final peakHourRange = '$formatStart – $formatEnd';

    // Compute Risk Score
    final totalRelapses = relapseEntries.length;
    int riskScore = 15;
    if (totalRelapses > 0) {
      riskScore = (totalRelapses * 12 + maxHourCount * 15).clamp(20, 95);
    }

    String riskLevel = 'Low';
    if (riskScore >= 65) {
      riskLevel = 'High';
    } else if (riskScore >= 35) {
      riskLevel = 'Moderate';
    }

    String alertMessage =
        'Pattern stable. Continue your daily mindfulness check-ins!';
    if (riskLevel == 'High') {
      alertMessage =
          'High-Risk Window: $peakDayName between $peakHourRange. Stay alert & use Urge Surfing if triggered!';
    } else if (riskLevel == 'Moderate') {
      alertMessage =
          'Moderate Trigger Pattern: $peakDayName around $formatStart. Keep awareness strong!';
    }

    return RiskRadarResult(
      peakHourRange: peakHourRange,
      peakDayName: peakDayName,
      riskScore: riskScore,
      riskLevel: riskLevel,
      alertMessage: alertMessage,
    );
  }
}
