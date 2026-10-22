import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Modal bottom sheet allowing users to log a habit checkpoint as a full Two-Way Session
/// with interactive start and end points, quick duration chips, optional notes, or start live.
class CheckpointSessionSheet extends StatefulWidget {
  const CheckpointSessionSheet({
    super.key,
    required this.p,
    required this.preset,
    required this.onLogSession,
    this.onStartLive,
    this.onLogSingle,
  });

  final Palette p;
  final CheckpointPreset preset;
  final Future<void> Function({
    required DateTime start,
    required DateTime end,
    String? note,
  })
  onLogSession;
  final Future<void> Function({required DateTime start, String? note})?
  onStartLive;
  final Future<void> Function({required DateTime timestamp, String? note})?
  onLogSingle;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required CheckpointPreset preset,
    required Future<void> Function({
      required DateTime start,
      required DateTime end,
      String? note,
    })
    onLogSession,
    Future<void> Function({required DateTime start, String? note})? onStartLive,
    Future<void> Function({required DateTime timestamp, String? note})?
    onLogSingle,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: kTelegramSpringSheetAnimation,
      builder: (ctx) => CheckpointSessionSheet(
        p: p,
        preset: preset,
        onLogSession: onLogSession,
        onStartLive: onStartLive,
        onLogSingle: onLogSingle,
      ),
    );
  }

  @override
  State<CheckpointSessionSheet> createState() => _CheckpointSessionSheetState();
}

class _CheckpointSessionSheetState extends State<CheckpointSessionSheet> {
  late DateTime _endPoint;
  late DateTime _startPoint;
  int _selectedDurationMinutes = 30;
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  static const List<int> _quickDurations = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endPoint = now;
    _startPoint = now.subtract(Duration(minutes: _selectedDurationMinutes));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Duration get _currentDuration {
    final diff = _endPoint.difference(_startPoint);
    return diff.isNegative ? Duration.zero : diff;
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String _formatTimeOnly(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $ampm';
  }

  void _applyDuration(int minutes) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDurationMinutes = minutes;
      _startPoint = _endPoint.subtract(Duration(minutes: minutes));
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    HapticFeedback.selectionClick();
    final initialDt = isStart ? _startPoint : _endPoint;
    DateTime tempDt = initialDt;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: widget.p.surface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel'.localized(context),
                        style: TextStyle(color: widget.p.text3),
                      ),
                    ),
                    Text(
                      isStart
                          ? 'Select Start Point'.localized(context)
                          : 'Select End Point'.localized(context),
                      style: TextStyle(
                        color: widget.p.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          if (isStart) {
                            _startPoint = tempDt;
                            if (_startPoint.isAfter(_endPoint)) {
                              _endPoint = _startPoint.add(
                                Duration(minutes: _selectedDurationMinutes),
                              );
                            }
                          } else {
                            _endPoint = tempDt;
                            if (_endPoint.isBefore(_startPoint)) {
                              _startPoint = _endPoint.subtract(
                                Duration(minutes: _selectedDurationMinutes),
                              );
                            }
                          }
                          _selectedDurationMinutes = _endPoint
                              .difference(_startPoint)
                              .inMinutes;
                        });
                      },
                      child: Text(
                        'Done'.localized(context),
                        style: TextStyle(
                          color: widget.p.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: initialDt,
                  maximumDate: DateTime.now().add(const Duration(hours: 1)),
                  onDateTimeChanged: (newDt) => tempDt = newDt,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSaveSession() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    try {
      await widget.onLogSession(
        start: _startPoint,
        end: _endPoint,
        note: _noteController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleStartLive() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    try {
      await widget.onStartLive?.call(
        start: _startPoint,
        note: _noteController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleLogSingle() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();
    try {
      await widget.onLogSingle?.call(
        timestamp: _startPoint,
        note: _noteController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final preset = widget.preset;
    final catMeta = getCategoryMeta(preset.category, p);
    final durationStr = _formatDuration(_currentDuration);

    return AppSheet(
      p: p,
      title: '${preset.emoji} ${preset.label}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category & Target Time Badge Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: catMeta.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: catMeta.color.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(catMeta.icon, size: 12, color: catMeta.color),
                    const SizedBox(width: 4),
                    Text(
                      preset.category,
                      style: TextStyle(
                        color: catMeta.color,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (preset.formattedTargetTime.isNotEmpty)
                Text(
                  'Target: ${preset.formattedTargetTime}'.localized(context),
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: spacing16),

          // Interactive Start & End Points Hero Card
          Container(
            padding: const EdgeInsets.all(spacing16),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Start Point Tile
                    Expanded(
                      child: PressableScale(
                        onTap: () => _pickTime(isStart: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: p.surface3.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: p.border.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    size: 14,
                                    color: p.green,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'START POINT'.localized(context),
                                    style: TextStyle(
                                      color: p.text3,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimeOnly(_startPoint),
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Duration Connector Arrow
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: p.text3,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: p.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              durationStr,
                              style: TextStyle(
                                color: p.accent,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // End Point Tile
                    Expanded(
                      child: PressableScale(
                        onTap: () => _pickTime(isStart: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: p.surface3.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: p.border.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.stop_rounded,
                                    size: 14,
                                    color: p.red,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'END POINT'.localized(context),
                                    style: TextStyle(
                                      color: p.text3,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimeOnly(_endPoint),
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: spacing12),

                // Quick Duration Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _quickDurations.map((mins) {
                      final isSelected = _selectedDurationMinutes == mins;
                      final label = mins >= 60
                          ? (mins % 60 == 0
                                ? '${mins ~/ 60}h'
                                : '${mins ~/ 60}h ${mins % 60}m')
                          : '${mins}m';

                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: PressableScale(
                          onTap: () => _applyDuration(mins),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? p.accent : p.surface3,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? p.accent
                                    : p.border.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : p.text2,
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: spacing12),

          // Optional Note Composer
          TextField(
            controller: _noteController,
            style: TextStyle(color: p.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add note (optional)...'.localized(context),
              hintStyle: TextStyle(color: p.text3, fontSize: 13.5),
              filled: true,
              fillColor: p.surface2,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: p.border.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: p.border.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: p.accent, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: spacing16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _handleSaveSession,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    'Log 2-Way Session'.localized(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (widget.onStartLive != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.text,
                      side: BorderSide(color: p.border.withValues(alpha: 0.8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _handleStartLive,
                    icon: Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: p.green,
                    ),
                    label: Text(
                      'Start Live Timer Now'.localized(context),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (widget.onLogSingle != null) ...[
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: _handleLogSingle,
                child: Text(
                  'Log as single timestamp'.localized(context),
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
