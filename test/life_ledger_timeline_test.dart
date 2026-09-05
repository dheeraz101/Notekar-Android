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
  });
}
