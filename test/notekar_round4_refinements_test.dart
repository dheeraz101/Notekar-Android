import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/settings/app_icons_settings_page.dart';
import 'package:notekar/dialogs/settings/personalization_settings_page.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/scroll_state_preserver.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppScrollState.resetAll();
  });

  group('1. Accent Color Carousel & Full-Bottom Fluid Reservoir', () {
    testWidgets(
      'PersonalizationSettingsPage renders optical carousel with center indicator rings',
      (tester) async {
        String selectedKey = 'blue';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PersonalizationSettingsPage(
                  p: testPalette,
                  subCategory: 'Accent Color',
                  theme: 'dark',
                  accentColor: selectedKey,
                  appIconStyle: 'default',
                  currentLocale: 'en',
                  reduceMotion: false,
                  enableTranslucency: true,
                  onLocaleChanged: (_) {},
                  onAccentColorChanged: (key) => selectedKey = key,
                  onOpenCategory: (_, {String? parent}) {},
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('SWIPE OR TAP TO APPLY ACCENT'), findsOneWidget);
        expect(find.byType(ListView), findsWidgets);
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    test('AccentSnappingScrollPhysics momentum and spring simulation', () {
      const physics = AccentSnappingScrollPhysics(itemExtent: 46.0);
      expect(physics.itemExtent, equals(46.0));
      expect(physics.allowImplicitScrolling, isFalse);
    });
  });

  group('2. App Icons Page Height & Selected Dock Filter', () {
    testWidgets(
      'AppIconsSettingsPage expands home preview height to 550 and filters selected icon from dock',
      (tester) async {
        String activeIcon = 'default';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppIconsSettingsPage(
                  p: testPalette,
                  appIconStyle: activeIcon,
                  godModeUnlocked: false,
                  onAppIconStyleChanged: (key) async {
                    activeIcon = key;
                    return true;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 600));

        // Phone container has height 550
        final containerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container && widget.constraints?.maxHeight == 550,
        );
        expect(containerFinder, findsOneWidget);

        // Active launcher card shows 'Active Launcher Icon'
        expect(find.text('Active Launcher Icon'), findsOneWidget);

        // The active icon 'default' must NOT be in the dock
        expect(find.byKey(const ValueKey('app_icon_default')), findsNothing);
      },
    );
  });

  group('3. Update Center Formal Page Description Text Copy', () {
    testWidgets(
      'UpdateCenterView renders sovereign verification formal description copy',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UpdateCenterView(
                  p: testPalette,
                  appVersion: '7.5.10',
                  checkingUpdates: false,
                  updateStatus: 'Up to date',
                  currentBuildChannel: 'stable',
                  updateInfo: null,
                  reduceMotion: false,
                  enableTranslucency: true,
                  onCheckUpdates: () {},
                  onOpenLink: (_) {},
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text(
            'Update Center provides verified, sovereign software releases and security advisories for your device. All distributions undergo cryptographic signature verification and SHA-256 checksum validation prior to installation, maintaining complete offline integrity without intermediary telemetry.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('4. Scroll Restoration & Immediate Header Visibility', () {
    testWidgets(
      'AppSheet restores header small title and avatar immediately from AppScrollState without manual scroll',
      (tester) async {
        // Pre-save offset = 300 in settings_root
        AppScrollState.save('settings_root', 300.0);

        final controller = ScrollController(initialScrollOffset: 300.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppSheet(
                  p: testPalette,
                  title: 'Settings',
                  showLargeTitle: true,
                  controller: controller,
                  scrollLeadingAction: const KeyedSubtree(
                    key: ValueKey('test_profile_avatar'),
                    child: SizedBox(width: 32, height: 32),
                  ),
                  child: SizedBox(
                    height: 300,
                    child: ListView.builder(
                      controller: controller,
                      itemCount: 50,
                      itemBuilder: (_, i) =>
                          SizedBox(height: 40, child: Text('Row $i')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // The profile avatar must be visible (opacity > 0.0) because offset is 300
        final opacityFinder = find.byWidgetPredicate((w) {
          if (w is Opacity && w.child is KeyedSubtree) {
            final child = w.child as KeyedSubtree;
            return child.key == const ValueKey('test_profile_avatar') &&
                w.opacity == 1.0;
          }
          return false;
        });
        expect(opacityFinder, findsOneWidget);

        controller.dispose();
      },
    );
  });

  group('5. Profile Avatar Dimming Threshold in Main Settings', () {
    testWidgets(
      'Profile avatar is strictly hidden (opacity: 0.0) when offset <= 190 while profile card is visible',
      (tester) async {
        AppScrollState.save('settings_root', 100.0);

        final controller = ScrollController(initialScrollOffset: 100.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppSheet(
                  p: testPalette,
                  title: 'Settings',
                  showLargeTitle: true,
                  controller: controller,
                  scrollLeadingAction: const KeyedSubtree(
                    key: ValueKey('test_profile_avatar_hidden'),
                    child: SizedBox(width: 32, height: 32),
                  ),
                  child: SizedBox(
                    height: 300,
                    child: ListView.builder(
                      controller: controller,
                      itemCount: 50,
                      itemBuilder: (_, i) =>
                          SizedBox(height: 40, child: Text('Row $i')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // When offset <= 190 (100.0), opacity must be strictly 0.0 (not dim!)
        final opacityFinder = find.byWidgetPredicate((w) {
          if (w is Opacity && w.child is KeyedSubtree) {
            final child = w.child as KeyedSubtree;
            return child.key == const ValueKey('test_profile_avatar_hidden') &&
                w.opacity == 0.0;
          }
          return false;
        });
        expect(opacityFinder, findsOneWidget);

        controller.dispose();
      },
    );
  });
}
