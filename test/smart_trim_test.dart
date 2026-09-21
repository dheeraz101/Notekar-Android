import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/smart_trim_sheet.dart';
import 'package:notekar/models/palette.dart';

void main() {
  final p = paletteFor('dark');

  group('SmartTrimSheet Tests', () {
    testWidgets(
      'renders session summary, Keep Full button, and smart preset chips for 4-hour session',
      (tester) async {
        final start = DateTime(2026, 9, 21, 10, 0);
        final end = DateTime(2026, 9, 21, 14, 0); // 4 hours

        DateTime? chosenResult;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    chosenResult = await showSmartTrimSheet(
                      context,
                      p: p,
                      startDateTime: start,
                      originalEndDateTime: end,
                      category: 'Deep Focus',
                    );
                  },
                  child: const Text('Open Trim'),
                ),
              ),
            ),
          ),
        );

        // Tap to open sheet
        await tester.tap(find.text('Open Trim'));
        await tester.pumpAndSettle();

        // Verify summary header
        expect(find.text('4h in Deep Focus'), findsOneWidget);
        expect(
          find.text('Did you finish earlier, or was this continuous flow?'),
          findsOneWidget,
        );

        // Verify Keep Full button
        expect(find.text('Keep Full 4h'), findsOneWidget);

        // Verify preset chips
        expect(find.text('Trim to 90m Flow'), findsOneWidget);
        expect(find.text('Trim to 2 Hours'), findsOneWidget);
        expect(find.text('Trim to 45m'), findsOneWidget);

        // Tap "Trim to 90m Flow"
        await tester.tap(find.text('Trim to 90m Flow'));
        await tester.pumpAndSettle();

        // Verify result is 90 minutes after start
        expect(chosenResult, equals(start.add(const Duration(minutes: 90))));
      },
    );

    testWidgets('tapping Keep Full button returns original end time', (
      tester,
    ) async {
      final start = DateTime(2026, 9, 21, 10, 0);
      final end = DateTime(2026, 9, 21, 13, 30); // 3.5 hours

      DateTime? chosenResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  chosenResult = await showSmartTrimSheet(
                    context,
                    p: p,
                    startDateTime: start,
                    originalEndDateTime: end,
                    category: 'Coding',
                  );
                },
                child: const Text('Open Trim'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Trim'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keep Full 3h 30m'));
      await tester.pumpAndSettle();

      expect(chosenResult, equals(end));
    });
  });
}
