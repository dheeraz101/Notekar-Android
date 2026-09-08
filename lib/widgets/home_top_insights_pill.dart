import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class HomeTopInsightsPill extends StatelessWidget {
  const HomeTopInsightsPill({
    super.key,
    required this.p,
    required this.entries,
    required this.onTap,
    this.blur = false,
  });

  final Palette p;
  final List<Moment> entries;
  final VoidCallback onTap;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final label = _computeHumanLifeNarrative(context);

    return Center(
      child: PressableScale(
        onTap: () {
          NotekarHaptics.selection('standard');
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text3,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  (String, String, int) _computeTimeSlotBias() {
    if (entries.isEmpty) {
      return ('Insights', '', 0);
    }

    int morning = 0;
    int afternoon = 0;
    int evening = 0;
    int night = 0;

    for (final entry in entries) {
      final dt = DateTime.fromMillisecondsSinceEpoch(entry.timestamp);
      final hour = dt.hour;

      if (hour >= 6 && hour < 12) {
        morning++;
      } else if (hour >= 12 && hour < 17) {
        afternoon++;
      } else if (hour >= 17 && hour < 22) {
        evening++;
      } else {
        night++;
      }
    }

    final total = entries.length;
    String peakSlot = 'Afternoon';
    String range = '12–5 PM';
    int peakCount = afternoon;

    if (morning > peakCount) {
      peakSlot = 'Morning';
      range = '6 AM–12 PM';
      peakCount = morning;
    }
    if (evening > peakCount) {
      peakSlot = 'Evening';
      range = '5–10 PM';
      peakCount = evening;
    }
    if (night > peakCount) {
      peakSlot = 'Night';
      range = '10 PM–6 AM';
      peakCount = night;
    }

    final pct = total > 0 ? (peakCount / total * 100).round() : 0;
    return (peakSlot, range, pct);
  }

  String _computeHumanLifeNarrative(BuildContext context) {
    if (entries.isEmpty) {
      return 'Activity Insights • Tap to explore'.localized(context);
    }

    final now = DateTime.now();
    final todayKey = dateKey(now);
    final todayEntries = entries.where((e) => e.date == todayKey).toList();

    if (todayEntries.isEmpty) {
      final (slotName, _, _) = _computeTimeSlotBias();
      return 'Ready for today • Peak rhythm in $slotName'.localized(context);
    }

    final inCount = todayEntries.where((e) => e.type == 'in').length;
    final outCount = todayEntries.where((e) => e.type == 'out').length;
    if (inCount > outCount) {
      return 'Active session in flow • Tap to inspect'.localized(context);
    }

    final completedSessions = math.min(inCount, outCount);
    final (slotName, _, _) = _computeTimeSlotBias();

    if (completedSessions > 0) {
      final sessionLabel = completedSessions == 1
          ? '1 session today'
          : '$completedSessions sessions today';
      return '$sessionLabel • Peak in $slotName'.localized(context);
    }

    final singles = todayEntries.length;
    final momentLabel = singles == 1
        ? '1 moment today'
        : '$singles moments today';
    return '$momentLabel • Rhythm in flow'.localized(context);
  }
}
