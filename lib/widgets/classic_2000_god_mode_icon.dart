import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Classic 2000s Skeuomorphic God Mode Icon.
/// Features authentic Mac OS X Aqua glass sheen, metallic 3D beveled rim,
/// radial imperial golden specular gradient, and embossed retro seal.
class Classic2000GodModeIcon extends StatelessWidget {
  const Classic2000GodModeIcon({
    super.key,
    this.size = 40.0,
    this.showGlow = true,
  });

  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(size * 0.23);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          if (showGlow)
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.28),
              blurRadius: size * 0.35,
              spreadRadius: 1,
              offset: Offset(0, size * 0.08),
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: size * 0.18,
            offset: Offset(0, size * 0.09),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // 1. 3D Beveled Metallic Rim (Outer Gradient Ring)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF8D6), // High chrome glint
                    Color(0xFFE5B842), // Rich gold
                    Color(0xFF8B6414), // Deep bronze shadow
                    Color(0xFFFFDF7A), // Specular rim bounce
                  ],
                  stops: [0.0, 0.35, 0.75, 1.0],
                ),
              ),
            ),

            // 2. Inner Recessed Core with Deep Radial Gold Sheen
            Positioned(
              top: math.max(1.5, size * 0.045),
              bottom: math.max(1.5, size * 0.045),
              left: math.max(1.5, size * 0.045),
              right: math.max(1.5, size * 0.045),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.20),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.35, -0.4),
                      radius: 0.95,
                      colors: [
                        Color(0xFFFFF092), // Sunburst specular hot spot
                        Color(0xFFFFC72C), // Vibrant gold
                        Color(0xFFB8820B), // Satin mid-tone
                        Color(0xFF533703), // Deep burnished core
                      ],
                      stops: [0.0, 0.28, 0.68, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 3. Subtle Concentric Guilloché / Coin Rings
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _RetroCoinTexturePainter(size: size),
                        ),
                      ),

                      // 4. Embossed Retro Sovereign Seal / Monogram
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: size * 0.32,
                              color: const Color(0xFFFFF5B8),
                              shadows: const [
                                Shadow(
                                  color: Color(0xFF4A3000),
                                  offset: Offset(0, 1.2),
                                  blurRadius: 1.5,
                                ),
                                Shadow(
                                  color: Color(0xFFFFFEF0),
                                  offset: Offset(0, -0.6),
                                  blurRadius: 0.5,
                                ),
                              ],
                            ),
                            Text(
                              'GOD',
                              style: TextStyle(
                                color: const Color(0xFFFFFAEB),
                                fontSize: size * 0.17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                shadows: const [
                                  Shadow(
                                    color: Color(0xFF382302),
                                    offset: Offset(0, 1.2),
                                    blurRadius: 1.5,
                                  ),
                                  Shadow(
                                    color: Color(0xFFFFFEF0),
                                    offset: Offset(0, -0.6),
                                    blurRadius: 0.5,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 5. Authentic 2000s Aqua Glass Oval Gloss Sheen (Upper Half)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: size * 0.48,
                        child: CustomPaint(painter: _AquaGlassGlossPainter()),
                      ),

                      // 6. Bottom Ambient Rim Light (Bounce Reflection)
                      Positioned(
                        bottom: 0,
                        left: size * 0.1,
                        right: size * 0.1,
                        height: size * 0.16,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.bottomCenter,
                              radius: 0.9,
                              colors: [
                                Colors.white.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for classic Mac OS X Aqua gloss curve
class _AquaGlassGlossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.15,
      0,
      size.height * 0.65,
    );
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.62),
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fine coin milling ring texture painter
class _RetroCoinTexturePainter extends CustomPainter {
  final double size;

  _RetroCoinTexturePainter({required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = const Color(0xFFFFF092).withValues(alpha: 0.16);

    final radius1 = size.width * 0.36;
    final radius2 = size.width * 0.42;

    canvas.drawCircle(center, radius1, paint);
    canvas.drawCircle(center, radius2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
