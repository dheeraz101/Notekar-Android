import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/app_notice.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/utils/notice_service.dart';
import 'package:notekar/widgets/pressable_scale.dart';

class OfficialBulletinsSheet extends StatefulWidget {
  const OfficialBulletinsSheet({
    super.key,
    required this.p,
    required this.onOpenLink,
  });

  final Palette p;
  final void Function(String url) onOpenLink;

  static Future<void> show(
    BuildContext context, {
    required Palette p,
    required void Function(String url) onOpenLink,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          OfficialBulletinsSheet(p: p, onOpenLink: onOpenLink),
    );
  }

  @override
  State<OfficialBulletinsSheet> createState() => _OfficialBulletinsSheetState();
}

class _OfficialBulletinsSheetState extends State<OfficialBulletinsSheet> {
  final _service = NoticeService.instance;
  List<AppNotice> _notices = [];
  DateTime? _lastChecked;
  bool _checking = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cached = await _service.getCachedNotices();
    final lastCheck = await _service.getLastCheckTime();
    if (mounted) {
      setState(() {
        _notices = cached;
        _lastChecked = lastCheck;
        _loaded = true;
      });
    }
    // If not checked yet or empty, fetch automatically
    if (cached.isEmpty && lastCheck == null) {
      _checkNow();
    }
  }

  Future<void> _checkNow() async {
    if (_checking) return;
    NotekarHaptics.selection('standard');
    setState(() => _checking = true);

    final fresh = await _service.fetchNotices(force: true);
    final lastCheck = await _service.getLastCheckTime();

    if (mounted) {
      setState(() {
        _notices = fresh;
        _lastChecked = lastCheck ?? DateTime.now();
        _checking = false;
      });
    }
  }

  String _formatLastChecked(BuildContext context, DateTime? dt) {
    if (dt == null) return 'Never checked'.localized(context);
    final now = DateTime.now();
    final isToday =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;

    final hourStr = dt.hour.toString().padLeft(2, '0');
    final minStr = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hourStr:$minStr';

    if (isToday) {
      return '${'Today'.localized(context)}, $timeStr';
    }
    return '${dt.day}/${dt.month}/${dt.year}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final critical = _notices.where((n) => n.isCritical).toList();
    final bulletins = _notices.where((n) => n.isReleaseBulletin).toList();
    final tips = _notices.where((n) => n.isCuratedTip).toList();

    return AppSheet(
      p: p,
      title: 'Bulletins & Advisories'.localized(context),
      docked: true,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Control & Status Pill Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.border.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: critical.isNotEmpty
                            ? p.red
                            : (_checking ? p.orange : p.green),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            critical.isNotEmpty
                                ? 'Action Required'.localized(context)
                                : 'Notice Engine Active'.localized(context),
                            style: TextStyle(
                              color: p.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${'Last checked'.localized(context)}: ${_formatLastChecked(context, _lastChecked)}',
                            style: TextStyle(
                              color: p.text3,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PressableScale(
                      onTap: _checkNow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: p.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_checking)
                              CupertinoActivityIndicator(
                                radius: 6,
                                color: p.accent,
                              )
                            else
                              Icon(
                                Icons.refresh_rounded,
                                size: 14,
                                color: p.accent,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              _checking
                                  ? 'Checking'.localized(context)
                                  : 'Check Now'.localized(context),
                              style: TextStyle(
                                color: p.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Zero-Tracking Privacy Guarantee Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.green.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_rounded, color: p.green, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ZERO-TRACKING GUARANTEE'.localized(context),
                            style: TextStyle(
                              color: p.green,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Bulletins are fetched directly from a static public GitHub JSON feed. Zero telemetry, zero device identifiers, zero advertising IDs, and zero cookies are ever transmitted.'
                                .localized(context),
                            style: TextStyle(
                              color: p.text2,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: spacing20),

              // 3. Hierarchical Notices List
              if (!_loaded && _checking)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CupertinoActivityIndicator(radius: 12)),
                )
              else if (_notices.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: p.border.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: p.green.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: p.green,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'All Systems Normal'.localized(context),
                        style: TextStyle(
                          color: p.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No active advisories, critical bug alerts, or notices for your version.'
                            .localized(context),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: p.text3,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Critical Advisories
                if (critical.isNotEmpty) ...[
                  _NoticeSectionHeader(
                    p: p,
                    title: 'CRITICAL ADVISORIES'.localized(context),
                    color: p.red,
                    icon: Icons.error_outline_rounded,
                  ),
                  for (final n in critical)
                    _NoticeCard(p: p, notice: n, onOpenLink: widget.onOpenLink),
                  const SizedBox(height: spacing16),
                ],

                // Release Bulletins
                if (bulletins.isNotEmpty) ...[
                  _NoticeSectionHeader(
                    p: p,
                    title: 'RELEASE BULLETINS'.localized(context),
                    color: p.accent,
                    icon: Icons.campaign_rounded,
                  ),
                  for (final n in bulletins)
                    _NoticeCard(p: p, notice: n, onOpenLink: widget.onOpenLink),
                  const SizedBox(height: spacing16),
                ],

                // Curated Tips
                if (tips.isNotEmpty) ...[
                  _NoticeSectionHeader(
                    p: p,
                    title: 'CURATED TIPS & BEST PRACTICES'.localized(context),
                    color: p.orange,
                    icon: Icons.lightbulb_outline_rounded,
                  ),
                  for (final n in tips)
                    _NoticeCard(p: p, notice: n, onOpenLink: widget.onOpenLink),
                ],
              ],

              const SizedBox(height: spacing48),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticeSectionHeader extends StatelessWidget {
  const _NoticeSectionHeader({
    required this.p,
    required this.title,
    required this.color,
    required this.icon,
  });

  final Palette p;
  final String title;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.p,
    required this.notice,
    required this.onOpenLink,
  });

  final Palette p;
  final AppNotice notice;
  final void Function(String url) onOpenLink;

  @override
  Widget build(BuildContext context) {
    final isCritical = notice.isCritical;
    final cardColor = isCritical ? p.red.withValues(alpha: 0.06) : p.surface2;
    final borderColor = isCritical
        ? p.red.withValues(alpha: 0.35)
        : p.border.withValues(alpha: 0.5);
    final badgeColor = isCritical
        ? p.red
        : (notice.isReleaseBulletin ? p.accent : p.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCritical
                      ? 'CRITICAL'
                      : (notice.isReleaseBulletin ? 'BULLETIN' : 'TIP'),
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              if (notice.minVersion != null || notice.maxVersion != null)
                Text(
                  'v${notice.minVersion ?? '*'}-${notice.maxVersion ?? '*'}',
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notice.localizedTitle(context),
            style: TextStyle(
              color: p.text,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            notice.localizedBody(context),
            style: TextStyle(color: p.text2, fontSize: 13, height: 1.45),
          ),
          if (notice.url != null && notice.url!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: PressableScale(
                onTap: () => onOpenLink(notice.url!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details'.localized(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
