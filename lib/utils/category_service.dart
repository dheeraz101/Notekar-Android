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

  static const List<String> defaultCategories = ['Work', 'Deep Focus'];
  static const String keyCustomCategories = 'notekar.custom_categories';
  static const String keyActiveCategory = 'notekar.active_category';

  Future<SharedPreferences> _getPrefs({SharedPreferences? prefs}) async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  Future<List<String>> getCategories({SharedPreferences? prefs}) async {
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

  Future<bool> addCategory(String name, {SharedPreferences? prefs}) async {
    final clean = name.trim();
    if (clean.isEmpty || clean.length > 30) return false;
    final p = await _getPrefs(prefs: prefs);
    final all = await getCategories(prefs: p);
    if (all.any((e) => e.toLowerCase() == clean.toLowerCase())) {
      return false;
    }
    final stored = p.getStringList(keyCustomCategories) ?? [];
    stored.add(clean);
    await p.setStringList(keyCustomCategories, stored);
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
      };

      final categoryLabel = cat ?? 'General';
      final itemMs = switch (item) {
        TimelineSessionItem s => s.duration.inMilliseconds,
        TimelineSingleItem _ => const Duration(minutes: 15).inMilliseconds,
      };

      durationMs[categoryLabel] = (durationMs[categoryLabel] ?? 0) + itemMs;
    }

    return durationMs.map((k, v) => MapEntry(k, Duration(milliseconds: v)));
  }
}
