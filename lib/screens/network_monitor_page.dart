import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/network_logger.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class NetworkMonitorPage extends StatefulWidget {
  final Palette p;

  const NetworkMonitorPage({super.key, required this.p});

  @override
  State<NetworkMonitorPage> createState() => _NetworkMonitorPageState();
}

class _NetworkMonitorPageState extends State<NetworkMonitorPage> {
  List<NetworkLogEntry> _logs = [];
  bool _loading = true;
  String? _expandedUrlIndex;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await NetworkLogger.getLogs();
    if (mounted) {
      setState(() {
        _logs = logs;
        _loading = false;
      });
    }
  }

  Future<void> _clearLogs() async {
    HapticFeedback.mediumImpact();
    await NetworkLogger.clearLogs();
    await _loadLogs();
  }

  String _calculateTotalData() {
    double totalKb = 0;
    for (final entry in _logs) {
      final sizeStr = entry.size.toLowerCase();
      if (sizeStr.contains('kb')) {
        totalKb += double.tryParse(sizeStr.replaceAll('kb', '').trim()) ?? 0.0;
      } else if (sizeStr.contains('mb')) {
        totalKb +=
            (double.tryParse(sizeStr.replaceAll('mb', '').trim()) ?? 0.0) *
            1024.0;
      }
    }
    if (totalKb > 1024) {
      return '${(totalKb / 1024).toStringAsFixed(2)} MB';
    }
    return '${totalKb.toStringAsFixed(1)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return AppSheet(
      p: p,
      title: 'Network Monitor'.localized(context),
      docked: true,
      blur: true,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 410,
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: Column(
            children: [
              // Stats Panel Header
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: p.surface2.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.border.withValues(alpha: 0.5)),
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
                                color: p.text3,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _calculateTotalData(),
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
                              '${_logs.length} reqs',
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Offline Privacy Log'.localized(context),
                          style: TextStyle(
                            color: p.text2,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        PressableScale(
                          onTap: _clearLogs,
                          child: Text(
                            'Clear History'.localized(context),
                            style: TextStyle(
                              color: p.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator(color: p.accent))
                    : _logs.isEmpty
                    ? Center(
                        child: HIGEmptyState(
                          p: p,
                          icon: Icons.wifi_tethering_off_rounded,
                          title: 'No Network Traffic',
                          message:
                              'All network activities made by NoteKar are audited and recorded here.',
                          compact: true,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final entry = _logs[index];
                          final isExpanded = _expandedUrlIndex == '$index';
                          final timeStr =
                              '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}';
                          final dateStr =
                              '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}';

                          // Determine status indicator color
                          Color statusColor = p.green;
                          if (entry.statusCode < 200 ||
                              entry.statusCode >= 300) {
                            statusColor = p.red;
                          }

                          // Method tag colors
                          Color methodBg = p.accent.withValues(alpha: 0.1);
                          Color methodText = p.accent;
                          if (entry.method == 'HEAD') {
                            methodBg = p.text2.withValues(alpha: 0.1);
                            methodText = p.text2;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: p.surface.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: p.border.withValues(alpha: 0.2),
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _expandedUrlIndex = isExpanded
                                      ? null
                                      : '$index';
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Method Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: methodBg,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                        // Purpose description
                                        Expanded(
                                          child: Text(
                                            entry.purpose.localized(context),
                                            style: TextStyle(
                                              color: p.text,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Size indicator
                                        Text(
                                          entry.size,
                                          style: TextStyle(
                                            color: p.text2,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Status indicator
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
                                              'Status ${entry.statusCode}',
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Time label
                                        Text(
                                          '$dateStr • $timeStr',
                                          style: TextStyle(
                                            color: p.text3,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isExpanded) ...[
                                      const SizedBox(height: 12),
                                      Divider(
                                        color: p.border.withValues(alpha: 0.2),
                                        height: 1,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'ENDPOINT URL'.localized(context),
                                        style: TextStyle(
                                          color: p.text3,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SelectableText(
                                        entry.url,
                                        style: TextStyle(
                                          color: p.accent,
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
