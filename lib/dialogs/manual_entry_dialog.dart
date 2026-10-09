import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_date_picker_sheet.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
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
    this.linkedGoal,
  });

  final bool isSession;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String note;
  final List<String> tags;
  final String? category;
  final Goal? linkedGoal;
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
  return AppDatePickerSheet.show(
    context,
    p: p,
    title: title,
    mode: mode,
    initialDateTime: initialDateTime,
    minimumDate: minimumDate,
    maximumDate: maximumDate,
  );
}

/// Apple HIG Manual Entry Sheet allowing users to retroactively log
/// single moments or full start/end sessions up to 30 days in the past,
/// with direct integration to Targets & Goals.
class ManualEntryDialog extends StatelessWidget {
  const ManualEntryDialog({
    super.key,
    required this.p,
    required this.categories,
    this.initialCategory,
    this.initialGoal,
    this.prefilledStartTime,
    this.prefilledEndTime,
    this.lockToSession = false,
  });

  final Palette p;
  final List<String> categories;
  final String? initialCategory;
  final Goal? initialGoal;
  final DateTime? prefilledStartTime;
  final DateTime? prefilledEndTime;
  final bool lockToSession;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      p: p,
      title: 'Log Past Moment',
      child: ManualEntryContent(
        p: p,
        categories: categories,
        initialCategory: initialCategory,
        initialGoal: initialGoal,
        prefilledStartTime: prefilledStartTime,
        prefilledEndTime: prefilledEndTime,
        lockToSession: lockToSession,
        onSubmit: (res) => Navigator.pop(context, res),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

class ManualEntryContent extends StatefulWidget {
  const ManualEntryContent({
    super.key,
    required this.p,
    required this.categories,
    this.initialCategory,
    this.initialGoal,
    this.prefilledStartTime,
    this.prefilledEndTime,
    this.lockToSession = false,
    required this.onSubmit,
    this.onCancel,
  });

  final Palette p;
  final List<String> categories;
  final String? initialCategory;
  final Goal? initialGoal;
  final DateTime? prefilledStartTime;
  final DateTime? prefilledEndTime;
  final bool lockToSession;
  final ValueChanged<ManualEntryResult> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<ManualEntryContent> createState() => _ManualEntryContentState();
}

class _ManualEntryContentState extends State<ManualEntryContent> {
  late bool _isSession;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _activeCategory;
  late List<String> _categories;
  List<Goal> _goals = [];
  Goal? _selectedGoal;

  final TextEditingController _noteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _tags = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final isGapLocked = widget.lockToSession || widget.prefilledEndTime != null;
    _isSession = isGapLocked ? true : false;

    final start =
        widget.prefilledStartTime ?? now.subtract(const Duration(hours: 1));
    final end = widget.prefilledEndTime ?? now;

    _selectedDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    _endTime = TimeOfDay(hour: end.hour, minute: end.minute);

    _categories = List<String>.from(widget.categories);
    _selectedGoal = widget.initialGoal;

    if (_selectedGoal != null) {
      if (_selectedGoal!.category != null &&
          _selectedGoal!.category!.isNotEmpty) {
        _activeCategory = _selectedGoal!.category!;
      } else {
        _activeCategory = widget.initialCategory ?? 'All';
      }
      if (!isGapLocked) {
        if (_selectedGoal!.mode == 'two-way') {
          _isSession = true;
        } else if (_selectedGoal!.mode == 'single') {
          _isSession = false;
        }
      }
    } else {
      _activeCategory = widget.initialCategory ?? 'All';
    }

    _loadTags();
    _loadGoals();
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
                                        Icons.check_rounded,
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

  Future<void> _loadGoals() async {
    final list = await GoalsService.instance.getGoals();
    if (mounted) {
      setState(() {
        _goals = list.where((g) => !g.isArchived).toList();
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
    final isGapLocked = widget.lockToSession || widget.prefilledEndTime != null;
    if (isGapLocked) {
      _isSession = true;
    }
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
      category: _activeCategory != 'All'
          ? _activeCategory
          : (_selectedGoal?.category),
      linkedGoal: _selectedGoal,
    );

    HapticFeedback.mediumImpact();
    widget.onSubmit(result);
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode Control: Locked to Session for Untracked Intervals vs Segmented Control
          if (widget.lockToSession || widget.prefilledEndTime != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: spacing8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: p.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'FILLING UNTRACKED INTERVAL',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                      if (widget.lockToSession ||
                          widget.prefilledEndTime != null) {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          _errorMessage =
                              'Untracked interval must be logged as a completed session.'
                                  .localized(context);
                        });
                        return;
                      }
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
                  Icon(Icons.calendar_today_rounded, size: 18, color: p.accent),
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
                  Icon(Icons.chevron_right_rounded, size: 14, color: p.text3),
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

          // Target & Goal Selector (Optional)
          if (_goals.isNotEmpty) ...[
            Text(
              'TARGET & GOAL (OPTIONAL)',
              style: TextStyle(
                color: p.text3,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: spacing8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedGoal = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6.5,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedGoal == null ? p.accent : p.surface2,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _selectedGoal == null
                              ? p.accent
                              : p.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        'None',
                        style: TextStyle(
                          color: _selectedGoal == null ? Colors.white : p.text2,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  for (final g in _goals) ...[
                    PressableScale(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedGoal = g;
                          if (g.category != null && g.category!.isNotEmpty) {
                            if (!_categories.contains(g.category!)) {
                              _categories.add(g.category!);
                            }
                            _activeCategory = g.category!;
                          }
                          if (g.mode == 'two-way') {
                            _isSession = true;
                          } else if (g.mode == 'single') {
                            _isSession = false;
                          }
                          final catTag = g.category != null
                              ? '#${g.category!.toLowerCase()}'
                              : '';
                          if (catTag.isNotEmpty &&
                              !_noteController.text.toLowerCase().contains(
                                catTag,
                              )) {
                            final text = _noteController.text;
                            final spacer = text.isEmpty || text.endsWith(' ')
                                ? ''
                                : ' ';
                            _noteController.text = '$text$spacer$catTag ';
                            _noteController
                                .selection = TextSelection.fromPosition(
                              TextPosition(offset: _noteController.text.length),
                            );
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6.5,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedGoal?.id == g.id
                              ? p.accent.withValues(alpha: 0.18)
                              : p.surface2,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _selectedGoal?.id == g.id
                                ? p.accent
                                : p.border.withValues(alpha: 0.6),
                            width: _selectedGoal?.id == g.id ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              size: 11,
                              color: _selectedGoal?.id == g.id
                                  ? p.accent
                                  : p.text3,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              g.title,
                              style: TextStyle(
                                color: _selectedGoal?.id == g.id
                                    ? p.accent
                                    : p.text,
                                fontSize: 12,
                                fontWeight: _selectedGoal?.id == g.id
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: spacing16),
          ],

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
                  onTap: () {
                    if (widget.onCancel != null) {
                      widget.onCancel!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
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
