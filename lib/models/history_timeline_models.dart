import 'dart:math' as math;

import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/app_utils.dart';

/// Base class for items displayed in the Life Ledger Timeline.
sealed class TimelineItem {
  int get primaryTimestamp;

  String get note;

  String? get category;
}

/// A connected Two-Way session interval (paired IN and OUT moments, or ongoing IN).
class TimelineSessionItem extends TimelineItem {
  TimelineSessionItem({required this.inMoment, this.outMoment, bool? isOngoing})
    : _isOngoingOverride = isOngoing;

  final Moment inMoment;
  final Moment? outMoment;
  final bool? _isOngoingOverride;

  bool get isOngoing => _isOngoingOverride ?? (outMoment == null);

  @override
  int get primaryTimestamp => outMoment?.timestamp ?? inMoment.timestamp;

  int get startTimestamp => inMoment.timestamp;

  int? get endTimestamp => outMoment?.timestamp;

  Duration get duration {
    final start = inMoment.timestamp;
    if (outMoment != null) {
      final diff = outMoment!.timestamp - start;
      return Duration(milliseconds: diff > 0 ? diff : 0);
    }
    if (isOngoing) {
      final diff = DateTime.now().millisecondsSinceEpoch - start;
      return Duration(milliseconds: diff > 0 ? diff : 0);
    }
    final inDt = DateTime.fromMillisecondsSinceEpoch(start);
    final endOfDay = DateTime(
      inDt.year,
      inDt.month,
      inDt.day,
      23,
      59,
      59,
    ).millisecondsSinceEpoch;
    final capped = math.min(
      endOfDay - start,
      const Duration(hours: 2).inMilliseconds,
    );
    return Duration(milliseconds: capped > 0 ? capped : 0);
  }

  @override
  String get note {
    if (inMoment.note.trim().isNotEmpty) return inMoment.note.trim();
    if (outMoment != null && outMoment!.note.trim().isNotEmpty) {
      return outMoment!.note.trim();
    }
    return '';
  }

  /// The moment within this session that holds the user's note or media.
  /// If the note or media was logged on IN, returns inMoment.
  /// If on OUT, returns outMoment.
  /// If neither has a note/media, returns outMoment if completed, otherwise inMoment.
  Moment get noteMoment {
    if (inMoment.note.trim().isNotEmpty ||
        inMoment.imagePath != null ||
        inMoment.voicePath != null) {
      return inMoment;
    }
    if (outMoment != null &&
        (outMoment!.note.trim().isNotEmpty ||
            outMoment!.imagePath != null ||
            outMoment!.voicePath != null)) {
      return outMoment!;
    }
    return outMoment ?? inMoment;
  }

  String? get imagePath => noteMoment.imagePath;
  String? get voicePath => noteMoment.voicePath;
  int? get voiceDurationMs => noteMoment.voiceDurationMs;

  @override
  String? get category {
    if (inMoment.category != null && inMoment.category!.trim().isNotEmpty) {
      final c = inMoment.category!.trim();
      if (c.toLowerCase() == 'rest & recovery' ||
          c.toLowerCase() == 'recovery') {
        return 'Rest';
      }
      return c;
    }
    if (outMoment != null &&
        outMoment!.category != null &&
        outMoment!.category!.trim().isNotEmpty) {
      final c = outMoment!.category!.trim();
      if (c.toLowerCase() == 'rest & recovery' ||
          c.toLowerCase() == 'recovery') {
        return 'Rest';
      }
      return c;
    }
    final inTag = extractHashtagCategory(inMoment.note);
    if (inTag != null) return inTag;
    if (outMoment != null) {
      final outTag = extractHashtagCategory(outMoment!.note);
      if (outTag != null) return outTag;
    }
    if (inMoment.note.toLowerCase().contains('rest & recovery') ||
        inMoment.tags.contains('rest')) {
      return 'Rest';
    }
    return null;
  }

  /// Goal ID bound to this session, if any.
  String? get goalId => inMoment.effectiveGoalId ?? outMoment?.effectiveGoalId;

  /// Moment IDs associated with this session.
  List<int> get momentIds => [
    inMoment.id,
    if (outMoment != null && outMoment!.id > 0) outMoment!.id,
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

  @override
  String? get category {
    if (moment.category != null && moment.category!.trim().isNotEmpty) {
      return moment.category!.trim();
    }
    return extractHashtagCategory(moment.note);
  }

  int get id => moment.id;

  String get type => moment.type;

  String? get goalId => moment.effectiveGoalId;
}

/// Represents an untracked gap between sessions or moments.
class TimelineGapItem extends TimelineItem {
  TimelineGapItem({required this.startTimestamp, required this.endTimestamp});

  final int startTimestamp;
  final int endTimestamp;

  @override
  int get primaryTimestamp => endTimestamp;

  @override
  String get note => '';

  @override
  String? get category => null;

  Duration get duration => Duration(
    milliseconds: (endTimestamp - startTimestamp).clamp(0, 86400000),
  );
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
    Map<String, Duration>? categoryBreakdown,
  }) : categoryBreakdown =
           categoryBreakdown ?? _calculateCategoryBreakdown(items);

  final String dateKey;
  final DateTime date;
  final String displayTitle;
  final Duration totalTrackedDuration;
  final int totalLogs;
  final List<TimelineItem> items;
  final Map<String, Duration> categoryBreakdown;

  static Map<String, Duration> _calculateCategoryBreakdown(
    List<TimelineItem> items,
  ) {
    final Map<String, int> msMap = {};
    for (final it in items) {
      final cat = it.category ?? 'General';
      final itemMs = switch (it) {
        TimelineSessionItem s => s.duration.inMilliseconds,
        TimelineSingleItem _ => 0,
        TimelineGapItem _ => 0,
      };
      if (itemMs > 0) {
        msMap[cat] = (msMap[cat] ?? 0) + itemMs;
      }
    }
    return msMap.map((k, v) => MapEntry(k, Duration(milliseconds: v)));
  }

  String? get categorySummaryText {
    if (categoryBreakdown.isEmpty) return null;
    final entries = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final parts = <String>[];
    for (final e in entries) {
      final totalMins = e.value.inMinutes;
      if (totalMins <= 0) continue;
      final hours = totalMins ~/ 60;
      final mins = totalMins % 60;
      final dur = hours > 0 && mins > 0
          ? '${hours}h ${mins}m'
          : hours > 0
          ? '${hours}h'
          : '${mins}m';
      parts.add('${e.key} $dur');
    }
    return parts.isEmpty ? null : parts.join(' • ');
  }

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
List<TimelineDaySection> buildTimelineDaySections(
  List<Moment> entries, {
  bool includeGaps = false,
}) {
  if (entries.isEmpty) return [];

  // 1. Sort all moments chronologically ascending (earliest to latest).
  final chronoSorted = List<Moment>.from(entries)
    ..sort((a, b) {
      final cmp = a.timestamp.compareTo(b.timestamp);
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });

  // Group moments by timestamp while preserving chronological order
  final Map<int, List<Moment>> byTimestamp = {};
  for (final m in chronoSorted) {
    byTimestamp.putIfAbsent(m.timestamp, () => []).add(m);
  }

  final List<TimelineItem> allItems = [];
  final Map<String, Moment> activeInTracks = {};

  String canonicalCategory(Moment m) {
    final cat = m.category?.trim().toLowerCase() ?? '';
    if (cat == 'rest' ||
        cat == 'recovery' ||
        cat == 'rest & recovery' ||
        cat.contains('rest & recovery')) {
      return 'rest';
    }
    if (m.tags.any((t) {
      final lower = t.toLowerCase();
      return lower == 'rest' || lower == '#rest' || lower == 'recovery';
    })) {
      return 'rest';
    }
    final note = m.note.trim().toLowerCase();
    if (note.contains('rest & recovery') || note == 'rest' || note == '#rest') {
      return 'rest';
    }
    if (cat.isNotEmpty) return cat;
    final tagCat = extractHashtagCategory(m.note);
    if (tagCat != null) return tagCat.trim().toLowerCase();
    return '';
  }

  String trackKey(Moment m) =>
      '${canonicalCategory(m)}|${m.effectiveGoalId ?? ''}';

  for (final entry in byTimestamp.entries) {
    final momentsAtT = entry.value;
    final singles = momentsAtT
        .where((m) => m.type != 'in' && m.type != 'out')
        .toList();
    final outs = momentsAtT.where((m) => m.type == 'out').toList();
    final ins = momentsAtT.where((m) => m.type == 'in').toList();

    // 1. Process single moments
    for (final s in singles) {
      allItems.add(TimelineSingleItem(moment: s));
    }

    // 2. Process OUT moments: match with matching category/track first, then category, then any active in
    final remainingOuts = <Moment>[];
    for (final outMoment in outs) {
      final exactKey = trackKey(outMoment);
      if (activeInTracks.containsKey(exactKey)) {
        allItems.add(
          TimelineSessionItem(
            inMoment: activeInTracks.remove(exactKey)!,
            outMoment: outMoment,
            isOngoing: false,
          ),
        );
        continue;
      }

      // Check same category track
      final cat = canonicalCategory(outMoment);
      final matchingCatKey = activeInTracks.keys
          .where(
            (k) =>
                k.startsWith('$cat|') ||
                (cat.isNotEmpty && k.split('|').first == cat),
          )
          .firstOrNull;
      if (matchingCatKey != null) {
        allItems.add(
          TimelineSessionItem(
            inMoment: activeInTracks.remove(matchingCatKey)!,
            outMoment: outMoment,
            isOngoing: false,
          ),
        );
        continue;
      }

      // Fallback: match any open session if only one track or general
      if (activeInTracks.isNotEmpty) {
        final oldestKey = activeInTracks.keys.first;
        allItems.add(
          TimelineSessionItem(
            inMoment: activeInTracks.remove(oldestKey)!,
            outMoment: outMoment,
            isOngoing: false,
          ),
        );
        continue;
      }

      remainingOuts.add(outMoment);
    }

    // 3. Process IN moments
    for (final inMoment in ins) {
      // Check if there are leftover OUT moments at the same timestamp that can pair immediately
      if (remainingOuts.isNotEmpty) {
        allItems.add(
          TimelineSessionItem(
            inMoment: inMoment,
            outMoment: remainingOuts.removeAt(0),
            isOngoing: false,
          ),
        );
        continue;
      }

      final exactKey = trackKey(inMoment);
      if (activeInTracks.containsKey(exactKey)) {
        // Close previous unclosed session on the same track
        allItems.add(
          TimelineSessionItem(
            inMoment: activeInTracks.remove(exactKey)!,
            outMoment: null,
          ),
        );
      }
      activeInTracks[exactKey] = inMoment;
    }

    // 4. Any leftover OUT moments become single items
    for (final outMoment in remainingOuts) {
      allItems.add(TimelineSingleItem(moment: outMoment));
    }
  }

  // 5. Any remaining active IN moments
  for (final inMoment in activeInTracks.values) {
    allItems.add(TimelineSessionItem(inMoment: inMoment, outMoment: null));
  }

  // 2. Group timeline items by day based on the item's anchor date
  // For a session, its anchor date is when it started (inMoment.date).
  // For a single/out, its anchor date is moment.date.
  final Map<String, List<TimelineItem>> groupedByDate = {};
  for (final item in allItems) {
    final dKey = switch (item) {
      TimelineSessionItem s => s.inMoment.date,
      TimelineSingleItem s => s.moment.date,
      TimelineGapItem g => dateKey(
        DateTime.fromMillisecondsSinceEpoch(g.startTimestamp),
      ),
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

    if (includeGaps && dayItems.isNotEmpty) {
      dayItems.sort((a, b) => a.primaryTimestamp.compareTo(b.primaryTimestamp));
      final List<TimelineItem> itemsWithGaps = [];
      for (int i = 0; i < dayItems.length; i++) {
        final current = dayItems[i];
        itemsWithGaps.add(current);
        if (i < dayItems.length - 1) {
          final next = dayItems[i + 1];
          final currentEnd = switch (current) {
            TimelineSessionItem s =>
              s.endTimestamp ??
                  math.max(
                    s.startTimestamp,
                    DateTime.now().millisecondsSinceEpoch,
                  ),
            TimelineSingleItem s => s.moment.timestamp,
            TimelineGapItem g => g.endTimestamp,
          };
          final nextStart = switch (next) {
            TimelineSessionItem s => s.startTimestamp,
            TimelineSingleItem s => s.moment.timestamp,
            TimelineGapItem g => g.startTimestamp,
          };
          final gapMs = nextStart - currentEnd;
          if (gapMs >= 15 * 60 * 1000) {
            itemsWithGaps.add(
              TimelineGapItem(
                startTimestamp: currentEnd,
                endTimestamp: nextStart,
              ),
            );
          }
        }
      }
      dayItems
        ..clear()
        ..addAll(itemsWithGaps);
    }

    // Sort items descending so newest moments/sessions within the day appear at the top
    dayItems.sort((a, b) => b.primaryTimestamp.compareTo(a.primaryTimestamp));

    int totalTrackedMs = 0;
    int totalLogs = 0;
    for (final it in dayItems) {
      if (it is TimelineSessionItem) {
        totalTrackedMs += it.duration.inMilliseconds;
        totalLogs += it.momentIds.length;
      } else if (it is TimelineSingleItem) {
        totalLogs += 1;
      }
    }

    // Formulate clean Apple HIG day section title
    final sampleDate = dateFromKey(dKey);
    final String title;
    final weekdayShort = _weekdayShort(sampleDate.weekday).toUpperCase();
    if (dKey == todayKey) {
      title = 'TODAY, $weekdayShort';
    } else if (dKey == yesterdayKey) {
      title = 'YESTERDAY, $weekdayShort';
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

class TimelineIsolateResult {
  final List<TimelineDaySection> sections;
  final Map<int, String> singleNumberMap;

  TimelineIsolateResult(this.sections, this.singleNumberMap);
}

class TimelineIsolatePayload {
  final List<Moment> entries;
  final bool includeGaps;
  final String filter;
  final String? selectedDateKey;
  final String today;
  final DateTime weekAgo;

  TimelineIsolatePayload({
    required this.entries,
    required this.includeGaps,
    required this.filter,
    this.selectedDateKey,
    required this.today,
    required this.weekAgo,
  });
}

TimelineIsolateResult buildTimelineDataInIsolate(
  TimelineIsolatePayload payload,
) {
  // 1. Build Single Number Map
  final map = <int, String>{};
  final singles = payload.entries.where((e) => e.type == 'single').toList();
  if (singles.isNotEmpty) {
    // Sort oldest first to assign sequential numbers
    singles.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    String currentDay = '';
    int count = 0;
    for (int i = 0; i < singles.length; i++) {
      if (singles[i].date != currentDay) {
        currentDay = singles[i].date;
        count = 1;
      } else {
        count++;
      }
      map[singles[i].id] = count.toString().padLeft(2, '0');
    }
  }

  // 2. Build Sections
  final allSections = buildTimelineDaySections(
    payload.entries,
    includeGaps: payload.includeGaps,
  );

  var sections = allSections;
  if (payload.filter == 'today') {
    sections = sections.where((s) => s.dateKey == payload.today).toList();
  } else if (payload.filter == 'week') {
    sections = sections.where((s) {
      return s.dateKey == payload.today || s.date.isAfter(payload.weekAgo);
    }).toList();
  } else if (payload.filter == 'date') {
    if (payload.selectedDateKey != null) {
      sections = sections
          .where((s) => s.dateKey == payload.selectedDateKey)
          .toList();
    }
  } else if (payload.filter == 'sessions') {
    sections = sections
        .map(
          (s) => TimelineDaySection(
            dateKey: s.dateKey,
            date: s.date,
            displayTitle: s.displayTitle,
            totalTrackedDuration: s.totalTrackedDuration,
            totalLogs: s.totalLogs,
            items: s.items.whereType<TimelineSessionItem>().toList(),
          ),
        )
        .where((s) => s.items.isNotEmpty)
        .toList();
  } else if (payload.filter == 'single') {
    sections = sections
        .map(
          (s) => TimelineDaySection(
            dateKey: s.dateKey,
            date: s.date,
            displayTitle: s.displayTitle,
            totalTrackedDuration: s.totalTrackedDuration,
            totalLogs: s.totalLogs,
            items: s.items
                .whereType<TimelineSingleItem>()
                .where((item) => item.moment.type == 'single')
                .toList(),
          ),
        )
        .where((s) => s.items.isNotEmpty)
        .toList();
  } else if (payload.filter == 'notes') {
    sections = sections
        .map(
          (s) => TimelineDaySection(
            dateKey: s.dateKey,
            date: s.date,
            displayTitle: s.displayTitle,
            totalTrackedDuration: s.totalTrackedDuration,
            totalLogs: s.totalLogs,
            items: s.items.where((it) {
              if (it is TimelineSingleItem && it.moment.note.isNotEmpty) {
                return true;
              }
              if (it is TimelineSessionItem &&
                  ((it.inMoment.note.isNotEmpty) ||
                      (it.outMoment?.note.isNotEmpty ?? false))) {
                return true;
              }
              return false;
            }).toList(),
          ),
        )
        .where((s) => s.items.isNotEmpty)
        .toList();
  }

  return TimelineIsolateResult(sections, map);
}
