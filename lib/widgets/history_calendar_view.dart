import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/day_detail_sheet.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
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

  @override
  State<HistoryCalendarView> createState() => _HistoryCalendarViewState();
}

class _HistoryCalendarViewState extends State<HistoryCalendarView> {
  late PageController _pageController;
  late ScrollController _stripScrollController;
  late int _currentIndex;
  late List<DateTime> _daysList;
  late Map<String, TimelineDaySection> _sectionMap;

  static const int _daysRange = 60; // 60 days lookback

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: PressableScale(
            onTap: () {
              HapticFeedback.lightImpact();
              if (currentSection != null) {
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
                    CupertinoIcons.calendar,
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
                            CupertinoIcons.chevron_right,
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
                        CupertinoIcons.moon_zzz,
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
    final items = sec.items;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        final it = items[idx];

        if (it is TimelineSessionItem) {
          final cat = it.category ?? 'Session';
          final meta = getCategoryMeta(cat, widget.p);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.p.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: meta.color.withValues(alpha: 0.35),
                  width: 1,
                ),
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
                        CupertinoIcons.time,
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
                    GestureDetector(
                      onTap: () {
                        final endStr = it.endTimestamp != null
                            ? timeOnly(it.endTimestamp!)
                            : 'Now';
                        NotePreviewSheet.show(
                          context,
                          p: widget.p,
                          note: it.note,
                          title: '${timeOnly(it.startTimestamp)} - $endStr',
                          category: it.category,
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
          );
        } else if (it is TimelineSingleItem) {
          final cat = it.category ?? 'Moment';
          final meta = getCategoryMeta(cat, widget.p);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.p.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.p.border.withValues(alpha: 0.5),
                ),
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
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (it.note.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          IosEmojiText(
                            it.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.p.text2,
                              fontSize: 11.5,
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
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
