import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/backup_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4: Cross-Midnight Arithmetic Tests', () {
    test(
      'calculateIntervalDuration computes intra-day and cross-midnight intervals accurately',
      () {
        // Intra-day: 14:00 to 16:30 (2h 30m = 150m)
        final start1 = DateTime(2026, 11, 3, 14, 0);
        final end1 = DateTime(2026, 11, 3, 16, 30);
        final dur1 = calculateIntervalDuration(start1, end1);
        expect(dur1.inMinutes, equals(150));

        // Cross-midnight: start at 23:30, end at 01:15 on clock (end < start)
        // Rollover produces +1 day: 23:30 to next day 01:15 (1h 45m = 105m)
        final startMidnight = DateTime(2026, 11, 3, 23, 30);
        final endMidnightClock = DateTime(2026, 11, 3, 1, 15);
        final durMidnight = calculateIntervalDuration(
          startMidnight,
          endMidnightClock,
        );
        expect(durMidnight.inMinutes, equals(105));
      },
    );
  });

  group('Phase 4: Localization & Lock Delay Tests', () {
    test('privacyLockDelayLabel returns formatted labels', () {
      expect(privacyLockDelayLabel(0), equals('Immediately'));
      expect(privacyLockDelayLabel(1), equals('After 1 Min'));
      expect(privacyLockDelayLabel(5), equals('After 5 Min'));
      expect(privacyLockDelayLabel(10), equals('After 10 Min'));
    });
  });

  group('Phase 4: Backup Hardening & Dual-Path Payload Tests', () {
    test(
      'bundleCompressedBackup and extractBackupJson roundtrip successfully',
      () {
        final sampleJson = jsonEncode({
          'app': 'NoteKar',
          'kind': 'backup',
          'version': 1,
          'entries': [
            {
              'id': 1,
              'timestamp': 1762100000000,
              'type': 'in',
              'note': 'Midnight meditation session',
              'category': 'Focus',
            },
          ],
          'settings': {'theme': 'dark'},
        });

        // Compress to .notekar bundle
        final bundle = bundleCompressedBackup(sampleJson);
        expect(bundle.startsWith('H4sI'), isTrue);

        // Extract JSON back
        final extracted = extractBackupJson(bundle);
        expect(extracted, equals(sampleJson));

        // Dual-path validation: validateNoteKarBackupContent validates both
        final validationPlain = validateNoteKarBackupContent(sampleJson);
        expect(validationPlain.isValid, isTrue);
        expect(validationPlain.entries.length, equals(1));

        final validationBundle = validateNoteKarBackupContent(bundle);
        expect(validationBundle.isValid, isTrue);
        expect(validationBundle.entries.length, equals(1));
        expect(
          validationBundle.entries.first.note,
          equals('Midnight meditation session'),
        );
      },
    );
  });
}
