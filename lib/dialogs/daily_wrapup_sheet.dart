import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/services/universal_interval_ledger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Apple HIG Daily Wrap-up & Time-Awareness Sheet.
/// Allows ending all active sessions, aggregating conscious vs unconscious time,
/// and displaying an intentional day wrap-up summary with calendar synchronization.
class DailyWrapupSheet extends StatefulWidget {
  const DailyWrapupSheet({
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

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required List<Moment> moments,
    bool isSessionOngoing = false,
    Future<void> Function()? onEndActiveSessions,
    Future<void> Function(String note)? onSaveWrapupNote,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DailyWrapupSheet(
        p: p,
        moments: moments,
        isSessionOngoing: isSessionOngoing,
        onEndActiveSessions: onEndActiveSessions,
        onSaveWrapupNote: onSaveWrapupNote,
      ),
    );
  }

  @override
  State<DailyWrapupSheet> createState() => _DailyWrapupSheetState();
}

class _DailyWrapupSheetState extends State<DailyWrapupSheet> {
  final TextEditingController _noteCtrl = TextEditingController();
  bool _isEnding = false;
  late bool _hasActiveSession;
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _hasActiveSession = widget.isSessionOngoing;
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final list = await GoalsService.instance.getGoals();
    if (mounted) {
      setState(() => _goals = list);
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

  Future<void> _handleEndAll() async {
    if (_isEnding) return;
    setState(() => _isEnding = true);
    HapticFeedback.heavyImpact();

    if (widget.onEndActiveSessions != null) {
      await widget.onEndActiveSessions!();
    }

    setState(() {
      _hasActiveSession = false;
      _isEnding = false;
    });
  }

  Future<void> _handleCompleteWrapup() async {
    HapticFeedback.mediumImpact();
    final note = _noteCtrl.text.trim();
    if (note.isNotEmpty && widget.onSaveWrapupNote != null) {
      await widget.onSaveWrapupNote!(note);
    }
    if (mounted) {
      Navigator.pop(context);
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

    // Default to at least 50% conscious if no specific categorizations yet
    final consciousPct = totalTrackedMs > 0
        ? (consciousMs / totalTrackedMs).clamp(0.0, 1.0)
        : 1.0;
    final unconsciousMs = totalTrackedMs - consciousMs;

    return AppSheet(
      p: p,
      title: 'Daily Wrap-up',
      trailingAction: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.surface2, shape: BoxShape.circle),
          child: Icon(Icons.close_rounded, size: 18, color: p.subtext),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 28 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // End Active Sessions Banner (if any timer is running)
            if (_hasActiveSession) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withAlpha(120),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.timer_off_rounded,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Timer Running',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Stop all open sessions to seal today’s records.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PressableScale(
                      onTap: _handleEndAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _isEnding ? 'Stopping...' : 'End All',
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

            // Daily Summary Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: p.surface3.withAlpha(120)),
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
                            'TOTAL TRACKED TODAY',
                            style: TextStyle(
                              color: p.subtext,
                              fontSize: 11,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(totalTrackedMs),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
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
                          color: p.accent.withAlpha(35),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${(consciousPct * 100).round()}% Conscious',
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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
                            flex: (consciousPct * 100).round(),
                            child: Container(color: p.accent),
                          ),
                          Flexible(
                            flex: ((1.0 - consciousPct) * 100).round(),
                            child: Container(color: p.surface3),
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
                            'Conscious: ${_formatDuration(consciousMs)}',
                            style: TextStyle(
                              color: p.subtext,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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
                              color: p.surface3,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Downtime: ${_formatDuration(unconsciousMs)}',
                            style: TextStyle(
                              color: p.subtext,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Active Targets & Initiatives Section
            if (_goals.where((g) => !g.isArchived).isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'ACTIVE TARGETS & INITIATIVES',
                  style: TextStyle(
                    color: p.subtext,
                    fontSize: 11,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
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
                  border: Border.all(color: p.surface3.withAlpha(120)),
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
                                    'Done',
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
                                    color: p.subtext,
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
                  'CATEGORY ALLOCATION',
                  style: TextStyle(
                    color: p.subtext,
                    fontSize: 11,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
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
                  border: Border.all(color: p.surface3.withAlpha(120)),
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
                              color: p.subtext,
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
                'CLOSING REFLECTION / GRATITUDE',
                style: TextStyle(
                  color: p.subtext,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.surface3.withAlpha(120)),
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
                      'What went well today? What will you improve tomorrow?',
                  hintStyle: TextStyle(
                    color: p.subtext.withAlpha(140),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Wrap-up Action Button
            PressableScale(
              onTap: _handleCompleteWrapup,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: p.accent.withAlpha(80),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.done_all_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Wrap Up & Seal Day',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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
