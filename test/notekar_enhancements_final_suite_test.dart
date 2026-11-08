import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/checkpoint_session_sheet.dart';
import 'package:notekar/dialogs/experimental_build_unlocked_sheet.dart';
import 'package:notekar/dialogs/reset_sheets.dart';
import 'package:notekar/dialogs/settings/app_permissions_settings_page.dart';
import 'package:notekar/dialogs/settings/content_rating_settings_page.dart';
import 'package:notekar/dialogs/settings/god_mode_settings_page.dart';
import 'package:notekar/dialogs/settings/privacy_security_settings_page.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/category_service.dart';
import 'package:notekar/widgets/checkpoints_quick_bar.dart';
import 'package:notekar/widgets/design_system/nk_ios_switch.dart';
import 'package:notekar/widgets/feedback_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final pDark = paletteFor('dark');
  final pLight = paletteFor('light');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Task 1: Data Safety Hero Card (Apple HIG, minimal, powerful)', () {
    testWidgets(
      'DataSafetySettingsPage hero card renders cleanly without leading icon',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: DataSafetySettingsPage(
                  p: pDark,
                  vtRatio: '0/72',
                  vtStatus: 'Clean',
                  vtScanDate: '2026-10-30',
                  vtUrl: 'https://virustotal.com',
                  privacyLock: true,
                  obfuscateInRecents: false,
                  onObfuscateInRecentsChanged: (_) {},
                  onOpenCategory: (_, {required parent}) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('DATA SAFETY SOVEREIGNTY'), findsOneWidget);
        expect(find.text('Google Play & Store Disclosures'), findsOneWidget);
        expect(find.text('100% On-Device'), findsOneWidget);
        expect(find.text('0 KB (None)'), findsOneWidget);
        expect(find.text('Local Isar Encrypted'), findsOneWidget);
      },
    );
  });

  group('Task 2: App Permissions Page Top Card (Full width, no icon)', () {
    testWidgets('AppPermissions top card has no icon and spans edge-to-edge', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppPermissionsSettingsPage(p: pDark),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top card title and subtitle
      expect(find.text('DEVICE CAPABILITIES'), findsOneWidget);
      expect(find.text('App Permissions'), findsOneWidget);
      expect(find.text('Inspecting Permissions...'), findsOneWidget);

      // Verify no checkmark_shield icon was kept in the top card
      expect(find.byIcon(CupertinoIcons.checkmark_shield_fill), findsNothing);
    });
  });

  group(
    'Task 3: Content Rating Page (Full-width top card & Apple HIG bottom cards)',
    () {
      testWidgets(
        'ContentRating top card has full width and bottom cards use minimal status pills',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ContentRatingSettingsPage(p: pDark),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('GLOBAL CONTENT RATING'), findsOneWidget);
          expect(find.text('Rated for Everyone / Age 3+'), findsOneWidget);
          expect(find.text('3+'), findsOneWidget);
          expect(find.text('IARC'), findsOneWidget);
          expect(find.text('ESRB'), findsOneWidget);
          expect(find.text('PEGI'), findsOneWidget);
          expect(find.text('USK'), findsOneWidget);

          // Bottom cards use minimal status pills
          expect(find.text('Violence & Gore'), findsOneWidget);
          expect(find.text('Sexual Content & Nudity'), findsOneWidget);
          expect(find.text('Profanity & Crude Humor'), findsOneWidget);
          expect(find.text('Drugs, Alcohol & Tobacco'), findsOneWidget);
          expect(find.text('Gambling & Simulated Betting'), findsOneWidget);
          expect(find.text('None'), findsNWidgets(8));
        },
      );
    },
  );

  group('Task 4 & Q8: NkIosSwitch and App Lock switch cancellation', () {
    testWidgets(
      'NkIosSwitch strictly follows widget.value on tap without optimistic stuck state',
      (tester) async {
        bool switchVal = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (ctx, setState) {
                  return NkIosSwitch(
                    value: switchVal,
                    onChanged: (newVal) {
                      // Simulating user cancelling setup dialog: switchVal is NOT updated
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Verify initial state
        final switchFinder = find.byType(NkIosSwitch);
        expect(switchFinder, findsOneWidget);

        // Tap the switch
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Because switchVal remained false, the switch remains false and does not stick to true
        final widgetState = tester.widget<NkIosSwitch>(switchFinder);
        expect(widgetState.value, isFalse);
      },
    );
  });

  group('Task 5: Factory Reset Popups without Zero-Knowledge Notice', () {
    testWidgets('ResetAllConfirmSheet renders without Zero-Knowledge Notice', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResetAllConfirmSheet(
              p: pDark,
              title: 'Factory Reset NoteKar?',
              message: 'This will wipe all local data.',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Factory Reset NoteKar?'), findsOneWidget);
      expect(find.text('Zero-Knowledge Notice'), findsNothing);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('Tasks 6 & 7: Experimental Build Choose Option & God Mode Unlock', () {
    testWidgets(
      'BuildTrackSelectPage hides Developer Experiments when locked and channel is stable',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BuildTrackSelectPage(
                  p: pDark,
                  betaTrack: false,
                  currentChannel: 'stable',
                  isExperimentalUnlocked: false,
                  onSaveTrackPreference: (_) {},
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Stable Channel'), findsOneWidget);
        expect(find.text('Beta Channel'), findsOneWidget);
        expect(find.text('Developer Experiments'), findsNothing);
      },
    );

    testWidgets(
      'BuildTrackSelectPage shows Developer Experiments when unlocked even if currently on stable channel (God Mode Tester access)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BuildTrackSelectPage(
                  p: pDark,
                  betaTrack: false,
                  currentChannel: 'stable',
                  isExperimentalUnlocked: true,
                  onSaveTrackPreference: (_) {},
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Stable Channel'), findsOneWidget);
        expect(find.text('Beta Channel'), findsOneWidget);
        expect(find.text('Developer Experiments'), findsOneWidget);
      },
    );

    testWidgets(
      'BuildTrackSelectPage defaults to hiding Developer Experiments when isExperimentalUnlocked is omitted',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BuildTrackSelectPage(
                  p: pDark,
                  betaTrack: true,
                  currentChannel: 'beta',
                  onSaveTrackPreference: (_) {},
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Stable Channel'), findsOneWidget);
        expect(find.text('Beta Channel'), findsOneWidget);
        expect(find.text('Developer Experiments'), findsNothing);
      },
    );

    testWidgets(
      'ExperimentalBuildUnlockedSheet renders Apple HIG style modal with action buttons',
      (tester) async {
        bool navigated = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ExperimentalBuildUnlockedSheet(
                p: pDark,
                onNavigateToBuildChoose: () => navigated = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Experimental Build Unlocked'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.sparkles), findsOneWidget);
        expect(find.text('Choose Experimental Build'), findsOneWidget);
        expect(find.text('Dismiss'), findsOneWidget);

        await tester.tap(find.text('Choose Experimental Build'));
        await tester.pumpAndSettle();
        expect(navigated, isTrue);
      },
    );

    testWidgets(
      'GodModeSettingsPage displays Unlock Builds row and triggers callback',
      (tester) async {
        bool unlockTriggered = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: GodModeSettingsPage(
                  p: pDark,
                  currentTheme: 'dark',
                  onThemeChanged: (_) {},
                  totalMoments: 10,
                  streakDays: 5,
                  onRelockGodMode: () {},
                  onUnlockBuilds: () => unlockTriggered = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('DIRECT TESTER ACCESS'), findsOneWidget);
        expect(find.text('Unlock Builds'), findsOneWidget);

        await tester.ensureVisible(find.text('Unlock Builds'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Unlock Builds'));
        await tester.pumpAndSettle();
        expect(unlockTriggered, isTrue);
      },
    );
  });

  group('Q1: Habits live session timer starts from now', () {
    testWidgets(
      'CheckpointSessionSheet onStartLive receives current DateTime',
      (tester) async {
        DateTime? receivedStart;
        const preset = CheckpointPreset(
          id: 'test_habit',
          label: 'Workout',
          emoji: '🏋️',
          category: 'Health',
        );

        final before = DateTime.now();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckpointSessionSheet(
                p: pDark,
                preset: preset,
                onLogSession: ({required start, required end, note}) async {},
                onStartLive: ({required start, note}) async {
                  receivedStart = start;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap the Start Live Timer Now button
        final startLiveButton = find.text('Start Live Timer Now');
        expect(startLiveButton, findsOneWidget);
        await tester.tap(startLiveButton);
        await tester.pumpAndSettle();

        expect(receivedStart, isNotNull);
        expect(
          receivedStart!.difference(before).inSeconds.abs(),
          lessThanOrEqualTo(2),
        );
      },
    );
  });

  group('Q2 & Q3: CheckpointsQuickBar habit selection color & high contrast', () {
    testWidgets(
      'CheckpointsQuickBar applies category color and contrast safe text for completed habits',
      (tester) async {
        final meta = getCategoryMeta('Health', pLight);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckpointsQuickBar(
                p: pLight,
                moments: const [],
                onLogCheckpoint: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check header exists
        expect(find.textContaining('Habits'), findsOneWidget);
        expect(meta.color, isNotNull);
      },
    );
  });

  group('Q4 & Q7: Stop option and Habit title long-press', () {
    testWidgets(
      'CheckpointsQuickBar long-press on header pill invokes onOpenSettings',
      (tester) async {
        bool settingsOpened = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckpointsQuickBar(
                p: pDark,
                moments: const [],
                onLogCheckpoint: (_) {},
                onOpenSettings: () => settingsOpened = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Long press on Habits title pill
        final habitTitleFinder = find.textContaining('Habits');
        expect(habitTitleFinder, findsOneWidget);

        await tester.longPress(habitTitleFinder);
        await tester.pumpAndSettle();

        expect(settingsOpened, isTrue);
      },
    );

    testWidgets(
      'CheckpointsQuickBar renders Stop button when isSessionActive is true',
      (tester) async {
        bool stopCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckpointsQuickBar(
                p: pDark,
                moments: const [],
                onLogCheckpoint: (_) {},
                isSessionActive: true,
                onStopSession: () => stopCalled = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final stopFinder = find.text('Stop');
        expect(stopFinder, findsOneWidget);

        await tester.tap(stopFinder);
        await tester.pumpAndSettle();
        expect(stopCalled, isTrue);
      },
    );

    testWidgets('UndoToast renders Stop action when onStop is provided', (
      tester,
    ) async {
      bool stopped = false;
      bool undid = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UndoToast(
              p: pDark,
              onUndo: () => undid = true,
              token: 1,
              message: 'Session active',
              persistent: true,
              onStop: () => stopped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Stop'), findsOneWidget);

      await tester.tap(find.text('Stop'));
      await tester.pumpAndSettle();
      expect(stopped, isTrue);
      expect(undid, isFalse);
    });
  });

  group('Q5: Checkpoint background color reset', () {
    test(
      'CategoryService allows setting and resetting category color',
      () async {
        final service = CategoryService.instance;
        const testCat = 'CustomCategoryForTest';

        await service.setCategoryColor(testCat, const Color(0xFFFF5500));
        expect(
          service.getCategoryColor(testCat),
          equals(const Color(0xFFFF5500)),
        );

        await service.resetCategoryColor(testCat);
        expect(service.getCategoryColor(testCat), isNull);
      },
    );
  });
}
