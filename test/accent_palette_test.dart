import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';

void main() {
  group('Accent palette', () {
    for (final theme in ['light', 'dark', 'amoled']) {
      test('$theme theme maps every offered accent to its own color', () {
        final colors = accentOptions
            .map((name) => accentColorFor(name, theme: theme))
            .toSet();

        expect(colors, hasLength(accentOptions.length));
        expect(
          accentOptions.every(
            (name) =>
                paletteFor(theme, accentName: name).accent ==
                accentColorFor(name, theme: theme),
          ),
          isTrue,
        );
      });
    }

    test('unknown accent safely falls back to blue', () {
      expect(
        accentColorFor('not-a-color', theme: 'dark'),
        const Color(0xFF007AFF),
      );
    });
  });
}
