import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryMeta {
  const CategoryMeta({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

CategoryMeta getCategoryMeta(String categoryName, Palette p) {
  final clean = categoryName.trim();
  final lower = clean.toLowerCase();

  final customIcon = CategoryService().getCategoryIcon(clean);
  final customColor = CategoryService().getCategoryColor(clean);

  IconData defaultIcon = Icons.label_outline_rounded;
  if (lower == 'work') {
    defaultIcon = Icons.work_outline_rounded;
  } else if (lower == 'deep focus' || lower == 'focus') {
    defaultIcon = Icons.bolt_rounded;
  } else if (lower == 'study') {
    defaultIcon = Icons.school_outlined;
  } else if (lower == 'health' || lower == 'fitness' || lower == 'gym') {
    defaultIcon = Icons.fitness_center_rounded;
  } else if (lower == 'play') {
    defaultIcon = Icons.sports_esports_outlined;
  } else if (lower == 'routine') {
    defaultIcon = Icons.repeat_rounded;
  } else if (lower == 'rest' || lower == 'recovery') {
    defaultIcon = Icons.spa_rounded;
  }

  final icon = customIcon ?? defaultIcon;

  if (customColor != null) {
    return CategoryMeta(name: clean, icon: icon, color: customColor);
  }

  if (lower == 'work') {
    return CategoryMeta(
      name: clean,
      icon: icon,
      color: const Color(0xFF007AFF),
    );
  } else if (lower == 'deep focus' || lower == 'focus') {
    return CategoryMeta(
      name: clean,
      icon: icon,
      color: const Color(0xFF5856D6),
    );
  } else if (lower == 'study') {
    return CategoryMeta(
      name: clean,
      icon: icon,
      color: const Color(0xFFAF52DE),
    );
  } else if (lower == 'health' || lower == 'fitness' || lower == 'gym') {
    return CategoryMeta(
      name: clean,
      icon: icon,
      color: const Color(0xFF34C759),
    );
  } else if (lower == 'play') {
    return CategoryMeta(
      name: clean,
      icon: icon,
      color: const Color(0xFFFF2D55),
    );
  } else if (lower == 'routine') {
    return CategoryMeta(
      name: clean,
      icon: icon,
      color: const Color(0xFF30B0C7),
    );
  } else if (lower == 'rest' || lower == 'recovery') {
    return CategoryMeta(
      name: clean,
      icon: icon,
      color: const Color(0xFF30B0C7),
    );
  }

  const customColors = [
    Color(0xFF007AFF),
    Color(0xFF5856D6),
    Color(0xFFAF52DE),
    Color(0xFFFF2D55),
    Color(0xFFFF9500),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFF00C7BE),
  ];
  final color = customColors[clean.hashCode.abs() % customColors.length];
  return CategoryMeta(name: clean, icon: icon, color: color);
}

class CategoryService {
  static final CategoryService _instance = CategoryService._internal();

  factory CategoryService() => _instance;

  CategoryService._internal();

  /// 7 canonical Apple HIG system palette colors
  static const List<Color> appleHigColors = [
    Color(0xFF007AFF), // Blue
    Color(0xFF5856D6), // Indigo
    Color(0xFFAF52DE), // Purple
    Color(0xFFFF2D55), // Pink
    Color(0xFFFF3B30), // Red
    Color(0xFFFF9500), // Orange
    Color(0xFF34C759), // Green
  ];

  static const List<String> defaultCategories = ['Work', 'Deep Focus'];
  static const String keyCustomCategories = 'notekar.custom_categories';
  static const String keyActiveCategory = 'notekar.active_category';
  static const String keyCustomCategoryColors =
      'notekar.custom_category_colors';
  static const String keyCustomCategoryIcons = 'notekar.custom_category_icons';

  final Map<String, int> _customColorCache = {};
  final Map<String, int> _customIconCache = {};
  bool _colorsLoaded = false;
  bool _iconsLoaded = false;

  /// Curated list of minimal Apple HIG style glyph icons
  static const List<IconData> minimalGlyphIcons = [
    Icons.label_outline_rounded,
    Icons.bolt_rounded,
    Icons.work_outline_rounded,
    Icons.school_outlined,
    Icons.fitness_center_rounded,
    Icons.spa_rounded,
    Icons.code_rounded,
    Icons.book_outlined,
    Icons.sports_esports_outlined,
    Icons.palette_outlined,
    Icons.music_note_rounded,
    Icons.flight_rounded,
    Icons.local_cafe_outlined,
    Icons.favorite_border_rounded,
    Icons.lightbulb_outline_rounded,
    Icons.explore_outlined,
    Icons.flag_outlined,
    Icons.timer_outlined,
  ];

  Future<SharedPreferences> _getPrefs({SharedPreferences? prefs}) async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  Future<void> ensureIconsLoaded({SharedPreferences? prefs}) async {
    if (_iconsLoaded && prefs == null) return;
    final p = await _getPrefs(prefs: prefs);
    final raw = p.getString(keyCustomCategoryIcons);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _customIconCache.clear();
        for (final entry in decoded.entries) {
          if (entry.value is int) {
            _customIconCache[entry.key.toLowerCase()] = entry.value as int;
          }
        }
      } catch (_) {}
    }
    _iconsLoaded = true;
  }

  Future<void> ensureColorsLoaded({SharedPreferences? prefs}) async {
    await ensureIconsLoaded(prefs: prefs);
    if (_colorsLoaded && prefs == null) return;
    final p = await _getPrefs(prefs: prefs);
    final raw = p.getString(keyCustomCategoryColors);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _customColorCache.clear();
        for (final entry in decoded.entries) {
          if (entry.value is int) {
            _customColorCache[entry.key.toLowerCase()] = entry.value as int;
          }
        }
      } catch (_) {}
    }
    _colorsLoaded = true;
  }

  Color? getCategoryColor(String name) {
    final lower = name.trim().toLowerCase();
    final val = _customColorCache[lower];
    if (val != null) {
      return Color(val);
    }
    return null;
  }

  IconData? getCategoryIcon(String name) {
    final lower = name.trim().toLowerCase();
    final val = _customIconCache[lower];
    if (val != null) {
      for (final ic in minimalGlyphIcons) {
        if (ic.codePoint == val) return ic;
      }
      return minimalGlyphIcons.first;
    }
    return null;
  }

  Future<void> setCategoryColor(
    String name,
    Color color, {
    SharedPreferences? prefs,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    _customColorCache[clean.toLowerCase()] = color.toARGB32();
    _colorsLoaded = true;
    final p = await _getPrefs(prefs: prefs);
    final raw = p.getString(keyCustomCategoryColors);
    Map<String, dynamic> map = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    map[clean.toLowerCase()] = color.toARGB32();
    await p.setString(keyCustomCategoryColors, jsonEncode(map));
  }

  Future<void> setCategoryIcon(
    String name,
    IconData icon, {
    SharedPreferences? prefs,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    _customIconCache[clean.toLowerCase()] = icon.codePoint;
    _iconsLoaded = true;
    final p = await _getPrefs(prefs: prefs);
    final raw = p.getString(keyCustomCategoryIcons);
    Map<String, dynamic> map = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    map[clean.toLowerCase()] = icon.codePoint;
    await p.setString(keyCustomCategoryIcons, jsonEncode(map));
  }

  Future<List<String>> getCategories({SharedPreferences? prefs}) async {
    await ensureColorsLoaded(prefs: prefs);
    final p = await _getPrefs(prefs: prefs);
    final stored = p.getStringList(keyCustomCategories) ?? [];
    final List<String> list = List.from(defaultCategories);
    for (final c in stored) {
      final clean = c.trim();
      if (clean.isNotEmpty &&
          !list.any((e) => e.toLowerCase() == clean.toLowerCase())) {
        list.add(clean);
      }
    }
    return list;
  }

  Future<bool> addCategory(
    String name, {
    Color? color,
    IconData? icon,
    SharedPreferences? prefs,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty || clean.length > 15) return false;
    final p = await _getPrefs(prefs: prefs);
    final all = await getCategories(prefs: p);
    if (all.any((e) => e.toLowerCase() == clean.toLowerCase())) {
      return false;
    }
    final stored = p.getStringList(keyCustomCategories) ?? [];
    stored.add(clean);
    await p.setStringList(keyCustomCategories, stored);
    if (color != null) {
      await setCategoryColor(clean, color, prefs: p);
    }
    if (icon != null) {
      await setCategoryIcon(clean, icon, prefs: p);
    }
    return true;
  }

  Future<bool> deleteCategory(String name, {SharedPreferences? prefs}) async {
    final clean = name.trim();
    // Default categories cannot be deleted
    if (defaultCategories.any((e) => e.toLowerCase() == clean.toLowerCase())) {
      return false;
    }
    final p = await _getPrefs(prefs: prefs);
    final stored = p.getStringList(keyCustomCategories) ?? [];
    final updated = stored
        .where((e) => e.trim().toLowerCase() != clean.toLowerCase())
        .toList();
    await p.setStringList(keyCustomCategories, updated);

    // Clean up cached color and icon
    _customColorCache.remove(clean.toLowerCase());
    _customIconCache.remove(clean.toLowerCase());
    final rawColors = p.getString(keyCustomCategoryColors);
    if (rawColors != null) {
      try {
        final map = jsonDecode(rawColors) as Map<String, dynamic>;
        map.remove(clean.toLowerCase());
        await p.setString(keyCustomCategoryColors, jsonEncode(map));
      } catch (_) {}
    }
    final rawIcons = p.getString(keyCustomCategoryIcons);
    if (rawIcons != null) {
      try {
        final map = jsonDecode(rawIcons) as Map<String, dynamic>;
        map.remove(clean.toLowerCase());
        await p.setString(keyCustomCategoryIcons, jsonEncode(map));
      } catch (_) {}
    }

    // If active category was deleted, reset to 'All'
    final active = await getActiveCategory(prefs: p);
    if (active.toLowerCase() == clean.toLowerCase()) {
      await setActiveCategory('All', prefs: p);
    }
    return true;
  }

  Future<String> getActiveCategory({SharedPreferences? prefs}) async {
    final p = await _getPrefs(prefs: prefs);
    final active = p.getString(keyActiveCategory) ?? 'All';
    return active.trim().isEmpty ? 'All' : active.trim();
  }

  Future<void> setActiveCategory(
    String category, {
    SharedPreferences? prefs,
  }) async {
    final p = await _getPrefs(prefs: prefs);
    final clean = category.trim().isEmpty ? 'All' : category.trim();
    await p.setString(keyActiveCategory, clean);
  }

  /// Extracts category for a given moment, checking `category` first then `#tag` in `note`.
  static String? extractCategory(Moment moment) {
    if (moment.category != null && moment.category!.trim().isNotEmpty) {
      return moment.category!.trim();
    }
    return extractHashtagCategory(moment.note);
  }

  /// Computes total tracked duration aggregated by category.
  static Map<String, Duration> computeCategoryDurations(
    List<TimelineItem> items,
  ) {
    final Map<String, int> durationMs = {};

    for (final item in items) {
      final cat = switch (item) {
        TimelineSessionItem s =>
          extractCategory(s.inMoment) ??
              (s.outMoment != null ? extractCategory(s.outMoment!) : null),
        TimelineSingleItem s => extractCategory(s.moment),
        TimelineGapItem _ => null,
      };

      if (cat == null && item is TimelineGapItem) continue;

      final categoryLabel = cat ?? 'General';
      final itemMs = switch (item) {
        TimelineSessionItem s => s.duration.inMilliseconds,
        TimelineSingleItem _ => const Duration(minutes: 15).inMilliseconds,
        TimelineGapItem _ => 0,
      };

      if (itemMs > 0) {
        durationMs[categoryLabel] = (durationMs[categoryLabel] ?? 0) + itemMs;
      }
    }

    return durationMs.map((k, v) => MapEntry(k, Duration(milliseconds: v)));
  }
}
