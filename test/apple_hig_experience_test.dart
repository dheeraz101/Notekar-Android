import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/settings/modes_categories_settings_page.dart';
import 'package:notekar/dialogs/sunday_dispatch_sheet.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/widgets/dynamic_header_capsule.dart';
import 'package:notekar/widgets/home_clock_complication.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPalette = Palette(
    name: 'dark',
    bg: const Color(0xFF000000),
    surface: const Color(0xFF1C1C1E),
    surface2: const Color(0xFF2C2C2E),
    surface3: const Color(0xFF3A3A3C),
    border: const Color(0xFF38383A),
    text: const Color(0xFFFFFFFF),
    text2: const Color(0xFFEBEBF5),
    text3: const Color(0xFF8E8E93),
    clock: const Color(0xFFFFFFFF),
    accent: const Color(0xFF007AFF),
    green: const Color(0xFF34C759),
    orange: const Color(0xFFFF9500),
    red: const Color(0xFFFF3B30),
    blue: const Color(0xFF007AFF),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Apple HIG 7-Color System & CategoryService', () {
    test('CategoryService defines exactly 7 Apple HIG system colors', () {
      expect(CategoryService.appleHigColors.length, 7);
      expect(
        CategoryService.appleHigColors[0],
        const Color(0xFF007AFF),
      ); // Blue
      expect(
        CategoryService.appleHigColors[1],
        const Color(0xFF5856D6),
      ); // Indigo
      expect(
        CategoryService.appleHigColors[2],
        const Color(0xFFAF52DE),
      ); // Purple
      expect(
        CategoryService.appleHigColors[3],
        const Color(0xFFFF2D55),
      ); // Pink
      expect(CategoryService.appleHigColors[4], const Color(0xFFFF3B30)); // Red
      expect(
        CategoryService.appleHigColors[5],
        const Color(0xFFFF9500),
      ); // Orange
      expect(
        CategoryService.appleHigColors[6],
        const Color(0xFF34C759),
      ); // Green
    });

    test(
      'addCategory persists custom Apple HIG color and getCategoryMeta resolves it',
      () async {
        final service = CategoryService();
        const customColor = Color(0xFFFF9500); // Orange
        final added = await service.addCategory(
          'Photography',
          color: customColor,
        );
        expect(added, isTrue);

        final color = service.getCategoryColor('Photography');
        expect(color, customColor);

        final meta = getCategoryMeta('Photography', testPalette);
        expect(meta.name, 'Photography');
        expect(meta.color, customColor);
      },
    );
  });

  group('History Sheet Refinements', () {
    testWidgets(
      'HistoryDialog has search icon in trailing header next to close',
      (tester) async {
        bool searchOpened = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryDialog(
                p: testPalette,
                entries: const [],
                compactRows: false,
                largeText: false,
                minimalMomentOptions: false,
                confirmDelete: false,
                onDelete: (_) async {},
                onRestore: (_) async {},
                onUpdateNote: (_, _) async {},
                onDuration: (_, _) {},
                onOpenSearchNotes: () => searchOpened = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final searchFinder = find.byIcon(CupertinoIcons.search);
        expect(searchFinder, findsOneWidget);

        await tester.tap(searchFinder);
        await tester.pump();
        expect(searchOpened, isTrue);
      },
    );

    testWidgets(
      'HistoryDialog embeds Today inline insight card in scrollable view',
      (tester) async {
        final now = DateTime.now();
        final todayDate = dateKey(now);
        final List<Moment> entries = [
          Moment(
            id: 1,
            type: 'out',
            timestamp: now
                .subtract(const Duration(minutes: 45))
                .millisecondsSinceEpoch,
            note: 'Deep focus architecture #Work',
            date: todayDate,
            category: 'Work',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryDialog(
                p: testPalette,
                entries: entries,
                compactRows: false,
                largeText: false,
                minimalMomentOptions: false,
                confirmDelete: false,
                onDelete: (_) async {},
                onRestore: (_) async {},
                onUpdateNote: (_, _) async {},
                onDuration: (_, _) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify inline insight card header is present in scroll view
        expect(find.text("TODAY'S INSIGHTS"), findsOneWidget);
        expect(find.text('Tracked'), findsOneWidget);
        expect(find.text('Longest Flow'), findsOneWidget);
        expect(find.text('Peak Hour'), findsOneWidget);
      },
    );
  });

  group('DynamicHeaderCapsule Widget', () {
    testWidgets('Renders resting 34px capsule and smoothly expands on tap', (
      tester,
    ) async {
      final now = DateTime.now();
      final todayDate = dateKey(now);
      final List<Moment> entries = [
        Moment(
          id: 1,
          type: 'out',
          timestamp: now
              .subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          note: 'Flow session',
          date: todayDate,
          category: 'Work',
        ),
      ];

      bool expandedState = false;
      String selected = 'All';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DynamicHeaderCapsule(
                p: testPalette,
                entries: entries,
                categories: const ['Work', 'Deep Focus', 'Study'],
                activeCategory: selected,
                onSelectCategory: (cat) => selected = cat,
                onAddCategory: () {},
                onExpansionChanged: (exp) => expandedState = exp,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In resting state: shows chevron down
      expect(find.byIcon(CupertinoIcons.chevron_down), findsOneWidget);
      expect(find.text('MODES & RHYTHM'), findsNothing);

      // Tap resting capsule to expand
      await tester.tap(find.byType(DynamicHeaderCapsule));
      await tester.pumpAndSettle();

      expect(expandedState, isTrue);
      expect(find.text('MODES & RHYTHM'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chevron_up), findsOneWidget);

      // Tap close chevron to collapse
      await tester.tap(find.byIcon(CupertinoIcons.chevron_up));
      await tester.pumpAndSettle();

      expect(expandedState, isFalse);
      expect(find.byIcon(CupertinoIcons.chevron_down), findsOneWidget);
    });
  });

  group('HomeClockComplication Widget', () {
    testWidgets('Renders Intentionality complication', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeClockComplication(
              p: testPalette,
              style: 'intentionality',
              entries: const [],
              streak: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0m / 10h'), findsOneWidget);
      expect(find.text('0% Intentional'), findsOneWidget);
    });

    testWidgets('Renders Streak complication', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeClockComplication(
              p: testPalette,
              style: 'streak',
              entries: const [],
              streak: 14,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('14 days streak'), findsOneWidget);
      expect(find.text('Active Flow'), findsOneWidget);
    });

    testWidgets('Renders Circadian complication', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeClockComplication(
              p: testPalette,
              style: 'circadian',
              entries: const [],
              streak: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Circadian'), findsOneWidget);
    });

    testWidgets('Renders Void complication as empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeClockComplication(
              p: testPalette,
              style: 'void',
              entries: const [],
              streak: 5,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsNothing);
    });
  });

  group('Sunday Evening Dispatch Sheet', () {
    testWidgets('Renders retrospective digest and save archive button', (
      tester,
    ) async {
      final now = DateTime.now();
      final List<Moment> entries = [
        Moment(
          id: 1,
          type: 'out',
          timestamp: now
              .subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
          note: 'Code refactoring #Work',
          date: dateKey(now.subtract(const Duration(days: 2))),
          category: 'Work',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SundayDispatchSheet(p: testPalette, entries: entries),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sunday Dispatch'), findsOneWidget);
      expect(find.text('A Week of Deliberate Focus'), findsOneWidget);
      expect(find.text('Conscious Focus'), findsOneWidget);
      expect(find.text('Peak Circadian'), findsOneWidget);
      expect(find.text('Save to Sovereign Archive'), findsOneWidget);

      // Tap Save to Sovereign Archive
      await tester.tap(
        find.text('Save to Sovereign Archive'),
        warnIfMissed: false,
      );
      await tester.pump();
    });
  });

  group('Manual Entry & Timeline Pairing Bug Fixes', () {
    test(
      'buildTimelineDaySections handles simultaneous in and out timestamps cleanly without creating zombie live session',
      () {
        final now = DateTime.now();
        final ms = now.millisecondsSinceEpoch;
        final day = dateKey(now);

        final entries = [
          Moment(
            id: 1,
            type: 'in',
            timestamp: ms,
            note: 'Focus #Work',
            date: day,
            category: 'Work',
          ),
          Moment(
            id: 2,
            type: 'out',
            timestamp: ms,
            note: '',
            date: day,
            category: 'Work',
          ),
        ];

        final sections = buildTimelineDaySections(entries);
        expect(sections.length, 1);
        final items = sections.first.items;
        expect(items.length, 1);
        expect(items.first, isA<TimelineSessionItem>());
        final session = items.first as TimelineSessionItem;
        expect(session.isOngoing, isFalse);
        expect(session.endTimestamp, ms);
        expect(session.momentIds, containsAll([1, 2]));
      },
    );

    test(
      'buildTimelineDaySections auto-closes past unclosed session when subsequent sessions exist',
      () {
        final now = DateTime.now();
        final ms1 = now
            .subtract(const Duration(hours: 3))
            .millisecondsSinceEpoch;
        final ms2 = now
            .subtract(const Duration(hours: 2))
            .millisecondsSinceEpoch;
        final ms3 = now
            .subtract(const Duration(hours: 1))
            .millisecondsSinceEpoch;
        final day = dateKey(now);

        final entries = [
          Moment(
            id: 1,
            type: 'in',
            timestamp: ms1,
            note: 'Old unclosed',
            date: day,
            category: 'Work',
          ),
          Moment(
            id: 2,
            type: 'in',
            timestamp: ms2,
            note: 'New session',
            date: day,
            category: 'Deep Focus',
          ),
          Moment(
            id: 3,
            type: 'out',
            timestamp: ms3,
            note: '',
            date: day,
            category: 'Deep Focus',
          ),
        ];

        final sections = buildTimelineDaySections(entries);
        expect(sections.length, 1);
        final items = sections.first.items;
        expect(items.length, 2);

        // Newest session is first (reverse chrono): started at ms2, closed at ms3
        final newSession = items[0] as TimelineSessionItem;
        expect(newSession.isOngoing, isFalse);
        expect(newSession.endTimestamp, ms3);

        // Oldest session is second: started at ms1, remains ongoing until ended explicitly
        final oldSession = items[1] as TimelineSessionItem;
        expect(oldSession.isOngoing, isTrue);
        expect(oldSession.outMoment, isNull);
      },
    );

    testWidgets(
      'HistoryDialog triggers onEndLiveSession when End button tapped on live session',
      (tester) async {
        final now = DateTime.now();
        final ms = now.millisecondsSinceEpoch;
        final day = dateKey(now);

        Moment? endedOutMoment;

        final entries = [
          Moment(
            id: 1,
            type: 'in',
            timestamp: ms,
            note: 'Current live session',
            date: day,
            category: 'Work',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryDialog(
                p: testPalette,
                entries: entries,
                compactRows: false,
                largeText: false,
                minimalMomentOptions: false,
                confirmDelete: false,
                onDelete: (_) async {},
                onRestore: (_) async {},
                onEndLiveSession: (inMomentId, outEntry) async {
                  endedOutMoment = outEntry;
                },
                onUpdateNote: (_, _) async {},
                onDuration: (_, _) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final endButton = find.text('End');
        expect(endButton, findsOneWidget);

        await tester.tap(endButton);
        await tester.pumpAndSettle();

        expect(endedOutMoment, isNotNull);
        expect(endedOutMoment!.type, 'out');
        expect(endedOutMoment!.category, 'Work');
      },
    );
  });

  group('Mode Color Customization in Settings', () {
    testWidgets(
      'ModeDetailSettingsPage renders Apple HIG colors and allows changing color',
      (tester) async {
        bool changedNotified = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ModeDetailSettingsPage(
                  p: testPalette,
                  category: 'Work',
                  entries: const [],
                  onCategoriesChanged: () => changedNotified = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('MODE COLOR'), findsOneWidget);
        expect(find.text('CATEGORY TIMELINE'), findsOneWidget);

        // Tap Indigo swatch (#5856D6)
        final indigoSwatch = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color ==
                  CategoryService.appleHigColors[1],
        );
        expect(indigoSwatch, findsOneWidget);
        await tester.tap(indigoSwatch);
        await tester.pumpAndSettle();

        expect(changedNotified, isTrue);
        expect(
          CategoryService().getCategoryColor('Work'),
          CategoryService.appleHigColors[1],
        );
      },
    );
  });
}
