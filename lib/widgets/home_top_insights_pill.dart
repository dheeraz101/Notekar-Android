import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/glass.dart';
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
    final (slotName, slotRange, percentage) = _computeTimeSlotBias();

    final label = entries.isEmpty
        ? 'Activity Insights • Tap to explore'.localized(context)
        : '$slotName ($slotRange) • $percentage%';

    return Center(
      child: PressableScale(
        onTap: () {
          NotekarHaptics.selection('standard');
          onTap();
        },
        child: Glass(
          p: p,
          blur: blur,
          radius: 999,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: math.min(
                MediaQuery.sizeOf(context).width - spacing32,
                340,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.sparkles,
                    color: p.accent,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: p.text3, size: 16),
              ],
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
}
