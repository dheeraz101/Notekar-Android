import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class AppIconData {
  final String key;
  final String title;
  final String subtitle;
  final String asset;

  const AppIconData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.asset,
  });
}

const List<AppIconData> kAppIconOptions = [
  AppIconData(
    key: 'default',
    title: 'Aurora',
    subtitle: 'Default Spectrum',
    asset: 'icon-maskable-512.png',
  ),
  AppIconData(
    key: 'black',
    title: 'Midnight',
    subtitle: 'Obsidian Onyx',
    asset: 'app_icons/black.png',
  ),
  AppIconData(
    key: 'blue',
    title: 'Sapphire',
    subtitle: 'Royal Ocean',
    asset: 'app_icons/blue.png',
  ),
  AppIconData(
    key: 'gold',
    title: 'Imperial',
    subtitle: 'Champagne Gold',
    asset: 'app_icons/gold.png',
  ),
  AppIconData(
    key: 'green',
    title: 'Emerald',
    subtitle: 'Forest Jade',
    asset: 'app_icons/green.png',
  ),
  AppIconData(
    key: 'orange',
    title: 'Sunset',
    subtitle: 'Tangerine Coral',
    asset: 'app_icons/orange.png',
  ),
  AppIconData(
    key: 'red',
    title: 'Crimson',
    subtitle: 'Velvet Ruby',
    asset: 'app_icons/red.png',
  ),
  AppIconData(
    key: 'purple',
    title: 'Amethyst',
    subtitle: 'Cosmic Nebula',
    asset: 'app_icons/purple.png',
  ),
];

class AppIconsSettingsPage extends StatelessWidget {
  const AppIconsSettingsPage({
    super.key,
    required this.p,
    required this.appIconStyle,
    required this.onAppIconStyleChanged,
    this.godModeUnlocked = false,
  });

  final Palette p;
  final String appIconStyle;
  final ValueChanged<String> onAppIconStyleChanged;
  final bool godModeUnlocked;

  @override
  Widget build(BuildContext context) {
    final currentIcon = kAppIconOptions.firstWhere(
      (opt) => opt.key == appIconStyle,
      orElse: () => kAppIconOptions.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing12),

        // Hero Active Icon Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: spacing16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: p.accent.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(currentIcon.asset, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        (godModeUnlocked && currentIcon.key == 'gold')
                            ? '⚡ VIP Sovereign Icon'.localized(context)
                            : 'Active Launcher Icon'.localized(context),
                        style: TextStyle(
                          color: (godModeUnlocked && currentIcon.key == 'gold')
                              ? const Color(0xFFFFD700)
                              : p.accent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (godModeUnlocked && currentIcon.key == 'gold')
                          ? 'Sovereign • Champagne VIP'
                          : '${currentIcon.title.localized(context)} • ${currentIcon.subtitle.localized(context)}',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tap any icon below to switch style'.localized(context),
                      style: TextStyle(color: p.text3, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing20),

        // 4-Column Icon-Only Grid with Large App Logos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacing16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kAppIconOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final item = kAppIconOptions[index];
              final isSelected = appIconStyle == item.key;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (item.key == appIconStyle) return;
                    NotekarHaptics.selection('standard');
                    onAppIconStyleChanged(item.key);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? p.accent.withValues(alpha: 0.14)
                          : p.surface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? p.accent : p.border,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: p.accent.withValues(alpha: 0.20),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        item.asset,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: spacing16),

        SettingsPageDescription(
          p: p,
          showIcon: true,
          text:
              'App Icons update your Android launcher shortcut dynamically. Some launcher home screens may take a moment to refresh.'
                  .localized(context),
        ),
        const SizedBox(height: spacing32),
      ],
    );
  }
}
