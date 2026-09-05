import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/timeline_session_card.dart';
import 'package:notekar/widgets/timeline_single_tile.dart';

void main() {
  final p = paletteFor('dark');

  group('Life Ledger Timeline Logic & Session Pairing Tests', () {
    test(
      'Pairs in and out moments into connected session card with accurate duration',
      () {
        final now = DateTime(2026, 9, 5, 12, 0);
        final inTime = DateTime(2026, 9, 5, 9, 15);
        final outTime = DateTime(2026, 9, 5, 11, 0); // 1h 45m session
        final singleTime = DateTime(2026, 9, 5, 11, 30);

        final moments = [
          Moment(
            id: 3,
            timestamp: singleTime.millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(now),
            note: 'Quick call',
          ),
          Moment(
            id: 2,
            timestamp: outTime.millisecondsSinceEpoch,
            type: 'out',
            date: dateKey(now),
            note: '',
          ),
          Moment(
            id: 1,
            timestamp: inTime.millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(now),
            note: 'Rust backend work',
          ),
        ];

        final sections = buildTimelineDaySections(moments);
        expect(sections.length, 1);
        final sec = sections.first;
        expect(sec.totalLogs, 3);
        expect(sec.totalTrackedDuration.inMinutes, 105); // 1h 45m
        expect(sec.formattedTrackedDuration, '1h 45m');
        expect(sec.summaryText, contains('1h 45m tracked • 3 logs'));

        expect(sec.items.length, 2);
        expect(sec.items.any((it) => it is TimelineSessionItem), isTrue);
        expect(sec.items.any((it) => it is TimelineSingleItem), isTrue);

        final session =
            sec.items.firstWhere((it) => it is TimelineSessionItem)
                as TimelineSessionItem;
        expect(session.isOngoing, isFalse);
        expect(session.inMoment.id, 1);
        expect(session.outMoment?.id, 2);
        expect(session.duration.inMinutes, 105);
        expect(session.note, 'Rust backend work');
      },
    );

    test('Marks in moment without out as ongoing live session', () {
      final now = DateTime(2026, 9, 5, 10, 0);
      final moments = [
        Moment(
          id: 10,
          timestamp: now
              .subtract(const Duration(minutes: 38))
              .millisecondsSinceEpoch,
          type: 'in',
          date: dateKey(now),
          note: 'Active coding session',
        ),
      ];

      final sections = buildTimelineDaySections(moments);
      expect(sections.length, 1);
      final sec = sections.first;
      expect(sec.items.length, 1);

      final session = sec.items.first as TimelineSessionItem;
      expect(session.isOngoing, isTrue);
      expect(session.outMoment, isNull);
      expect(session.duration.inMinutes, greaterThanOrEqualTo(37));
    });

    test(
      'Pairs midnight-crossing session into start day section with full duration',
      () {
        final inTime = DateTime(2026, 9, 4, 23, 45);
        final outTime = DateTime(2026, 9, 5, 0, 30); // 45m across midnight

        final moments = [
          Moment(
            id: 1,
            timestamp: inTime.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-04',
            note: 'Night owl session',
          ),
          Moment(
            id: 2,
            timestamp: outTime.millisecondsSinceEpoch,
            type: 'out',
            date: '2026-09-05',
            note: '',
          ),
        ];

        final sections = buildTimelineDaySections(moments);
        expect(sections.length, 1);
        final sec = sections.first;
        expect(sec.dateKey, '2026-09-04');
        expect(sec.totalTrackedDuration.inMinutes, 45);
        expect(sec.totalLogs, 2);

        final session = sec.items.first as TimelineSessionItem;
        expect(session.isOngoing, isFalse);
        expect(session.inMoment.id, 1);
        expect(session.outMoment?.id, 2);
        expect(session.duration.inMinutes, 45);
      },
    );

    test(
      'Closing an older live session with a later out moment ends it cleanly',
      () {
        final inTime = DateTime(2026, 9, 4, 21, 0); // Yesterday
        final moments = [
          Moment(
            id: 1,
            timestamp: inTime.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-04',
            note: 'Evening work',
          ),
        ];

        // Initially ongoing
        var sections = buildTimelineDaySections(moments);
        var session = sections.first.items.first as TimelineSessionItem;
        expect(session.isOngoing, isTrue);

        // Simulated "End" action creates an out moment today:
        final outTime = DateTime(2026, 9, 5, 1, 30);
        final outEntry = Moment(
          id: 2,
          timestamp: outTime.millisecondsSinceEpoch,
          type: 'out',
          date: '2026-09-05',
          note: '',
        );

        final updatedMoments = [outEntry, ...moments];
        sections = buildTimelineDaySections(updatedMoments);
        expect(sections.length, 1);
        session = sections.first.items.first as TimelineSessionItem;
        expect(session.isOngoing, isFalse);
        expect(session.outMoment, isNotNull);
        expect(session.outMoment?.id, 2);
        expect(session.duration.inMinutes, 270); // 4h 30m
      },
    );

    test(
      'Multiple in moments: Ending older session pairs it without breaking newer session',
      () {
        final t1 = DateTime(2026, 9, 5, 9, 0).millisecondsSinceEpoch;
        final t2 = DateTime(2026, 9, 5, 12, 0).millisecondsSinceEpoch;
        final t3 = DateTime(2026, 9, 5, 13, 0).millisecondsSinceEpoch;

        final moments = [
          Moment(
            id: 1,
            timestamp: t1,
            type: 'in',
            date: '2026-09-05',
            note: 'Session 1',
          ),
          Moment(
            id: 2,
            timestamp: t2,
            type: 'in',
            date: '2026-09-05',
            note: 'Session 2',
          ),
          Moment(
            id: 3,
            timestamp: t3,
            type: 'out',
            date: '2026-09-05',
            note: '',
          ),
        ];

        // Session 1 is unclosed, Session 2 is closed
        var sections = buildTimelineDaySections(moments);
        var s1 = sections.first.items
            .whereType<TimelineSessionItem>()
            .firstWhere((s) => s.inMoment.id == 1);
        expect(s1.isOngoing, isTrue);

        // Targeted end of Session 1: out moment placed before Session 2 starts
        final out1 = Moment(
          id: 4,
          timestamp: t2 - 1000,
          type: 'out',
          date: '2026-09-05',
          note: '',
        );

        final updated = [out1, ...moments];
        sections = buildTimelineDaySections(updated);
        expect(sections.length, 1);
        final sessionItems = sections.first.items
            .whereType<TimelineSessionItem>()
            .toList();
        expect(sessionItems.length, 2);

        final updatedS1 = sessionItems.firstWhere((s) => s.inMoment.id == 1);
        final updatedS2 = sessionItems.firstWhere((s) => s.inMoment.id == 2);

        expect(updatedS1.isOngoing, isFalse);
        expect(updatedS1.outMoment?.id, 4);
        expect(updatedS2.isOngoing, isFalse);
        expect(updatedS2.outMoment?.id, 3);
      },
    );
  });

  group('Timeline Widgets Tests', () {
    testWidgets(
      'TimelineSessionCard displays start time, duration badge, end time, and note',
      (tester) async {
        final inTime = DateTime(2026, 9, 5, 9, 15);
        final outTime = DateTime(2026, 9, 5, 11, 0);

        final session = TimelineSessionItem(
          inMoment: Moment(
            id: 1,
            timestamp: inTime.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-05',
            note: 'Fixed auth token bug',
          ),
          outMoment: Moment(
            id: 2,
            timestamp: outTime.millisecondsSinceEpoch,
            type: 'out',
            date: '2026-09-05',
            note: '',
          ),
        );

        bool editTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSessionCard(
                p: p,
                session: session,
                onEditNote: () => editTapped = true,
                onDeleteSession: () {},
              ),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (w) => w is IosEmojiText && w.text == 'Fixed auth token bug',
          ),
          findsOneWidget,
        );
        expect(find.text('1h 45m'), findsOneWidget);

        await tester.tap(
          find.byWidgetPredicate(
            (w) => w is IosEmojiText && w.text == 'Fixed auth token bug',
          ),
        );
        await tester.pump();
        expect(editTapped, isTrue);
      },
    );

    testWidgets(
      'TimelineSingleTile renders timeline rail node and tap-to-add-note placeholder',
      (tester) async {
        final moment = Moment(
          id: 99,
          timestamp: DateTime(2026, 9, 5, 16, 20).millisecondsSinceEpoch,
          type: 'single',
          date: '2026-09-05',
          note: '',
        );

        bool editNoteCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSingleTile(
                p: p,
                moment: moment,
                onEditNote: () => editNoteCalled = true,
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text('Tap to add quick note...'), findsOneWidget);

        await tester.tap(find.text('Tap to add quick note...'));
        await tester.pump();
        expect(editNoteCalled, isTrue);
      },
    );

    testWidgets(
      'TimelineSessionCard ongoing session renders live indicator cleanly without overflow',
      (tester) async {
        final inTime = DateTime.now().subtract(const Duration(minutes: 38));
        final ongoingSession = TimelineSessionItem(
          inMoment: Moment(
            id: 10,
            timestamp: inTime.millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(DateTime.now()),
            note: 'Ongoing deep work session',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSessionCard(
                p: p,
                session: ongoingSession,
                onEditNote: () {},
                onDeleteSession: () {},
              ),
            ),
          ),
        );

        expect(find.textContaining('LIVE'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) => w is IosEmojiText && w.text == 'Ongoing deep work session',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'TimelineSessionCard ongoing session renders End button and triggers callback',
      (tester) async {
        final inTime = DateTime.now().subtract(const Duration(minutes: 20));
        final ongoingSession = TimelineSessionItem(
          inMoment: Moment(
            id: 20,
            timestamp: inTime.millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(DateTime.now()),
            note: 'Live study session',
          ),
        );

        bool endSessionCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSessionCard(
                p: p,
                session: ongoingSession,
                onEditNote: () {},
                onDeleteSession: () {},
                onEndSession: () => endSessionCalled = true,
              ),
            ),
          ),
        );

        expect(find.text('End'), findsOneWidget);
        expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);

        await tester.tap(find.text('End'));
        await tester.pump();

        expect(endSessionCalled, isTrue);
      },
    );

    test('fullDateLabel formats correctly', () {
      expect(fullDateLabel('2026-09-05'), '05 Sep 2026');
      expect(fullDateLabel('2026-01-01'), '01 Jan 2026');
      expect(fullDateLabel('2026-12-31'), '31 Dec 2026');
    });
  });
}
