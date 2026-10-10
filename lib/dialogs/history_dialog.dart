import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_date_picker_sheet.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/day_detail_sheet.dart';
import 'package:notekar/dialogs/goals_sheet.dart';
import 'package:notekar/dialogs/manual_entry_dialog.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/dialogs/personalization_setup_dialog.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/settings/life_audit_page.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/history_calendar_view.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/milestone_celebration_dialog.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/timeline_gap_card.dart';
import 'package:notekar/widgets/timeline_session_card.dart';
import 'package:notekar/widgets/timeline_single_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryDialog extends StatefulWidget {
  const HistoryDialog({
    super.key,
    required this.p,
    required this.entries,
    required this.compactRows,
    required this.largeText,
    required this.minimalMomentOptions,
    required this.confirmDelete,
    required this.onDelete,
    required this.onRestore,
    required this.onUpdateNote,
    this.onUpdateNoteWithTags,
    this.onUpdateMomentNote,
    required this.onDuration,
    this.onOpenTrash,
    this.onClearAll,
    this.onOpenSearchNotes,
    this.onOpenGodModeSettings,
    this.onOpenManualEntry,
    this.onClaimRest,
    this.onEndLiveSession,
    this.onRestoreLiveSession,
    this.activeCategory,
    this.isSessionRunning = false,
    this.onStopSession,
    this.blur = false,
    this.useNumbersInSingle = false,
    this.resetSingleDaily = false,
    this.initialView,
  });

  final Palette p;
  final List<Moment> entries;
  final bool compactRows;
  final bool largeText;
  final bool minimalMomentOptions;
  final bool confirmDelete;
  final Future<void> Function(int id) onDelete;
  final Future<void> Function(Moment entry) onRestore;
  final Future<void> Function(int id, String note) onUpdateNote;
  final Future<void> Function(int id, String note, List<String> tags)?
  onUpdateNoteWithTags;
  final Future<void> Function(
    int id,
    String note, [
    List<String>? tags,
    String? imagePath,
    String? voicePath,
    int? voiceDurationMs,
    bool updateMedia,
  ])?
  onUpdateMomentNote;
  final void Function(Moment a, Moment b) onDuration;
  final VoidCallback? onOpenTrash;
  final Future<void> Function()? onClearAll;
  final VoidCallback? onOpenSearchNotes;
  final VoidCallback? onOpenGodModeSettings;
  final void Function({
    DateTime? prefilledStartTime,
    DateTime? prefilledEndTime,
  })?
  onOpenManualEntry;
  final Future<List<Moment>> Function(DateTime start, DateTime end)?
  onClaimRest;
  final Future<void> Function(int inMomentId, Moment outEntry)?
  onEndLiveSession;
  final Future<void> Function(Moment inMoment)? onRestoreLiveSession;
  final String? activeCategory;
  final bool isSessionRunning;
  final VoidCallback? onStopSession;
  final bool blur;
  final bool useNumbersInSingle;
  final bool resetSingleDaily;
  final String? initialView;

  @override
  State<HistoryDialog> createState() => _HistoryDialogState();
}

sealed class _TimelineRowItem {}

class _SectionHeaderRow extends _TimelineRowItem {
  _SectionHeaderRow(this.section);

  final TimelineDaySection section;
}

class _TimelineElementRow extends _TimelineRowItem {
  _TimelineElementRow(this.item, {this.isFirst = false, this.isLast = false});

  final TimelineItem item;
  final bool isFirst;
  final bool isLast;
}

class _HistoryDialogState extends State<HistoryDialog> {
  static const _pageSize = 100;
  String _filter = 'all';
  String? _selectedDateKey;
  final List<Moment> _selected = [];
  late List<Moment> _entries;
  late Set<String> _availableDateKeys;
  Set<String> get availableDateKeys => _availableDateKeys;
  String? _notice;
  VoidCallback? _noticeUndo;
  Timer? _noticeTimer;
  int _noticeToken = 0;
  static const _noticeDuration = Duration(milliseconds: 3500);
  int _visibleCount = _pageSize;
  final _scrollController = ScrollController();
  bool _enableNoteOnClick = false;
  late bool _compactRows;
  String _viewMode = 'list';
  bool _showGapCards = false;
  bool _rainbowCards = false;
  TimelineDaySection? _activeInsightsSection;
  String? _inSheetView; // null, 'manual', 'goals', 'create_goal', 'life_audit'
  Goal? _editingGoal;
  List<Goal> _goals = [];
  double _sleepHours = 10.0;
  double _essentialsHours = 4.0;
  DateTime? _manualPrefilledStartTime;
  DateTime? _manualPrefilledEndTime;
  String? _activeGapKey;
  bool _isClaimingRest = false;
  bool _isEndingLiveSession = false;
  final Set<String> _claimedGaps = {};
  final Set<int> _endingSessionIds = {};
  bool _showImagesAlways = true;
  final Set<int> _manuallyExpandedMomentIds = {};
  final Set<int> _manuallyCollapsedMomentIds = {};

  bool _isMomentImageCollapsed(int id) {
    if (_manuallyExpandedMomentIds.contains(id)) return false;
    if (_manuallyCollapsedMomentIds.contains(id)) return true;
    return !_showImagesAlways;
  }

  void _toggleMomentImageCollapse(int id) {
    setState(() {
      final currentlyCollapsed = _isMomentImageCollapsed(id);
      if (currentlyCollapsed) {
        _manuallyCollapsedMomentIds.remove(id);
        _manuallyExpandedMomentIds.add(id);
      } else {
        _manuallyExpandedMomentIds.remove(id);
        _manuallyCollapsedMomentIds.add(id);
      }
    });
  }

  // Memoized lists & number maps
  List<TimelineDaySection> _daySections = [];
  List<_TimelineRowItem> _allTimelineRows = [];
  List<_TimelineRowItem> _timelineRows = [];
  Map<int, String> _singleNumberMap = {};

  Goal? _manualInitialGoal;
  bool _manualLockToSession = false;
  late bool _isSessionRunning;

  @override
  void initState() {
    super.initState();
    _isSessionRunning = widget.isSessionRunning;
    _inSheetView = widget.initialView;
    _compactRows = widget.compactRows;
    _entries = List<Moment>.from(widget.entries);
    _availableDateKeys = _entries.map((entry) => entry.date).toSet();
    _rebuildMemoizedLists();
    _loadHistoryPreferences();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final list = await GoalsService.instance.getGoals();
    if (mounted) {
      setState(() => _goals = list);
    }
  }

  Future<void> _loadHistoryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      final savedViewMode = prefs.getString('history_view_mode') ?? 'list';
      final savedGaps = prefs.getBool('show_gap_cards') ?? false;
      final savedRainbow = prefs.getBool('m-rainbow-cards') ?? false;
      final savedShowImagesAlways =
          prefs.getBool('history_show_images_always') ?? true;
      final savedClaimedGaps =
          prefs.getStringList('history_claimed_gaps') ?? [];
      if (savedClaimedGaps.isNotEmpty) {
        _claimedGaps.addAll(savedClaimedGaps);
      }
      setState(() {
        _enableNoteOnClick = prefs.getBool('enable_note_on_click') ?? false;
        _viewMode = savedViewMode;
        _showGapCards = savedGaps;
        _rainbowCards = savedRainbow;
        _showImagesAlways = savedShowImagesAlways;
        _sleepHours = prefs.getDouble('time_audit_sleep_hours') ?? 10.0;
        _essentialsHours =
            prefs.getDouble('time_audit_essentials_hours') ?? 4.0;
      });
      _rebuildMemoizedLists();
    }
  }

  Future<void> _persistClaimedGaps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history_claimed_gaps', _claimedGaps.toList());
  }

  bool _isProcessingTimeline = false;

  void _populateTimelineRows(TimelineIsolateResult result) {
    final sections = result.sections;
    _singleNumberMap = result.singleNumberMap;
    _daySections = sections;

    final allRows = <_TimelineRowItem>[];
    for (final sec in _daySections) {
      if (sec.items.isEmpty) continue;
      allRows.add(_SectionHeaderRow(sec));
      for (int i = 0; i < sec.items.length; i++) {
        allRows.add(
          _TimelineElementRow(
            sec.items[i],
            isFirst: i == 0,
            isLast: i == sec.items.length - 1,
          ),
        );
      }
    }

    _allTimelineRows = allRows;
    _updateVisibleItems();
    _isProcessingTimeline = false;
  }

  Future<void> _rebuildMemoizedLists() async {
    final payload = TimelineIsolatePayload(
      entries: _entries,
      includeGaps: _showGapCards,
      filter: _viewMode == 'calendar' ? 'all' : _filter,
      selectedDateKey: _selectedDateKey,
      today: dateKey(DateTime.now()),
      weekAgo: DateTime.now().subtract(const Duration(days: 7)),
    );

    // Fast synchronous path for smaller datasets (<200 moments) avoids isolate spawning overhead,
    // eliminates unsendable closure capturing issues, and allows immediate rendering on first frame.
    if (kIsWeb || _entries.length < 200) {
      final result = buildTimelineDataInIsolate(payload);
      _populateTimelineRows(result);
      if (mounted) {
        setState(() {});
      }
      return;
    }

    setState(() {
      _isProcessingTimeline = true;
    });

    final result = await compute(buildTimelineDataInIsolate, payload);

    if (!mounted) return;

    setState(() {
      _populateTimelineRows(result);
    });
  }

  void _updateVisibleItems() {
    _timelineRows = _allTimelineRows.take(_visibleCount).toList();
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _showNotice(String text, {VoidCallback? onUndo}) {
    _noticeTimer?.cancel();
    setState(() {
      _notice = text;
      _noticeUndo = onUndo;
      _noticeToken++;
    });
    _noticeTimer = Timer(_noticeDuration, () {
      if (mounted) {
        setState(() {
          _notice = null;
          _noticeUndo = null;
        });
      }
    });
  }

  bool get _hasOlderRows => _visibleCount < _allTimelineRows.length;

  IconData get _emptyIcon {
    return switch (_filter) {
      'today' => Icons.today_rounded,
      'week' => Icons.date_range_rounded,
      'date' => Icons.event_busy_rounded,
      'sessions' => Icons.hourglass_empty_rounded,
      'in' => Icons.login_rounded,
      'out' => Icons.logout_rounded,
      'single' => Icons.radio_button_checked_rounded,
      'notes' => Icons.speaker_notes_off_rounded,
      'media' => Icons.perm_media_rounded,
      _ => Icons.history_toggle_off_rounded,
    };
  }

  String get _emptyTitle {
    return switch (_filter) {
      'today' => 'Nothing Today',
      'week' => 'Clean Week',
      'date' => 'Empty Date',
      'sessions' => 'No Sessions',
      'in' => 'No IN Moments',
      'out' => 'No OUT Moments',
      'single' => 'No Single Logs',
      'notes' => 'No Notes Found',
      'media' => 'No Media Moments',
      _ => 'No History',
    };
  }

  String get _emptyMessage {
    return switch (_filter) {
      'today' => 'Your moments for today will appear here as you log them.',
      'week' => 'You haven\'t saved any moments during the last seven days.',
      'date' => 'There are no records for this specific calendar day.',
      'sessions' =>
        'Two-Way IN and OUT moments are automatically grouped into sessions.',
      'in' => 'IN moments are created when using Two-Way logging mode.',
      'out' => 'OUT moments complete the pair in Two-Way logging mode.',
      'single' => 'Single logs are standalone timestamps for one-shot events.',
      'notes' =>
        'Moments with text notes will be listed here for quick review.',
      'media' =>
        'Moments with voice notes or attached images will appear here.',
      _ => 'Start capturing moments by tapping the clock on the home screen.',
    };
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showIosConfirmSheet(
      context,
      p: widget.p,
      title: 'Delete All Moments?'.localized(context),
      message:
          'Are you sure you want to delete all history moments? Deleted moments will be moved to Trash Bin.'
              .localized(context),
      confirmLabel: 'Delete All'.localized(context),
      isDestructive: true,
      icon: Icons.delete_sweep_rounded,
    );

    if (confirmed == true && widget.onClearAll != null) {
      await widget.onClearAll!();
      if (mounted) {
        setState(() {
          _entries.clear();
          _rebuildMemoizedLists();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasOlderRows = _hasOlderRows;

    return PopScope(
      canPop: _activeInsightsSection == null && _inSheetView == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_inSheetView == 'create_goal') {
            setState(() => _inSheetView = 'goals');
          } else if (_inSheetView != null) {
            setState(() => _inSheetView = null);
          } else if (_activeInsightsSection != null) {
            setState(() => _activeInsightsSection = null);
          }
        }
      },
      child: AppSheet(
        p: widget.p,
        title: _inSheetView == 'manual'
            ? 'Log Past Moment'.localized(context)
            : _inSheetView == 'goals'
            ? 'Targets & Goals'.localized(context)
            : _inSheetView == 'create_goal'
            ? (_editingGoal == null ? 'New Target Goal' : 'Edit Target Goal')
                  .localized(context)
            : _inSheetView == 'life_audit'
            ? 'Life Audit & Horizon'.localized(context)
            : _activeInsightsSection != null
            ? _activeInsightsSection!.displayTitle
            : 'History'.localized(context),
        docked: true,
        blur: widget.blur,
        largeText: widget.largeText,
        controller: _scrollController,
        showLargeTitle:
            _inSheetView == null &&
            _activeInsightsSection == null &&
            _viewMode == 'list',
        removeBottomPadding: true,
        leadingAction: (_inSheetView != null || _activeInsightsSection != null)
            ? Tooltip(
                message: 'Back'.localized(context),
                child: PressableScale(
                  onTap: () {
                    if (_inSheetView == 'create_goal') {
                      setState(() => _inSheetView = 'goals');
                    } else if (_inSheetView == 'manual') {
                      final fromGoals = _manualInitialGoal != null;
                      setState(() {
                        _manualPrefilledStartTime = null;
                        _manualPrefilledEndTime = null;
                        _activeGapKey = null;
                        _manualInitialGoal = null;
                        _manualLockToSession = false;
                        _inSheetView = fromGoals ? 'goals' : null;
                      });
                    } else if (_inSheetView != null) {
                      setState(() => _inSheetView = null);
                    } else if (_activeInsightsSection != null) {
                      setState(() => _activeInsightsSection = null);
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.p.surface3,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: widget.p.text,
                      size: 19,
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Targets & Goals Flag Button (Swapped with View Switcher)
                  Semantics(
                    button: true,
                    label: 'Targets & Goals'.localized(context),
                    child: Tooltip(
                      message: 'Targets & Goals'.localized(context),
                      child: PressableScale(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _inSheetView = 'goals');
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: widget.p.surface3,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.flag_rounded,
                            size: 19,
                            color: widget.p.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.onOpenSearchNotes != null) ...[
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Search Notes'.localized(context),
                      child: Tooltip(
                        message: 'Search Notes'.localized(context),
                        child: PressableScale(
                          onTap: () {
                            widget.onOpenSearchNotes!();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.p.surface3,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_rounded,
                              color: widget.p.text,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
        trailingAction: _inSheetView == 'goals'
            ? (_goals.isNotEmpty
                  ? Tooltip(
                      message: 'New Goal'.localized(context),
                      child: PressableScale(
                        onTap: () {
                          setState(() {
                            _editingGoal = null;
                            _inSheetView = 'create_goal';
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: widget.p.accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: widget.p.accent,
                            size: 19,
                          ),
                        ),
                      ),
                    )
                  : null)
            : (_inSheetView != null || _activeInsightsSection != null)
            ? null
            : Tooltip(
                message: 'More Options'.localized(context),
                child: PressableScale(
                  onTap: () {
                    _showThreeDotsMenu();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.p.surface3,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: widget.p.text,
                      size: 20,
                    ),
                  ),
                ),
              ),
        child: SizedBox(
          width: double.infinity,
          height: math.min(MediaQuery.sizeOf(context).height * 0.75, 680),
          child: _inSheetView == 'manual'
              ? FutureBuilder<List<String>>(
                  future: CategoryService().getCategories(),
                  builder: (context, catSnapshot) {
                    final cats = catSnapshot.data ?? const ['General'];
                    return ManualEntryContent(
                      p: widget.p,
                      categories: cats,
                      initialCategory: _manualInitialGoal?.category ?? 'All',
                      initialGoal: _manualInitialGoal,
                      moments: _entries,
                      prefilledStartTime: _manualPrefilledStartTime,
                      prefilledEndTime: _manualPrefilledEndTime,
                      lockToSession:
                          _manualLockToSession ||
                          _manualPrefilledEndTime != null,
                      onSubmit: (res) {
                        if (_manualPrefilledStartTime != null &&
                            _manualPrefilledEndTime != null) {
                          _claimedGaps.add(
                            '${_manualPrefilledStartTime!.millisecondsSinceEpoch}-${_manualPrefilledEndTime!.millisecondsSinceEpoch}',
                          );
                        }
                        if (_activeGapKey != null) {
                          _claimedGaps.add(_activeGapKey!);
                        }
                        unawaited(_persistClaimedGaps());
                        _manualPrefilledStartTime = null;
                        _manualPrefilledEndTime = null;
                        _activeGapKey = null;
                        final fromGoals = _manualInitialGoal != null;
                        _manualInitialGoal = null;
                        _manualLockToSession = false;
                        _handleManualEntrySubmit(res, returnToGoals: fromGoals);
                      },
                      onCancel: () {
                        setState(() {
                          _manualPrefilledStartTime = null;
                          _manualPrefilledEndTime = null;
                          _activeGapKey = null;
                          final fromGoals = _manualInitialGoal != null;
                          _manualInitialGoal = null;
                          _manualLockToSession = false;
                          _inSheetView = fromGoals ? 'goals' : null;
                        });
                      },
                    );
                  },
                )
              : _inSheetView == 'goals'
              ? GoalsContentView(
                  p: widget.p,
                  moments: _entries,
                  activeCategory: widget.activeCategory,
                  isSessionRunning: _isSessionRunning,
                  onStopSession: _stopActiveSessionFromGoals,
                  onManualEntry: (goal) {
                    setState(() {
                      _manualInitialGoal = goal;
                      _manualLockToSession = true;
                      _manualPrefilledStartTime = null;
                      _manualPrefilledEndTime = null;
                      _inSheetView = 'manual';
                    });
                  },
                  onAddGoal: () {
                    setState(() {
                      _editingGoal = null;
                      _inSheetView = 'create_goal';
                    });
                  },
                  onEditGoal: (g) {
                    setState(() {
                      _editingGoal = g;
                      _inSheetView = 'create_goal';
                    });
                  },
                  onStartSession: (g) {
                    Navigator.pop(context, {
                      'action': 'start_goal_session',
                      'category': g.category,
                      'mode': g.mode ?? 'two-way',
                      'goalId': g.id,
                    });
                  },
                  onGoalsCountChanged: (count) {
                    _loadGoals();
                  },
                )
              : _inSheetView == 'create_goal'
              ? CreateOrEditGoalView(
                  p: widget.p,
                  goal: _editingGoal,
                  onSave: (saved) async {
                    await GoalsService.instance.saveGoal(saved);
                    setState(() {
                      _editingGoal = null;
                      _inSheetView = 'goals';
                    });
                  },
                  onCancel: () {
                    setState(() {
                      _editingGoal = null;
                      _inSheetView = 'goals';
                    });
                  },
                )
              : _inSheetView == 'life_audit'
              ? SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                  child: LifeAuditPage(
                    p: widget.p,
                    entries: _entries,
                    sleepHours: _sleepHours,
                    essentialsHours: _essentialsHours,
                    onOpenPersonalProfile: () async {
                      await PersonalizationSetupDialog.show(
                        context,
                        p: widget.p,
                        onSaved: () {
                          if (mounted) setState(() {});
                        },
                      );
                      if (mounted) setState(() {});
                    },
                    onSleepHoursChanged: (val) async {
                      setState(() => _sleepHours = val);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setDouble('time_audit_sleep_hours', val);
                    },
                    onEssentialsHoursChanged: (val) async {
                      setState(() => _essentialsHours = val);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setDouble('time_audit_essentials_hours', val);
                    },
                  ),
                )
              : _activeInsightsSection != null
              ? DayDetailContent(
                  p: widget.p,
                  section: _activeInsightsSection!,
                  allEntries: _entries,
                  onEditNote: _openDirectNoteEditor,
                  onOpenManualEntry: _handleOpenManualEntry,
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
                )
              : _viewMode == 'calendar'
              ? HistoryCalendarView(
                  p: widget.p,
                  sections: _daySections,
                  allEntries: _entries,
                  goals: _goals,
                  initialDateKey: _selectedDateKey,
                  onEditNote: _openDirectNoteEditor,
                  onOpenManualEntry: _handleOpenManualEntry,
                  onClaimRest: _claimRest,
                  onEndLiveSession: _endLiveSession,
                  endingSessionIds: _endingSessionIds,
                  claimedGaps: _claimedGaps,
                  onOpenInsights: (sec) {
                    setState(() => _activeInsightsSection = sec);
                  },
                  onDelete: _removeEntry,
                  onDeleteSession: _removeSession,
                  rainbowCards: _rainbowCards,
                  onOpenGodModeSettings: _openGodModeSettings,
                  isMomentImageCollapsed: _isMomentImageCollapsed,
                  onToggleMomentImageCollapse: _toggleMomentImageCollapse,
                )
              : Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onScaleUpdate: (details) {
                          if (details.pointerCount >= 2) {
                            if (details.scale < 0.85 && !_compactRows) {
                              NotekarHaptics.selection('standard');
                              setState(() => _compactRows = true);
                              unawaited(
                                SharedPreferences.getInstance().then(
                                  (prefs) =>
                                      prefs.setBool('m-compact-history', true),
                                ),
                              );
                            } else if (details.scale > 1.15 && _compactRows) {
                              NotekarHaptics.selection('standard');
                              setState(() => _compactRows = false);
                              unawaited(
                                SharedPreferences.getInstance().then(
                                  (prefs) =>
                                      prefs.setBool('m-compact-history', false),
                                ),
                              );
                            }
                          }
                        },
                        child: CustomScrollView(
                          key: const PageStorageKey<String>(
                            'history_timeline_scroll_view',
                          ),
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: AppSheetLargeTitle(
                                  p: widget.p,
                                  title: 'History'.localized(context),
                                  scrollController: _scrollController,
                                ),
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: SliverStickyHeaderDelegate(
                                height:
                                    56.0 + (_selected.isNotEmpty ? 52.0 : 0.0),
                                child: Container(
                                  color: widget.p.surface.withValues(
                                    alpha: widget.blur ? 0.65 : 1.0,
                                  ),
                                  padding: const EdgeInsets.only(
                                    bottom: spacing8,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2.0,
                                                  ),
                                              child: Row(
                                                children: [
                                                  for (final f in const [
                                                    'all',
                                                    'sessions',
                                                    'single',
                                                    'notes',
                                                    'media',
                                                    'date',
                                                  ])
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: spacing8,
                                                          ),
                                                      child: ChipButton(
                                                        p: widget.p,
                                                        label: f == 'date'
                                                            ? (_selectedDateKey !=
                                                                          null &&
                                                                      _selectedDateKey !=
                                                                          dateKey(
                                                                            DateTime.now(),
                                                                          )
                                                                  ? fullDateLabel(
                                                                      _selectedDateKey!,
                                                                    )
                                                                  : null)
                                                            : switch (f) {
                                                                'all' =>
                                                                  'All'
                                                                      .localized(
                                                                        context,
                                                                      ),
                                                                'sessions' =>
                                                                  'Sessions'
                                                                      .localized(
                                                                        context,
                                                                      ),
                                                                'single' =>
                                                                  'Singles'
                                                                      .localized(
                                                                        context,
                                                                      ),
                                                                'notes' =>
                                                                  'With Notes'
                                                                      .localized(
                                                                        context,
                                                                      ),
                                                                'media' =>
                                                                  'Media'
                                                                      .localized(
                                                                        context,
                                                                      ),
                                                                _ => f,
                                                              },
                                                        icon: f == 'date'
                                                            ? Icons
                                                                  .calendar_today_rounded
                                                            : null,
                                                        active: _filter == f,
                                                        onTap: f == 'date'
                                                            ? () =>
                                                                  _openDateFilter()
                                                            : () {
                                                                setState(() {
                                                                  _filter = f;
                                                                  _selectedDateKey =
                                                                      null;
                                                                  _visibleCount =
                                                                      _pageSize;
                                                                  _rebuildMemoizedLists();
                                                                });
                                                                if (_scrollController
                                                                    .hasClients) {
                                                                  _scrollController
                                                                      .jumpTo(
                                                                        0.0,
                                                                      );
                                                                }
                                                              },
                                                        onLongPress: f == 'date'
                                                            ? _openDateFilter
                                                            : null,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: spacing8),
                                          Tooltip(
                                            message: 'Scroll to top',
                                            child: PressableScale(
                                              onTap: () {
                                                if (!_scrollController
                                                    .hasClients) {
                                                  return;
                                                }
                                                _scrollController.animateTo(
                                                  0,
                                                  duration: const Duration(
                                                    milliseconds: 250,
                                                  ),
                                                  curve: Curves.easeOutCubic,
                                                );
                                              },
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: widget.p.surface2,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: widget.p.border,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .keyboard_double_arrow_up_rounded,
                                                  color: widget.p.text2,
                                                  size: 19,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                      ),
                                      AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 160,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        child: _selected.isEmpty
                                            ? const SizedBox.shrink()
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      0,
                                                      spacing8,
                                                      0,
                                                      0,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: PressableScale(
                                                        onTap: () => setState(
                                                          () =>
                                                              _selected.clear(),
                                                        ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 7,
                                                                horizontal: 14,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: widget
                                                                .p
                                                                .accent
                                                                .withValues(
                                                                  alpha: 0.12,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  999,
                                                                ),
                                                            border: Border.all(
                                                              color: widget
                                                                  .p
                                                                  .accent
                                                                  .withValues(
                                                                    alpha: 0.20,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Selected ${_selected.length} of 2 for duration'
                                                                .localized(
                                                                  context,
                                                                ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: widget
                                                                  .p
                                                                  .accent,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    PressableScale(
                                                      onTap: () => setState(
                                                        () => _selected.clear(),
                                                      ),
                                                      child: Container(
                                                        width: 32,
                                                        height: 32,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: widget
                                                                  .p
                                                                  .accent
                                                                  .withValues(
                                                                    alpha: 0.14,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                color: widget
                                                                    .p
                                                                    .accent
                                                                    .withValues(
                                                                      alpha:
                                                                          0.22,
                                                                    ),
                                                              ),
                                                            ),
                                                        child: Icon(
                                                          Icons.close_rounded,
                                                          size: 16,
                                                          color:
                                                              widget.p.accent,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            () {
                              final todayK = dateKey(DateTime.now());
                              final activeSec = _daySections
                                  .where(
                                    (s) =>
                                        s.dateKey ==
                                        (_selectedDateKey ?? todayK),
                                  )
                                  .firstOrNull;
                              if (activeSec != null &&
                                  activeSec.items.isNotEmpty &&
                                  _viewMode != 'calendar') {
                                return SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      0,
                                      0,
                                      spacing12,
                                    ),
                                    child: _TodayInlineInsightCard(
                                      p: widget.p,
                                      section: activeSec,
                                    ),
                                  ),
                                );
                              }
                              return const SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              );
                            }(),
                            if (_isProcessingTimeline && _timelineRows.isEmpty)
                              const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_timelineRows.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: HIGEmptyState(
                                  p: widget.p,
                                  icon: _emptyIcon,
                                  title: _emptyTitle,
                                  message: _emptyMessage,
                                  actionLabel: _filter == 'all'
                                      ? 'Start Logging'
                                      : 'Show All',
                                  onAction: _filter == 'all'
                                      ? () => Navigator.pop(context)
                                      : () {
                                          setState(() {
                                            _filter = 'all';
                                            _visibleCount = _pageSize;
                                            _rebuildMemoizedLists();
                                          });
                                        },
                                ),
                              )
                            else
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  0,
                                  0,
                                  spacing48,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      if (index >= _timelineRows.length) {
                                        if (hasOlderRows) {
                                          return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              0,
                                              4,
                                              0,
                                              8,
                                            ),
                                            child: PressableScale(
                                              onTap: () => setState(() {
                                                _visibleCount += _pageSize;
                                                _updateVisibleItems();
                                              }),
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: widget.p.surface2,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                  border: Border.all(
                                                    color: widget.p.border,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Load older moments'
                                                      .localized(context),
                                                  style: TextStyle(
                                                    color: widget.p.accent,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return null;
                                      }

                                      final row = _timelineRows[index];
                                      if (row is _SectionHeaderRow) {
                                        final sec = row.section;
                                        return GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              _activeInsightsSection = sec;
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              4.0,
                                              _compactRows ? 8 : spacing16,
                                              4.0,
                                              _compactRows ? 4 : spacing8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_today_rounded,
                                                            size: 12,
                                                            color:
                                                                widget.p.text3,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              sec.displayTitle,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: widget
                                                                    .p
                                                                    .text,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                letterSpacing:
                                                                    -0.2,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: widget
                                                                      .p
                                                                      .surface3
                                                                      .withValues(
                                                                        alpha:
                                                                            0.5,
                                                                      ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                            child: Text(
                                                              '${sec.totalLogs}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: widget
                                                                    .p
                                                                    .text2,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontFeatures:
                                                                    const [
                                                                      FontFeature.tabularFigures(),
                                                                    ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (sec
                                                            .totalTrackedDuration
                                                            .inMinutes >
                                                        0)
                                                      Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              left: 8,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              const Color(
                                                                0xFF30D158,
                                                              ).withValues(
                                                                alpha: 0.12,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                999,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .timelapse_rounded,
                                                              size: 11,
                                                              color: Color(
                                                                0xFF30D158,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              sec.formattedTrackedDuration,
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFF30D158,
                                                                ),
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontFeatures: [
                                                                  FontFeature.tabularFigures(),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                if (sec.categorySummaryText !=
                                                    null) ...[
                                                  const SizedBox(height: 4),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 18,
                                                        ),
                                                    child: Text(
                                                      sec.categorySummaryText!,
                                                      style: TextStyle(
                                                        color: widget.p.text3,
                                                        fontSize: 10.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      final elem = row as _TimelineElementRow;
                                      if (elem.item is TimelineGapItem) {
                                        final gap =
                                            elem.item as TimelineGapItem;
                                        final gapKey =
                                            '${gap.startTimestamp}-${gap.endTimestamp}';
                                        if (_claimedGaps.contains(gapKey)) {
                                          return const SizedBox.shrink();
                                        }
                                        return TimelineGapCard(
                                          p: widget.p,
                                          startTimestamp: gap.startTimestamp,
                                          endTimestamp: gap.endTimestamp,
                                          isProcessing: _isClaimingRest,
                                          onTap: () {
                                            _handleOpenManualEntry(
                                              prefilledStartTime:
                                                  DateTime.fromMillisecondsSinceEpoch(
                                                    gap.startTimestamp,
                                                  ),
                                              prefilledEndTime:
                                                  DateTime.fromMillisecondsSinceEpoch(
                                                    gap.endTimestamp,
                                                  ),
                                            );
                                          },
                                          onClaimRest: () => _claimRest(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              gap.startTimestamp,
                                            ),
                                            DateTime.fromMillisecondsSinceEpoch(
                                              gap.endTimestamp,
                                            ),
                                          ),
                                        );
                                      }
                                      if (elem.item is TimelineSessionItem) {
                                        final session =
                                            elem.item as TimelineSessionItem;
                                        final isSelected = _selected.any(
                                          (m) =>
                                              session.momentIds.contains(m.id),
                                        );
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0,
                                          ),
                                          child: TimelineSessionCard(
                                            p: widget.p,
                                            session: session,
                                            selected: isSelected,
                                            compact: _compactRows,
                                            rainbowCards: _rainbowCards,
                                            isOngoing:
                                                session.isOngoing &&
                                                !_endingSessionIds.contains(
                                                  session.inMoment.id,
                                                ),
                                            goals: _goals,
                                            isImageCollapsed:
                                                _isMomentImageCollapsed(
                                                  session.noteMoment.id,
                                                ),
                                            onToggleImageCollapse: () =>
                                                _toggleMomentImageCollapse(
                                                  session.noteMoment.id,
                                                ),
                                            onEditNote: () =>
                                                _openDirectNoteEditor(
                                                  session.noteMoment,
                                                ),
                                            onDeleteSession: () =>
                                                _removeSession(session),
                                            onEndSession:
                                                (session.isOngoing &&
                                                    !_endingSessionIds.contains(
                                                      session.inMoment.id,
                                                    ))
                                                ? () => _endLiveSession(session)
                                                : null,
                                            onTapCard: _selected.isNotEmpty
                                                ? () => _handleSelection(
                                                    session.inMoment,
                                                    isSelected,
                                                  )
                                                : (_enableNoteOnClick
                                                      ? () =>
                                                            _openDirectNoteEditor(
                                                              session
                                                                  .noteMoment,
                                                            )
                                                      : () => _handleSelection(
                                                          session.inMoment,
                                                          isSelected,
                                                        )),
                                            onLongPressCard: () =>
                                                _showMomentDetails(
                                                  session.noteMoment,
                                                ),
                                          ),
                                        );
                                      }

                                      final single =
                                          elem.item as TimelineSingleItem;
                                      final moment = single.moment;
                                      final isSelected = _selected.any(
                                        (m) => m.id == moment.id,
                                      );
                                      final isGodMode =
                                          moment.note.trim() ==
                                              'Access granted' ||
                                          moment.note.contains(
                                            'God Mode Unlocked',
                                          ) ||
                                          moment.note.contains('#godmode') ||
                                          moment.note.toLowerCase().contains(
                                            'sovereign access granted',
                                          );

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0,
                                        ),
                                        child: TimelineSingleTile(
                                          p: widget.p,
                                          moment: moment,
                                          singleNumber:
                                              widget.useNumbersInSingle
                                              ? _singleNumberMap[moment.id]
                                              : null,
                                          selected: isSelected,
                                          compact: _compactRows,
                                          rainbowCards: _rainbowCards,
                                          isFirst: elem.isFirst,
                                          isLast: elem.isLast,
                                          isImageCollapsed:
                                              _isMomentImageCollapsed(
                                                moment.id,
                                              ),
                                          onToggleImageCollapse: () =>
                                              _toggleMomentImageCollapse(
                                                moment.id,
                                              ),
                                          onEditNote: () =>
                                              _openDirectNoteEditor(moment),
                                          onDelete: () => _removeEntry(moment),
                                          onTap: _selected.isNotEmpty
                                              ? () => _handleSelection(
                                                  moment,
                                                  isSelected,
                                                )
                                              : (_enableNoteOnClick
                                                    ? () =>
                                                          _openDirectNoteEditor(
                                                            moment,
                                                          )
                                                    : () => _handleSelection(
                                                        moment,
                                                        isSelected,
                                                      )),
                                          onLongPress: isGodMode
                                              ? _openGodModeSettings
                                              : () =>
                                                    _showMomentDetails(moment),
                                        ),
                                      );
                                    },
                                    childCount:
                                        _timelineRows.length +
                                        (hasOlderRows ? 1 : 0),
                                    addAutomaticKeepAlives: false,
                                    addRepaintBoundaries: true,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom:
                          spacing12, // Elevated to avoid touching the navigation area
                      left: 16,
                      right: 16,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        reverseDuration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutBack,
                        // Professional iOS spring curve
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0, 0.4),
                            end: Offset.zero,
                          ).animate(animation);
                          final scale = Tween<double>(
                            begin: 0.92,
                            end: 1.0,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: ScaleTransition(
                                scale: scale,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: _notice == null
                            ? const SizedBox.shrink()
                            : _HistoryNoticePill(
                                key: ValueKey('notice-pill-$_noticeToken'),
                                p: widget.p,
                                notice: _notice!,
                                onUndo: _noticeUndo,
                                token: _noticeToken,
                                duration: _noticeDuration,
                              ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _removeEntry(Moment entry) {
    NotekarHaptics.success(
      'standard',
    ); // History delete is an intentional success action
    setState(() {
      _entries = _entries.where((item) => item.id != entry.id).toList();
      _selected.removeWhere((item) => item.id == entry.id);
      _rebuildMemoizedLists();
    });
    _showNotice(
      'Moment removed'.localized(context),
      onUndo: () => _restoreRemovedEntry(entry),
    );
    unawaited(widget.onDelete(entry.id));
  }

  Future<void> _openDateFilter() async {
    if (_entries.isEmpty) {
      _showNotice('No moments to pick from');
      return;
    }
    final latest = _selectedDateKey == null
        ? DateTime.fromMillisecondsSinceEpoch(_entries.first.timestamp)
        : dateFromKey(_selectedDateKey!);
    final now = DateTime.now();
    final earliest = _entries.isNotEmpty
        ? DateTime.fromMillisecondsSinceEpoch(_entries.last.timestamp)
        : now.subtract(const Duration(days: 365));

    final picked = await AppDatePickerSheet.show(
      context,
      p: widget.p,
      title: 'Pick Specific Date'.localized(context),
      initialDateTime: latest,
      mode: CupertinoDatePickerMode.date,
      minimumDate: DateTime(earliest.year, earliest.month, earliest.day),
      maximumDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
    if (picked == null) return;
    setState(() {
      _selectedDateKey = dateKey(picked);
      _filter = 'date';
      _visibleCount = _pageSize;
      _rebuildMemoizedLists();
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  void _restoreRemovedEntry(Moment entry) {
    _noticeTimer?.cancel();
    setState(() {
      if (!_entries.any((item) => item.id == entry.id)) {
        _entries = [entry, ..._entries]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _availableDateKeys = _entries.map((item) => item.date).toSet();
      }
      _notice = null;
      _noticeUndo = null;
      _rebuildMemoizedLists();
    });
    unawaited(widget.onRestore(entry));
  }

  Future<void> _openDirectNoteEditor(Moment entry) async {
    final isAdd =
        entry.note.trim().isEmpty &&
        entry.imagePath == null &&
        entry.voicePath == null;
    final previousNote = entry.note;
    final previousImagePath = entry.imagePath;
    final previousVoicePath = entry.voicePath;
    final previousVoiceDuration = entry.voiceDurationMs;
    final title = (isAdd ? 'Add Note' : 'Edit Note').localized(context);
    final saveLabel = (isAdd ? 'Add Note' : 'Save').localized(context);
    final addedNotice = 'Note added'.localized(context);
    final updatedNotice = 'Note updated'.localized(context);

    HapticFeedback.selectionClick();
    final result = await showGeneralDialog<NoteResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close note editor',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => NoteDialog(
        p: widget.p,
        initialNote: entry.note,
        initialImagePath: entry.imagePath,
        initialVoicePath: entry.voicePath,
        initialVoiceDurationMs: entry.voiceDurationMs,
        title: title,
        saveLabel: saveLabel,
        allowEmpty: false,
      ),
    );

    if (result == null || !mounted) return;
    await _updateEntryNote(
      entry,
      result.note,
      tags: result.tags,
      imagePath: result.imagePath,
      voicePath: result.voicePath,
      voiceDurationMs: result.voiceDurationMs,
      updateMedia: true,
    );
    _showNotice(
      isAdd ? addedNotice : updatedNotice,
      onUndo: () {
        unawaited(
          _updateEntryNote(
            entry,
            previousNote,
            imagePath: previousImagePath,
            voicePath: previousVoicePath,
            voiceDurationMs: previousVoiceDuration,
            updateMedia: true,
          ),
        );
        _showNotice(
          isAdd
              ? 'Note removed'.localized(context)
              : 'Note restored'.localized(context),
        );
      },
    );
  }

  void _removeSession(TimelineSessionItem session) {
    final ids = session.momentIds;
    final toRemove = _entries.where((m) => ids.contains(m.id)).toList();
    if (toRemove.isEmpty) return;

    NotekarHaptics.success('standard');
    setState(() {
      _entries.removeWhere((m) => ids.contains(m.id));
      _availableDateKeys = _entries.map((item) => item.date).toSet();
      _selected.removeWhere((item) => ids.contains(item.id));
      _rebuildMemoizedLists();
    });

    _showNotice(
      ids.length > 1
          ? 'Session removed'.localized(context)
          : 'Moment removed'.localized(context),
      onUndo: () => _restoreRemovedEntries(toRemove),
    );

    for (final id in ids) {
      unawaited(widget.onDelete(id));
    }
  }

  Future<void> _claimRest(DateTime start, DateTime end) async {
    final effectiveEnd = end.isAfter(start)
        ? end
        : start.add(const Duration(minutes: 15));
    final gapKey =
        '${start.millisecondsSinceEpoch}-${effectiveEnd.millisecondsSinceEpoch}';
    if (_claimedGaps.contains(gapKey) || _isClaimingRest) return;
    _isClaimingRest = true;
    _claimedGaps.add(gapKey);
    if (mounted) setState(() {});

    try {
      List<Moment> savedMoments = const [];
      if (widget.onClaimRest != null) {
        savedMoments = await widget.onClaimRest!(start, effectiveEnd);
      }

      if (savedMoments.isEmpty) {
        final maxId = _entries.isEmpty
            ? 0
            : _entries.map((e) => e.id).reduce(math.max);
        final inMoment = Moment(
          id: math.max(maxId + 1, start.millisecondsSinceEpoch),
          timestamp: start.millisecondsSinceEpoch,
          type: 'in',
          date: dateKey(start),
          note: 'Rest & Recovery',
          category: 'Rest',
          tags: const ['rest'],
        );
        final outMoment = Moment(
          id: math.max(maxId + 2, effectiveEnd.millisecondsSinceEpoch),
          timestamp: effectiveEnd.millisecondsSinceEpoch,
          type: 'out',
          date: dateKey(effectiveEnd),
          note: 'Rest & Recovery',
          category: 'Rest',
          tags: const ['rest'],
        );
        savedMoments = [inMoment, outMoment];
        for (final m in savedMoments) {
          await widget.onRestore(m);
        }
      }

      if (savedMoments.length >= 2 && mounted) {
        NotekarHaptics.success('standard');
        final inMoment = savedMoments.firstWhere(
          (m) => m.type == 'in',
          orElse: () => savedMoments.first,
        );
        final outMoment = savedMoments.firstWhere(
          (m) => m.type == 'out',
          orElse: () => savedMoments.last,
        );

        setState(() {
          _entries = [...savedMoments, ..._entries]
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          _rebuildMemoizedLists();
        });
        unawaited(_persistClaimedGaps());

        _showNotice(
          '🌿 Rest & Recovery accounted in Life Audit',
          onUndo: () {
            _claimedGaps.remove(gapKey);
            unawaited(_persistClaimedGaps());
            _removeSession(
              TimelineSessionItem(inMoment: inMoment, outMoment: outMoment),
            );
          },
        );
      }
    } catch (error, stackTrace) {
      _claimedGaps.remove(gapKey);
      unawaited(_persistClaimedGaps());
      debugPrint('Could not save claimed rest interval: $error\n$stackTrace');
      if (mounted) {
        _showNotice(
          'Could not save Rest & Recovery. Your history was not changed.'
              .localized(context),
        );
      }
    } finally {
      _isClaimingRest = false;
    }
  }

  void _openGodModeSettings() {
    HapticFeedback.mediumImpact();
    if (widget.onOpenGodModeSettings != null) {
      widget.onOpenGodModeSettings!();
    } else {
      Navigator.of(context).pop('god_mode_settings');
    }
  }

  Future<void> _handleOpenManualEntry({
    DateTime? prefilledStartTime,
    DateTime? prefilledEndTime,
  }) async {
    setState(() {
      _manualPrefilledStartTime = prefilledStartTime;
      _manualPrefilledEndTime = prefilledEndTime;
      if (prefilledStartTime != null && prefilledEndTime != null) {
        _activeGapKey =
            '${prefilledStartTime.millisecondsSinceEpoch}-${prefilledEndTime.millisecondsSinceEpoch}';
      } else {
        _activeGapKey = null;
      }
      _inSheetView = 'manual';
    });
  }

  Future<void> _handleManualEntrySubmit(
    ManualEntryResult result, {
    bool returnToGoals = false,
  }) async {
    setState(() => _inSheetView = returnToGoals ? 'goals' : null);

    final List<Moment> addedMoments = [];
    final maxId = _entries.isEmpty
        ? 0
        : _entries.map((e) => e.id).reduce(math.max);

    if (_activeGapKey != null) {
      _claimedGaps.add(_activeGapKey!);
      _activeGapKey = null;
    }

    final goalId = result.linkedGoal?.id;
    final goalTag = goalId != null ? 'goal:$goalId' : null;
    final inTags = List<String>.from(result.tags);
    if (goalTag != null && !inTags.contains(goalTag)) {
      inTags.add(goalTag);
    }
    final outTags = goalTag != null ? [goalTag] : const <String>[];

    if (result.isSession && result.endDateTime != null) {
      final startMs = result.startDateTime.millisecondsSinceEpoch;
      var endMs = result.endDateTime!.millisecondsSinceEpoch;
      if (endMs <= startMs) {
        endMs = startMs + 60000;
      }
      final endDt = DateTime.fromMillisecondsSinceEpoch(endMs);
      _claimedGaps.add('$startMs-$endMs');

      final inMoment = Moment(
        id: math.max(maxId + 1, startMs),
        timestamp: startMs,
        type: 'in',
        date: dateKey(result.startDateTime),
        note: result.note,
        tags: inTags,
        category: result.category,
        goalId: goalId,
        imagePath: result.imagePath,
        voicePath: result.voicePath,
        voiceDurationMs: result.voiceDurationMs,
      );
      final outMoment = Moment(
        id: math.max(maxId + 2, endMs),
        timestamp: endMs,
        type: 'out',
        date: dateKey(endDt),
        note: '',
        tags: outTags,
        category: result.category,
        goalId: goalId,
      );

      addedMoments.addAll([inMoment, outMoment]);
    } else {
      final startMs = result.startDateTime.millisecondsSinceEpoch;
      final moment = Moment(
        id: math.max(maxId + 1, startMs),
        timestamp: startMs,
        type: 'single',
        date: dateKey(result.startDateTime),
        note: result.note,
        tags: inTags,
        category: result.category,
        goalId: goalId,
        imagePath: result.imagePath,
        voicePath: result.voicePath,
        voiceDurationMs: result.voiceDurationMs,
      );
      addedMoments.add(moment);
    }

    setState(() {
      _entries = [...addedMoments, ..._entries]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _availableDateKeys = _entries.map((item) => item.date).toSet();
      _rebuildMemoizedLists();
    });
    unawaited(_persistClaimedGaps());

    for (final m in addedMoments) {
      await widget.onRestore(m);
    }
    await _loadGoals();

    if (result.linkedGoal != null) {
      final goal = result.linkedGoal!;
      final progress = GoalsService.instance.calculateProgress(goal, _entries);
      if (progress.isCompleted && mounted) {
        showGoalCompletionCelebrationDialog(
          context: context,
          p: widget.p,
          goal: goal,
        );
      }
    }

    if (!mounted) return;
    final noticeText = result.isSession
        ? 'Session logged manually'.localized(context)
        : 'Moment logged manually'.localized(context);
    _showNotice(
      noticeText,
      onUndo: () async {
        _noticeTimer?.cancel();
        if (!mounted) return;
        setState(() {
          final idsToRemove = addedMoments.map((m) => m.id).toSet();
          _entries = _entries
              .where((e) => !idsToRemove.contains(e.id))
              .toList();
          _availableDateKeys = _entries.map((item) => item.date).toSet();
          _notice = null;
          _noticeUndo = null;
          _rebuildMemoizedLists();
        });
        for (final m in addedMoments) {
          await widget.onDelete(m.id);
        }
        await _loadGoals();
        if (mounted) {
          _showNotice('Moment reverted'.localized(context));
        }
      },
    );
  }

  void _showThreeDotsMenu() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(
          'Timeline Options'.localized(context),
          style: TextStyle(
            color: widget.p.text,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        actions: [
          if (widget.onOpenManualEntry != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _inSheetView = 'manual');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    size: 20,
                    color: widget.p.accent,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Add Manual Moment'.localized(context),
                    style: TextStyle(
                      color: widget.p.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              final nextMode = _viewMode == 'list' ? 'calendar' : 'list';
              setState(() => _viewMode = nextMode);
              unawaited(
                SharedPreferences.getInstance().then(
                  (prefs) => prefs.setString('history_view_mode', nextMode),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _viewMode == 'list'
                      ? Icons.calendar_today_rounded
                      : Icons.format_list_bulleted_rounded,
                  size: 20,
                  color: widget.p.text,
                ),
                const SizedBox(width: 10),
                Text(
                  _viewMode == 'list'
                      ? 'Calendar View'.localized(context)
                      : 'Timeline View'.localized(context),
                  style: TextStyle(
                    color: widget.p.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _inSheetView = 'life_audit');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_bottom_rounded,
                  size: 20,
                  color: widget.p.text,
                ),
                const SizedBox(width: 10),
                Text(
                  'Life Audit & Horizon'.localized(context),
                  style: TextStyle(
                    color: widget.p.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_viewMode == 'calendar')
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                _openFilterSheet();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tune_rounded, size: 20, color: widget.p.text),
                  const SizedBox(width: 10),
                  Text(
                    'Filter Timeline'.localized(context),
                    style: TextStyle(
                      color: widget.p.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.onClearAll != null && _entries.isNotEmpty)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(ctx);
                _confirmDeleteAll();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_rounded,
                    size: 20,
                    color: CupertinoColors.destructiveRed,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Delete All Moments'.localized(context),
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

  void _openFilterSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(
          'Filter Timeline'.localized(context),
          style: TextStyle(
            color: widget.p.text,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        message: Text(
          'Select moments to display'.localized(context),
          style: TextStyle(color: widget.p.text3, fontSize: 12),
        ),
        actions: [
          for (final f in [
            'all',
            'today',
            'week',
            'sessions',
            'single',
            'notes',
            'media',
            'date',
          ])
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                if (f == 'date') {
                  _openDateFilter();
                } else {
                  setState(() {
                    _filter = f;
                    _selectedDateKey = null;
                    _visibleCount = _pageSize;
                    _rebuildMemoizedLists();
                  });
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0.0);
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_filter == f) ...[
                    Icon(Icons.check_rounded, size: 16, color: widget.p.accent),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    switch (f) {
                      'all' => 'All Moments'.localized(context),
                      'today' => 'Today'.localized(context),
                      'week' => 'This Week'.localized(context),
                      'sessions' => 'Sessions (In/Out)'.localized(context),
                      'single' => 'Single Logs'.localized(context),
                      'notes' => 'With Notes'.localized(context),
                      'media' => 'Media (Voice/Images)'.localized(context),
                      'date' => 'Pick Specific Date...'.localized(context),
                      _ => f,
                    },
                    style: TextStyle(
                      color: _filter == f ? widget.p.accent : widget.p.text,
                      fontWeight: _filter == f
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 16,
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

  Future<void> _endLiveSession(TimelineSessionItem session) async {
    if (_endingSessionIds.contains(session.inMoment.id) ||
        _isEndingLiveSession) {
      return;
    }
    _endingSessionIds.add(session.inMoment.id);
    _isEndingLiveSession = true;
    try {
      NotekarHaptics.success('standard');

      final isRest =
          (session.category?.toLowerCase() == 'rest' ||
          session.category?.toLowerCase() == 'recovery' ||
          session.category?.toLowerCase() == 'rest & recovery' ||
          session.inMoment.note.toLowerCase().contains('rest') ||
          session.inMoment.tags.any((t) => t.toLowerCase() == 'rest'));

      // Find subsequent session boundaries on the SAME category or goal
      final sessionCat = isRest
          ? 'rest'
          : (session.category?.trim().toLowerCase() ?? '');
      final sessionGoal = session.goalId;
      final laterSessionMoments =
          _entries
              .where(
                (m) =>
                    m.timestamp > session.startTimestamp &&
                    (m.type == 'in' || m.type == 'out') &&
                    ((isRest &&
                            ((m.category?.toLowerCase() == 'rest') ||
                                (m.category?.toLowerCase() == 'recovery') ||
                                m.note.toLowerCase().contains('rest') ||
                                m.tags.any(
                                  (t) => t.toLowerCase() == 'rest',
                                ))) ||
                        (sessionCat.isNotEmpty &&
                            (m.category?.trim().toLowerCase() ?? '') ==
                                sessionCat) ||
                        (sessionGoal != null &&
                            m.effectiveGoalId == sessionGoal)),
              )
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final int effectiveTimestamp;
      if (laterSessionMoments.isNotEmpty) {
        final nextMoment = laterSessionMoments.first;
        final nextSessionStart = nextMoment.timestamp;
        final diff = nextSessionStart - session.startTimestamp;
        if (diff > 2000) {
          effectiveTimestamp = nextSessionStart - 1000;
        } else if (diff > 1) {
          effectiveTimestamp = session.startTimestamp + (diff ~/ 2);
        } else {
          effectiveTimestamp = session.startTimestamp + 1;
        }
      } else {
        final inDt = DateTime.fromMillisecondsSinceEpoch(
          session.startTimestamp,
        );
        final isToday = session.inMoment.date == dateKey(DateTime.now());
        if (isToday) {
          effectiveTimestamp = math.max(
            DateTime.now().millisecondsSinceEpoch,
            session.startTimestamp + 1000,
          );
        } else {
          final endOfDay = DateTime(
            inDt.year,
            inDt.month,
            inDt.day,
            23,
            59,
            59,
          ).millisecondsSinceEpoch;
          final fallbackEnd =
              session.startTimestamp + const Duration(hours: 1).inMilliseconds;
          final targetEnd = math.min(endOfDay, fallbackEnd);
          effectiveTimestamp = targetEnd > session.startTimestamp
              ? targetEnd
              : session.startTimestamp + 1000;
        }
      }

      final maxId = _entries.isEmpty
          ? 0
          : _entries.map((e) => e.id).reduce(math.max);
      final effectiveCategory = isRest
          ? 'Rest'
          : (session.category ?? session.inMoment.category);
      final outEntry = Moment(
        id: math.max(maxId + 1, effectiveTimestamp),
        timestamp: effectiveTimestamp,
        type: 'out',
        date: dateKey(DateTime.fromMillisecondsSinceEpoch(effectiveTimestamp)),
        note: isRest ? 'Rest & Recovery' : '',
        category: effectiveCategory,
        tags: isRest ? const ['rest'] : session.inMoment.tags,
        goalId: session.goalId,
      );
      setState(() {
        _entries = [outEntry, ..._entries]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _availableDateKeys = _entries.map((item) => item.date).toSet();
        _isSessionRunning = false;
        _rebuildMemoizedLists();
      });
      _showNotice(
        'Session ended'.localized(context),
        onUndo: () async {
          _endingSessionIds.remove(session.inMoment.id);
          _noticeTimer?.cancel();
          setState(() {
            _entries = _entries
                .where((item) => item.id != outEntry.id)
                .toList();
            _availableDateKeys = _entries.map((item) => item.date).toSet();
            _notice = null;
            _noticeUndo = null;
            _rebuildMemoizedLists();
          });
          await widget.onDelete(outEntry.id);
          if (widget.onRestoreLiveSession != null) {
            await widget.onRestoreLiveSession!(session.inMoment);
          }
          if (mounted) {
            _showNotice('Session restored'.localized(context));
          }
        },
      );
      if (widget.onEndLiveSession != null) {
        await widget.onEndLiveSession!(session.inMoment.id, outEntry);
      } else {
        await widget.onRestore(outEntry);
      }
    } finally {
      _isEndingLiveSession = false;
    }
  }

  Future<void> _stopActiveSessionFromGoals() async {
    TimelineSessionItem? ongoingSession;
    for (final sec in _daySections) {
      for (final item in sec.items) {
        if (item is TimelineSessionItem && item.isOngoing) {
          ongoingSession = item;
          break;
        }
      }
      if (ongoingSession != null) break;
    }

    if (ongoingSession != null) {
      await _endLiveSession(ongoingSession);
    } else if (widget.onStopSession != null) {
      widget.onStopSession!();
    }
    if (mounted) {
      setState(() {
        _isSessionRunning = false;
      });
      await _loadGoals();
    }
  }

  void _restoreRemovedEntries(List<Moment> moments) {
    _noticeTimer?.cancel();
    setState(() {
      for (final m in moments) {
        if (!_entries.any((item) => item.id == m.id)) {
          _entries.add(m);
        }
      }
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _availableDateKeys = _entries.map((item) => item.date).toSet();
      _notice = null;
      _noticeUndo = null;
      _rebuildMemoizedLists();
    });
    for (final m in moments) {
      unawaited(widget.onRestore(m));
    }
  }

  Future<void> _updateEntryNote(
    Moment entry,
    String note, {
    List<String>? tags,
    String? imagePath,
    String? voicePath,
    int? voiceDurationMs,
    bool updateMedia = false,
  }) async {
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index < 0) return;

    final effectiveTags =
        tags ??
        NoteTagExtractor.extractHashtags(
          note,
        ).map((t) => t.replaceFirst('#', '').toLowerCase()).toList();

    final updated = updateMedia
        ? entry.copyWith(
            note: note.trim(),
            tags: effectiveTags,
            imagePath: imagePath,
            clearImagePath: imagePath == null,
            voicePath: voicePath,
            clearVoicePath: voicePath == null,
            voiceDurationMs: voiceDurationMs,
          )
        : entry.copyWith(note: note.trim(), tags: effectiveTags);

    setState(() {
      _entries[index] = updated;

      final selectedIndex = _selected.indexWhere((item) => item.id == entry.id);

      if (selectedIndex >= 0) {
        _selected[selectedIndex] = updated;
      }
      _rebuildMemoizedLists();
    });

    if (widget.onUpdateMomentNote != null) {
      await widget.onUpdateMomentNote!(
        entry.id,
        updated.note,
        updated.tags,
        updated.imagePath,
        updated.voicePath,
        updated.voiceDurationMs,
        updateMedia,
      );
    } else if (widget.onUpdateNoteWithTags != null) {
      await widget.onUpdateNoteWithTags!(entry.id, updated.note, updated.tags);
    } else {
      await widget.onUpdateNote(entry.id, updated.note);
    }
  }

  void _handleSelection(Moment entry, bool selected) {
    setState(() {
      if (selected) {
        _selected.removeWhere((item) => item.id == entry.id);
      } else {
        if (_selected.length == 2) {
          _selected.removeAt(0);
        }
        _selected.add(entry);
      }
    });
    if (_selected.length == 2) {
      widget.onDuration(_selected[0], _selected[1]);
      setState(() => _selected.clear());
    }
  }

  Future<void> _showMomentDetails(Moment entry) async {
    HapticFeedback.selectionClick();

    await showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      barrierDismissible: true,
      barrierLabel: 'Close moment actions',
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (_, _, _) => MomentActionsDialog(
        p: widget.p,
        entry: entry,
        confirmDelete: widget.confirmDelete,
        minimal: widget.minimalMomentOptions,
        onAddOrEditNote: () async {
          Navigator.pop(context);

          final isAdd =
              entry.note.trim().isEmpty &&
              entry.imagePath == null &&
              entry.voicePath == null;
          final previousNote = entry.note;
          final previousImagePath = entry.imagePath;
          final previousVoicePath = entry.voicePath;
          final previousVoiceDuration = entry.voiceDurationMs;
          final addedNotice = (isAdd ? 'Note added' : 'Note updated').localized(
            context,
          );
          final removedNotice = (isAdd ? 'Note removed' : 'Note restored')
              .localized(context);
          final result = await showGeneralDialog<NoteResult>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.42),
            barrierDismissible: true,
            barrierLabel: 'Close note editor',
            transitionDuration: const Duration(milliseconds: 120),
            pageBuilder: (_, _, _) => NoteDialog(
              p: widget.p,
              initialNote: entry.note,
              initialImagePath: entry.imagePath,
              initialVoicePath: entry.voicePath,
              initialVoiceDurationMs: entry.voiceDurationMs,
              title: isAdd ? 'Add Note' : 'Edit Note',
              saveLabel: isAdd ? 'Add Note' : 'Save',
              allowEmpty: false,
            ),
          );

          if (result == null || !mounted) return;

          await _updateEntryNote(
            entry,
            result.note,
            tags: result.tags,
            imagePath: result.imagePath,
            voicePath: result.voicePath,
            voiceDurationMs: result.voiceDurationMs,
            updateMedia: true,
          );
          _showNotice(
            addedNotice,
            onUndo: () {
              unawaited(
                _updateEntryNote(
                  entry,
                  previousNote,
                  imagePath: previousImagePath,
                  voicePath: previousVoicePath,
                  voiceDurationMs: previousVoiceDuration,
                  updateMedia: true,
                ),
              );
              _showNotice(removedNotice);
            },
          );
        },
        onDeleteNote:
            (entry.note.trim().isEmpty &&
                entry.imagePath == null &&
                entry.voicePath == null)
            ? null
            : () async {
                Navigator.pop(context);
                final previous = entry.note;
                final previousImagePath = entry.imagePath;
                final previousVoicePath = entry.voicePath;
                final previousVoiceDuration = entry.voiceDurationMs;
                await _updateEntryNote(
                  entry,
                  '',
                  imagePath: null,
                  voicePath: null,
                  voiceDurationMs: null,
                  updateMedia: true,
                );
                _showNotice(
                  'Note deleted',
                  onUndo: () {
                    unawaited(
                      _updateEntryNote(
                        entry,
                        previous,
                        imagePath: previousImagePath,
                        voicePath: previousVoicePath,
                        voiceDurationMs: previousVoiceDuration,
                        updateMedia: true,
                      ),
                    );
                    _showNotice('Note restored');
                  },
                );
              },
        onDeleteMoment: () {
          Navigator.pop(context);
          _removeEntry(entry);
        },
      ),
    );
  }
}

class MomentActionsDialog extends StatefulWidget {
  const MomentActionsDialog({
    super.key,
    required this.p,
    required this.entry,
    required this.confirmDelete,
    required this.onAddOrEditNote,
    required this.onDeleteMoment,
    this.onDeleteNote,
    this.minimal = false,
  });

  final Palette p;
  final Moment entry;
  final bool confirmDelete;
  final VoidCallback onAddOrEditNote;
  final VoidCallback? onDeleteNote;
  final VoidCallback onDeleteMoment;
  final bool minimal;

  @override
  State<MomentActionsDialog> createState() => _MomentActionsDialogState();
}

class _MomentActionsDialogState extends State<MomentActionsDialog> {
  String? _pendingAction;

  void _confirmOrRun(String action, VoidCallback callback) {
    if (!widget.confirmDelete || _pendingAction == action) {
      callback();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _pendingAction = action);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final entry = widget.entry;
    final hasNote = entry.note.trim().isNotEmpty;

    if (widget.minimal) {
      return AppSheet(
        p: p,
        title: 'Moment Options',
        child: SizedBox(
          width: 430,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SettingsStatusPill(
                    p: p,
                    label: entry.type.toUpperCase(),
                    color: momentColor(p, entry.type),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${datePretty(entry.timestamp)} at '
                      '${timeOnly(entry.timestamp)}',
                      style: TextStyle(color: p.text2, fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (hasNote) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.border),
                  ),
                  child: SingleChildScrollView(
                    child: IosEmojiText(
                      entry.note,
                      style: TextStyle(color: p.text, height: 1.45),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MinimalActionButton(
                    p: p,
                    icon: hasNote
                        ? Icons.edit_rounded
                        : Icons.add_comment_rounded,
                    color: p.accent,
                    onTap: widget.onAddOrEditNote,
                  ),
                  if (widget.onDeleteNote != null) ...[
                    const SizedBox(width: 20),
                    _MinimalActionButton(
                      p: p,
                      icon: Icons.comments_disabled_rounded,
                      color: p.orange,
                      pending: _pendingAction == 'note',
                      onTap: () => _confirmOrRun('note', widget.onDeleteNote!),
                    ),
                  ],
                  const SizedBox(width: 20),
                  _MinimalActionButton(
                    p: p,
                    icon: Icons.delete_outline_rounded,
                    color: p.red,
                    pending: _pendingAction == 'moment',
                    onTap: () => _confirmOrRun('moment', widget.onDeleteMoment),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }

    return AppSheet(
      p: p,
      title: 'Moment Options',
      child: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SettingsStatusPill(
                  p: p,
                  label: entry.type.toUpperCase(),
                  color: momentColor(p, entry.type),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${datePretty(entry.timestamp)} at '
                    '${timeOnly(entry.timestamp)}',
                    style: TextStyle(color: p.text2, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (hasNote) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.border),
                ),
                child: SingleChildScrollView(
                  child: IosEmojiText(
                    entry.note,
                    style: TextStyle(color: p.text, height: 1.45),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: MomentOptionPill(
                    p: p,
                    icon: hasNote
                        ? Icons.edit_rounded
                        : Icons.add_comment_rounded,
                    label: hasNote ? 'Edit Note' : 'Add Note',
                    color: p.accent,
                    onTap: widget.onAddOrEditNote,
                  ),
                ),
                if (widget.onDeleteNote != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: MomentOptionPill(
                      p: p,
                      icon: Icons.comments_disabled_rounded,
                      label: _pendingAction == 'note'
                          ? 'Confirm'
                          : 'Delete Note',
                      color: p.orange,
                      onTap: () => _confirmOrRun('note', widget.onDeleteNote!),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            MomentOptionPill(
              p: p,
              icon: Icons.delete_outline_rounded,
              label: _pendingAction == 'moment' ? 'Confirm' : 'Delete Moment',
              color: p.red,
              fullWidth: true,
              onTap: () => _confirmOrRun('moment', widget.onDeleteMoment),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalActionButton extends StatelessWidget {
  const _MinimalActionButton({
    required this.p,
    required this.icon,
    required this.color,
    required this.onTap,
    this.pending = false,
  });

  final Palette p;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: pending ? color : color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: pending ? color : color.withValues(alpha: 0.28),
            width: 2,
          ),
        ),
        child: Icon(
          pending ? Icons.check_rounded : icon,
          color: pending ? Colors.white : color,
          size: 26,
        ),
      ),
    );
  }
}

class MomentOptionPill extends StatelessWidget {
  const MomentOptionPill({
    super.key,
    required this.p,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  final Palette p;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        NotekarHaptics.selection('standard');
        onTap();
      },
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label.localized(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryNoticePill extends StatefulWidget {
  const _HistoryNoticePill({
    super.key,
    required this.p,
    required this.notice,
    this.onUndo,
    required this.token,
    this.duration = const Duration(milliseconds: 3500),
  });

  final Palette p;
  final String notice;
  final VoidCallback? onUndo;
  final int token;
  final Duration duration;

  @override
  State<_HistoryNoticePill> createState() => _HistoryNoticePillState();
}

class _HistoryNoticePillState extends State<_HistoryNoticePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void didUpdateWidget(covariant _HistoryNoticePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.p.name == 'amoled'
            ? Colors.black
            : (!widget.p.isDark
                  ? Colors.white.withValues(alpha: 0.96)
                  : widget.p.surface2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: !widget.p.isDark
              ? widget.p.border
              : (widget.p.name == 'amoled'
                    ? widget.p.border
                    : widget.p.border.withValues(alpha: 0.6)),
        ),
        boxShadow: widget.p.name == 'amoled'
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: !widget.p.isDark ? 0.08 : 0.18,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (1 - _controller.value).clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.p.accent.withValues(alpha: 0.12),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.notice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.p.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.onUndo != null) ...[
                    const SizedBox(width: 10),
                    PressableScale(
                      onTap: widget.onUndo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: widget.p.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Undo'.localized(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayInlineInsightCard extends StatelessWidget {
  const _TodayInlineInsightCard({required this.p, required this.section});

  final Palette p;
  final TimelineDaySection section;

  String _formatDuration(Duration d) {
    final totalMins = d.inMinutes;
    if (totalMins <= 0) return '0m';
    final hours = totalMins ~/ 60;
    final mins = totalMins % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final dayItems = section.items;
    int morningMs = 0;
    int afternoonMs = 0;
    int eveningMs = 0;
    int nightMs = 0;
    int longestSessionMs = 0;
    final Map<int, int> hourActivity = {};

    for (final it in dayItems) {
      final dt = DateTime.fromMillisecondsSinceEpoch(it.primaryTimestamp);
      final hour = dt.hour;
      hourActivity[hour] = (hourActivity[hour] ?? 0) + 1;

      final int durMs;
      if (it is TimelineSessionItem) {
        durMs = it.duration.inMilliseconds;
        longestSessionMs = math.max(longestSessionMs, durMs);
      } else if (it is TimelineSingleItem) {
        durMs = 15 * 60 * 1000;
      } else {
        durMs = 0;
      }

      if (hour >= 6 && hour < 12) {
        morningMs += durMs;
      } else if (hour >= 12 && hour < 17) {
        afternoonMs += durMs;
      } else if (hour >= 17 && hour < 21) {
        eveningMs += durMs;
      } else {
        nightMs += durMs;
      }
    }

    int? peakHour;
    int maxHourCount = 0;
    hourActivity.forEach((hour, count) {
      if (count > maxHourCount) {
        maxHourCount = count;
        peakHour = hour;
      }
    });

    final totalTracked = section.totalTrackedDuration;
    const consciousWindow = Duration(hours: 10);
    final intentionalityRatio = consciousWindow.inMilliseconds > 0
        ? (totalTracked.inMilliseconds / consciousWindow.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    final isToday = section.dateKey == dateKey(DateTime.now());
    final title = isToday
        ? "TODAY'S INSIGHTS".localized(context)
        : "${section.displayTitle.toUpperCase()} INSIGHTS";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 13, color: p.accent),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(intentionalityRatio * 100).toStringAsFixed(0)}% Intentional',
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: intentionalityRatio,
              minHeight: 5,
              backgroundColor: p.surface3,
              valueColor: AlwaysStoppedAnimation<Color>(p.accent),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Tracked',
                  _formatDuration(totalTracked),
                  p.accent,
                ),
              ),
              Container(
                width: 0.5,
                height: 24,
                color: p.border.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _buildMetric(
                  'Longest Flow',
                  longestSessionMs > 0
                      ? _formatDuration(
                          Duration(milliseconds: longestSessionMs),
                        )
                      : '--',
                  p.green,
                ),
              ),
              Container(
                width: 0.5,
                height: 24,
                color: p.border.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _buildMetric(
                  'Peak Hour',
                  peakHour != null ? '${peakHour!}:00' : '--',
                  p.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildRhythmSegment('Morning', morningMs, p.orange),
              const SizedBox(width: 4),
              _buildRhythmSegment('Afternoon', afternoonMs, p.accent),
              const SizedBox(width: 4),
              _buildRhythmSegment(
                'Evening',
                eveningMs,
                const Color(0xFFAF52DE),
              ),
              const SizedBox(width: 4),
              _buildRhythmSegment('Night', nightMs, const Color(0xFF30B0C7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color col) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: p.text3,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: col,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildRhythmSegment(String label, int ms, Color col) {
    final active = ms > 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? col.withValues(alpha: 0.15)
              : p.surface3.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? col : p.text3,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _formatDuration(Duration(milliseconds: ms)),
              style: TextStyle(
                color: active ? p.text : p.text3.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
