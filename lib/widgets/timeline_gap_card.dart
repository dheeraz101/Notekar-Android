import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Clean Apple HIG card representing an untracked gap between sessions or moments.
class TimelineGapCard extends StatefulWidget {
  const TimelineGapCard({
    super.key,
    required this.p,
    required this.startTimestamp,
    required this.endTimestamp,
    this.onTap,
    this.onClaimRest,
    this.isProcessing = false,
  });

  final Palette p;
  final int startTimestamp;
  final int endTimestamp;
  final VoidCallback? onTap;
  final VoidCallback? onClaimRest;
  final bool isProcessing;

  @override
  State<TimelineGapCard> createState() => _TimelineGapCardState();
}

class _TimelineGapCardState extends State<TimelineGapCard> {
  bool _localProcessing = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool get _busy => widget.isProcessing || _localProcessing;

  Duration get duration => Duration(
    milliseconds: (widget.endTimestamp - widget.startTimestamp).clamp(0, 86400000),
  );

  String _formatDuration(Duration d) {
    final totalMins = d.inMinutes;
    if (totalMins <= 0) return '0m';
    final hours = totalMins ~/ 60;
    final mins = totalMins % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final durText = _formatDuration(duration);
    final timeSpan =
        '${timeOnly(widget.startTimestamp)} – ${timeOnly(widget.endTimestamp)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: PressableScale(
        onTap: () {
          if (widget.isProcessing) return;
          if (widget.onTap != null) {
            HapticFeedback.lightImpact();
            widget.onTap!();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: p.surface2.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: p.border.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: p.surface3.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_bottom_rounded,
                  size: 14,
                  color: p.text3,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$durText untracked',
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      timeSpan,
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onClaimRest != null && duration.inMinutes >= 15) ...[
                PressableScale(
                  onTap: () {
                    if (_busy) return;
                    setState(() => _localProcessing = true);
                    HapticFeedback.lightImpact();
                    widget.onClaimRest!();
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                      if (mounted) setState(() => _localProcessing = false);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: _busy ? 0.05 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: p.accent.withValues(alpha: _busy ? 0.15 : 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bedtime_rounded,
                          size: 11,
                          color: _busy ? p.text3 : p.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _busy ? 'Rest...' : 'Rest',
                          style: TextStyle(
                            color: _busy ? p.text3 : p.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (widget.onTap != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface3.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 11, color: p.accent),
                      const SizedBox(width: 3),
                      Text(
                        'Log',
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
