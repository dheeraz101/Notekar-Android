import 'package:flutter/material.dart';
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

    return AppSheet(
      p: widget.p,
      title: 'Select Date',
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
            Row(
              children: [
                for (final label in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.p.text3,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: rowCount * 44,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: 42,
                ),
                itemCount: rowCount * 7,
                itemBuilder: (_, index) {
                  final day = index - leading + 1;
                  if (day < 1 || day > days) return const SizedBox.shrink();
                  final date = DateTime(_month.year, _month.month, day);
                  final key = dateKey(date);
                  final available = widget.availableDateKeys.contains(key);
                  final selected = key == dateKey(widget.initialDate);
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: PressableScale(
                      enabled: available,
                      onTap: available
                          ? () => Navigator.pop(context, date)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: available
                              ? widget.p.surface2
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: available
                                ? widget.p.border
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                color: selected
                                    ? widget.p.accent
                                    : available
                                    ? widget.p.text
                                    : widget.p.text3.withValues(alpha: 0.42),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: available
                                    ? widget.p.accent
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
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
