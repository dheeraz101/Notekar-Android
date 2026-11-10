import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/services/auto_categorization_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MAJ-01: AutoCategorizationEngine Local Naive Bayes Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      AutoCategorizationEngine.instance.clear();
    });

    test('Returns null category on empty or untrained model', () {
      final engine = AutoCategorizationEngine.instance;
      expect(engine.isTrained, isFalse);
      final pred = engine.predict('writing rust code in backend');
      expect(pred.category, isNull);
      expect(pred.confidence, 0.0);
      expect(pred.isHighConfidence, isFalse);
    });

    test('Trains on historical notes and predicts high-confidence category', () {
      final engine = AutoCategorizationEngine.instance;

      final trainingMoments = [
        // Work moments
        Moment(
          id: 1,
          timestamp: 1700000000000,
          type: 'single',
          date: '2026-01-01',
          category: 'Work',
          note: 'Rust backend API server implementation and database migration',
        ),
        Moment(
          id: 2,
          timestamp: 1700001000000,
          type: 'in',
          date: '2026-01-01',
          category: 'Work',
          note:
              'Debug backend microservices and pull request review for server',
        ),
        Moment(
          id: 3,
          timestamp: 1700002000000,
          type: 'single',
          date: '2026-01-02',
          category: 'Work',
          note: 'Architecture refactor of backend endpoints and unit testing',
        ),

        // Health / Gym moments
        Moment(
          id: 4,
          timestamp: 1700003000000,
          type: 'single',
          date: '2026-01-02',
          category: 'Health',
          note: 'Morning workout bench press deadlift and cardio run',
        ),
        Moment(
          id: 5,
          timestamp: 1700004000000,
          type: 'single',
          date: '2026-01-03',
          category: 'Health',
          note:
              'Gym session leg day squats dumbbell press and protein smoothie',
        ),
        Moment(
          id: 6,
          timestamp: 1700005000000,
          type: 'single',
          date: '2026-01-03',
          category: 'Health',
          note: 'Evening stretching cardio workout and recovery session',
        ),

        // Study moments
        Moment(
          id: 7,
          timestamp: 1700006000000,
          type: 'single',
          date: '2026-01-04',
          category: 'Study',
          note: 'Reading chapter 4 quantum physics textbook and notes',
        ),
        Moment(
          id: 8,
          timestamp: 1700007000000,
          type: 'single',
          date: '2026-01-04',
          category: 'Study',
          note: 'Linear algebra homework assignment and physics exam revision',
        ),
      ];

      engine.train(trainingMoments);
      expect(engine.isTrained, isTrue);

      // Predict Work query
      final workPred = engine.predict('backend server database bug fix');
      expect(workPred.category, 'Work');
      expect(workPred.confidence, greaterThan(0.70));

      // Predict Health query
      final healthPred = engine.predict('squats and bench press workout');
      expect(healthPred.category, 'Health');
      expect(healthPred.confidence, greaterThan(0.70));

      // Predict Study query
      final studyPred = engine.predict('physics homework textbook');
      expect(studyPred.category, 'Study');
      expect(studyPred.confidence, greaterThan(0.70));
    });

    test(
      'SharedPreferences persistence roundtrip preserves trained model',
      () async {
        final engine = AutoCategorizationEngine.instance;

        final trainingMoments = [
          Moment(
            id: 1,
            timestamp: 1700000000000,
            type: 'single',
            date: '2026-01-01',
            category: 'Work',
            note: 'flutter compiler frontend widget layout',
          ),
          Moment(
            id: 2,
            timestamp: 1700001000000,
            type: 'single',
            date: '2026-01-01',
            category: 'Routine',
            note: 'making espresso coffee breakfast grocery cleaning',
          ),
        ];

        engine.train(trainingMoments);
        expect(engine.isTrained, isTrue);

        await engine.saveToPrefs();

        // Clear memory
        engine.clear();
        expect(engine.isTrained, isFalse);

        // Restore from prefs
        final loaded = await engine.loadFromPrefs();
        expect(loaded, isTrue);
        expect(engine.isTrained, isTrue);

        final pred = engine.predict('morning espresso coffee breakfast');
        expect(pred.category, 'Routine');
        expect(pred.confidence, greaterThan(0.70));
      },
    );

    test(
      'Accurately tokenizes and classifies multilingual and accented text',
      () {
        final engine = AutoCategorizationEngine.instance;

        // Tokenize test for accents and non-Latin scripts
        final frenchTokens = AutoCategorizationEngine.tokenize(
          'Réunion importante avec l’équipe de développement',
        );
        expect(frenchTokens, contains('réunion'));
        expect(frenchTokens, contains('importante'));
        expect(frenchTokens, contains('développement'));

        final hindiTokens = AutoCategorizationEngine.tokenize(
          'आज सुबह की कसरत और योग ध्यान',
        );
        expect(hindiTokens, contains('सुबह'));
        expect(hindiTokens, contains('कसरत'));
        expect(hindiTokens, contains('ध्यान'));

        final moments = [
          Moment(
            id: 1,
            timestamp: 1700000000000,
            type: 'single',
            date: '2026-01-01',
            category: 'Travail',
            note: 'Réunion importante architecture logicielle équipe',
          ),
          Moment(
            id: 2,
            timestamp: 1700001000000,
            type: 'single',
            date: '2026-01-01',
            category: 'स्वास्थ्य',
            note: 'सुबह की कसरत व्यायाम और योग ध्यान',
          ),
        ];

        engine.train(moments);
        expect(engine.isTrained, isTrue);

        final predFr = engine.predict('équipe architecture réunion');
        expect(predFr.category, 'Travail');
        expect(predFr.confidence, greaterThan(0.70));

        final predHi = engine.predict('कसरत योग ध्यान');
        expect(predHi.category, 'स्वास्थ्य');
        expect(predHi.confidence, greaterThan(0.70));
      },
    );
  });
}
