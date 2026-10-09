import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/pressable_scale.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class AppIconData {
  final String key;
  final String title;
  final String subtitle;
  final String asset;
  final Color themeColor;

  const AppIconData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.themeColor,
  });
}

const List<AppIconData> kAppIconOptions = [
  AppIconData(
    key: 'default',
    title: 'Aurora',
    subtitle: 'Default Spectrum',
    asset: 'icon-maskable-512.png',
    themeColor: Color(0xFF007AFF),
  ),
  AppIconData(
    key: 'black',
    title: 'Midnight',
    subtitle: 'Obsidian Onyx',
    asset: 'app_icons/black.png',
    themeColor: Color(0xFF48484A),
  ),
  AppIconData(
    key: 'blue',
    title: 'Sapphire',
    subtitle: 'Royal Ocean',
    asset: 'app_icons/blue.png',
    themeColor: Color(0xFF0A84FF),
  ),
  AppIconData(
    key: 'gold',
    title: 'Imperial',
    subtitle: 'Champagne Gold',
    asset: 'app_icons/gold.png',
    themeColor: Color(0xFFFFD700),
  ),
  AppIconData(
    key: 'green',
    title: 'Emerald',
    subtitle: 'Forest Jade',
    asset: 'app_icons/green.png',
    themeColor: Color(0xFF30D158),
  ),
  AppIconData(
    key: 'orange',
    title: 'Sunset',
    subtitle: 'Tangerine Coral',
    asset: 'app_icons/orange.png',
    themeColor: Color(0xFFFF9F0A),
  ),
  AppIconData(
    key: 'red',
    title: 'Crimson',
    subtitle: 'Velvet Ruby',
    asset: 'app_icons/red.png',
    themeColor: Color(0xFFFF453A),
  ),
  AppIconData(
    key: 'purple',
    title: 'Amethyst',
    subtitle: 'Cosmic Nebula',
    asset: 'app_icons/purple.png',
    themeColor: Color(0xFFBF5AF2),
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
  final Future<bool> Function(String value) onAppIconStyleChanged;
  final bool godModeUnlocked;

  @override
  Widget build(BuildContext context) {
    final currentIcon = kAppIconOptions.firstWhere(
      (opt) => opt.key == appIconStyle,
      orElse: () => kAppIconOptions.first,
    );

    final isVipGold = godModeUnlocked && currentIcon.key == 'gold';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),

        // 1. Hero Active Icon Showcase Pedestal
        Container(
          margin: const EdgeInsets.symmetric(horizontal: spacing16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: p.border),
            boxShadow: [
              BoxShadow(
                color:
                    (isVipGold
                            ? const Color(0xFFFFD700)
                            : currentIcon.themeColor)
                        .withValues(alpha: 0.16),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    currentIcon.asset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (isVipGold ? const Color(0xFFFFD700) : p.accent)
                            .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isVipGold
                            ? '⚡ VIP Sovereign Icon'.localized(context)
                            : 'Active Launcher Icon'.localized(context),
                        style: TextStyle(
                          color: isVipGold ? const Color(0xFFFFD700) : p.accent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isVipGold
                            ? 'Sovereign • Champagne VIP'
                            : '${currentIcon.title.localized(context)} • ${currentIcon.subtitle.localized(context)}',
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap any icon below to apply style'.localized(context),
                      style: TextStyle(color: p.text3, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing16),

        // 2. Adaptive Apple HIG Icon Choices Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacing16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kAppIconOptions.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisExtent: 84,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final item = kAppIconOptions[index];
              final isSelected = appIconStyle == item.key;

              return PressableScale(
                onTap: () async {
                  if (item.key == appIconStyle) return;
                  NotekarHaptics.selection('standard');
                  await onAppIconStyleChanged(item.key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? p.accent.withValues(alpha: 0.12)
                        : p.surface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? p.accent : p.border,
                      width: isSelected ? 1.75 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            item.asset,
                            fit: BoxFit.cover,
                            cacheWidth: 96,
                            cacheHeight: 96,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: p.surface3,
                                  child: Icon(
                                    CupertinoIcons.photo,
                                    color: p.text3,
                                    size: 18,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title.localized(context),
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle.localized(context),
                                style: TextStyle(color: p.text3, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isSelected
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.circle,
                        size: 18,
                        color: isSelected ? p.accent : p.text3,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: spacing16),

        // 3. Footer description
        SettingsPageDescription(
          p: p,
          showIcon: true,
          text:
              'App icons update your Android launcher shortcut dynamically. Some home screen launchers may take a few moments to reload the cache.'
                  .localized(context),
        ),

        const SizedBox(height: spacing32),
      ],
    );
  }
}
