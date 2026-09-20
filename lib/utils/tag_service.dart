import 'package:notekar/models/moment.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized tag management service.
/// Single source of truth for custom tags, recent tags, and tag utilities.
class TagService {
  TagService._();

  static final TagService instance = TagService._();

  static const _customTagsKey = 'custom_note_tags';
  static const _recentTagsKey = 'notekar.recent_tags';
  static const _maxRecentTags = 10;
  static const _maxTagLength = 20;

  static const defaultTags = [
    '#work',
    '#study',
    '#play',
    '#health',
    '#focus',
    '#routine',
  ];

  List<String> _customTags = List.from(defaultTags);
  List<String> _recentTags = [];
  bool _loaded = false;

  /// Load custom and recent tags from SharedPreferences.
  /// Safe to call multiple times — only loads once.
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_customTagsKey);
    if (saved != null && saved.isNotEmpty) {
      _customTags = saved;
    }
    final recent = prefs.getStringList(_recentTagsKey);
    if (recent != null) {
      _recentTags = recent;
    }
    _loaded = true;
  }

  /// Force reload from disk (e.g. after background sync).
  Future<void> reload() async {
    _loaded = false;
    await load();
  }

  /// Get the user's custom tag palette.
  List<String> get customTags => List.unmodifiable(_customTags);

  /// Get recently used tags (most recent first), excluding any already in customTags.
  List<String> get recentTags {
    final customSet = _customTags.toSet();
    return _recentTags.where((t) => !customSet.contains(t)).toList();
  }

  /// Add a new custom tag to the palette.
  /// Returns true if the tag was added (not a duplicate).
  Future<bool> addCustomTag(String rawTag) async {
    final tag = normalize(rawTag);
    if (tag.isEmpty || _customTags.contains(tag)) return false;
    _customTags = [..._customTags, tag];
    await _saveCustomTags();
    return true;
  }

  /// Remove a custom tag from the palette.
  Future<void> removeCustomTag(String tag) async {
    _customTags = _customTags.where((t) => t != tag).toList();
    await _saveCustomTags();
  }

  /// Record a tag as recently used.
  Future<void> recordUsage(String rawTag) async {
    final tag = normalize(rawTag);
    if (tag.isEmpty) return;
    _recentTags = [
      tag,
      ..._recentTags.where((t) => t != tag),
    ].take(_maxRecentTags).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentTagsKey, _recentTags);
  }

  /// Record multiple tags as recently used.
  Future<void> recordUsages(List<String> tags) async {
    for (final tag in tags) {
      await recordUsage(tag);
    }
  }

  /// Normalize a tag string: lowercase, trim, remove leading #, clamp length.
  /// Returns the tag WITH the # prefix for display consistency.
  String normalize(String raw) {
    var tag = raw.trim();
    if (tag.startsWith('#')) tag = tag.substring(1);
    tag = tag.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    if (tag.isEmpty) return '';
    if (tag.length > _maxTagLength) tag = tag.substring(0, _maxTagLength);
    return '#$tag';
  }

  /// Extract the tag name without # prefix.
  static String stripHash(String tag) {
    return tag.startsWith('#') ? tag.substring(1) : tag;
  }

  /// Get all unique tags ever used across all entries.
  /// Merges custom tags + recent tags + inline hashtags from all moments.
  List<String> getAllKnownTags(List<Moment> entries) {
    final all = <String>{..._customTags, ..._recentTags};
    for (final entry in entries) {
      for (final tag in entry.effectiveTags) {
        all.add('#$tag');
      }
    }
    return all.toList()..sort();
  }

  /// Suggest tags matching a prefix (for autocomplete).
  /// Returns tags starting with the prefix, ordered by: recent → custom → all.
  List<String> suggestTags(String prefix, List<Moment> entries) {
    final normalizedPrefix = prefix.toLowerCase().replaceAll('#', '');
    if (normalizedPrefix.isEmpty) return [];

    final all = getAllKnownTags(entries);
    return all
        .where((tag) => TagService.stripHash(tag).startsWith(normalizedPrefix))
        .take(8)
        .toList();
  }

  Future<void> _saveCustomTags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_customTagsKey, _customTags);
  }
}
