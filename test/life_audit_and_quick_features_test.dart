import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/life_audit_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/user_profile_service.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LifeAuditPage Apple HIG Cupertino Sliders and Calibrate Route', () {
    testWidgets(
      'Uses CupertinoSlider instead of Material Slider for sleep and essentials',
      (tester) async {
        final p = paletteFor('dark');
        double sleep = 8.0;
        double essentials = 3.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LifeAuditPage(
                  p: p,
                  entries: const [],
                  sleepHours: sleep,
                  essentialsHours: essentials,
                  onSleepHoursChanged: (val) => sleep = val,
                  onEssentialsHoursChanged: (val) => essentials = val,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify CupertinoSliders are used
        expect(find.byType(CupertinoSlider), findsNWidgets(2));
        expect(find.byType(Slider), findsNothing);
      },
    );

    testWidgets('Calibrate button triggers onOpenPersonalProfile callback', (
      tester,
    ) async {
      final p = paletteFor('dark');
      bool calibratedOpened = false;

      // Ensure profile has no DOB so Calibrate button is visible
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(UserProfileService.keyUserDob);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LifeAuditPage(
                p: p,
                entries: const [],
                sleepHours: 8.0,
                essentialsHours: 3.0,
                onSleepHoursChanged: (_) {},
                onEssentialsHoursChanged: (_) {},
                onOpenPersonalProfile: () {
                  calibratedOpened = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final calibrateFinder = find.text('Calibrate');
      expect(calibrateFinder, findsOneWidget);

      await tester.ensureVisible(calibrateFinder);
      await tester.pumpAndSettle();
      await tester.tap(calibrateFinder);
      await tester.pumpAndSettle();

      expect(calibratedOpened, isTrue);
    });
  });

  group('IosEmojiText Offline Rendering (H-42)', () {
    testWidgets('renders text and emojis without network requests', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: IosEmojiText('Deep Work 🚀 #focus 🧘')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deep Work 🚀 #focus 🧘'), findsOneWidget);
    });
  });
}
