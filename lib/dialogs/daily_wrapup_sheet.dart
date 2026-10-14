import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/services/universal_interval_ledger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Apple HIG Dedicated Daily Wrap-up & Time-Awareness Page.
/// Allows reviewing intentional time distribution, active goals progress,
/// ending active sessions, saving closing reflections, and sealing the day's record.
class DailyWrapupPage extends StatefulWidget {
  const DailyWrapupPage({
    super.key,
    required this.p,
    required this.moments,
    this.isSessionOngoing = false,
    this.onEndActiveSessions,
    this.onSaveWrapupNote,
  });

  final Palette p;
  final List<Moment> moments;
  final bool isSessionOngoing;
  final Future<void> Function()? onEndActiveSessions;
  final Future<void> Function(String note)? onSaveWrapupNote;

  static Route<bool> route({
    required Palette p,
    required List<Moment> moments,
    bool isSessionOngoing = false,
    Future<void> Function()? onEndActiveSessions,
    Future<void> Function(String note)? onSaveWrapupNote,
  }) {
    return CupertinoPageRoute<bool>(
      builder: (_) => DailyWrapupPage(
        p: p,
        moments: moments,
        isSessionOngoing: isSessionOngoing,
        onEndActiveSessions: onEndActiveSessions,
        onSaveWrapupNote: onSaveWrapupNote,
      ),
    );
  }

  static Future<bool?> open(
    BuildContext context, {
    required Palette p,
    required List<Moment> moments,
    bool isSessionOngoing = false,
    Future<void> Function()? onEndActiveSessions,
    Future<void> Function(String note)? onSaveWrapupNote,
  }) {
    HapticFeedback.mediumImpact();
    return Navigator.of(context).push<bool>(
      route(
        p: p,
        moments: moments,
        isSessionOngoing: isSessionOngoing,
        onEndActiveSessions: onEndActiveSessions,
        onSaveWrapupNote: onSaveWrapupNote,
      ),
    );
  }

  /// Backward-compatible entrypoint replacing modal sheet with the dedicated page.
  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required List<Moment> moments,
    bool isSessionOngoing = false,
    Future<void> Function()? onEndActiveSessions,
    Future<void> Function(String note)? onSaveWrapupNote,
  }) {
    return open(
      context,
      p: p,
      moments: moments,
      isSessionOngoing: isSessionOngoing,
      onEndActiveSessions: onEndActiveSessions,
      onSaveWrapupNote: onSaveWrapupNote,
    );
  }

  @override
  State<DailyWrapupPage> createState() => _DailyWrapupPageState();
}

typedef DailyWrapupSheet = DailyWrapupPage;

class _DailyWrapupPageState extends State<DailyWrapupPage> {
  final TextEditingController _noteCtrl = TextEditingController();
  bool _isEnding = false;
  bool _isSaving = false;
  late bool _hasActiveSession;
  bool _isSealed = false;
  DateTime? _sealedAt;
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _hasActiveSession = widget.isSessionOngoing;
    _checkInitialActiveState();
    _loadGoalsAndSealStatus();
  }

  void _checkInitialActiveState() {
    final todayKey = dateKey(DateTime.now());
    final todayMoments = widget.moments
        .where((m) => m.date == todayKey)
        .toList();
    if (todayMoments.isNotEmpty && todayMoments.last.type == 'in') {
      _hasActiveSession = true;
    }
  }

  Future<void> _loadGoalsAndSealStatus() async {
    final list = await GoalsService.instance.getGoals();
    final prefs = await SharedPreferences.getInstance();
    final todayKey = dateKey(DateTime.now());
    final sealed = prefs.getBool('day_sealed_$todayKey') ?? false;
    final sealedMs = prefs.getInt('day_sealed_time_$todayKey');
    final savedNote = prefs.getString('day_seal_note_$todayKey');

    if (savedNote != null && savedNote.isNotEmpty && _noteCtrl.text.isEmpty) {
      _noteCtrl.text = savedNote;
    }

    if (mounted) {
      setState(() {
        _goals = list;
        _isSealed = sealed;
        if (sealedMs != null) {
          _sealedAt = DateTime.fromMillisecondsSinceEpoch(sealedMs);
        }
      });
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final hours = d.inHours;
    final mins = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  String _formatDateSubtitle(DateTime dt) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dayName = days[(dt.weekday - 1) % 7];
    final monthName = months[(dt.month - 1) % 12];
    return '$dayName, ${dt.day} $monthName';
  }

  Future<void> _endActiveSessionsInternal() async {
    if (widget.onEndActiveSessions != null) {
      await widget.onEndActiveSessions!();
    }
    try {
      final repo = MomentRepository();
      final all = repo.getAllMoments();
      if (all.isNotEmpty && all.last.type == 'in') {
        final now = DateTime.now();
        final outMoment = Moment(
          id: repo.getNextId(),
          timestamp: now.millisecondsSinceEpoch,
          type: 'out',
          date: dateKey(now),
          note: 'Session concluded via Daily Wrap-up',
          category: all.last.category,
        );
        await repo.saveMoment(outMoment);
      }
    } catch (_) {}
  }

  Future<void> _handleEndAll() async {
    if (_isEnding) return;
    setState(() => _isEnding = true);
    HapticFeedback.heavyImpact();

    await _endActiveSessionsInternal();

    if (mounted) {
      setState(() {
        _hasActiveSession = false;
        _isEnding = false;
      });
      showIosPillToast(
        context: context,
        p: widget.p,
        message: 'Active sessions ended'.localized(context),
        icon: Icons.timer_off_rounded,
      );
    }
  }

  Future<void> _handleCompleteWrapup() async {
    if (_isSaving) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final note = _noteCtrl.text.trim();
    final todayKey = dateKey(DateTime.now());

    // 1. End any active timer/session
    if (_hasActiveSession) {
      await _endActiveSessionsInternal();
    }

    // 2. Persist reflection note
    if (widget.onSaveWrapupNote != null) {
      await widget.onSaveWrapupNote!(note);
    } else {
      try {
        final now = DateTime.now();
        final repo = MomentRepository();
        final reflectionText = note.isNotEmpty
            ? '$note #dailywrapup'
            : 'Day Sealed & Completed #dailywrapup';
        final wrapupMoment = Moment(
          id: repo.getNextId(),
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: todayKey,
          note: reflectionText,
          category: 'Reflection',
          tags: ['#dailywrapup', '#reflection'],
        );
        await repo.saveMoment(wrapupMoment);
      } catch (_) {}
    }

    // 3. Persist Seal status to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('day_sealed_$todayKey', true);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('day_sealed_time_$todayKey', nowMs);
    if (note.isNotEmpty) {
      await prefs.setString('day_seal_note_$todayKey', note);
    }

    if (mounted) {
      setState(() {
        _isSealed = true;
        _sealedAt = DateTime.fromMillisecondsSinceEpoch(nowMs);
        _hasActiveSession = false;
        _isSaving = false;
      });

      showIosPillToast(
        context: context,
        p: widget.p,
        message: 'Day wrapped up & sealed'.localized(context),
        icon: Icons.check_circle_rounded,
      );

      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final todayKey = dateKey(DateTime.now());

    // Aggregate intervals for today
    final allIntervals = UniversalIntervalLedger.instance.computeIntervals(
      widget.moments,
    );
    final todayIntervals = allIntervals
        .where((i) => i.dateKey == todayKey)
        .toList();

    int totalTrackedMs = 0;
    int consciousMs = 0;
    final categoryTotals = <String, int>{};

    for (final interval in todayIntervals) {
      final dur = interval.durationMs;
      totalTrackedMs += dur;
      final cat = interval.category;
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + dur;

      // Conscious categories: Work, Deep Focus, Study, Health
      final lower = cat.toLowerCase();
      if (lower.contains('work') ||
          lower.contains('deep') ||
          lower.contains('focus') ||
          lower.contains('study') ||
          lower.contains('health') ||
          lower.contains('gym')) {
        consciousMs += dur;
      }
    }

    final consciousPct = totalTrackedMs > 0
        ? (consciousMs / totalTrackedMs).clamp(0.0, 1.0)
        : 1.0;
    final unconsciousMs = totalTrackedMs - consciousMs;

    return Scaffold(
      backgroundColor: p.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 6,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: p.bg,
            border: Border(
              bottom: BorderSide(
                color: p.border.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              PressableScale(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    color: p.text,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Daily Wrap-up'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      _formatDateSubtitle(DateTime.now()),
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSealed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: p.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        color: p.blue,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sealed'.localized(context),
                        style: TextStyle(
                          color: p.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active Session Alert Card
            if (_hasActiveSession) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: p.red.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(CupertinoIcons.timer, color: p.red, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Session Ongoing'.localized(context),
                            style: TextStyle(
                              color: p.red,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Conclude running sessions to finalize today\'s ledger.'
                                .localized(context),
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    PressableScale(
                      onTap: _handleEndAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: p.red,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _isEnding
                              ? 'Closing...'.localized(context)
                              : 'End Now'.localized(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Day Sealed Banner (if previously sealed)
            if (_isSealed && !_hasActiveSession) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: p.blue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        color: p.blue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day Sealed & Archived'.localized(context),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _sealedAt != null
                                ? '${'Records finalized at'.localized(context)} ${_sealedAt!.hour.toString().padLeft(2, '0')}:${_sealedAt!.minute.toString().padLeft(2, '0')}'
                                : 'All intervals and reflections locked.'
                                      .localized(context),
                            style: TextStyle(color: p.text3, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Daily Summary Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: p.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL TRACKED TODAY'.localized(context),
                            style: TextStyle(
                              color: p.text3,
                              fontSize: 10.5,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(totalTrackedMs),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: p.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${(consciousPct * 100).round()}% Conscious',
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stacked Conscious vs Downtime ratio bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          Flexible(
                            flex: (consciousPct * 100).round().clamp(1, 100),
                            child: Container(color: p.accent),
                          ),
                          Flexible(
                            flex: ((1.0 - consciousPct) * 100).round().clamp(
                              1,
                              100,
                            ),
                            child: Container(
                              color: p.surface3.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: p.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${'Conscious'.localized(context)}: ${_formatDuration(consciousMs)}',
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: p.text3,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${'Downtime'.localized(context)}: ${_formatDuration(unconsciousMs)}',
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Active Targets & Initiatives Section
            if (_goals.where((g) => !g.isArchived).isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'ACTIVE TARGETS & INITIATIVES'.localized(context),
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 10.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: _goals.where((g) => !g.isArchived).take(4).map((g) {
                    final progress = GoalsService.instance.calculateProgress(
                      g,
                      widget.moments,
                    );
                    Color goalColor = p.accent;
                    if (g.colorHex != null && g.colorHex!.isNotEmpty) {
                      try {
                        goalColor = Color(
                          int.parse(g.colorHex!.replaceFirst('#', '0xFF')),
                        );
                      } catch (_) {}
                    }
                    final isComplete = g.isCompleted || progress.isCompleted;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                g.hasMilestones ? '🚀' : '🎯',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  g.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: p.text,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isComplete)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Done'.localized(context),
                                    style: TextStyle(
                                      color: p.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              else if (g.hasMilestones)
                                Text(
                                  '${g.completedMilestonesCount}/${g.milestones.length} ms',
                                  style: TextStyle(
                                    color: p.text3,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else if (g.targetMinutes > 0)
                                Text(
                                  '${(progress.ratio * 100).round()}%',
                                  style: TextStyle(
                                    color: goalColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: isComplete
                                  ? 1.0
                                  : (g.hasMilestones
                                        ? g.milestoneProgress
                                        : progress.ratio),
                              minHeight: 5,
                              backgroundColor: p.surface3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isComplete ? p.green : goalColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Category breakdown
            if (categoryTotals.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'CATEGORY ALLOCATION'.localized(context),
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 10.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: categoryTotals.entries.map((entry) {
                    final catName = entry.key;
                    final catMs = entry.value;
                    final pct = totalTrackedMs > 0
                        ? catMs / totalTrackedMs
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              catName,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: p.surface3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  p.accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDuration(catMs),
                            style: TextStyle(
                              color: p.text3,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Daily Reflection Note
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'CLOSING REFLECTION / GRATITUDE'.localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 10.5,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.border.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _noteCtrl,
                maxLines: 3,
                minLines: 2,
                style: TextStyle(color: p.text, fontSize: 14, height: 1.35),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText:
                      'What went well today? What will you improve tomorrow?'
                          .localized(context),
                  hintStyle: TextStyle(color: p.text3, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Wrap-up Action Button
            PressableScale(
              onTap: _handleCompleteWrapup,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: p.accent.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isSaving
                    ? const CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 10,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSealed
                                ? CupertinoIcons.checkmark_seal_fill
                                : Icons.done_all_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSealed
                                ? 'Update & Re-seal Day'.localized(context)
                                : 'Wrap Up & Seal Day'.localized(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
