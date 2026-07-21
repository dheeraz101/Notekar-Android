import 'package:flutter/material.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/clock_face.dart';

class HomeClockSection extends StatelessWidget {
  const HomeClockSection({
    super.key,
    required this.p,
    required this.bottomInset,
    required this.savedPulseToken,
    required this.lastSavedType,
    required this.showSeconds,
    required this.highlightSeconds,
  });

  final Palette p;
  final double bottomInset;
  final int savedPulseToken;
  final String lastSavedType;
  final bool showSeconds;
  final bool highlightSeconds;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: RepaintBoundary(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 104 + bottomInset,
            ),
            child: LiveClockFace(
              p: p,
              pulseToken: savedPulseToken,
              pulseType: lastSavedType,
              showSeconds: showSeconds,
              highlightSeconds: highlightSeconds,
            ),
          ),
        ),
      ),
    );
  }
}
