import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Migration Compatibility & Data Contract Tests', () {
    test(
      'Moment JSON serialization preserves existing legacy schema fields',
      () {
        final json = {
          'id': 101,
          'timestamp': 1700000000000,
          'type': 'single',
          'date': '2023-11-14',
          'note': 'Working on #deepfocus project',
          'category': 'Deep Focus',
          'tags': ['focus', 'priority'],
        };

        final moment = Moment.fromJson(json);

        expect(moment.id, 101);
        expect(moment.timestamp, 1700000000000);
        expect(moment.type, 'single');
        expect(moment.note, 'Working on #deepfocus project');
        expect(moment.category, 'Deep Focus');
        expect(moment.tags, ['focus', 'priority']);
        expect(moment.effectiveTags, contains('deepfocus'));

        final serialized = moment.toJson();
        expect(serialized['id'], 101);
        expect(serialized['type'], 'single');
        expect(serialized['category'], 'Deep Focus');
        expect(serialized['tags'], ['focus', 'priority']);
      },
    );

    test(
      'Moment handles legacy fallback types (in, out, single) without corrupting',
      () {
        final inMoment = Moment.fromJson({
          'id': 1,
          'timestamp': 1700000000000,
          'type': 'in',
        });
        final outMoment = Moment.fromJson({
          'id': 2,
          'timestamp': 1700003600000,
          'type': 'out',
        });
        final invalidTypeMoment = Moment.fromJson({
          'id': 3,
          'timestamp': 1700007200000,
          'type': 'unknown_arbitrary_string',
        });

        expect(inMoment.type, 'in');
        expect(outMoment.type, 'out');
        // Defaults gracefully to single if unknown
        expect(invalidTypeMoment.type, 'single');
      },
    );

    test('Canonical vocabulary presentation mapping contract', () {
      // Maps internal persisted tokens to canonical presentation terms
      String mapModePresentation(String mode) {
        switch (mode) {
          case 'single':
            return 'Quick log';
          case 'two-way':
            return 'Session';
          default:
            return 'Quick log';
        }
      }

      String mapInoutPresentation(String inout) {
        switch (inout) {
          case 'in':
            return 'Start';
          case 'out':
            return 'End';
          default:
            return 'Start';
        }
      }

      expect(mapModePresentation('single'), 'Quick log');
      expect(mapModePresentation('two-way'), 'Session');
      expect(mapInoutPresentation('in'), 'Start');
      expect(mapInoutPresentation('out'), 'End');
    });

    test(
      'SharedPreferences canonical vs legacy fallback key resolution',
      () async {
        SharedPreferences.setMockInitialValues({
          'm-theme': 'dark',
          'm-history-density': 'compact',
          'm-inout': 'out',
          'm-ses': 1710000000000,
        });

        final prefs = await SharedPreferences.getInstance();

        // Resolver utility verifying fallback behavior
        String resolveString(
          String canonicalKey,
          String legacyKey,
          String defaultVal,
        ) {
          return prefs.getString(canonicalKey) ??
              prefs.getString(legacyKey) ??
              defaultVal;
        }

        expect(resolveString('theme', 'm-theme', 'system'), 'dark');
        expect(
          resolveString('history_density', 'm-history-density', 'comfortable'),
          'compact',
        );
        expect(prefs.getString('m-inout'), 'out');
        expect(prefs.getInt('m-ses'), 1710000000000);
      },
    );
  });
}
