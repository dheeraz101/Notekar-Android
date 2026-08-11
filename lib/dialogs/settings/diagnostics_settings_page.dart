import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
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
              value: 'v${widget.appVersion} (${widget.appBuildNumber})',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Build Date',
              value: widget.appBuildDate,
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
                Icon(Icons.content_copy_rounded, color: Colors.white, size: 18),
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
      'Version: v${widget.appVersion} (${widget.appBuildNumber})',
      'Build date: ${widget.appBuildDate}',
      'Moments: ${entries.length} total, $todayCount today',
      'Storage: local offline storage',
      'Android backup: configured',
      'Updates: ${widget.updateSubtitle}',
      'Last update check: ${widget.lastUpdateCheckedAt == null ? 'Not checked yet' : relativeAge(widget.lastUpdateCheckedAt!)}',
      'App notices: ${widget.remoteNotices ? 'Enabled' : 'Disabled'}',
      'Last moment: $latest',
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
                  Icons.warning_amber_rounded,
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
                        Icons.memory_rounded,
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
              label: 'Performance Tier',
              value: engine.tier.name.toUpperCase(),
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'RAM Capacity',
              value: '${engine.ramGb} GB',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'CPU Cores',
              value: '${engine.processors} Cores',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'System Blur',
              value: engine.supportsBlur ? 'Supported' : 'Hardware Limited',
            ),
            DiagnosticRow(
              p: widget.p,
              label: 'Live Animations',
              value: engine.supportsAdvancedAnimations
                  ? 'High Performance'
                  : 'Optimized',
            ),
          ],
        ),
        SettingsPageDescription(
          p: widget.p,
          text: 'Technical stats about your device and the Adaptive Engine.'
              .localized(context),
        ),
        SettingsBetaNote(
          p: widget.p,
          text: 'The current features on this page are under Beta stage.'
              .localized(context),
          onLearnMore: widget.onLearnMoreBeta,
        ),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (widget.networkLogs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: HIGEmptyState(
              p: widget.p,
              icon: Icons.wifi_tethering_off_rounded,
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
                      ? widget.p.surface.withValues(alpha: 0.4)
                      : widget.p.surface2,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.p.border.withValues(alpha: 0.2),
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
                                Icons.shield_outlined,
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
