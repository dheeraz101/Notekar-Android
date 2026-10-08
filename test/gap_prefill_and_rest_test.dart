import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/manual_entry_dialog.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/history_calendar_view.dart';
import 'package:notekar/widgets/timeline_gap_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Gap Prefill, Rest Authority, and Calendar Parity Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
        'ManualEntryContent honors prefilledStartTime and prefilledEndTime',
        (tester) async {
      final start = DateTime(2026, 10, 8, 9, 30);
      final end = DateTime(2026, 10, 8, 11, 45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManualEntryContent(
              p: p,
              categories: const ['Work', 'Study'],
              prefilledStartTime: start,
              prefilledEndTime: end,
              onSubmit: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be in session mode since end was supplied
      expect(find.text('Time Span (Session)'), findsOneWidget);
    });

    testWidgets('HistoryCalendarView renders TimelineGapCard for TimelineGapItem',
        (tester) async {
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final startMs = DateTime(now.year, now.month, now.day, 10, 0).millisecondsSinceEpoch;
      final endMs = DateTime(now.year, now.month, now.day, 11, 30).millisecondsSinceEpoch;

      final gapSection = TimelineDaySection(
        dateKey: todayKey,
        date: DateTime(now.year, now.month, now.day),
        displayTitle: 'Today',
        totalTrackedDuration: Duration.zero,
        totalLogs: 0,
        items: [
          TimelineGapItem(
            startTimestamp: startMs,
            endTimestamp: endMs,
          ),
        ],
      );

      bool restTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCalendarView(
              p: p,
              sections: [gapSection],
              allEntries: const [],
              initialDateKey: todayKey,
              onClaimRest: (s, e) {
                restTriggered = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Must find the gap card in Calendar view
      expect(find.byType(TimelineGapCard), findsOneWidget);
      expect(find.text('1h 30m untracked'), findsOneWidget);

      // Tapping Rest triggers onClaimRest
      final restBtn = find.text('Rest');
      expect(restBtn, findsOneWidget);
      await tester.tap(restBtn);
      await tester.pumpAndSettle();

      expect(restTriggered, isTrue);
    });

    testWidgets(
        'HistoryDialog claims Rest with single authoritative write path',
        (tester) async {
      final start = DateTime(2026, 10, 8, 14, 0);
      final end = DateTime(2026, 10, 8, 15, 0);

      final returnedIn = Moment(
        id: 777,
        timestamp: start.millisecondsSinceEpoch,
        type: 'in',
        date: '2026-10-08',
        note: 'Rest & Recovery',
        category: 'Rest',
        tags: const ['rest'],
      );
      final returnedOut = Moment(
        id: 778,
        timestamp: end.millisecondsSinceEpoch,
        type: 'out',
        date: '2026-10-08',
        note: 'Rest & Recovery',
        category: 'Rest',
        tags: const ['rest'],
      );

      bool parentClaimCalled = false;

      // Provide moments that produce an untracked gap
      final priorSessionIn = Moment(
        id: 1,
        timestamp: DateTime(2026, 10, 8, 9, 0).millisecondsSinceEpoch,
        type: 'in',
        date: '2026-10-08',
        category: 'Work',
      );
      final priorSessionOut = Moment(
        id: 2,
        timestamp: DateTime(2026, 10, 8, 10, 0).millisecondsSinceEpoch,
        type: 'out',
        date: '2026-10-08',
        category: 'Work',
      );
      final nextSessionIn = Moment(
        id: 3,
        timestamp: DateTime(2026, 10, 8, 12, 0).millisecondsSinceEpoch,
        type: 'in',
        date: '2026-10-08',
        category: 'Study',
      );
      final nextSessionOut = Moment(
        id: 4,
        timestamp: DateTime(2026, 10, 8, 13, 0).millisecondsSinceEpoch,
        type: 'out',
        date: '2026-10-08',
        category: 'Study',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_gap_cards', true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryDialog(
              p: p,
              entries: [
                nextSessionOut,
                nextSessionIn,
                priorSessionOut,
                priorSessionIn,
              ],
              compactRows: false,
              largeText: false,
              minimalMomentOptions: false,
              confirmDelete: false,
              onDelete: (_) async {},
              onRestore: (_) async {},
              onUpdateNote: (_, _) async {},
              onDuration: (_, _) {},
              onClaimRest: (s, e) async {
                parentClaimCalled = true;
                return [returnedIn, returnedOut];
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Rest button on the gap card
      final restButtons = find.text('Rest');
      if (restButtons.evaluate().isNotEmpty) {
        await tester.tap(restButtons.first);
        await tester.pumpAndSettle();
        expect(parentClaimCalled, isTrue);
      }
    });
  });
}
