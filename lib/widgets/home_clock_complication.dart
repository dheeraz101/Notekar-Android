import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Apple Watch-grade complication displayed beneath the live horology clock face.
///
/// Supported complication styles:
/// - `intentionality`: Today's intentional focus duration & target ratio
/// - `streak`: Active habit streak count
/// - `circadian`: Current circadian window & peak focus phase
/// - `void`: Pure blank stillness (zero distractions)
class HomeClockComplication extends StatelessWidget {
  const HomeClockComplication({
    super.key,
    required this.p,
    required this.style,
    required this.entries,
    required this.streak,
    this.isLiveSession = false,
    this.liveSessionColor,
    this.onTap,
    this.onLongPress,
  });

  final Palette p;
  final String style;
  final List<Moment> entries;
  final int streak;
  final bool isLiveSession;
  final Color? liveSessionColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  String _formatDuration(Duration d) {
    final totalMinutes = d.inMinutes;
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    if (style == 'void') {
      return const SizedBox.shrink();
    }

    final today = dateKey(DateTime.now());
    final todayMoments = entries.where((e) => e.date == today).toList();
    final sections = buildTimelineDaySections(todayMoments);
    final totalToday = sections.isNotEmpty
        ? sections.first.totalTrackedDuration
        : Duration.zero;

    final content = switch (style) {
      'streak' => _buildStreakComplication(context),
      'circadian' => _buildCircadianComplication(context, todayMoments),
      _ => _buildIntentionalityComplication(context, totalToday),
    };

    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Live Dynamic Color Glow: 8% opacity radial ambient light behind complication when session is live
          if (isLiveSession && liveSessionColor != null)
            Positioned(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 220,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: RadialGradient(
                      radius: 0.85,
                      colors: [
                        liveSessionColor!.withValues(alpha: 0.08),
                        liveSessionColor!.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          PressableScale(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: p.surface2.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: p.border.withValues(alpha: 0.18),
                  width: 0.5,
                ),
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntentionalityComplication(
    BuildContext context,
    Duration totalToday,
  ) {
    const baseline = Duration(hours: 10);
    final ratio = baseline.inMilliseconds > 0
        ? (totalToday.inMilliseconds / baseline.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final percent = (ratio * 100).toInt();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CupertinoIcons.scope, size: 11, color: p.accent),
        const SizedBox(width: 5),
        Text(
          '${_formatDuration(totalToday)} / 10h',
          style: TextStyle(
            color: p.text2,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            '•',
            style: TextStyle(
              color: p.text3.withValues(alpha: 0.5),
              fontSize: 9,
            ),
          ),
        ),
        Text(
          '$percent% Intentional',
          style: TextStyle(
            color: p.accent,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakComplication(BuildContext context) {
    final count = streak > 0 ? streak : 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 11)),
        const SizedBox(width: 5),
        Text(
          '$count days streak',
          style: TextStyle(
            color: p.orange,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            '•',
            style: TextStyle(
              color: p.text3.withValues(alpha: 0.5),
              fontSize: 9,
            ),
          ),
        ),
        Text(
          'Active Flow',
          style: TextStyle(
            color: p.text3,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCircadianComplication(
    BuildContext context,
    List<Moment> todayMoments,
  ) {
    final now = DateTime.now();
    final hour = now.hour;

    final (phase, icon, col) = switch (hour) {
      >= 6 && < 12 => (
        'Morning Horizon',
        CupertinoIcons.sunrise_fill,
        p.orange,
      ),
      >= 12 && < 17 => (
        'Peak Focus Window',
        CupertinoIcons.sun_max_fill,
        p.accent,
      ),
      >= 17 && < 21 => (
        'Evening Wind-Down',
        CupertinoIcons.sunset_fill,
        const Color(0xFFAF52DE),
      ),
      _ => (
        'Night Recovery',
        CupertinoIcons.moon_stars_fill,
        const Color(0xFF30B0C7),
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: col),
        const SizedBox(width: 5),
        Text(
          phase,
          style: TextStyle(
            color: col,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            '•',
            style: TextStyle(
              color: p.text3.withValues(alpha: 0.5),
              fontSize: 9,
            ),
          ),
        ),
        Text(
          'Circadian',
          style: TextStyle(
            color: p.text3,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
