import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/checkpoint_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fast-entry horizontal chip bar for habit checkpoints with collapsible state,
/// whisper-thin styling, and 2-way session configuration.
class CheckpointsQuickBar extends StatefulWidget {
  const CheckpointsQuickBar({
    super.key,
    required this.p,
    required this.moments,
    required this.onLogCheckpoint,
    this.onOpenDashboard,
    this.initialCollapsed = false,
  });

  final Palette p;
  final List<Moment> moments;
  final void Function(CheckpointPreset preset) onLogCheckpoint;
  final VoidCallback? onOpenDashboard;
  final bool initialCollapsed;

  @override
  State<CheckpointsQuickBar> createState() => _CheckpointsQuickBarState();
}

class _CheckpointsQuickBarState extends State<CheckpointsQuickBar> {
  static const String _prefCollapsedKey = 'notekar.checkpoints_bar_collapsed';
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initialCollapsed;
    _loadCollapsedPref();
  }

  Future<void> _loadCollapsedPref() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final val = sp.getBool(_prefCollapsedKey);
      if (val != null && mounted) {
        setState(() => _isCollapsed = val);
      }
    } catch (_) {}
  }

  Future<void> _toggleCollapsed() async {
    HapticFeedback.selectionClick();
    setState(() => _isCollapsed = !_isCollapsed);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool(_prefCollapsedKey, _isCollapsed);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final presets = CheckpointService.instance.presets;
    int completedCount = 0;
    for (final pr in presets) {
      if (CheckpointService.instance.isCompletedToday(pr.id, widget.moments)) {
        completedCount++;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decluttered Minimalist Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            child: Row(
              children: [
                PressableScale(
                  onTap: _toggleCollapsed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: p.border.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_rounded, size: 12, color: p.accent),
                        const SizedBox(width: 4),
                        Text(
                          'Habits ($completedCount/${presets.length})'
                              .localized(context),
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isCollapsed
                              ? CupertinoIcons.chevron_down
                              : CupertinoIcons.chevron_up,
                          size: 11,
                          color: p.text3,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.onOpenDashboard != null)
                  PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onOpenDashboard!();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Insights'.localized(context),
                            style: TextStyle(
                              color: p.text3,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 13,
                            color: p.text3,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Collapsible Horizontal Chip Scroll
          if (!_isCollapsed) ...[
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  ...presets.map((preset) {
                    final isDone = CheckpointService.instance.isCompletedToday(
                      preset.id,
                      widget.moments,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: PressableScale(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onLogCheckpoint(preset);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5.5,
                          ),
                          decoration: BoxDecoration(
                            color: isDone
                                ? p.accent.withValues(alpha: 0.12)
                                : p.surface2,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: isDone
                                  ? p.accent.withValues(alpha: 0.45)
                                  : p.border.withValues(alpha: 0.5),
                              width: isDone ? 1.0 : 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                preset.emoji,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4.5),
                              Text(
                                preset.label,
                                style: TextStyle(
                                  color: isDone ? p.accent : p.text,
                                  fontSize: 11,
                                  fontWeight: isDone
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                              if (isDone) ...[
                                const SizedBox(width: 3.5),
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 11.5,
                                  color: p.accent,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
