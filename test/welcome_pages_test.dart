import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/help_guides_settings_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/screens/welcome_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark');

  group('WelcomeScreen Standalone Pages Tests', () {
    testWidgets(
      'Renders History Redesign (Life Ledger Timeline) standalone page',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WelcomeScreen(
                p: p,
                theme: 'dark',
                defaultMode: 'two-way',
                currentLocale: 'en',
                onLocaleChanged: (_) {},
                onTheme: (_) {},
                onDefaultMode: (_) {},
                pages: const ['history-redesign'],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify header
        expect(find.text('Life Ledger Timeline'), findsOneWidget);

        // Verify session preview card elements
        expect(find.text('Today · Sunday, Sep 6'), findsOneWidget);
        expect(find.text('09:30 AM'), findsOneWidget);
        expect(find.text('1h 45m'), findsOneWidget);
        expect(find.text('11:15 AM'), findsOneWidget);
        expect(find.text('LIVE 24m'), findsOneWidget);
        expect(find.text('End'), findsOneWidget);

        // Verify core feature highlights
        expect(find.text('Connected Session Pairing'), findsOneWidget);
        expect(find.text('1-Tap Live Session End'), findsOneWidget);
        expect(find.text('Frictionless Filter Pills'), findsOneWidget);
        expect(find.text('iOS Calendar with Event Dots'), findsOneWidget);

        // Verify button says Done for single standalone page
        expect(find.text('Done'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders Dashboard Redesign (Executive Intelligence Hub) standalone page',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WelcomeScreen(
                p: p,
                theme: 'dark',
                defaultMode: 'two-way',
                currentLocale: 'en',
                onLocaleChanged: (_) {},
                onTheme: (_) {},
                onDefaultMode: (_) {},
                pages: const ['dashboard-redesign'],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify header
        expect(find.text('Executive Intelligence Hub'), findsOneWidget);

        // Verify time-scope filter pills simulation
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Week'), findsOneWidget);
        expect(find.text('Month'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);

        // Verify Daily Rhythm chart & 90-day activity grid
        expect(find.text('Daily Rhythm'), findsOneWidget);
        expect(find.text('Activity Grid'), findsOneWidget);
        expect(find.text('(last 90 days)'), findsOneWidget);
        expect(find.text('12-day streak'), findsOneWidget);

        // Verify core feature highlights
        expect(find.text('Time-Scope Intelligence'), findsOneWidget);
        expect(find.text('Grounded Daily Rhythm Chart'), findsOneWidget);
        expect(find.text('90-Day Activity Heatmap Grid'), findsOneWidget);
        expect(find.text('Circadian & Time-of-Day Bias'), findsOneWidget);

        // Verify button says Done for single standalone page
        expect(find.text('Done'), findsOneWidget);
      },
    );
  });

  group('HelpGuidesSettingsPage Interactive Feature Tours Tests', () {
    testWidgets('Renders Interactive Feature Tours and handles tour taps', (
      tester,
    ) async {
      List<String>? launchedPages;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HelpGuidesSettingsPage(
                p: p,
                onOpenCategory: (_, {required parent}) {},
                onOpenTour: (pages) => launchedPages = pages,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('INTERACTIVE FEATURE TOURS'), findsOneWidget);
      expect(find.text('Life Ledger Timeline Tour'), findsOneWidget);
      expect(find.text('Executive Intelligence Hub Tour'), findsOneWidget);

      // Tap History Tour
      await tester.tap(find.text('Life Ledger Timeline Tour'));
      await tester.pump();
      expect(launchedPages, ['history-redesign']);

      // Tap Dashboard Tour
      await tester.tap(find.text('Executive Intelligence Hub Tour'));
      await tester.pump();
      expect(launchedPages, ['dashboard-redesign']);
    });
  });
}
