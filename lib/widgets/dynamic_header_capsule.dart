import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/goal.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/home_category_pills.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/zen_day_gauge.dart';

/// An Apple Dynamic Island-inspired dynamic header capsule.
///
/// In resting state, it renders as a whisper-thin 32px pill:
/// `[ 🟢 3h 12m Deep Focus • 78% Intentional ]`.
///
/// Tapping smoothly expands it into a card containing today's
/// momentum metrics, streak shields, category modes, and circadian rhythm.
class DynamicHeaderCapsule extends StatefulWidget {
  /// Apple Dynamic Island spring curve (stiffness: 300, damping: 28)
  static const Curve appleSpringCurve = Cubic(0.2, 0.9, 0.3, 1.0);

  const DynamicHeaderCapsule({
    super.key,
    required this.p,
    required this.entries,
    required this.categories,
    required this.activeCategory,
    required this.onSelectCategory,
    required this.onAddCategory,
    this.onManageCategories,
    this.onLongPressCategory,
    this.blur = false,
    this.isExpanded = false,
    this.onExpansionChanged,
    this.mode = 'two-way',
    this.onModeChanged,
    this.trackedDuration,
    this.momentsCount,
    this.currentStreak = 0,
    this.bankedGraceDays = 0,
    this.isSessionOngoing = false,
    this.onOpenIntelligenceHub,
    this.goals,
    this.activeGoal,
    this.onSelectGoal,
  });

  final Palette p;
  final List<Moment> entries;
  final List<String> categories;
  final String activeCategory;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onAddCategory;
  final VoidCallback? onManageCategories;
  final void Function(String category)? onLongPressCategory;
  final bool blur;
  final bool isExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final String mode;
  final ValueChanged<String>? onModeChanged;
  final Duration? trackedDuration;
  final int? momentsCount;
  final int currentStreak;
  final int bankedGraceDays;
  final bool isSessionOngoing;
  final VoidCallback? onOpenIntelligenceHub;
  final List<Goal>? goals;
  final Goal? activeGoal;
  final ValueChanged<Goal?>? onSelectGoal;

  @override
  State<DynamicHeaderCapsule> createState() => _DynamicHeaderCapsuleState();
}

class _DynamicHeaderCapsuleState extends State<DynamicHeaderCapsule>
    with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isExpanded;
  }

  @override
  void didUpdateWidget(covariant DynamicHeaderCapsule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      _expanded = widget.isExpanded;
    }
  }

  void _toggleExpanded() {
    HapticFeedback.selectionClick();
    final next = !_expanded;
    setState(() => _expanded = next);
    widget.onExpansionChanged?.call(next);
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
    final p = widget.p;
    final today = dateKey(DateTime.now());
    final todayMoments = widget.entries.where((e) => e.date == today).toList();

    // Calculate today's duration in active category vs total
    final sections = buildTimelineDaySections(todayMoments);
    final todaySection = sections.isNotEmpty ? sections.first : null;
    final totalTodayDuration =
        widget.trackedDuration ??
        (todaySection?.totalTrackedDuration ?? Duration.zero);
    final totalMomentsCount = widget.momentsCount ?? todayMoments.length;

    // Filtered duration for active category
    Duration activeCatDuration = totalTodayDuration;
    if (widget.activeCategory != 'All' &&
        widget.activeCategory.trim().isNotEmpty) {
      final catDurations = CategoryService.computeCategoryDurations(
        todaySection?.items ?? [],
      );
      activeCatDuration = catDurations[widget.activeCategory] ?? Duration.zero;
    }

    // Conscious ratio (10h baseline)
    const consciousWindow = Duration(hours: 10);
    final intentionalityRatio = consciousWindow.inMilliseconds > 0
        ? (totalTodayDuration.inMilliseconds / consciousWindow.inMilliseconds)
              .clamp(0.0, 1.0)
        : 0.0;
    final intPercent = (intentionalityRatio * 100).toInt();

    // Active category meta
    final isAll =
        widget.activeCategory == 'All' || widget.activeCategory.trim().isEmpty;
    final meta = isAll
        ? CategoryMeta(
            name: 'All',
            icon: Icons.all_inclusive_rounded,
            color: p.accent,
          )
        : getCategoryMeta(widget.activeCategory, p);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: DynamicHeaderCapsule.appleSpringCurve,
      width: _expanded ? double.infinity : null,
      constraints: BoxConstraints(maxWidth: _expanded ? 440 : 340),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.surface2.withValues(alpha: widget.blur ? 0.78 : 0.94),
        borderRadius: BorderRadius.circular(_expanded ? 24 : 999),
        border: Border.all(
          color: p.border.withValues(alpha: _expanded ? 0.35 : 0.20),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _expanded ? 0.16 : 0.08),
            blurRadius: _expanded ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_expanded ? 24 : 999),
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          firstCurve: DynamicHeaderCapsule.appleSpringCurve,
          secondCurve: Curves.easeInCubic,
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: !_expanded
              ? _buildRestingCapsule(
                  context,
                  meta,
                  activeCatDuration,
                  intPercent,
                  intentionalityRatio,
                )
              : const SizedBox.shrink(),
          secondChild: _expanded
              ? _buildExpandedCard(
                  context,
                  meta,
                  isAll ? totalTodayDuration : activeCatDuration,
                  intPercent,
                  intentionalityRatio,
                  todaySection,
                  isAll
                      ? totalMomentsCount
                      : todayMoments
                            .where((m) => m.category == widget.activeCategory)
                            .length,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// Compact 32-34px resting pill
  Widget _buildRestingCapsule(
    BuildContext context,
    CategoryMeta meta,
    Duration duration,
    int intPercent,
    double ratio,
  ) {
    final p = widget.p;
    final durLabel = _formatDuration(duration);

    return PressableScale(
      onTap: _toggleExpanded,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode Dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: meta.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: meta.color.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            // Duration & Category (or Active Goal if selected)
            Flexible(
              child: Text(
                widget.activeGoal != null
                    ? '$durLabel 🎯 ${widget.activeGoal!.title}'
                    : '$durLabel ${meta.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '•',
                style: TextStyle(
                  color: p.text3.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ),
            // Intentionality Badge
            ZenDayRing(p: p, progress: ratio, size: 10),
            const SizedBox(width: 5),
            Text(
              '$intPercent% Intentional',
              style: TextStyle(
                color: p.text2,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 11, color: p.text3),
          ],
        ),
      ),
    );
  }

  /// Expanded Apple-grade sheet inside header
  Widget _buildExpandedCard(
    BuildContext context,
    CategoryMeta meta,
    Duration displayDuration,
    int intPercent,
    double ratio,
    TimelineDaySection? section,
    int momentsCount,
  ) {
    final p = widget.p;

    // Temporal groups for circadian bar
    int morningMs = 0;
    int afternoonMs = 0;
    int eveningMs = 0;
    int nightMs = 0;

    if (section != null) {
      for (final it in section.items) {
        final dt = DateTime.fromMillisecondsSinceEpoch(it.primaryTimestamp);
        final hour = dt.hour;
        final dur = switch (it) {
          TimelineSessionItem s => s.duration.inMilliseconds,
          TimelineSingleItem _ => 15 * 60 * 1000,
          TimelineGapItem _ => 0,
        };
        if (hour >= 6 && hour < 12) {
          morningMs += dur;
        } else if (hour >= 12 && hour < 17) {
          afternoonMs += dur;
        } else if (hour >= 17 && hour < 21) {
          eveningMs += dur;
        } else {
          nightMs += dur;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: meta.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: meta.color.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'MODES & RHYTHM'.localized(context),
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onManageCategories != null)
                    PressableScale(
                      onTap: () {
                        _toggleExpanded();
                        widget.onManageCategories!();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          'Manage'.localized(context),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  PressableScale(
                    onTap: _toggleExpanded,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: p.surface3,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 13,
                        color: p.text2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Category Selector Pills
          HomeCategoryPills(
            p: p,
            categories: widget.categories,
            activeCategory: widget.activeCategory,
            onSelectCategory: (cat) {
              widget.onSelectCategory(cat);
            },
            onAddCategory: widget.onAddCategory,
            onManageCategories: widget.onManageCategories,
            onLongPressCategory: widget.onLongPressCategory,
          ),

          if (widget.goals != null && widget.goals!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.flag_rounded, size: 11, color: p.accent),
                const SizedBox(width: 5),
                Text(
                  'TARGET GOAL'.localized(context),
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGoalChip(
                    context,
                    title: 'None'.localized(context),
                    isSelected: widget.activeGoal == null,
                    onTap: () => widget.onSelectGoal?.call(null),
                  ),
                  for (final g in widget.goals!) ...[
                    const SizedBox(width: 6),
                    _buildGoalChip(
                      context,
                      title: '🎯 ${g.title}',
                      isSelected: widget.activeGoal?.id == g.id,
                      onTap: () => widget.onSelectGoal?.call(g),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Unified Minimal Momentum & Conscious Card
          PressableScale(
            onTap: () {
              _toggleExpanded();
              widget.onOpenIntelligenceHub?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: p.surface3.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSessionOngoing
                      ? p.green.withValues(alpha: 0.5)
                      : p.border.withValues(alpha: 0.4),
                  width: widget.isSessionOngoing ? 1.2 : 0.8,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Duration, Active Category & Live status, Conscious % & Streak
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Live Duration & Category Tag
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.isSessionOngoing)
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: p.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: p.green.withValues(alpha: 0.6),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              _formatDuration(displayDuration),
                              style: TextStyle(
                                color: p.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            Text(
                              ' tracked',
                              style: TextStyle(
                                color: p.text2,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.activeCategory != 'All' &&
                                widget.activeCategory.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: meta.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.activeCategory,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: meta.color,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Right: Conscious %, Streak & Chevron
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.currentStreak > 0) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 11,
                                  color: p.orange,
                                ),
                                const SizedBox(width: 2.5),
                                Text(
                                  '${widget.currentStreak}d',
                                  style: TextStyle(
                                    color: p.orange,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (widget.bankedGraceDays > 0) ...[
                              const SizedBox(width: 5),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.security_rounded,
                                    size: 10,
                                    color: p.accent,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${widget.bankedGraceDays}',
                                    style: TextStyle(
                                      color: p.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(width: 6),
                          ],
                          ZenDayRing(p: p, progress: ratio, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            '$intPercent% Conscious',
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 10,
                            color: p.text3.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // Row 2: Circadian Intentionality Progress Track
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 4,
                      backgroundColor: p.surface2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isSessionOngoing ? p.green : p.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),

                  // Row 3: Day Rhythm Quick Micro-Blocks
                  Row(
                    children: [
                      _buildMicroRhythm('Morning', morningMs, p.orange),
                      const SizedBox(width: 4),
                      _buildMicroRhythm('Afternoon', afternoonMs, p.accent),
                      const SizedBox(width: 4),
                      _buildMicroRhythm(
                        'Evening',
                        eveningMs,
                        const Color(0xFFAF52DE),
                      ),
                      const SizedBox(width: 4),
                      _buildMicroRhythm(
                        'Night',
                        nightMs,
                        const Color(0xFF30B0C7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroRhythm(String label, int ms, Color col) {
    final p = widget.p;
    final active = ms > 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: active
              ? col.withValues(alpha: 0.15)
              : p.surface3.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label[0],
            style: TextStyle(
              color: active ? col : p.text3.withValues(alpha: 0.5),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalChip(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final p = widget.p;
    return PressableScale(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? p.accent.withValues(alpha: 0.18) : p.surface3,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? p.accent.withValues(alpha: 0.5)
                : p.border.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? p.accent : p.text2,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
