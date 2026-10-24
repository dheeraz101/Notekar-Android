import 'package:flutter/cupertino.dart';
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

class AppIconsSettingsPage extends StatefulWidget {
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
  State<AppIconsSettingsPage> createState() => _AppIconsSettingsPageState();
}

class _AppIconsSettingsPageState extends State<AppIconsSettingsPage> {
  late ScrollController _scrollController;
  final double _itemWidth = 76.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedIcon(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant AppIconsSettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appIconStyle != oldWidget.appIconStyle) {
      _scrollToSelectedIcon(animate: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<AppIconData> _getAvailableIcons() {
    return [...kAppIconOptions, if (widget.godModeUnlocked) kGodModeIconOption];
  }

  void _scrollToSelectedIcon({bool animate = true}) {
    final icons = _getAvailableIcons();
    final index = icons.indexWhere((opt) => opt.key == widget.appIconStyle);
    if (index == -1 || !_scrollController.hasClients) return;

    final targetOffset = index * _itemWidth;
    if (animate) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final availableIcons = _getAvailableIcons();

    final currentIcon = availableIcons.firstWhere(
      (opt) => opt.key == widget.appIconStyle,
      orElse: () => availableIcons.first,
    );

    final isVipGold =
        widget.godModeUnlocked &&
        (currentIcon.key == 'gold' || currentIcon.key == 'godmode');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: spacing8),

        // 1. Top Section: Fake Phone Home Screen Live Preview (fits above fold)
        _buildHomePhonePreview(context, currentIcon, p),

        const SizedBox(height: 16),

        // Section Title: Optical Icon Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SWIPE OR TAP TO SWITCH ICON'.localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${availableIcons.length} Icons',
                style: TextStyle(
                  color: p.text3,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Second Section: Horizontal Optical Scaling Icon Chooser (fits above fold)
        SizedBox(
          height: 98,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth;
              final halfViewport = viewportWidth / 2;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Center Stationary Target Squircle Indicator
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isVipGold ? const Color(0xFFFFD700) : p.accent)
                            .withValues(alpha: 0.45),
                        width: 2.0,
                      ),
                    ),
                  ),

                  // Horizontal List with Distance-Based Scaling
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      setState(() {});
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: halfViewport - (_itemWidth / 2),
                      ),
                      itemCount: availableIcons.length,
                      itemBuilder: (context, index) {
                        final item = availableIcons[index];
                        final itemCenterOffset = index * _itemWidth;
                        final currentScroll = _scrollController.hasClients
                            ? _scrollController.offset
                            : 0.0;
                        final distance = (itemCenterOffset - currentScroll)
                            .abs();

                        // Optical distance scaling
                        final scaleFactor = (1.0 - (distance / 170.0)).clamp(
                          0.48,
                          1.0,
                        );
                        final iconBoxSize = 36.0 + 26.0 * scaleFactor;
                        final cornerRadius = 11.0 + 7.0 * scaleFactor;
                        final opacity = (0.40 + 0.60 * scaleFactor).clamp(
                          0.4,
                          1.0,
                        );
                        final isSelected = item.key == widget.appIconStyle;

                        return GestureDetector(
                          onTap: () async {
                            if (item.key == widget.appIconStyle) return;
                            NotekarHaptics.selection('standard');
                            await widget.onAppIconStyleChanged(item.key);
                            _scrollToSelectedIcon(animate: true);
                          },
                          child: Container(
                            width: _itemWidth,
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: opacity,
                              child: Container(
                                width: iconBoxSize,
                                height: iconBoxSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    cornerRadius,
                                  ),
                                  border: isSelected
                                      ? Border.all(
                                          color: isVipGold
                                              ? const Color(0xFFFFD700)
                                              : Colors.white,
                                          width: 2.2,
                                        )
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: item.themeColor.withValues(
                                              alpha: 0.45,
                                            ),
                                            blurRadius: 14,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          cornerRadius - 1,
                                        ),
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
                                                      size: 16,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        bottom: 3,
                                        right: 3,
                                        child: Container(
                                          padding: const EdgeInsets.all(2.5),
                                          decoration: BoxDecoration(
                                            color: isVipGold
                                                ? const Color(0xFFFFD700)
                                                : p.accent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 9,
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
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // 3. Third Section (Visible on scroll down): Active Launcher Icon Card
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
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Applied to Android Home Screen'.localized(context),
                      style: TextStyle(color: p.text3, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing16),

        // 4. Page Description
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

  Widget _buildHomePhonePreview(
    BuildContext context,
    AppIconData currentIcon,
    Palette p,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E24), Color(0xFF121216), Color(0xFF181822)],
        ),
        border: Border.all(color: p.border.withValues(alpha: 0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // Ambient Wallpaper Glows
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIcon.themeColor.withValues(alpha: 0.16),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: 20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.accent.withValues(alpha: 0.12),
                ),
              ),
            ),

            // Mini Phone Layout
            Column(
              children: [
                // Top Notch & Status Indicators
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '9:41',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            CupertinoIcons.wifi,
                            size: 10,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.battery_100,
                            size: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Home Screen Apps Row with NoteKar Icon live updating
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _homeAppItem(
                        label: 'Camera',
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            CupertinoIcons.camera_fill,
                            color: Color(0xFF8E8E93),
                            size: 20,
                          ),
                        ),
                      ),
                      _homeAppItem(
                        label: 'Music',
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            CupertinoIcons.music_note_2,
                            color: Color(0xFF8E8E93),
                            size: 20,
                          ),
                        ),
                      ),
                      // The Dynamic Live NoteKar Icon
                      _homeAppItem(
                        label: 'NoteKar',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: currentIcon.themeColor.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.asset(
                              currentIcon.asset,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        isHighlight: true,
                      ),
                      _homeAppItem(
                        label: 'Safari',
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            CupertinoIcons.compass_fill,
                            color: Color(0xFF8E8E93),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Mini Bottom Dock
                Container(
                  margin: const EdgeInsets.fromLTRB(28, 0, 28, 10),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeAppItem({
    required String label,
    required Widget child,
    bool isHighlight = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 46, height: 46, child: child),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: isHighlight ? Colors.white : const Color(0xFF8E8E93),
            fontSize: 9.5,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
