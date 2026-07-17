import 'package:notekar/models/moment.dart';

class BackupValidationResult {
  const BackupValidationResult.valid({
    required this.entries,
    required this.settings,
    required this.exportedAt,
  }) : error = null;

  const BackupValidationResult.invalid(this.error)
    : entries = const [],
      settings = const {},
      exportedAt = null;

  final String? error;
  final List<Moment> entries;
  final Map<String, dynamic> settings;
  final DateTime? exportedAt;

  bool get isValid => error == null;
}

class BackupDryRunSummary {
  const BackupDryRunSummary({
    required this.backupMoments,
    required this.backupNotes,
    required this.newMoments,
    required this.duplicatesSkipped,
    required this.settingsToRestore,
    required this.exportedAt,
  });

  final int backupMoments;
  final int backupNotes;
  final int newMoments;
  final int duplicatesSkipped;
  final int settingsToRestore;
  final DateTime? exportedAt;
}
