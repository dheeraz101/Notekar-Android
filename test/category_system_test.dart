import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/modes_categories_settings_page.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/widgets/home_category_pills.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Category System - Data Models & Helpers', () {
    test('Moment encodes and decodes category explicitly', () {
      final now = DateTime.now();
      final moment = Moment(
        id: 1,
        timestamp: now.millisecondsSinceEpoch,
        type: 'single',
        date: '2026-09-12',
        note: 'Writing code',
        category: 'Work',
      );

      final json = moment.toJson();
      expect(json['category'], 'Work');

      final decoded = Moment.fromJson(json);
      expect(decoded.category, 'Work');
      expect(decoded.note, 'Writing code');
    });

    test('Moment decodes category passively from #hashtags in note', () {
      final now = DateTime.now();
      final jsonWork = {
        'id': 2,
        'timestamp': now.millisecondsSinceEpoch,
        'type': 'single',
        'note': '#work Meeting with stakeholders',
      };
      final decodedWork = Moment.fromJson(jsonWork);
      expect(decodedWork.category, 'Work');

      final jsonFocus = {
        'id': 3,
        'timestamp': now.millisecondsSinceEpoch,
        'type': 'single',
        'note': 'Writing deep algorithms #deepfocus',
      };
      final decodedFocus = Moment.fromJson(jsonFocus);
      expect(decodedFocus.category, 'Deep Focus');

      final jsonPlain = {
        'id': 4,
        'timestamp': now.millisecondsSinceEpoch,
        'type': 'single',
        'note': 'Just regular note without tags',
      };
      final decodedPlain = Moment.fromJson(jsonPlain);
      expect(decodedPlain.category, isNull);
    });

    test(
      'CategoryService manages default, custom, and active categories',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = CategoryService();

        final defaults = await service.getCategories(prefs: prefs);
        expect(defaults, containsAll(['Work', 'Deep Focus']));

        // Add custom category
        final added = await service.addCategory('Reading', prefs: prefs);
        expect(added, isTrue);

        final withCustom = await service.getCategories(prefs: prefs);
        expect(withCustom, contains('Reading'));

        // Duplicate prevention
        final dup = await service.addCategory('reading', prefs: prefs);
        expect(dup, isFalse);

        // Active category
        expect(await service.getActiveCategory(prefs: prefs), 'All');
        await service.setActiveCategory('Work', prefs: prefs);
        expect(await service.getActiveCategory(prefs: prefs), 'Work');

        // Cannot delete default category
        final delDefault = await service.deleteCategory('Work', prefs: prefs);
        expect(delDefault, isFalse);

        // Can delete custom category
        final delCustom = await service.deleteCategory('Reading', prefs: prefs);
        expect(delCustom, isTrue);
        expect(
          await service.getCategories(prefs: prefs),
          isNot(contains('Reading')),
        );
      },
    );

    test('TimelineDaySection computes category breakdown and summary text', () {
      final now = DateTime.now();
      final t1 = now.subtract(const Duration(hours: 3)).millisecondsSinceEpoch;
      final t2 = now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch;

      final session = TimelineSessionItem(
        inMoment: Moment(
          id: 1,
          timestamp: t1,
          type: 'in',
          date: '2026-09-12',
          category: 'Work',
        ),
        outMoment: Moment(
          id: 2,
          timestamp: t2,
          type: 'out',
          date: '2026-09-12',
        ),
      );

      final single = TimelineSingleItem(
        moment: Moment(
          id: 3,
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: '2026-09-12',
          note: '#study math revision',
        ),
      );

      final daySection = TimelineDaySection(
        dateKey: '2026-09-12',
        date: now,
        displayTitle: 'TODAY',
        totalTrackedDuration: const Duration(hours: 2, minutes: 15),
        totalLogs: 3,
        items: [session, single],
      );

      expect(daySection.categoryBreakdown['Work'], const Duration(hours: 2));
      expect(
        daySection.categoryBreakdown['Study'],
        const Duration(minutes: 15),
      );
      expect(daySection.categorySummaryText, contains('Work 2h'));
      expect(daySection.categorySummaryText, contains('Study 15m'));
    });
  });

  group('Category System - UI Widgets', () {
    testWidgets('HomeCategoryPills renders categories and handles selection', (
      WidgetTester tester,
    ) async {
      final p = paletteFor('dark');
      String selected = 'All';
      bool addPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HomeCategoryPills(
                  p: p,
                  categories: const ['Work', 'Deep Focus'],
                  activeCategory: selected,
                  onSelectCategory: (cat) {
                    setState(() => selected = cat);
                  },
                  onAddCategory: () {
                    addPressed = true;
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Deep Focus'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      // Tap "Work"
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      expect(selected, 'Work');

      // Tap active "Work" toggles back to "All"
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      expect(selected, 'All');

      // Tap "Add"
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(addPressed, isTrue);
    });

    testWidgets(
      'ModesCategoriesSettingsPage renders modes and opens category detail',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final p = paletteFor('dark');

        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: now
                .subtract(const Duration(hours: 2))
                .millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-12',
            category: 'Work',
          ),
          Moment(
            id: 2,
            timestamp: now.millisecondsSinceEpoch,
            type: 'out',
            date: '2026-09-12',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ModesCategoriesSettingsPage(p: p, entries: entries),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Modes & Categories'), findsOneWidget);
        expect(find.text('Work'), findsOneWidget);
        expect(find.text('Deep Focus'), findsOneWidget);
        expect(find.text('Create New Category / Mode'), findsOneWidget);

        // Tap Work to open category detail sheet
        await tester.tap(find.text('Work'));
        await tester.pumpAndSettle();

        expect(find.text('TOTAL FOCUS'), findsOneWidget);
        expect(find.text('SESSIONS'), findsOneWidget);
        expect(find.text('CATEGORY TIMELINE'), findsOneWidget);
        expect(find.text('CATEGORY INSIGHTS'), findsOneWidget);
      },
    );
  });
}
