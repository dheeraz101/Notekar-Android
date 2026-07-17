import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/utils/backup_utils.dart';

void main() {
  const firstTs = 1718000000000;
  const secondTs = 1718086400000;

  String backupJson({
    Object? entries,
    Map<String, Object?> settings = const {},
  }) {
    return jsonEncode({
      'app': 'NoteKar',
      'kind': 'backup',
      'version': '4.0.2',
      'build': '11',
      'exportedAt': '2026-06-10T08:00:00.000',
      'settings': settings,
      'entries':
          entries ??
          [
            {
              'id': 1,
              'timestamp': firstTs,
              'type': 'single',
              'date': 'wrong-date-is-normalized',
              'note': 'First note',
            },
            {
              'id': 2,
              'timestamp': secondTs,
              'type': 'in',
              'date': '2024-06-11',
              'note': '',
            },
          ],
    });
  }

  test('validates and normalizes a NoteKar backup before import', () {
    final result = validateNoteKarBackupContent(
      backupJson(settings: {'theme': 'amoled', 'tapDelay': 10}),
    );

    expect(result.isValid, isTrue);
    expect(result.entries, hasLength(2));
    expect(result.entries.first.timestamp, secondTs);
    expect(result.entries.last.note, 'First note');
    expect(result.entries.last.date, '2024-06-10');
    expect(result.exportedAt, DateTime(2026, 6, 10, 8));
  });

  test('rejects corrupted JSON without throwing', () {
    final result = validateNoteKarBackupContent('{not json');

    expect(result.isValid, isFalse);
    expect(result.error, 'Backup is not valid JSON');
  });

  test('rejects damaged backup rows', () {
    final result = validateNoteKarBackupContent(
      backupJson(entries: ['bad-row']),
    );

    expect(result.isValid, isFalse);
    expect(result.error, contains('damaged moment data'));
  });

  test('dry-run summary reports new moments and duplicates', () {
    final validation = validateNoteKarBackupContent(
      backupJson(settings: {'theme': 'light', 'defaultMode': 'single'}),
    );
    final summary = buildBackupDryRunSummary(
      validation: validation,
      existingEntries: [
        Moment(
          id: 99,
          timestamp: firstTs,
          type: 'single',
          date: '2024-06-10',
          note: 'First note',
        ),
      ],
    );

    expect(summary.backupMoments, 2);
    expect(summary.backupNotes, 1);
    expect(summary.newMoments, 1);
    expect(summary.duplicatesSkipped, 1);
    expect(summary.settingsToRestore, 2);
  });

  test('rejects unknown moment types', () {
    final result = validateNoteKarBackupContent(
      backupJson(
        entries: [
          {'id': 1, 'timestamp': firstTs, 'type': 'sideways', 'note': ''},
        ],
      ),
    );

    expect(result.isValid, isFalse);
    expect(result.error, contains('unknown moment type'));
  });
}
