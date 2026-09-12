import 'dart:math' as math;

import 'package:flutter/cupertino.dart'
    show
        CupertinoAlertDialog,
        CupertinoDialogAction,
        CupertinoIcons,
        CupertinoTextField,
        CupertinoTheme,
        CupertinoThemeData;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class ModesCategoriesSettingsPage extends StatefulWidget {
  const ModesCategoriesSettingsPage({
    super.key,
    required this.p,
    required this.entries,
    this.onCategoriesChanged,
    this.onOpenCategory,
    this.onLearnMoreBeta,
  });

  final Palette p;
  final List<Moment> entries;
  final VoidCallback? onCategoriesChanged;
  final void Function(String category, {String? parent})? onOpenCategory;
  final VoidCallback? onLearnMoreBeta;

  @override
  State<ModesCategoriesSettingsPage> createState() =>
      _ModesCategoriesSettingsPageState();
}

class _ModesCategoriesSettingsPageState
    extends State<ModesCategoriesSettingsPage> {
  final CategoryService _categoryService = CategoryService();
  List<String> _categories = ['Work', 'Deep Focus'];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final list = await _categoryService.getCategories();
    if (mounted) {
      setState(() {
        _categories = list;
        _loading = false;
      });
    }
  }

  String _formatDuration(Duration d) {
    final totalMinutes = d.inMinutes;
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  Future<void> _showAddCategoryDialog() async {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: widget.p.name == 'light'
              ? Brightness.light
              : Brightness.dark,
          primaryColor: widget.p.accent,
        ),
        child: CupertinoAlertDialog(
          title: Text('New Mode'.localized(ctx)),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CupertinoTextField(
              controller: textController,
              autofocus: true,
              placeholder: 'Mode Name (e.g. Study, Gym)',
              placeholderStyle: TextStyle(color: widget.p.text3),
              textCapitalization: TextCapitalization.words,
              maxLength: 15,
              inputFormatters: [LengthLimitingTextInputFormatter(15)],
              style: TextStyle(color: widget.p.text),
              decoration: BoxDecoration(
                color: widget.p.name == 'light'
                    ? const Color(0xFFE5E5EA)
                    : (widget.p.name == 'amoled'
                          ? const Color(0xFF161616)
                          : widget.p.surface3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.p.border.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'.localized(ctx)),
              onPressed: () => Navigator.pop(ctx, false),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Create'.localized(ctx)),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );

    if (created == true) {
      final name = textController.text.trim();
      if (name.isNotEmpty) {
        final success = await _categoryService.addCategory(name);
        if (success) {
          HapticFeedback.mediumImpact();
          await _loadCategories();
          widget.onCategoriesChanged?.call();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final daySections = buildTimelineDaySections(widget.entries);
    final allTimelineItems = <TimelineItem>[];
    for (final sec in daySections) {
      allTimelineItems.addAll(sec.items);
    }
    final durationsMap = CategoryService.computeCategoryDurations(
      allTimelineItems,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: spacing8),

        // Hero Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: spacing16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.p.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.p.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.p.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: widget.p.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modes'.localized(context),
                      style: TextStyle(
                        color: widget.p.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Categorize life moments into dedicated modes. Tap any mode to review its history and insights.'
                          .localized(context),
                      style: TextStyle(
                        color: widget.p.text2,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing16),

        // Action: Add Category Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacing16),
          child: PressableScale(
            onTap: _showAddCategoryDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.p.accent.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.plus_circle_fill,
                    size: 18,
                    color: widget.p.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Create New Mode'.localized(context),
                    style: TextStyle(
                      color: widget.p.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: spacing16),

        // Categories List
        SettingsGroup(
          p: widget.p,
          title: 'ACTIVE & CUSTOM MODES'.localized(context),
          insetDividers: true,
          children: [
            for (final category in _categories) ...[
              _buildCategoryRow(
                category: category,
                duration: durationsMap[category] ?? Duration.zero,
              ),
            ],
          ],
        ),

        // Beta Page Note
        if (widget.onLearnMoreBeta != null) ...[
          const SizedBox(height: spacing12),
          SettingsBetaNote(p: widget.p, onLearnMore: widget.onLearnMoreBeta!),
        ],
        const SizedBox(height: spacing16),
      ],
    );
  }

  Widget _buildCategoryRow({
    required String category,
    required Duration duration,
  }) {
    final meta = getCategoryMeta(category, widget.p);
    final durStr = _formatDuration(duration);

    return SettingsRow(
      p: widget.p,
      icon: meta.icon,
      color: meta.color,
      title: category,
      status: durStr,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: widget.p.text3,
        size: 18,
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onOpenCategory?.call('Mode: $category', parent: 'Modes');
      },
    );
  }
}

/// Dedicated Settings Page for an inspected Mode / Category.
class ModeDetailSettingsPage extends StatelessWidget {
  const ModeDetailSettingsPage({
    super.key,
    required this.p,
    required this.category,
    required this.entries,
    this.onDelete,
    this.onCategoriesChanged,
  });

  final Palette p;
  final String category;
  final List<Moment> entries;
  final VoidCallback? onDelete;
  final VoidCallback? onCategoriesChanged;

  String _formatDuration(Duration d) {
    final totalMinutes = d.inMinutes;
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  Future<void> _confirmDeleteCategory(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoTheme(
        data: CupertinoThemeData(
          brightness: p.name == 'light' ? Brightness.light : Brightness.dark,
          primaryColor: p.accent,
        ),
        child: CupertinoAlertDialog(
          title: Text('Delete Mode?'.localized(ctx)),
          content: Text(
            'Are you sure you want to remove "$category"? Existing logged moments will retain their history.'
                .localized(ctx),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'.localized(ctx)),
              onPressed: () => Navigator.pop(ctx, false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Delete'.localized(ctx)),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final success = await CategoryService().deleteCategory(category);
      if (success) {
        onCategoriesChanged?.call();
        onDelete?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = getCategoryMeta(category, p);

    // Build timeline sections filtered to this category
    final allSections = buildTimelineDaySections(entries);
    final List<TimelineDaySection> filteredSections = [];

    int categoryTotalMs = 0;
    int categoryTotalLogs = 0;
    int longestSessionMs = 0;
    final Set<String> activeDays = {};

    for (final sec in allSections) {
      final matchingItems = sec.items.where((it) {
        final cat = it.category;
        return cat != null && cat.toLowerCase() == category.toLowerCase();
      }).toList();

      if (matchingItems.isNotEmpty) {
        activeDays.add(sec.dateKey);
        int dayTrackedMs = 0;
        int dayLogs = 0;
        for (final it in matchingItems) {
          if (it is TimelineSessionItem) {
            final dMs = it.duration.inMilliseconds;
            dayTrackedMs += dMs;
            categoryTotalMs += dMs;
            dayLogs += it.momentIds.length;
            categoryTotalLogs += it.momentIds.length;
            longestSessionMs = math.max(longestSessionMs, dMs);
          } else {
            const singleMs = 15 * 60 * 1000;
            dayTrackedMs += singleMs;
            categoryTotalMs += singleMs;
            dayLogs += 1;
            categoryTotalLogs += 1;
          }
        }

        filteredSections.add(
          TimelineDaySection(
            dateKey: sec.dateKey,
            date: sec.date,
            displayTitle: sec.displayTitle,
            totalTrackedDuration: Duration(milliseconds: dayTrackedMs),
            totalLogs: dayLogs,
            items: matchingItems,
          ),
        );
      }
    }

    // Compute total tracked time across all categories to determine share
    int grandTotalTrackedMs = 0;
    for (final sec in allSections) {
      grandTotalTrackedMs += sec.totalTrackedDuration.inMilliseconds;
    }
    final double focusSharePct = grandTotalTrackedMs > 0
        ? ((categoryTotalMs / grandTotalTrackedMs) * 100).clamp(0.0, 100.0)
        : 0.0;

    final avgSessionMins = categoryTotalLogs > 0
        ? (categoryTotalMs ~/ 1000 ~/ 60 ~/ categoryTotalLogs)
        : 0;

    final isDefault = CategoryService.defaultCategories.any(
      (d) => d.toLowerCase() == category.toLowerCase(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Hero Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: meta.color.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(meta.icon, color: meta.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatDuration(Duration(milliseconds: categoryTotalMs))} tracked across ${activeDays.length} days',
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3 Metric Stat Capsules
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'TOTAL FOCUS',
                  value: _formatDuration(
                    Duration(milliseconds: categoryTotalMs),
                  ),
                  icon: Icons.timer_outlined,
                  color: meta.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'SESSIONS',
                  value: '$categoryTotalLogs',
                  icon: Icons.layers_outlined,
                  color: p.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'AVG SESSION',
                  value: '${avgSessionMins}m',
                  icon: Icons.speed_rounded,
                  color: p.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Section Header: Detailed History
          Text(
            'CATEGORY TIMELINE'.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),

          if (filteredSections.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 36,
                    color: p.text3.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No moments logged in this category yet.'.localized(
                      context,
                    ),
                    style: TextStyle(color: p.text3, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            for (final sec in filteredSections) ...[
              _buildDaySectionCard(sec),
              const SizedBox(height: 10),
            ],

          const SizedBox(height: 20),

          // Bottom Insights Section
          Text(
            'CATEGORY INSIGHTS'.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                _buildInsightRow(
                  label: 'Focus Time Share',
                  value: '${focusSharePct.toStringAsFixed(1)}%',
                  detail: 'of total conscious tracked duration',
                  icon: Icons.pie_chart_outline_rounded,
                  color: meta.color,
                ),
                Divider(color: p.border.withValues(alpha: 0.4), height: 16),
                _buildInsightRow(
                  label: 'Longest Interval',
                  value: _formatDuration(
                    Duration(milliseconds: longestSessionMs),
                  ),
                  detail: 'peak uninterrupted immersion',
                  icon: Icons.trending_up_rounded,
                  color: p.accent,
                ),
                Divider(color: p.border.withValues(alpha: 0.4), height: 16),
                _buildInsightRow(
                  label: 'Active Logging Days',
                  value: '${activeDays.length}',
                  detail: 'distinct days with this focus mode',
                  icon: Icons.event_available_rounded,
                  color: p.green,
                ),
              ],
            ),
          ),

          // Dedicated Bottom Delete Button for custom modes
          if (!isDefault) ...[
            const SizedBox(height: spacing24),
            PressableScale(
              onTap: () => _confirmDeleteCategory(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: p.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.red.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.trash, size: 18, color: p.red),
                    const SizedBox(width: 8),
                    Text(
                      'Delete Mode'.localized(context),
                      style: TextStyle(
                        color: p.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: spacing24),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: p.text,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySectionCard(TimelineDaySection sec) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sec.displayTitle,
                style: TextStyle(
                  color: p.text,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  sec.formattedTrackedDuration,
                  style: TextStyle(
                    color: p.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in sec.items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: item is TimelineSessionItem ? p.green : p.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item is TimelineSessionItem) ...[
                    Text(
                      '${timeOnly(item.startTimestamp)} → ${item.endTimestamp != null ? timeOnly(item.endTimestamp!) : "Live"}',
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '[ ${_formatDuration(item.duration)} ]',
                      style: TextStyle(
                        color: p.text3,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else if (item is TimelineSingleItem) ...[
                    Text(
                      timeOnly(item.moment.timestamp),
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                  if (item.note.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: IosEmojiText(
                        item.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.text3, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required String label,
    required String value,
    required String detail,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: p.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(detail, style: TextStyle(color: p.text3, fontSize: 10.5)),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
