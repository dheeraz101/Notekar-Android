import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';

/// Base class for items displayed in the Life Ledger Timeline.
sealed class TimelineItem {
  int get primaryTimestamp;

  String get note;
}

/// A connected Two-Way session interval (paired IN and OUT moments, or ongoing IN).
class TimelineSessionItem extends TimelineItem {
  TimelineSessionItem({required this.inMoment, this.outMoment});

  final Moment inMoment;
  final Moment? outMoment;

  bool get isOngoing => outMoment == null;

  @override
  int get primaryTimestamp => outMoment?.timestamp ?? inMoment.timestamp;

  int get startTimestamp => inMoment.timestamp;

  int? get endTimestamp => outMoment?.timestamp;

  Duration get duration {
    final start = inMoment.timestamp;
    final end = outMoment?.timestamp ?? DateTime.now().millisecondsSinceEpoch;
    final diff = end - start;
    return Duration(milliseconds: diff > 0 ? diff : 0);
  }

  @override
  String get note {
    if (inMoment.note.trim().isNotEmpty) return inMoment.note.trim();
    if (outMoment != null && outMoment!.note.trim().isNotEmpty) {
      return outMoment!.note.trim();
    }
    return '';
  }

  /// Moment IDs associated with this session.
  List<int> get momentIds => [
    inMoment.id,
    if (outMoment != null) outMoment!.id,
  ];
}

/// A standalone moment (e.g. single log, or unpaired event).
class TimelineSingleItem extends TimelineItem {
  TimelineSingleItem({required this.moment});

  final Moment moment;

  @override
  int get primaryTimestamp => moment.timestamp;

  @override
  String get note => moment.note.trim();

  int get id => moment.id;

  String get type => moment.type;
}

/// Represents a day section in the History Life Ledger.
class TimelineDaySection {
  TimelineDaySection({
    required this.dateKey,
    required this.date,
    required this.displayTitle,
    required this.totalTrackedDuration,
    required this.totalLogs,
    required this.items,
  });

  final String dateKey;
  final DateTime date;
  final String displayTitle;
  final Duration totalTrackedDuration;
  final int totalLogs;
  final List<TimelineItem> items;

  String get formattedTrackedDuration {
    final totalMinutes = totalTrackedDuration.inMinutes;
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }

  String get summaryText {
    final dur = formattedTrackedDuration;
    final logSuffix = totalLogs == 1 ? 'log' : 'logs';
    if (totalTrackedDuration.inMinutes > 0) {
      return '$dur tracked • $totalLogs $logSuffix';
    }
    return '$totalLogs $logSuffix';
  }
}

/// Converts a flat list of moments into chronological day sections of Life Ledger timeline items.
List<TimelineDaySection> buildTimelineDaySections(List<Moment> entries) {
  if (entries.isEmpty) return [];

  // 1. Sort all moments chronologically ascending (earliest to latest) to pair sessions globally
  final chronoSorted = List<Moment>.from(entries)
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final List<TimelineItem> allItems = [];
  final Set<int> consumedOutIds = {};

  for (int i = 0; i < chronoSorted.length; i++) {
    final m = chronoSorted[i];
    if (consumedOutIds.contains(m.id)) continue;

    if (m.type == 'in') {
      Moment? matchedOut;
      for (int j = i + 1; j < chronoSorted.length; j++) {
        final next = chronoSorted[j];
        if (next.type == 'in') {
          break; // Next session started before this ended
        }
        if (next.type == 'out' && !consumedOutIds.contains(next.id)) {
          matchedOut = next;
          consumedOutIds.add(next.id);
          break;
        }
      }

      final session = TimelineSessionItem(inMoment: m, outMoment: matchedOut);
      allItems.add(session);
    } else if (m.type == 'out') {
      allItems.add(TimelineSingleItem(moment: m));
    } else {
      allItems.add(TimelineSingleItem(moment: m));
    }
  }

  // 2. Group timeline items by day based on the item's anchor date
  // For a session, its anchor date is when it started (inMoment.date).
  // For a single/out, its anchor date is moment.date.
  final Map<String, List<TimelineItem>> groupedByDate = {};
  for (final item in allItems) {
    final dKey = switch (item) {
      TimelineSessionItem s => s.inMoment.date,
      TimelineSingleItem s => s.moment.date,
    };
    groupedByDate.putIfAbsent(dKey, () => []).add(item);
  }

  final now = DateTime.now();
  final todayKey = dateKey(now);
  final yesterdayKey = dateKey(now.subtract(const Duration(days: 1)));

  // Sort dates descending (newest date first)
  final sortedDates = groupedByDate.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  final List<TimelineDaySection> sections = [];

  for (final dKey in sortedDates) {
    final dayItems = groupedByDate[dKey]!;

    // Sort items descending so newest moments/sessions within the day appear at the top
    dayItems.sort((a, b) => b.primaryTimestamp.compareTo(a.primaryTimestamp));

    int totalTrackedMs = 0;
    int totalLogs = 0;
    for (final it in dayItems) {
      if (it is TimelineSessionItem) {
        totalTrackedMs += it.duration.inMilliseconds;
        totalLogs += it.momentIds.length;
      } else {
        totalLogs += 1;
      }
    }

    // Formulate clean Apple HIG day section title
    final sampleDate = dateFromKey(dKey);
    final String title;
    if (dKey == todayKey) {
      title = 'TODAY, ${_formatDayMonth(sampleDate).toUpperCase()}';
    } else if (dKey == yesterdayKey) {
      title = 'YESTERDAY, ${_formatDayMonth(sampleDate).toUpperCase()}';
    } else {
      title = _formatDayMonth(sampleDate).toUpperCase();
    }

    sections.add(
      TimelineDaySection(
        dateKey: dKey,
        date: sampleDate,
        displayTitle: title,
        totalTrackedDuration: Duration(milliseconds: totalTrackedMs),
        totalLogs: totalLogs,
        items: dayItems,
      ),
    );
  }

  return sections;
}

String _formatDayMonth(DateTime date) {
  final weekday = _weekdayShort(date.weekday);
  final month = _monthShort(date.month);
  return '$weekday $month ${date.day}';
}

String _weekdayShort(int w) {
  return switch (w) {
    DateTime.monday => 'Mon',
    DateTime.tuesday => 'Tue',
    DateTime.wednesday => 'Wed',
    DateTime.thursday => 'Thu',
    DateTime.friday => 'Fri',
    DateTime.saturday => 'Sat',
    DateTime.sunday => 'Sun',
    _ => '',
  };
}

String _monthShort(int m) {
  return switch (m) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    12 => 'Dec',
    _ => '',
  };
}
