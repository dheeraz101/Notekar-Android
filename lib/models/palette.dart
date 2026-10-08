import 'package:flutter/material.dart';

class Palette extends ThemeExtension<Palette> {
  const Palette({
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

  @override
  Palette copyWith({
    String? name,
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? border,
    Color? text,
    Color? text2,
    Color? text3,
    Color? clock,
    Color? accent,
    Color? green,
    Color? orange,
    Color? red,
    Color? blue,
  }) {
    return Palette(
      name: name ?? this.name,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      border: border ?? this.border,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      clock: clock ?? this.clock,
      accent: accent ?? this.accent,
      green: green ?? this.green,
      orange: orange ?? this.orange,
      red: red ?? this.red,
      blue: blue ?? this.blue,
    );
  }

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) return this;
    return Palette(
      name: t < 0.5 ? name : other.name,
      bg: Color.lerp(bg, other.bg, t) ?? bg,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surface2: Color.lerp(surface2, other.surface2, t) ?? surface2,
      surface3: Color.lerp(surface3, other.surface3, t) ?? surface3,
      border: Color.lerp(border, other.border, t) ?? border,
      text: Color.lerp(text, other.text, t) ?? text,
      text2: Color.lerp(text2, other.text2, t) ?? text2,
      text3: Color.lerp(text3, other.text3, t) ?? text3,
      clock: Color.lerp(clock, other.clock, t) ?? clock,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      green: Color.lerp(green, other.green, t) ?? green,
      orange: Color.lerp(orange, other.orange, t) ?? orange,
      red: Color.lerp(red, other.red, t) ?? red,
      blue: Color.lerp(blue, other.blue, t) ?? blue,
    );
  }

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

  bool get isDark => name != 'light' && name != 'eink';
}

extension PaletteContextExtension on BuildContext {
  Palette get palette =>
      Theme.of(this).extension<Palette>() ?? paletteFor('dark');
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
      bg: const Color(0xFFF2F2F7),
      // Official iOS Grouped Modal Sheet Surface: #FFFFFF
      surface: const Color(0xFFFFFFFF),
      // Official iOS Card color
      surface2: const Color(0xFFFFFFFF),
      // Official iOS Tertiary Control / Fill: #E5E5EA
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
  if (theme == 'matrix') {
    return Palette(
      name: 'matrix',
      bg: const Color(0xFF000000),
      surface: const Color(0xFF000000),
      surface2: const Color(0xFF051105),
      surface3: const Color(0xFF0A220A),
      border: const Color(
        0xFF00FF41,
      ).withValues(alpha: highContrast ? 0.8 : 0.4),
      text: const Color(0xFF00FF41),
      text2: const Color(0xFF00DD38).withValues(alpha: 0.8),
      text3: const Color(0xFF008F24),
      clock: const Color(0xFF00FF41),
      accent: const Color(0xFF00FF41),
      green: const Color(0xFF00FF41),
      orange: const Color(0xFF39FF14),
      red: const Color(0xFFFF0055),
      blue: const Color(0xFF00FFCC),
    );
  }
  if (theme == 'eink') {
    return Palette(
      name: 'eink',
      bg: const Color(0xFFFFFFFF),
      surface: const Color(0xFFFFFFFF),
      surface2: const Color(0xFFF4F4F4),
      surface3: const Color(0xFFE5E5EA),
      border: const Color(0xFF000000),
      text: const Color(0xFF000000),
      text2: const Color(0xFF2A2A2A),
      text3: const Color(0xFF666666),
      clock: const Color(0xFF000000),
      accent: const Color(0xFF000000),
      green: const Color(0xFF222222),
      orange: const Color(0xFF444444),
      red: const Color(0xFF000000),
      blue: const Color(0xFF111111),
    );
  }
  final amoled = theme == 'amoled';
  return Palette(
    name: theme,
    // Apple Dark: Pure OLED Black canvas creates luminous contrast for glass surfaces
    bg: amoled ? Colors.black : const Color(0xFF000000),
    // Apple Secondary Grouped Background: #1C1C1E (Base for modal sheets, dialogs & pinned headers)
    surface: amoled ? const Color(0xFF0A0A0C) : const Color(0xFF1C1C1E),
    // Apple Tertiary Grouped Background: #2C2C2E (Cards, tiles & elevated containers)
    surface2: amoled ? const Color(0xFF141416) : const Color(0xFF2C2C2E),
    // Apple Quaternary Fill: #3A3A3C (Controls, input fills, action circles & selected highlights)
    surface3: amoled ? const Color(0xFF1E1E22) : const Color(0xFF3A3A3C),
    // Apple System Separator / Hairline Border: #48484A (crisp, visible contrast on surfaces 1, 2, and 3)
    border: amoled
        ? (highContrast ? const Color(0xFF666666) : const Color(0xFF333338))
        : (highContrast ? const Color(0xFF8E8E93) : const Color(0xFF48484A)),
    text: const Color(0xFFFFFFFF),
    // Apple Secondary Label: #8E8E93
    text2: highContrast ? const Color(0xFFE5E5E5) : const Color(0xFF8E8E93),
    // Apple Tertiary Label: #636366
    text3: highContrast ? const Color(0xFFBDBDBD) : const Color(0xFF636366),
    clock: amoled
        ? (highContrast ? const Color(0xFF8E8E93) : const Color(0xFF48484A))
        : (highContrast ? const Color(0xFF98989D) : const Color(0xFF5A5A5E)),
    accent: accent,
    green: amoled ? const Color(0xFF30D158) : const Color(0xFF34C759),
    orange: amoled ? const Color(0xFFFF9F0A) : const Color(0xFFFF9500),
    red: amoled ? const Color(0xFFFF453A) : const Color(0xFFFA2D48),
    // Apple Music Accent Red
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
    'lavender' =>
      isLight
          ? const Color(0xFF6B5AA6)
          : (isAmoled ? const Color(0xFFD0B0FF) : const Color(0xFFBF9AF7)),
    'rose' =>
      isLight
          ? const Color(0xFFB43B5E)
          : (isAmoled ? const Color(0xFFFF8FAB) : const Color(0xFFFF375F)),
    'coral' =>
      isLight
          ? const Color(0xFFC14F3B)
          : (isAmoled ? const Color(0xFFFF8A70) : const Color(0xFFFF7A59)),
    'amber' =>
      isLight
          ? const Color(0xFFB7791F)
          : (isAmoled ? const Color(0xFFFFC857) : const Color(0xFFFFCC00)),
    'sand' =>
      isLight
          ? const Color(0xFF8C6D3F)
          : (isAmoled ? const Color(0xFFE6CE91) : const Color(0xFFD6B779)),
    'sage' =>
      isLight
          ? const Color(0xFF497457)
          : (isAmoled ? const Color(0xFFA0D7AD) : const Color(0xFF8BC69B)),
    'olive' =>
      isLight
          ? const Color(0xFF63742B)
          : (isAmoled ? const Color(0xFFB9D971) : const Color(0xFFA6C750)),
    'slate' =>
      isLight
          ? const Color(0xFF526273)
          : (isAmoled ? const Color(0xFFB8C8D8) : const Color(0xFFA5B7CA)),
    'brown' =>
      isLight
          ? const Color(0xFF795548)
          : (isAmoled ? const Color(0xFFD7B1A1) : const Color(0xFFC69C89)),

    _ =>
      isLight
          ? const Color(0xFF007AFF)
          : (isAmoled ? const Color(0xFF0A84FF) : const Color(0xFF007AFF)),
  };
}
