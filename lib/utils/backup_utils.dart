import 'dart:convert';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/backup_models.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/app_logger.dart';

BackupValidationResult validateNoteKarBackupContent(String content) {
  final logger = AppLogger();
  if (content.length > 25 * 1024 * 1024) { // Increased to 25MB
    return const BackupValidationResult.invalid(
      'Backup is too large to import safely',
    );
  }

  Object? decoded;
  try {
    decoded = jsonDecode(content);
  } catch (e) {
    logger.error('Backup JSON decode failed', e);
    return const BackupValidationResult.invalid('Backup is not valid JSON');
  }

  if (decoded is! Map) {
    return const BackupValidationResult.invalid('Invalid backup structure');
  }

  final data = Map<String, dynamic>.from(decoded);
  if (data['app'] != 'NoteKar') {
    return const BackupValidationResult.invalid('This is not a NoteKar backup');
  }

  final kind = data['kind'];
  if (kind != null && kind != 'backup') {
    return const BackupValidationResult.invalid(
      'This file is not a backup export',
    );
  }

  final rawEntries = data['entries'];
  if (rawEntries is! List) {
    return const BackupValidationResult.invalid(
      'This file does not contain NoteKar moments',
    );
  }

  if (rawEntries.length > 100000) { // Increased limit
    return const BackupValidationResult.invalid(
      'Backup has too many moments to import safely',
    );
  }

  final imported = <Moment>[];
  final now = DateTime.now().millisecondsSinceEpoch;
  final maxFuture = now + const Duration(days: 366).inMilliseconds;

  for (var i = 0; i < rawEntries.length; i++) {
    final row = rawEntries[i];
    if (row is! Map) {
      logger.warn('Damaged moment row at index $i');
      continue; // Skip damaged rows instead of failing entirely
    }

    final item = Map<String, dynamic>.from(row);
    final timestampValue = item['timestamp'];
    
    // Robust validation for timestamp
    if (timestampValue is! num ||
        !timestampValue.isFinite ||
        timestampValue <= 0 ||
        timestampValue > maxFuture) {
      logger.warn('Invalid timestamp at index $i: $timestampValue');
      continue;
    }

    final type = item['type'] is String ? item['type'] as String : 'single';
    final validatedType = {'single', 'in', 'out'}.contains(type) ? type : 'single';

    final noteValue = item['note'];
    final note = (noteValue is String ? noteValue : '').trim();
    
    if (note.length > 2000) { // Limit extremely long notes
      logger.warn('Note too long at index $i, truncating');
    }

    final timestamp = timestampValue.toInt();
    final moment = Moment(
      id: i + 1, // ID will be reassigned during merge
      timestamp: timestamp,
      type: validatedType,
      date: dateKey(DateTime.fromMillisecondsSinceEpoch(timestamp)),
      note: note.length > 2000 ? note.substring(0, 2000) : note,
    );

    if (moment.isValid) {
      imported.add(moment);
    }
  }

  imported.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  final settings = data['settings'] is Map
      ? Map<String, dynamic>.from(data['settings'] as Map)
      : <String, dynamic>{};
  final exportedAt = data['exportedAt'] is String
      ? DateTime.tryParse(data['exportedAt'] as String)
      : null;

  return BackupValidationResult.valid(
    entries: imported,
    settings: settings,
    exportedAt: exportedAt,
  );
}

BackupDryRunSummary buildBackupDryRunSummary({
  required BackupValidationResult validation,
  required List<Moment> existingEntries,
}) {
  // Enhanced key including note to allow moments at same time but with different context
  final existingKeys = existingEntries
      .map((entry) => '${entry.timestamp}|${entry.type}|${entry.note.trim()}')
      .toSet();
  
  var newMoments = 0;
  var duplicates = 0;

  for (final entry in validation.entries) {
    final key = '${entry.timestamp}|${entry.type}|${entry.note.trim()}';
    if (existingKeys.contains(key)) {
      duplicates++;
    } else {
      existingKeys.add(key);
      newMoments++;
    }
  }

  return BackupDryRunSummary(
    backupMoments: validation.entries.length,
    backupNotes: validation.entries
        .where((entry) => entry.note.isNotEmpty)
        .length,
    newMoments: newMoments,
    duplicatesSkipped: duplicates,
    settingsToRestore: restorableBackupSettingsCount(validation.settings),
    exportedAt: validation.exportedAt,
  );
}

int restorableBackupSettingsCount(Map<String, dynamic> settings) {
  var count = 0;
  if (['dark', 'light', 'amoled'].contains(settings['theme'])) count++;
  if (['single', 'two-way'].contains(settings['defaultMode'])) count++;
  final tapDelay = settings['tapDelay'];
  if (tapDelay is num &&
      delayValues.contains(tapDelay.toInt())) {
    count++;
  }
  if (accentOptions.contains(settings['accentColor'])) {
    count++;
  }
  if (isAppIconStyle(settings['appIconStyle'] as String?)) count++;
  if (['off', 'light', 'standard'].contains(settings['hapticStyle'])) count++;
  if (['comfortable', 'compact'].contains(settings['historyDensity'])) count++;
  final backupDays = settings['backupReminderDays'];
  if (backupDays is num && [0, 7, 14, 30].contains(backupDays.toInt())) {
    count++;
  }
  if (settings['homeMenuAnimations'] is bool) count++;
  return count;
}
