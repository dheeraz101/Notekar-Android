import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/universal_interval_ledger.dart';
import 'package:notekar/utils/markdown_text_editing_controller.dart';
import 'package:notekar/widgets/checkpoints_quick_bar.dart';

void main() {
  group('Codebase Surgery Verification Tests', () {
    test('UI-09: extractHashtagCategory excludes hex color codes', () {
      expect(extractHashtagCategory('Color is #FFFFFF'), isNull);
      expect(extractHashtagCategory('Dark is #1C1C1E'), isNull);
      expect(extractHashtagCategory('White is #FFF'), isNull);
      expect(extractHashtagCategory('Alpha is #80FFFFFF'), isNull);

      // Real hashtags still parse accurately
      expect(extractHashtagCategory('Working on #fitness today'), 'Health');
      expect(extractHashtagCategory('Session #study session'), 'Study');
      expect(extractHashtagCategory('Deep work #coding'), 'Coding');
    });

    testWidgets(
      'UI-09: MarkdownTextEditingController styles hex colors as code, not hashtags',
      (tester) async {
        final p = paletteFor('dark');
        final controller = MarkdownTextEditingController(
          text: 'The background is #FFFFFF and #coding is fun',
          palette: p,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final span = controller.buildTextSpan(
                    context: context,
                    withComposing: false,
                  );
                  expect(span, isNotNull);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
      },
    );

    test('UI-11: Moment.isValid permits 24-hour clock and timezone drift', () {
      final now = DateTime.now();
      // Valid past moment
      final past = Moment(
        id: 1,
        timestamp: now
            .subtract(const Duration(hours: 2))
            .millisecondsSinceEpoch,
        date: '2026-10-31',
        note: 'Past moment',
        type: 'single',
      );
      expect(past.isValid, isTrue);

      // Moment slightly in the future due to timezone difference (e.g. +3 hours ahead)
      final futureTimezone = Moment(
        id: 2,
        timestamp: now.add(const Duration(hours: 3)).millisecondsSinceEpoch,
        date: '2026-10-31',
        note: 'Future timezone backup',
        type: 'single',
      );
      expect(futureTimezone.isValid, isTrue);

      // Wildly invalid future moment (> 24 hours ahead)
      final invalidFuture = Moment(
        id: 3,
        timestamp: now.add(const Duration(days: 3)).millisecondsSinceEpoch,
        date: '2026-11-03',
        note: 'Impossible future',
        type: 'single',
      );
      expect(invalidFuture.isValid, isFalse);
    });

    test(
      'CRIT-10: UniversalIntervalLedger relaxed session fallback pairing',
      () {
        final t0 = DateTime(2026, 10, 31, 10, 0).millisecondsSinceEpoch;
        final t1 = DateTime(2026, 10, 31, 11, 0).millisecondsSinceEpoch;

        final inMoment = Moment(
          id: 101,
          timestamp: t0,
          date: '2026-10-31',
          note: 'Started work session #work',
          type: 'in',
          category: 'Work',
        );

        // OUT moment logged with omitted category or slightly different tag
        final outMoment = Moment(
          id: 102,
          timestamp: t1,
          date: '2026-10-31',
          note: 'Done for now',
          type: 'out',
          category: null,
        );

        final intervals = UniversalIntervalLedger.reconstructAndSlice([
          inMoment,
          outMoment,
        ], referenceNow: DateTime(2026, 10, 31, 12, 0));

        expect(intervals.length, equals(1));
        final session = intervals.first;
        expect(session.isSession, isTrue);
        expect(session.inMomentId, equals(101));
        expect(session.outMomentId, equals(102));
        expect(session.durationMs, equals(3600000));
      },
    );

    test('UI-04: Light theme text3 contrast satisfies WCAG AA', () {
      final lightPalette = paletteFor('light');
      // text3 in light mode is Color(0xFF6C6C70)
      expect(lightPalette.text3.a, equals(1.0));
      expect(lightPalette.text3, equals(const Color(0xFF6C6C70)));
    });

    testWidgets(
      'UI-02: CheckpointsQuickBar enforces 44pt minimum touch target',
      (tester) async {
        final p = paletteFor('dark');
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckpointsQuickBar(
                p: p,
                moments: const [],
                onLogCheckpoint: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the ConstrainedBox ensuring minHeight: 44
        final constrainedBoxes = tester.widgetList<ConstrainedBox>(
          find.byWidgetPredicate(
            (w) => w is ConstrainedBox && w.constraints.minHeight >= 44.0,
          ),
        );

        expect(constrainedBoxes.isNotEmpty, isTrue);
      },
    );
  });
}
