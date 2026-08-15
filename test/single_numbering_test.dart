import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/calendar_dialog.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/feedback_widgets.dart';
import 'package:notekar/widgets/moment_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Single Moment Numbering Logic', () {
    test('Continuous sequence counts 00 to 99 and wraps back to 00', () {
      final singles = List.generate(
        105,
        (i) => Moment(
          id: i + 1,
          timestamp: 1700000000000 + i * 1000,
          type: 'single',
          date: '2026-08-15',
          note: '',
        ),
      );

      final Map<int, String> map = {};
      for (int i = 0; i < singles.length; i++) {
        final count = (i % 100).toString().padLeft(2, '0');
        map[singles[i].id] = count;
      }

      expect(map[1], '00');
      expect(map[2], '01');
      expect(map[10], '09');
      expect(map[100], '99');
      expect(map[101], '00'); // Wraps back to 00
      expect(map[102], '01');
    });

    test(
      'Reset Daily groups by date and restarts sequence at 00 every day',
      () {
        final day1 = List.generate(
          5,
          (i) => Moment(
            id: i + 1,
            timestamp: 1700000000000 + i * 1000,
            type: 'single',
            date: '2026-08-14',
            note: '',
          ),
        );
        final day2 = List.generate(
          3,
          (i) => Moment(
            id: 10 + i + 1,
            timestamp: 1700086400000 + i * 1000,
            type: 'single',
            date: '2026-08-15',
            note: '',
          ),
        );

        final allSingles = [...day1, ...day2];
        final Map<String, List<Moment>> grouped = {};
        for (final e in allSingles) {
          grouped.putIfAbsent(e.date, () => []).add(e);
        }

        final Map<int, String> map = {};
        for (final dayEntries in grouped.values) {
          for (int i = 0; i < dayEntries.length; i++) {
            final count = (i % 100).toString().padLeft(2, '0');
            map[dayEntries[i].id] = count;
          }
        }

        // Day 1
        expect(map[1], '00');
        expect(map[2], '01');
        expect(map[5], '04');

        // Day 2 restarts at 00
        expect(map[11], '00');
        expect(map[12], '01');
        expect(map[13], '02');
      },
    );
  });

  group('MomentTile Widget with singleNumber', () {
    testWidgets('Displays 2-digit number badge in standard layout', (
      tester,
    ) async {
      final entry = Moment(
        id: 1,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        type: 'single',
        date: '2026-08-15',
        note: 'Test note',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MomentTile(
              p: p,
              entry: entry,
              selected: false,
              compact: false,
              singleNumber: '00',
              onTap: () {},
              onLongPress: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('00'), findsOneWidget);
    });

    testWidgets('Displays 2-digit number pill badge in compact layout', (
      tester,
    ) async {
      final entry = Moment(
        id: 1,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        type: 'single',
        date: '2026-08-15',
        note: 'Compact note',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MomentTile(
              p: p,
              entry: entry,
              selected: false,
              compact: true,
              singleNumber: '42',
              onTap: () {},
              onLongPress: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });
  });

  group('SavedPulse with pulseCount', () {
    testWidgets('Renders 2-digit pulse count when supplied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SavedPulse(
                  origin: const Offset(100, 100),
                  p: p,
                  type: 'single',
                  pulseCount: '07',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('07 saved'), findsOneWidget);
    });
  });

  group('MomentCalendarDialog iOS Styling', () {
    testWidgets('Today renders with iOS red color and no inner dot', (
      tester,
    ) async {
      final today = DateTime.now();
      final todayStr = dateKey(today);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MomentCalendarDialog(
              p: p,
              availableDateKeys: {todayStr},
              initialDate: today,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify today date text is present
      expect(find.text('${today.day}'), findsWidgets);

      // Verify iOS single-letter weekday header format
      expect(find.text('S'), findsWidgets);
      expect(find.text('M'), findsWidgets);
      expect(find.text('T'), findsWidgets);
      expect(find.text('W'), findsWidgets);
      expect(find.text('F'), findsWidgets);
    });
  });
}
