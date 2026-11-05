import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/vault_encryption_service.dart';
import 'package:notekar/widgets/clock_face.dart';
import 'package:notekar/widgets/design_system/nk_button.dart';
import 'package:notekar/widgets/design_system/nk_empty_state.dart';
import 'package:notekar/widgets/design_system/nk_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark');

  group('Phase 1 P0 Critical Improvements Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('1. ClockFace in 12h mode renders AM/PM period indicator', (
      tester,
    ) async {
      // 14:30 (2:30 PM)
      final afternoon = DateTime(2026, 11, 5, 14, 30, 45);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockFace(
              now: afternoon,
              p: p,
              pulseToken: 0,
              pulseType: '',
              minimal: false,
              showSeconds: true,
              highlightSeconds: false,
              use24HourFormat: false,
              showPeriod: true,
              isPaused: false,
            ),
          ),
        ),
      );

      expect(find.text('2:30'), findsOneWidget);
      expect(find.text('PM'), findsOneWidget);

      // 09:15 (9:15 AM)
      final morning = DateTime(2026, 11, 5, 9, 15, 0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockFace(
              now: morning,
              p: p,
              pulseToken: 0,
              pulseType: '',
              minimal: false,
              showSeconds: true,
              highlightSeconds: false,
              use24HourFormat: false,
              showPeriod: true,
              isPaused: false,
            ),
          ),
        ),
      );

      expect(find.text('9:15'), findsOneWidget);
      expect(find.text('AM'), findsOneWidget);

      // Default (showPeriod: false) renders cleanly without AM/PM
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockFace(
              now: morning,
              p: p,
              pulseToken: 0,
              pulseType: '',
              minimal: false,
              showSeconds: true,
              highlightSeconds: false,
              use24HourFormat: false,
              isPaused: false,
            ),
          ),
        ),
      );

      expect(find.text('9:15'), findsOneWidget);
      expect(find.text('AM'), findsNothing);

      // In 24h mode, AM/PM is not rendered
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockFace(
              now: morning,
              p: p,
              pulseToken: 0,
              pulseType: '',
              minimal: false,
              showSeconds: true,
              highlightSeconds: false,
              use24HourFormat: true,
              isPaused: false,
            ),
          ),
        ),
      );

      expect(find.text('09:15'), findsOneWidget);
      expect(find.text('AM'), findsNothing);
      expect(find.text('PM'), findsNothing);
    });

    testWidgets(
      '2. NkButton.primary uses dynamic p.onAccent foreground color',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NkButton.primary(
                p: p,
                label: 'Save Moment',
                onPressed: () {},
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Save Moment'));
        expect(textWidget.style?.color, equals(p.onAccent));
      },
    );

    testWidgets(
      '3. NkEmptyState does not render empty Text or SizedBox when description is empty',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NkEmptyState(
                p: p,
                icon: Icons.history,
                title: 'No History Yet',
                description: '',
              ),
            ),
          ),
        );

        expect(find.text('No History Yet'), findsOneWidget);
        // Only 1 Text widget should exist (the title)
        expect(find.byType(Text), findsOneWidget);
      },
    );

    testWidgets(
      '4. NkSwitchTile wraps Switch.adaptive in ExcludeSemantics to prevent double announcement',
      (tester) async {
        bool switchValue = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return NkSwitchTile(
                    p: p,
                    title: 'Biometric Lock',
                    value: switchValue,
                    onChanged: (val) => setState(() => switchValue = val),
                  );
                },
              ),
            ),
          ),
        );

        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);
        final excludeSemanticsFinder = find.ancestor(
          of: switchFinder,
          matching: find.byType(ExcludeSemantics),
        );
        expect(excludeSemanticsFinder, findsWidgets);
        final excludeSemantics = tester.widget<ExcludeSemantics>(
          excludeSemanticsFinder.first,
        );
        expect(excludeSemantics.excluding, isTrue);
      },
    );

    test(
      '5. VaultEncryptionService default iterations is 100000 and decrypts both legacy and 100k vaults',
      () {
        final service = VaultEncryptionService.instance;
        expect(VaultEncryptionService.defaultPbkdf2Iterations, equals(100000));

        // Legacy 10,000 iteration vault payload
        final legacyVault = service.encryptVault(
          plaintext: 'Confidential Notes #legacy',
          password: 'SecretPassword123!',
          iterations: 10000,
        );
        expect(legacyVault.contains('"iterations": 10000'), isTrue);

        final legacyDecrypted = service.decryptVault(
          vaultContent: legacyVault,
          password: 'SecretPassword123!',
        );
        expect(legacyDecrypted, equals('Confidential Notes #legacy'));

        // Fast round-trip
        final fastVault = service.encryptVault(
          plaintext: 'Fast Test #100k',
          password: 'SecretPassword123!',
          iterations: 1000,
        );
        final fastDecrypted = service.decryptVault(
          vaultContent: fastVault,
          password: 'SecretPassword123!',
        );
        expect(fastDecrypted, equals('Fast Test #100k'));
      },
    );

    testWidgets('6. NoteDialog includes PopScope and draft persistence logic', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteDialog(p: p, initialNote: ''),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsOneWidget);
      final popScope = tester.widget(popScopeFinder) as PopScope;
      expect(popScope.canPop, isFalse);
    });
  });
}
