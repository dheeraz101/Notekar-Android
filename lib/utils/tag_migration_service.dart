import 'package:notekar/utils/moment_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-time migration that parses inline #hashtags from existing notes
/// and writes them into the new Moment.tags field.
class TagMigrationService {
  TagMigrationService._();

  static const _migratedKey = 'notekar.tags_migrated_v1';
  static final _hashtagRegex = RegExp(r'#([a-zA-Z0-9_-]+)');

  /// Run the migration if it hasn't been run yet.
  /// Safe to call on every app launch — checks the migration flag first.
  static Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migratedKey) == true) return;

    final repo = MomentRepository();
    final allMoments = repo.getAllMoments();
    for (final moment in allMoments) {
      // Skip if tags are already populated
      if (moment.tags.isNotEmpty) continue;

      // Parse inline hashtags from note
      final matches = _hashtagRegex.allMatches(moment.note);
      if (matches.isEmpty) continue;

      final tags = matches
          .map((m) => m.group(1)!.toLowerCase())
          .toSet()
          .toList();

      if (tags.isNotEmpty) {
        final updated = moment.copyWith(tags: tags);
        await repo.saveMoment(updated);
      }
    }

    await prefs.setBool(_migratedKey, true);
  }
}
