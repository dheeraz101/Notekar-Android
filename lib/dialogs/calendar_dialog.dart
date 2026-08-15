import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class MomentCalendarDialog extends StatefulWidget {
  const MomentCalendarDialog({
    super.key,
    required this.p,
    required this.availableDateKeys,
    required this.initialDate,
  });

  final Palette p;
  final Set<String> availableDateKeys;
  final DateTime initialDate;

  @override
  State<MomentCalendarDialog> createState() => _MomentCalendarDialogState();
}

class _MomentCalendarDialogState extends State<MomentCalendarDialog> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_month.year, _month.month);
    final leading = first.weekday % 7;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final cells = leading + days;
    final rowCount = (cells / 7).ceil();
    final todayKey = dateKey(DateTime.now());

    return AppSheet(
      p: widget.p,
      title: 'Select Date',
      removeBottomPadding: true,
      child: SizedBox(
        width: 410,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month - 1);
                  }),
                  icon: Icon(Icons.chevron_left_rounded, color: widget.p.text2),
                ),
                Expanded(
                  child: Text(
                    monthLabel(_month),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.p.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month + 1);
                  }),
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: widget.p.text2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (final label in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.p.text3,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: rowCount * 46,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: 44,
                ),
                itemCount: rowCount * 7,
                itemBuilder: (_, index) {
                  final day = index - leading + 1;
                  if (day < 1 || day > days) return const SizedBox.shrink();
                  final date = DateTime(_month.year, _month.month, day);
                  final key = dateKey(date);
                  final isToday = key == todayKey;
                  final available = widget.availableDateKeys.contains(key);
                  final selected = key == dateKey(widget.initialDate);

                  // iOS Calendar Styling:
                  // 1. The currently selected date gets the solid iOS Red circle (#FF3B30) with bold white text.
                  // 2. When any other date is selected, the red circle moves to that selected date.
                  // 3. Non-selected dates (including today) have no circle, and if they contain moments, show a small event dot below.
                  final isSelected = selected;
                  final Color circleColor = isSelected
                      ? const Color(
                          0xFFFF3B30,
                        ) // iOS Calendar System Red selection circle
                      : Colors.transparent;

                  Color textColor;
                  if (isSelected) {
                    textColor = Colors.white;
                  } else if (isToday) {
                    textColor = const Color(0xFFFF3B30);
                  } else if (available) {
                    textColor = widget.p.text;
                  } else {
                    textColor = widget.p.text3.withValues(alpha: 0.28);
                  }

                  return Padding(
                    padding: const EdgeInsets.all(3),
                    child: PressableScale(
                      enabled: available || isToday,
                      onTap: available || isToday
                          ? () {
                              HapticFeedback.mediumImpact();
                              Navigator.pop(context, date);
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: circleColor.withValues(alpha: 0.30),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : (isToday || available
                                          ? FontWeight.w700
                                          : FontWeight.w500),
                              ),
                            ),
                            if (!isSelected && available) ...[
                              const SizedBox(height: 2),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? const Color(0xFFFF3B30)
                                      : widget.p.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
