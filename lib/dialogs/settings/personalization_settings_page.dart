import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/device_health_manager.dart';
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

class AccentSnappingScrollPhysics extends ScrollPhysics {
  final double itemExtent;

  const AccentSnappingScrollPhysics({required this.itemExtent, super.parent});

  @override
  AccentSnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return AccentSnappingScrollPhysics(
      itemExtent: itemExtent,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    double page = position.pixels / itemExtent;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return page.roundToDouble() * itemExtent;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final tolerance = toleranceFor(position);
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final target = _getTargetPixels(
      position,
      tolerance,
      velocity,
    ).clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() < tolerance.distance) {
      return null;
    }
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}

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

  late String _currentColorKey;
  Color _currentColor = const Color(0xFF007AFF);
  bool _isPouring = false;
  int? _lastFocalHapticIndex;

  final double _itemWidth = 78.0;

  @override
  void initState() {
    super.initState();
    _currentColorKey = widget.accentColor.isEmpty ? 'blue' : widget.accentColor;
    _currentColor = _findColor(_currentColorKey);
    final initialIndex = kAccentColorPalette.indexWhere(
      (c) => c.key == _currentColorKey,
    );
    _lastFocalHapticIndex = initialIndex != -1 ? initialIndex : 0;

    _scrollController = ScrollController();
    final isLowEnd = AdaptiveEngine().isLowEnd;
    final shouldThrottle = DeviceHealthManager.instance.shouldThrottle;
    _waveController = AnimationController(
      vsync: this,
      duration: isLowEnd
          ? const Duration(seconds: 10)
          : const Duration(milliseconds: 2200),
      value: (isLowEnd || shouldThrottle) ? 0.5 : 0.0,
    );
    if (!isLowEnd && !shouldThrottle) {
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

    _fillController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _isPouring = false);
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
    _scrollController.dispose();
    _waveController.dispose();
    _fillController.dispose();
    _drainController.dispose();
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

    return Stack(
      children: [
        // 1. Full-page fluid bucket canvas (fluid drop stream from top + bottom reservoir fill)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _waveController,
              _fillController,
              _drainController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _FullPageFluidBucketPainter(
                  fillLevel: _fillController.value,
                  wavePhase: _waveController.value,
                  fluidColor: _currentColor,
                  drainLevel: _drainController.value,
                  isPouring: _isPouring,
                  isLowEnd: AdaptiveEngine().isLowEnd,
                  isThrottled: DeviceHealthManager.instance.shouldThrottle,
                ),
              );
            },
          ),
        ),

        // 2. Foreground content
        Column(
          children: [
            const SizedBox(height: spacing12),

            // Active Color Pill Badge & Name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: p.surface2.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentColor,
                      boxShadow: [
                        BoxShadow(
                          color: _currentColor.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _findName(_currentColorKey).localized(context),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 16,
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
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SettingsPageDescription(
                p: p,
                text:
                    'Swipe horizontally to select an accent color. Fluid tint dynamically reflects across all dials, pills, and sovereign moments.'
                        .localized(context),
              ),
            ),

            const SizedBox(height: 24),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
            const SizedBox(height: 14),

            // Horizontal Color Carousel with Degraded Outward Sizing
            SizedBox(
              height: 110,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewportWidth = constraints.maxWidth;
                  final halfViewport = viewportWidth / 2;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Center Stationary Target Indicator Rings (Apple HIG Glow & Outer Frame)
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentColor.withValues(alpha: 0.18),
                            width: 1.0,
                          ),
                        ),
                      ),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentColor.withValues(alpha: 0.5),
                            width: 2.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _currentColor.withValues(alpha: 0.25),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // Horizontal List with Degraded Outward Sizing & Fluid Spring Snap
                      NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollUpdateNotification &&
                              _scrollController.hasClients) {
                            final currentScroll = _scrollController.offset;
                            final nearestIndex = (currentScroll / _itemWidth)
                                .round()
                                .clamp(0, kAccentColorPalette.length - 1);
                            if (nearestIndex != _lastFocalHapticIndex) {
                              _lastFocalHapticIndex = nearestIndex;
                              HapticFeedback.selectionClick();
                            }
                          }
                          if (notification is ScrollEndNotification &&
                              _scrollController.hasClients) {
                            final currentScroll = _scrollController.offset;
                            final nearestIndex = (currentScroll / _itemWidth)
                                .round()
                                .clamp(0, kAccentColorPalette.length - 1);
                            final newKey =
                                kAccentColorPalette[nearestIndex].key;
                            if (newKey != _currentColorKey) {
                              _triggerColorTransition(newKey);
                            }
                          }
                          return false;
                        },
                        child: AnimatedBuilder(
                          animation: _scrollController,
                          builder: (context, _) {
                            return ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: AccentSnappingScrollPhysics(
                                itemExtent: _itemWidth,
                                parent: const BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: halfViewport - (_itemWidth / 2),
                              ),
                              itemCount: kAccentColorPalette.length,
                              itemBuilder: (context, index) {
                                final item = kAccentColorPalette[index];
                                final itemCenterOffset = index * _itemWidth;
                                final currentScroll =
                                    _scrollController.hasClients
                                    ? _scrollController.offset
                                    : 0.0;
                                final distance =
                                    (itemCenterOffset - currentScroll).abs();
                                final step = distance / _itemWidth;

                                // Degraded sizing outward from center
                                double circleDiameter;
                                if (step <= 1.0) {
                                  circleDiameter = 66.0 - (66.0 - 48.0) * step;
                                } else if (step <= 2.0) {
                                  circleDiameter =
                                      48.0 - (48.0 - 36.0) * (step - 1.0);
                                } else {
                                  circleDiameter =
                                      (36.0 -
                                      (36.0 - 26.0) *
                                          ((step - 2.0).clamp(0.0, 1.0)));
                                }

                                // Degraded opacity outward from center
                                double opacity;
                                if (step <= 0.25) {
                                  opacity = 1.0;
                                } else if (step <= 1.0) {
                                  opacity =
                                      1.0 -
                                      (1.0 - 0.72) * ((step - 0.25) / 0.75);
                                } else {
                                  opacity =
                                      (0.72 -
                                              (0.72 - 0.28) *
                                                  ((step - 1.0) / 1.5))
                                          .clamp(0.24, 0.72);
                                }

                                final isSelected = item.key == _currentColorKey;

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
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
                                                    color: item.color
                                                        .withValues(
                                                          alpha: 0.55,
                                                        ),
                                                    blurRadius: 14,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child:
                                            isSelected && circleDiameter >= 44
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
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 52),
          ],
        ),
      ],
    );
  }
}

class _FullPageFluidBucketPainter extends CustomPainter {
  final double fillLevel;
  final double wavePhase;
  final Color fluidColor;
  final double drainLevel;
  final bool isPouring;
  final bool isLowEnd;
  final bool isThrottled;

  _FullPageFluidBucketPainter({
    required this.fillLevel,
    required this.wavePhase,
    required this.fluidColor,
    required this.drainLevel,
    required this.isPouring,
    this.isLowEnd = false,
    this.isThrottled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final effectiveFill = (fillLevel * (1.0 - drainLevel)).clamp(0.0, 1.0);

    // Subtle page-wide tint
    if (effectiveFill > 0.01) {
      final bgTint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fluidColor.withValues(alpha: 0.0),
            fluidColor.withValues(alpha: 0.05 * effectiveFill),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgTint);
    }

    // Bottom reservoir: filling bottom portion exactly few pixels down from circles
    const reservoirHeight = 52.0;
    final surfaceY = h - (reservoirHeight * effectiveFill);

    if (effectiveFill > 0.01) {
      final fluidPath = Path();
      fluidPath.moveTo(0, h);
      fluidPath.lineTo(0, surfaceY);

      if (isLowEnd || isThrottled) {
        fluidPath.lineTo(w, surfaceY);
      } else {
        final waveAmp =
            (3.5 * math.sin(effectiveFill * math.pi) * (isPouring ? 1.4 : 0.7))
                .clamp(0.0, 5.0);
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
            fluidColor.withValues(alpha: 0.65),
            fluidColor.withValues(alpha: 0.35),
          ],
        ).createShader(Rect.fromLTWH(0, surfaceY, w, h - surfaceY));
      canvas.drawPath(fluidPath, fluidPaint);

      // Subtle glow shader on top of fluid meniscus for Flagship / High-performance tier
      if (!isLowEnd &&
          !isThrottled &&
          DeviceHealthManager.instance.enableGlowShader) {
        final glowShaderPaint = Paint()
          ..color = fluidColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        canvas.drawPath(fluidPath, glowShaderPaint);
      }

      // Meniscus crest highlight line
      final crestPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      final crestPath = Path();
      crestPath.moveTo(0, surfaceY);
      if (isLowEnd || isThrottled) {
        crestPath.lineTo(w, surfaceY);
      } else {
        final waveAmp =
            (3.5 * math.sin(effectiveFill * math.pi) * (isPouring ? 1.4 : 0.7))
                .clamp(0.0, 5.0);
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

    // Top to bottom fluid drop pouring stream
    if (isPouring && fillLevel < 0.98) {
      final dropY = (surfaceY * fillLevel).clamp(0.0, surfaceY);
      final streamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fluidColor.withValues(alpha: 0.0),
            fluidColor.withValues(alpha: 0.85),
          ],
        ).createShader(Rect.fromLTWH(w / 2 - 2, 0, 4, dropY))
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, dropY), streamPaint);

      // Droplet head at dropY
      final dropPaint = Paint()..color = fluidColor;
      canvas.drawCircle(Offset(w / 2, dropY), 3.5, dropPaint);
      canvas.drawCircle(
        Offset(w / 2, dropY),
        5.5,
        Paint()..color = fluidColor.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FullPageFluidBucketPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.fluidColor != fluidColor ||
        oldDelegate.drainLevel != drainLevel ||
        oldDelegate.isPouring != isPouring ||
        oldDelegate.isLowEnd != isLowEnd ||
        oldDelegate.isThrottled != isThrottled;
  }
}
