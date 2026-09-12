import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/settings/search_notes_settings_page.dart';
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

    testWidgets(
      'TimelineSessionCard renders high-density layout in compact mode',
      (tester) async {
        final inTime = DateTime(2026, 9, 5, 10, 0);
        final outTime = DateTime(2026, 9, 5, 11, 15);
        final sessionWithNote = TimelineSessionItem(
          inMoment: Moment(
            id: 50,
            timestamp: inTime.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-05',
            note: 'Compact note test',
          ),
          outMoment: Moment(
            id: 51,
            timestamp: outTime.millisecondsSinceEpoch,
            type: 'out',
            date: '2026-09-05',
            note: '',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSessionCard(
                p: p,
                session: sessionWithNote,
                compact: true,
                onEditNote: () {},
                onDeleteSession: () {},
              ),
            ),
          ),
        );

        expect(find.text('1h 15m'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) => w is IosEmojiText && w.text == 'Compact note test',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'TimelineSessionCard in compact mode omits placeholder box when note is empty',
      (tester) async {
        final inTime = DateTime(2026, 9, 5, 10, 0);
        final outTime = DateTime(2026, 9, 5, 10, 45);
        final sessionNoNote = TimelineSessionItem(
          inMoment: Moment(
            id: 60,
            timestamp: inTime.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-05',
            note: '',
          ),
          outMoment: Moment(
            id: 61,
            timestamp: outTime.millisecondsSinceEpoch,
            type: 'out',
            date: '2026-09-05',
            note: '',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSessionCard(
                p: p,
                session: sessionNoNote,
                compact: true,
                onEditNote: () {},
                onDeleteSession: () {},
              ),
            ),
          ),
        );

        expect(find.text('45m'), findsOneWidget);
        // In compact mode, empty note placeholder is omitted to save vertical space
        expect(find.text('Tap to add session note...'), findsNothing);
      },
    );

    testWidgets('TimelineSingleTile renders compact layout correctly', (
      tester,
    ) async {
      final moment = Moment(
        id: 70,
        timestamp: DateTime(2026, 9, 5, 14, 30).millisecondsSinceEpoch,
        type: 'single',
        date: '2026-09-05',
        note: 'Coffee break',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineSingleTile(
              p: p,
              moment: moment,
              singleNumber: '1',
              compact: true,
              onEditNote: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is IosEmojiText && w.text == 'Coffee break',
        ),
        findsOneWidget,
      );
    });

    testWidgets('ActionConfirmSheet renders as standard CupertinoAlertDialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  showIosConfirmSheet(
                    ctx,
                    p: p,
                    title: 'Delete Item?',
                    message: 'This cannot be undone.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Delete Item?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets(
      'HistoryDialog shows undo pill with progress bar and without icon on delete, and tapping Undo restores',
      (tester) async {
        final now = DateTime.now();
        final moment = Moment(
          id: 101,
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(now),
          note: 'Task to undo',
        );

        int? deletedId;
        Moment? restoredMoment;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryDialog(
                p: p,
                entries: [moment],
                compactRows: false,
                largeText: false,
                minimalMomentOptions: false,
                confirmDelete: false,
                onDelete: (id) async => deletedId = id,
                onRestore: (m) async => restoredMoment = m,
                onUpdateNote: (_, _) async {},
                onDuration: (_, _) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Drag to delete the item
        await tester.drag(
          find.byType(TimelineSingleTile),
          const Offset(-500, 0),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(deletedId, 101);
        expect(find.text('Moment removed'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        // Verify that the old icon is removed
        expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
        expect(find.byIcon(Icons.info_outline_rounded), findsNothing);

        // Verify that the progress bar exists (FractionallySizedBox)
        expect(find.byType(FractionallySizedBox), findsWidgets);

        // Tap Undo
        await tester.tap(find.text('Undo'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(restoredMoment?.id, 101);
        expect(find.text('Moment removed'), findsNothing);
      },
    );

    testWidgets(
      'HistoryDialog shows undo pill when note is added and tapping Undo reverts note',
      (tester) async {
        final now = DateTime.now();
        final moment = Moment(
          id: 202,
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(now),
          note: '',
        );

        String? updatedNote;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryDialog(
                p: p,
                entries: [moment],
                compactRows: false,
                largeText: false,
                minimalMomentOptions: false,
                confirmDelete: false,
                onDelete: (_) async {},
                onRestore: (_) async {},
                onUpdateNote: (id, note) async => updatedNote = note,
                onDuration: (_, _) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the tap-to-add-note area on the tile
        await tester.tap(find.text('Tap to add quick note...'));
        await tester.pumpAndSettle();

        expect(find.byType(NoteDialog), findsOneWidget);

        // Enter note text and tap Add Note
        await tester.enterText(find.byType(TextField), 'Deep focus session');
        await tester.tap(find.byType(FilledButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 300));

        expect(updatedNote, 'Deep focus session');
        expect(find.text('Note added'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);
        expect(find.byType(FractionallySizedBox), findsWidgets);

        // Tap Undo
        await tester.tap(find.text('Undo'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(updatedNote, '');
        expect(find.text('Note removed'), findsOneWidget);
      },
    );

    testWidgets(
      'SearchNotesSettingsPage displays 80% notes and 20% mode info (Single vs 2-Way with in/out times and duration)',
      (tester) async {
        final day = DateTime(2026, 9, 12, 10, 0);
        final inTime = DateTime(2026, 9, 12, 9, 0);
        final outTime = DateTime(2026, 9, 12, 10, 30); // 1h 30m
        final singleTime = DateTime(2026, 9, 12, 14, 0);

        final entries = [
          Moment(
            id: 1,
            timestamp: inTime.millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(day),
            note: 'Morning architecture planning',
          ),
          Moment(
            id: 2,
            timestamp: outTime.millisecondsSinceEpoch,
            type: 'out',
            date: dateKey(day),
            note: '',
          ),
          Moment(
            id: 3,
            timestamp: singleTime.millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(day),
            note: 'Reviewed pull request #ios',
          ),
        ];

        final searchController = TextEditingController();
        final searchFocus = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return CustomScrollView(
                    slivers: SearchNotesSettingsPage.buildSlivers(
                      context: context,
                      p: p,
                      entries: entries,
                      settingsQuery: '',
                      onQueryChanged: (_) {},
                      onClearQuery: () {},
                      settingsSearchController: searchController,
                      settingsSearchFocusNode: searchFocus,
                      compactHistory: false,
                      reduceMotion: false,
                      enableTranslucency: false,
                      recentSearches: [],
                      onSaveRecentSearch: (_) {},
                      onClearRecentSearches: () {},
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 2-Way badge and timing for the paired session
        expect(find.text('2-WAY'), findsOneWidget);
        expect(
          find.text(
            'IN ${timeOnly(inTime.millisecondsSinceEpoch)}',
            findRichText: true,
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'OUT ${timeOnly(outTime.millisecondsSinceEpoch)}',
            findRichText: true,
          ),
          findsOneWidget,
        );
        expect(find.text('1h 30m'), findsOneWidget);
        expect(
          find.text('Morning architecture planning', findRichText: true),
          findsOneWidget,
        );

        // Single badge and timing for the single moment
        expect(find.text('SINGLE'), findsOneWidget);
        expect(
          find.text(
            timeOnly(singleTime.millisecondsSinceEpoch),
            findRichText: true,
          ),
          findsOneWidget,
        );
        expect(
          find.text('Reviewed pull request #ios', findRichText: true),
          findsOneWidget,
        );
      },
    );
  });
}
