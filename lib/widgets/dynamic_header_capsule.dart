import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// Tapping smoothly expands it to reveal mode selection,
/// circadian day rhythm, and manage actions.
class DynamicHeaderCapsule extends StatefulWidget {
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
        todaySection?.totalTrackedDuration ?? Duration.zero;

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
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
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
          duration: const Duration(milliseconds: 250),
          firstCurve: Curves.easeOutCubic,
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
                  totalTodayDuration,
                  intPercent,
                  intentionalityRatio,
                  todaySection,
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
            // Duration & Category
            Flexible(
              child: Text(
                '$durLabel ${meta.name}',
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
            Icon(CupertinoIcons.chevron_down, size: 11, color: p.text3),
          ],
        ),
      ),
    );
  }

  /// Expanded Apple-grade sheet inside header
  Widget _buildExpandedCard(
    BuildContext context,
    CategoryMeta meta,
    Duration totalToday,
    int intPercent,
    double ratio,
    TimelineDaySection? section,
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
                        CupertinoIcons.chevron_up,
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
              // Do not close immediately, let them see active change
            },
            onAddCategory: widget.onAddCategory,
            onManageCategories: widget.onManageCategories,
            onLongPressCategory: widget.onLongPressCategory,
          ),

          const SizedBox(height: 12),

          // Circadian Progress Bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today: ${_formatDuration(totalToday)} tracked',
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$intPercent% Conscious',
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 4,
                        backgroundColor: p.surface3,
                        valueColor: AlwaysStoppedAnimation<Color>(p.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Day Rhythm Quick Micro-Blocks
          Row(
            children: [
              _buildMicroRhythm('Morning', morningMs, p.orange),
              const SizedBox(width: 4),
              _buildMicroRhythm('Afternoon', afternoonMs, p.accent),
              const SizedBox(width: 4),
              _buildMicroRhythm('Evening', eveningMs, const Color(0xFFAF52DE)),
              const SizedBox(width: 4),
              _buildMicroRhythm('Night', nightMs, const Color(0xFF30B0C7)),
            ],
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
}
