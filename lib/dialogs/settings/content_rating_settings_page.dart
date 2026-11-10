import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/theme/app_tokens.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class ContentRatingSettingsPage extends StatelessWidget {
  const ContentRatingSettingsPage({super.key, required this.p});

  final Palette p;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),

        // 1. Official Rating Hero Banner
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      p.green,
                      Color.lerp(p.green, Colors.black, 0.25) ?? p.green,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: p.green.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_shield_fill,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(height: 2),
                      Text(
                        '3+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'GLOBAL CONTENT RATING'.localized(context),
                style: TextStyle(
                  color: p.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rated for Everyone / Age 3+'.localized(context),
                textAlign: TextAlign.center,
                style: NkTokens.typography.title2(p.text),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'NoteKar is certified suitable for all age groups. Clean of mature themes, violence, profanity, and commercial tracking.'
                      .localized(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.text2, fontSize: 13.5, height: 1.4),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // 2. Global Standards Badges Grid
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: p.border.withValues(
                alpha: p.name == 'amoled' ? 0.45 : (!p.isDark ? 0.35 : 0.40),
              ),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: _buildAuthorityPill('IARC', 'Everyone', p)),
              _buildDivider(p),
              Expanded(child: _buildAuthorityPill('ESRB', 'Everyone (E)', p)),
              _buildDivider(p),
              Expanded(child: _buildAuthorityPill('PEGI', '3', p)),
              _buildDivider(p),
              Expanded(child: _buildAuthorityPill('USK', '0', p)),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 3. Content Scorecard Matrix
        SettingsGroup(
          p: p,
          title: 'Content Scorecard'.localized(context),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.shield_slash,
              title: 'Violence & Gore'.localized(context),
              subtitle: 'No physical violence, combat, or blood',
              color: p.green,
              trailing: _buildMinimalStatusBadge('None', p.green, p),
              softIcon: true,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.eye_slash,
              title: 'Sexual Content & Nudity'.localized(context),
              subtitle: 'No provocative themes or depictions',
              color: p.green,
              trailing: _buildMinimalStatusBadge('None', p.green, p),
              softIcon: true,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.slash_circle,
              title: 'Profanity & Crude Humor'.localized(context),
              subtitle: 'Zero offensive language or slurs',
              color: p.green,
              trailing: _buildMinimalStatusBadge('None', p.green, p),
              softIcon: true,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.nosign,
              title: 'Drugs, Alcohol & Tobacco'.localized(context),
              subtitle: 'Includes sobriety support & milestone logging',
              color: p.green,
              trailing: _buildMinimalStatusBadge('None', p.green, p),
              softIcon: true,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.money_dollar_circle,
              title: 'Gambling & Simulated Betting'.localized(context),
              subtitle: 'Zero gambling mechanisms or coin wagering',
              color: p.green,
              trailing: _buildMinimalStatusBadge('None', p.green, p),
              softIcon: true,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 4. Interactive Elements & Safety
        SettingsGroup(
          p: p,
          title: 'Interactive Elements'.localized(context),
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.person_crop_circle_badge_checkmark,
              title: 'User-Generated Content'.localized(context),
              subtitle: 'Strictly on-device personal journaling',
              color: p.accent,
              trailing: _buildMinimalStatusBadge('100% Offline', p.accent, p),
              softIcon: true,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.location_slash,
              title: 'Location Sharing'.localized(context),
              subtitle: 'No GPS tracking, geofences, or maps',
              color: p.green,
              trailing: _buildMinimalStatusBadge('None', p.green, p),
              softIcon: true,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.creditcard,
              title: 'In-App Purchases'.localized(context),
              subtitle: 'Completely free with zero paywalls or subscriptions',
              color: p.green,
              trailing: _buildMinimalStatusBadge('None', p.green, p),
              softIcon: true,
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.ant,
              title: 'Third-Party Ad SDKs'.localized(context),
              subtitle: 'Zero ad banners, interstitials, or tracking tokens',
              color: p.green,
              trailing: _buildMinimalStatusBadge('None', p.green, p),
              softIcon: true,
            ),
          ],
        ),

        SettingsPageDescription(
          p: p,
          text:
              'Official rating classifications ensure NoteKar complies with global child protection guidelines and application store policies (Google Play Developer Program Policy & Apple App Store Review Guidelines).'
                  .localized(context),
        ),

        const SizedBox(height: spacing48),
      ],
    );
  }

  static Widget _buildAuthorityPill(String code, String rating, Palette p) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            code,
            style: TextStyle(
              color: p.text3,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            rating,
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildDivider(Palette p) {
    return Container(
      width: 1,
      height: 22,
      color: p.border.withValues(alpha: 0.4),
    );
  }

  static Widget _buildMinimalStatusBadge(String label, Color color, Palette p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}
