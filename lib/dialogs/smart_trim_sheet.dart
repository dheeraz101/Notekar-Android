import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/manual_entry_dialog.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Shows an Apple HIG Smart Trim modal when a session exceeds 3 hours.
/// Returns the chosen DateTime end time (or original if kept or dismissed).
Future<DateTime?> showSmartTrimSheet(
  BuildContext context, {
  required Palette p,
  required DateTime startDateTime,
  required DateTime originalEndDateTime,
  required String category,
  bool blur = false,
  bool largeText = false,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => SmartTrimSheet(
      p: p,
      startDateTime: startDateTime,
      originalEndDateTime: originalEndDateTime,
      category: category,
      blur: blur,
      largeText: largeText,
    ),
  );
}

class SmartTrimSheet extends StatefulWidget {
  const SmartTrimSheet({
    super.key,
    required this.p,
    required this.startDateTime,
    required this.originalEndDateTime,
    required this.category,
    this.blur = false,
    this.largeText = false,
  });

  final Palette p;
  final DateTime startDateTime;
  final DateTime originalEndDateTime;
  final String category;
  final bool blur;
  final bool largeText;

  @override
  State<SmartTrimSheet> createState() => _SmartTrimSheetState();
}

class _SmartTrimSheetState extends State<SmartTrimSheet> {
  late DateTime _selectedEndTime;

  Duration get _totalDuration =>
      widget.originalEndDateTime.difference(widget.startDateTime);

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  @override
  void initState() {
    super.initState();
    _selectedEndTime = widget.originalEndDateTime;
  }

  void _confirm(DateTime time) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(time);
  }

  Future<void> _pickCustomTime() async {
    final picked = await showCupertinoDatePickerSheet(
      context,
      p: widget.p,
      title: 'End Time',
      initialDateTime: _selectedEndTime,
      minimumDate: widget.startDateTime,
      maximumDate: widget.originalEndDateTime,
      mode: CupertinoDatePickerMode.time,
    );
    if (picked != null) {
      _confirm(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final durStr = _formatDuration(_totalDuration);
    final startTimeStr = timeOnly(widget.startDateTime.millisecondsSinceEpoch);
    final endTimeStr = timeOnly(
      widget.originalEndDateTime.millisecondsSinceEpoch,
    );

    // Calculate smart presets
    final flow90 = widget.startDateTime.add(const Duration(minutes: 90));
    final pomodoro45 = widget.startDateTime.add(const Duration(minutes: 45));
    final hours2 = widget.startDateTime.add(const Duration(hours: 2));

    final canOffer90 = _totalDuration.inMinutes > 95;
    final canOffer45 = _totalDuration.inMinutes > 50;
    final canOffer2h = _totalDuration.inMinutes > 130;

    return AppSheet(
      p: widget.p,
      title: 'Session Complete',
      blur: widget.blur,
      largeText: widget.largeText,
      child: Padding(
        padding: const EdgeInsets.only(bottom: spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.p.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.p.border.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.p.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.sparkles,
                      color: widget.p.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$durStr in ${widget.category}',
                          style: TextStyle(
                            color: widget.p.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$startTimeStr – $endTimeStr',
                          style: TextStyle(color: widget.p.text3, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: spacing16),

            Text(
              'Did you finish earlier, or was this continuous flow?'.localized(
                context,
              ),
              style: TextStyle(
                color: widget.p.text2,
                fontSize: 13,
                height: 1.35,
              ),
            ),

            const SizedBox(height: spacing16),

            // 1. Keep Full Duration (Default Action - primary button)
            PressableScale(
              onTap: () => _confirm(widget.originalEndDateTime),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.p.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.p.accent.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: widget.p.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keep Full $durStr'.localized(context),
                            style: TextStyle(
                              color: widget.p.text,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Logged until $endTimeStr'.localized(context),
                            style: TextStyle(
                              color: widget.p.text3,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: widget.p.text3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: spacing8),

            // Smart Presets Row
            if (canOffer90 || canOffer45 || canOffer2h) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (canOffer90)
                    _buildTrimChip(
                      label: 'Trim to 90m Flow',
                      subtitle: timeOnly(flow90.millisecondsSinceEpoch),
                      onTap: () => _confirm(flow90),
                    ),
                  if (canOffer2h)
                    _buildTrimChip(
                      label: 'Trim to 2 Hours',
                      subtitle: timeOnly(hours2.millisecondsSinceEpoch),
                      onTap: () => _confirm(hours2),
                    ),
                  if (canOffer45)
                    _buildTrimChip(
                      label: 'Trim to 45m',
                      subtitle: timeOnly(pomodoro45.millisecondsSinceEpoch),
                      onTap: () => _confirm(pomodoro45),
                    ),
                ],
              ),
              const SizedBox(height: spacing8),
            ],

            // Custom End Time Button
            PressableScale(
              onTap: _pickCustomTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.p.surface3.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.p.border.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.clock, size: 15, color: widget.p.text2),
                    const SizedBox(width: 8),
                    Text(
                      'Choose Custom End Time'.localized(context),
                      style: TextStyle(
                        color: widget.p.text2,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrimChip({
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.p.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.p.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.localized(context),
              style: TextStyle(
                color: widget.p.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(color: widget.p.text3, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}
