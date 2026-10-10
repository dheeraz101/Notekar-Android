import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/classic_2000_god_mode_icon.dart';
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

const kGodModeIconOption = AppIconData(
  key: 'godmode',
  title: 'God Mode',
  subtitle: 'Golden Sovereign',
  asset: 'app_icons/g.png',
  themeColor: Color(0xFFFFD700),
);

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
    final availableIcons = [
      ...kAppIconOptions,
      if (godModeUnlocked) kGodModeIconOption,
    ];

    final currentIcon = availableIcons.firstWhere(
      (opt) => opt.key == appIconStyle,
      orElse: () => availableIcons.first,
    );

    final isVipGold =
        godModeUnlocked &&
        (currentIcon.key == 'gold' || currentIcon.key == 'godmode');

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
                child: currentIcon.key == 'godmode'
                    ? const Classic2000GodModeIcon(size: 68)
                    : ClipRRect(
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

        // 2. Adaptive Apple HIG Icon Choices Grid (Icons only, transparent NK on selected)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacing16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: availableIcons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final item = availableIcons[index];
              final isSelected = appIconStyle == item.key;

              return Tooltip(
                key: ValueKey('app_icon_${item.key}'),
                message: item.title.localized(context),
                child: Semantics(
                  label: item.title.localized(context),
                  button: true,
                  selected: isSelected,
                  child: PressableScale(
                    onTap: () async {
                      if (item.key == appIconStyle) return;
                      NotekarHaptics.selection('standard');
                      await onAppIconStyleChanged(item.key);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.transparent : p.surface2,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? p.accent.withValues(alpha: 0.6)
                              : p.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: item.key == 'godmode'
                                ? const Center(
                                    child: Classic2000GodModeIcon(
                                      size: 54,
                                      showGlow: false,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(17),
                                    child: Image.asset(
                                      item.asset,
                                      fit: BoxFit.cover,
                                      cacheWidth: 128,
                                      cacheHeight: 128,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: p.surface3,
                                                child: Icon(
                                                  CupertinoIcons.photo,
                                                  color: p.text3,
                                                  size: 20,
                                                ),
                                              ),
                                    ),
                                  ),
                          ),
                          if (isSelected)
                            Positioned(
                              bottom: -5,
                              right: -5,
                              child: Container(
                                padding: const EdgeInsets.all(3.5),
                                decoration: BoxDecoration(
                                  color: p.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
