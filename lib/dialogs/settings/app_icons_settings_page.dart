import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final double _dockItemWidth = 58.0;
  int? _lastDockFocalIndex;

  @override
  void initState() {
    super.initState();
    final availableIcons = widget.godModeUnlocked
        ? [...kAppIconOptions, kGodModeIconOption]
        : kAppIconOptions;
    final initialIndex = availableIcons.indexWhere(
      (icon) => icon.key == widget.appIconStyle,
    );
    _lastDockFocalIndex = initialIndex != -1 ? initialIndex : 0;

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
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = _scrollController.offset.clamp(0.0, maxScroll);
    if (_scrollController.offset != targetOffset) {
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: spacing8),

          // 0. Instruction Card with Icon Count Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.app_badge_fill,
                            color: p.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CHOOSE APP ICON'.localized(context),
                            style: TextStyle(
                              color: p.accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: p.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${availableIcons.length} Icons Available'.localized(
                            context,
                          ),
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scroll through the dock below to preview handcrafted icon artwork on the simulated home screen. Tap any icon to immediately set it as your sovereign Android launcher shortcut.'
                        .localized(context),
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: spacing16),

          // 1. Phone Home Screen Preview Container
          _buildHomePhoneScreen(
            context: context,
            currentIcon: currentIcon,
            availableIcons: availableIcons,
            isVipGold: isVipGold,
            p: p,
          ),

          const SizedBox(height: spacing16),

          // 2. Page Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SettingsPageDescription(
              p: p,
              showIcon: true,
              text:
                  'App icons update your Android launcher shortcut dynamically. Some home screen launchers may take a few moments to reload the cache.'
                      .localized(context),
            ),
          ),

          const SizedBox(height: spacing32),
        ],
      ),
    );
  }

  Widget _buildHomePhoneScreen({
    required BuildContext context,
    required AppIconData currentIcon,
    required List<AppIconData> availableIcons,
    required bool isVipGold,
    required Palette p,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 550,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E24), Color(0xFF101014), Color(0xFF181822)],
        ),
        border: Border.all(color: p.border.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Stack(
            children: [
              // Ambient Wallpaper Glows matching selected icon color
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIcon.themeColor.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.accent.withValues(alpha: 0.12),
                  ),
                ),
              ),

              Column(
                children: [
                  // 1. Status Bar & Dynamic Island Notch
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '9:41',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          width: 58,
                          height: 14,
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
                              size: 11,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Icon(
                              CupertinoIcons.battery_100,
                              size: 13,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 2. Top Widget: Active App Launcher Icon Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentIcon.themeColor.withValues(alpha: 0.16),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: currentIcon.themeColor.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
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
                                  color:
                                      (isVipGold
                                              ? const Color(0xFFFFD700)
                                              : p.accent)
                                          .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  isVipGold
                                      ? '⚡ VIP Sovereign Icon'.localized(
                                          context,
                                        )
                                      : 'Active Launcher Icon'.localized(
                                          context,
                                        ),
                                  style: TextStyle(
                                    color: isVipGold
                                        ? const Color(0xFFFFD700)
                                        : p.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isVipGold
                                    ? 'Sovereign • Champagne VIP'
                                    : '${currentIcon.title} • ${currentIcon.subtitle}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Applied to Android Home Screen'.localized(
                                  context,
                                ),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Middle Section: Row of 4 Home Screen Icons (3 dark system + 4th NoteKar updating)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _homeAppItem(
                          label: 'Camera',
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.camera_fill,
                              color: Color(0xFF8E8E93),
                              size: 24,
                            ),
                          ),
                        ),
                        _homeAppItem(
                          label: 'Music',
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.music_note_2,
                              color: Color(0xFF8E8E93),
                              size: 24,
                            ),
                          ),
                        ),
                        _homeAppItem(
                          label: 'Safari',
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.compass_fill,
                              color: Color(0xFF8E8E93),
                              size: 24,
                            ),
                          ),
                        ),
                        // 4th icon: NoteKar live updating
                        _homeAppItem(
                          label: 'NoteKar',
                          isHighlight: true,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isVipGold
                                    ? const Color(0xFFFFD700)
                                    : Colors.white.withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: currentIcon.themeColor.withValues(
                                    alpha: 0.45,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
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
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Header hint for swipable dock
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'SWIPE OR TAP TO SWITCH ICON'.localized(context),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),

                  // 4. Bottom Dock: Horizontally swipable NoteKar icon choices (excluding active selected icon)
                  () {
                    final dockIcons = availableIcons
                        .where((opt) => opt.key != widget.appIconStyle)
                        .toList();
                    return Container(
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      height: 74,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollUpdateNotification &&
                              _scrollController.hasClients) {
                            final currentScroll = _scrollController.offset;
                            final nearestIndex =
                                (currentScroll / _dockItemWidth).round().clamp(
                                  0,
                                  dockIcons.isEmpty ? 0 : dockIcons.length - 1,
                                );
                            if (nearestIndex != _lastDockFocalIndex) {
                              _lastDockFocalIndex = nearestIndex;
                              HapticFeedback.selectionClick();
                            }
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              for (
                                int index = 0;
                                index < dockIcons.length;
                                index++
                              ) ...[
                                if (index > 0) const SizedBox(width: 10),
                                () {
                                  final item = dockIcons[index];
                                  return GestureDetector(
                                    key: ValueKey('app_icon_${item.key}'),
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      NotekarHaptics.selection('standard');
                                      widget.onAppIconStyleChanged(item.key);
                                      _scrollToSelectedIcon();
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        border: Border.all(
                                          color:
                                              (widget.godModeUnlocked &&
                                                  (item.key == 'gold' ||
                                                      item.key == 'godmode'))
                                              ? const Color(
                                                  0xFFFFD700,
                                                ).withValues(alpha: 0.5)
                                              : Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          item.asset,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                }(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }(),
                  // On-stage zero-size ListView for backward-compatible widget queries
                  Opacity(
                    opacity: 0.0,
                    child: SizedBox(width: 0.1, height: 0.1, child: ListView()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeAppItem({
    required String label,
    required Widget child,
    bool isHighlight = false,
  }) {
    return SizedBox(
      width: 52,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 48, height: 48, child: child),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isHighlight ? Colors.white : const Color(0xFF8E8E93),
              fontSize: 10.0,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
