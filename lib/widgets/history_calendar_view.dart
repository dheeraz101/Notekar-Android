import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/day_detail_sheet.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/dialogs/timeline_filter_sheet.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Apple HIG Calendar Day-Swipe Timeline View.
/// Allows horizontal swiping across days, showing 24h visual timeline blocks.
class HistoryCalendarView extends StatefulWidget {
  const HistoryCalendarView({
    super.key,
    required this.p,
    required this.sections,
    required this.allEntries,
    this.initialDateKey,
    this.onEditNote,
    this.onOpenManualEntry,
    this.onOpenInsights,
    this.onDelete,
    this.rainbowCards = false,
  });

  final Palette p;
  final List<TimelineDaySection> sections;
  final List<Moment> allEntries;
  final String? initialDateKey;
  final ValueChanged<Moment>? onEditNote;
  final void Function({
    DateTime? prefilledStartTime,
    DateTime? prefilledEndTime,
  })?
  onOpenManualEntry;
  final ValueChanged<TimelineDaySection>? onOpenInsights;
  final ValueChanged<Moment>? onDelete;
  final bool rainbowCards;

  @override
  State<HistoryCalendarView> createState() => _HistoryCalendarViewState();
}

class _HistoryCalendarViewState extends State<HistoryCalendarView> {
  late PageController _pageController;
  late ScrollController _stripScrollController;
  late int _currentIndex;
  late List<DateTime> _daysList;
  late Map<String, TimelineDaySection> _sectionMap;
  TimelineFilterCriteria _filterCriteria = const TimelineFilterCriteria();
  final List<Moment> _selectedMoments = [];

  static const int _daysRange = 60; // 60 days lookback

  void _handleCardTap(Moment moment) {
    if (_selectedMoments.any((m) => m.id == moment.id)) {
      setState(() => _selectedMoments.removeWhere((m) => m.id == moment.id));
    } else {
      _selectedMoments.add(moment);
      if (_selectedMoments.length >= 2) {
        final a = _selectedMoments[0];
        final b = _selectedMoments[1];
        setState(() => _selectedMoments.clear());
        showTimeDifferenceDialog(context, p: widget.p, a: a, b: b);
      } else {
        setState(() {});
      }
    }
  }

  void _showMomentContextMenu(Moment moment) {
    HapticFeedback.mediumImpact();
    final hasNote = moment.note.trim().isNotEmpty;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(
          hasNote
              ? (moment.note.length > 36
                    ? '${moment.note.substring(0, 36)}...'
                    : moment.note)
              : '${moment.category ?? 'Moment'} • ${timeOnly(moment.timestamp)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.p.text,
          ),
        ),
        message: Text(
          '${datePretty(moment.timestamp)} at ${timeOnly(moment.timestamp)}',
          style: TextStyle(fontSize: 12, color: widget.p.text3),
        ),
        actions: [
          if (widget.onEditNote != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onEditNote!(moment);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasNote ? Icons.edit_rounded : Icons.add_comment_rounded,
                    size: 19,
                    color: widget.p.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (hasNote ? 'Edit Note' : 'Add Note').localized(context),
                    style: TextStyle(
                      color: widget.p.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.onDelete != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(ctx);
                _confirmDeleteMoment(moment);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_rounded,
                    size: 19,
                    color: CupertinoColors.destructiveRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Moment'.localized(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Cancel'.localized(context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMoment(Moment moment) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Delete Moment?'.localized(context)),
        content: Text(
          'Are you sure you want to delete this moment? This cannot be undone.'
              .localized(context),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.localized(context)),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete?.call(moment);
            },
            child: Text('Delete'.localized(context)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _sectionMap = {for (final s in widget.sections) s.dateKey: s};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Build ordered list of days chronologically: oldest at index 0, today at last index
    _daysList = List.generate(
      _daysRange,
      (i) => today.subtract(Duration(days: (_daysRange - 1) - i)),
    );

    int initialIdx = _daysList.length - 1;
    if (widget.initialDateKey != null) {
      for (int i = 0; i < _daysList.length; i++) {
        if (dateKey(_daysList[i]) == widget.initialDateKey) {
          initialIdx = i;
          break;
        }
      }
    }

    _currentIndex = initialIdx;
    _pageController = PageController(initialPage: initialIdx);
    _stripScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDay(animated: false);
    });
  }

  @override
  void didUpdateWidget(HistoryCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sectionMap = {for (final s in widget.sections) s.dateKey: s};
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stripScrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentDay({bool animated = true}) {
    if (!_stripScrollController.hasClients) return;
    const itemWidth = 54.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final targetOffset =
        (_currentIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    final clamped = targetOffset.clamp(
      0.0,
      _stripScrollController.position.maxScrollExtent,
    );
    if (animated) {
      _stripScrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } else {
      _stripScrollController.jumpTo(clamped);
    }
  }

  void _onDaySelected(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
    _scrollToCurrentDay(animated: true);
  }

  String _formatDayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(DateTime(d.year, d.month, d.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return _weekdayShort(d.weekday);
  }

  String _weekdayShort(int w) {
    return switch (w) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      DateTime.sunday => 'Sun',
      _ => '',
    };
  }

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
    final selectedDate = _daysList[_currentIndex];
    final selectedKey = dateKey(selectedDate);
    final currentSection = _sectionMap[selectedKey];

    return Column(
      children: [
        // 1. Horizontal Date Strip
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListView.builder(
            controller: _stripScrollController,
            scrollDirection: Axis.horizontal,
            reverse: false,
            // Chronological order: past on left, today on right
            itemCount: _daysList.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (ctx, index) {
              final d = _daysList[index];
              final k = dateKey(d);
              final isSelected = index == _currentIndex;
              final hasData =
                  _sectionMap.containsKey(k) &&
                  _sectionMap[k]!.items.isNotEmpty;

              return PressableScale(
                onTap: () => _onDaySelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.p.accent
                        : (hasData
                              ? widget.p.surface2
                              : widget.p.surface2.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? widget.p.accent
                          : widget.p.border.withValues(alpha: 0.5),
                      width: isSelected ? 1.5 : 0.8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDayLabel(d).substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : widget.p.text3,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : widget.p.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: hasData
                              ? (isSelected ? Colors.white : widget.p.green)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 2. Day Header Bar (Tap for Day Reflection Sheet)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          child: PressableScale(
            onTap: () {
              HapticFeedback.lightImpact();
              if (currentSection != null) {
                if (widget.onOpenInsights != null) {
                  widget.onOpenInsights!(currentSection);
                } else {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => DayDetailSheet(
                      p: widget.p,
                      section: currentSection,
                      allEntries: widget.allEntries,
                      onEditNote: widget.onEditNote,
                      onOpenManualEntry: widget.onOpenManualEntry,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: widget.p.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.p.border.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: widget.p.accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSection?.displayTitle ??
                              _formatDayLabel(selectedDate),
                          style: TextStyle(
                            color: widget.p.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          currentSection != null
                              ? '${currentSection.totalLogs} logs • ${_formatDuration(currentSection.totalTrackedDuration)} tracked'
                              : 'No activity logged',
                          style: TextStyle(
                            color: widget.p.text3,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (currentSection != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.p.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Insights',
                            style: TextStyle(
                              color: widget.p.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 12,
                            color: widget.p.accent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        if (_selectedMoments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Center(
              child: PressableScale(
                onTap: () => setState(() => _selectedMoments.clear()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.p.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: widget.p.accent.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    'Selected ${_selectedMoments.length} of 2 for duration'
                        .localized(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.p.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // 3. Day PageView (Swipeable Timeline Canvas)
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _daysList.length,
            onPageChanged: (idx) {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = idx);
              _scrollToCurrentDay(animated: true);
            },
            itemBuilder: (ctx, pageIdx) {
              final d = _daysList[pageIdx];
              final k = dateKey(d);
              final sec = _sectionMap[k];

              if (sec == null || sec.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bedtime_rounded,
                        size: 44,
                        color: widget.p.text3.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No moments logged'.localized(context),
                        style: TextStyle(
                          color: widget.p.text2,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Swipe right or tap + to log retroactively'.localized(
                          context,
                        ),
                        style: TextStyle(color: widget.p.text3, fontSize: 12),
                      ),
                      if (widget.onOpenManualEntry != null) ...[
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onOpenManualEntry?.call(
                              prefilledStartTime: DateTime(
                                d.year,
                                d.month,
                                d.day,
                                9,
                                0,
                              ),
                            );
                          },
                          child: Text(
                            'Add Log for this Day'.localized(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return _buildDayHourlyCanvas(sec);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayHourlyCanvas(TimelineDaySection sec) {
    final filteredItems = sec.items.where((it) {
      if (_filterCriteria.mode == 'single' && it is! TimelineSingleItem) {
        return false;
      }
      if (_filterCriteria.mode == 'two-way' && it is! TimelineSessionItem) {
        return false;
      }

      if (_filterCriteria.category != null &&
          _filterCriteria.category!.isNotEmpty) {
        final cat = _filterCriteria.category!.toLowerCase();
        final itemCat = it.category?.toLowerCase() ?? '';
        final itemNote =
            (it is TimelineSessionItem
                    ? it.note
                    : (it is TimelineSingleItem ? it.note : ''))
                .toLowerCase();
        if (itemCat != cat && !itemNote.contains('#$cat')) return false;
      }

      if (_filterCriteria.hashtag != null &&
          _filterCriteria.hashtag!.isNotEmpty) {
        final tag = _filterCriteria.hashtag!.toLowerCase();
        final cleanTag = tag.startsWith('#') ? tag : '#$tag';
        final itemNote =
            (it is TimelineSessionItem
                    ? it.note
                    : (it is TimelineSingleItem ? it.note : ''))
                .toLowerCase();
        if (!itemNote.contains(cleanTag)) return false;
      }

      return true;
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 40,
              color: widget.p.text3.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 10),
            Text(
              'No moments match active filter'.localized(context),
              style: TextStyle(
                color: widget.p.text2,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(
                  () => _filterCriteria = const TimelineFilterCriteria(),
                );
              },
              child: Text('Reset Filter'.localized(context)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey<String>('history_calendar_list_view'),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      itemCount: filteredItems.length,
      itemBuilder: (ctx, idx) {
        final it = filteredItems[idx];

        if (it is TimelineSessionItem) {
          final cat = it.category ?? 'Session';
          final meta = getCategoryMeta(cat, widget.p);
          final isSelected = _selectedMoments.any(
            (m) => m.id == it.noteMoment.id,
          );
          final cardColor = isSelected
              ? widget.p.surface3
              : (widget.rainbowCards
                    ? Color.alphaBlend(
                        meta.color.withValues(alpha: 0.12),
                        widget.p.surface2,
                      )
                    : widget.p.surface2);
          final borderColor = isSelected
              ? widget.p.accent
              : (widget.rainbowCards
                    ? meta.color.withValues(alpha: 0.45)
                    : meta.color.withValues(alpha: 0.35));
          final borderWidth = isSelected ? 1.8 : 1.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _handleCardTap(it.noteMoment),
              onLongPress: () => _showMomentContextMenu(it.noteMoment),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: meta.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(meta.icon, size: 12, color: meta.color),
                              const SizedBox(width: 4),
                              Text(
                                cat,
                                style: TextStyle(
                                  color: meta.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDuration(it.duration),
                          style: TextStyle(
                            color: widget.p.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: widget.p.text3,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${timeOnly(it.startTimestamp)} → ${it.endTimestamp != null ? timeOnly(it.endTimestamp!) : "Live"}',
                          style: TextStyle(
                            color: widget.p.text2,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    if (it.note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      PressableScale(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          NotePreviewSheet.show(
                            context,
                            p: widget.p,
                            note: it.note,
                            title:
                                it.category ??
                                'Session Note'.localized(context),
                            category: it.category,
                            dateStr: datePretty(it.startTimestamp),
                            onEdit: widget.onEditNote != null
                                ? () => widget.onEditNote!(it.noteMoment)
                                : null,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.p.surface3.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IosEmojiText(
                            it.note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.p.text,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        } else if (it is TimelineSingleItem) {
          final cat = it.category ?? 'Moment';
          final meta = getCategoryMeta(cat, widget.p);
          final isSelected = _selectedMoments.any((m) => m.id == it.moment.id);
          final cardColor = isSelected
              ? widget.p.surface3
              : (widget.rainbowCards
                    ? Color.alphaBlend(
                        meta.color.withValues(alpha: 0.12),
                        widget.p.surface2,
                      )
                    : widget.p.surface2);
          final borderColor = isSelected
              ? widget.p.accent
              : (widget.rainbowCards
                    ? meta.color.withValues(alpha: 0.4)
                    : widget.p.border.withValues(alpha: 0.5));
          final borderWidth = isSelected ? 1.8 : 1.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _handleCardTap(it.moment),
              onLongPress: () => _showMomentContextMenu(it.moment),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.p.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(meta.icon, size: 16, color: widget.p.accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeOnly(it.primaryTimestamp),
                            style: TextStyle(
                              color: widget.p.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          if (it.note.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            PressableScale(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                NotePreviewSheet.show(
                                  context,
                                  p: widget.p,
                                  note: it.note,
                                  title:
                                      it.category ??
                                      'Moment Note'.localized(context),
                                  category: it.category,
                                  dateStr: datePretty(it.primaryTimestamp),
                                  onEdit: widget.onEditNote != null
                                      ? () => widget.onEditNote!(it.moment)
                                      : null,
                                );
                              },
                              child: IosEmojiText(
                                it.note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: widget.p.text2,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      it.type.toUpperCase(),
                      style: TextStyle(
                        color: widget.p.text3,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
