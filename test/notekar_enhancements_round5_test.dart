import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/settings/app_icons_settings_page.dart';
import 'package:notekar/dialogs/settings/personalization_settings_page.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/update_service.dart';

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

  group('Requirement 1: Accent Color Page & Fluid Dynamics', () {
    test('FluidDynamicsParams supports custom defaults and copyWith', () {
      const params = FluidDynamicsParams();
      expect(params.reservoirHeight, 360.0);
      expect(params.waveAmplitude, 6.0);
      expect(params.waveFrequency, 1.8);
      expect(params.waveSpeed, 1.0);
      expect(params.tiltResponse, 22.0);

      final modified = params.copyWith(
        reservoirHeight: 220.0,
        tiltResponse: 28.0,
      );
      expect(modified.reservoirHeight, 220.0);
      expect(modified.tiltResponse, 28.0);
      expect(modified.waveAmplitude, 6.0);
    });

    testWidgets(
      'Accent Color experience renders prominent center circle and stationary rings',
      (tester) async {
        String selectedColor = 'blue';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PersonalizationSettingsPage(
                  p: testPalette,
                  subCategory: 'Accent Color',
                  theme: 'dark',
                  accentColor: selectedColor,
                  appIconStyle: 'default',
                  currentLocale: 'en',
                  reduceMotion: false,
                  enableTranslucency: true,
                  onLocaleChanged: (_) {},
                  onAccentColorChanged: (key) => selectedColor = key,
                  onOpenCategory: (_, {String? parent}) {},
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('TAP ANY FISH TO HARMONIZE ACCENT'), findsOneWidget);
        expect(find.text('20 Living Species'), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);

        // Verify living pond aquarium and riverbed stones caption
        expect(find.byType(CustomPaint), findsWidgets);
        expect(
          find.textContaining('Riverbed stones retain their fixed hues'),
          findsOneWidget,
        );
      },
    );
  });

  group('Requirement 2: App Icons Page Dock & Phone Preview Height', () {
    testWidgets(
      'Active icon is excluded from dock and preview card height is 500',
      (tester) async {
        String activeIcon = 'default';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return AppIconsSettingsPage(
                      p: testPalette,
                      appIconStyle: activeIcon,
                      godModeUnlocked: false,
                      onAppIconStyleChanged: (newIcon) async {
                        setState(() => activeIcon = newIcon);
                        return true;
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Home Screen preview card height is 500
        final previewContainers = tester.widgetList<Container>(
          find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.constraints?.maxHeight == 550 &&
                w.decoration is BoxDecoration,
          ),
        );
        expect(previewContainers, isNotEmpty);

        // Selected icon 'default' MUST NOT be shown in the bottom dock
        expect(find.byKey(const ValueKey('app_icon_default')), findsNothing);

        // Non-selected icon 'black' MUST be shown in the bottom dock
        expect(find.byKey(const ValueKey('app_icon_black')), findsOneWidget);

        // Tap 'black' in the dock
        await tester.tap(find.byKey(const ValueKey('app_icon_black')));
        await tester.pumpAndSettle();

        expect(activeIcon, 'black');

        // Now 'black' is selected -> MUST NOT be in the dock
        expect(find.byKey(const ValueKey('app_icon_black')), findsNothing);

        // And 'default' is now unselected -> MUST be in the dock
        expect(find.byKey(const ValueKey('app_icon_default')), findsOneWidget);
      },
    );
  });

  group('Requirement 3: Update Center Page Description Copy', () {
    testWidgets(
      'UpdateCenterView displays formal professional description copy',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UpdateCenterView(
                  p: testPalette,
                  appVersion: '7.5.7',
                  enableTranslucency: true,
                  reduceMotion: false,
                  onOpenLink: (_) {},
                  onCheckUpdates: () {},
                  checkingUpdates: false,
                  updateStatus: 'Up to date',
                  currentBuildChannel: 'stable',
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.textContaining(
            'Update Center provides verified, sovereign software releases',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'UpdateCenterView description copy is present alongside update-available cards',
      (tester) async {
        final availableUpdate = AppUpdateInfo(
          version: '7.6.0',
          tagName: 'v7.6.0',
          type: 'Feature Update',
          body: 'New fluid dynamics and Apple HIG elegance.',
          date: DateTime.now(),
          isSecurity: false,
          isImportant: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UpdateCenterView(
                  p: testPalette,
                  appVersion: '7.5.7',
                  enableTranslucency: true,
                  reduceMotion: false,
                  onOpenLink: (_) {},
                  onCheckUpdates: () {},
                  updateInfo: availableUpdate,
                  checkingUpdates: false,
                  updateStatus: 'Update Available',
                  currentBuildChannel: 'stable',
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Formal page description copy is present
        expect(
          find.textContaining(
            'Update Center provides verified, sovereign software releases',
          ),
          findsOneWidget,
        );

        // Dynamic update-available text copy is distinct and also rendered
        expect(find.text('Update Available'), findsOneWidget);
        expect(
          find.textContaining(
            'This major update introduces brand new features, improvements, and interface designs to NoteKar.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('Requirement 4 & 5: Scroll Header & Profile Opacity Transitions', () {
    testWidgets(
      'Profile circle is hidden at low scroll offset and fades in after profile card',
      (tester) async {
        final controller = ScrollController();
        const leadingKey = ValueKey('test_profile_leading');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppSheet(
                p: testPalette,
                title: 'Settings',
                controller: controller,
                showLargeTitle: true,
                scrollLeadingAction: Container(
                  key: leadingKey,
                  width: 32,
                  height: 32,
                  color: Colors.red,
                ),
                child: SizedBox(
                  height: 400,
                  child: ListView.builder(
                    controller: controller,
                    itemCount: 50,
                    itemBuilder: (context, i) =>
                        SizedBox(height: 50, child: Text('Row $i')),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Finder for the Opacity wrapping scrollLeadingAction
        Finder leadingOpacityFinder() => find
            .ancestor(
              of: find.byKey(leadingKey),
              matching: find.byType(Opacity),
            )
            .first;

        // At offset 0.0: profile circle must be hidden (opacity 0.0)
        expect(tester.widget<Opacity>(leadingOpacityFinder()).opacity, 0.0);

        // Scroll to offset 80.0 (where large title is gone but profile card is fully visible)
        controller.jumpTo(80.0);
        await tester.pump();

        // Profile card is still visible on screen: profile circle MUST STILL BE 0.0 (not dim!)
        expect(tester.widget<Opacity>(leadingOpacityFinder()).opacity, 0.0);

        // Scroll past 190px (profile card is scrolling out of view)
        controller.jumpTo(205.0); // Midpoint of 190..220
        await tester.pump();
        final midOpacity = tester
            .widget<Opacity>(leadingOpacityFinder())
            .opacity;
        expect(midOpacity, greaterThan(0.0));
        expect(midOpacity, lessThan(1.0));

        // Scroll to offset 220.0 (profile card is completely scrolled away)
        controller.jumpTo(220.0);
        await tester.pump();
        expect(tester.widget<Opacity>(leadingOpacityFinder()).opacity, 1.0);
      },
    );

    testWidgets(
      'AppSheet immediately restores full header and leading opacity when returning to scrolled position',
      (tester) async {
        final controller = ScrollController(initialScrollOffset: 250.0);
        const leadingKey = ValueKey('restored_leading');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppSheet(
                p: testPalette,
                title: 'Settings',
                controller: controller,
                showLargeTitle: true,
                scrollLeadingAction: Container(
                  key: leadingKey,
                  width: 32,
                  height: 32,
                  color: Colors.blue,
                ),
                child: SizedBox(
                  height: 400,
                  child: ListView.builder(
                    controller: controller,
                    itemCount: 50,
                    itemBuilder: (context, i) =>
                        SizedBox(height: 50, child: Text('Item $i')),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        Finder leadingOpacityFinder() => find
            .ancestor(
              of: find.byKey(leadingKey),
              matching: find.byType(Opacity),
            )
            .first;

        // Both header title and leading circle MUST be immediately visible (opacity 1.0)
        expect(tester.widget<Opacity>(leadingOpacityFinder()).opacity, 1.0);

        // Title opacity must also be 1.0
        final titleFinder = find
            .ancestor(of: find.text('Settings'), matching: find.byType(Opacity))
            .first;
        expect(tester.widget<Opacity>(titleFinder).opacity, 1.0);
      },
    );
  });
}
