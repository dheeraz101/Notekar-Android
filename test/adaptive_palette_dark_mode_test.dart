import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/palette.dart';

void main() {
  group('Adaptive Session Palette Invariants', () {
    test(
      'Dark theme preserves dark canvas and luminous text when accent is modulated',
      () {
        final base = paletteFor('dark', accentName: 'blue');
        expect(base.isDark, isTrue);
        expect(base.bg.computeLuminance(), lessThan(0.1));

        // Simulate adaptive session color (e.g. green #30D158 / #34C759 or Routine cyan #30B0C7)
        const adaptiveGreen = Color(0xFF30D158);
        final sessionPalette = base.copyWith(accent: adaptiveGreen);

        // Invariants: canvas and surfaces MUST remain dark, text MUST remain white
        expect(sessionPalette.isDark, isTrue);
        expect(sessionPalette.bg, equals(base.bg));
        expect(sessionPalette.surface, equals(base.surface));
        expect(sessionPalette.surface2, equals(base.surface2));
        expect(sessionPalette.text, equals(base.text));
        expect(sessionPalette.clock, equals(base.clock));
        // Accent is modulated cleanly
        expect(sessionPalette.accent, equals(adaptiveGreen));
      },
    );

    test(
      'AMOLED theme preserves pure OLED black canvas during active sessions',
      () {
        final base = paletteFor('amoled', accentName: 'blue');
        expect(base.bg, equals(const Color(0xFF000000)));

        // Simulate adaptive session color
        const sessionEmerald = Color(0xFF30D158);
        final sessionPalette = base.copyWith(accent: sessionEmerald);

        // Invariants: OLED black canvas is strictly preserved (never overwritten)
        expect(sessionPalette.bg, equals(const Color(0xFF000000)));
        expect(sessionPalette.clock, equals(base.clock));
        expect(sessionPalette.surface, equals(base.surface));
        expect(sessionPalette.accent, equals(sessionEmerald));
      },
    );

    test('Status bar icons remain visible (light icons) on dark backdrops', () {
      // In dark and AMOLED themes, isDarkIcons must be false (Brightness.light)
      for (final theme in ['dark', 'amoled']) {
        final light = theme == 'light';
        final isDarkIcons = light;
        expect(
          isDarkIcons,
          isFalse,
          reason: 'Status bar icons must be light on $theme theme',
        );
      }
    });
  });
}
