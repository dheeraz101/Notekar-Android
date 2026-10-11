import 'package:isar/isar.dart';
import 'package:notekar/utils/app_utils.dart';

part 'moment.g.dart';

String? extractHashtagCategory(String? text) {
  if (text == null || text.trim().isEmpty) return null;
  final match = RegExp(r'#([a-zA-Z0-9_-]+)').firstMatch(text);
  if (match == null) return null;
  final tag = match.group(1);
  if (tag == null || tag.isEmpty) return null;
  final lower = tag.toLowerCase();
  if (lower == 'work') return 'Work';
  if (lower == 'deepfocus' || lower == 'focus') return 'Deep Focus';
  if (lower == 'study') return 'Study';
  if (lower == 'fitness' || lower == 'health' || lower == 'gym') {
    return 'Health';
  }
  if (lower == 'play') return 'Play';
  if (lower == 'routine') return 'Routine';
  return tag[0].toUpperCase() + tag.substring(1);
}

@collection
class Moment {
  Moment({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.date,
    this.note = '',
    this.category,
    this.tags = const [],
    this.imagePath,
    this.voicePath,
    this.voiceDurationMs,
    this.goalId,
    this.projectId,
  }) {
    if (goalId != null &&
        goalId!.isNotEmpty &&
        !tags.contains('goal:$goalId')) {
      tags = [...tags, 'goal:$goalId'];
    }
    if (projectId != null &&
        projectId!.isNotEmpty &&
        !tags.contains('proj:$projectId')) {
      tags = [...tags, 'proj:$projectId'];
    }
  }

  Id id;
  int timestamp;
  String type;
  String date;
  String note;
  String? category;
  List<String> tags;
  String? imagePath;
  String? voicePath;
  int? voiceDurationMs;

  @ignore
  String? goalId;

  @ignore
  String? projectId;

  @ignore
  String? get effectiveGoalId {
    if (goalId != null && goalId!.trim().isNotEmpty) return goalId!.trim();
    for (final t in tags) {
      if (t.startsWith('goal:')) {
        return t.substring(5).trim();
      }
    }
    return null;
  }

  @ignore
  String? get effectiveProjectId {
    if (projectId != null && projectId!.trim().isNotEmpty) {
      return projectId!.trim();
    }
    for (final t in tags) {
      if (t.startsWith('proj:')) {
        return t.substring(5).trim();
      }
    }
    return null;
  }

  @ignore
  String get effectiveCategory =>
      (category != null && category!.trim().isNotEmpty)
      ? category!.trim()
      : (extractHashtagCategory(note) ?? 'All');

  factory Moment.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String?) ?? 'single';
    // Validate type
    final validatedType = {'single', 'in', 'out'}.contains(type)
        ? type
        : 'single';
    final timestamp = (json['timestamp'] as num).toInt();
    final note = (json['note'] as String?) ?? '';
    final rawCategory = json['category'] as String?;
    final resolvedCategory =
        (rawCategory != null && rawCategory.trim().isNotEmpty)
        ? rawCategory.trim()
        : extractHashtagCategory(note);

    final tagsList =
        (json['tags'] as List<dynamic>?)?.cast<String>() ?? const <String>[];
    final rawGoalId = json['goalId'] as String?;
    final tagGoalId = tagsList
        .firstWhere((t) => t.startsWith('goal:'), orElse: () => '')
        .trim();
    final resolvedGoalId = (rawGoalId != null && rawGoalId.trim().isNotEmpty)
        ? rawGoalId.trim()
        : (tagGoalId.isNotEmpty ? tagGoalId.substring(5).trim() : null);

    final rawProjectId = json['projectId'] as String?;
    final tagProjectId = tagsList
        .firstWhere((t) => t.startsWith('proj:'), orElse: () => '')
        .trim();
    final resolvedProjectId =
        (rawProjectId != null && rawProjectId.trim().isNotEmpty)
        ? rawProjectId.trim()
        : (tagProjectId.isNotEmpty ? tagProjectId.substring(5).trim() : null);

    return Moment(
      id: (json['id'] as num).toInt(),
      timestamp: timestamp,
      type: validatedType,
      // Always derive date from timestamp for consistency
      date: dateKey(DateTime.fromMillisecondsSinceEpoch(timestamp)),
      note: note,
      category: resolvedCategory,
      tags: tagsList,
      imagePath: json['imagePath'] as String?,
      voicePath: json['voicePath'] as String?,
      voiceDurationMs: (json['voiceDurationMs'] as num?)?.toInt(),
      goalId: resolvedGoalId,
      projectId: resolvedProjectId,
    );
  }

  @ignore
  bool get isValid {
    if (id <= 0) return false;
    if (timestamp <= 0) return false;
    // Prevent future timestamps (allow 5 min drift)
    if (timestamp >
        DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch) {
      return false;
    }
    return true;
  }

  /// Returns the union of explicit tags and inline #hashtags from note.
  /// Used for filtering, search, and display.
  @ignore
  List<String> get effectiveTags {
    final result = <String>{...tags};
    final regex = RegExp(r'#([a-zA-Z0-9_-]+)');
    for (final match in regex.allMatches(note)) {
      final tag = match.group(1);
      if (tag != null && tag.isNotEmpty) {
        result.add(tag.toLowerCase());
      }
    }
    return result.toList();
  }

  /// Multi-asset support: Returns all attached image paths (split by '|').
  @ignore
  List<String> get imagePaths {
    if (imagePath == null || imagePath!.trim().isEmpty) return const [];
    return imagePath!
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Multi-asset support: Returns all attached voice paths (split by '|').
  @ignore
  List<String> get voicePaths {
    if (voicePath == null || voicePath!.trim().isEmpty) return const [];
    return voicePath!
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Multi-asset support: Returns all voice durations (split by '|' or single int).
  @ignore
  List<int> get voiceDurations {
    if (voiceDurationMs == null) return const [];
    return [voiceDurationMs!];
  }

  Moment copyWith({
    int? id,
    int? timestamp,
    String? type,
    String? date,
    String? note,
    String? category,
    List<String>? tags,
    String? imagePath,
    bool clearImagePath = false,
    String? voicePath,
    bool clearVoicePath = false,
    int? voiceDurationMs,
    String? goalId,
    String? projectId,
    bool clearProjectId = false,
  }) {
    return Moment(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      voicePath: clearVoicePath ? null : (voicePath ?? this.voicePath),
      voiceDurationMs: clearVoicePath
          ? null
          : (voiceDurationMs ?? this.voiceDurationMs),
      goalId: goalId ?? this.goalId,
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'type': type,
    'date': date,
    'note': note,
    if (category != null && category!.trim().isNotEmpty)
      'category': category!.trim(),
    if (tags.isNotEmpty) 'tags': tags,
    if (imagePath != null && imagePath!.isNotEmpty) 'imagePath': imagePath,
    if (voicePath != null && voicePath!.isNotEmpty) 'voicePath': voicePath,
    if (voiceDurationMs != null && voiceDurationMs! > 0)
      'voiceDurationMs': voiceDurationMs,
    if (effectiveGoalId != null) 'goalId': effectiveGoalId,
    if (effectiveProjectId != null) 'projectId': effectiveProjectId,
  };
}

/// Return type for NoteDialog and BigNoteDialog.
/// Contains both the note text, explicitly selected tags, and optional attachments.
class NoteResult {
  const NoteResult(
    this.note,
    this.tags, {
    this.imagePath,
    this.voicePath,
    this.voiceDurationMs,
    this.imagePaths = const [],
    this.voicePaths = const [],
    this.voiceDurations = const [],
  });

  final String note;
  final List<String> tags;
  final String? imagePath;
  final String? voicePath;
  final int? voiceDurationMs;
  final List<String> imagePaths;
  final List<String> voicePaths;
  final List<int> voiceDurations;

  List<String> get effectiveImagePaths {
    if (imagePaths.isNotEmpty) return imagePaths;
    if (imagePath != null && imagePath!.trim().isNotEmpty) {
      return imagePath!
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  List<String> get effectiveVoicePaths {
    if (voicePaths.isNotEmpty) return voicePaths;
    if (voicePath != null && voicePath!.trim().isNotEmpty) {
      return voicePath!
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

class HistoryListItem {
  const HistoryListItem.header(this.label) : moment = null;

  const HistoryListItem.moment(this.moment) : label = null;

  final String? label;
  final Moment? moment;
}
