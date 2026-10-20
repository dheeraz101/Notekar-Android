import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/day_detail_sheet.dart';
import 'package:notekar/dialogs/merge_entries_sheet.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/dialogs/timeline_filter_sheet.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/widgets/apple_hig_action_sheet.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/timeline_gap_card.dart';
import 'package:notekar/widgets/timeline_media_attachment_card.dart';
import 'package:notekar/widgets/timeline_voice_player_pill.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.onClaimRest,
    this.onEndLiveSession,
    this.onDeleteSession,
    this.claimedGaps,
    this.onOpenInsights,
    this.onDelete,
    this.rainbowCards = false,
    this.onOpenGodModeSettings,
    this.isMomentImageCollapsed,
    this.onToggleMomentImageCollapse,
    this.isMomentVoiceCollapsed,
    this.onToggleMomentVoiceCollapse,
    this.goals,
    this.endingSessionIds,
    this.filterCriteria,
    this.onFilterChanged,
    this.onEntriesMerged,
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
  final void Function(DateTime start, DateTime end)? onClaimRest;
  final ValueChanged<TimelineSessionItem>? onEndLiveSession;
  final ValueChanged<TimelineSessionItem>? onDeleteSession;
  final Set<String>? claimedGaps;
  final ValueChanged<TimelineDaySection>? onOpenInsights;
  final ValueChanged<Moment>? onDelete;
  final bool rainbowCards;
  final VoidCallback? onOpenGodModeSettings;
  final bool Function(int id)? isMomentImageCollapsed;
  final ValueChanged<int>? onToggleMomentImageCollapse;
  final bool Function(int id)? isMomentVoiceCollapsed;
  final ValueChanged<int>? onToggleMomentVoiceCollapse;
  final List<Goal>? goals;
  final Set<int>? endingSessionIds;
  final TimelineFilterCriteria? filterCriteria;
  final ValueChanged<TimelineFilterCriteria>? onFilterChanged;
  final VoidCallback? onEntriesMerged;

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
  final Set<String> _localClaimedGaps = {};
  final Set<int> _endingSessionIds = {};
  final Set<int> _expandedNoteIds = {};
  bool _showImagesAlways = true;
  final Set<int> _localManuallyExpandedMomentIds = {};
  final Set<int> _localManuallyCollapsedMomentIds = {};

  bool _showVoiceAlways = true;
  final Set<int> _localManuallyExpandedVoiceMomentIds = {};
  final Set<int> _localManuallyCollapsedVoiceMomentIds = {};

  bool _isMomentImageCollapsed(int id) {
    if (widget.isMomentImageCollapsed != null) {
      return widget.isMomentImageCollapsed!(id);
    }
    if (_localManuallyExpandedMomentIds.contains(id)) return false;
    if (_localManuallyCollapsedMomentIds.contains(id)) return true;
    return !_showImagesAlways;
  }

  void _toggleMomentImageCollapse(int id) {
    if (widget.onToggleMomentImageCollapse != null) {
      widget.onToggleMomentImageCollapse!(id);
      setState(() {});
      return;
    }
    setState(() {
      final currentlyCollapsed = _isMomentImageCollapsed(id);
      if (currentlyCollapsed) {
        _localManuallyCollapsedMomentIds.remove(id);
        _localManuallyExpandedMomentIds.add(id);
      } else {
        _localManuallyExpandedMomentIds.remove(id);
        _localManuallyCollapsedMomentIds.add(id);
      }
    });
  }

  bool _isMomentVoiceCollapsed(int id) {
    if (widget.isMomentVoiceCollapsed != null) {
      return widget.isMomentVoiceCollapsed!(id);
    }
    if (_localManuallyExpandedVoiceMomentIds.contains(id)) return false;
    if (_localManuallyCollapsedVoiceMomentIds.contains(id)) return true;
    return !_showVoiceAlways;
  }

  void _toggleMomentVoiceCollapse(int id) {
    if (widget.onToggleMomentVoiceCollapse != null) {
      widget.onToggleMomentVoiceCollapse!(id);
      setState(() {});
      return;
    }
    setState(() {
      final currentlyCollapsed = _isMomentVoiceCollapsed(id);
      if (currentlyCollapsed) {
        _localManuallyCollapsedVoiceMomentIds.remove(id);
        _localManuallyExpandedVoiceMomentIds.add(id);
      } else {
        _localManuallyExpandedVoiceMomentIds.remove(id);
        _localManuallyCollapsedVoiceMomentIds.add(id);
      }
    });
  }

  Future<void> _loadHistoryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _showImagesAlways = prefs.getBool('history_show_images_always') ?? true;
        _showVoiceAlways = prefs.getBool('history_show_voice_always') ?? true;
      });
    }
  }

  Goal? _findMatchingGoal(TimelineItem item) {
    final gList = widget.goals;
    if (gList == null || gList.isEmpty) return null;
    final cat = item.category;
    if (cat != null && cat.trim().isNotEmpty) {
      return gList
          .where(
            (g) =>
                !g.isArchived &&
                g.category != null &&
                g.category!.toLowerCase() == cat.toLowerCase(),
          )
          .firstOrNull;
    }
    return gList
        .where(
          (g) =>
              !g.isArchived &&
              (g.category == null || g.category!.trim().isEmpty),
        )
        .firstOrNull;
  }

  static const int _daysRange = 60; // 60 days lookback

  void _handleCardTap(Moment moment) {
    if (_selectedMoments.any((m) => m.id == moment.id)) {
      setState(() => _selectedMoments.removeWhere((m) => m.id == moment.id));
    } else {
      setState(() {
        if (_selectedMoments.length >= 2) {
          _selectedMoments.removeAt(0);
        }
        _selectedMoments.add(moment);
      });
    }
  }

  Future<void> _mergeSelectedCalendarEntries() async {
    if (_selectedMoments.length != 2) return;
    final a = _selectedMoments[0];
    final b = _selectedMoments[1];

    await MergeEntriesSheet.show(
      context,
      p: widget.p,
      momentA: a,
      momentB: b,
      onConfirmMerge:
          ({
            required Moment startMoment,
            required Moment endMoment,
            required String? category,
            required String? combinedNote,
            required bool unifyNotes,
          }) async {
            await MomentRepository.instance.saveMoments([
              startMoment,
              endMoment,
            ]);

            setState(() {
              _selectedMoments.clear();
            });

            widget.onEntriesMerged?.call();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Entries merged into a session!'.localized(context),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
    );
  }

  void _showMomentContextMenu(Moment moment) {
    HapticFeedback.mediumImpact();
    final hasNote = moment.note.trim().isNotEmpty;
    final title = hasNote
        ? (moment.note.length > 36
              ? '${moment.note.substring(0, 36)}...'
              : moment.note)
        : '${moment.category ?? 'Moment'} • ${timeOnly(moment.timestamp)}';
    final subtitle =
        '${datePretty(moment.timestamp)} at ${timeOnly(moment.timestamp)}';

    AppleHigActionSheet.show<void>(
      context,
      p: widget.p,
      title: title,
      subtitle: subtitle,
      actions: [
        if (widget.onEditNote != null)
          AppleHigActionItem(
            title: hasNote ? 'Edit Note' : 'Add Note',
            icon: hasNote ? Icons.edit_rounded : Icons.add_comment_rounded,
            color: widget.p.accent,
            onTap: () {
              widget.onEditNote!(moment);
            },
          ),
        AppleHigActionItem(
          title: _selectedMoments.any((m) => m.id == moment.id)
              ? 'Deselect Moment'
              : 'Select for Merge / Duration',
          icon: Icons.merge_type_rounded,
          color: widget.p.accent,
          onTap: () {
            _handleCardTap(moment);
          },
        ),
        if (widget.onDelete != null)
          AppleHigActionItem(
            title: 'Delete Moment',
            icon: Icons.delete_rounded,
            isDestructive: true,
            onTap: () {
              _confirmDeleteMoment(moment);
            },
          ),
      ],
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

  void _showSessionContextMenu(TimelineSessionItem session) {
    HapticFeedback.mediumImpact();
    final noteMoment = session.noteMoment;
    final hasNote = session.note.isNotEmpty;
    final cat = session.category ?? 'Session';
    final title = hasNote
        ? (session.note.length > 36
              ? '${session.note.substring(0, 36)}...'
              : session.note)
        : '$cat • ${_formatDuration(session.duration)}';
    final subtitle =
        '${datePretty(session.startTimestamp)} at ${timeOnly(session.startTimestamp)}'
        '${session.endTimestamp != null ? ' - ${timeOnly(session.endTimestamp!)}' : (session.isOngoing ? ' (Live)' : '')}';

    AppleHigActionSheet.show<void>(
      context,
      p: widget.p,
      title: title,
      subtitle: subtitle,
      actions: [
        if (widget.onEditNote != null)
          AppleHigActionItem(
            title: hasNote ? 'Edit Note' : 'Add Note',
            icon: hasNote ? Icons.edit_rounded : Icons.add_comment_rounded,
            color: widget.p.accent,
            onTap: () {
              widget.onEditNote!(noteMoment);
            },
          ),
        if (session.isOngoing && widget.onEndLiveSession != null)
          AppleHigActionItem(
            title: 'Stop Live Session',
            icon: Icons.stop_circle_rounded,
            color: widget.p.red,
            onTap: () {
              HapticFeedback.heavyImpact();
              setState(() {
                _endingSessionIds.add(session.inMoment.id);
              });
              widget.onEndLiveSession!(session);
            },
          ),
        if (widget.onDeleteSession != null)
          AppleHigActionItem(
            title: 'Delete Entire Session',
            icon: Icons.delete_sweep_rounded,
            isDestructive: true,
            onTap: () {
              _confirmDeleteSession(session);
            },
          ),
        if (widget.onDelete != null)
          AppleHigActionItem(
            title: 'Delete Moment Only',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: () {
              _confirmDeleteMoment(noteMoment);
            },
          ),
      ],
    );
  }

  void _confirmDeleteSession(TimelineSessionItem session) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Delete Entire Session?'.localized(context)),
        content: Text(
          'Are you sure you want to delete this complete session (${_formatDuration(session.duration)})? All paired moments will be removed.'
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
              widget.onDeleteSession?.call(session);
            },
            child: Text('Delete Session'.localized(context)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _filterCriteria = widget.filterCriteria ?? const TimelineFilterCriteria();
    _loadHistoryPreferences();
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
    if (widget.filterCriteria != null &&
        widget.filterCriteria != oldWidget.filterCriteria) {
      _filterCriteria = widget.filterCriteria!;
    }
    if (oldWidget.sections != widget.sections ||
        oldWidget.claimedGaps != widget.claimedGaps ||
        oldWidget.filterCriteria != widget.filterCriteria) {
      setState(() {});
    }
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
    final ongoingSession = currentSection?.items
        .whereType<TimelineSessionItem>()
        .where((s) => s.isOngoing && !_endingSessionIds.contains(s.inMoment.id))
        .firstOrNull;

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
                  if (ongoingSession != null &&
                      widget.onEndLiveSession != null) ...[
                    PressableScale(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          _endingSessionIds.add(ongoingSession.inMoment.id);
                        });
                        widget.onEndLiveSession!(ongoingSession);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: widget.p.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.p.red.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stop_circle_rounded,
                              size: 13,
                              color: widget.p.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stop Live'.localized(context),
                              style: TextStyle(
                                color: widget.p.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
            child: Row(
              children: [
                if (_selectedMoments.length < 2) ...[
                  Expanded(
                    child: PressableScale(
                      onTap: () => setState(() => _selectedMoments.clear()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: widget.p.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: widget.p.accent.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Text(
                          '1 selected (tap another to pair)'.localized(context),
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
                ] else ...[
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        final a = _selectedMoments[0];
                        final b = _selectedMoments[1];
                        setState(() => _selectedMoments.clear());
                        showTimeDifferenceDialog(
                          context,
                          p: widget.p,
                          a: a,
                          b: b,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: widget.p.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: widget.p.accent.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 13,
                              color: widget.p.accent,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Duration'.localized(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: widget.p.accent,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: PressableScale(
                      onTap: _mergeSelectedCalendarEntries,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: widget.p.green.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: widget.p.green.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.merge_type_rounded,
                              size: 13,
                              color: widget.p.green,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Merge Session'.localized(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: widget.p.green,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                PressableScale(
                  onTap: () => setState(() => _selectedMoments.clear()),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.p.accent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.p.accent.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: widget.p.accent,
                    ),
                  ),
                ),
              ],
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
      if (it is TimelineGapItem) {
        final gapKey = '${it.startTimestamp}-${it.endTimestamp}';
        if ((widget.claimedGaps?.contains(gapKey) ?? false) ||
            _localClaimedGaps.contains(gapKey)) {
          return false;
        }
      }
      if (_filterCriteria.mode == 'single' && it is! TimelineSingleItem) {
        return false;
      }
      if (_filterCriteria.mode == 'two-way' && it is! TimelineSessionItem) {
        return false;
      }
      if (_filterCriteria.mode == 'media') {
        if (it is TimelineSingleItem) {
          final m = it.moment;
          final hasMedia =
              (m.imagePath != null && m.imagePath!.isNotEmpty) ||
              (m.voicePath != null && m.voicePath!.isNotEmpty);
          if (!hasMedia) {
            return false;
          }
        } else if (it is TimelineSessionItem) {
          final inM = it.inMoment;
          final outM = it.outMoment;
          final hasMedia =
              (inM.imagePath != null && inM.imagePath!.isNotEmpty) ||
              (inM.voicePath != null && inM.voicePath!.isNotEmpty) ||
              (outM != null &&
                  ((outM.imagePath != null && outM.imagePath!.isNotEmpty) ||
                      (outM.voicePath != null && outM.voicePath!.isNotEmpty)));
          if (!hasMedia) {
            return false;
          }
        } else {
          return false;
        }
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

      if (_filterCriteria.goalId != null &&
          _filterCriteria.goalId!.isNotEmpty) {
        if (it is TimelineSessionItem) {
          final inGoal = it.inMoment.effectiveGoalId;
          final outGoal = it.outMoment?.effectiveGoalId;
          if (inGoal != _filterCriteria.goalId &&
              outGoal != _filterCriteria.goalId) {
            return false;
          }
        } else if (it is TimelineSingleItem) {
          if (it.moment.effectiveGoalId != _filterCriteria.goalId) {
            return false;
          }
        } else {
          return false;
        }
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
                widget.onFilterChanged?.call(const TimelineFilterCriteria());
              },
              child: Text('Reset Filter'.localized(context)),
            ),
          ],
        ),
      );
    }

    final dayNoteTimelineItems = filteredItems
        .where((item) => item.note.trim().isNotEmpty)
        .toList();
    final dayPreviewItems = dayNoteTimelineItems.map((item) {
      final moment = (item is TimelineSessionItem)
          ? item.noteMoment
          : (item is TimelineSingleItem ? item.moment : null);
      return NotePreviewItem(
        note: item.note,
        title:
            item.category ??
            (item is TimelineSessionItem
                ? 'Session Note'.localized(context)
                : 'Moment Note'.localized(context)),
        category: item.category,
        dateStr: datePretty(item.primaryTimestamp),
        onEdit: (widget.onEditNote != null && moment != null)
            ? () => widget.onEditNote!(moment)
            : null,
      );
    }).toList();

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
          final isEnding =
              _endingSessionIds.contains(it.inMoment.id) ||
              (widget.endingSessionIds?.contains(it.inMoment.id) ?? false);
          final isOngoing = it.isOngoing && !isEnding;
          final borderColor = isSelected
              ? widget.p.accent
              : (isOngoing
                    ? widget.p.green.withValues(alpha: 0.45)
                    : (widget.rainbowCards
                          ? ((cat.toLowerCase() == 'rest' ||
                                    cat.toLowerCase() == 'recovery')
                                ? widget.p.border.withValues(alpha: 0.5)
                                : meta.color.withValues(alpha: 0.45))
                          : widget.p.border.withValues(alpha: 0.5)));
          final borderWidth = (isSelected || isOngoing) ? 1.8 : 1.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _handleCardTap(it.noteMoment),
              onLongPress: () => _showSessionContextMenu(it),
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
                        () {
                          final matchingGoal = _findMatchingGoal(it);
                          if (matchingGoal == null) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: widget.p.accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.p.accent.withValues(
                                    alpha: 0.35,
                                  ),
                                  width: 0.6,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    size: 11,
                                    color: widget.p.accent,
                                  ),
                                  const SizedBox(width: 3.5),
                                  Text(
                                    matchingGoal.title,
                                    style: TextStyle(
                                      color: widget.p.accent,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }(),
                        if (it.isOngoing && !isEnding) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: widget.p.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: widget.p.green.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: widget.p.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.onEndLiveSession != null) ...[
                            const SizedBox(width: 6),
                            PressableScale(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  _endingSessionIds.add(it.inMoment.id);
                                });
                                widget.onEndLiveSession!(it);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.p.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: widget.p.red.withValues(alpha: 0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stop_circle_rounded,
                                      size: 11,
                                      color: widget.p.red,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'End'.localized(context),
                                      style: TextStyle(
                                        color: widget.p.red,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
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
                          final noteIdx = dayNoteTimelineItems.indexOf(it);
                          NotePreviewSheet.show(
                            context,
                            p: widget.p,
                            note: it.note,
                            title:
                                it.category ??
                                'Session Note'.localized(context),
                            category: it.category,
                            dateStr: datePretty(it.startTimestamp),
                            items: dayPreviewItems,
                            initialIndex: noteIdx >= 0 ? noteIdx : 0,
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
                            maxLines:
                                _expandedNoteIds.contains(it.noteMoment.id)
                                ? null
                                : 2,
                            overflow:
                                _expandedNoteIds.contains(it.noteMoment.id)
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.p.text,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                      if (it.note.contains('\n') || it.note.length > 40)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                if (_expandedNoteIds.contains(
                                  it.noteMoment.id,
                                )) {
                                  _expandedNoteIds.remove(it.noteMoment.id);
                                } else {
                                  _expandedNoteIds.add(it.noteMoment.id);
                                }
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _expandedNoteIds.contains(it.noteMoment.id)
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: widget.p.accent,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _expandedNoteIds.contains(it.noteMoment.id)
                                      ? 'Collapse'
                                      : 'Expand note',
                                  style: TextStyle(
                                    color: widget.p.accent,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    // Combined collapsed voice & photo pills on same line
                    if (_isMomentVoiceCollapsed(it.noteMoment.id) &&
                        _isMomentImageCollapsed(it.noteMoment.id) &&
                        it.noteMoment.voicePaths.isNotEmpty &&
                        it.noteMoment.imagePath != null &&
                        it.noteMoment.imagePath!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TimelineVoicePlayerPill.buildCollapsedPill(
                              p: widget.p,
                              count: it.noteMoment.voicePaths.length,
                              onToggleCollapse: () =>
                                  _toggleMomentVoiceCollapse(it.noteMoment.id),
                              compact: true,
                            ),
                            TimelineMediaAttachmentCard.buildCollapsedPill(
                              p: widget.p,
                              imagePath: it.noteMoment.imagePath,
                              onToggleCollapse: () =>
                                  _toggleMomentImageCollapse(it.noteMoment.id),
                              compact: true,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      if (_isMomentVoiceCollapsed(it.noteMoment.id) &&
                          it.noteMoment.voicePaths.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TimelineVoicePlayerPill.buildCollapsedPill(
                              p: widget.p,
                              count: it.noteMoment.voicePaths.length,
                              onToggleCollapse: () =>
                                  _toggleMomentVoiceCollapse(it.noteMoment.id),
                              compact: true,
                            ),
                          ),
                        )
                      else if (it.noteMoment.voicePaths.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5.0,
                                bottom: 2.0,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: PressableScale(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    _toggleMomentVoiceCollapse(
                                      it.noteMoment.id,
                                    );
                                  },
                                  child: Container(
                                    height: 26,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.p.surface3.withValues(
                                        alpha: 0.55,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: widget.p.border.withValues(
                                          alpha: 0.45,
                                        ),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.mic_fill,
                                          size: 12,
                                          color: widget.p.accent,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${it.noteMoment.voicePaths.length} Voice Memo${it.noteMoment.voicePaths.length > 1 ? "s" : ""}',
                                          style: TextStyle(
                                            color: widget.p.text2,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          CupertinoIcons.chevron_up,
                                          size: 10,
                                          color: widget.p.text3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            for (final vp in it.noteMoment.voicePaths) ...[
                              const SizedBox(height: 5),
                              TimelineVoicePlayerPill(
                                p: widget.p,
                                voicePath: vp,
                                durationMs: it.noteMoment.voiceDurationMs ?? 0,
                              ),
                            ],
                          ],
                        ),
                      if (it.noteMoment.imagePath != null) ...[
                        const SizedBox(height: 6),
                        TimelineMediaAttachmentCard(
                          p: widget.p,
                          imagePath: it.noteMoment.imagePath!,
                          isCollapsed: _isMomentImageCollapsed(
                            it.noteMoment.id,
                          ),
                          onToggleCollapse: () =>
                              _toggleMomentImageCollapse(it.noteMoment.id),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        } else if (it is TimelineSingleItem) {
          final isGodMode =
              it.moment.note.trim() == 'Access granted' ||
              it.moment.note.contains('God Mode Unlocked') ||
              it.moment.note.contains('#godmode') ||
              it.moment.note.toLowerCase().contains('sovereign access granted');
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
              onLongPress: isGodMode
                  ? () {
                      HapticFeedback.mediumImpact();
                      if (widget.onOpenGodModeSettings != null) {
                        widget.onOpenGodModeSettings!();
                      } else {
                        Navigator.of(context).pop('god_mode_settings');
                      }
                    }
                  : () => _showMomentContextMenu(it.moment),
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
                        if (isGodMode)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD700),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'D',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: widget.p.accent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              meta.icon,
                              size: 16,
                              color: widget.p.accent,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: isGodMode
                              ? Column(
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
                                    const SizedBox(height: 2),
                                    Text(
                                      'Access granted',
                                      style: TextStyle(
                                        color: widget.p.text2,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
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
                                          final noteIdx = dayNoteTimelineItems
                                              .indexOf(it);
                                          NotePreviewSheet.show(
                                            context,
                                            p: widget.p,
                                            note: it.note,
                                            title:
                                                it.category ??
                                                'Moment Note'.localized(
                                                  context,
                                                ),
                                            category: it.category,
                                            dateStr: datePretty(
                                              it.primaryTimestamp,
                                            ),
                                            items: dayPreviewItems,
                                            initialIndex: noteIdx >= 0
                                                ? noteIdx
                                                : 0,
                                            onEdit: widget.onEditNote != null
                                                ? () => widget.onEditNote!(
                                                    it.moment,
                                                  )
                                                : null,
                                          );
                                        },
                                        child: IosEmojiText(
                                          it.note,
                                          maxLines:
                                              _expandedNoteIds.contains(
                                                it.moment.id,
                                              )
                                              ? null
                                              : 1,
                                          overflow:
                                              _expandedNoteIds.contains(
                                                it.moment.id,
                                              )
                                              ? TextOverflow.visible
                                              : TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: widget.p.text2,
                                            fontSize: 11.5,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                      if (it.note.contains('\n') ||
                                          it.note.length > 36)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2.0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              setState(() {
                                                if (_expandedNoteIds.contains(
                                                  it.moment.id,
                                                )) {
                                                  _expandedNoteIds.remove(
                                                    it.moment.id,
                                                  );
                                                } else {
                                                  _expandedNoteIds.add(
                                                    it.moment.id,
                                                  );
                                                }
                                              });
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _expandedNoteIds.contains(
                                                        it.moment.id,
                                                      )
                                                      ? Icons
                                                            .keyboard_arrow_up_rounded
                                                      : Icons
                                                            .keyboard_arrow_down_rounded,
                                                  size: 14,
                                                  color: widget.p.accent,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  _expandedNoteIds.contains(
                                                        it.moment.id,
                                                      )
                                                      ? 'Collapse'
                                                      : 'Expand note',
                                                  style: TextStyle(
                                                    color: widget.p.accent,
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                        ),
                        if (!isGodMode) ...[
                          () {
                            final matchingGoal = _findMatchingGoal(it);
                            if (matchingGoal == null) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6.5,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.p.accent.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: widget.p.accent.withValues(
                                      alpha: 0.35,
                                    ),
                                    width: 0.6,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flag_rounded,
                                      size: 10,
                                      color: widget.p.accent,
                                    ),
                                    const SizedBox(width: 3.5),
                                    Text(
                                      matchingGoal.title,
                                      style: TextStyle(
                                        color: widget.p.accent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }(),
                          Text(
                            it.type.toUpperCase(),
                            style: TextStyle(
                              color: widget.p.text3,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Combined collapsed voice & photo pills on same line
                    if (_isMomentVoiceCollapsed(it.moment.id) &&
                        _isMomentImageCollapsed(it.moment.id) &&
                        it.moment.voicePaths.isNotEmpty &&
                        it.moment.imagePath != null &&
                        it.moment.imagePath!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TimelineVoicePlayerPill.buildCollapsedPill(
                              p: widget.p,
                              count: it.moment.voicePaths.length,
                              onToggleCollapse: () =>
                                  _toggleMomentVoiceCollapse(it.moment.id),
                              compact: true,
                            ),
                            TimelineMediaAttachmentCard.buildCollapsedPill(
                              p: widget.p,
                              imagePath: it.moment.imagePath,
                              onToggleCollapse: () =>
                                  _toggleMomentImageCollapse(it.moment.id),
                              compact: true,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      if (_isMomentVoiceCollapsed(it.moment.id) &&
                          it.moment.voicePaths.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TimelineVoicePlayerPill.buildCollapsedPill(
                              p: widget.p,
                              count: it.moment.voicePaths.length,
                              onToggleCollapse: () =>
                                  _toggleMomentVoiceCollapse(it.moment.id),
                              compact: true,
                            ),
                          ),
                        )
                      else if (it.moment.voicePaths.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5.0,
                                bottom: 2.0,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: PressableScale(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    _toggleMomentVoiceCollapse(it.moment.id);
                                  },
                                  child: Container(
                                    height: 26,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.p.surface3.withValues(
                                        alpha: 0.55,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: widget.p.border.withValues(
                                          alpha: 0.45,
                                        ),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.mic_fill,
                                          size: 12,
                                          color: widget.p.accent,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${it.moment.voicePaths.length} Voice Memo${it.moment.voicePaths.length > 1 ? "s" : ""}',
                                          style: TextStyle(
                                            color: widget.p.text2,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          CupertinoIcons.chevron_up,
                                          size: 10,
                                          color: widget.p.text3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            for (final vp in it.moment.voicePaths) ...[
                              const SizedBox(height: 5),
                              TimelineVoicePlayerPill(
                                p: widget.p,
                                voicePath: vp,
                                durationMs: it.moment.voiceDurationMs ?? 0,
                              ),
                            ],
                          ],
                        ),
                      if (it.moment.imagePath != null) ...[
                        const SizedBox(height: 6),
                        TimelineMediaAttachmentCard(
                          p: widget.p,
                          imagePath: it.moment.imagePath!,
                          isCollapsed: _isMomentImageCollapsed(it.moment.id),
                          onToggleCollapse: () =>
                              _toggleMomentImageCollapse(it.moment.id),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        } else if (it is TimelineGapItem) {
          final gapKey = '${it.startTimestamp}-${it.endTimestamp}';
          final isClaimed =
              (widget.claimedGaps?.contains(gapKey) ?? false) ||
              _localClaimedGaps.contains(gapKey);
          if (isClaimed) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TimelineGapCard(
              p: widget.p,
              startTimestamp: it.startTimestamp,
              endTimestamp: it.endTimestamp,
              isProcessing: isClaimed,
              onTap: () {
                setState(() => _localClaimedGaps.add(gapKey));
                widget.onOpenManualEntry?.call(
                  prefilledStartTime: DateTime.fromMillisecondsSinceEpoch(
                    it.startTimestamp,
                  ),
                  prefilledEndTime: DateTime.fromMillisecondsSinceEpoch(
                    it.endTimestamp,
                  ),
                );
              },
              onClaimRest: widget.onClaimRest != null
                  ? () {
                      setState(() => _localClaimedGaps.add(gapKey));
                      widget.onClaimRest!(
                        DateTime.fromMillisecondsSinceEpoch(it.startTimestamp),
                        DateTime.fromMillisecondsSinceEpoch(it.endTimestamp),
                      );
                    }
                  : null,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
