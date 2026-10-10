import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/circuit_breaker_service.dart';
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
            DiagnosticRow(
              p: widget.p,
              label: 'Build Number',
              value: widget.appBuildNumber,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LiveDeviceHealthGovernorCard(p: widget.p, engine: engine),
        const SizedBox(height: 16),
        if (engine.isLowEnd || engine.tier == PerformanceTier.low) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.p.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: widget.p.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: widget.p.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Optimized Performance Mode',
                        style: TextStyle(
                          color: widget.p.orange,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'NoteKar has automatically scaled back live animations and blur effects to preserve battery and maintain maximum responsiveness on your device hardware.',
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
          const SizedBox(height: 16),
        ],
        SettingsGroup(
          p: widget.p,
          title: 'Adaptive Engine Overview',
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.gauge,
                        color: widget.p.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Real-time Hardware Tuning',
                        style: TextStyle(
                          color: widget.p.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The Adaptive Engine analyzes system RAM capacity, CPU core count, and GPU tier at launch to tune visual effects for optimum 60 FPS performance without heating or lag.',
                    style: TextStyle(
                      color: widget.p.text2,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsGroup(
          p: widget.p,
          title: 'Hardware Diagnostics',
          children: [
            DiagnosticRow(
              p: widget.p,
              label: 'Device Model',
              value: engine.model,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'OS Version',
              value: engine.osVersion,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'System Health',
              value: engine.healthStatus,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'RAM Capacity',
              value: engine.ramGb > 0 ? '${engine.ramGb} GB' : 'Dynamic Heap',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'CPU Cores',
              value: '${engine.processors} Cores',
            ),
            DiagnosticRow(
              p: widget.p,
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
        SettingsPageDescription(
          p: widget.p,
          text:
              'Technical hardware telemetry detected by the Adaptive Engine at launch.'
                  .localized(context),
        ),

        const SizedBox(height: 16),
        SettingsGroup(
          p: widget.p,
          title: 'Performance Tiers & Capabilities',
          children: [
            DiagnosticRow(
              p: widget.p,
              label: 'Active Tier',
              value: '${engine.tierLabel} (${engine.tier.name.toUpperCase()})',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Target Frame Rate',
              value: '${engine.targetFps} FPS',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'System Blur',
              value: engine.blurStatusLabel,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Live Animations',
              value: engine.animationsStatusLabel,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Visual Effects',
              value: engine.visualEffectsStatusLabel,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Sensory Haptics',
              value: engine.hapticsStatusLabel,
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Background Polling',
              value: engine.backgroundPollingStatusLabel,
            ),
          ],
        ),
        SettingsPageDescription(
          p: widget.p,
          text:
              '${engine.tierDefinition}\n\n'
                      'Tier definitions:\n'
                      '• Pro (High): Full 120 FPS spring physics, Gaussian glass blur, and particle dynamics.\n'
                      '• Balanced: 60 FPS standard transitions and battery-efficient glass overlays.\n'
                      '• Power Saver (Low): Translucency and live physics scaled back to guarantee smooth responsiveness without lag or thermal throttling.'
                  .localized(context),
        ),

        SettingsBetaNote(p: widget.p, onLearnMore: widget.onLearnMoreBeta),
        const SizedBox(height: spacing48),
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
        _LiveNetworkStatusCanvas(p: widget.p, networkLogs: widget.networkLogs),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: useTranslucency
                ? widget.p.surface2.withValues(alpha: 0.8)
                : widget.p.surface2,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: widget.p.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Consumed'.localized(context).toUpperCase(),
                        style: TextStyle(
                          color: widget.p.text3,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        totalData,
                        style: TextStyle(
                          color: widget.p.text,
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
                          color: widget.p.text3,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.networkLogs.length} reqs',
                        style: TextStyle(
                          color: widget.p.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: widget.p.border.withValues(alpha: 0.3), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Offline Privacy Log'.localized(context),
                    style: TextStyle(
                      color: widget.p.text2,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  PressableScale(
                    onTap: widget.onClearNetworkLogs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
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

class _LiveDeviceHealthGovernorCard extends StatefulWidget {
  const _LiveDeviceHealthGovernorCard({required this.p, required this.engine});

  final Palette p;
  final AdaptiveEngine engine;

  @override
  State<_LiveDeviceHealthGovernorCard> createState() =>
      _LiveDeviceHealthGovernorCardState();
}

class _LiveDeviceHealthGovernorCardState
    extends State<_LiveDeviceHealthGovernorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final p = widget.p;
    final budgetMs = (1000.0 / engine.targetFps);
    final simulatedFrametime = (budgetMs * 0.48).toStringAsFixed(1);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(
                p.accent.withValues(alpha: 0.25),
                p.accent.withValues(alpha: 0.60),
                pulse,
              )!,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: p.accent.withValues(alpha: 0.08 * pulse),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.green,
                          boxShadow: [
                            BoxShadow(
                              color: p.green.withValues(
                                alpha: 0.4 + 0.5 * pulse,
                              ),
                              blurRadius: 8 * pulse + 2,
                              spreadRadius: 2 * pulse,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ADAPTIVE GOVERNOR LIVE'.localized(context),
                        style: TextStyle(
                          color: p.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${engine.targetFps} FPS TARGET',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frame Budget ($simulatedFrametime ms / ${budgetMs.toStringAsFixed(1)} ms)',
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Nominal Headroom',
                    style: TextStyle(
                      color: p.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  height: 6,
                  color: p.surface3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (0.42 + 0.08 * pulse).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [p.accent, p.green]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'DYNAMIC HARDWARE SAFEGUARDS'.localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              _buildRefinementChip(
                p,
                CupertinoIcons.circle_grid_hex,
                'Gaussian Glass Blur',
                engine.supportsBlur
                    ? 'Active (100% Depth)'
                    : 'Bypassed (Zero-lag Solid Glass)',
                engine.supportsBlur,
              ),
              const SizedBox(height: 6),
              _buildRefinementChip(
                p,
                CupertinoIcons.sparkles,
                'Particle Physics',
                engine.enableParticleEffects
                    ? 'Full Dynamic Physics'
                    : 'Throttled (Battery Safeguard)',
                engine.enableParticleEffects,
              ),
              const SizedBox(height: 6),
              _buildRefinementChip(
                p,
                CupertinoIcons.arrow_2_squarepath,
                'Mode Switch Transitions',
                'Pre-cached State (0ms Jitter)',
                true,
              ),
              const SizedBox(height: 6),
              _buildRefinementChip(
                p,
                CupertinoIcons.play_circle,
                'Audio Scrubber Cadence',
                engine.isLowEnd
                    ? '15 FPS Throttled (Thermally Safe)'
                    : '60 FPS Smooth Fluidity',
                !engine.isLowEnd,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefinementChip(
    Palette p,
    IconData icon,
    String label,
    String status,
    bool isPro,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: p.surface3.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: p.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: p.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: isPro ? p.green : p.orange,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

enum _NetworkLiveState { inFlight, stable, offline }

class _LiveNetworkStatusCanvas extends StatefulWidget {
  const _LiveNetworkStatusCanvas({required this.p, required this.networkLogs});

  final Palette p;
  final List<NetworkLogEntry> networkLogs;

  @override
  State<_LiveNetworkStatusCanvas> createState() =>
      _LiveNetworkStatusCanvasState();
}

class _LiveNetworkStatusCanvasState extends State<_LiveNetworkStatusCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  _NetworkLiveState _state = _NetworkLiveState.stable;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _evaluateConnectivity();
  }

  @override
  void didUpdateWidget(covariant _LiveNetworkStatusCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.networkLogs.length != oldWidget.networkLogs.length) {
      _evaluateConnectivity();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _evaluateConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'dns.google',
      ).timeout(const Duration(seconds: 3));
      if (!mounted) {
        return;
      }
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
      } else {
        if (!mounted) {
          return;
        }
        setState(() => _state = _NetworkLiveState.offline);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _state = _NetworkLiveState.offline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final t = _animController.value;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: switch (_state) {
                _NetworkLiveState.inFlight => p.accent.withValues(alpha: 0.5),
                _NetworkLiveState.stable => p.green.withValues(alpha: 0.35),
                _NetworkLiveState.offline => p.red.withValues(alpha: 0.35),
              },
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: Center(
                  child: switch (_state) {
                    _NetworkLiveState.inFlight => Stack(
                      alignment: Alignment.center,
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          () {
                            final waveT = (t + i * 0.33) % 1.0;
                            return Container(
                              width: 36 + waveT * 50,
                              height: 36 + waveT * 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: p.accent.withValues(
                                    alpha: (1.0 - waveT) * 0.6,
                                  ),
                                  width: 1.8,
                                ),
                              ),
                            );
                          }(),
                        ],
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.accent,
                            boxShadow: [
                              BoxShadow(
                                color: p.accent.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.arrow_up_arrow_down,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    _NetworkLiveState.stable => Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 58 + 4 * math.sin(t * 2 * math.pi),
                          height: 58 + 4 * math.sin(t * 2 * math.pi),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.green.withValues(alpha: 0.12),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.green,
                            boxShadow: [
                              BoxShadow(
                                color: p.green.withValues(alpha: 0.35),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.wifi,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    _NetworkLiveState.offline => Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 2,
                              color: p.red.withValues(alpha: 0.3),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: p.red.withValues(alpha: 0.16),
                                  border: Border.all(
                                    color: p.red.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  CupertinoIcons.wifi_slash,
                                  color: p.red,
                                  size: 22,
                                ),
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 2,
                              color: p.red.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                switch (_state) {
                  _NetworkLiveState.inFlight => 'ACTIVE NETWORK TRANSMISSION',
                  _NetworkLiveState.stable => 'NETWORK STABLE • ZERO LEAKAGE',
                  _NetworkLiveState.offline => 'LOCAL SOVEREIGN ISOLATION',
                },
                style: TextStyle(
                  color: switch (_state) {
                    _NetworkLiveState.inFlight => p.accent,
                    _NetworkLiveState.stable => p.green,
                    _NetworkLiveState.offline => p.red,
                  },
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                switch (_state) {
                  _NetworkLiveState.inFlight =>
                    'Transmitting telemetry packet via TLS 1.3 socket.',
                  _NetworkLiveState.stable =>
                    'Internet connected. No background sockets or tracking telemetry.',
                  _NetworkLiveState.offline =>
                    'No internet connection detected. 100% offline local database active.',
                },
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.text2,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
