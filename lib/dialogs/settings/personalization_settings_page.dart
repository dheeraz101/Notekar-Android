import 'dart:async';
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
import 'package:sensors_plus/sensors_plus.dart';

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

class FluidDynamicsParams {
  final double reservoirHeight;
  final double waveAmplitude;
  final double waveFrequency;
  final double waveSpeed;
  final double tiltResponse;

  const FluidDynamicsParams({
    this.reservoirHeight = 360.0,
    this.waveAmplitude = 6.0,
    this.waveFrequency = 1.8,
    this.waveSpeed = 1.0,
    this.tiltResponse = 22.0,
  });

  FluidDynamicsParams copyWith({
    double? reservoirHeight,
    double? waveAmplitude,
    double? waveFrequency,
    double? waveSpeed,
    double? tiltResponse,
  }) {
    return FluidDynamicsParams(
      reservoirHeight: reservoirHeight ?? this.reservoirHeight,
      waveAmplitude: waveAmplitude ?? this.waveAmplitude,
      waveFrequency: waveFrequency ?? this.waveFrequency,
      waveSpeed: waveSpeed ?? this.waveSpeed,
      tiltResponse: tiltResponse ?? this.tiltResponse,
    );
  }
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
    // Apple iOS UIPickerView momentum projection
    final projectedPixels = position.pixels + velocity * 0.14;
    final page = (projectedPixels / itemExtent).roundToDouble();
    return page * itemExtent;
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
      const SpringDescription(mass: 1.0, stiffness: 160.0, damping: 20.0),
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
  late AnimationController _colorTransitionController;
  StreamSubscription<AccelerometerEvent>? _motionSub;

  late String _currentColorKey;
  Color _currentColor = const Color(0xFF007AFF);
  Color _previousColor = const Color(0xFF007AFF);
  double _tiltX = 0.0;
  int? _lastFocalHapticIndex;

  final double _itemWidth = 46.0;

  @override
  void initState() {
    super.initState();
    _currentColorKey = widget.accentColor.isEmpty ? 'blue' : widget.accentColor;
    _currentColor = _findColor(_currentColorKey);
    _previousColor = _currentColor;
    final initialIndex = kAccentColorPalette.indexWhere(
      (c) => c.key == _currentColorKey,
    );
    _lastFocalHapticIndex = initialIndex != -1 ? initialIndex : 0;

    _scrollController = ScrollController();
    final isLowEnd =
        AdaptiveEngine().isLowEnd ||
        DeviceHealthManager.instance.shouldThrottle;
    _waveController = AnimationController(
      vsync: this,
      duration: isLowEnd
          ? const Duration(seconds: 8)
          : const Duration(milliseconds: 2400),
      value: 0.0,
    );
    // Continuous natural water wave motion
    if (!widget.reduceMotion) {
      _waveController.repeat();
    }

    _colorTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );

    // Responsive lateral fluid motion from phone tilt/movement
    if (!widget.reduceMotion) {
      try {
        _motionSub =
            accelerometerEventStream(
              samplingPeriod: const Duration(milliseconds: 50),
            ).listen(
              (event) {
                if (!mounted) return;
                final targetX = (event.x / 9.8).clamp(-1.0, 1.0);
                final nextTilt = _tiltX + (targetX - _tiltX) * 0.25;
                if ((nextTilt - _tiltX).abs() > 0.005) {
                  setState(() => _tiltX = nextTilt);
                }
              },
              onError: (_) {
                _motionSub?.cancel();
                _motionSub = null;
              },
            );
      } catch (_) {}
    }

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
    _motionSub?.cancel();
    _motionSub = null;
    _scrollController.dispose();
    _waveController.dispose();
    _colorTransitionController.dispose();
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
      _previousColor =
          Color.lerp(
            _previousColor,
            _currentColor,
            _colorTransitionController.value,
          ) ??
          _currentColor;
      _currentColorKey = newKey;
      _currentColor = _findColor(newKey);
    });

    _colorTransitionController.forward(from: 0.0);
    widget.onAccentColorChanged(newKey);
    _scrollToColor(newKey);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    final screenH = MediaQuery.sizeOf(context).height;
    final bottomReservoirHeight = (screenH - 340.0).clamp(380.0, 1000.0);

    return Stack(
      children: [
        // 1. Full-page fluid bucket canvas (continuous water waves + lateral phone tilt response)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _waveController,
              _colorTransitionController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _FullPageFluidBucketPainter(
                  wavePhase: _waveController.value,
                  fluidColor: _currentColor,
                  previousColor: _previousColor,
                  colorProgress: _colorTransitionController.value,
                  tiltX: _tiltX,
                  params: const FluidDynamicsParams(),
                  surfaceTopOffset: 308.0,
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

            // Horizontal Color Carousel with Natural Proportional Sizing
            SizedBox(
              height: 126,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewportWidth = constraints.maxWidth;
                  final halfViewport = viewportWidth / 2;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Center Stationary Target Indicator Rings (Apple HIG Glow & Outer Frame)
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentColor.withValues(alpha: 0.18),
                            width: 1.0,
                          ),
                        ),
                      ),
                      Container(
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentColor.withValues(alpha: 0.5),
                            width: 2.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _currentColor.withValues(alpha: 0.28),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // Horizontal List with Natural Focal Scale & Fluid Spring Snap
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

                                // Natural sizing: Center is prominent (84), neighbors scale down cleanly (32, 22, 14)
                                double circleDiameter;
                                if (step <= 1.0) {
                                  circleDiameter = 84.0 - (84.0 - 32.0) * step;
                                } else if (step <= 2.0) {
                                  circleDiameter =
                                      32.0 - (32.0 - 22.0) * (step - 1.0);
                                } else {
                                  circleDiameter =
                                      (22.0 -
                                      (22.0 - 14.0) *
                                          ((step - 2.0).clamp(0.0, 1.0)));
                                }

                                // Natural opacity scale outward from focal center
                                double opacity;
                                if (step <= 0.25) {
                                  opacity = 1.0;
                                } else if (step <= 1.0) {
                                  opacity =
                                      1.0 -
                                      (1.0 - 0.70) * ((step - 0.25) / 0.75);
                                } else {
                                  opacity =
                                      (0.70 -
                                              (0.70 - 0.25) *
                                                  ((step - 1.0) / 1.5))
                                          .clamp(0.22, 0.70);
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
                                            isSelected && circleDiameter >= 56
                                            ? const Icon(
                                                Icons.check,
                                                size: 24,
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

            // Move this bar slightly down from the circle group
            const SizedBox(height: 22),

            // Use the whole bottom as a filler for color fluid
            SizedBox(height: bottomReservoirHeight),
          ],
        ),
      ],
    );
  }
}

class _FullPageFluidBucketPainter extends CustomPainter {
  final double wavePhase;
  final Color fluidColor;
  final Color previousColor;
  final double colorProgress;
  final double tiltX;
  final FluidDynamicsParams params;
  final bool isLowEnd;
  final bool isThrottled;
  final double? surfaceTopOffset;

  _FullPageFluidBucketPainter({
    required this.wavePhase,
    required this.fluidColor,
    required this.previousColor,
    required this.colorProgress,
    this.tiltX = 0.0,
    this.params = const FluidDynamicsParams(),
    this.isLowEnd = false,
    this.isThrottled = false,
    this.surfaceTopOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final effectiveColor =
        Color.lerp(previousColor, fluidColor, colorProgress) ?? fluidColor;

    // Subtle page-wide tint
    final bgTint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          effectiveColor.withValues(alpha: 0.0),
          effectiveColor.withValues(alpha: 0.06),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgTint);

    // Bottom reservoir: filling whole bottom area, moved slightly down from circles
    final surfaceY = surfaceTopOffset != null
        ? surfaceTopOffset!.clamp(0.0, h)
        : (h - params.reservoirHeight).clamp(0.0, h);

    final fluidPath = Path();
    fluidPath.moveTo(0, h);
    fluidPath.lineTo(0, surfaceY);

    if (isLowEnd || isThrottled) {
      fluidPath.lineTo(w, surfaceY);
    } else {
      for (double x = 0; x <= w; x += 3) {
        final normX = x / w;
        final tiltOffset = (normX - 0.5) * tiltX * params.tiltResponse;
        final primaryWave =
            math.sin(
              (normX * params.waveFrequency * 2 * math.pi) +
                  (wavePhase * 2 * math.pi),
            ) *
            params.waveAmplitude;
        final secondaryHarmonic =
            math.sin(
              (normX * params.waveFrequency * 4 * math.pi) -
                  (wavePhase * 3 * math.pi),
            ) *
            (params.waveAmplitude * 0.35);
        final waveY = surfaceY + tiltOffset + primaryWave + secondaryHarmonic;
        fluidPath.lineTo(x, waveY);
      }
    }
    fluidPath.lineTo(w, h);
    fluidPath.close();

    final fluidPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              effectiveColor.withValues(alpha: 0.65),
              effectiveColor.withValues(alpha: 0.35),
            ],
          ).createShader(
            Rect.fromLTWH(0, surfaceY, w, math.max(1.0, h - surfaceY)),
          );
    canvas.drawPath(fluidPath, fluidPaint);

    // Subtle glow shader on top of fluid meniscus
    if (!isLowEnd &&
        !isThrottled &&
        DeviceHealthManager.instance.enableGlowShader) {
      final glowShaderPaint = Paint()
        ..color = effectiveColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawPath(fluidPath, glowShaderPaint);
    }

    // Meniscus crest highlight line
    final crestPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final crestPath = Path();
    crestPath.moveTo(0, surfaceY);
    if (isLowEnd || isThrottled) {
      crestPath.lineTo(w, surfaceY);
    } else {
      for (double x = 0; x <= w; x += 3) {
        final normX = x / w;
        final tiltOffset = (normX - 0.5) * tiltX * params.tiltResponse;
        final primaryWave =
            math.sin(
              (normX * params.waveFrequency * 2 * math.pi) +
                  (wavePhase * 2 * math.pi),
            ) *
            params.waveAmplitude;
        final secondaryHarmonic =
            math.sin(
              (normX * params.waveFrequency * 4 * math.pi) -
                  (wavePhase * 3 * math.pi),
            ) *
            (params.waveAmplitude * 0.35);
        final waveY = surfaceY + tiltOffset + primaryWave + secondaryHarmonic;
        crestPath.lineTo(x, waveY);
      }
    }
    canvas.drawPath(crestPath, crestPaint);
  }

  @override
  bool shouldRepaint(covariant _FullPageFluidBucketPainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.fluidColor != fluidColor ||
        oldDelegate.previousColor != previousColor ||
        oldDelegate.colorProgress != colorProgress ||
        oldDelegate.tiltX != tiltX ||
        oldDelegate.params != params ||
        oldDelegate.isLowEnd != isLowEnd ||
        oldDelegate.isThrottled != isThrottled ||
        oldDelegate.surfaceTopOffset != surfaceTopOffset;
  }
}
