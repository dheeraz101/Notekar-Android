import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/palette.dart';
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
    test('validateNoteKarBackupContentAsync parses valid JSON payload', () async {
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
          }
        ],
      });

      final result = await validateNoteKarBackupContentAsync(jsonPayload);
      expect(result.isValid, isTrue);
      expect(result.entries, hasLength(1));
      expect(result.entries.first.note, 'Test note');
    });
  });
}
