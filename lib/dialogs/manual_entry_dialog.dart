import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Material, TimeOfDay;
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
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

/// Reusable Apple HIG Cupertino Date & Time picker bottom sheet.
Future<DateTime?> showCupertinoDatePickerSheet(
  BuildContext context, {
  required Palette p,
  required DateTime initialDateTime,
  required CupertinoDatePickerMode mode,
  DateTime? minimumDate,
  DateTime? maximumDate,
  required String title,
}) {
  DateTime selected = initialDateTime;
  return showCupertinoModalPopup<DateTime>(
    context: context,
    barrierColor: const Color(0x66000000),
    builder: (BuildContext sheetContext) {
      return Material(
        color: Colors.transparent,
        child: DefaultTextStyle(
          style: TextStyle(
            color: p.text,
            decoration: TextDecoration.none,
            fontFamily: '.SF Pro Text',
          ),
          child: Container(
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(color: p.border.withValues(alpha: 0.6)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(sheetContext, null),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              Navigator.pop(sheetContext, selected),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 0.5,
                    color: p.border.withValues(alpha: 0.5),
                  ),
                  SizedBox(
                    height: 220,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: p.name == 'light'
                            ? Brightness.light
                            : Brightness.dark,
                        primaryColor: p.accent,
                        textTheme: CupertinoTextThemeData(
                          textStyle: TextStyle(
                            color: p.text,
                            decoration: TextDecoration.none,
                          ),
                          dateTimePickerTextStyle: TextStyle(
                            color: p.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: mode,
                        initialDateTime: initialDateTime,
                        minimumDate: minimumDate,
                        maximumDate: maximumDate,
                        onDateTimeChanged: (val) {
                          HapticFeedback.selectionClick();
                          selected = val;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
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
  late List<String> _categories;

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

    _categories = List<String>.from(widget.categories);
    _activeCategory = widget.initialCategory ?? 'All';
    _loadTags();
  }

  Future<void> _showAddCategoryDialog() async {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();
    Color selectedColor = CategoryService.appleHigColors[0];

    final created = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: widget.p.name == 'light'
              ? Brightness.light
              : Brightness.dark,
          primaryColor: widget.p.accent,
        ),
        child: StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return CupertinoAlertDialog(
              title: const Text('New Mode'),
              content: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoTextField(
                      controller: textController,
                      autofocus: true,
                      placeholder: 'Mode Name (e.g. Study, Gym)',
                      placeholderStyle: TextStyle(color: widget.p.text3),
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: widget.p.text),
                      decoration: BoxDecoration(
                        color: widget.p.surface3,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.p.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final col in CategoryService.appleHigColors) ...[
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setDialogState(() => selectedColor = col);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: col,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor == col
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: selectedColor == col
                                      ? [
                                          BoxShadow(
                                            color: col.withValues(alpha: 0.5),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: selectedColor == col
                                    ? const Icon(
                                        CupertinoIcons.check_mark,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(ctx, false),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Create'),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (created == true) {
      final name = textController.text.trim();
      if (name.isNotEmpty) {
        final success = await CategoryService().addCategory(
          name,
          color: selectedColor,
        );
        if (success && mounted) {
          HapticFeedback.mediumImpact();
          setState(() {
            if (!_categories.contains(name)) {
              _categories.add(name);
            }
            _activeCategory = name;
          });
        }
      }
    }
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

  String _formatTimeOfDay(TimeOfDay t) {
    final dt = DateTime(2026, 1, 1, t.hour, t.minute);
    return timeOnly(dt.millisecondsSinceEpoch);
  }

  Future<void> _selectDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final earliest = now.subtract(const Duration(days: 30));

    final picked = await showCupertinoDatePickerSheet(
      context,
      p: widget.p,
      title: 'Select Date',
      mode: CupertinoDatePickerMode.date,
      initialDateTime: _selectedDate.isBefore(earliest)
          ? earliest
          : _selectedDate,
      minimumDate: DateTime(earliest.year, earliest.month, earliest.day),
      maximumDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _errorMessage = null;
      });
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    HapticFeedback.selectionClick();
    final current = isStart ? _startTime : _endTime;
    final initialDt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      current.hour,
      current.minute,
    );

    final picked = await showCupertinoDatePickerSheet(
      context,
      p: widget.p,
      title: isStart ? 'Select Start Time' : 'Select End Time',
      mode: CupertinoDatePickerMode.time,
      initialDateTime: initialDt,
    );

    if (picked != null && mounted) {
      setState(() {
        final newTime = TimeOfDay(hour: picked.hour, minute: picked.minute);
        if (isStart) {
          _startTime = newTime;
        } else {
          _endTime = newTime;
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
      if (!endDt.isAfter(startDt)) {
        // End time must be strictly after start time
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
                        color: !_isSession
                            ? (p.name == 'light'
                                  ? Colors.white
                                  : (p.name == 'amoled'
                                        ? const Color(0xFF28282C)
                                        : const Color(0xFF48484A)))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: !_isSession
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
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
                        color: _isSession
                            ? (p.name == 'light'
                                  ? Colors.white
                                  : (p.name == 'amoled'
                                        ? const Color(0xFF28282C)
                                        : const Color(0xFF48484A)))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: _isSession
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
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
                  Icon(CupertinoIcons.chevron_right, size: 14, color: p.text3),
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
                          _formatTimeOfDay(_startTime),
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
                            _formatTimeOfDay(_endTime),
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
            categories: _categories,
            activeCategory: _activeCategory,
            onSelectCategory: (cat) {
              setState(() => _activeCategory = cat);
            },
            onAddCategory: _showAddCategoryDialog,
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
          CupertinoTextField(
            controller: _noteController,
            focusNode: _focusNode,
            maxLines: 3,
            minLines: 2,
            style: TextStyle(color: p.text, fontSize: 14),
            placeholder: 'What happened during this period?',
            placeholderStyle: TextStyle(color: p.text3, fontSize: 13.5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.surface3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.border.withValues(alpha: 0.6)),
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
                child: PressableScale(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: p.border.withValues(alpha: 0.6),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: p.text2,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PressableScale(
                  onTap: _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Save Log',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
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
