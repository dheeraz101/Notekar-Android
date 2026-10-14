import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/diagnostics_settings_page.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/screens/end_of_support_screen.dart';
import 'package:notekar/widgets/home_sobriety_streak_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark');

  group('HomeSobrietyStreakCard Tests', () {
    testWidgets(
      'renders clean duration, flame badge, and calls onTapSettings on tap and long press',
      (tester) async {
        bool settingsOpened = false;
        bool urgeSurfingOpened = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: HomeSobrietyStreakCard(
                duration: const Duration(days: 3, hours: 4),
                milestoneTheme: 'science',
                streakShields: 2,
                onTapMilestone: (m, d) {},
                onTapSettings: () {
                  settingsOpened = true;
                },
                onOpenUrgeSurfing: () {
                  urgeSurfingOpened = true;
                },
              ),
            ),
          ),
        );

        // Verify streak typography and badges
        expect(find.text('3d Clean'), findsOneWidget);
        expect(find.text('🔥'), findsOneWidget);
        expect(find.text('2'), findsOneWidget); // shields count

        // Tap card -> opens settings
        await tester.tap(find.byType(HomeSobrietyStreakCard));
        await tester.pumpAndSettle();
        expect(settingsOpened, isTrue);

        // Reset and test long press
        settingsOpened = false;
        await tester.longPress(find.byType(HomeSobrietyStreakCard));
        await tester.pumpAndSettle();
        expect(settingsOpened, isTrue);

        // Tap Urge Surfing
        await tester.tap(find.byIcon(Icons.air_rounded));
        await tester.pumpAndSettle();
        expect(urgeSurfingOpened, isTrue);
      },
    );

    testWidgets(
      'renders starting fresh seedling when streak is under 24 hours',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: HomeSobrietyStreakCard(
                duration: const Duration(hours: 5),
                milestoneTheme: 'science',
                streakShields: 0,
                onTapMilestone: (m, d) {},
                onTapSettings: () {},
                onOpenUrgeSurfing: () {},
              ),
            ),
          ),
        );

        expect(find.text('5h Clean'), findsOneWidget);
        expect(find.text('🌱'), findsOneWidget);
      },
    );
  });

  group('EndOfSupportScreen Tests', () {
    testWidgets(
      'renders Apple HIG end of support layout and dismisses cleanly',
      (tester) async {
        bool dismissed = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: EndOfSupportScreen(
              p: p,
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        );

        expect(find.text('END OF SUPPORT'), findsOneWidget);
        expect(find.text('Thank You for Trying NoteKar'), findsOneWidget);
        expect(find.text('100% Offline & Sovereign'), findsOneWidget);
        expect(find.text('GitHub Repository'), findsOneWidget);
        expect(find.text('Support the Developer'), findsOneWidget);

        // Tap Continue button
        await tester.tap(find.text('Continue to NoteKar'));
        await tester.pumpAndSettle();
        expect(dismissed, isTrue);
      },
    );
  });

  group('Diagnostics Easter Egg Tests', () {
    testWidgets('tapping build number 7 times shows hidden quest dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DiagnosticsSettingsPage(
                p: p,
                subCategory: 'Diagnostics',
                entries: const <Moment>[],
                todayCount: 0,
                appVersion: '2.5.0',
                appBuildNumber: '42',
                appBuildDate: '2026-10-11',
                updateSubtitle: 'Up to date',
                lastUpdateCheckedAt: null,
                remoteNotices: true,
                onCopyDiagnosticsFeedback: (_) {},
                reduceMotion: false,
                enableTranslucency: true,
                networkLogs: const [],
                loadingNetworkLogs: false,
                onClearNetworkLogs: () {},
                onLearnMoreBeta: () {},
              ),
            ),
          ),
        ),
      );

      // Find the build number row
      final buildRow = find.text('Build Number');
      expect(buildRow, findsOneWidget);

      // Tap 3 times (no quest popup)
      for (int i = 0; i < 3; i++) {
        await tester.tap(buildRow);
        await tester.pump(const Duration(milliseconds: 350));
      }
      expect(
        find.textContaining('You have unlocked developers hidden Quest'),
        findsNothing,
      );

      // Tap 4 more times to reach 7 total taps
      for (int i = 0; i < 4; i++) {
        await tester.tap(buildRow);
        await tester.pump(const Duration(milliseconds: 350));
      }
      await tester.pumpAndSettle();

      // Now developer quest dialog should be displayed!
      expect(
        find.textContaining('You have unlocked developers hidden Quest'),
        findsOneWidget,
      );
      expect(find.text('Okay'), findsOneWidget);

      // Tapping Okay opens EndOfSupportScreen
      await tester.tap(find.text('Okay'));
      await tester.pumpAndSettle();
      expect(find.text('END OF SUPPORT'), findsOneWidget);

      // Drain remaining toast timers
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
