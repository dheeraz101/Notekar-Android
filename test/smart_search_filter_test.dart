import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/services/smart_search_filter.dart';

void main() {
  group('SmartSearchFilter (Natural Language Search Chips)', () {
    final now = DateTime(2026, 10, 24, 18, 0, 0);

    final mRecent = Moment(
      id: 1,
      timestamp: now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      type: 'single',
      date: '2026-10-22',
      note: 'Recent study session',
      category: 'Study',
    );

    final mOld = Moment(
      id: 2,
      timestamp: now.subtract(const Duration(days: 15)).millisecondsSinceEpoch,
      type: 'single',
      date: '2026-10-09',
      note: 'Old note from 2 weeks ago',
      category: 'General',
    );

    final mDeepworkShort = Moment(
      id: 3,
      timestamp: now.subtract(const Duration(hours: 5)).millisecondsSinceEpoch,
      type: 'in',
      date: '2026-10-24',
      note: 'Short burst #deepwork',
      category: 'Work',
      tags: ['deepwork'],
    );

    final mDeepworkLongIn = Moment(
      id: 4,
      timestamp: now.subtract(const Duration(hours: 4)).millisecondsSinceEpoch,
      type: 'in',
      date: '2026-10-24',
      note: 'Architecture sprint #deepwork',
      category: 'Work',
      tags: ['deepwork'],
    );

    final mDeepworkLongOut = Moment(
      id: 5,
      timestamp: now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      type: 'out',
      date: '2026-10-24',
      note: '',
      category: 'Work',
      tags: ['deepwork'],
    );

    final mFocused = Moment(
      id: 6,
      timestamp: now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
      type: 'single',
      date: '2026-10-24',
      note: 'Reading chapter mood:focused with high energy',
      category: 'Personal',
      tags: ['mood:focused'],
    );

    final mCheckpoint = Moment(
      id: 7,
      timestamp: now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      type: 'single',
      date: '2026-10-24',
      note: 'Completed 10 pushups',
      category: 'Fitness',
      tags: ['checkpoint', 'checkpoint:pushups'],
    );

    final allMoments = [
      mRecent,
      mOld,
      mDeepworkShort,
      mDeepworkLongIn,
      mDeepworkLongOut,
      mFocused,
      mCheckpoint,
    ];

    // Session lookup mapping for the deepwork session (3 hours duration)
    final sessionItem = TimelineSessionItem(
      inMoment: mDeepworkLongIn,
      outMoment: mDeepworkLongOut,
    );
    final sessionLookup = <int, dynamic>{
      mDeepworkLongIn.id: sessionItem,
      mDeepworkLongOut.id: sessionItem,
    };

    test('Filter "this week" includes only moments within the last 7 days', () {
      final filter = const SmartSearchFilter(
        activeFilters: {SmartFilterType.thisWeek},
      );

      final results = filter.apply(moments: allMoments, referenceNow: now);

      expect(results.contains(mRecent), isTrue);
      expect(results.contains(mOld), isFalse);
    });

    test('Filter "#deepwork >2h" filters sessions exceeding 2 hours', () {
      final filter = const SmartSearchFilter(
        activeFilters: {SmartFilterType.deepworkOver2h},
      );

      final results = filter.apply(
        moments: allMoments,
        sessionLookup: sessionLookup,
        referenceNow: now,
      );

      expect(results.contains(mDeepworkLongIn), isTrue);
      // mDeepworkShort duration is not in session lookup or <2h
      expect(results.contains(mDeepworkShort), isFalse);
      expect(results.contains(mRecent), isFalse);
    });

    test(
      'Filter "mood:focused" matches moments tagged or noted with focus state',
      () {
        final filter = const SmartSearchFilter(
          activeFilters: {SmartFilterType.moodFocused},
        );

        final results = filter.apply(moments: allMoments, referenceNow: now);

        expect(results.contains(mFocused), isTrue);
        expect(results.contains(mRecent), isFalse);
      },
    );

    test('Filter "checkpoints:done" matches completed habit checkpoints', () {
      final filter = const SmartSearchFilter(
        activeFilters: {SmartFilterType.checkpointsDone},
      );

      final results = filter.apply(moments: allMoments, referenceNow: now);

      expect(results.contains(mCheckpoint), isTrue);
      expect(results.contains(mRecent), isFalse);
    });

    test(
      'parseQuery parses natural language rule chips from search query string',
      () {
        final parsed = SmartSearchFilter.parseQuery(
          'urgent bugs this week #deepwork >2h',
        );

        expect(parsed.filter.isFilterActive(SmartFilterType.thisWeek), isTrue);
        expect(
          parsed.filter.isFilterActive(SmartFilterType.deepworkOver2h),
          isTrue,
        );
        expect(
          parsed.filter.isFilterActive(SmartFilterType.moodFocused),
          isFalse,
        );
        expect(parsed.cleanQuery, equals('urgent bugs'));
      },
    );

    test('Multi-filter intersection requires all active chips to match', () {
      final filter = const SmartSearchFilter(
        activeFilters: {SmartFilterType.thisWeek, SmartFilterType.moodFocused},
      );

      final results = filter.apply(moments: allMoments, referenceNow: now);

      expect(results.length, equals(1));
      expect(results.first.id, equals(mFocused.id));
    });

    test(
      'Auto-builds session lookup when sessionLookup is null for #deepwork >2h',
      () {
        final filter = const SmartSearchFilter(
          activeFilters: {SmartFilterType.deepworkOver2h},
        );

        // Pass null for sessionLookup, filter should auto-derive session pair duration
        final results = filter.apply(
          moments: allMoments,
          sessionLookup: null,
          referenceNow: now,
        );

        expect(results.contains(mDeepworkLongIn), isTrue);
        expect(results.contains(mDeepworkShort), isFalse);
      },
    );

    test(
      'Auto-builds session lookup for checkpoints:done filtering ongoing sessions',
      () {
        final filter = const SmartSearchFilter(
          activeFilters: {SmartFilterType.checkpointsDone},
        );

        final uncompletedInCheckpoint = Moment(
          id: 99,
          timestamp: now
              .subtract(const Duration(minutes: 30))
              .millisecondsSinceEpoch,
          type: 'in',
          date: '2026-10-24',
          note: 'Ongoing meditation checkpoint',
          tags: ['checkpoint:meditation'],
        );

        final completedInCheckpoint = Moment(
          id: 100,
          timestamp: now
              .subtract(const Duration(minutes: 90))
              .millisecondsSinceEpoch,
          type: 'in',
          date: '2026-10-24',
          note: 'Completed workout checkpoint',
          tags: ['checkpoint:workout'],
        );
        final completedOutCheckpoint = Moment(
          id: 101,
          timestamp: now
              .subtract(const Duration(minutes: 45))
              .millisecondsSinceEpoch,
          type: 'out',
          date: '2026-10-24',
          note: 'Finished workout',
          tags: ['checkpoint:workout'],
        );

        final testMoments = [
          uncompletedInCheckpoint,
          completedInCheckpoint,
          completedOutCheckpoint,
        ];

        final results = filter.apply(
          moments: testMoments,
          sessionLookup: null,
          referenceNow: now,
        );

        // The uncompleted 'in' without 'out' is omitted
        expect(results.contains(uncompletedInCheckpoint), isFalse);
        // The completed pair is included
        expect(results.contains(completedInCheckpoint), isTrue);
      },
    );
  });
}
