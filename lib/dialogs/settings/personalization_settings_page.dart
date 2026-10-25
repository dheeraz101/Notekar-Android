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
  AccentColorItem(
    key: 'lavender',
    name: 'Lavender Mist',
    color: Color(0xFFBF9AF7),
  ),
  AccentColorItem(key: 'rose', name: 'Velvet Rose', color: Color(0xFFFF375F)),
  AccentColorItem(key: 'sage', name: 'Sage Meadow', color: Color(0xFF8BC69B)),
  AccentColorItem(key: 'olive', name: 'Olive Grove', color: Color(0xFFA6C750)),
  AccentColorItem(
    key: 'slate',
    name: 'Glacier Slate',
    color: Color(0xFFA5B7CA),
  ),
  AccentColorItem(key: 'brown', name: 'Cedar Wood', color: Color(0xFFC69C89)),
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

class _FishState {
  _FishState({
    required this.item,
    required this.y,
    required this.speed,
    required this.scale,
    required this.waggleSpeed,
    required this.wagglePhase,
    required this.bobPhase,
    this.x = 0.5,
  });

  final AccentColorItem item;
  double x; // 0.0 to 1.0 (horizontal relative coordinate in pond)
  double y; // vertical depth in pixels
  double speed; // normalized horizontal delta per second (signed)
  double scale;
  double waggleSpeed;
  double wagglePhase;
  double bobPhase;

  bool isDying = false;
  double deathProgress = 0.0;
}

class _WaterRipple {
  _WaterRipple({
    required this.origin,
    required this.color,
    this.progress = 0.0,
  });

  final Offset origin;
  final Color color;
  double progress;
}

class _AccentColorExperienceState extends State<_AccentColorExperience>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _colorTransitionController;
  StreamSubscription<AccelerometerEvent>? _motionSub;

  late String _currentColorKey;
  Color _currentColor = const Color(0xFF007AFF);
  Color _previousColor = const Color(0xFF007AFF);
  double _tiltX = 0.0;

  late List<_FishState> _fishList;
  final List<_WaterRipple> _ripples = [];
  int? _lastTickMs;

  @override
  void initState() {
    super.initState();
    _currentColorKey = widget.accentColor.isEmpty ? 'blue' : widget.accentColor;
    _currentColor = _findColor(_currentColorKey);
    _previousColor = _currentColor;

    _fishList = _initFish();

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

    _waveController.addListener(_onFrameTick);

    // Continuous natural water wave & fish swimming motion
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
  }

  List<_FishState> _initFish() {
    final list = <_FishState>[];
    for (int i = 0; i < kAccentColorPalette.length; i++) {
      final item = kAccentColorPalette[i];
      final isRight = i % 2 == 0;
      final speedMagnitude = 0.050 + (i % 5) * 0.012;
      final speed = isRight ? speedMagnitude : -speedMagnitude;
      final startX = (0.08 + (i * 0.19) % 0.84).clamp(0.06, 0.94);

      double depth;
      if (i < 6) {
        // Surface shallows (0..5)
        depth = 48.0 + (i * 20.0);
      } else if (i < 14) {
        // Mid-depth reservoir (6..13)
        depth = 180.0 + ((i - 6) * 34.0);
      } else {
        // Deeper waters (14..19)
        depth = 465.0 + ((i - 14) * 32.0);
      }

      list.add(
        _FishState(
          item: item,
          x: startX,
          y: depth,
          speed: speed,
          scale: 0.92 + (i % 4) * 0.08,
          waggleSpeed: 1.2 + (i % 3) * 0.35,
          wagglePhase: (i * 1.3) % (math.pi * 2),
          bobPhase: (i * 0.9) % (math.pi * 2),
        ),
      );
    }
    return list;
  }

  void _onFrameTick() {
    if (!mounted) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final dt = _lastTickMs == null
        ? 0.016
        : ((now - _lastTickMs!) / 1000.0).clamp(0.005, 0.05);
    _lastTickMs = now;

    // Update fish movement
    for (final fish in _fishList) {
      if (fish.isDying) {
        fish.deathProgress += dt * 1.6;
        if (fish.deathProgress >= 1.0) {
          // Reincarnate fish from the screen boundary
          fish.isDying = false;
          fish.deathProgress = 0.0;
          fish.x = fish.speed > 0 ? -0.15 : 1.15;
        }
        continue;
      }

      final tiltBonus = _tiltX * 0.035;
      fish.x += (fish.speed + tiltBonus) * dt;

      // Wrap-around naturally
      if (fish.speed > 0 && fish.x > 1.18) {
        fish.x = -0.18;
      } else if (fish.speed < 0 && fish.x < -0.18) {
        fish.x = 1.18;
      }
    }

    // Update ripples
    for (int i = _ripples.length - 1; i >= 0; i--) {
      _ripples[i].progress += dt * 1.8;
      if (_ripples[i].progress >= 1.0) {
        _ripples.removeAt(i);
      }
    }

    setState(() {});
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
    _waveController.removeListener(_onFrameTick);
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
  }

  void _handlePondTap(Offset localPos, Size pondSize) {
    final tappedX = localPos.dx;
    final tappedY = localPos.dy;

    _FishState? hitFish;
    double minDistance = 52.0;

    for (final fish in _fishList) {
      if (fish.isDying) continue;
      final fishPixelX = fish.x * pondSize.width;
      final fishPixelY =
          fish.y +
          math.sin(_waveController.value * 2 * math.pi + fish.bobPhase) * 4.0;
      final dist =
          (Offset(fishPixelX, fishPixelY) - Offset(tappedX, tappedY)).distance;
      if (dist < minDistance) {
        minDistance = dist;
        hitFish = fish;
      }
    }

    if (hitFish != null) {
      HapticFeedback.mediumImpact();
      hitFish.isDying = true;
      hitFish.deathProgress = 0.0;

      final fishPixelX = hitFish.x * pondSize.width;
      final fishPixelY =
          hitFish.y +
          math.sin(_waveController.value * 2 * math.pi + hitFish.bobPhase) *
              4.0;

      _ripples.add(
        _WaterRipple(
          origin: Offset(fishPixelX, fishPixelY),
          color: hitFish.item.color,
          progress: 0.0,
        ),
      );

      _triggerColorTransition(hitFish.item.key);
    } else {
      HapticFeedback.selectionClick();
      _ripples.add(
        _WaterRipple(
          origin: localPos,
          color: _currentColor.withValues(alpha: 0.6),
          progress: 0.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 1. Apple HIG Hero Top Page Header
          SettingsHeroHeader(
            p: p,
            icon: CupertinoIcons.drop_fill,
            title: 'Liquid Accent Sanctuary',
            subtitle:
                'Immerse yourself in NoteKar\'s living color pond. Tap any swimming fish to morph the fluid theme across your entire device experience.',
            accentColor: _currentColor,
          ),

          // 2. Active Color Pill Badge & Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: p.surface2.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.border.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: _currentColor.withValues(alpha: 0.14),
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

          const SizedBox(height: 16),

          // 3. Section Title & Instruction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TAP ANY FISH TO HARMONIZE ACCENT'.localized(context),
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${kAccentColorPalette.length} Living Species',
                  style: TextStyle(
                    color: p.text3,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SettingsPageDescription(
              p: p,
              text:
                  'Surface fish glide across the shallows. Scroll down to dive deeper into the reservoir to discover rare shades and bottom riverbed stones.'
                      .localized(context),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SettingsPageDescription(
              p: p,
              text:
                  'Riverbed stones retain their fixed hues for destructive actions, alerts, and system ink, ensuring sovereign contrast remains pristine across all accent choices.'
                      .localized(context),
            ),
          ),

          const SizedBox(height: 16),

          // 4. Living Aquarium Pond Canvas (Full side width & bottom space)
          Container(
            width: double.infinity,
            height: 800,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(
                  color: _currentColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: _currentColor.withValues(alpha: 0.15),
                  blurRadius: 32,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(27),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pondSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) =>
                        _handlePondTap(details.localPosition, pondSize),
                    child: CustomPaint(
                      size: pondSize,
                      painter: _PondAquariumPainter(
                        wavePhase: _waveController.value,
                        fluidColor: _currentColor,
                        previousColor: _previousColor,
                        colorProgress: _colorTransitionController.value,
                        tiltX: _tiltX,
                        selectedKey: _currentColorKey,
                        fishList: _fishList,
                        ripples: _ripples,
                        palette: p,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PondAquariumPainter extends CustomPainter {
  _PondAquariumPainter({
    required this.wavePhase,
    required this.fluidColor,
    required this.previousColor,
    required this.colorProgress,
    required this.tiltX,
    required this.selectedKey,
    required this.fishList,
    required this.ripples,
    required this.palette,
  });

  final double wavePhase;
  final Color fluidColor;
  final Color previousColor;
  final double colorProgress;
  final double tiltX;
  final String selectedKey;
  final List<_FishState> fishList;
  final List<_WaterRipple> ripples;
  final Palette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final effectiveColor =
        Color.lerp(previousColor, fluidColor, colorProgress) ?? fluidColor;

    // 1. Water Fluid Background Gradient
    final waterBg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          effectiveColor.withValues(alpha: 0.16),
          effectiveColor.withValues(alpha: 0.32),
          effectiveColor.withValues(alpha: 0.52),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), waterBg);

    // 2. Surface Water Meniscus & Light Waves
    final surfaceY = 22.0;
    final wavePath = Path()..moveTo(0, surfaceY);
    for (double x = 0; x <= w; x += 4) {
      final normX = x / w;
      final tilt = (normX - 0.5) * tiltX * 18.0;
      final wave =
          math.sin((normX * 3.0 * math.pi) + (wavePhase * 2 * math.pi)) * 4.0;
      wavePath.lineTo(x, surfaceY + tilt + wave);
    }
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(wavePath, wavePaint);

    // 3. Draw Water Shockwave Ripples
    for (final ripple in ripples) {
      final rippleRadius = ripple.progress * 48.0;
      final alpha = (1.0 - ripple.progress).clamp(0.0, 1.0);
      final rPaint = Paint()
        ..color = ripple.color.withValues(alpha: alpha * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - ripple.progress) * 2.8;
      canvas.drawCircle(ripple.origin, rippleRadius, rPaint);
      canvas.drawCircle(
        ripple.origin,
        rippleRadius * 0.55,
        rPaint..strokeWidth = 1.2,
      );
    }

    // 4. Draw Swimming Fish
    for (final fish in fishList) {
      final isSelected = fish.item.key == selectedKey;
      final fishPixelX = fish.x * w;
      final bob = math.sin(wavePhase * 2 * math.pi + fish.bobPhase) * 4.0;
      final fishPixelY = fish.y + bob;

      canvas.save();
      canvas.translate(fishPixelX, fishPixelY);

      if (fish.isDying) {
        // Draw burst bubble particles
        final pProgress = fish.deathProgress;
        final fade = (1.0 - pProgress).clamp(0.0, 1.0);
        final bubblePaint = Paint()
          ..color = fish.item.color.withValues(alpha: fade * 0.8)
          ..style = PaintingStyle.fill;

        for (int b = 0; b < 6; b++) {
          final bAngle = (b * (math.pi / 3)) + (pProgress * 2);
          final bDist = pProgress * 28.0;
          final bx = math.cos(bAngle) * bDist;
          final by = math.sin(bAngle) * bDist;
          canvas.drawCircle(
            Offset(bx, by),
            (1.0 - pProgress) * 4.0,
            bubblePaint,
          );
        }
      } else {
        // Direction & scale
        final isFacingRight = fish.speed >= 0;
        canvas.scale(isFacingRight ? fish.scale : -fish.scale, fish.scale);

        // Vector Tail Fin (Caudal) with Sinusoidal Waggle
        final waggle =
            math.sin(
              (wavePhase * 2 * math.pi * fish.waggleSpeed) + fish.wagglePhase,
            ) *
            0.36;

        canvas.save();
        canvas.translate(-20, 0);
        canvas.rotate(waggle);

        final tailPath = Path()
          ..moveTo(0, 0)
          ..cubicTo(-8, -11, -18, -14, -22, -11)
          ..cubicTo(-17, -4, -17, 4, -22, 11)
          ..cubicTo(-18, 14, -8, 11, 0, 0)
          ..close();

        final tailPaint = Paint()
          ..color = fish.item.color.withValues(alpha: 0.78)
          ..style = PaintingStyle.fill;
        canvas.drawPath(tailPath, tailPaint);
        canvas.restore();

        // Vector Dorsal Fin (Top)
        final dorsalPath = Path()
          ..moveTo(-6, -6)
          ..cubicTo(0, -14, 8, -13, 12, -5)
          ..close();
        final dorsalPaint = Paint()
          ..color = fish.item.color.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;
        canvas.drawPath(dorsalPath, dorsalPaint);

        // Vector Pectoral Fin (Belly)
        final pectoralPath = Path()
          ..moveTo(2, 4)
          ..cubicTo(6, 11, 10, 10, 12, 4)
          ..close();
        canvas.drawPath(pectoralPath, dorsalPaint);

        // Vector Body (Smooth Koi / Betta Spindle)
        final bodyPath = Path()
          ..moveTo(22, 0) // Mouth / Head
          ..cubicTo(12, -9, -10, -9, -20, -3) // Dorsal curve
          ..lineTo(-22, 0) // Tail base
          ..cubicTo(-10, 9, 12, 9, 22, 0) // Belly curve
          ..close();

        final bodyPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              fish.item.color,
              Color.lerp(fish.item.color, Colors.black, 0.18) ??
                  fish.item.color,
            ],
          ).createShader(const Rect.fromLTWH(-22, -9, 44, 18));
        canvas.drawPath(bodyPath, bodyPaint);

        // Eye
        canvas.drawCircle(
          const Offset(13, -3),
          2.2,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          const Offset(14, -3),
          1.1,
          Paint()..color = Colors.black,
        );

        // Subtle Dorsal Highlight
        final hlPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawArc(
          const Rect.fromLTWH(-14, -7, 28, 14),
          math.pi * 1.15,
          math.pi * 0.7,
          false,
          hlPaint,
        );

        // Golden Royal Crown atop fish head if selected
        if (isSelected) {
          canvas.save();
          // Position crown precisely atop forehead
          canvas.translate(14, -8);
          canvas.rotate(-0.16);

          // Subtle warm golden ambient aura
          final crownAura = Paint()
            ..color = const Color(0xFFFFD700).withValues(alpha: 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
          canvas.drawCircle(const Offset(0, -6), 9, crownAura);

          // Faceted 3-point imperial royal crown
          final crownPath = Path()
            ..moveTo(-8, 0)
            ..lineTo(8, 0)
            ..lineTo(7, -9)
            ..lineTo(3, -4)
            ..lineTo(0, -12)
            ..lineTo(-3, -4)
            ..lineTo(-7, -9)
            ..close();

          final crownShader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7A1), // diamond gold crest
              Color(0xFFFFD700), // imperial gold
              Color(0xFFC7920A), // antique gold band
            ],
            stops: [0.0, 0.55, 1.0],
          ).createShader(const Rect.fromLTWH(-8, -12, 16, 12));

          canvas.drawPath(crownPath, Paint()..shader = crownShader);

          // Crisp outline for Apple HIG sharpness
          final crownOutline = Paint()
            ..color = const Color(0xFF6B4D00)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8;
          canvas.drawPath(crownPath, crownOutline);

          // Headband divider line
          final bandPaint = Paint()
            ..color = const Color(0xFF916A00)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawLine(
            const Offset(-7.5, -0.6),
            const Offset(7.5, -0.6),
            bandPaint,
          );

          // Royal Jewels on peak tips:
          // Center diamond: brilliant sovereign white
          canvas.drawCircle(
            const Offset(0, -12),
            1.5,
            Paint()..color = Colors.white,
          );
          // Left ruby: crimson red
          canvas.drawCircle(
            const Offset(-7, -9),
            1.25,
            Paint()..color = const Color(0xFFFF2D55),
          );
          // Right emerald: vivid green
          canvas.drawCircle(
            const Offset(7, -9),
            1.25,
            Paint()..color = const Color(0xFF34C759),
          );

          // Headband center pearl
          canvas.drawCircle(
            const Offset(0, -2.0),
            1.0,
            Paint()..color = Colors.white.withValues(alpha: 0.9),
          );

          canvas.restore();
        }
      }

      canvas.restore();
    }

    // 5. Realistic Faceted Riverbed Stones at the Pond Bottom
    final riverbedY = h - 60.0;

    // Floor sediment layer with sandy gradient
    final sedimentPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: 0.42),
        ],
      ).createShader(Rect.fromLTWH(0, riverbedY - 25, w, 85));
    canvas.drawRect(Rect.fromLTWH(0, riverbedY - 25, w, 85), sedimentPaint);

    // Realistic faceted riverbed rocks using NoteKar's fixed invariant UI colors
    // (destructive red, warning orange, sovereign green, system grey, dark ink, white, gold)
    final fixedRocks = [
      (
        color: palette.red,
        xRatio: 0.11,
        width: 46.0,
        height: 27.0,
        polygon: [
          const Offset(-0.85, 0.25),
          const Offset(-0.65, -0.65),
          const Offset(-0.15, -0.95),
          const Offset(0.55, -0.75),
          const Offset(0.92, -0.15),
          const Offset(0.75, 0.85),
          const Offset(-0.25, 0.95),
          const Offset(-0.75, 0.70),
        ],
        topFacet: [
          const Offset(-0.65, -0.65),
          const Offset(-0.15, -0.95),
          const Offset(0.55, -0.75),
          const Offset(0.20, -0.20),
          const Offset(-0.35, -0.25),
        ],
        ridge: [
          const Offset(-0.35, -0.25),
          const Offset(0.20, -0.20),
          const Offset(0.75, 0.25),
        ],
      ),
      (
        color: palette.orange,
        xRatio: 0.24,
        width: 40.0,
        height: 23.0,
        polygon: [
          const Offset(-0.90, 0.30),
          const Offset(-0.55, -0.75),
          const Offset(0.20, -0.90),
          const Offset(0.85, -0.55),
          const Offset(0.95, 0.35),
          const Offset(0.45, 0.90),
          const Offset(-0.40, 0.85),
        ],
        topFacet: [
          const Offset(-0.55, -0.75),
          const Offset(0.20, -0.90),
          const Offset(0.85, -0.55),
          const Offset(0.35, -0.15),
          const Offset(-0.20, -0.20),
        ],
        ridge: [
          const Offset(-0.20, -0.20),
          const Offset(0.35, -0.15),
          const Offset(0.80, 0.10),
        ],
      ),
      (
        color: palette.green,
        xRatio: 0.37,
        width: 38.0,
        height: 22.0,
        polygon: [
          const Offset(-0.85, 0.20),
          const Offset(-0.45, -0.85),
          const Offset(0.35, -0.80),
          const Offset(0.90, -0.20),
          const Offset(0.80, 0.75),
          const Offset(-0.15, 0.95),
          const Offset(-0.75, 0.65),
        ],
        topFacet: [
          const Offset(-0.45, -0.85),
          const Offset(0.35, -0.80),
          const Offset(0.90, -0.20),
          const Offset(0.25, -0.10),
          const Offset(-0.15, -0.20),
        ],
        ridge: [
          const Offset(-0.15, -0.20),
          const Offset(0.25, -0.10),
          const Offset(0.65, 0.30),
        ],
      ),
      (
        color: palette.text3,
        xRatio: 0.50,
        width: 50.0,
        height: 26.0,
        polygon: [
          const Offset(-0.95, 0.15),
          const Offset(-0.70, -0.65),
          const Offset(-0.10, -0.90),
          const Offset(0.60, -0.70),
          const Offset(0.95, -0.10),
          const Offset(0.85, 0.70),
          const Offset(0.10, 0.95),
          const Offset(-0.60, 0.80),
        ],
        topFacet: [
          const Offset(-0.70, -0.65),
          const Offset(-0.10, -0.90),
          const Offset(0.60, -0.70),
          const Offset(0.15, -0.15),
          const Offset(-0.35, -0.20),
        ],
        ridge: [
          const Offset(-0.35, -0.20),
          const Offset(0.15, -0.15),
          const Offset(0.70, 0.20),
        ],
      ),
      (
        color: const Color(0xFF1C1C1E),
        xRatio: 0.63,
        width: 44.0,
        height: 24.0,
        polygon: [
          const Offset(-0.90, 0.25),
          const Offset(-0.50, -0.80),
          const Offset(0.25, -0.85),
          const Offset(0.85, -0.40),
          const Offset(0.92, 0.45),
          const Offset(0.35, 0.90),
          const Offset(-0.45, 0.85),
        ],
        topFacet: [
          const Offset(-0.50, -0.80),
          const Offset(0.25, -0.85),
          const Offset(0.85, -0.40),
          const Offset(0.25, -0.15),
          const Offset(-0.20, -0.25),
        ],
        ridge: [
          const Offset(-0.20, -0.25),
          const Offset(0.25, -0.15),
          const Offset(0.70, 0.25),
        ],
      ),
      (
        color: const Color(0xFFFFFFFF),
        xRatio: 0.76,
        width: 36.0,
        height: 21.0,
        polygon: [
          const Offset(-0.85, 0.20),
          const Offset(-0.40, -0.85),
          const Offset(0.30, -0.80),
          const Offset(0.85, -0.15),
          const Offset(0.75, 0.80),
          const Offset(-0.20, 0.90),
          const Offset(-0.70, 0.60),
        ],
        topFacet: [
          const Offset(-0.40, -0.85),
          const Offset(0.30, -0.80),
          const Offset(0.85, -0.15),
          const Offset(0.20, -0.10),
          const Offset(-0.15, -0.25),
        ],
        ridge: [
          const Offset(-0.15, -0.25),
          const Offset(0.20, -0.10),
          const Offset(0.60, 0.35),
        ],
      ),
      (
        color: const Color(0xFFFFD700),
        xRatio: 0.89,
        width: 40.0,
        height: 23.0,
        polygon: [
          const Offset(-0.85, 0.30),
          const Offset(-0.60, -0.70),
          const Offset(0.00, -0.90),
          const Offset(0.70, -0.65),
          const Offset(0.90, 0.20),
          const Offset(0.60, 0.85),
          const Offset(-0.30, 0.90),
        ],
        topFacet: [
          const Offset(-0.60, -0.70),
          const Offset(0.00, -0.90),
          const Offset(0.70, -0.65),
          const Offset(0.25, -0.15),
          const Offset(-0.25, -0.20),
        ],
        ridge: [
          const Offset(-0.25, -0.20),
          const Offset(0.25, -0.15),
          const Offset(0.65, 0.25),
        ],
      ),
    ];

    for (final rock in fixedRocks) {
      final stoneX = rock.xRatio * w;
      final stoneY = riverbedY + 12.0;
      final hw = rock.width / 2.0;
      final hh = rock.height / 2.0;

      // 1. Soft contact shadow on the bed
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(stoneX, stoneY + hh * 0.6),
          width: rock.width * 1.15,
          height: rock.height * 0.45,
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // 2. Main faceted body polygon
      final bodyPath = Path();
      for (int i = 0; i < rock.polygon.length; i++) {
        final pt = Offset(
          stoneX + rock.polygon[i].dx * hw,
          stoneY + rock.polygon[i].dy * hh,
        );
        if (i == 0) {
          bodyPath.moveTo(pt.dx, pt.dy);
        } else {
          bodyPath.lineTo(pt.dx, pt.dy);
        }
      }
      bodyPath.close();

      final bodyShader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(rock.color, Colors.white, 0.15) ?? rock.color,
              Color.lerp(rock.color, Colors.black, 0.32) ?? rock.color,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(stoneX, stoneY),
              width: rock.width,
              height: rock.height,
            ),
          );

      canvas.drawPath(bodyPath, Paint()..shader = bodyShader);

      // 3. Top-lit beveled light facet
      final facetPath = Path();
      for (int i = 0; i < rock.topFacet.length; i++) {
        final pt = Offset(
          stoneX + rock.topFacet[i].dx * hw,
          stoneY + rock.topFacet[i].dy * hh,
        );
        if (i == 0) {
          facetPath.moveTo(pt.dx, pt.dy);
        } else {
          facetPath.lineTo(pt.dx, pt.dy);
        }
      }
      facetPath.close();

      final facetPaint = Paint()
        ..color = Color.lerp(rock.color, Colors.white, 0.38) ?? rock.color
        ..style = PaintingStyle.fill;
      canvas.drawPath(facetPath, facetPaint);

      // 4. Subtle faceted mineral ridge seam
      final ridgePath = Path();
      for (int i = 0; i < rock.ridge.length; i++) {
        final pt = Offset(
          stoneX + rock.ridge[i].dx * hw,
          stoneY + rock.ridge[i].dy * hh,
        );
        if (i == 0) {
          ridgePath.moveTo(pt.dx, pt.dy);
        } else {
          ridgePath.lineTo(pt.dx, pt.dy);
        }
      }
      final ridgePaint = Paint()
        ..color = Color.lerp(rock.color, Colors.black, 0.42) ?? Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9;
      canvas.drawPath(ridgePath, ridgePaint);

      // 5. Crisp stone facet perimeter outline
      final edgePaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85;
      canvas.drawPath(bodyPath, edgePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PondAquariumPainter oldDelegate) {
    return true;
  }
}
