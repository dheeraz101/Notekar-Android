import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/utils/dashboard_metrics_service.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/life_audit_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';

/// Reusable Apple-aesthetic shareable performance & stats card for social media.
class ShareableStatsSheet extends StatefulWidget {
  const ShareableStatsSheet({
    super.key,
    required this.p,
    required this.periodLabel,
    required this.totalTracked,
    required this.intentionalityRatio,
    required this.wastedOrDrift,
    required this.streakDays,
    this.topCategory,
    this.topCategoryPct,
  });

  final Palette p;
  final String periodLabel;
  final Duration totalTracked;
  final double intentionalityRatio;
  final Duration wastedOrDrift;
  final int streakDays;
  final String? topCategory;
  final int? topCategoryPct;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    String? periodLabel,
    Duration? totalTracked,
    double? intentionalityRatio,
    Duration? wastedOrDrift,
    int? streakDays,
    String? topCategory,
    int? topCategoryPct,
    List<Moment>? entries,
    ExecutiveDashboardData? dashboardData,
    LifeAuditSummary? summary,
  }) {
    String effectivePeriod = periodLabel ?? 'Past 7 Days';
    Duration effectiveTracked = totalTracked ?? Duration.zero;
    double effectiveRatio = intentionalityRatio ?? 0.0;
    Duration effectiveWasted = wastedOrDrift ?? Duration.zero;
    int effectiveStreak = streakDays ?? 0;
    String? effectiveCat = topCategory;
    int? effectiveCatPct = topCategoryPct;

    if (dashboardData != null) {
      effectivePeriod = periodLabel ?? dashboardData.timeframe.label;
      effectiveTracked = totalTracked ?? dashboardData.totalTracked;
      effectiveRatio =
          intentionalityRatio ??
          (dashboardData.activityRingRatio * 100.0).clamp(0.0, 100.0);
      effectiveWasted = wastedOrDrift ?? dashboardData.untrackedDuration;
      effectiveStreak = streakDays ?? dashboardData.gridStats.currentStreak;
      effectiveCat =
          topCategory ??
          (dashboardData.focusBreakdown.categories.isNotEmpty
              ? dashboardData.focusBreakdown.categories.first.name
              : null);
      effectiveCatPct =
          topCategoryPct ??
          (dashboardData.focusBreakdown.categories.isNotEmpty
              ? dashboardData.focusBreakdown.categories.first.percentage
              : null);
    } else if (summary != null) {
      effectivePeriod = periodLabel ?? summary.timeframe.label;
      effectiveTracked = totalTracked ?? summary.totalTrackedDuration;
      effectiveRatio = intentionalityRatio ?? summary.intentionalityRatio;
      effectiveWasted = wastedOrDrift ?? summary.totalWastedDuration;
      effectiveStreak = streakDays ?? summary.currentStreak;
      effectiveCat =
          topCategory ??
          (summary.categoryBreakdown.isNotEmpty
              ? summary.categoryBreakdown.keys.first
              : null);
    } else if (entries != null) {
      final audit = LifeAuditService.calculate(
        entries: entries,
        timeframe: LifeAuditTimeframe.week,
      );
      effectivePeriod = periodLabel ?? 'Past 7 Days';
      effectiveTracked = totalTracked ?? audit.totalTrackedDuration;
      effectiveRatio = intentionalityRatio ?? audit.intentionalityRatio;
      effectiveWasted = wastedOrDrift ?? audit.totalWastedDuration;
      effectiveStreak = streakDays ?? audit.currentStreak;
      effectiveCat =
          topCategory ??
          (audit.categoryBreakdown.isNotEmpty
              ? audit.categoryBreakdown.keys.first
              : null);
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareableStatsSheet(
        p: p,
        periodLabel: effectivePeriod,
        totalTracked: effectiveTracked,
        intentionalityRatio: effectiveRatio,
        wastedOrDrift: effectiveWasted,
        streakDays: effectiveStreak,
        topCategory: effectiveCat,
        topCategoryPct: effectiveCatPct,
      ),
    );
  }

  @override
  State<ShareableStatsSheet> createState() => _ShareableStatsSheetState();
}

class _ShareableStatsSheetState extends State<ShareableStatsSheet> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  String _formatDuration(Duration d) {
    final mins = d.inMinutes;
    if (mins <= 0) return '0m';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  Future<void> _exportCard() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      HapticFeedback.heavyImpact();
      final profile = UserProfileService();
      final hasName = profile.name.trim().isNotEmpty;
      final userName = hasName ? profile.name.trim() : 'Explorer';
      final formattedTracked = _formatDuration(widget.totalTracked);
      final formattedWasted = _formatDuration(widget.wastedOrDrift);
      final intentionality = widget.intentionalityRatio.round();

      final shareContent =
          '⚡ $userName\'s ${widget.periodLabel} Focus Report\n'
          'Conscious Focus: $formattedTracked • $intentionality% Intentional\n'
          'Void Reclaimed: $formattedWasted • ${widget.streakDays} Day Streak\n'
          '${widget.topCategory != null ? 'Obsession: ${widget.topCategory} (${widget.topCategoryPct ?? 0}%)\n' : ''}'
          'Logged with NoteKar — Deliberate Time & Life Horizon • 100% Private, Zero Cloud.';

      await Future<void>.delayed(const Duration(milliseconds: 120));

      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData?.buffer.asUint8List();

        if (pngBytes != null) {
          try {
            await const MethodChannel(
              'notekar/files',
            ).invokeMethod<void>('shareImageBytes', {
              'title': 'Share Focus Stats',
              'fileName':
                  'notekar-stats-${widget.periodLabel.toLowerCase()}.png',
              'bytes': pngBytes,
              'text': shareContent,
            });
          } catch (_) {
            await const MethodChannel('notekar/files').invokeMethod<void>(
              'shareText',
              {'title': 'Share Focus Stats', 'text': shareContent},
            );
          }
        } else {
          await const MethodChannel('notekar/files').invokeMethod<void>(
            'shareText',
            {'title': 'Share Focus Stats', 'text': shareContent},
          );
        }
      } else {
        await const MethodChannel('notekar/files').invokeMethod<void>(
          'shareText',
          {'title': 'Share Focus Stats', 'text': shareContent},
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final profile = UserProfileService();
    final horizon = profile.calculateLifeHorizon();
    final displayName = profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'NoteKar Explorer';

    final formattedFocus = _formatDuration(widget.totalTracked);
    final formattedDrift = _formatDuration(widget.wastedOrDrift);
    final intentionality = widget.intentionalityRatio.round().clamp(0, 100);

    return AppSheet(
      p: p,
      title: 'Share Stats Card'.localized(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF0F172A), const Color(0xFF090D16)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row: User info & Timeframe Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          profile.buildAvatarWidget(p: p, size: 36),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              if (horizon.hasDob)
                                Text(
                                  'Life Clock: ${horizon.lifeClockFormatted}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: p.accent.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          widget.periodLabel.toUpperCase(),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Hero Intentionality & Focus Display
                  Text(
                    'CONSCIOUS FOCUS TIME',
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formattedFocus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                            fontFeatures: [FontFeature.tabularFigures()],
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: p.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$intentionality% INTENTIONAL',
                            style: TextStyle(
                              color: p.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3-Metric Stats Row
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DRIFT / VOID',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                formattedDrift,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 34,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STREAK',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${widget.streakDays} Days',
                                style: TextStyle(
                                  color: p.orange,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.topCategory != null) ...[
                          Container(
                            width: 1,
                            height: 34,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOP MODE',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.topCategory!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Bottom Brand Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.circle_grid_hex,
                            size: 13,
                            color: p.accent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Life Horizon Intelligence',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'NoteKar',
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Share Button
          PressableScale(
            onTap: _exportCard,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: p.accent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isExporting
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.share,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Share Stats on Social'.localized(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
