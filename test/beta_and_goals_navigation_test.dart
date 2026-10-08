import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/settings/settings_dashboard_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/circuit_breaker_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Beta Switch & Goals Navigation Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'CircuitBreakerService hasAnyTripped reports healthy by default',
      () async {
        final prefs = await SharedPreferences.getInstance();
        CircuitBreakerService.instance.init(prefs);
        await CircuitBreakerService.instance.resetAll();

        expect(CircuitBreakerService.instance.hasAnyTripped(), isFalse);
      },
    );

    testWidgets(
      'HistoryDialog opens directly to Goals when initialView is goals',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryDialog(
                p: p,
                entries: const [],
                compactRows: false,
                largeText: false,
                minimalMomentOptions: false,
                confirmDelete: false,
                initialView: 'goals',
                onDelete: (_) async {},
                onRestore: (_) async {},
                onUpdateNote: (_, _) async {},
                onDuration: (_, _) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should display Targets & Goals header directly
        expect(find.text('Targets & Goals'), findsWidgets);
      },
    );

    testWidgets(
      'SettingsDashboardPage triggers onOpenGoals callback when tapping goal card',
      (tester) async {
        bool openGoalsCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SettingsDashboardPage(
                  p: p,
                  entries: const [],
                  enableSobrietyMode: false,
                  onLogNow: () {},
                  onLearnMoreBeta: () {},
                  onOpenGoals: () {
                    openGoalsCalled = true;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on Targets & Intentional Goals card
        final goalsCard = find.text('Targets & Intentional Goals');
        expect(goalsCard, findsOneWidget);

        await tester.ensureVisible(goalsCard);
        await tester.pumpAndSettle();

        await tester.tap(goalsCard);
        await tester.pumpAndSettle();

        expect(openGoalsCalled, isTrue);
      },
    );
  });
}
