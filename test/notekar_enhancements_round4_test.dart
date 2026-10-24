import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/capture_settings_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/sobriety_milestones.dart';
import 'package:notekar/utils/scroll_state_preserver.dart';
import 'package:notekar/widgets/settings_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPalette = Palette(
    name: 'dark',
    bg: const Color(0xFF000000),
    surface: const Color(0xFF1C1C1E),
    surface2: const Color(0xFF2C2C2E),
    surface3: const Color(0xFF3A3A3C),
    border: const Color(0xFF38383A),
    text: const Color(0xFFFFFFFF),
    text2: const Color(0xFFEBEBF5),
    text3: const Color(0xFF8E8E93),
    clock: const Color(0xFFFFFFFF),
    accent: const Color(0xFF007AFF),
    green: const Color(0xFF34C759),
    orange: const Color(0xFFFF9500),
    red: const Color(0xFFFF3B30),
    blue: const Color(0xFF007AFF),
  );

  group('Item 9: AppScrollState In-Memory Preserver', () {
    setUp(() {
      AppScrollState.resetAll();
    });

    test('AppScrollState saves, retrieves, and clears scroll offsets', () {
      expect(AppScrollState.get('settings_root'), 0.0);
      expect(AppScrollState.has('settings_root'), isFalse);

      AppScrollState.save('settings_root', 245.5);
      expect(AppScrollState.has('settings_root'), isTrue);
      expect(AppScrollState.get('settings_root'), 245.5);

      AppScrollState.save('history_dialog_main', 120.0);
      expect(AppScrollState.get('history_dialog_main'), 120.0);

      AppScrollState.clear('settings_root');
      expect(AppScrollState.has('settings_root'), isFalse);
      expect(AppScrollState.get('settings_root'), 0.0);
      expect(AppScrollState.get('history_dialog_main'), 120.0);

      AppScrollState.resetAll();
      expect(AppScrollState.has('history_dialog_main'), isFalse);
    });

    test(
      'Negative scroll offsets are ignored to maintain valid coordinates',
      () {
        AppScrollState.save('test_key', -10.0);
        expect(AppScrollState.has('test_key'), isFalse);
        expect(AppScrollState.get('test_key'), 0.0);
      },
    );
  });

  group('Item 11: SettingsGroup Apple HIG Footers', () {
    testWidgets(
      'SettingsGroup renders optional footer text in Apple HIG typography',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsGroup(
                p: testPalette,
                title: 'ACCOUNT SECURITY',
                footer:
                    'Passcode and biometric locks protect your logs from unauthorized access.',
                children: [SettingsRow(p: testPalette, title: 'App Lock')],
              ),
            ),
          ),
        );

        expect(find.text('ACCOUNT SECURITY'), findsOneWidget);
        expect(find.text('App Lock'), findsOneWidget);
        expect(
          find.text(
            'Passcode and biometric locks protect your logs from unauthorized access.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('Item 8: Milestone Themes Emoji in Icon Slot', () {
    test('MilestoneThemes names do not contain hardcoded emojis', () {
      for (final theme in kMilestoneThemes) {
        expect(theme.emoji.isNotEmpty, isTrue);
        // Verify the theme name does not start with the emoji
        expect(
          theme.name.startsWith(theme.emoji),
          isFalse,
          reason:
              'Theme name "${theme.name}" should not be prefixed with its emoji "${theme.emoji}"',
        );
      }
    });
  });

  group('Log After Unlock Feature Tests', () {
    testWidgets('CaptureSettingsPage renders Log after unlock controls', (
      tester,
    ) async {
      bool toggleValue = false;
      String actionStyle = 'notification';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CaptureSettingsPage(
                p: testPalette,
                defaultMode: 'single',
                tapDelay: 1000,
                enableNoteOnClick: false,
                logAfterUnlock: true,
                unlockActionStyle: 'notification',
                onDefaultModeChanged: (_) {},
                onTapDelayChanged: (_) {},
                onEnableNoteOnClickChanged: (_) {},
                onLogAfterUnlockChanged: (val) => toggleValue = val,
                onUnlockActionStyleChanged: (style) => actionStyle = style,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Log after unlock'), findsOneWidget);
      expect(find.text('TRIGGERED QUICK LOGGING'), findsOneWidget);
      expect(find.text('Notification Alert'), findsOneWidget);
      expect(find.text('Floating Note Overlay'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Floating Note Overlay'), 150);
      await tester.tap(find.text('Floating Note Overlay'));
      await tester.pumpAndSettle();
      expect(actionStyle, 'quick_note');

      await tester.tap(find.text('Log after unlock'));
      await tester.pumpAndSettle();
      expect(toggleValue, isFalse);
    });

    testWidgets(
      'CaptureSettingsPage hides sub-actions when logAfterUnlock is false',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CaptureSettingsPage(
                  p: testPalette,
                  defaultMode: 'single',
                  tapDelay: 1000,
                  enableNoteOnClick: false,
                  logAfterUnlock: false,
                  unlockActionStyle: 'notification',
                  onDefaultModeChanged: (_) {},
                  onTapDelayChanged: (_) {},
                  onEnableNoteOnClickChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Log after unlock'), findsOneWidget);
        expect(find.text('Notification Alert'), findsNothing);
        expect(find.text('Floating Note Overlay'), findsNothing);
      },
    );
  });
}
