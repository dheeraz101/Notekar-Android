import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class AppPhilosophySettingsPage extends StatelessWidget {
  const AppPhilosophySettingsPage({
    super.key,
    required this.p,
    required this.appVersion,
  });

  final Palette p;
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),

        // 1. Apple Hero Header
        Center(
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'icon-maskable-512.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'THE NOTEKAR MANIFESTO'.localized(context),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Simplicity is the Ultimate Sophistication'.localized(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Technology married with liberal arts. Software crafted to serve the human spirit, not harvest it.'
                      .localized(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.text2,
                    fontSize: 14.5,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing24),

        // 2. The Steve Jobs Conviction Callout
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: p.accent.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: p.accent.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.format_quote_rounded, color: p.accent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'THE COURAGE TO SAY NO'.localized(context),
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '"People think focus means saying yes to the thing you\'ve got to focus on. But that\'s not what it means at all. It means saying no to the hundred other good ideas that there are. Innovation is saying no to 1,000 things."'
                    .localized(context),
                style: TextStyle(
                  color: p.text,
                  fontSize: 14.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '— Steve Jobs',
                style: TextStyle(
                  color: p.accent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Divider(color: p.border.withValues(alpha: 0.5), height: 1),
              const SizedBox(height: 14),
              Text(
                'We said NO to cloud telemetry, NO to advertising trackers, NO to subscription locks, and NO to addictive engagement loops. By saying NO to noise, we make room for a quiet, permanent canvas for your life.'
                    .localized(context),
                style: TextStyle(color: p.text2, fontSize: 13.5, height: 1.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing24),

        // 3. Section Title: Core Pillars
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'FIVE PILLARS OF CRAFT'.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),

        // Pillar I: Simplicity
        _PhilosophyPillarCard(
          p: p,
          number: '01',
          icon: Icons.touch_app_rounded,
          iconColor: p.accent,
          tag: '1-TAP TRUTH'.localized(context),
          title: 'Simplicity is Sacred'.localized(context),
          body:
              'Recording your life should never be bogged down by forms, dropdowns, or friction. One tap captures the moment. The interface disappears the instant your moment is recorded, keeping your attention in reality.'
                  .localized(context),
        ),

        const SizedBox(height: 12),

        // Pillar II: Privacy
        _PhilosophyPillarCard(
          p: p,
          number: '02',
          icon: Icons.shield_rounded,
          iconColor: p.green,
          tag: 'ZERO TELEMETRY'.localized(context),
          title: 'Sanctuary of Radical Privacy'.localized(context),
          body:
              'Privacy is not a setting; it is a fundamental human right. What you do, when you focus, and how you spend your days belongs to you alone. NoteKar has zero cloud databases, zero analytics SDKs, and zero tracking pixels.'
                  .localized(context),
        ),

        const SizedBox(height: 12),

        // Pillar III: Attention
        _PhilosophyPillarCard(
          p: p,
          number: '03',
          icon: Icons.spa_rounded,
          iconColor: p.orange,
          tag: 'CALM TECHNOLOGY'.localized(context),
          title: 'Reverence for Human Attention'.localized(context),
          body:
              'Modern apps are weaponized slot machines engineered to addict. NoteKar is calm software. No red notification badges, no synthetic urgency, and no guilt trips. It obeys your touch in 50ms, then gets out of the way.'
                  .localized(context),
        ),

        const SizedBox(height: 12),

        // Pillar IV: Craftsmanship
        _PhilosophyPillarCard(
          p: p,
          number: '04',
          icon: Icons.brush_rounded,
          iconColor: const Color(0xFFAF52DE),
          // Apple Purple
          tag: 'UNCOMPROMISING CRAFT'.localized(context),
          title: 'The Back of the Mahogany Cabinet'.localized(context),
          body:
              'Steve Jobs\' father taught him that the back of a cabinet must be finished as beautifully as the front, even if nobody will ever see it. We obsess over the hidden details: sub-millisecond local queries, tactile mechanical haptics, and clean architecture.'
                  .localized(context),
        ),

        const SizedBox(height: 12),

        // Pillar V: Longevity
        _PhilosophyPillarCard(
          p: p,
          number: '05',
          icon: Icons.all_inclusive_rounded,
          iconColor: p.blue,
          tag: 'TIMELESS POSSESSION'.localized(context),
          title: 'Built Like an Heirloom'.localized(context),
          body:
              'Software should outlive startup business models. Because NoteKar requires no remote servers or cloud accounts, it cannot be sunset or turned off. Thirty years from now, if your device powers on, your life ledger remains intact.'
                  .localized(context),
        ),

        const SizedBox(height: spacing24),

        // 4. All-in-One Spec Grid
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'THE ARCHITECTURAL CODE'.localized(context),
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),

        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            _SpecRow(
              p: p,
              icon: Icons.cloud_off_rounded,
              color: p.accent,
              title: '100% Offline Core'.localized(context),
              subtitle:
                  'Zero network connectivity required to record, search, or review'
                      .localized(context),
            ),
            _SpecRow(
              p: p,
              icon: Icons.visibility_off_rounded,
              color: p.green,
              title: 'Zero Analytics or Trackers'.localized(context),
              subtitle:
                  'No Google Analytics, Firebase, Sentry, or third-party beacons'
                      .localized(context),
            ),
            _SpecRow(
              p: p,
              icon: Icons.bolt_rounded,
              color: p.orange,
              title: 'Local Hive Engine'.localized(context),
              subtitle:
                  'Sub-millisecond disk queries with encrypted-ready local storage'
                      .localized(context),
            ),
            _SpecRow(
              p: p,
              icon: Icons.vibration_rounded,
              color: const Color(0xFFAF52DE),
              title: 'Tactile Mechanical Haptics'.localized(context),
              subtitle:
                  'Physical acoustic weight tuned for natural tactile feedback'
                      .localized(context),
            ),
            _SpecRow(
              p: p,
              icon: Icons.code_rounded,
              color: p.accent,
              title: 'Open Source Transparency'.localized(context),
              subtitle:
                  'Every line of source code is public and auditable on GitHub'
                      .localized(context),
            ),
            _SpecRow(
              p: p,
              icon: Icons.money_off_rounded,
              color: p.red,
              title: 'Zero Subscriptions or Ads'.localized(context),
              subtitle:
                  'A permanent, respectful tool without monetization traps'
                      .localized(context),
            ),
          ],
        ),

        const SizedBox(height: spacing32),

        // 5. Apple Colophon Signature
        Center(
          child: Column(
            children: [
              Text(
                'NoteKar',
                style: TextStyle(
                  color: p.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version v$appVersion • Designed with Conviction'.localized(
                  context,
                ),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Crafted for the quiet dignity of human attention.'.localized(
                  context,
                ),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing48),
      ],
    );
  }
}

class _PhilosophyPillarCard extends StatelessWidget {
  const _PhilosophyPillarCard({
    required this.p,
    required this.number,
    required this.icon,
    required this.iconColor,
    required this.tag,
    required this.title,
    required this.body,
  });

  final Palette p;
  final String number;
  final IconData icon;
  final Color iconColor;
  final String tag;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.border.withValues(alpha: 0.5), width: 0.8),
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
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                number,
                style: TextStyle(
                  color: p.text3,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: p.text,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: p.text2,
              fontSize: 13.5,
              height: 1.5,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({
    required this.p,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final Palette p;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: p.text2, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
