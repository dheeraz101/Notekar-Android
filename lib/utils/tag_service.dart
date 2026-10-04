import 'dart:convert';
import 'dart:isolate';

import 'package:notekar/models/activity_tag.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized tag management service.
/// Single source of truth for 15 Activity Quick Tags with glyph icons,
/// custom user tags, recent usages, and tag utilities.
class TagService {
  TagService._();

  static final TagService instance = TagService._();

  static const _activityTagsKey = 'notekar_activity_tags_v2';
  static const _customTagsKey = 'custom_note_tags';
  static const _recentTagsKey = 'notekar.recent_tags';
  static const _maxRecentTags = 10;
  static const _maxTagLength = 20;

  List<ActivityTag> _activityTags = List.from(ActivityTag.default15Tags);
  List<String> _recentTags = [];
  bool _loaded = false;

  /// Load activity tags and recent tags from SharedPreferences.
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    final rawJson = prefs.getString(_activityTagsKey);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        _activityTags = decoded
            .map((item) => ActivityTag.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _activityTags = List.from(ActivityTag.default15Tags);
      }
    } else {
      final legacy = prefs.getStringList(_customTagsKey);
      if (legacy != null && legacy.isNotEmpty) {
        _activityTags = [];
        for (final t in legacy) {
          final clean = t.replaceFirst('#', '').trim();
          if (clean.isNotEmpty) {
            _activityTags.add(
              ActivityTag(
                id: 'legacy_${clean.toLowerCase()}',
                label: t,
                iconCodePoint: 0xf56b,
                isCustom: true,
              ),
            );
          }
        }
        for (final def in ActivityTag.default15Tags) {
          if (!_activityTags.any(
            (t) => t.label.toLowerCase() == def.label.toLowerCase(),
          )) {
            _activityTags.add(def);
          }
        }
      } else {
        _activityTags = List.from(ActivityTag.default15Tags);
      }
      await _saveActivityTags();
    }

    final recent = prefs.getStringList(_recentTagsKey);
    if (recent != null) {
      _recentTags = recent;
    }
    _loaded = true;
  }

  /// Reset internal state for test environments.
  void resetForTesting() {
    _loaded = false;
    _activityTags = List.from(ActivityTag.default15Tags);
    _recentTags = [];
  }

  /// Force reload from disk.
  Future<void> reload() async {
    _loaded = false;
    await load();
  }

  /// Get the configured Activity Quick Tags.
  List<ActivityTag> get activityTags => List.unmodifiable(_activityTags);

  /// Get legacy list of string hashtags (e.g. '#walking', '#gym').
  List<String> get customTags => _activityTags.map((t) => t.hashtag).toList();

  /// Get recently used tags (most recent first).
  List<String> get recentTags {
    final customSet = customTags.toSet();
    return _recentTags.where((t) => !customSet.contains(t)).toList();
  }

  /// Add a new Activity Quick Tag.
  Future<bool> addActivityTag(ActivityTag tag) async {
    if (_activityTags.any(
      (t) => t.id == tag.id || t.label.toLowerCase() == tag.label.toLowerCase(),
    )) {
      return false;
    }
    _activityTags = [..._activityTags, tag];
    await _saveActivityTags();
    return true;
  }

  /// Update an existing Activity Quick Tag.
  Future<bool> updateActivityTag(ActivityTag updated) async {
    final idx = _activityTags.indexWhere((t) => t.id == updated.id);
    if (idx < 0) return false;
    _activityTags[idx] = updated;
    await _saveActivityTags();
    return true;
  }

  /// Remove an Activity Quick Tag by ID.
  Future<void> removeActivityTag(String id) async {
    _activityTags = _activityTags.where((t) => t.id != id).toList();
    await _saveActivityTags();
  }

  /// Reorder tags in palette.
  Future<void> reorderActivityTags(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _activityTags.removeAt(oldIndex);
    _activityTags.insert(newIndex, item);
    await _saveActivityTags();
  }

  /// Reset to standard 15 research-backed activity tags.
  Future<void> resetToDefaultTags() async {
    _activityTags = List.from(ActivityTag.default15Tags);
    await _saveActivityTags();
  }

  /// Backward-compatible method to add a raw string tag.
  Future<bool> addCustomTag(String rawTag) async {
    final clean = normalize(rawTag);
    if (clean.isEmpty) return false;
    final label = stripHash(clean);
    return addActivityTag(
      ActivityTag(
        id: 'tag_${DateTime.now().millisecondsSinceEpoch}',
        label: label[0].toUpperCase() + label.substring(1),
        iconCodePoint: 0xf56b, // default glyph
        isCustom: true,
      ),
    );
  }

  /// Backward-compatible method to remove a tag by string.
  Future<void> removeCustomTag(String tag) async {
    final clean = normalize(tag);
    final target = _activityTags.firstWhere(
      (t) => t.hashtag.toLowerCase() == clean.toLowerCase(),
      orElse: () => _activityTags.first,
    );
    await removeActivityTag(target.id);
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

  /// Get all unique tags asynchronously on a background isolate for large entry sets.
  Future<List<String>> getAllKnownTagsAsync(List<Moment> entries) {
    if (entries.length < 50) {
      return Future.value(getAllKnownTags(entries));
    }
    final seedTags = <String>{...customTags, ..._recentTags};
    return Isolate.run(() {
      final all = Set<String>.from(seedTags);
      for (final entry in entries) {
        for (final tag in entry.effectiveTags) {
          all.add('#$tag');
        }
      }
      return all.toList()..sort();
    });
  }

  /// Get all unique tags ever used across all entries.
  List<String> getAllKnownTags(List<Moment> entries) {
    final all = <String>{...customTags, ..._recentTags};
    for (final entry in entries) {
      for (final tag in entry.effectiveTags) {
        all.add('#$tag');
      }
    }
    return all.toList()..sort();
  }

  /// Suggest tags matching a prefix (for autocomplete).
  List<String> suggestTags(String prefix, List<Moment> entries) {
    final normalizedPrefix = prefix.toLowerCase().replaceAll('#', '');
    if (normalizedPrefix.isEmpty) return [];

    final all = getAllKnownTags(entries);
    return all
        .where((tag) => TagService.stripHash(tag).startsWith(normalizedPrefix))
        .take(8)
        .toList();
  }

  /// Find an ActivityTag by hashtag or label.
  ActivityTag? findActivityTag(String tagOrHashtag) {
    final clean = TagService.stripHash(tagOrHashtag).toLowerCase();
    for (final tag in _activityTags) {
      if (tag.label.toLowerCase() == clean ||
          tag.hashtag.toLowerCase() == '#$clean') {
        return tag;
      }
    }
    return null;
  }

  /// Renames an existing hashtag across all moments in storage and updates tag lists.
  /// Replaces both occurrences in `moment.tags` and inline `#oldtag` in `moment.note`.
  Future<int> renameTagAcrossAllNotes({
    required String oldTag,
    required String newTag,
  }) async {
    final oldClean = stripHash(oldTag).trim().toLowerCase();
    final newClean = stripHash(newTag).trim().toLowerCase();
    if (oldClean.isEmpty || newClean.isEmpty || oldClean == newClean) {
      return 0;
    }

    final repo = MomentRepository();
    await repo.ensureInitialized();
    final moments = repo.getAllMoments();

    final oldHashtagRegex = RegExp(
      r'#' + RegExp.escape(oldClean) + r'(?=$|[^\w])',
      caseSensitive: false,
    );

    int updatedCount = 0;
    for (final moment in moments) {
      bool changed = false;
      var note = moment.note;
      var tags = List<String>.from(moment.tags);

      if (tags.any((t) => t.toLowerCase() == oldClean)) {
        tags.removeWhere((t) => t.toLowerCase() == oldClean);
        if (!tags.any((t) => t.toLowerCase() == newClean)) {
          tags.add(newClean);
        }
        changed = true;
      }

      if (oldHashtagRegex.hasMatch(note)) {
        note = note.replaceAll(oldHashtagRegex, '#$newClean');
        changed = true;
      }

      if (changed) {
        final updated = moment.copyWith(note: note, tags: tags);
        await repo.saveMoment(updated);
        updatedCount++;
      }
    }

    _recentTags = _recentTags.map((t) {
      if (stripHash(t).toLowerCase() == oldClean) {
        return '#$newClean';
      }
      return t;
    }).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentTagsKey, _recentTags);

    return updatedCount;
  }

  /// Removes a hashtag across all moments in storage and removes it from tag lists.
  Future<int> removeTagFromAllNotes({required String tag}) async {
    final clean = stripHash(tag).trim().toLowerCase();
    if (clean.isEmpty) return 0;

    final repo = MomentRepository();
    await repo.ensureInitialized();
    final moments = repo.getAllMoments();

    final hashtagRegex = RegExp(
      r'#' + RegExp.escape(clean) + r'(?=$|[^\w])',
      caseSensitive: false,
    );

    int updatedCount = 0;
    for (final moment in moments) {
      bool changed = false;
      var note = moment.note;
      var tags = List<String>.from(moment.tags);

      if (tags.any((t) => t.toLowerCase() == clean)) {
        tags.removeWhere((t) => t.toLowerCase() == clean);
        changed = true;
      }

      if (hashtagRegex.hasMatch(note)) {
        note = note
            .replaceAll(hashtagRegex, '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        changed = true;
      }

      if (changed) {
        final updated = moment.copyWith(note: note, tags: tags);
        await repo.saveMoment(updated);
        updatedCount++;
      }
    }

    _recentTags.removeWhere((t) => stripHash(t).toLowerCase() == clean);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentTagsKey, _recentTags);

    return updatedCount;
  }

  Future<void> _saveActivityTags() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_activityTags.map((t) => t.toJson()).toList());
    await prefs.setString(_activityTagsKey, encoded);

    // Sync legacy string list for widget/quick note parsing
    final stringList = _activityTags.map((t) => t.label).toList();
    await prefs.setStringList(_customTagsKey, stringList);
  }
}

/// Helper for extracting and stripping hashtags from note body text in view modes.
class NoteTagExtractor {
  static final RegExp _hashtagRegex = RegExp(
    r'(?:^|\s)#[a-zA-Z0-9_\u0900-\u097F]+',
  );

  /// Extracts list of unique hashtags from note text (e.g. ['#walking', '#deepwork']).
  static List<String> extractHashtags(String note) {
    if (note.isEmpty) return const [];
    return _hashtagRegex
        .allMatches(note)
        .map((m) => m.group(0)!.trim())
        .toSet()
        .toList();
  }

  /// Removes hashtags from note text for clean Apple HIG timeline presentation.
  static String cleanBodyText(String note) {
    if (note.isEmpty) return '';
    return note
        .replaceAll(_hashtagRegex, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
