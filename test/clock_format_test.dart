import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/clock_face.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark');

  group('Clock Format Utilities', () {
    final afternoon = DateTime(2026, 9, 15, 14, 30, 45).millisecondsSinceEpoch;
    final midnight = DateTime(2026, 9, 15, 0, 15, 0).millisecondsSinceEpoch;
    final noon = DateTime(2026, 9, 15, 12, 0, 0).millisecondsSinceEpoch;

    test('timeOnly formats in 24-hour mode by default', () {
      setGlobalUse24Hour(true);
      expect(timeOnly(afternoon), '14:30:45');
      expect(timeOnly(midnight), '00:15:00');
      expect(timeOnly(noon), '12:00:00');
    });

    test('timeOnly formats in 12-hour AM/PM mode when use24Hour is false', () {
      expect(timeOnly(afternoon, use24Hour: false), '2:30:45 PM');
      expect(timeOnly(midnight, use24Hour: false), '12:15:00 AM');
      expect(timeOnly(noon, use24Hour: false), '12:00:00 PM');
    });

    test('formatTimeShort formats in 24-hour and 12-hour modes', () {
      expect(formatTimeShort(afternoon, use24Hour: true), '14:30');
      expect(formatTimeShort(afternoon, use24Hour: false), '2:30 PM');
      expect(formatTimeShort(midnight, use24Hour: false), '12:15 AM');
    });

    test('globalUse24Hour affects default format if not overridden', () {
      setGlobalUse24Hour(false);
      expect(globalUse24Hour, isFalse);
      expect(formatTimeShort(afternoon), '2:30 PM');

      setGlobalUse24Hour(true);
      expect(globalUse24Hour, isTrue);
      expect(formatTimeShort(afternoon), '14:30');
    });
  });

  group('ClockFace Widget', () {
    testWidgets('renders 24-hour time correctly', (tester) async {
      final afternoonDt = DateTime(2026, 9, 15, 14, 30, 45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockFace(
              now: afternoonDt,
              p: p,
              pulseToken: 0,
              pulseType: 'single',
              minimal: false,
              showSeconds: true,
              highlightSeconds: true,
              use24HourFormat: true,
            ),
          ),
        ),
      );

      expect(find.text('14:30'), findsOneWidget);
      expect(find.text('.45'), findsOneWidget);
      expect(find.text('PM'), findsNothing);
    });

    testWidgets('renders 12-hour time cleanly without AM/PM label', (
      tester,
    ) async {
      final afternoonDt = DateTime(2026, 9, 15, 14, 30, 45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockFace(
              now: afternoonDt,
              p: p,
              pulseToken: 0,
              pulseType: 'single',
              minimal: false,
              showSeconds: true,
              highlightSeconds: true,
              use24HourFormat: false,
            ),
          ),
        ),
      );

      expect(find.text('2:30'), findsOneWidget);
      expect(find.text('.45'), findsOneWidget);
      expect(find.text('PM'), findsNothing);
    });

    testWidgets('renders 12-hour midnight with 12:05 without AM label', (
      tester,
    ) async {
      final midnightDt = DateTime(2026, 9, 15, 0, 5, 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockFace(
              now: midnightDt,
              p: p,
              pulseToken: 0,
              pulseType: 'single',
              minimal: false,
              showSeconds: false,
              highlightSeconds: false,
              use24HourFormat: false,
            ),
          ),
        ),
      );

      expect(find.text('12:05'), findsOneWidget);
      expect(find.text('.10'), findsNothing);
      expect(find.text('AM'), findsNothing);
    });
  });
}
