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
}

Palette paletteFor(
  String theme, {
  bool highContrast = false,
  String accentName = 'blue',
}) {
  final accent = accentColorFor(accentName, light: theme == 'light');
  if (theme == 'light') {
    return Palette(
      name: 'light',
      bg: const Color(0xFFFFFFFF),
      surface: const Color(0xFFFFFFFF),
      surface2: const Color(0xFFF7F7F7),
      surface3: const Color(0xFFEDEDED),
      border: highContrast ? const Color(0xFFB8B8B8) : const Color(0xFFE4E4E4),
      text: const Color(0xFF0F0F0F),
      text2: highContrast ? const Color(0xFF303030) : const Color(0xFF606060),
      text3: highContrast ? const Color(0xFF5D5D5D) : const Color(0xFF9A9A9A),
      clock: const Color(0xFFE9E9E9),
      accent: accent,
      green: const Color(0xFF25D366),
      orange: const Color(0xFFFF9500),
      red: const Color(0xFFFF0033),
    );
  }
  final amoled = theme == 'amoled';
  return Palette(
    name: theme,
    bg: amoled ? Colors.black : const Color(0xFF0F0F0F),
    surface: amoled ? const Color(0xFF0C0C0C) : const Color(0xFF212121),
    surface2: amoled ? const Color(0xFF151515) : const Color(0xFF2A2A2A),
    surface3: amoled ? const Color(0xFF202020) : const Color(0xFF3F3F3F),
    border: amoled
        ? (highContrast ? const Color(0xFF323232) : const Color(0xFF1F1F1F))
        : (highContrast ? const Color(0xFF666666) : const Color(0xFF343434)),
    text: const Color(0xFFF1F1F1),
    text2: highContrast ? const Color(0xFFD8D8D8) : const Color(0xFFAAAAAA),
    text3: highContrast ? const Color(0xFFAFAFAF) : const Color(0xFF717171),
    clock: amoled ? const Color(0xFF1F1F1F) : const Color(0xFF303030),
    accent: accent,
    green: const Color(0xFF30D158),
    orange: const Color(0xFFFF9F0A),
    red: const Color(0xFFFF0033),
  );
}

Color accentColorFor(String name, {required bool light}) {
  return switch (name) {
    'green' => light ? const Color(0xFF248A3D) : const Color(0xFF30D158),
    'purple' => light ? const Color(0xFF7E57C2) : const Color(0xFFBF5AF2),
    'pink' => light ? const Color(0xFFC1466E) : const Color(0xFFFF6B8A),
    'orange' => light ? const Color(0xFFC46A00) : const Color(0xFFFF9F0A),
    'graphite' => light ? const Color(0xFF5F6368) : const Color(0xFF8E8E93),

    'teal' => light ? const Color(0xFF0A7C75) : const Color(0xFF40C8C0),
    'mint' => light ? const Color(0xFF2E7D5B) : const Color(0xFF63D7A5),
    'cyan' => light ? const Color(0xFF087EA4) : const Color(0xFF64D2FF),
    'indigo' => light ? const Color(0xFF4F5BD5) : const Color(0xFF7D89FF),
    'violet' => light ? const Color(0xFF6D5BD0) : const Color(0xFFA78BFA),
    'lavender' => light ? const Color(0xFF7B68A8) : const Color(0xFFC4B5FD),
    'rose' => light ? const Color(0xFFB43B5E) : const Color(0xFFFF8FAB),
    'coral' => light ? const Color(0xFFB85C4A) : const Color(0xFFFF8A7A),
    'amber' => light ? const Color(0xFFB7791F) : const Color(0xFFFFC857),
    'sand' => light ? const Color(0xFF8A6F3D) : const Color(0xFFD6B86A),
    'sage' => light ? const Color(0xFF5F7A61) : const Color(0xFFA3B18A),
    'olive' => light ? const Color(0xFF6B7A2F) : const Color(0xFFB6C667),
    'slate' => light ? const Color(0xFF52616B) : const Color(0xFF9BAAB3),
    'brown' => light ? const Color(0xFF795548) : const Color(0xFFB08A78),

    _ => light ? const Color(0xFF007AFF) : const Color(0xFF0A84FF),
  };
}
