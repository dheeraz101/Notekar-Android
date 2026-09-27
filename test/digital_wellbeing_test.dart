import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/digital_wellbeing_service.dart';
import 'package:notekar/widgets/digital_wellbeing_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DigitalWellbeing Models & Logic Tests', () {
    test('AppUsageEntry parses correctly and formats duration', () {
      final entry = AppUsageEntry.fromMap({
        'packageName': 'com.android.chrome',
        'name': 'Chrome',
        'category': 'Productivity',
        'durationMs': 3600000 + (15 * 60 * 1000), // 1h 15m
      });

      expect(entry.packageName, 'com.android.chrome');
      expect(entry.name, 'Chrome');
      expect(entry.category, 'Productivity');
      expect(entry.duration, const Duration(hours: 1, minutes: 15));
      expect(entry.formattedDuration, '1h 15m');
    });

    test('DigitalWellbeingSnapshot parses from map with Smart Buckets', () {
      final snapshot = DigitalWellbeingSnapshot.fromMap({
        'hasPermission': true,
        'totalScreenTimeMs': 4 * 3600 * 1000, // 4 hours
        'unlockCount': 50,
        'categories': {
          'Productivity': 2 * 3600 * 1000, // 2 hours (50%)
          'Social': 1 * 3600 * 1000, // 1 hour (25%)
          'Entertainment': 30 * 60 * 1000, // 30 mins (12.5%)
          'System': 30 * 60 * 1000, // 30 mins (12.5%)
        },
        'topApps': [
          {
            'packageName': 'app.notekar.notekar',
            'name': 'NoteKar',
            'category': 'Productivity',
            'durationMs': 1800000,
          },
        ],
      });

      expect(snapshot.hasPermission, true);
      expect(snapshot.totalScreenTime, const Duration(hours: 4));
      expect(snapshot.formattedTotalScreenTime, '4h 0m');
      expect(snapshot.unlockCount, 50);
      expect(snapshot.getCategoryRatio('Productivity'), 0.5);
      expect(snapshot.getCategoryRatio('Social'), 0.25);
      expect(snapshot.topApps.length, 1);
      expect(snapshot.topApps.first.name, 'NoteKar');
    });

    test('Intentionality ratio calculation contracts', () {
      final snapshot = DigitalWellbeingSnapshot.fromMap({
        'hasPermission': true,
        'totalScreenTimeMs': 4 * 3600 * 1000, // 4 hours
        'unlockCount': 40,
        'categories': {},
        'topApps': [],
      });

      // 2 hours tracked out of 4 hours screen time = 50%
      final ratio50 = snapshot.computeIntentionalityRatio(
        const Duration(hours: 2),
      );
      expect(ratio50, closeTo(0.5, 0.001));

      // 4 hours tracked out of 4 hours screen time = 100%
      final ratio100 = snapshot.computeIntentionalityRatio(
        const Duration(hours: 4),
      );
      expect(ratio100, 1.0);

      // Clamp test: 6 hours tracked out of 4 hours screen time = 100%
      final clamped = snapshot.computeIntentionalityRatio(
        const Duration(hours: 6),
      );
      expect(clamped, 1.0);

      // Mindful pickups ratio
      // 20 moments logged out of 40 unlocks = 50%
      expect(snapshot.computeMindfulPickupRatio(20), closeTo(0.5, 0.001));
    });
  });

  group('DigitalWellbeingCard Widget Tests', () {
    final palette = paletteFor('dark');

    testWidgets('Renders opt-in card when permission is not granted', (
      tester,
    ) async {
      DigitalWellbeingService().snapshotNotifier.value =
          DigitalWellbeingSnapshot.empty;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DigitalWellbeingCard(
              p: palette,
              todayTrackedDuration: const Duration(hours: 1),
              todayMomentsCount: 5,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Connect Screen Time'), findsOneWidget);
      expect(find.text('Enable Screen Time Insights'), findsOneWidget);
      expect(
        find.textContaining('Unlock your true Intentionality Ratio'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Renders full reality delta metrics when permission is active',
      (tester) async {
        DigitalWellbeingService().snapshotNotifier.value =
            DigitalWellbeingSnapshot.fromMap({
              'hasPermission': true,
              'totalScreenTimeMs': 4 * 3600 * 1000, // 4 hours
              'unlockCount': 35,
              'categories': {
                'Productivity': 2 * 3600 * 1000,
                'Social': 1 * 3600 * 1000,
                'Entertainment': 3600 * 1000,
                'System': 0,
              },
              'topApps': [
                {
                  'packageName': 'com.google.android.youtube',
                  'name': 'YouTube',
                  'category': 'Entertainment',
                  'durationMs': 3600 * 1000,
                },
              ],
            });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DigitalWellbeingCard(
                p: palette,
                todayTrackedDuration: const Duration(hours: 2),
                todayMomentsCount: 14,
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Digital Wellbeing · Reality Delta'), findsOneWidget);
        expect(find.text('INTENTIONAL FOCUS'), findsOneWidget);
        expect(find.text('2h 0m'), findsOneWidget);
        expect(find.text('SCREEN TIME'), findsOneWidget);
        expect(find.text('4h 0m'), findsOneWidget);
        expect(find.text('50% Intentional'), findsOneWidget);
        expect(find.text('35 pickups'), findsOneWidget);
        expect(find.text('14 moments logged'), findsOneWidget);
        expect(find.text('SMART CATEGORY DISTRIBUTION'), findsOneWidget);
        expect(find.text('TOP APPS TODAY'), findsOneWidget);
        expect(find.text('YouTube'), findsOneWidget);
      },
    );
  });
}
