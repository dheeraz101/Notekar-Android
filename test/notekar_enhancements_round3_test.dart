import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/app_icons_settings_page.dart';
import 'package:notekar/dialogs/settings/diagnostics_settings_page.dart';
import 'package:notekar/dialogs/settings/display_settings_page.dart';
import 'package:notekar/dialogs/settings/personalization_settings_page.dart';
import 'package:notekar/models/help_guide_data.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/adaptive_engine.dart';
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
  });

  group('1. Low-End Device Adaptation Algorithm', () {
    test('AdaptiveEngine low-end capability flags and duration collapsing', () {
      final engine = AdaptiveEngine();
      expect(engine.isLowEnd, isA<bool>());
      expect(engine.isLowEndDevice, equals(engine.isLowEnd));
      expect(engine.supportsContinuousAnimations, equals(!engine.isLowEnd));

      const standardDuration = Duration(milliseconds: 300);
      final duration = engine.animationDuration(standardDuration);
      if (engine.isLowEnd) {
        expect(duration, equals(Duration.zero));
      } else {
        expect(duration, equals(standardDuration));
      }
    });
  });

  group('2. Network Monitor Hospital ECG Oscilloscope Sweep', () {
    testWidgets('DiagnosticsSettingsPage renders live ECG card and canvas', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DiagnosticsSettingsPage(
                p: testPalette,
                subCategory: 'Network Monitor',
                entries: const [],
                todayCount: 0,
                appVersion: '1.0.0',
                appBuildNumber: '100',
                appBuildDate: '2026-10-24',
                updateSubtitle: 'Up to date',
                lastUpdateCheckedAt: 12345678,
                remoteNotices: false,
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

      await tester.pump(const Duration(seconds: 4));

      expect(find.text('DATA CONSUMED'), findsOneWidget);
      expect(find.text('TOTAL REQUESTS'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('3. Display Page Apple HIG Live Home Screen Preview', () {
    testWidgets(
      'Renders miniature iPhone mockup frame and verifies absence of feature pills',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: DisplaySettingsPage(
                  p: testPalette,
                  theme: 'dark',
                  showSeconds: true,
                  highlightSeconds: true,
                  use24HourFormat: false,
                  clockFont: 'SF Pro',
                  buttonLabels: true,
                  showHistoryText: true,
                  largeControls: true,
                  homeMenuPill: true,
                  reduceMotion: false,
                  homeMenuAnimations: true,
                  enableTranslucency: true,
                  showLastSavedHint: true,
                  onThemeChanged: (_) {},
                  onShowSecondsChanged: (_) {},
                  onHighlightSecondsChanged: (_) {},
                  onFeedback: (_) {},
                  onButtonLabelsChanged: (_) {},
                  onShowHistoryTextChanged: (_) {},
                  onLargeControlsChanged: (_) {},
                  onHomeMenuPillChanged: (_) {},
                  onHomeMenuAnimations: (_) async => true,
                  onHomeMenuAnimationsChanged: (_) {},
                  onTranslucencyChanged: (_) {},
                  onShowLastSavedHintChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        // Header and live phone preview components
        expect(find.text('LIVE HOME PREVIEW'), findsOneWidget);
        expect(find.text('9:41'), findsOneWidget);
        expect(find.text('Deep Work Session Completed'), findsOneWidget);
        expect(find.text('Saved'), findsOneWidget);
        expect(find.text('History'), findsOneWidget);
        expect(find.text('Log'), findsOneWidget);
        expect(find.text('Remind'), findsOneWidget);
        expect(find.text('Menu'), findsOneWidget);

        // Verify that tacky feature pills are removed from the preview
        expect(find.text('Translucency'), findsNothing);
        expect(
          find.text('Large Controls'),
          findsOneWidget,
        ); // settings toggle only
        expect(
          find.text('Button Labels'),
          findsOneWidget,
        ); // settings toggle only
      },
    );
  });

  group('4. Accent Color Optical Carousel & Snapping Selection', () {
    testWidgets(
      'PersonalizationSettingsPage renders optical carousel with center stationary indicator',
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
        expect(find.text('FLUID MENISCUS RESERVOIR'), findsNothing);
        expect(find.byType(ListView), findsWidgets);
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );
  });

  group('5. App Icons Optical Carousel & Snapping Selection', () {
    testWidgets(
      'AppIconsSettingsPage renders optical icon carousel with Apple squircle target',
      (tester) async {
        String activeIcon = 'default';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppIconsSettingsPage(
                  p: testPalette,
                  appIconStyle: activeIcon,
                  godModeUnlocked: true,
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

        expect(find.text('Active Launcher Icon'), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);
        expect(find.byType(ListView), findsWidgets);
      },
    );
  });

  group('6. Guide & Knowledge Base New Entries', () {
    test(
      'allGuideItems contains 5 new architecture articles with keywords',
      () {
        expect(
          allGuideItems.any(
            (item) => item.title == 'Universal Title Tap-to-Scroll',
          ),
          isTrue,
        );
        expect(
          allGuideItems.any(
            (item) =>
                item.title ==
                'External Link HTTPS Verification & Security Check',
          ),
          isTrue,
        );
        expect(
          allGuideItems.any(
            (item) => item.title == 'Real-Time ECG Network Oscilloscope',
          ),
          isTrue,
        );
        expect(
          allGuideItems.any(
            (item) =>
                item.title == 'Adaptive Performance & Low-End Acceleration',
          ),
          isTrue,
        );
        expect(
          allGuideItems.any(
            (item) =>
                item.title ==
                'Circadian Relapse Trigger & Behavioral Pattern Analysis',
          ),
          isTrue,
        );

        final ecgItem = allGuideItems.firstWhere(
          (i) => i.title == 'Real-Time ECG Network Oscilloscope',
        );
        expect(ecgItem.keywords, contains('oscilloscope'));
        expect(ecgItem.keywords, contains('heartbeat'));

        final scrollItem = allGuideItems.firstWhere(
          (i) => i.title == 'Universal Title Tap-to-Scroll',
        );
        expect(scrollItem.keywords, contains('title scroll'));
        expect(scrollItem.keywords, contains('tap to top'));
      },
    );
  });
}
