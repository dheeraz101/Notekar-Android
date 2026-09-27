import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/digital_wellbeing_service.dart';
import 'package:notekar/theme/app_tokens.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Card rendering Android Digital Wellbeing metrics contrasted with NoteKar's
/// intentional moments, or an opt-in card if permissions have not yet been granted.
class DigitalWellbeingCard extends StatefulWidget {
  const DigitalWellbeingCard({
    super.key,
    required this.p,
    required this.todayTrackedDuration,
    required this.todayMomentsCount,
  });

  final Palette p;
  final Duration todayTrackedDuration;
  final int todayMomentsCount;

  @override
  State<DigitalWellbeingCard> createState() => _DigitalWellbeingCardState();
}

class _DigitalWellbeingCardState extends State<DigitalWellbeingCard>
    with WidgetsBindingObserver {
  final _service = DigitalWellbeingService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permission and stats when user returns from System Settings
      _refreshStats();
    }
  }

  Future<void> _refreshStats({bool force = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _service.checkPermission();
    await _service.fetchTodayStats(forceRefresh: force);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return ValueListenableBuilder<DigitalWellbeingSnapshot>(
      valueListenable: _service.snapshotNotifier,
      builder: (context, snapshot, _) {
        if (!snapshot.hasPermission) {
          return _buildOptInCard(p);
        }
        return _buildMetricsCard(p, snapshot);
      },
    );
  }

  Widget _buildOptInCard(Palette p) {
    return Container(
      padding: NkTokens.spacing.cardPadding,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: NkTokens.radii.card,
        border: Border.all(color: p.border.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.14),
                  borderRadius: NkTokens.radii.md,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: p.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect Screen Time',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 11,
                          color: p.text2,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '100% On-Device · Zero Network Access',
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock your true Intentionality Ratio by contrasting conscious NoteKar tracked moments against device screen time. Categorizes time into Productivity, Social, and Entertainment.',
            style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PressableScale(
                  onTap: () async {
                    await _service.openUsageSettings();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: NkTokens.radii.sm,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Enable Screen Time Insights',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PressableScale(
                onTap: () => _refreshStats(force: true),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: NkTokens.radii.sm,
                    border: Border.all(
                      color: p.border.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: _isLoading
                      ? Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(p.accent),
                            ),
                          ),
                        )
                      : Icon(Icons.refresh_rounded, color: p.text2, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(Palette p, DigitalWellbeingSnapshot snapshot) {
    final intentionalRatio = snapshot.computeIntentionalityRatio(
      widget.todayTrackedDuration,
    );
    final ratioPercent = (intentionalRatio * 100).round();

    final Color ratioColor;
    if (ratioPercent >= 60) {
      ratioColor = p.green;
    } else if (ratioPercent >= 35) {
      ratioColor = p.accent;
    } else {
      ratioColor = p.red;
    }

    final hours = widget.todayTrackedDuration.inHours;
    final mins = widget.todayTrackedDuration.inMinutes.remainder(60);
    final formattedTracked = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    final mindfulPickupRatio = snapshot.computeMindfulPickupRatio(
      widget.todayMomentsCount,
    );
    final mindfulPercent = (mindfulPickupRatio * 100).round();

    return Container(
      padding: NkTokens.spacing.cardPadding,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: NkTokens.radii.card,
        border: Border.all(color: p.border.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.12),
                  borderRadius: NkTokens.radii.sm,
                ),
                child: Icon(
                  Icons.pie_chart_outline_rounded,
                  color: p.accent,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Digital Wellbeing · Reality Delta',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Device screen time vs. conscious focus',
                      style: TextStyle(color: p.text2, fontSize: 11),
                    ),
                  ],
                ),
              ),
              PressableScale(
                onTap: () => _refreshStats(force: true),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: p.surface2,
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? Center(
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation(p.accent),
                            ),
                          ),
                        )
                      : Icon(Icons.refresh_rounded, color: p.text2, size: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Comparison Block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: NkTokens.radii.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INTENTIONAL FOCUS',
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedTracked,
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ratioColor.withValues(alpha: 0.16),
                    borderRadius: NkTokens.radii.pill,
                    border: Border.all(
                      color: ratioColor.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '$ratioPercent% Intentional',
                    style: TextStyle(
                      color: ratioColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'SCREEN TIME',
                        style: TextStyle(
                          color: p.text2,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.formattedTotalScreenTime,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Mindful Pickups Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_open_rounded, size: 14, color: p.text2),
                  const SizedBox(width: 5),
                  Text(
                    '${snapshot.unlockCount} pickups',
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 14, color: p.text2),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.todayMomentsCount} moments logged',
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: NkTokens.radii.pill,
                ),
                child: Text(
                  '$mindfulPercent% conscious',
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Smart Buckets Categorization Bar
          Text(
            'SMART CATEGORY DISTRIBUTION',
            style: TextStyle(
              color: p.text2,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildCategoryDistributionBar(p, snapshot),
          const SizedBox(height: 10),
          _buildCategoryLegend(p, snapshot),

          // Top Apps of the Day (Top 3)
          if (snapshot.topApps.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'TOP APPS TODAY',
              style: TextStyle(
                color: p.text2,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            ...snapshot.topApps.take(3).map((app) => _buildTopAppRow(p, app)),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionBar(
    Palette p,
    DigitalWellbeingSnapshot snapshot,
  ) {
    final prodRatio = snapshot.getCategoryRatio('Productivity');
    final socialRatio = snapshot.getCategoryRatio('Social');
    final enterRatio = snapshot.getCategoryRatio('Entertainment');
    final sysRatio = snapshot.getCategoryRatio('System');

    final prodColor = p.accent;
    final socialColor = const Color(0xFFAB47BC); // Purple
    final enterColor = const Color(0xFFFF7043); // Coral / Orange
    final sysColor = p.text2.withValues(alpha: 0.45);

    return ClipRRect(
      borderRadius: NkTokens.radii.pill,
      child: Container(
        height: 8,
        color: p.surface2,
        child: Row(
          children: [
            if (prodRatio > 0)
              Flexible(
                flex: (prodRatio * 1000).toInt().clamp(1, 1000),
                child: Container(color: prodColor),
              ),
            if (socialRatio > 0)
              Flexible(
                flex: (socialRatio * 1000).toInt().clamp(1, 1000),
                child: Container(color: socialColor),
              ),
            if (enterRatio > 0)
              Flexible(
                flex: (enterRatio * 1000).toInt().clamp(1, 1000),
                child: Container(color: enterColor),
              ),
            if (sysRatio > 0)
              Flexible(
                flex: (sysRatio * 1000).toInt().clamp(1, 1000),
                child: Container(color: sysColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLegend(Palette p, DigitalWellbeingSnapshot snapshot) {
    final categories = [
      (
        'Productivity',
        p.accent,
        snapshot.categoryBreakdown['Productivity'] ?? Duration.zero,
      ),
      (
        'Social',
        const Color(0xFFAB47BC),
        snapshot.categoryBreakdown['Social'] ?? Duration.zero,
      ),
      (
        'Entertainment',
        const Color(0xFFFF7043),
        snapshot.categoryBreakdown['Entertainment'] ?? Duration.zero,
      ),
      (
        'System',
        p.text2.withValues(alpha: 0.45),
        snapshot.categoryBreakdown['System'] ?? Duration.zero,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: categories.map((cat) {
        final hours = cat.$3.inHours;
        final mins = cat.$3.inMinutes.remainder(60);
        final formatted = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: cat.$2, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              '${cat.$1}: $formatted',
              style: TextStyle(
                color: p.text2,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTopAppRow(Palette p, AppUsageEntry app) {
    final Color categoryColor;
    switch (app.category) {
      case 'Productivity':
        categoryColor = p.accent;
        break;
      case 'Social':
        categoryColor = const Color(0xFFAB47BC);
        break;
      case 'Entertainment':
        categoryColor = const Color(0xFFFF7043);
        break;
      default:
        categoryColor = p.text2.withValues(alpha: 0.45);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: categoryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              app.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.text,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: NkTokens.radii.pill,
            ),
            child: Text(
              app.category,
              style: TextStyle(
                color: categoryColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            app.formattedDuration,
            style: TextStyle(
              color: p.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
