import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/home_category_pills.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class ManualEntryResult {
  const ManualEntryResult({
    required this.isSession,
    required this.startDateTime,
    this.endDateTime,
    required this.note,
    required this.tags,
    this.category,
  });

  final bool isSession;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String note;
  final List<String> tags;
  final String? category;
}

/// Apple HIG Manual Entry Sheet allowing users to retroactively log
/// single moments or full start/end sessions up to 30 days in the past.
class ManualEntryDialog extends StatefulWidget {
  const ManualEntryDialog({
    super.key,
    required this.p,
    required this.categories,
    this.initialCategory,
    this.prefilledStartTime,
    this.prefilledEndTime,
  });

  final Palette p;
  final List<String> categories;
  final String? initialCategory;
  final DateTime? prefilledStartTime;
  final DateTime? prefilledEndTime;

  @override
  State<ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  late bool _isSession;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _activeCategory;

  final TextEditingController _noteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _tags = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _isSession = widget.prefilledEndTime != null;

    final start =
        widget.prefilledStartTime ?? now.subtract(const Duration(hours: 1));
    final end = widget.prefilledEndTime ?? now;

    _selectedDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    _endTime = TimeOfDay(hour: end.hour, minute: end.minute);

    _activeCategory = widget.initialCategory ?? 'All';
    _loadTags();
  }

  Future<void> _loadTags() async {
    await TagService.instance.load();
    if (mounted) {
      setState(() {
        _tags = TagService.instance.customTags;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _selectDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final earliest = now.subtract(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(earliest) ? earliest : _selectedDate,
      firstDate: DateTime(earliest.year, earliest.month, earliest.day),
      lastDate: DateTime(now.year, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: widget.p.accent,
              surface: widget.p.surface2,
              onSurface: widget.p.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    HapticFeedback.selectionClick();
    final current = isStart ? _startTime : _endTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: widget.p.accent,
              surface: widget.p.surface2,
              onSurface: widget.p.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
        _errorMessage = null;
      });
    }
  }

  void _submit() {
    final startDt = _combine(_selectedDate, _startTime);
    final now = DateTime.now();

    if (startDt.isAfter(now)) {
      setState(() => _errorMessage = 'Start time cannot be in the future.');
      return;
    }

    DateTime? endDt;
    if (_isSession) {
      endDt = _combine(_selectedDate, _endTime);
      if (endDt.isBefore(startDt)) {
        // If end is before start on same date, assume it wrapped around or is invalid
        setState(() => _errorMessage = 'End time must be after start time.');
        return;
      }
      if (endDt.isAfter(now.add(const Duration(minutes: 5)))) {
        setState(() => _errorMessage = 'End time cannot be in the future.');
        return;
      }
    }

    final rawNote = _noteController.text.trim();
    final tagRegex = RegExp(r'#([a-zA-Z0-9_-]+)');
    final extractedTags = tagRegex
        .allMatches(rawNote)
        .map((m) => m.group(1)!.toLowerCase())
        .toSet()
        .toList();

    if (extractedTags.isNotEmpty) {
      TagService.instance.recordUsages(
        extractedTags.map((t) => '#$t').toList(),
      );
    }

    final result = ManualEntryResult(
      isSession: _isSession,
      startDateTime: startDt,
      endDateTime: endDt,
      note: rawNote,
      tags: extractedTags,
      category: _activeCategory != 'All' ? _activeCategory : null,
    );

    HapticFeedback.mediumImpact();
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final dateLabel = isToday
        ? 'Today (${datePretty(_selectedDate.millisecondsSinceEpoch)})'
        : datePretty(_selectedDate.millisecondsSinceEpoch);

    return AppSheet(
      p: p,
      title: 'Manual Entry',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Control: Single vs Session
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isSession = false;
                        _errorMessage = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isSession ? p.surface2 : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: !_isSession
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Point in Time',
                          style: TextStyle(
                            color: !_isSession ? p.text : p.text3,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isSession = true;
                        _errorMessage = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isSession ? p.surface2 : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: _isSession
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Time Span (Session)',
                          style: TextStyle(
                            color: _isSession ? p.text : p.text3,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: spacing16),

          // Date Selector Card
          PressableScale(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.border.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.calendar, size: 18, color: p.accent),
                  const SizedBox(width: 10),
                  Text(
                    'Date',
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 18, color: p.text3),
                ],
              ),
            ),
          ),

          const SizedBox(height: spacing12),

          // Time Selector Row
          Row(
            children: [
              Expanded(
                child: PressableScale(
                  onTap: () => _selectTime(isStart: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: p.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSession ? 'START TIME' : 'TIME',
                          style: TextStyle(
                            color: p.text3,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _startTime.format(context),
                          style: TextStyle(
                            color: p.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isSession) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: PressableScale(
                    onTap: () => _selectTime(isStart: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: p.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'END TIME',
                            style: TextStyle(
                              color: p.text3,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _endTime.format(context),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: spacing16),

          // Category Mode Selector
          Text(
            'MODE / CATEGORY',
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: spacing8),
          HomeCategoryPills(
            p: p,
            categories: widget.categories,
            activeCategory: _activeCategory,
            onSelectCategory: (cat) {
              setState(() => _activeCategory = cat);
            },
            onAddCategory: () {},
          ),

          const SizedBox(height: spacing16),

          // Note text input
          Text(
            'NOTE & TAGS',
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: spacing8),
          TextField(
            controller: _noteController,
            focusNode: _focusNode,
            maxLines: 3,
            minLines: 2,
            style: TextStyle(color: p.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'What happened during this period?',
              hintStyle: TextStyle(color: p.text3, fontSize: 13.5),
              filled: true,
              fillColor: p.surface3,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.border.withValues(alpha: 0.6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.border.withValues(alpha: 0.6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.accent),
              ),
            ),
          ),

          // Quick tag chips
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: spacing8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (final tag in _tags)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: PressableScale(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          final text = _noteController.text;
                          final spacer = text.isEmpty || text.endsWith(' ')
                              ? ''
                              : ' ';
                          final newText = '$text$spacer$tag ';
                          _noteController.text = newText;
                          _noteController.selection =
                              TextSelection.fromPosition(
                                TextPosition(offset: newText.length),
                              );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: p.surface2,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: p.border.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          if (_errorMessage != null) ...[
            const SizedBox(height: spacing12),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: p.red,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          const SizedBox(height: spacing20),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.text2,
                    side: BorderSide(color: p.border),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Save Log',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
