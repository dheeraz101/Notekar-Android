import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/personalization_setup_dialog.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/utils/dashboard_metrics_service.dart';
import 'package:notekar/widgets/executive_dashboard_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Valid 1x1 transparent PNG image bytes for memory image decoder
  final validPngBytes = Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    11,
    73,
    68,
    65,
    84,
    120,
    156,
    99,
    96,
    0,
    0,
    0,
    2,
    0,
    1,
    244,
    113,
    100,
    4,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130,
  ]);

  group('UserProfileService & Personalization System', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with sane defaults', () async {
      final service = UserProfileService();
      await service.loadProfile();

      expect(service.name, isEmpty);
      expect(service.dob, isNull);
      expect(service.avatarBytes, isNull);
      expect(service.presetAvatarIndex, isNull);
      expect(service.mementoMoriYears, equals(80));
      expect(service.isOnboardingCompleted, isFalse);
    });

    test('Saves and loads user profile correctly', () async {
      final service = UserProfileService();
      final birthDate = DateTime(2000, 1, 1);

      await service.saveProfile(
        name: 'Dheeraj',
        dob: birthDate,
        customAvatarBytes: validPngBytes,
        mementoMoriYears: 85,
        completeOnboarding: true,
      );

      expect(service.name, equals('Dheeraj'));
      expect(service.dob, equals(birthDate));
      expect(service.avatarBytes, isNotNull);
      expect(service.avatarBytes!.length, equals(validPngBytes.length));
      expect(service.presetAvatarIndex, isNull);
      expect(service.mementoMoriYears, equals(85));
      expect(service.isOnboardingCompleted, isTrue);

      // Reload to ensure persistence
      await service.loadProfile();
      expect(service.name, equals('Dheeraj'));
      expect(service.dob, equals(birthDate));
      expect(service.avatarBytes!.length, equals(validPngBytes.length));
      expect(service.mementoMoriYears, equals(85));
      expect(service.isOnboardingCompleted, isTrue);
    });

    test(
      'Strictly enforces 100-year ceiling on Memento Mori life expectancy',
      () async {
        final service = UserProfileService();

        // Attempt to save 120 years
        await service.saveProfile(name: 'Alex', mementoMoriYears: 120);
        expect(service.mementoMoriYears, equals(100));

        // Attempt to save 250 years
        await service.saveProfile(name: 'Alex', mementoMoriYears: 250);
        expect(service.mementoMoriYears, equals(100));

        // Attempt to save 0 or negative years
        await service.saveProfile(name: 'Alex', mementoMoriYears: -10);
        expect(service.mementoMoriYears, equals(1));
      },
    );

    test(
      'Calculates exact age and lived vs remaining horizon correctly',
      () async {
        final service = UserProfileService();
        // Exactly 20 years before reference date
        final refDate = DateTime(2025, 1, 1);
        final birthDate = DateTime(2005, 1, 1);

        await service.saveProfile(
          name: 'Sam',
          dob: birthDate,
          mementoMoriYears: 80,
        );

        final horizon = service.calculateLifeHorizon(asOf: refDate);
        expect(horizon.hasDob, isTrue);
        expect(horizon.ageYears, equals(20));
        expect(horizon.targetYears, equals(80));
        expect(horizon.livedWeeks, greaterThan(1000));
        expect(horizon.remainingWeeks, greaterThan(3000));
        expect(horizon.totalWeeks, equals((80 * 365.2425).round() ~/ 7));
        expect(horizon.livedPercentage, closeTo(0.25, 0.03));
      },
    );

    test('Calculates focus vs rest vs untracked productivity breakdown', () {
      final service = UserProfileService();
      final now = DateTime(2026, 9, 25, 12, 0);
      final start = now.subtract(const Duration(hours: 10));

      final entries = [
        Moment(
          id: 1,
          timestamp: now
              .subtract(const Duration(hours: 8))
              .millisecondsSinceEpoch,
          type: 'in',
          date: '2026-09-25',
          category: 'Work',
        ),
        Moment(
          id: 2,
          timestamp: now
              .subtract(const Duration(hours: 6))
              .millisecondsSinceEpoch,
          type: 'out',
          date: '2026-09-25',
          category: 'Work',
        ),
        Moment(
          id: 3,
          timestamp: now
              .subtract(const Duration(hours: 4))
              .millisecondsSinceEpoch,
          type: 'in',
          date: '2026-09-25',
          category: 'Rest',
        ),
        Moment(
          id: 4,
          timestamp: now
              .subtract(const Duration(hours: 2))
              .millisecondsSinceEpoch,
          type: 'out',
          date: '2026-09-25',
          category: 'Rest',
        ),
      ];

      final prod = service.calculateProductivity(
        entries: entries,
        start: start,
        end: now,
      );

      expect(prod.periodTotal, equals(const Duration(hours: 10)));
      expect(prod.trackedFocus.inHours, equals(2)); // 8h ago to 6h ago
      expect(prod.claimedRest.inHours, equals(2)); // 4h ago to 2h ago
      expect(prod.untrackedOrWasted.inHours, equals(6)); // Remaining 6h
      expect(prod.focusPercentage, closeTo(0.2, 0.01));
      expect(prod.restPercentage, closeTo(0.2, 0.01));
      expect(prod.untrackedPercentage, closeTo(0.6, 0.01));
    });
  });

  group('Category Minimal Glyph Icons Integration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Persists and retrieves custom category glyph icons', () async {
      final catService = CategoryService();
      await catService.setCategoryIcon('Deep Focus', Icons.code_rounded);

      final icon = catService.getCategoryIcon('Deep Focus');
      expect(icon, equals(Icons.code_rounded));

      // Check CategoryMeta integration
      final meta = getCategoryMeta('Deep Focus', paletteFor('dark'));
      expect(meta.icon, equals(Icons.code_rounded));
    });
  });

  group('Personalization UI Widgets', () {
    final p = paletteFor('dark');

    testWidgets(
      'PersonalizationSetupDialog renders all configuration controls',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PersonalizationSetupDialog(p: p, isFirstTime: true),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Personalize NoteKar'), findsOneWidget);
        expect(find.text('YOUR NAME'), findsOneWidget);
        expect(find.text('DATE OF BIRTH'), findsOneWidget);
        expect(find.text('MEMENTO MORI HORIZON'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);
      },
    );

    testWidgets('MementoMoriLifeHorizonCard renders horizon metrics', (
      tester,
    ) async {
      final profile = UserProfileService();
      await profile.saveProfile(
        name: 'Aurelius',
        dob: DateTime(1995, 4, 26),
        mementoMoriYears: 85,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MementoMoriLifeHorizonCard(
              p: p,
              entries: const [],
              timeframe: DashboardTimeframe.week,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MEMENTO MORI'), findsOneWidget);
      expect(find.text('Life Horizon'), findsOneWidget);
      expect(find.text('Lived So Far'), findsOneWidget);
      expect(find.text('Horizon Left'), findsOneWidget);
      expect(find.textContaining('Seneca'), findsOneWidget);
    });
  });
}
