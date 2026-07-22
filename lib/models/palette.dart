import 'package:flutter/material.dart';

class Palette {
  Palette({
    required this.name,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.text,
    required this.text2,
    required this.text3,
    required this.clock,
    required this.accent,
    required this.green,
    required this.orange,
    required this.red,
    required this.blue,
  });

  final String name;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color text;
  final Color text2;
  final Color text3;
  final Color clock;
  final Color accent;
  final Color green;
  final Color orange;
  final Color red;
  final Color blue;
}

Palette paletteFor(
  String theme, {
  bool highContrast = false,
  String accentName = 'blue',
}) {
  final accent = accentColorFor(accentName, theme: theme);
  if (theme == 'light') {
    return Palette(
      name: 'light',
      bg: const Color(0xFFF2F2F7), // Official iOS Inset Grouped Background
      surface: const Color(0xFFF2F2F7),
      surface2: const Color(0xFFFFFFFF), // Official iOS Card color
      surface3: const Color(0xFFE5E5EA),
      border: highContrast ? const Color(0xFFB8B8B8) : const Color(0xFFE4E4E4),
      text: const Color(0xFF000000),
      text2: highContrast
          ? const Color(0xFF202020)
          : const Color(0xFF3C3C43).withValues(alpha: 0.6),
      text3: highContrast
          ? const Color(0xFF5D5D5D)
          : const Color(0xFF3C3C43).withValues(alpha: 0.3),
      clock: highContrast ? const Color(0xFF8E8E93) : const Color(0xFFD1D1D6),
      accent: accent,
      green: const Color(0xFF248A3D),
      orange: const Color(0xFFC46A00),
      red: const Color(0xFFD70015),
      blue: const Color(0xFF007AFF),
    );
  }
  final amoled = theme == 'amoled';
  return Palette(
    name: theme,
    bg: amoled ? Colors.black : const Color(0xFF121212),
    surface: amoled ? Colors.black : const Color(0xFF121212),
    surface2: amoled ? const Color(0xFF0A0A0A) : const Color(0xFF1C1C1E),
    surface3: amoled ? const Color(0xFF1C1C1E) : const Color(0xFF2C2C2E),
    border: amoled
        ? (highContrast ? const Color(0xFF444444) : const Color(0xFF1F1F1F))
        : (highContrast ? const Color(0xFF777777) : const Color(0xFF343434)),
    text: const Color(0xFFFFFFFF),
    text2: highContrast
        ? const Color(0xFFE5E5E5)
        : const Color(0xFFEBEBF5).withValues(alpha: 0.6),
    text3: highContrast
        ? const Color(0xFFBDBDBD)
        : const Color(0xFFEBEBF5).withValues(alpha: 0.3),
    clock: amoled ? const Color(0xFF1F1F1F) : const Color(0xFF303030),
    accent: accent,
    green: amoled ? const Color(0xFF30D158) : const Color(0xFF34C759),
    orange: amoled ? const Color(0xFFFF9F0A) : const Color(0xFFFF9500),
    red: amoled ? const Color(0xFFFF453A) : const Color(0xFFFF3B30),
    blue: amoled ? const Color(0xFF0A84FF) : const Color(0xFF007AFF),
  );
}

Color accentColorFor(String name, {String theme = 'dark', bool light = false}) {
  final isLight = theme == 'light' || light;
  final isAmoled = theme == 'amoled';

  return switch (name) {
    'green' =>
      isLight
          ? const Color(0xFF248A3D)
          : (isAmoled ? const Color(0xFF30D158) : const Color(0xFF34C759)),
    'purple' =>
      isLight
          ? const Color(0xFF7E57C2)
          : (isAmoled ? const Color(0xFFBF5AF2) : const Color(0xFFAF52DE)),
    'pink' =>
      isLight
          ? const Color(0xFFC1466E)
          : (isAmoled ? const Color(0xFFFF6B8A) : const Color(0xFFFF2D55)),
    'orange' =>
      isLight
          ? const Color(0xFFC46A00)
          : (isAmoled ? const Color(0xFFFF9F0A) : const Color(0xFFFF9500)),
    'graphite' =>
      isLight
          ? const Color(0xFF5F6368)
          : (isAmoled ? const Color(0xFF98989D) : const Color(0xFF8E8E93)),

    'teal' =>
      isLight
          ? const Color(0xFF0A7C75)
          : (isAmoled ? const Color(0xFF40C8C0) : const Color(0xFF30B0C7)),
    'mint' =>
      isLight
          ? const Color(0xFF2E7D5B)
          : (isAmoled ? const Color(0xFF63D7A5) : const Color(0xFF00C7BE)),
    'cyan' =>
      isLight
          ? const Color(0xFF087EA4)
          : (isAmoled ? const Color(0xFF64D2FF) : const Color(0xFF32ADE6)),
    'indigo' =>
      isLight
          ? const Color(0xFF4F5BD5)
          : (isAmoled ? const Color(0xFF7D89FF) : const Color(0xFF5856D6)),
    'violet' =>
      isLight
          ? const Color(0xFF6D5BD0)
          : (isAmoled ? const Color(0xFFA78BFA) : const Color(0xFF8E44AD)),
    'rose' =>
      isLight
          ? const Color(0xFFB43B5E)
          : (isAmoled ? const Color(0xFFFF8FAB) : const Color(0xFFFF375F)),
    'amber' =>
      isLight
          ? const Color(0xFFB7791F)
          : (isAmoled ? const Color(0xFFFFC857) : const Color(0xFFFFCC00)),

    _ =>
      isLight
          ? const Color(0xFF007AFF)
          : (isAmoled ? const Color(0xFF0A84FF) : const Color(0xFF007AFF)),
  };
}
