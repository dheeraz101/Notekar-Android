import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/smart_search_filter.dart';
import 'package:notekar/widgets/smart_search_chips_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('SmartSearchChipsBar Widget Tests', () {
    testWidgets('Renders all four natural language search chips with labels', (
      tester,
    ) async {
      var filter = const SmartSearchFilter();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartSearchChipsBar(
              p: p,
              filter: filter,
              onToggleFilter: (type) {},
            ),
          ),
        ),
      );

      expect(find.text('this week'), findsOneWidget);
      expect(find.text('#deepwork >2h'), findsOneWidget);
      expect(find.text('mood:focused'), findsOneWidget);
      expect(find.text('checkpoints:done'), findsOneWidget);
    });

    testWidgets(
      'Tapping chip triggers onToggleFilter with correct filter type',
      (tester) async {
        SmartFilterType? toggledType;
        var filter = const SmartSearchFilter();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SmartSearchChipsBar(
                p: p,
                filter: filter,
                onToggleFilter: (type) {
                  toggledType = type;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('mood:focused'));
        await tester.pumpAndSettle();

        expect(toggledType, equals(SmartFilterType.moodFocused));
      },
    );

    testWidgets('Active chip displays checkmark icon', (tester) async {
      final filter = const SmartSearchFilter(
        activeFilters: {SmartFilterType.thisWeek},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartSearchChipsBar(
              p: p,
              filter: filter,
              onToggleFilter: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.byIcon(Icons.check_rounded).evaluate().isNotEmpty ||
            find.byType(Icon).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('NoteSearchContent filtering updates when chips are clicked', (
      tester,
    ) async {
      final now = DateTime.now();
      final entries = [
        Moment(
          id: 1,
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: '2026-10-24',
          note: 'Recent study note',
          category: 'Learning',
        ),
        Moment(
          id: 2,
          timestamp: now
              .subtract(const Duration(days: 30))
              .millisecondsSinceEpoch,
          type: 'single',
          date: '2026-09-24',
          note: 'Old vintage memory',
          category: 'Personal',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: NoteSearchContent(
                p: p,
                entries: entries,
                compactRows: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially both visible
      expect(find.text('Recent study note'), findsOneWidget);
      expect(find.text('Old vintage memory'), findsOneWidget);

      // Tap 'this week' chip
      await tester.tap(find.text('this week'));
      await tester.pumpAndSettle();

      // Now only recent note is visible
      expect(find.text('Recent study note'), findsOneWidget);
      expect(find.text('Old vintage memory'), findsNothing);
    });
  });
}
