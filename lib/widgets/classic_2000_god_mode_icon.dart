import 'package:flutter/material.dart';

/// God Mode Icon rendering user's custom Sovereign G asset with premium styling.
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
    final borderRadius = BorderRadius.circular(size * 0.22);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          if (showGlow)
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.35),
              blurRadius: size * 0.35,
              spreadRadius: 1,
              offset: Offset(0, size * 0.08),
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: size * 0.16,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          'app_icons/g.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
