import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_date_picker_sheet.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/manual_entry_dialog.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/widgets/pressable_scale.dart';

String _formatDateShort(DateTime dt) {
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
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

/// Flagship Apple HIG Goals & Targets Sheet.
/// Allows setting intentional target allocations across week, month, year, or all-time,
/// tracking invested duration vs remaining deficit ("X hours to go"),
/// with daily pacing breakdown and 1-tap direct session start.
class GoalsSheet extends StatelessWidget {
  const GoalsSheet({
    super.key,
    required this.p,
    required this.moments,
    this.activeCategory,
    this.isSessionRunning = false,
    this.onStartSession,
    this.onStopSession,
    this.onManualEntry,
  });

  final Palette p;
  final List<Moment> moments;
  final String? activeCategory;
  final bool isSessionRunning;
  final ValueChanged<Goal>? onStartSession;
  final VoidCallback? onStopSession;
  final ValueChanged<Goal>? onManualEntry;

  static Future<dynamic> show(
    BuildContext context, {
    required Palette p,
    required List<Moment> moments,
    String? activeCategory,
    bool isSessionRunning = false,
    ValueChanged<Goal>? onStartSession,
    VoidCallback? onStopSession,
    ValueChanged<Goal>? onManualEntry,
  }) {
    return showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GoalsSheet(
        p: p,
        moments: moments,
        activeCategory: activeCategory,
        isSessionRunning: isSessionRunning,
        onStartSession: onStartSession,
        onStopSession: onStopSession,
        onManualEntry: onManualEntry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentKey = GlobalKey<GoalsContentViewState>();
    return AppSheet(
      p: p,
      title: 'Targets & Goals'.localized(context),
      trailingAction: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          contentKey.currentState?.openCreateOrEditGoalDialog();
        },
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.surface3, shape: BoxShape.circle),
          child: Icon(CupertinoIcons.add, size: 18, color: p.accent),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 580,
        child: GoalsContentView(
          key: contentKey,
          p: p,
          moments: moments,
          activeCategory: activeCategory,
          isSessionRunning: isSessionRunning,
          onStartSession: onStartSession,
          onStopSession: onStopSession,
          onManualEntry: onManualEntry,
        ),
      ),
    );
  }
}

class GoalsContentView extends StatefulWidget {
  const GoalsContentView({
    super.key,
    required this.p,
    required this.moments,
    this.activeCategory,
    this.isSessionRunning = false,
    this.onAddGoal,
    this.onEditGoal,
    this.onStartSession,
    this.onStopSession,
    this.onManualEntry,
    this.shrinkWrap = false,
    this.physics,
  });

  final Palette p;
  final List<Moment> moments;
  final String? activeCategory;
  final bool isSessionRunning;
  final VoidCallback? onAddGoal;
  final ValueChanged<Goal>? onEditGoal;
  final ValueChanged<Goal>? onStartSession;
  final VoidCallback? onStopSession;
  final ValueChanged<Goal>? onManualEntry;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  State<GoalsContentView> createState() => GoalsContentViewState();
}

class GoalsContentViewState extends State<GoalsContentView>
    with SingleTickerProviderStateMixin {
  List<Goal> _goals = [];
  bool _isLoading = true;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isSessionRunning) {
      _pulseController.repeat(reverse: true);
    }
    loadGoals();
  }

  @override
  void didUpdateWidget(covariant GoalsContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSessionRunning && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isSessionRunning && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> loadGoals() async {
    final list = await GoalsService.instance.getGoals();
    if (mounted) {
      setState(() {
        _goals = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleManualEntryForGoal(Goal goal) async {
    HapticFeedback.lightImpact();
    if (widget.onManualEntry != null) {
      widget.onManualEntry!(goal);
      return;
    }

    final categories = await CategoryService().getCategories();
    if (!mounted) return;

    final result = await showModalBottomSheet<ManualEntryResult>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => ManualEntryDialog(
        p: widget.p,
        categories: categories,
        initialCategory: goal.category,
        initialGoal: goal,
      ),
    );

    if (result == null || !mounted) return;

    final repo = MomentRepository();
    await repo.ensureInitialized();
    final startMs = result.startDateTime.millisecondsSinceEpoch;

    if (result.isSession && result.endDateTime != null) {
      var endMs = result.endDateTime!.millisecondsSinceEpoch;
      if (endMs <= startMs) {
        endMs = startMs + 60000;
      }
      final endDt = DateTime.fromMillisecondsSinceEpoch(endMs);

      final inMoment = Moment(
        id: repo.getNextId(),
        timestamp: startMs,
        type: 'in',
        date: dateKey(result.startDateTime),
        note: result.note,
        tags: result.tags,
        category: result.category,
      );
      final outMoment = Moment(
        id: repo.getNextId(),
        timestamp: endMs,
        type: 'out',
        date: dateKey(endDt),
        note: '',
        tags: const [],
        category: result.category,
      );

      await repo.saveMoment(inMoment);
      await repo.saveMoment(outMoment);

      setState(() {
        widget.moments.insert(0, inMoment);
        widget.moments.insert(0, outMoment);
      });
    } else {
      final singleMoment = Moment(
        id: repo.getNextId(),
        timestamp: startMs,
        type: 'single',
        date: dateKey(result.startDateTime),
        note: result.note,
        tags: result.tags,
        category: result.category,
      );

      await repo.saveMoment(singleMoment);

      setState(() {
        widget.moments.insert(0, singleMoment);
      });
    }
  }

  void openCreateOrEditGoalDialog([Goal? existing]) {
    if (widget.onEditGoal != null && existing != null) {
      widget.onEditGoal!(existing);
      return;
    }
    if (widget.onAddGoal != null && existing == null) {
      widget.onAddGoal!();
      return;
    }

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => AppSheet(
        p: widget.p,
        title: (existing == null ? 'New Target Goal' : 'Edit Target Goal')
            .localized(context),
        child: SizedBox(
          width: 580,
          child: CreateOrEditGoalView(
            p: widget.p,
            goal: existing,
            onSave: (saved) async {
              Navigator.pop(ctx);
              await GoalsService.instance.saveGoal(saved);
              await loadGoals();
            },
            onCancel: () => Navigator.pop(ctx),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteGoal(Goal goal) {
    HapticFeedback.lightImpact();
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Delete Goal?'.localized(context)),
        content: Text(
          'Are you sure you want to delete "${goal.title}"?'.localized(context),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.localized(context)),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await GoalsService.instance.deleteGoal(goal.id);
              await loadGoals();
            },
            child: Text('Delete'.localized(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_goals.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _goals.length,
      itemBuilder: (ctx, idx) {
        final goal = _goals[idx];
        final progress = GoalsService.instance.calculateProgress(
          goal,
          widget.moments,
        );
        return _buildGoalCard(goal, progress);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.flag_circle,
            size: 54,
            color: widget.p.text3.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          Text(
            'No Targets Defined'.localized(context),
            style: TextStyle(
              color: widget.p.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Set intentional allocation goals across weeks, months or years.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: widget.p.text3, fontSize: 13),
            ),
          ),
          const SizedBox(height: 18),
          PressableScale(
            onTap: () {
              HapticFeedback.lightImpact();
              openCreateOrEditGoalDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: widget.p.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.add, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Create First Goal'.localized(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, GoalProgress progress) {
    final meta = getCategoryMeta(goal.category ?? 'Target', widget.p);
    final accentCol = goal.category != null ? meta.color : widget.p.accent;
    final isActiveGoal =
        widget.isSessionRunning &&
        (goal.category == widget.activeCategory ||
            (goal.category == null && widget.activeCategory == 'All'));

    Widget cardBody = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Category Badge, Timeframe / Due Date, and Prominent Action Buttons
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: accentCol.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      goal.category != null
                          ? meta.icon
                          : CupertinoIcons.flag_fill,
                      size: 12,
                      color: accentCol,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      goal.category ?? 'All Categories',
                      style: TextStyle(
                        color: accentCol,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.p.surface3,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goal.timeframe == GoalTimeframe.custom &&
                          goal.targetDate != null
                      ? 'Due ${_formatDateShort(DateTime.fromMillisecondsSinceEpoch(goal.targetDate!))}'
                      : goal.timeframe.label.localized(context),
                  style: TextStyle(
                    color: widget.p.text2,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Icon-only Edit Action Button (38x38)
              Tooltip(
                message: 'Edit Goal'.localized(context),
                child: PressableScale(
                  onTap: () => openCreateOrEditGoalDialog(goal),
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.p.surface3,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.p.border.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.square_pencil,
                      size: 16,
                      color: widget.p.text2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Icon-only Delete Action Button (38x38 with red tint)
              Tooltip(
                message: 'Delete Goal'.localized(context),
                child: PressableScale(
                  onTap: () => _confirmDeleteGoal(goal),
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.p.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.p.red.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.trash,
                      size: 16,
                      color: widget.p.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Completion Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    color: widget.p.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (progress.isCompleted ? widget.p.green : accentCol)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(progress.ratio * 100).toInt()}%',
                  style: TextStyle(
                    color: progress.isCompleted ? widget.p.green : accentCol,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Continuous Gauge Track
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: widget.p.surface3,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.ratio.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: progress.isCompleted
                          ? [widget.p.green, widget.p.green]
                          : [accentCol, accentCol.withValues(alpha: 0.85)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tracked vs Target metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.clock, size: 13, color: widget.p.text3),
                  const SizedBox(width: 5),
                  Text(
                    '${progress.trackedFormatted} of ${progress.targetFormatted}',
                    style: TextStyle(
                      color: widget.p.text2,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: progress.isCompleted
                      ? widget.p.green.withValues(alpha: 0.14)
                      : widget.p.orange.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  progress.isCompleted
                      ? 'Goal Met 🎉'.localized(context)
                      : '${progress.remainingFormatted} to go'.localized(
                          context,
                        ),
                  style: TextStyle(
                    color: progress.isCompleted
                        ? widget.p.green
                        : widget.p.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Detailed Daily Investment Callout Block
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (progress.isCompleted ? widget.p.green : widget.p.orange)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (progress.isCompleted ? widget.p.green : widget.p.orange)
                    .withValues(alpha: 0.28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      progress.isCompleted
                          ? CupertinoIcons.checkmark_seal_fill
                          : CupertinoIcons.flame_fill,
                      size: 14,
                      color: progress.isCompleted
                          ? widget.p.green
                          : widget.p.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      progress.isCompleted
                          ? 'Target Achieved!'.localized(context)
                          : '${progress.dailyPaceFormatted} / day needed'
                                .localized(context),
                      style: TextStyle(
                        color: progress.isCompleted
                            ? widget.p.green
                            : widget.p.orange,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${progress.daysRemainingInTimeframe}d left',
                      style: TextStyle(
                        color: widget.p.text2,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (!progress.isCompleted) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Invest ${progress.dailyPaceFormatted} daily over the next ${progress.daysRemainingInTimeframe} days to achieve your target on schedule.',
                    style: TextStyle(
                      color: widget.p.text2,
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: [Stop/Start Session] + [+ Manual Entry]
          Row(
            children: [
              Expanded(
                child: isActiveGoal
                    ? PressableScale(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          if (widget.onStopSession != null) {
                            widget.onStopSession!();
                          } else {
                            Navigator.of(
                              context,
                            ).pop({'action': 'stop_goal_session'});
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: widget.p.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.p.red.withValues(alpha: 0.4),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.stop_fill,
                                size: 13,
                                color: widget.p.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Stop Session (${goal.category ?? 'Active'})'
                                    .localized(context),
                                style: TextStyle(
                                  color: widget.p.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : PressableScale(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          if (widget.onStartSession != null) {
                            widget.onStartSession!(goal);
                          } else {
                            Navigator.of(context).pop({
                              'action': 'start_goal_session',
                              'category': goal.category,
                              'mode': goal.mode ?? 'two-way',
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: accentCol.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentCol.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.play_arrow_solid,
                                size: 13,
                                color: accentCol,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Start ${goal.category ?? 'Session'}'.localized(
                                  context,
                                ),
                                style: TextStyle(
                                  color: accentCol,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              PressableScale(
                onTap: () => _handleManualEntryForGoal(goal),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: widget.p.surface3,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.p.border.withValues(alpha: 0.6),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.plus_circle_fill,
                        size: 13,
                        color: widget.p.accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Manual Entry'.localized(context),
                        style: TextStyle(
                          color: widget.p.text,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: isActiveGoal
          ? AnimatedBuilder(
              animation: _pulseController,
              builder: (ctx, child) {
                final pulse = _pulseController.value;
                final glowColor = accentCol.withValues(
                  alpha: 0.4 + 0.4 * pulse,
                );
                return Container(
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      accentCol.withValues(alpha: 0.06),
                      widget.p.surface2,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: glowColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: accentCol.withValues(alpha: 0.15 * pulse),
                        blurRadius: 12 * pulse + 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: cardBody,
            )
          : Container(
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  accentCol.withValues(alpha: 0.04),
                  widget.p.surface2,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: progress.isCompleted
                      ? widget.p.green.withValues(alpha: 0.5)
                      : accentCol.withValues(alpha: 0.35),
                  width: progress.isCompleted ? 1.4 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: cardBody,
            ),
    );
  }
}

/// Apple HIG Grouped Inset Form for Creating or Editing Goals.
class CreateOrEditGoalView extends StatefulWidget {
  const CreateOrEditGoalView({
    super.key,
    required this.p,
    this.goal,
    required this.onSave,
    this.onCancel,
  });

  final Palette p;
  final Goal? goal;
  final ValueChanged<Goal> onSave;
  final VoidCallback? onCancel;

  @override
  State<CreateOrEditGoalView> createState() => _CreateOrEditGoalViewState();
}

class _CreateOrEditGoalViewState extends State<CreateOrEditGoalView> {
  late final TextEditingController _titleController;
  late int _targetHours;
  late GoalTimeframe _timeframe;
  int? _targetDate;
  String? _category;

  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _targetHours = (widget.goal?.targetMinutes ?? 1200) ~/ 60;
    _timeframe = widget.goal?.timeframe ?? GoalTimeframe.week;
    _targetDate = widget.goal?.targetDate;
    _category = widget.goal?.category;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryService().getCategories();
    if (mounted) {
      setState(() {
        _availableCategories = cats;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final id =
        widget.goal?.id ?? 'goal_${DateTime.now().millisecondsSinceEpoch}';
    final saved = Goal(
      id: id,
      title: title,
      category: _category,
      mode: 'two-way',
      targetMinutes: math.max(1, _targetHours) * 60,
      timeframe: _timeframe,
      targetDate: _timeframe == GoalTimeframe.custom ? _targetDate : null,
      createdAt:
          widget.goal?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      isArchived: widget.goal?.isArchived ?? false,
    );

    HapticFeedback.mediumImpact();
    widget.onSave(saved);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Title Input (Apple HIG Inset Grouped)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.p.surface3,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.p.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal Title'.localized(context).toUpperCase(),
                  style: TextStyle(
                    color: widget.p.text3,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                CupertinoTextField(
                  controller: _titleController,
                  maxLength: 9,
                  inputFormatters: [LengthLimitingTextInputFormatter(9)],
                  autofocus: widget.goal == null,
                  padding: EdgeInsets.zero,
                  decoration: null,
                  cursorColor: widget.p.accent,
                  style: TextStyle(
                    color: widget.p.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  placeholder: 'e.g. Deep Work, Gym, Study',
                  placeholderStyle: TextStyle(
                    color: widget.p.text3.withValues(alpha: 0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Max 9 characters for widget and pill fit'.localized(context),
                  style: TextStyle(
                    color: widget.p.text3.withValues(alpha: 0.8),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Target Hours Stepper & Apple Presets
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.p.surface3,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.p.border.withValues(alpha: 0.6)),
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
                          '$_targetHours hrs'.localized(context),
                          style: TextStyle(
                            color: widget.p.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          'Target Allocation'.localized(context),
                          style: TextStyle(
                            color: widget.p.text3,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Apple Stepper
                    Container(
                      decoration: BoxDecoration(
                        color: widget.p.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.p.border.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PressableScale(
                            onTap: () {
                              if (_targetHours > 1) {
                                HapticFeedback.lightImpact();
                                setState(() => _targetHours--);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              child: Icon(
                                CupertinoIcons.minus,
                                size: 14,
                                color: _targetHours > 1
                                    ? widget.p.text
                                    : widget.p.text3.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 16,
                            color: widget.p.border.withValues(alpha: 0.6),
                          ),
                          PressableScale(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _targetHours++);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              child: Icon(
                                CupertinoIcons.plus,
                                size: 14,
                                color: widget.p.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Apple preset pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [2, 5, 10, 15, 20, 30, 40].map((hrs) {
                      final selected = _targetHours == hrs;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: PressableScale(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _targetHours = hrs);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? widget.p.accent
                                  : widget.p.surface2,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? widget.p.accent
                                    : widget.p.border.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              '${hrs}h',
                              style: TextStyle(
                                color: selected ? Colors.white : widget.p.text,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Timeframe (Apple HIG Sliding Segmented Control)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TIMEFRAME'.localized(context),
                style: TextStyle(
                  color: widget.p.text3,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.p.surface3,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: CupertinoSlidingSegmentedControl<GoalTimeframe>(
                  backgroundColor: Colors.transparent,
                  thumbColor: widget.p.surface2,
                  groupValue: _timeframe,
                  children: {
                    for (final tf in GoalTimeframe.values)
                      tf: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Text(
                          tf.label.localized(context),
                          style: TextStyle(
                            color: _timeframe == tf
                                ? widget.p.text
                                : widget.p.text2,
                            fontSize: 11,
                            fontWeight: _timeframe == tf
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                  },
                  onValueChanged: (val) {
                    if (val != null) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _timeframe = val;
                        if (val == GoalTimeframe.custom &&
                            _targetDate == null) {
                          _targetDate = DateTime.now()
                              .add(const Duration(days: 14))
                              .millisecondsSinceEpoch;
                        }
                      });
                    }
                  },
                ),
              ),
              if (_timeframe == GoalTimeframe.custom) ...[
                const SizedBox(height: 10),
                PressableScale(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await AppDatePickerSheet.show(
                      context,
                      p: widget.p,
                      title: 'Target Deadline'.localized(context),
                      initialDateTime: _targetDate != null
                          ? DateTime.fromMillisecondsSinceEpoch(_targetDate!)
                          : now.add(const Duration(days: 14)),
                      minimumDate: now.add(const Duration(days: 1)),
                    );
                    if (picked != null) {
                      setState(
                        () => _targetDate = picked.millisecondsSinceEpoch,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: widget.p.surface3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.p.accent.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.calendar,
                              size: 16,
                              color: widget.p.accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Target Deadline'.localized(context),
                              style: TextStyle(
                                color: widget.p.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              _targetDate != null
                                  ? _formatDateShort(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        _targetDate!,
                                      ),
                                    )
                                  : 'Choose Date'.localized(context),
                              style: TextStyle(
                                color: widget.p.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 13,
                              color: widget.p.accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // 4. Category Scope (Apple HIG Pills)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CATEGORY SCOPE'.localized(context),
                style: TextStyle(
                  color: widget.p.text3,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _category = null);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _category == null
                            ? widget.p.accent
                            : widget.p.surface3,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _category == null
                              ? widget.p.accent
                              : widget.p.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.circle_grid_hex,
                            size: 13,
                            color: _category == null
                                ? Colors.white
                                : widget.p.text2,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'All Categories'.localized(context),
                            style: TextStyle(
                              color: _category == null
                                  ? Colors.white
                                  : widget.p.text,
                              fontSize: 12,
                              fontWeight: _category == null
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ..._availableCategories.map((cat) {
                    final isSelected = _category == cat;
                    final meta = getCategoryMeta(cat, widget.p);
                    return PressableScale(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _category = isSelected ? null : cat);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? meta.color : widget.p.surface3,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? meta.color
                                : widget.p.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              meta.icon,
                              size: 12,
                              color: isSelected ? Colors.white : meta.color,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              cat,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : widget.p.text,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 6. Action Buttons
          Row(
            children: [
              Expanded(
                child: PressableScale(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onCancel?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.p.surface3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.p.border.withValues(alpha: 0.6),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel'.localized(context),
                      style: TextStyle(
                        color: widget.p.text2,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PressableScale(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.p.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Save Goal'.localized(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
