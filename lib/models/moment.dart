import 'package:notekar/utils/app_utils.dart';

class Moment {
  Moment({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.date,
    this.note = '',
  });

  final int id;
  final int timestamp;
  final String type;
  final String date;
  final String note;

  factory Moment.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String?) ?? 'single';
    // Validate type
    final validatedType = {'single', 'in', 'out'}.contains(type) ? type : 'single';

    return Moment(
      id: (json['id'] as num).toInt(),
      timestamp: (json['timestamp'] as num).toInt(),
      type: validatedType,
      date: (json['date'] as String?) ?? dateKey(DateTime.now()),
      note: (json['note'] as String?) ?? '',
    );
  }

  bool get isValid {
    if (id <= 0) return false;
    if (timestamp <= 0) return false;
    // Prevent future timestamps (allow 5 min drift)
    if (timestamp > DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'type': type,
    'date': date,
    'note': note,
  };
}

class HistoryListItem {
  const HistoryListItem.header(this.label) : moment = null;
  const HistoryListItem.moment(this.moment) : label = null;

  final String? label;
  final Moment? moment;
}
