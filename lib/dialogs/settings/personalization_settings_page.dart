import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/l10n_utils.dart';
import 'package:notekar/widgets/settings_widgets.dart';

class PersonalizationSettingsPage extends StatelessWidget {
  const PersonalizationSettingsPage({
    super.key,
    required this.p,
    required this.subCategory,
    required this.theme,
    required this.accentColor,
    required this.appIconStyle,
    required this.currentLocale,
    required this.reduceMotion,
    required this.enableTranslucency,
    required this.onLocaleChanged,
    required this.onAccentColorChanged,
    required this.onOpenCategory,
    this.onLearnMoreBeta,
  });

  final Palette p;
  final String subCategory; // 'Personalization', 'Accent Color'
  final String theme;
  final String accentColor;
  final String appIconStyle;
  final String currentLocale;
  final bool reduceMotion;
  final bool enableTranslucency;

  final ValueChanged<String> onLocaleChanged;
  final ValueChanged<String> onAccentColorChanged;
  final void Function(String category, {required String parent}) onOpenCategory;
  final VoidCallback? onLearnMoreBeta;

  @override
  Widget build(BuildContext context) {
    if (subCategory == 'Personalization') {
      return _buildPersonalization(context);
    } else if (subCategory == 'Accent Color') {
      return _buildAccentColor(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPersonalization(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: spacing8),
        SettingsGroup(
          p: p,
          insetDividers: true,
          children: [
            SettingsRow(
              p: p,
              icon: CupertinoIcons.moon,
              title: 'Display'.localized(context),
              status: theme.isEmpty
                  ? ''
                  : theme[0].toUpperCase() + theme.substring(1),
              color: p.accent,
              onTap: () => onOpenCategory('Display', parent: 'Personalization'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.paintbrush,
              title: 'Accent Color'.localized(context),
              status: accentColor.isEmpty
                  ? ''
                  : accentColor[0].toUpperCase() + accentColor.substring(1),
              color: p.accent,
              onTap: () =>
                  onOpenCategory('Accent Color', parent: 'Personalization'),
            ),
            SettingsRow(
              p: p,
              icon: CupertinoIcons.square_grid_2x2,
              title: 'App Icons'.localized(context),
              status: switch (appIconStyle) {
                'default' => 'Aurora',
                'black' => 'Midnight',
                'blue' => 'Sapphire',
                'gold' => 'Imperial',
                'green' => 'Emerald',
                'orange' => 'Sunset',
                'red' => 'Crimson',
                'purple' => 'Amethyst',
                _ => 'Aurora',
              }.localized(context),
              color: p.orange,
              onTap: () =>
                  onOpenCategory('App Icons', parent: 'Personalization'),
            ),
          ],
        ),
        SettingsPageDescription(
          p: p,
          text:
              'These settings refine the interface aesthetic and do not modify your saved data.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }

  Widget _buildAccentColor(BuildContext context) {
    return _AccentColorExperience(
      p: p,
      accentColor: accentColor,
      reduceMotion: reduceMotion,
      enableTranslucency: enableTranslucency,
      onAccentColorChanged: onAccentColorChanged,
    );
  }
}

class AccentColorItem {
  final String key;
  final String name;
  final Color color;

  const AccentColorItem({
    required this.key,
    required this.name,
    required this.color,
  });
}

const List<AccentColorItem> kAccentColorPalette = [
  AccentColorItem(key: 'blue', name: 'Sapphire', color: Color(0xFF007AFF)),
  AccentColorItem(key: 'green', name: 'Emerald', color: Color(0xFF34C759)),
  AccentColorItem(key: 'purple', name: 'Amethyst', color: Color(0xFFAF52DE)),
  AccentColorItem(key: 'pink', name: 'Rose', color: Color(0xFFFF2D55)),
  AccentColorItem(key: 'orange', name: 'Amber', color: Color(0xFFFF9500)),
  AccentColorItem(key: 'teal', name: 'Aquamarine', color: Color(0xFF30B0C7)),
  AccentColorItem(key: 'cyan', name: 'Cyan', color: Color(0xFF32ADE6)),
  AccentColorItem(key: 'indigo', name: 'Indigo', color: Color(0xFF5856D6)),
  AccentColorItem(
    key: 'violet',
    name: 'Royal Violet',
    color: Color(0xFF7D52DE),
  ),
  AccentColorItem(key: 'coral', name: 'Coral Sunset', color: Color(0xFFFF6482)),
  AccentColorItem(key: 'amber', name: 'Solar Amber', color: Color(0xFFFFB340)),
  AccentColorItem(key: 'sand', name: 'Golden Sand', color: Color(0xFFD4A373)),
  AccentColorItem(key: 'mint', name: 'Spring Mint', color: Color(0xFF63E6BE)),
  AccentColorItem(
    key: 'graphite',
    name: 'Onyx Slate',
    color: Color(0xFF8E8E93),
  ),
];

class _AccentColorExperience extends StatefulWidget {
  const _AccentColorExperience({
    required this.p,
    required this.accentColor,
    required this.reduceMotion,
    required this.enableTranslucency,
    required this.onAccentColorChanged,
  });

  final Palette p;
  final String accentColor;
  final bool reduceMotion;
  final bool enableTranslucency;
  final ValueChanged<String> onAccentColorChanged;

  @override
  State<_AccentColorExperience> createState() => _AccentColorExperienceState();
}

class _AccentColorExperienceState extends State<_AccentColorExperience>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _waveController;
  late AnimationController _fillController;
  late AnimationController _drainController;
  late AnimationController _toastController;

  Timer? _toastDismissTimer;
  String _toastMessage = '';
  late String _currentColorKey;
  Color _currentColor = const Color(0xFF007AFF);
  bool _isPouring = false;

  int _selectedIndex = 0;
  final double _itemWidth = 78.0;

  @override
  void initState() {
    super.initState();
    _currentColorKey = widget.accentColor.isEmpty ? 'blue' : widget.accentColor;
    _currentColor = _findColor(_currentColorKey);
    final initialIndex = kAccentColorPalette.indexWhere(
      (c) => c.key == _currentColorKey,
    );
    _selectedIndex = initialIndex != -1 ? initialIndex : 0;

    _scrollController = ScrollController();
    final isLowEnd = AdaptiveEngine().isLowEnd;
    _waveController = AnimationController(
      vsync: this,
      duration: isLowEnd
          ? const Duration(seconds: 10)
          : const Duration(milliseconds: 2200),
      value: isLowEnd ? 0.5 : 0.0,
    );
    if (!isLowEnd) {
      _waveController.repeat();
    }

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: 1.0,
    );

    _drainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 0.0,
    );

    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    _fillController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _isPouring = false);
        _showToast('Accent color applied: ${_findName(_currentColorKey)}');
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToColor(_currentColorKey, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant _AccentColorExperience oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.accentColor != oldWidget.accentColor &&
        widget.accentColor.isNotEmpty &&
        widget.accentColor != _currentColorKey) {
      _triggerColorTransition(widget.accentColor);
    }
  }

  @override
  void dispose() {
    _toastDismissTimer?.cancel();
    _scrollController.dispose();
    _waveController.dispose();
    _fillController.dispose();
    _drainController.dispose();
    _toastController.dispose();
    super.dispose();
  }

  Color _findColor(String key) {
    return kAccentColorPalette
        .firstWhere(
          (c) => c.key == key,
          orElse: () => kAccentColorPalette.first,
        )
        .color;
  }

  String _findName(String key) {
    return kAccentColorPalette
        .firstWhere(
          (c) => c.key == key,
          orElse: () => kAccentColorPalette.first,
        )
        .name;
  }

  void _scrollToColor(String key, {bool animate = true}) {
    final index = kAccentColorPalette.indexWhere((c) => c.key == key);
    if (index == -1 || !_scrollController.hasClients) return;
    _selectedIndex = index;

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

  void _applyColorFromScroll(String newKey) {
    if (newKey == _currentColorKey) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentColorKey = newKey;
      _currentColor = _findColor(newKey);
      _isPouring = false;
    });
    widget.onAccentColorChanged(newKey);
  }

  void _showToast(String message) {
    _toastDismissTimer?.cancel();
    setState(() => _toastMessage = message);
    _toastController.forward(from: 0.0);
    _toastDismissTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) _toastController.reverse();
    });
  }

  void _triggerColorTransition(String newKey) {
    if (newKey == _currentColorKey) return;

    HapticFeedback.lightImpact();
    setState(() {
      _currentColorKey = newKey;
      _currentColor = _findColor(newKey);
      _isPouring = true;
    });

    // 1. Drain previous fluid out bottom
    _drainController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      _drainController.reset();
      // 2. Pour new fluid in from top spout
      _fillController.forward(from: 0.0);
    });

    widget.onAccentColorChanged(newKey);
    _scrollToColor(newKey);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return Column(
      children: [
        const SizedBox(height: spacing8),

        // 1. Fluid Container Interactive Preview Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: p.border.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: _currentColor.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top iOS Dynamic Pill Toast
              SizedBox(
                height: 32,
                child: AnimatedBuilder(
                  animation: _toastController,
                  builder: (context, _) {
                    final t = _toastController.value;
                    if (t <= 0.001) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: p.surface3.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.drop_fill,
                                  size: 10,
                                  color: _currentColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'FLUID MENISCUS RESERVOIR'.localized(context),
                                  style: TextStyle(
                                    color: p.text3,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return Transform.translate(
                      offset: Offset(0, (1.0 - t) * -8),
                      child: Opacity(
                        opacity: t,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _currentColor,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: _currentColor.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _toastMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Fluid Container Beaker
              Center(
                child: SizedBox(
                  width: 130,
                  height: 140,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _waveController,
                      _fillController,
                      _drainController,
                    ]),
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _LiquidWavePainter(
                          fillLevel: _fillController.value,
                          wavePhase: _waveController.value,
                          fluidColor: _currentColor,
                          drainLevel: _drainController.value,
                          isPouring: _isPouring,
                          isLowEnd: AdaptiveEngine().isLowEnd,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Active Accent Name Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _findName(_currentColorKey).localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('•', style: TextStyle(color: p.text3, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text(
                    'Active'.localized(context),
                    style: TextStyle(
                      color: p.text2,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SWIPE OR TAP TO APPLY ACCENT'.localized(context),
                style: TextStyle(
                  color: p.text3,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${kAccentColorPalette.length} Shades',
                style: TextStyle(
                  color: p.text3,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Optical Scaling Horizontal Color Carousel with Real-Time Snapping Auto-Select
        SizedBox(
          height: 108,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth;
              final halfViewport = viewportWidth / 2;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Center Stationary Target Indicator Rings (Apple HIG Glow & Outer Frame)
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentColor.withValues(alpha: 0.16),
                        width: 1.0,
                      ),
                    ),
                  ),
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentColor.withValues(alpha: 0.45),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _currentColor.withValues(alpha: 0.20),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Horizontal List with Distance-Based Scaling & Real-Time Auto-Select
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (_scrollController.hasClients) {
                        final currentScroll = _scrollController.offset;
                        final nearestIndex = (currentScroll / _itemWidth)
                            .round()
                            .clamp(0, kAccentColorPalette.length - 1);
                        if (nearestIndex != _selectedIndex) {
                          _selectedIndex = nearestIndex;
                          final newKey = kAccentColorPalette[nearestIndex].key;
                          _applyColorFromScroll(newKey);
                        }
                      }
                      if (notification is ScrollEndNotification &&
                          _scrollController.hasClients) {
                        final currentScroll = _scrollController.offset;
                        final nearestIndex = (currentScroll / _itemWidth)
                            .round()
                            .clamp(0, kAccentColorPalette.length - 1);
                        final snapOffset = nearestIndex * _itemWidth;
                        if ((currentScroll - snapOffset).abs() > 0.5) {
                          Future.microtask(() {
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                snapOffset,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          });
                        }
                      }
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
                      itemCount: kAccentColorPalette.length,
                      itemBuilder: (context, index) {
                        final item = kAccentColorPalette[index];
                        final itemCenterOffset = index * _itemWidth;
                        final currentScroll = _scrollController.hasClients
                            ? _scrollController.offset
                            : 0.0;
                        final distance = (itemCenterOffset - currentScroll)
                            .abs();

                        // Distance-based optical scaling & dimming
                        final scaleFactor = (1.0 - (distance / 140.0)).clamp(
                          0.38,
                          1.0,
                        );
                        final circleDiameter =
                            30.0 + 44.0 * ((scaleFactor - 0.38) / 0.62);
                        final opacity = (distance < 18.0)
                            ? 1.0
                            : (0.22 + 0.38 * ((scaleFactor - 0.38) / 0.62))
                                  .clamp(0.22, 0.65);
                        final isSelected = item.key == _currentColorKey;

                        return GestureDetector(
                          onTap: () {
                            _triggerColorTransition(item.key);
                          },
                          child: Container(
                            width: _itemWidth,
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: opacity,
                              child: Container(
                                width: circleDiameter,
                                height: circleDiameter,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item.color,
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        )
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: item.color.withValues(
                                              alpha: 0.5,
                                            ),
                                            blurRadius: 14,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      )
                                    : null,
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

        const SizedBox(height: 16),
        SettingsPageDescription(
          p: p,
          text:
              'Select an accent color for buttons and fluid interface highlights.'
                  .localized(context),
        ),
        const SizedBox(height: spacing48),
      ],
    );
  }
}

class _LiquidWavePainter extends CustomPainter {
  final double fillLevel;
  final double wavePhase;
  final Color fluidColor;
  final double drainLevel;
  final bool isPouring;
  final bool isLowEnd;

  _LiquidWavePainter({
    required this.fillLevel,
    required this.wavePhase,
    required this.fluidColor,
    required this.drainLevel,
    required this.isPouring,
    this.isLowEnd = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glass beaker container rrect
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(24),
    );

    canvas.save();
    canvas.clipRRect(rrect);

    // Dark beaker inner background
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.12);
    canvas.drawRRect(rrect, bgPaint);

    final effectiveFill = (fillLevel * (1.0 - drainLevel)).clamp(0.0, 1.0);
    final surfaceY = h - (h - 18) * effectiveFill;

    if (effectiveFill > 0.01) {
      final fluidPath = Path();
      fluidPath.moveTo(0, h);
      fluidPath.lineTo(0, surfaceY);

      if (isLowEnd) {
        fluidPath.lineTo(w, surfaceY);
      } else {
        final waveAmp =
            (4.5 * math.sin(effectiveFill * math.pi) * (isPouring ? 1.6 : 0.8))
                .clamp(0.0, 7.5);
        for (double x = 0; x <= w; x += 4) {
          final normX = x / w;
          final waveY =
              surfaceY +
              math.sin((normX * 2 * math.pi) + (wavePhase * 2 * math.pi)) *
                  waveAmp;
          fluidPath.lineTo(x, waveY);
        }
      }

      fluidPath.lineTo(w, h);
      fluidPath.close();

      final fluidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fluidColor.withValues(alpha: 0.90),
            fluidColor.withValues(alpha: 0.65),
          ],
        ).createShader(Rect.fromLTWH(0, surfaceY, w, h - surfaceY));
      canvas.drawPath(fluidPath, fluidPaint);

      // Meniscus wave crest highlight
      final crestPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      final crestPath = Path();
      crestPath.moveTo(0, surfaceY);
      if (isLowEnd) {
        crestPath.lineTo(w, surfaceY);
      } else {
        final waveAmp =
            (4.5 * math.sin(effectiveFill * math.pi) * (isPouring ? 1.6 : 0.8))
                .clamp(0.0, 7.5);
        for (double x = 0; x <= w; x += 4) {
          final normX = x / w;
          final waveY =
              surfaceY +
              math.sin((normX * 2 * math.pi) + (wavePhase * 2 * math.pi)) *
                  waveAmp;
          crestPath.lineTo(x, waveY);
        }
      }
      canvas.drawPath(crestPath, crestPaint);
    }

    // Top spout pouring droplet stream when filling
    if (isPouring && fillLevel < 0.96) {
      final streamPaint = Paint()
        ..color = fluidColor
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(w / 2, 6), Offset(w / 2, surfaceY), streamPaint);

      final dropletPaint = Paint()..color = fluidColor.withValues(alpha: 0.8);
      canvas.drawCircle(Offset(w / 2 - 8, surfaceY - 6), 2.2, dropletPaint);
      canvas.drawCircle(Offset(w / 2 + 7, surfaceY - 8), 2.6, dropletPaint);
    }

    // Glass reflection diagonal highlight
    final glassShine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.16),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(rrect, glassShine);

    canvas.restore();

    // Container glass border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidWavePainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.fluidColor != fluidColor ||
        oldDelegate.drainLevel != drainLevel ||
        oldDelegate.isPouring != isPouring ||
        oldDelegate.isLowEnd != isLowEnd;
  }
}
