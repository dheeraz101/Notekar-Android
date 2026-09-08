import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/life_audit_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class LifeAuditPage extends StatefulWidget {
  const LifeAuditPage({
    super.key,
    required this.p,
    required this.entries,
    required this.sleepHours,
    required this.essentialsHours,
    required this.onSleepHoursChanged,
    required this.onEssentialsHoursChanged,
    this.onLearnMoreBeta,
  });

  final Palette p;
  final List<Moment> entries;
  final double sleepHours;
  final double essentialsHours;
  final ValueChanged<double> onSleepHoursChanged;
  final ValueChanged<double> onEssentialsHoursChanged;
  final VoidCallback? onLearnMoreBeta;

  @override
  State<LifeAuditPage> createState() => _LifeAuditPageState();
}

class _LifeAuditPageState extends State<LifeAuditPage> {
  LifeAuditTimeframe _timeframe = LifeAuditTimeframe.week;
  bool _showAllDays = false;

  Palette get p => widget.p;

  @override
  Widget build(BuildContext context) {
    final summary = LifeAuditService.calculate(
      entries: widget.entries,
      timeframe: _timeframe,
      sleepHours: widget.sleepHours,
      essentialsHours: widget.essentialsHours,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: spacing8),
        SettingsPageDescription(
          p: p,
          text:
              'Life Audit ledger measuring the cost of unaccounted time. Un-tracked hours within your daily conscious window are computed as lost mortal void.'
                  .localized(context),
        ),
        const SizedBox(height: 12),

        // 1. Interactive 24-Hour Day Allocation & Horizon Bar
        _build24HourHorizonCard(summary),
        const SizedBox(height: 16),

        // 2. Timeframe Selector (Today, Week, Month, 6 Weeks, 6 Months, Year)
        _buildTimeframeSelector(),
        const SizedBox(height: 16),

        // 3. The Brutal Reality Hero Card ("Wild Nature")
        _buildBrutalRealityCard(summary),
        const SizedBox(height: 16),

        // 4. Day-by-Day Historical Ledger
        _buildDayByDayLedger(summary),
        const SizedBox(height: 16),

        // 5. Stoic Philosophical Colophon
        _buildStoicColophonCard(),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _build24HourHorizonCard(LifeAuditSummary summary) {
    final sleep = summary.sleepHours;
    final essentials = summary.essentialsHours;
    final conscious = summary.consciousHoursPerDay;

    // Today's tracked hours
    final todayRecord = summary.dailyRecords.firstWhere(
      (r) => r.isToday,
      orElse: () => summary.dailyRecords.first,
    );
    final trackedTodayHours =
        todayRecord.trackedDuration.inMilliseconds / (3600.0 * 1000.0);
    final activeToday = trackedTodayHours.clamp(0.0, conscious);
    final voidToday = (conscious - activeToday).clamp(0.0, conscious);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(28),
        border: p.name == 'amoled'
            ? Border.all(color: p.border.withValues(alpha: 0.5), width: 0.8)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.accent.withValues(alpha: 0.14),
                ),
                child: Icon(
                  CupertinoIcons.circle_grid_hex,
                  size: 18,
                  color: p.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '24-Hour Daily Partition'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${'Conscious Window'.localized(context)}: ${conscious.toStringAsFixed(1)}h / ${'day'.localized(context)}',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 24-Hour Horizon Segmented Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  // Sleep
                  Expanded(
                    flex: (sleep * 10).round(),
                    child: Container(color: Colors.blueGrey.shade700),
                  ),
                  const SizedBox(width: 1.5),
                  // Essentials
                  Expanded(
                    flex: (essentials * 10).round(),
                    child: Container(color: Colors.amber.shade700),
                  ),
                  const SizedBox(width: 1.5),
                  // Conscious Focus
                  if (activeToday > 0) ...[
                    Expanded(
                      flex: (activeToday * 10).round(),
                      child: Container(color: p.green),
                    ),
                    const SizedBox(width: 1.5),
                  ],
                  // Conscious Void
                  Expanded(
                    flex: (voidToday * 10).round(),
                    child: Container(color: p.red),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Horizon Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendPill(
                color: Colors.blueGrey.shade700,
                label:
                    '${'Sleep'.localized(context)} (${sleep.toStringAsFixed(1)}h)',
              ),
              _buildLegendPill(
                color: Colors.amber.shade700,
                label:
                    '${'Logistics'.localized(context)} (${essentials.toStringAsFixed(1)}h)',
              ),
              _buildLegendPill(
                color: p.green,
                label:
                    '${'Focus'.localized(context)} (${todayRecord.formattedTracked})',
              ),
              _buildLegendPill(
                color: p.red,
                label:
                    '${'Void'.localized(context)} (${todayRecord.formattedWasted})',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: p.border.withValues(alpha: 0.4)),
          const SizedBox(height: 14),

          // Sleep Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sleep & Rest'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.sleepHours.toStringAsFixed(1)} ${'Hours'.localized(context)}',
                style: TextStyle(
                  color: p.text2,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.blueGrey.shade600,
              inactiveTrackColor: p.surface3,
              thumbColor: Colors.blueGrey.shade300,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: widget.sleepHours,
              min: 4.0,
              max: 12.0,
              divisions: 16,
              onChanged: (val) {
                NotekarHaptics.selection('soft');
                widget.onSleepHoursChanged(val);
              },
            ),
          ),

          // Essentials Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Food, Commute & Logistics'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.essentialsHours.toStringAsFixed(1)} ${'Hours'.localized(context)}',
                style: TextStyle(
                  color: p.text2,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.amber.shade700,
              inactiveTrackColor: p.surface3,
              thumbColor: Colors.amber.shade400,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: widget.essentialsHours,
              min: 1.0,
              max: 8.0,
              divisions: 14,
              onChanged: (val) {
                NotekarHaptics.selection('soft');
                widget.onEssentialsHoursChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: p.text2,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: LifeAuditTimeframe.values.map((tf) {
          final isSelected = _timeframe == tf;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PressableScale(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _timeframe = tf);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? p.accent : p.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? p.accent
                        : p.border.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  tf.label.localized(context),
                  style: TextStyle(
                    color: isSelected ? Colors.white : p.text,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBrutalRealityCard(LifeAuditSummary summary) {
    final wasted = summary.formattedTotalWasted;
    final wakingLost = summary.wakingDaysLostText;
    final celestialLost = summary.celestialDaysLostText;
    final ratio = summary.intentionalityRatio;
    final voidRatio = summary.voidRatio;

    final isSevere = ratio < 40.0;
    final isGood = ratio >= 70.0;

    final headlineVerdict = isGood
        ? 'Disciplined Presence'
        : isSevere
        ? 'Critical Life Void'
        : 'Substantial Mortal Drift';

    final verdictQuote = isGood
        ? 'You are commanding your conscious hours with intention and discipline.'
        : isSevere
        ? 'Over ${voidRatio.toStringAsFixed(0)}% of your waking existence dissolved into unaccounted void.'
        : 'Half of your mortal window slipped by without a record or dedicated session.';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isSevere
              ? p.red.withValues(alpha: 0.3)
              : p.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'The Cost of the Void'.localized(context).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSevere ? p.red : p.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isSevere ? p.red : p.orange).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  headlineVerdict.localized(context),
                  style: TextStyle(
                    color: isSevere ? p.red : p.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Big Typographic Hero
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$wasted ${'Wasted'.localized(context)}',
              maxLines: 1,
              style: TextStyle(
                color: isSevere ? p.red : p.text,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            verdictQuote.localized(context),
            style: TextStyle(color: p.text2, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 18),

          // Dual-Stat Pill Badges
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Waking Days Lost'.localized(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.text3,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            wakingLost,
                            style: TextStyle(
                              color: p.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Earth (24h) Days'.localized(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.text3,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            celestialLost,
                            style: TextStyle(
                              color: p.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
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
          const SizedBox(height: 18),

          // Dual-Tone Linear Intentionality Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ratio.toStringAsFixed(1)}% ${'Accounted'.localized(context)}',
                style: TextStyle(
                  color: p.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${voidRatio.toStringAsFixed(1)}% ${'Void'.localized(context)}',
                style: TextStyle(
                  color: p.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (ratio > 0)
                    Expanded(
                      flex: (ratio * 10).round(),
                      child: Container(color: p.green),
                    ),
                  if (voidRatio > 0)
                    Expanded(
                      flex: (voidRatio * 10).round(),
                      child: Container(color: p.red),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayByDayLedger(LifeAuditSummary summary) {
    final records = summary.dailyRecords;
    final displayRecords = _showAllDays ? records : records.take(7).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(28),
        border: p.name == 'amoled'
            ? Border.all(color: p.border.withValues(alpha: 0.5), width: 0.8)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Ledger Breakdown'.localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${records.length} ${'Days Total'.localized(context)}',
                style: TextStyle(color: p.text3, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...displayRecords.map((r) {
            final statusColor = r.status.color(
              accent: p.accent,
              green: p.green,
              orange: p.orange,
              red: p.red,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r.displayLabel,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 13,
                                fontWeight: r.isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          r.wastedDuration.inMinutes > 0
                              ? '${r.formattedWasted} ${'lost'.localized(context)}'
                              : 'Fully Accounted'.localized(context),
                          style: TextStyle(
                            color: r.wastedDuration.inMinutes > 0
                                ? p.red
                                : p.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress line
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 5,
                        child: Row(
                          children: [
                            if (r.intentionalityPercentage > 0)
                              Expanded(
                                flex: (r.intentionalityPercentage * 10).round(),
                                child: Container(color: p.green),
                              ),
                            if (r.intentionalityPercentage < 100)
                              Expanded(
                                flex: ((100 - r.intentionalityPercentage) * 10)
                                    .round(),
                                child: Container(color: p.red),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          if (records.length > 7) ...[
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showAllDays = !_showAllDays);
                },
                child: Text(
                  _showAllDays
                      ? 'Show Recent 7 Days'.localized(context)
                      : '${'Show All'.localized(context)} ${records.length} ${'Days'.localized(context)}',
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStoicColophonCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.flame, size: 18, color: p.orange),
              const SizedBox(width: 8),
              Text(
                'THE STOIC REALITY'.localized(context),
                style: TextStyle(
                  color: p.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '“It is not that we have a short time to live, but that we waste a lot of it. Life is long enough, and a sufficiently generous estimate has been given to us for the highest achievements, if it were all well invested.”'
                .localized(context),
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '— Seneca, On the Shortness of Life',
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
