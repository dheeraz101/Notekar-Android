import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/personalization_settings_page.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/dialogs/shareable_profile_card_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/widgets/settings_widgets.dart';
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
    text2: const Color(0xFF8E8E93),
    text3: const Color(0xFF636366),
    clock: const Color(0xFFFFFFFF),
    accent: const Color(0xFF007AFF),
    green: const Color(0xFF34C759),
    orange: const Color(0xFFFF9500),
    red: const Color(0xFFFF3B30),
    blue: const Color(0xFF007AFF),
  );

  group('1. Accent Color 20 Living Fish Pond', () {
    test('kAccentColorPalette contains exactly 20 distinct accent shades', () {
      expect(kAccentColorPalette.length, equals(20));
      final keys = kAccentColorPalette.map((c) => c.key).toSet();
      expect(keys.length, equals(20));

      for (final item in kAccentColorPalette) {
        final resolvedColor = accentColorFor(item.key);
        expect(resolvedColor, isNotNull);
      }
    });

    testWidgets('PersonalizationSettingsPage renders fish pond sanctuary', (
      tester,
    ) async {
      String selected = 'blue';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonalizationSettingsPage(
              p: testPalette,
              subCategory: 'Accent Color',
              theme: 'dark',
              accentColor: selected,
              appIconStyle: 'default',
              currentLocale: 'en',
              reduceMotion: false,
              enableTranslucency: true,
              onLocaleChanged: (_) {},
              onAccentColorChanged: (key) => selected = key,
              onOpenCategory: (_, {String? parent}) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Liquid Accent Sanctuary'), findsOneWidget);
      expect(find.text('TAP ANY FISH TO HARMONIZE ACCENT'), findsOneWidget);
      expect(find.text('20 Living Species'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('2. MediaStorageService Self-Healing & Multi-Directory Fallback', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('notekar_test_media_');
      MediaStorageService.instance.testRootPath = tempDir.path;
    });

    tearDown(() async {
      MediaStorageService.instance.testRootPath = null;
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'Auto-migrates cached/temp photo to persistent media directory',
      () async {
        final service = MediaStorageService.instance;
        final mediaDir = await service.getMediaDirectory();

        // Create a file simulating a camera capture stored in systemTemp
        final tempSubDir = Directory(
          '${Directory.systemTemp.path}/notekar_media/images',
        );
        await tempSubDir.create(recursive: true);
        final tempCapturedFile = File(
          '${tempSubDir.path}/img_test_capture_9999.jpg',
        );
        await tempCapturedFile.writeAsString('fake_image_bytes_xyz');

        // Resolve via relative path
        final resolved = await service.resolveFile(
          'images/img_test_capture_9999.jpg',
        );

        expect(resolved.existsSync(), isTrue);
        // Verify it was copied to the persistent media directory
        final persistentTarget = File(
          '${mediaDir.path}/images/img_test_capture_9999.jpg',
        );
        expect(persistentTarget.existsSync(), isTrue);
        expect(
          await persistentTarget.readAsString(),
          equals('fake_image_bytes_xyz'),
        );

        // Cleanup
        if (tempCapturedFile.existsSync()) {
          await tempCapturedFile.delete();
        }
      },
    );
  });

  group('3. MomentRepository Database Corruption Quarantine & Recovery', () {
    late Directory testDataDir;

    setUp(() async {
      MomentRepository().resetForTesting();
      testDataDir = await Directory.systemTemp.createTemp('notekar_repo_test_');
    });

    tearDown(() async {
      MomentRepository().resetForTesting();
      try {
        if (testDataDir.existsSync()) {
          await testDataDir.delete(recursive: true);
        }
      } catch (_) {}
    });

    test(
      'Quarantines corrupt files and restores moments from snapshot',
      () async {
        final prefsMap = <String, Object>{};
        SharedPreferences.setMockInitialValues(prefsMap);
        final prefs = await SharedPreferences.getInstance();

        // Seed rolling snapshot in SharedPreferences
        final testMoments = [
          Moment(
            id: 101,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            type: 'Log',
            note: 'Essential moment before crash',
            date: '2026-10-25',
          ),
        ];
        await prefs.setString(
          'notekar.auto_rolling_snapshot',
          jsonEncode(testMoments.map((m) => m.toJson()).toList()),
        );

        // Create mock corrupt database file
        final fakeCorruptDb = File(
          '${testDataDir.path}/notekar_entries_v1.isar',
        );
        await fakeCorruptDb.writeAsString(
          'corrupted_binary_data_header_failure',
        );

        final repo = MomentRepository();
        await repo.initialize(
          preloadedPrefs: prefs,
          directoryPath: testDataDir.path,
        );

        // Explicitly trigger quarantine & recovery on corrupt database file
        await repo.quarantineAndRecoverDatabase(
          directoryPath: testDataDir.path,
          originalError: Exception('Simulated MDBX_CORRUPTED header failure'),
        );

        // Verify that the repository has moments recovered from snapshot
        final moments = repo.getAllMoments();
        expect(moments.isNotEmpty, isTrue);
        expect(moments.first.note, equals('Essential moment before crash'));

        // Verify that the corrupt file was quarantined with .corrupt suffix
        final dirEntities = testDataDir.listSync();
        final quarantinedFiles = dirEntities
            .where((e) => e.path.contains('.corrupt.'))
            .toList();
        expect(quarantinedFiles.isNotEmpty, isTrue);
      },
    );
  });

  group('4. SettingsHeroHeader & Apple HIG Headers', () {
    testWidgets('SettingsHeroHeader renders with icon, title and description', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsHeroHeader(
              p: testPalette,
              icon: CupertinoIcons.sun_max_fill,
              title: 'Display & Visuals',
              subtitle: 'Calibrate typography and theme contrast.',
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Display & Visuals'), findsOneWidget);
      expect(
        find.text('Calibrate typography and theme contrast.'),
        findsOneWidget,
      );
      expect(find.byIcon(CupertinoIcons.sun_max_fill), findsOneWidget);
    });
  });

  group('5. BuildTrackSelectPage Apple Style Copy', () {
    testWidgets('BuildTrackSelectPage renders sovereign Apple copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BuildTrackSelectPage(
                p: testPalette,
                betaTrack: false,
                currentChannel: 'stable',
                onSaveTrackPreference: (_) {},
                onLearnMoreBeta: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Stable Channel'), findsOneWidget);
      expect(find.text('Beta Channel'), findsOneWidget);
      expect(find.text('Developer Experiments'), findsOneWidget);
      expect(
        find.textContaining('Choose how NoteKar receives software updates'),
        findsOneWidget,
      );
    });
  });

  group('6. Shareable Profile Card Chronometer Dial Redesign', () {
    testWidgets(
      'ShareableProfileCardSheet renders Chronometer dial & 24h clock',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_name': 'Dheeraj',
          'user_dob': '2000-01-01',
          'user_target_years': 80,
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ShareableProfileCardSheet(p: testPalette)),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('24-HOUR LIFE CLOCK'), findsOneWidget);
        expect(find.text('WAKING WEEKS'), findsOneWidget);
        expect(find.text('CONSCIOUS TIME'), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );
  });
}
