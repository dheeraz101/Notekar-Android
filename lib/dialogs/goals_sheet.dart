import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/goals_service.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Flagship Apple HIG Goals & Targets Sheet.
/// Allows setting intentional target allocations across week, month, year, or all-time,
/// tracking invested duration vs remaining deficit ("X hours to go").
class GoalsSheet extends StatelessWidget {
  const GoalsSheet({super.key, required this.p, required this.moments});

  final Palette p;
  final List<Moment> moments;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required List<Moment> moments,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GoalsSheet(p: p, moments: moments),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      p: p,
      title: 'Targets & Goals'.localized(context),
      child: SizedBox(
        width: 420,
        height: 520,
        child: GoalsContentView(p: p, moments: moments),
      ),
    );
  }
}

class GoalsContentView extends StatefulWidget {
  const GoalsContentView({
    super.key,
    required this.p,
    required this.moments,
    this.onAddGoal,
    this.onEditGoal,
    this.shrinkWrap = false,
    this.physics,
  });

  final Palette p;
  final List<Moment> moments;
  final VoidCallback? onAddGoal;
  final ValueChanged<Goal>? onEditGoal;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  State<GoalsContentView> createState() => GoalsContentViewState();
}

class GoalsContentViewState extends State<GoalsContentView> {
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGoals();
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

  void _openCreateOrEditGoalDialog([Goal? existing]) {
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
          width: 420,
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
      itemCount: _goals.length + 1,
      itemBuilder: (ctx, idx) {
        if (idx == _goals.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () => _openCreateOrEditGoalDialog(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.p.accent,
                  side: BorderSide(
                    color: widget.p.accent.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(CupertinoIcons.add, size: 15),
                label: Text(
                  'Add New Target'.localized(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }
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
          FilledButton.tonalIcon(
            onPressed: () => _openCreateOrEditGoalDialog(),
            icon: const Icon(CupertinoIcons.add, size: 16),
            label: Text('Create First Goal'.localized(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, GoalProgress progress) {
    final meta = getCategoryMeta(goal.category ?? 'Target', widget.p);
    final accentCol = goal.category != null ? meta.color : widget.p.accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.p.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: progress.isCompleted
                ? widget.p.green.withValues(alpha: 0.5)
                : widget.p.border.withValues(alpha: 0.6),
            width: progress.isCompleted ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Tags & Actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accentCol.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        goal.category != null
                            ? meta.icon
                            : CupertinoIcons.flag_fill,
                        size: 11,
                        color: accentCol,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        goal.category ??
                            (goal.mode == 'two-way' ? 'Sessions' : 'All Modes'),
                        style: TextStyle(
                          color: accentCol,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: widget.p.surface3,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    goal.timeframe.label.localized(context),
                    style: TextStyle(
                      color: widget.p.text2,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _openCreateOrEditGoalDialog(goal),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      CupertinoIcons.pencil,
                      size: 16,
                      color: widget.p.text3,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _confirmDeleteGoal(goal),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      CupertinoIcons.trash,
                      size: 16,
                      color: widget.p.red.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title & Percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      color: widget.p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${(progress.ratio * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: progress.isCompleted
                        ? widget.p.green
                        : widget.p.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.ratio,
                minHeight: 7,
                backgroundColor: widget.p.surface3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress.isCompleted ? widget.p.green : accentCol,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Metrics row: Tracked vs Deficit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.trackedFormatted} / ${progress.targetFormatted}',
                  style: TextStyle(
                    color: widget.p.text2,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: progress.isCompleted
                        ? widget.p.green.withValues(alpha: 0.15)
                        : widget.p.orange.withValues(alpha: 0.15),
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
          ],
        ),
      ),
    );
  }
}

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
  String? _category;
  String? _mode;

  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _targetHours = (widget.goal?.targetMinutes ?? 1200) ~/ 60;
    _timeframe = widget.goal?.timeframe ?? GoalTimeframe.week;
    _category = widget.goal?.category;
    _mode = widget.goal?.mode;

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
      mode: _mode,
      targetMinutes: math.max(1, _targetHours) * 60,
      timeframe: _timeframe,
      createdAt:
          widget.goal?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      isArchived: widget.goal?.isArchived ?? false,
    );

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
          TextField(
            controller: _titleController,
            autofocus: widget.goal == null,
            style: TextStyle(color: widget.p.text),
            decoration: InputDecoration(
              labelText: 'Goal Title'.localized(context),
              hintText: 'e.g. Deep Work, Reading, Fitness',
              hintStyle: TextStyle(color: widget.p.text3),
              filled: true,
              fillColor: widget.p.surface3,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.p.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.p.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.p.accent),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Target Hours Stepper & Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: $_targetHours hrs'.localized(context),
                style: TextStyle(
                  color: widget.p.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  PressableScale(
                    onTap: () {
                      if (_targetHours > 1) {
                        setState(() => _targetHours--);
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.p.surface3,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.minus,
                        size: 14,
                        color: widget.p.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PressableScale(
                    onTap: () {
                      setState(() => _targetHours++);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.p.surface3,
                        shape: BoxShape.circle,
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
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [2, 5, 10, 15, 20, 30, 40].map((hrs) {
              final selected = _targetHours == hrs;
              return ChoiceChip(
                label: Text('${hrs}h'),
                selected: selected,
                onSelected: (val) {
                  if (val) {
                    setState(() => _targetHours = hrs);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Timeframe Segmented Control
          Text(
            'Timeframe'.localized(context),
            style: TextStyle(
              color: widget.p.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: GoalTimeframe.values.map((tf) {
              final selected = _timeframe == tf;
              return ChoiceChip(
                label: Text(tf.label.localized(context)),
                selected: selected,
                onSelected: (val) {
                  if (val) {
                    setState(() => _timeframe = tf);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Category Scope
          Text(
            'Category Scope'.localized(context),
            style: TextStyle(
              color: widget.p.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: Text('All Categories'.localized(context)),
                selected: _category == null,
                onSelected: (val) {
                  if (val) setState(() => _category = null);
                },
              ),
              ..._availableCategories.map((cat) {
                final selected = _category == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (val) {
                    setState(() => _category = val ? cat : null);
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: PressableScale(
                  onTap: () {
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
