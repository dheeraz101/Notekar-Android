import 'package:flutter/cupertino.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

/// Minimal Apple HIG Roadmap and Upcoming Features settings page.
class UpcomingFeaturesSettingsPage extends StatelessWidget {
  const UpcomingFeaturesSettingsPage({super.key, required this.p});

  final Palette p;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),

        // Hero Header Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(CupertinoIcons.sparkles, color: p.accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roadmap & Innovations'.localized(context),
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sovereign chronometer craft, private local intelligence, and zero telemetry.'
                          .localized(context),
                      style: TextStyle(
                        color: p.text2,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing16),

        // 1. Shipped & Active
        SettingsGroup(
          p: p,
          title: 'SHIPPED & ACTIVE'.localized(context),
          insetDividers: true,
          children: [
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.stopwatch_fill,
              iconColor: p.accent,
              title: 'In/Out Chronometer Engine'.localized(context),
              subtitle: 'Real-time live sessions & day distribution accounting'
                  .localized(context),
              status: 'Shipped'.localized(context),
              statusColor: p.green,
            ),
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.hourglass,
              iconColor: p.red,
              title: 'Life Audit & 24h Baseline'.localized(context),
              subtitle: 'Time wastage auditing & mortality balance insights'
                  .localized(context),
              status: 'Shipped'.localized(context),
              statusColor: p.green,
            ),
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.sparkles,
              iconColor: p.orange,
              title: 'Sobriety Companion'.localized(context),
              subtitle: 'Clean streaks, relapse analysis & habit triggers'
                  .localized(context),
              status: 'Shipped'.localized(context),
              statusColor: p.green,
            ),
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.bell_fill,
              iconColor: p.accent,
              title: 'Lockscreen Notification Panel'.localized(context),
              subtitle: 'Sticky persistent drawer control & quick note popup'
                  .localized(context),
              status: 'Shipped'.localized(context),
              statusColor: p.green,
            ),
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.lock_shield_fill,
              iconColor: p.green,
              title: 'Offline Encrypted Backups'.localized(context),
              subtitle: 'Local AES encrypted archive, JSON & CSV data exports'
                  .localized(context),
              status: 'Shipped'.localized(context),
              statusColor: p.green,
            ),
          ],
        ),

        const SizedBox(height: spacing16),

        // 2. Upcoming Roadmap
        SettingsGroup(
          p: p,
          title: 'UPCOMING INNOVATIONS'.localized(context),
          insetDividers: true,
          children: [
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.globe,
              iconColor: p.accent,
              title: 'Full-Fledged Language Support'.localized(context),
              subtitle:
                  'Expanding translations across 7+ regional and global languages'
                      .localized(context),
              status: 'In Progress'.localized(context),
              statusColor: p.orange,
            ),
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.square_grid_2x2_fill,
              iconColor: p.accent,
              title: 'Interactive Android Widgets'.localized(context),
              subtitle:
                  'Glanceable 2x2 and 4x2 home screen widgets with live ticker'
                      .localized(context),
              status: 'Planned'.localized(context),
              statusColor: p.accent,
            ),
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.speedometer,
              iconColor: p.green,
              title: 'Performance & Cold Start'.localized(context),
              subtitle:
                  'Sub-second startup, low-memory profiling & faster renders'
                      .localized(context),
              status: 'In Progress'.localized(context),
              statusColor: p.orange,
            ),
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.photo_fill_on_rectangle_fill,
              iconColor: const Color(0xFFFF2D55),
              title: 'Photo & Receipt Logging'.localized(context),
              subtitle:
                  'Private offline media attachments to ground moments with visuals'
                      .localized(context),
              status: 'Planned'.localized(context),
              statusColor: p.accent,
            ),
            _FeatureRow(
              p: p,
              icon: CupertinoIcons.mic_fill,
              iconColor: const Color(0xFF5856D6),
              title: 'Hands-Free Voice Dictation'.localized(context),
              subtitle:
                  '100% on-device speech-to-text with auto hashtag parsing'
                      .localized(context),
              status: 'Planned'.localized(context),
              statusColor: p.accent,
            ),
          ],
        ),

        const SizedBox(height: spacing20),

        // Colophon Note
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'All NoteKar innovations adhere strictly to 100% offline sovereignty. No cloud servers, no trackers.'
                .localized(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.text3,
              fontSize: 11.5,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        const SizedBox(height: spacing48),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.p,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  final Palette p;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 11.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
