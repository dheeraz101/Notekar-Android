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

  // Check custom persisted color first
  final customColor = CategoryService().getCategoryColor(clean);
  if (customColor != null) {
    IconData icon = Icons.label_outline_rounded;
    if (lower == 'work') {
      icon = Icons.work_outline_rounded;
    } else if (lower == 'deep focus' || lower == 'focus') {
      icon = Icons.bolt_rounded;
    } else if (lower == 'study') {
      icon = Icons.school_outlined;
    } else if (lower == 'health' || lower == 'fitness' || lower == 'gym') {
      icon = Icons.fitness_center_rounded;
    } else if (lower == 'play') {
      icon = Icons.sports_esports_outlined;
    } else if (lower == 'routine') {
      icon = Icons.repeat_rounded;
    }
    return CategoryMeta(name: clean, icon: icon, color: customColor);
  }

  if (lower == 'work') {
    return CategoryMeta(
      name: clean,
      icon: Icons.work_outline_rounded,
      color: const Color(0xFF007AFF),
    );
  } else if (lower == 'deep focus' || lower == 'focus') {
    return CategoryMeta(
      name: clean,
      icon: Icons.bolt_rounded,
      color: const Color(0xFF5856D6),
    );
  } else if (lower == 'study') {
    return CategoryMeta(
      name: clean,
      icon: Icons.school_outlined,
      color: const Color(0xFFAF52DE),
    );
  } else if (lower == 'health' || lower == 'fitness' || lower == 'gym') {
    return CategoryMeta(
      name: clean,
      icon: Icons.fitness_center_rounded,
      color: const Color(0xFF34C759),
    );
  } else if (lower == 'play') {
    return CategoryMeta(
      name: clean,
      icon: Icons.sports_esports_outlined,
      color: const Color(0xFFFF2D55),
    );
  } else if (lower == 'routine') {
    return CategoryMeta(
      name: clean,
      icon: Icons.repeat_rounded,
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
  return CategoryMeta(
    name: clean,
    icon: Icons.label_outline_rounded,
    color: color,
  );
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

  final Map<String, int> _customColorCache = {};
  bool _colorsLoaded = false;

  Future<SharedPreferences> _getPrefs({SharedPreferences? prefs}) async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  Future<void> ensureColorsLoaded({SharedPreferences? prefs}) async {
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
