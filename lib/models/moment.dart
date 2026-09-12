import 'package:notekar/utils/app_utils.dart';

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

class Moment {
  Moment({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.date,
    this.note = '',
    this.category,
  });

  final int id;
  final int timestamp;
  final String type;
  final String date;
  final String note;
  final String? category;

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

    return Moment(
      id: (json['id'] as num).toInt(),
      timestamp: timestamp,
      type: validatedType,
      // Always derive date from timestamp for consistency
      date: dateKey(DateTime.fromMillisecondsSinceEpoch(timestamp)),
      note: note,
      category: resolvedCategory,
    );
  }

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'type': type,
    'date': date,
    'note': note,
    if (category != null && category!.trim().isNotEmpty)
      'category': category!.trim(),
  };
}

class HistoryListItem {
  const HistoryListItem.header(this.label) : moment = null;

  const HistoryListItem.moment(this.moment) : label = null;

  final String? label;
  final Moment? moment;
}
