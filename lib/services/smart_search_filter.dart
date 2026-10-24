import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/services/checkpoint_service.dart';

/// Predefined Natural Language Smart Filter types.
enum SmartFilterType { thisWeek, deepworkOver2h, moodFocused, checkpointsDone }

/// Metadata definition for each Apple HIG Natural Language Search Chip.
class SmartChipDefinition {
  final SmartFilterType type;
  final String label;
  final String queryRule;
  final String description;

  const SmartChipDefinition({
    required this.type,
    required this.label,
    required this.queryRule,
    required this.description,
  });
}

const List<SmartChipDefinition> kSmartSearchChips = [
  SmartChipDefinition(
    type: SmartFilterType.thisWeek,
    label: 'this week',
    queryRule: 'this week',
    description: 'Moments logged in the past 7 days',
  ),
  SmartChipDefinition(
    type: SmartFilterType.deepworkOver2h,
    label: '#deepwork >2h',
    queryRule: '#deepwork >2h',
    description: 'Deep work sessions lasting longer than 2 hours',
  ),
  SmartChipDefinition(
    type: SmartFilterType.moodFocused,
    label: 'mood:focused',
    queryRule: 'mood:focused',
    description: 'Notes tagged with focus state or flow mood',
  ),
  SmartChipDefinition(
    type: SmartFilterType.checkpointsDone,
    label: 'checkpoints:done',
    queryRule: 'checkpoints:done',
    description: 'Habit checkpoints completed and recorded',
  ),
];

/// Rule-based parser and filtering engine for Natural Language Search Chips.
class SmartSearchFilter {
  final Set<SmartFilterType> activeFilters;

  const SmartSearchFilter({this.activeFilters = const {}});

  bool get isEmpty => activeFilters.isEmpty;
  bool get isNotEmpty => activeFilters.isNotEmpty;

  bool isFilterActive(SmartFilterType type) => activeFilters.contains(type);

  SmartSearchFilter toggle(SmartFilterType type) {
    final updated = Set<SmartFilterType>.from(activeFilters);
    if (updated.contains(type)) {
      updated.remove(type);
    } else {
      updated.add(type);
    }
    return SmartSearchFilter(activeFilters: updated);
  }

  /// Parses a natural language search query string, extracting rule chips and returning
  /// clean remaining keywords.
  static ({SmartSearchFilter filter, String cleanQuery}) parseQuery(
    String rawQuery,
  ) {
    var text = rawQuery.trim();
    final filters = <SmartFilterType>{};

    // 1. "this week"
    final thisWeekRegex = RegExp(r'\bthis\s+week\b', caseSensitive: false);
    if (thisWeekRegex.hasMatch(text)) {
      filters.add(SmartFilterType.thisWeek);
      text = text.replaceAll(thisWeekRegex, '').trim();
    }

    // 2. "#deepwork >2h" or "#deepwork > 2h" or "#deepwork >2 hours"
    final deepworkRegex = RegExp(
      r'#?deepwork\s*>\s*2\s*h(ours)?\b',
      caseSensitive: false,
    );
    if (deepworkRegex.hasMatch(text)) {
      filters.add(SmartFilterType.deepworkOver2h);
      text = text.replaceAll(deepworkRegex, '').trim();
    }

    // 3. "mood:focused" or "mood: focused"
    final moodRegex = RegExp(r'\bmood:\s*focused\b', caseSensitive: false);
    if (moodRegex.hasMatch(text)) {
      filters.add(SmartFilterType.moodFocused);
      text = text.replaceAll(moodRegex, '').trim();
    }

    // 4. "checkpoints:done" or "checkpoint:done"
    final checkpointRegex = RegExp(
      r'\bcheckpoints?:\s*done\b',
      caseSensitive: false,
    );
    if (checkpointRegex.hasMatch(text)) {
      filters.add(SmartFilterType.checkpointsDone);
      text = text.replaceAll(checkpointRegex, '').trim();
    }

    // Clean multiple spaces
    text = text.replaceAll(RegExp(r'\s{2,}'), ' ').trim();

    return (
      filter: SmartSearchFilter(activeFilters: filters),
      cleanQuery: text,
    );
  }

  /// Applies active rule filters over a collection of moments.
  List<Moment> apply({
    required List<Moment> moments,
    Map<int, dynamic>? sessionLookup,
    DateTime? referenceNow,
  }) {
    if (activeFilters.isEmpty) return moments;

    final now = referenceNow ?? DateTime.now();
    final sevenDaysAgo = now
        .subtract(const Duration(days: 7))
        .millisecondsSinceEpoch;

    Map<int, dynamic>? effectiveSessionLookup = sessionLookup;
    if (effectiveSessionLookup == null &&
        (activeFilters.contains(SmartFilterType.deepworkOver2h) ||
            activeFilters.contains(SmartFilterType.checkpointsDone))) {
      final lookup = <int, dynamic>{};
      final daySections = buildTimelineDaySections(moments);
      for (final sec in daySections) {
        for (final item in sec.items) {
          if (item is TimelineSessionItem) {
            lookup[item.inMoment.id] = item;
            if (item.outMoment != null) {
              lookup[item.outMoment!.id] = item;
            }
          }
        }
      }
      effectiveSessionLookup = lookup;
    }

    return moments.where((m) {
      // 1. this week rule
      if (activeFilters.contains(SmartFilterType.thisWeek)) {
        if (m.timestamp < sevenDaysAgo) {
          return false;
        }
      }

      // 2. #deepwork >2h rule
      if (activeFilters.contains(SmartFilterType.deepworkOver2h)) {
        final lowerNote = m.note.toLowerCase();
        final lowerTags = m.tags.map((t) => t.toLowerCase()).toList();
        final hasDeepworkTag =
            lowerTags.contains('deepwork') ||
            lowerTags.contains('#deepwork') ||
            lowerNote.contains('#deepwork') ||
            lowerNote.contains('deepwork');
        if (!hasDeepworkTag) return false;

        // Check if duration exceeds 2 hours
        var durationMs = 0;
        if (effectiveSessionLookup != null &&
            effectiveSessionLookup.containsKey(m.id)) {
          final item = effectiveSessionLookup[m.id];
          if (item is TimelineSessionItem) {
            if (item.outMoment == null) {
              return false; // Unfinished / ongoing session without outMoment is not a completed deepwork >2h session
            }
            durationMs = item.outMoment!.timestamp - item.inMoment.timestamp;
          }
        }
        // Also support note annotations like (2h 15m), >2h, or manual duration in note
        final manual2hMatch =
            lowerNote.contains('>2h') ||
            lowerNote.contains('> 2h') ||
            lowerNote.contains('2h') ||
            lowerNote.contains('3h') ||
            lowerNote.contains('4h') ||
            lowerNote.contains('5h');

        final isOver2h =
            durationMs > (2 * 60 * 60 * 1000) ||
            (manual2hMatch && durationMs == 0);
        if (!isOver2h) return false;
      }

      // 3. mood:focused rule
      if (activeFilters.contains(SmartFilterType.moodFocused)) {
        final lowerNote = m.note.toLowerCase();
        final lowerTags = m.tags.map((t) => t.toLowerCase()).toList();
        final isFocused =
            lowerTags.contains('mood:focused') ||
            lowerTags.contains('focused') ||
            lowerNote.contains('mood:focused') ||
            lowerNote.contains('mood: focused') ||
            lowerNote.contains('#focused') ||
            lowerNote.contains('focused');
        if (!isFocused) return false;
      }

      // 4. checkpoints:done rule
      if (activeFilters.contains(SmartFilterType.checkpointsDone)) {
        final isCheckpoint =
            CheckpointService.instance.isCheckpointMoment(m) ||
            m.tags.any((t) => t.startsWith('checkpoint'));
        if (!isCheckpoint) return false;

        // Checkpoint completion: either single moment with checkpoint tag, or paired session
        // where out moment exists, or note marked done
        if (m.type == 'in') {
          // If effectiveSessionLookup exists, ensure outMoment is present
          if (effectiveSessionLookup != null &&
              effectiveSessionLookup.containsKey(m.id)) {
            final item = effectiveSessionLookup[m.id];
            if (item is TimelineSessionItem && item.outMoment == null) {
              return false; // Active ongoing session is not yet completed
            }
          }
        }
      }

      return true;
    }).toList();
  }
}
