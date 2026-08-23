import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/time_reflection_settings_page.dart';
import 'package:notekar/dialogs/time_reflection_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/backup_utils.dart';
import 'package:notekar/utils/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsController & Palette Tests', () {
    test('SettingsController initializes with default values', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = SettingsController(prefs);

      expect(controller.theme, 'dark');
      expect(controller.accentColor, 'blue');
      expect(controller.showSeconds, isTrue);
      expect(controller.confirmDelete, isTrue);
    });

    test('SettingsController updates theme and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = SettingsController(prefs);

      var notified = false;
      controller.addListener(() => notified = true);

      await controller.setTheme('light');

      expect(controller.theme, 'light');
      expect(notified, isTrue);
      expect(prefs.getString('theme'), 'light');
    });

    test('paletteFor returns correct color surfaces for theme modes', () {
      final dark = paletteFor('dark');
      final light = paletteFor('light');
      final amoled = paletteFor('amoled');

      expect(dark.name, 'dark');
      expect(light.name, 'light');
      expect(amoled.name, 'amoled');
      expect(amoled.bg, Colors.black);
    });
  });

  group('Async Isolate & Backup Tests', () {
    test(
      'validateNoteKarBackupContentAsync parses valid JSON payload',
      () async {
        final jsonPayload = jsonEncode({
          'app': 'NoteKar',
          'kind': 'backup',
          'version': '4.0.4',
          'entries': [
            {
              'id': 1,
              'timestamp': 1718000000000,
              'type': 'single',
              'note': 'Test note',
            },
          ],
        });

        final result = await validateNoteKarBackupContentAsync(jsonPayload);
        expect(result.isValid, isTrue);
        expect(result.entries, hasLength(1));
      },
    );
  });

  group('Build Channel Codes & Priority Release Tests', () {
    test('kAppBuildNumber adheres to YY<CHANNEL>MMDD format with SR/BR/PR', () {
      expect(kAppBuildNumber, matches(r'^\d{2}(BR|SR|PR)\d{4}[a-z]?$'));
    });
  });

  group('Time Reflection & Mindfulness Tests', () {
    testWidgets(
      'TimeReflectionSheet renders mindfulness elements and actions',
      (tester) async {
        final p = paletteFor('dark');
        var logTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeReflectionSheet(
                p: p,
                intervalMinutes: 60,
                onLogMoment: () => logTapped = true,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Time Reflection'), findsOneWidget);
        expect(find.text('Take a Mindful Breath'), findsOneWidget);
        expect(find.text('1 Hour Has Passed'), findsOneWidget);
        expect(find.text('Log Current Moment'), findsOneWidget);
        expect(find.text('Continue Mindfully'), findsOneWidget);

        await tester.tap(find.text('Log Current Moment'));
        await tester.pump();
        expect(logTapped, isTrue);
      },
    );

    testWidgets(
      'TimeReflectionSettingsPage renders settings, rationale, and 4-step practice guide',
      (tester) async {
        final p = paletteFor('dark');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TimeReflectionSettingsPage(
                  p: p,
                  reflectionReminderEnabled: true,
                  reflectionReminderIntervalMins: 60,
                  reflectionReminderSound: true,
                  onToggleReflectionReminder: (_) {},
                  onTapReflectionInterval: (_) {},
                  onToggleReflectionSound: (_) {},
                  onPreviewReflectionSheet: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Mindfulness'), findsWidgets);
        expect(find.text('Enable Time Reflection'), findsOneWidget);
        expect(find.text('WHY TIME REFLECTION?'), findsOneWidget);
        expect(find.text('HOW TO USE IT EFFECTIVELY'), findsOneWidget);
        expect(find.text('Take Three Deep Breaths'), findsOneWidget);
        expect(find.text('Acknowledge the Elapsed Hour'), findsOneWidget);
        expect(find.text('Set One Focus For Next Hour'), findsOneWidget);
        expect(find.text('Log a Quick Moment'), findsOneWidget);
      },
    );
  });
}
