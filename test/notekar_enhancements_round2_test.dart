import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/settings/advanced_settings_page.dart';
import 'package:notekar/dialogs/settings/app_icons_settings_page.dart';
import 'package:notekar/dialogs/settings/diagnostics_settings_page.dart';
import 'package:notekar/dialogs/settings/display_settings_page.dart';
import 'package:notekar/dialogs/settings/personalization_settings_page.dart';
import 'package:notekar/dialogs/settings/privacy_security_settings_page.dart';
import 'package:notekar/dialogs/settings/sobriety_companion_settings_page.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/common_elements.dart';
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

  group('1. Universal Title Tap-to-Scroll', () {
    testWidgets(
      'AppSheetLargeTitle responds to tap and invokes onTap callback',
      (tester) async {
        final scrollController = ScrollController();
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    AppSheetLargeTitle(
                      title: 'Universal Header',
                      p: testPalette,
                      onTap: () {
                        tapped = true;
                      },
                    ),
                    const SizedBox(height: 1200),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Universal Header'), findsOneWidget);
        await tester.tap(find.text('Universal Header'));
        await tester.pumpAndSettle();
        expect(tapped, isTrue);
      },
    );

    testWidgets('AppSheet header title is interactive and invokes onTitleTap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 380,
                height: 300,
                child: AppSheet(
                  title: 'Diagnostics Sheet',
                  p: testPalette,
                  onTitleTap: () {
                    tapped = true;
                  },
                  child: const SizedBox(height: 80),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Diagnostics Sheet'), findsOneWidget);
      await tester.tap(find.text('Diagnostics Sheet'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('2. External Link Security Check Dialog', () {
    testWidgets(
      'ExternalLinkConfirmSheet shows Safe & Encrypted badge for HTTPS URL',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExternalLinkConfirmSheet(
                url: 'https://github.com/notekar/safe',
                p: testPalette,
              ),
            ),
          ),
        );

        expect(find.text('SECURE HTTPS · SAFE'), findsOneWidget);
        expect(find.text('Open Link'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.lock_shield_fill), findsOneWidget);
      },
    );

    testWidgets(
      'ExternalLinkConfirmSheet shows Unencrypted Connection warning for HTTP URL',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExternalLinkConfirmSheet(
                url: 'http://insecure-site.example.com',
                p: testPalette,
              ),
            ),
          ),
        );

        expect(find.text('UNENCRYPTED HTTP · NOT SAFE'), findsOneWidget);
        expect(find.text('Open Anyway'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(
          find.byIcon(CupertinoIcons.exclamationmark_triangle_fill),
          findsOneWidget,
        );
      },
    );
  });

  group('3. Privacy & Security -> Network Monitor Navigation', () {
    testWidgets(
      'PrivacySecuritySettingsPage navigates to Network Monitor on Network Use tap',
      (tester) async {
        String? navigatedCat;
        String? navigatedParent;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PrivacySecuritySettingsPage(
                  p: testPalette,
                  vtRatio: '0/70',
                  vtStatus: 'Clean',
                  vtScanDate: 'Today',
                  vtUrl: 'https://virustotal.com',
                  privacyLock: false,
                  obfuscateInRecents: false,
                  onObfuscateInRecentsChanged: (_) {},
                  onOpenCategory: (cat, {required parent}) {
                    navigatedCat = cat;
                    navigatedParent = parent;
                  },
                ),
              ),
            ),
          ),
        );

        final networkCard = find.text('Network Use');
        expect(networkCard, findsOneWidget);
        await tester.tap(networkCard);
        await tester.pumpAndSettle();

        expect(navigatedCat, 'Network Monitor');
        expect(navigatedParent, 'Developer Options');
      },
    );
  });

  group('4. Network Monitor Hospital ECG Waveform & Redesign', () {
    testWidgets(
      'DiagnosticsSettingsPage renders Network Monitor with ECG Card and telemetry',
      (tester) async {
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
        expect(find.text('0.0 KB'), findsOneWidget);
      },
    );
  });

  group('5. Device Health Consolidated Sheet', () {
    testWidgets(
      'DiagnosticsSettingsPage renders consolidated Device Health with hardware specs & privacy notice',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: DiagnosticsSettingsPage(
                  p: testPalette,
                  subCategory: 'Device Health',
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

        await tester.pump();
        expect(
          find.text('Hardware Privacy & Sovereign Processing'),
          findsOneWidget,
        );
        expect(find.text('System Health'), findsOneWidget);
        expect(find.text('CPU Cores'), findsOneWidget);
      },
    );
  });

  group('6. Factory Reset Zero-Knowledge Legal Notice', () {
    testWidgets(
      'ResetAllConfirmSheet displays Apple-style zero-knowledge local storage legal notice',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ResetAllConfirmSheet(
                  p: testPalette,
                  title: 'Factory Reset',
                  message: 'Erase all user data and settings.',
                ),
              ),
            ),
          ),
        );

        expect(find.text('Zero-Knowledge Notice'), findsOneWidget);
        expect(
          find.textContaining(
            'NoteKar does not collect or sync data to any cloud',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AdvancedSettingsPage displays Apple-style factory reset permanence notice',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AdvancedSettingsPage(
                  p: testPalette,
                  subCategory: 'Reset',
                  hapticStyle: 'default',
                  reduceMotion: false,
                  largeText: false,
                  highContrast: false,
                  healthStatus: 'Optimal',
                  onHapticStyleChanged: (_) {},
                  onReduceMotionChanged: (_) {},
                  onLargeTextChanged: (_) {},
                  onHighContrastChanged: (_) {},
                  onResetSettings: () {},
                  onResetAllData: () {},
                  onFactoryReset: () {},
                  onOpenCategory: (_, {required parent}) {},
                  onExportCsv: () {},
                  onExportJson: () {},
                  onExportBackup: () {},
                  onResetCircuitBreakers: () {},
                ),
              ),
            ),
          ),
        );

        expect(
          find.text('Permanent Deletion & Zero-Knowledge Storage'),
          findsNothing,
        );
        expect(find.text('Reset Settings'), findsOneWidget);
        expect(find.text('Reset All Data'), findsOneWidget);
        expect(find.text('Factory Reset'), findsOneWidget);
        expect(
          find.textContaining(
            'Data wipe operations permanently erase local storage',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('7. Sobriety Companion Enhancements & Trigger Analysis', () {
    testWidgets(
      'SobrietyCompanionSettingsPage renders clean Theme Style and View All Milestones',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SobrietyCompanionSettingsPage(
                  p: testPalette,
                  enableSobrietyMode: true,
                  sobrietyResetType: 'streak',
                  sobrietyCustomStartMs: DateTime.now().millisecondsSinceEpoch,
                  sobrietyMilestoneTheme: 'science',
                  onEnableSobrietyModeChanged: (_) {},
                  onSobrietyCustomStartMsChanged: (_) {},
                  onOpenCategory: (_, {required parent}) {},
                  onSelectStartDate: (ctx, d) async => d,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Theme Style'), findsOneWidget);
        expect(find.textContaining('Science'), findsOneWidget);
        expect(find.text('View All Milestones'), findsOneWidget);
        expect(find.textContaining('Explore 21 milestones'), findsOneWidget);
      },
    );

    testWidgets('MilestoneThemePage renders thematic milestone descriptions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MilestoneThemePage(
                p: testPalette,
                sobrietyMilestoneTheme: 'science',
                onThemeChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(
        find.textContaining(
          'Choose the narrative style for your milestone names',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('Clinical neuroscience terms'),
        findsOneWidget,
      );
    });

    testWidgets(
      'TriggerAnalysisPage renders clean unbroken trajectory or circadian breakdown',
      (tester) async {
        // 1. Unbroken clean trajectory when no relapse entries
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TriggerAnalysisPage(p: testPalette, entries: const []),
              ),
            ),
          ),
        );

        expect(find.text('Unbroken Clean Trajectory'), findsOneWidget);

        // 2. Full circadian analysis when relapse entries exist
        final relapseTime = DateTime(2026, 10, 24, 21, 30); // 9:30 PM (Night)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TriggerAnalysisPage(
                  p: testPalette,
                  entries: [
                    Moment(
                      id: 1,
                      timestamp: relapseTime.millisecondsSinceEpoch,
                      type: 'moment',
                      date: '2026-10-24',
                      note:
                          '#relapse #trigger:stress #mood:anxious Exhausted late night',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('CIRCADIAN RISK DISTRIBUTION'), findsOneWidget);
        expect(find.text('Morning'), findsOneWidget);
        expect(find.text('Night'), findsWidgets);
        expect(find.text('RANKED TRIGGER VULNERABILITY'), findsOneWidget);
        expect(find.text('EMOTIONAL PRECURSOR CLUSTERS'), findsOneWidget);
        expect(
          find.textContaining(
            'All behavioral correlations are computed locally in device memory',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('8. Display Page Live Home Screen Preview Card', () {
    testWidgets(
      'DisplaySettingsPage renders tall iOS home preview card with live controls',
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

        expect(find.text('LIVE HOME PREVIEW'), findsOneWidget);
        expect(find.text('Deep Work Session Completed'), findsOneWidget);
        expect(find.text('History'), findsOneWidget);
        expect(find.text('Log'), findsOneWidget);
        expect(find.text('Remind'), findsOneWidget);
        expect(find.text('Menu'), findsOneWidget);
      },
    );
  });

  group('9. Accent Color Optical Carousel & Fluid Reservoir', () {
    test('kAccentColorPalette contains rich Apple-style color entries', () {
      expect(kAccentColorPalette.length, greaterThanOrEqualTo(10));
      expect(kAccentColorPalette.any((c) => c.name == 'Sapphire'), isTrue);
      expect(kAccentColorPalette.any((c) => c.name == 'Emerald'), isTrue);
    });

    testWidgets(
      'PersonalizationSettingsPage renders optical accent carousel and fluid reservoir',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PersonalizationSettingsPage(
                  p: testPalette,
                  subCategory: 'Accent Color',
                  theme: 'dark',
                  accentColor: 'blue',
                  appIconStyle: 'default',
                  currentLocale: 'system',
                  reduceMotion: false,
                  enableTranslucency: true,
                  onLocaleChanged: (_) {},
                  onAccentColorChanged: (_) {},
                  onOpenCategory: (_, {required parent}) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('FLUID MENISCUS RESERVOIR'), findsNothing);
        expect(find.text('TAP ANY FISH TO HARMONIZE ACCENT'), findsOneWidget);
        expect(
          find.text('${kAccentColorPalette.length} Living Species'),
          findsOneWidget,
        );
      },
    );
  });

  group('10. App Icons Mock Home Preview & Optical Chooser', () {
    testWidgets(
      'AppIconsSettingsPage renders mock home preview, optical chooser and launcher card',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppIconsSettingsPage(
                  p: testPalette,
                  appIconStyle: 'default',
                  onAppIconStyleChanged: (_) async => true,
                ),
              ),
            ),
          ),
        );

        expect(find.text('9:41'), findsOneWidget);
        expect(find.text('SWIPE OR TAP TO SWITCH ICON'), findsOneWidget);
        expect(find.text('Active Launcher Icon'), findsOneWidget);
        expect(find.text('Applied to Android Home Screen'), findsOneWidget);
      },
    );
  });
}
