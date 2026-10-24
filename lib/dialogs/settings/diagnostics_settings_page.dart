import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/screens/end_of_support_screen.dart';
import 'package:notekar/services/circuit_breaker_service.dart';
import 'package:notekar/services/device_health_manager.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_logger.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/network_logger.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class DiagnosticsSettingsPage extends StatefulWidget {
  const DiagnosticsSettingsPage({
    super.key,
    required this.p,
    required this.subCategory,
    required this.entries,
    required this.todayCount,
    required this.appVersion,
    required this.appBuildNumber,
    required this.appBuildDate,
    required this.updateSubtitle,
    required this.lastUpdateCheckedAt,
    required this.remoteNotices,
    required this.onCopyDiagnosticsFeedback,
    required this.reduceMotion,
    required this.enableTranslucency,
    required this.networkLogs,
    required this.loadingNetworkLogs,
    required this.onClearNetworkLogs,
    required this.onLearnMoreBeta,
  });

  final Palette p;
  final String subCategory; // 'Diagnostics', 'Device Health', 'Network Monitor'
  final List<Moment> entries;
  final int todayCount;
  final String appVersion;
  final String appBuildNumber;
  final String appBuildDate;
  final String updateSubtitle;
  final int? lastUpdateCheckedAt;
  final bool remoteNotices;
  final ValueChanged<String> onCopyDiagnosticsFeedback;
  final bool reduceMotion;
  final bool enableTranslucency;
  final List<NetworkLogEntry> networkLogs;
  final bool loadingNetworkLogs;
  final VoidCallback onClearNetworkLogs;
  final VoidCallback onLearnMoreBeta;

  @override
  State<DiagnosticsSettingsPage> createState() =>
      _DiagnosticsSettingsPageState();
}

class _DiagnosticsSettingsPageState extends State<DiagnosticsSettingsPage> {
  int? _expandedNetworkLogIndex;
  int _buildTapCount = 0;
  DateTime? _lastBuildTapTime;

  void _handleBuildTap(BuildContext context) {
    final now = DateTime.now();
    if (_lastBuildTapTime != null &&
        now.difference(_lastBuildTapTime!).inSeconds > 4) {
      _buildTapCount = 0;
    }
    _lastBuildTapTime = now;
    _buildTapCount++;

    if (_buildTapCount >= 4 && _buildTapCount <= 6) {
      HapticFeedback.lightImpact();
      showIosPillToast(
        context: context,
        p: widget.p,
        message: '$_buildTapCount',
        icon: CupertinoIcons.sparkles,
      );
    } else if (_buildTapCount >= 7) {
      _buildTapCount = 0;
      HapticFeedback.heavyImpact();
      _showDeveloperQuestDialog(context);
    }
  }

  Future<void> _showDeveloperQuestDialog(BuildContext context) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) {
        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: widget.p.isDark ? Brightness.dark : Brightness.light,
          ),
          child: CupertinoAlertDialog(
            title: Text('Developer Quest'.localized(context)),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'You have unlocked developers hidden Quest.'.localized(context),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  EndOfSupportScreen.open(context, p: widget.p);
                },
                child: Text('Okay'.localized(context)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subCategory == 'Diagnostics') {
      return _buildDiagnostics(context);
    } else if (widget.subCategory == 'Device Health') {
      return _buildDeviceHealth(context);
    } else if (widget.subCategory == 'Network Monitor') {
      return _buildNetworkMonitor(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildDiagnostics(BuildContext context) {
    final latest = widget.entries.isEmpty
        ? 'No moments yet'
        : relativeAge(
            widget.entries.map((entry) => entry.timestamp).reduce(math.max),
          );
    final lastChecked = widget.lastUpdateCheckedAt == null
        ? 'Not checked yet'
        : relativeAge(widget.lastUpdateCheckedAt!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          p: widget.p,
          children: [
            DiagnosticRow(
              p: widget.p,
              label: 'App Version',
              value: 'v${widget.appVersion}',
            ),
            PressableScale(
              onTap: () => _handleBuildTap(context),
              child: DiagnosticRow(
                p: widget.p,
                label: 'Build Number',
                value: widget.appBuildNumber,
              ),
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Build Date',
              value: widget.appBuildDate,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Moments',
              value:
                  '${widget.entries.length} total - ${widget.todayCount} today',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Storage',
              value: 'Saved privately on this device',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Android Backup',
              value: 'Enabled for system transfer and Google backup',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Updates',
              value: widget.updateSubtitle,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Last Update Check',
              value: lastChecked,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'App Notices',
              value: widget.remoteNotices ? 'Enabled' : 'Disabled',
            ),
            DiagnosticRow(p: widget.p, label: 'Last Moment', value: latest),
          ],
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          p: widget.p,
          title: 'Fault Isolation & Circuit Breakers',
          children: [
            DiagnosticRow(
              p: widget.p,
              label: 'Protection Mode',
              value: 'Active (3-failure auto-isolate)',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Digital Wellbeing Stats',
              value:
                  CircuitBreakerService.instance.isOpen(
                    'digital_wellbeing_stats',
                  )
                  ? 'Tripped (Isolated)'
                  : 'Healthy',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Stats Failures',
              value:
                  '${CircuitBreakerService.instance.getFailureCount('digital_wellbeing_stats')}/3',
            ),
          ],
        ),
        const SizedBox(height: 10),
        PressableScale(
          onTap: () async {
            await CircuitBreakerService.instance.resetAll();
            if (mounted) setState(() {});
            widget.onCopyDiagnosticsFeedback('All Circuit Breakers Reset');
          },
          child: Container(
            width: double.infinity,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.p.surface2,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: widget.p.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.arrow_counterclockwise,
                  color: widget.p.accent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Reset Circuit Breakers',
                  style: TextStyle(
                    color: widget.p.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        PressableScale(
          onTap: () {
            Clipboard.setData(
              ClipboardData(
                text: _diagnosticsText(
                  widget.entries,
                  widget.todayCount,
                  latest,
                ),
              ),
            );
            widget.onCopyDiagnosticsFeedback('Diagnostics copied');
          },
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.p.accent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(CupertinoIcons.doc_on_doc, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Copy Diagnostics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        SettingsPageDescription(
          p: widget.p,
          text:
              'Diagnostics help in troubleshooting. Copying them does not send any data automatically.'
                  .localized(context),
        ),
      ],
    );
  }

  String _diagnosticsText(List<Moment> entries, int todayCount, String latest) {
    final logs = AppLogger().diagnosticLogs;
    return [
      'NoteKar diagnostics',
      'Version: v${widget.appVersion}',
      'Build number: ${widget.appBuildNumber}',
      'Build date: ${widget.appBuildDate}',
      'Moments: ${entries.length} total, $todayCount today',
      'Storage: local offline storage',
      'Android backup: configured',
      'Updates: ${widget.updateSubtitle}',
      'Last update check: ${widget.lastUpdateCheckedAt == null ? 'Not checked yet' : relativeAge(widget.lastUpdateCheckedAt!)}',
      'App notices: ${widget.remoteNotices ? 'Enabled' : 'Disabled'}',
      'Last moment: $latest',
      '',
      'Circuit Breakers:',
      'Digital Wellbeing: ${CircuitBreakerService.instance.isOpen('digital_wellbeing_stats') ? 'TRIPPED (OPEN)' : 'HEALTHY (CLOSED)'}',
      '',
      'Internal Logs:',
      logs.isEmpty ? 'No internal logs available' : logs,
    ].join('\n');
  }

  Widget _buildDeviceHealth(BuildContext context) {
    final engine = AdaptiveEngine();
    final p = widget.p;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DeviceHealthHeroHeader(p: p),
        const SizedBox(height: 18),
        _buildHardwareSpecCard(context, engine, p),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'FEATURE ADAPTATION BREAKDOWN'.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
        // 1. Gaussian Blur
        _FeatureAdaptationCard(
          p: p,
          icon: CupertinoIcons.sparkles,
          title: 'System & Dialog Blur',
          isRestricted: !engine.supportsBlur,
          statusText: engine.supportsBlur
              ? 'Full Real-Time Blur'
              : 'Power-Saving Opaque Glass',
          explanation: engine.supportsBlur
              ? 'Your GPU effortlessly processes Gaussian backdrop blurs without frame drops.'
              : 'Backdrop blurs are restricted to eliminate frame stutter and prevent device heating.',
        ),
        const SizedBox(height: 10),
        // 2. Animation Physics
        _FeatureAdaptationCard(
          p: p,
          icon: CupertinoIcons.arrow_2_circlepath_circle,
          title: 'Spring Animation Curves',
          isRestricted: engine.tier == PerformanceTier.low,
          statusText: '${engine.targetFps} FPS Target Curve',
          explanation: engine.tier == PerformanceTier.high
              ? 'Full 120 FPS high refresh-rate physics curves active for silky gestures.'
              : (engine.tier == PerformanceTier.balanced
                    ? 'Balanced 60 FPS spring transitions optimized for smooth battery life.'
                    : 'Lightweight curve transitions active to preserve processor battery budget.'),
        ),
        const SizedBox(height: 10),
        // 3. Visual Particles
        _FeatureAdaptationCard(
          p: p,
          icon: CupertinoIcons.wand_stars,
          title: 'Particle Celebrations',
          isRestricted: !engine.enableParticleEffects,
          statusText: engine.enableParticleEffects
              ? 'Dynamic Physics Particle Bursts'
              : 'Lightweight Fade Celebrations',
          explanation: engine.enableParticleEffects
              ? 'Goal milestones render interactive particle physics dynamics.'
              : 'Milestones use lightweight visual celebrations to save memory heap.',
        ),
        const SizedBox(height: 10),
        // 4. Background Polling
        _FeatureAdaptationCard(
          p: p,
          icon: CupertinoIcons.clock,
          title: 'Background Engine Precision',
          isRestricted: engine.isLowEnd,
          statusText: engine.backgroundPollingStatusLabel,
          explanation: engine.isLowEnd
              ? 'Task executions are throttled to hourly batches to protect battery life.'
              : 'Adaptive 15-minute sync intervals maintain up-to-date tracking accuracy.',
        ),
        const SizedBox(height: 10),
        // 5. Tactile Haptics
        _FeatureAdaptationCard(
          p: p,
          icon: CupertinoIcons.hand_point_right,
          title: 'Sensory Haptics',
          isRestricted: false,
          statusText: 'Active & Calibrated',
          explanation:
              'Subtle mechanical haptics calibrated for tactile reassurance without excessive motor draw.',
        ),
        const SizedBox(height: 20),
        SettingsGroup(
          p: p,
          title: 'Hardware Diagnostics',
          children: [
            DiagnosticRow(p: p, label: 'Device Model', value: engine.model),
            DiagnosticRow(p: p, label: 'OS Version', value: engine.osVersion),
            DiagnosticRow(
              p: p,
              label: 'System Health',
              value: engine.healthStatus,
            ),
            DiagnosticRow(
              p: p,
              label: 'RAM Capacity',
              value: engine.ramGb > 0 ? '${engine.ramGb} GB' : 'Dynamic Heap',
            ),
            DiagnosticRow(
              p: p,
              label: 'CPU Cores',
              value: '${engine.processors} Cores',
            ),
            DiagnosticRow(
              p: p,
              label: 'Architecture',
              value: engine.supportedAbis.isNotEmpty
                  ? (engine.supportedAbis.any(
                          (a) =>
                              a.toLowerCase().contains('arm64') ||
                              a.toLowerCase().contains('aarch64'),
                        )
                        ? 'arm64-v8a'
                        : engine.supportedAbis.first)
                  : 'arm64-v8a',
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Apple-style Hardware Privacy Notice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.surface2.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.border.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.lock_shield, size: 18, color: p.green),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hardware Privacy & Sovereign Processing'.localized(
                        context,
                      ),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All hardware telemetry is measured 100% locally on your device. NoteKar does not transmit hardware profiles, serial numbers, or diagnostic metrics to any remote server or third party. Calibrations are stored on-device and reset upon uninstallation.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildHardwareSpecCard(
    BuildContext context,
    AdaptiveEngine engine,
    Palette p,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border.withValues(alpha: 0.6), width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.phone_android_rounded, size: 16, color: p.accent),
                  const SizedBox(width: 8),
                  Text(
                    engine.model,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (engine.isLowEnd ? p.orange : p.green).withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${engine.tierLabel} (${engine.targetFps} FPS)',
                  style: TextStyle(
                    color: engine.isLowEnd ? p.orange : p.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: p.border.withValues(alpha: 0.4), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _specSubItem(
                  p: p,
                  icon: Icons.memory_rounded,
                  label: 'Processor Cores',
                  value: '${engine.processors} Cores',
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: p.border.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _specSubItem(
                  p: p,
                  icon: Icons.storage_rounded,
                  label: 'RAM Capacity',
                  value: engine.ramGb > 0
                      ? '${engine.ramGb} GB'
                      : 'Dynamic Heap',
                ),
              ),
              Container(
                width: 1,
                height: 28,
                color: p.border.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _specSubItem(
                  p: p,
                  icon: CupertinoIcons.layers_alt,
                  label: 'OS Version',
                  value: engine.osVersion,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _specSubItem({
    required Palette p,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 14, color: p.text3),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: p.text,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          style: TextStyle(color: p.text3, fontSize: 9.5),
        ),
      ],
    );
  }

  Widget _buildNetworkMonitor(BuildContext context) {
    double totalKb = 0;
    for (final entry in widget.networkLogs) {
      final sizeStr = entry.size.toLowerCase();
      if (sizeStr.contains('kb')) {
        totalKb += double.tryParse(sizeStr.replaceAll('kb', '').trim()) ?? 0.0;
      } else if (sizeStr.contains('mb')) {
        totalKb +=
            (double.tryParse(sizeStr.replaceAll('mb', '').trim()) ?? 0.0) *
            1024.0;
      }
    }
    String totalData = '';
    if (totalKb > 1024) {
      totalData = '${(totalKb / 1024).toStringAsFixed(2)} MB';
    } else {
      totalData = '${totalKb.toStringAsFixed(1)} KB';
    }

    final useTranslucency =
        !widget.reduceMotion &&
        widget.enableTranslucency &&
        AdaptiveEngine().supportsBlur;

    return Column(
      children: [
        _LiveNetworkStatusCard(
          p: widget.p,
          networkLogs: widget.networkLogs,
          totalData: totalData,
          useTranslucency: useTranslucency,
          onClearNetworkLogs: widget.onClearNetworkLogs,
        ),
        const SizedBox(height: 12),
        if (widget.loadingNetworkLogs)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: CupertinoActivityIndicator(
                radius: 12,
                color: widget.p.accent,
              ),
            ),
          )
        else if (widget.networkLogs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: HIGEmptyState(
              p: widget.p,
              icon: CupertinoIcons.wifi_slash,
              title: 'No Network Traffic',
              message:
                  'All network activities made by NoteKar are audited and recorded here.',
              compact: true,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.networkLogs.length,
            itemBuilder: (context, index) {
              final entry = widget.networkLogs[index];
              final isExpanded = _expandedNetworkLogIndex == index;
              final timeStr =
                  '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}';
              final dateStr =
                  '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}';

              Color statusColor = widget.p.green;
              if (entry.statusCode < 200 || entry.statusCode >= 300) {
                statusColor = widget.p.red;
              }

              Color methodBg = widget.p.accent.withValues(alpha: 0.1);
              Color methodText = widget.p.accent;
              if (entry.method == 'HEAD') {
                methodBg = widget.p.text2.withValues(alpha: 0.1);
                methodText = widget.p.text2;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: useTranslucency
                      ? widget.p.surface2.withValues(alpha: 0.6)
                      : widget.p.surface2,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.p.border.withValues(alpha: 0.4),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _expandedNetworkLogIndex = isExpanded ? null : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: methodBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                entry.method,
                                style: TextStyle(
                                  color: methodText,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.purpose.localized(context),
                                style: TextStyle(
                                  color: widget.p.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: isExpanded ? null : 1,
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.size,
                              style: TextStyle(
                                color: widget.p.text2,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  entry.statusCode == 200
                                      ? 'HTTP 200 OK'
                                      : (entry.statusCode == 404
                                            ? 'HTTP 404 Not Found'
                                            : 'HTTP ${entry.statusCode}'),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$dateStr • $timeStr',
                              style: TextStyle(
                                color: widget.p.text3,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 12),
                          Divider(
                            color: widget.p.border.withValues(alpha: 0.2),
                            height: 1,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'FULL TITLE & PURPOSE'.localized(context),
                            style: TextStyle(
                              color: widget.p.text3,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            entry.purpose.localized(context),
                            style: TextStyle(
                              color: widget.p.text,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ENDPOINT URL'.localized(context),
                            style: TextStyle(
                              color: widget.p.text3,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            entry.url,
                            style: TextStyle(
                              color: widget.p.accent,
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.shield,
                                color: widget.p.green,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'HTTPS / TLS 1.3 Encrypted • Offline Cache',
                                style: TextStyle(
                                  color: widget.p.text3,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _DeviceHealthHeroHeader extends StatefulWidget {
  const _DeviceHealthHeroHeader({required this.p});
  final Palette p;

  @override
  State<_DeviceHealthHeroHeader> createState() =>
      _DeviceHealthHeroHeaderState();
}

class _DeviceHealthHeroHeaderState extends State<_DeviceHealthHeroHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final t = _pulseController.value;
        final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
        return Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.accent.withValues(alpha: 0.08 + 0.08 * pulse),
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.accent.withValues(alpha: 0.16),
                      border: Border.all(
                        color: p.accent.withValues(alpha: 0.35 + 0.35 * pulse),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.heart_circle_fill,
                      size: 34,
                      color: p.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Device Health & Adaptation'.localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'NoteKar calibrates every animation, blur, and background service to match your hardware profile for maximum smoothness and battery health.'
                  .localized(context),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text2, fontSize: 12.5, height: 1.38),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureAdaptationCard extends StatelessWidget {
  const _FeatureAdaptationCard({
    required this.p,
    required this.icon,
    required this.title,
    required this.isRestricted,
    required this.statusText,
    required this.explanation,
  });

  final Palette p;
  final IconData icon;
  final String title;
  final bool isRestricted;
  final String statusText;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final statusColor = isRestricted ? p.orange : p.green;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border.withValues(alpha: 0.6), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: p.surface3,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: p.text),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusText.localized(context),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isRestricted
                      ? p.orange.withValues(alpha: 0.12)
                      : p.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isRestricted ? 'RESTRICTED' : 'ENABLED',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              explanation.localized(context),
              style: TextStyle(color: p.text2, fontSize: 11.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartbeatEcgPainter extends CustomPainter {
  final double sweepProgress;
  final int sweepPass;
  final double connectedFactor;
  final Color liveColor;
  final Color offlineColor;
  final bool isLowEnd;
  final bool isThrottled;

  _HeartbeatEcgPainter({
    required this.sweepProgress,
    this.sweepPass = 0,
    required this.connectedFactor,
    required this.liveColor,
    required this.offlineColor,
    this.isLowEnd = false,
    this.isThrottled = false,
  });

  // Continuous smooth biological ECG calculation with zero jitter
  double _calculateEcg(double t) {
    if (connectedFactor <= 0.001) return 0.0;

    // Periodic normalized cycle ~75 BPM (cycle length 0.8s)
    const double cycle = 0.8;
    double p = (t / cycle) % 1.0;
    if (p < 0) p += 1.0;

    // Continuous subtle baseline wander without jumps
    final double baselineWander = math.sin(t * 0.75) * 0.015;

    double wave = 0.0;
    if (p >= 0.10 && p < 0.20) {
      // P-wave (atrial depolarization)
      final double prog = (p - 0.10) / 0.10;
      wave += math.sin(prog * math.pi) * 0.18;
    } else if (p >= 0.26 && p < 0.29) {
      // Q-dip (septal depolarization)
      final double prog = (p - 0.26) / 0.03;
      wave -= math.sin(prog * math.pi) * 0.14;
    } else if (p >= 0.29 && p < 0.34) {
      // R-spike (ventricular depolarization)
      final double prog = (p - 0.29) / 0.05;
      wave += math.sin(prog * math.pi) * 1.05;
    } else if (p >= 0.34 && p < 0.39) {
      // S-drop (ventricular rebound)
      final double prog = (p - 0.34) / 0.05;
      wave -= math.sin(prog * math.pi) * 0.28;
    } else if (p >= 0.48 && p < 0.66) {
      // T-wave (ventricular repolarization)
      final double prog = (p - 0.48) / 0.18;
      wave += math.sin(prog * math.pi) * 0.32;
    }

    return (baselineWander + wave) * connectedFactor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final midY = h / 2;

    // 1. When offline / zero connectivity, flatline immediately to a solid red line
    if (connectedFactor <= 0.001) {
      final flatlinePaint = Paint()
        ..color = offlineColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, midY), Offset(w, midY), flatlinePaint);
      return;
    }

    final activeColor = Color.lerp(offlineColor, liveColor, connectedFactor)!;
    const double sweepPeriod = 2.4;

    if (isThrottled) {
      // Adaptive Canvas Throttling: Lightweight static vector curve with instantaneous
      // state changes and zero CPU timer ticks.
      final staticPath = Path();
      bool started = false;
      for (double x = 0; x <= w; x += 3.5) {
        final normX = x / w;
        final t = normX * sweepPeriod;
        final y = midY - _calculateEcg(t) * (h * 0.42);
        if (!started) {
          staticPath.moveTo(x, y);
          started = true;
        } else {
          staticPath.lineTo(x, y);
        }
      }
      final staticPaint = Paint()
        ..color = activeColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(staticPath, staticPaint);
      return;
    }

    // 2. Stable continuous background hinted waveform track across the full width
    // (no horizontal cut-through straight line, smooth continuous cardiac pattern)
    final hintPath = Path();
    bool hintStarted = false;
    for (double x = 0; x <= w; x += 2.0) {
      final normX = x / w;
      final t = normX * sweepPeriod;
      final y = midY - _calculateEcg(t) * (h * 0.42);
      if (!hintStarted) {
        hintPath.moveTo(x, y);
        hintStarted = true;
      } else {
        hintPath.lineTo(x, y);
      }
    }
    final hintPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.16)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(hintPath, hintPaint);

    // 3. Sweep beam position
    final sweepX = w * sweepProgress.clamp(0.0, 1.0);

    final linePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final enableGlow =
        !isLowEnd &&
        !isThrottled &&
        DeviceHealthManager.instance.enableGlowShader;
    final glowPaint = enableGlow
        ? (Paint()
            ..color = activeColor.withValues(
              alpha: (0.18 + 0.22 * connectedFactor).clamp(0.0, 1.0),
            )
            ..strokeWidth = 4.2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round)
        : null;

    // 4. Draw active trace from 0 up to sweepX flowing seamlessly over hinted baseline
    if (sweepX > 1.0) {
      final freshPath = Path();
      const step = 1.5;
      bool started = false;
      for (double x = 0; x <= sweepX; x += step) {
        final normX = x / w;
        final t = normX * sweepPeriod;
        final y = midY - _calculateEcg(t) * (h * 0.42);
        if (!started) {
          freshPath.moveTo(x, y);
          started = true;
        } else {
          freshPath.lineTo(x, y);
        }
      }
      if (glowPaint != null) canvas.drawPath(freshPath, glowPaint);
      canvas.drawPath(freshPath, linePaint);
    }

    // 5. Live glowing oscilloscope sweep head at (sweepX, sweepY)
    final sweepNormX = (sweepX / w).clamp(0.0, 1.0);
    final sweepT = sweepNormX * sweepPeriod;
    final sweepY = midY - _calculateEcg(sweepT) * (h * 0.42);

    // Leading vertical erase beam gradient
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          activeColor.withValues(alpha: 0.0),
          activeColor.withValues(alpha: 0.45 * connectedFactor),
          activeColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(sweepX - 1.5, 0, 3.0, h));
    canvas.drawLine(Offset(sweepX, 4), Offset(sweepX, h - 4), beamPaint);

    // Glowing phosphor sweep head dot exactly at the drawing wave tip
    final dotPaint = Paint()..color = activeColor;
    final outerHalo = Paint()
      ..color = activeColor.withValues(
        alpha: (0.35 + 0.45 * connectedFactor).clamp(0.0, 1.0),
      );

    if (!isLowEnd && !isThrottled && enableGlow) {
      canvas.drawCircle(Offset(sweepX, sweepY), 6.5, outerHalo);
    }
    canvas.drawCircle(Offset(sweepX, sweepY), 3.0, dotPaint);
    canvas.drawCircle(
      Offset(sweepX, sweepY),
      1.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _HeartbeatEcgPainter oldDelegate) {
    return oldDelegate.sweepProgress != sweepProgress ||
        oldDelegate.sweepPass != sweepPass ||
        oldDelegate.connectedFactor != connectedFactor ||
        oldDelegate.liveColor != liveColor ||
        oldDelegate.offlineColor != offlineColor ||
        oldDelegate.isLowEnd != isLowEnd ||
        oldDelegate.isThrottled != isThrottled;
  }
}

enum _NetworkLiveState { inFlight, stable, offline }

class _LiveNetworkStatusCard extends StatefulWidget {
  const _LiveNetworkStatusCard({
    required this.p,
    required this.networkLogs,
    required this.totalData,
    required this.useTranslucency,
    required this.onClearNetworkLogs,
  });

  final Palette p;
  final List<NetworkLogEntry> networkLogs;
  final String totalData;
  final bool useTranslucency;
  final VoidCallback onClearNetworkLogs;

  @override
  State<_LiveNetworkStatusCard> createState() => _LiveNetworkStatusCardState();
}

class _LiveNetworkStatusCardState extends State<_LiveNetworkStatusCard>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _connectedAnimController;
  Timer? _connectivityTimer;
  _NetworkLiveState _state = _NetworkLiveState.stable;
  int _sweepPass = 0;
  double _lastAnimValue = 0.0;

  @override
  void initState() {
    super.initState();
    final isLowEnd = AdaptiveEngine().isLowEnd;
    final shouldThrottle = DeviceHealthManager.instance.shouldThrottle;
    _animController = AnimationController(
      vsync: this,
      duration: isLowEnd
          ? const Duration(seconds: 8)
          : const Duration(milliseconds: 2400),
      value: (isLowEnd || shouldThrottle) ? 1.0 : 0.0,
    );
    _animController.addListener(() {
      if (_animController.value < _lastAnimValue) {
        _sweepPass++;
      }
      _lastAnimValue = _animController.value;
    });
    if (!isLowEnd && !shouldThrottle) {
      _animController.repeat();
    }
    _connectedAnimController = AnimationController(
      vsync: this,
      duration: isLowEnd ? Duration.zero : const Duration(milliseconds: 800),
      value: 1.0,
    );
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _evaluateConnectivity();
      _connectivityTimer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => _evaluateConnectivity(),
      );
    }
  }

  @override
  void didUpdateWidget(covariant _LiveNetworkStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.networkLogs.length != oldWidget.networkLogs.length) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        _evaluateConnectivity();
      }
    }
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    _animController.dispose();
    _connectedAnimController.dispose();
    super.dispose();
  }

  Future<void> _evaluateConnectivity() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      if (mounted) {
        setState(() => _state = _NetworkLiveState.stable);
        _connectedAnimController.value = 1.0;
      }
      return;
    }
    try {
      final result = await InternetAddress.lookup(
        'dns.google',
      ).timeout(const Duration(seconds: 3));
      if (!mounted) return;
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        final now = DateTime.now();
        final hasRecent = widget.networkLogs.any((entry) {
          final diff = now.difference(entry.timestamp).inSeconds.abs();
          return diff < 15;
        });
        setState(() {
          _state = hasRecent
              ? _NetworkLiveState.inFlight
              : _NetworkLiveState.stable;
        });
        _connectedAnimController.animateTo(1.0, curve: Curves.easeInOutCubic);
      } else {
        if (!mounted) return;
        _handleOfflineDrop();
      }
    } catch (_) {
      if (!mounted) return;
      _handleOfflineDrop();
    }
  }

  void _handleOfflineDrop() {
    final wasOnline = _state != _NetworkLiveState.offline;
    setState(() => _state = _NetworkLiveState.offline);
    _connectedAnimController.animateTo(0.0, curve: Curves.easeInOutCubic);
    if (wasOnline && mounted) {
      showIosPillToast(
        context: context,
        p: widget.p,
        message: 'No internet'.localized(context),
        icon: CupertinoIcons.wifi_slash,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final stateColor = switch (_state) {
      _NetworkLiveState.inFlight => p.accent,
      _NetworkLiveState.stable => p.green,
      _NetworkLiveState.offline => p.red,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.useTranslucency
            ? p.surface2.withValues(alpha: 0.8)
            : p.surface2,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: p.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Metrics Row: Data Consumed & Total Requests
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Consumed'.localized(context).toUpperCase(),
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.totalData,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Requests'.localized(context).toUpperCase(),
                    style: TextStyle(
                      color: p.text3,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.networkLogs.length} reqs',
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: p.border.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 14),
          // Redesigned Live Connectivity Status Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: stateColor.withValues(alpha: 0.14),
                  border: Border.all(
                    color: stateColor.withValues(alpha: 0.28),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  switch (_state) {
                    _NetworkLiveState.inFlight =>
                      CupertinoIcons.arrow_2_circlepath,
                    _NetworkLiveState.stable =>
                      CupertinoIcons.waveform_path_ecg,
                    _NetworkLiveState.offline => CupertinoIcons.wifi_slash,
                  },
                  size: 18,
                  color: stateColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      switch (_state) {
                        _NetworkLiveState.inFlight =>
                          'Active HTTPS Transmission'.localized(context),
                        _NetworkLiveState.stable =>
                          'Network Live & Verified'.localized(context),
                        _NetworkLiveState.offline =>
                          'Offline Sovereign Mode'.localized(context),
                      },
                      style: TextStyle(
                        color: p.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(switch (_state) {
                      _NetworkLiveState.inFlight =>
                        'Direct channel open • Zero tracking or diagnostic data sent'
                            .localized(context),
                      _NetworkLiveState.stable =>
                        'Live cardiac pulse active • Zero telemetry • 100% offline DB'
                            .localized(context),
                      _NetworkLiveState.offline =>
                        'Heartbeat flatlined • Offline sovereign mode • No packets sent'
                            .localized(context),
                    }, style: TextStyle(color: p.text3, fontSize: 11, height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: stateColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, _) {
                        final pulseAlpha = _state == _NetworkLiveState.offline
                            ? 1.0
                            : (0.4 +
                                      0.6 *
                                          math.sin(
                                            _animController.value * 2 * math.pi,
                                          ))
                                  .clamp(0.2, 1.0);
                        return Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stateColor.withValues(alpha: pulseAlpha),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 5),
                    Text(
                      switch (_state) {
                        _NetworkLiveState.inFlight => 'SYNCING',
                        _NetworkLiveState.stable => 'LIVE',
                        _NetworkLiveState.offline => 'DOWN',
                      },
                      style: TextStyle(
                        color: stateColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Hospital-Style Animated ECG Heartbeat Waveform
          AnimatedBuilder(
            animation: Listenable.merge([
              _animController,
              _connectedAnimController,
            ]),
            builder: (context, _) {
              return Container(
                height: 46,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: p.border.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: CustomPaint(
                  size: const Size(double.infinity, 38),
                  painter: _HeartbeatEcgPainter(
                    sweepProgress: _animController.value,
                    sweepPass: _sweepPass,
                    connectedFactor: _connectedAnimController.value,
                    liveColor: _state == _NetworkLiveState.inFlight
                        ? p.accent
                        : p.green,
                    offlineColor: p.red,
                    isLowEnd: AdaptiveEngine().isLowEnd,
                    isThrottled: DeviceHealthManager.instance.shouldThrottle,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Divider(color: p.border.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 10),
          // Offline Privacy Log Row & Clear Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Offline Privacy Audit Log'.localized(context),
                style: TextStyle(
                  color: p.text2,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.networkLogs.isNotEmpty)
                PressableScale(
                  onTap: widget.onClearNetworkLogs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: widget.p.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: widget.p.red.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Clear'.localized(context),
                      style: TextStyle(
                        color: widget.p.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
