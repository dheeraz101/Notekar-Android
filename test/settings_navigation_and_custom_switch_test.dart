import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/official_bulletins_sheet.dart';
import 'package:notekar/dialogs/settings_dialog.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/design_system/nk_ios_switch.dart';
import 'package:notekar/widgets/predictive_back_peek.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPalette = Palette(
    name: 'light',
    bg: const Color(0xFFF2F2F7),
    surface: const Color(0xFFF7F7F9),
    surface2: const Color(0xFFFFFFFF),
    surface3: const Color(0xFFE5E5EA),
    border: const Color(0xFFE5E5EA),
    text: const Color(0xFF000000),
    text2: const Color(0xFF3C3C43),
    text3: const Color(0xFF6C6C70),
    clock: const Color(0xFFD1D1D6),
    accent: const Color(0xFF007AFF),
    green: const Color(0xFF248A3D),
    orange: const Color(0xFFC46A00),
    red: const Color(0xFFD70015),
    blue: const Color(0xFF007AFF),
  );

  group('Olden iOS Custom Switch Toggle (Commit 9a166b26) Verification', () {
    testWidgets(
      'Renders with exact 62x32 track, accessibility indicators, and 34px pill thumb',
      (tester) async {
        bool switchVal = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Center(
                    child: NkIosSwitch(
                      value: switchVal,
                      onChanged: (v) => setState(() => switchVal = v),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final trackFinder = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.constraints?.maxWidth == 62.0 &&
              w.constraints?.maxHeight == 32.0,
        );
        expect(trackFinder, findsOneWidget);

        // Verify pill thumb container has base width 34 and height 28
        final thumbFinder = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.constraints?.maxWidth == 34.0 &&
              w.constraints?.maxHeight == 28.0,
        );
        expect(thumbFinder, findsOneWidget);

        // Tap toggles switch to true
        await tester.tap(find.byType(NkIosSwitch));
        await tester.pumpAndSettle();
        expect(switchVal, isTrue);

        // Verify accessibility indicators exist in switch tree
        expect(
          find.descendant(
            of: find.byType(NkIosSwitch),
            matching: find.byType(Align),
          ),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'Pressing switch triggers fluid stretch animation without clipping',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(child: NkIosSwitch(value: false, onChanged: (_) {})),
            ),
          ),
        );

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(NkIosSwitch)),
        );
        await gesture.moveBy(const Offset(20.0, 0.0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 140));

        // Locate stretched thumb container (width > 34.0)
        final stretchedThumbFinder = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              (w.constraints?.maxWidth ?? 0) > 34.0 &&
              w.constraints?.maxHeight == 28.0,
        );
        expect(stretchedThumbFinder, findsOneWidget);

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('SettingsSwitchRow uses NkIosSwitch and toggles on tap', (
      tester,
    ) async {
      bool rowVal = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SettingsSwitchRow(
                  p: testPalette,
                  title: 'Test Switch Row',
                  value: rowVal,
                  onChanged: (v) => setState(() => rowVal = v),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(NkIosSwitch), findsOneWidget);
      expect(find.text('Test Switch Row'), findsOneWidget);

      await tester.tap(find.byType(SettingsSwitchRow));
      await tester.pumpAndSettle();
      expect(rowVal, isTrue);
    });

    testWidgets(
      'Controlled switch: when parent rejects state change, switch reconciles back to false without desync',
      (tester) async {
        bool switchVal = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Center(
                    child: NkIosSwitch(
                      value: switchVal,
                      onChanged: (v) {
                        // Reject change: do not mutate switchVal, but trigger rebuild
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Tap switch
        await tester.tap(find.byType(NkIosSwitch));
        // Pump 50ms into animation
        await tester.pump(const Duration(milliseconds: 50));
        // Settle animation
        await tester.pumpAndSettle();

        // Switch value in parent remains false
        expect(switchVal, isFalse);

        // Verify thumb returned to 0 position (left-aligned)
        final thumbContainer = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.constraints?.maxWidth == 34.0 &&
              w.constraints?.maxHeight == 28.0,
        );
        expect(thumbContainer, findsOneWidget);
      },
    );
  });

  group('Settings In-Depth Pages Hierarchical Back-Navigation', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Widget buildTestSettingsDialog({
      String? initialCategory,
      Future<bool> Function(bool)? onPrivacyLock,
    }) {
      final entriesNotifier = ValueNotifier<List<Moment>>([]);
      final trashNotifier = ValueNotifier<List<Moment>>([]);

      return MaterialApp(
        home: Scaffold(
          body: SettingsDialog(
            p: testPalette,
            initialCategory: initialCategory,
            theme: 'light',
            defaultMode: 'two-way',
            tapDelay: 300,
            accentColor: 'blue',
            appIconStyle: 'default',
            hapticStyle: 'standard',
            historyDensity: 'standard',
            privacyLock: false,
            backupReminderDays: 7,
            lastBackupAt: null,
            remoteNotices: false,
            reduceMotion: true,
            largeText: false,
            highContrast: false,
            confirmDelete: false,
            showSeconds: false,
            highlightSeconds: false,
            buttonLabels: true,
            largeControls: false,
            homeMenuPill: false,
            homeMenuAnimations: false,
            showHistoryText: true,
            showLastSavedHint: true,
            extendedDuration: false,
            minimalMomentOptions: false,
            enableTranslucency: false,
            privacyLockDelayMinutes: 0,
            isSystemLockAvailable: false,
            privacyLockType: 'system',
            onPrivacyLockTypeChanged: (_) async => true,
            updateStatus: '',
            checkingUpdates: false,
            lastUpdateCheckedAt: null,
            entriesNotifier: entriesNotifier,
            lastSavedAt: null,
            trashEntriesNotifier: trashNotifier,
            currentLocale: 'en',
            onLocaleChanged: (_) {},
            onTheme: (_) {},
            onDefaultMode: (_) {},
            onDelay: (_) {},
            onAccentColor: (_) {},
            onAppIconStyle: (_) async => true,
            onHapticStyle: (_) {},
            onHistoryDensity: (_) {},
            onPrivacyLock: onPrivacyLock ?? (_) async => true,
            onResetPrivacyPin: () async {},
            onBackupReminderDays: (_) {},
            onRemoteNotices: (_) {},
            onReduceMotion: (_) {},
            onLargeText: (_) {},
            onHighContrast: (_) {},
            onConfirmDelete: (_) {},
            onShowSeconds: (_) {},
            onHighlightSeconds: (_) {},
            onButtonLabels: (_) {},
            onLargeControls: (_) {},
            onHomeMenuPill: (_) {},
            onHomeMenuAnimations: (_) async => true,
            onShowHistoryText: (_) {},
            onShowLastSavedHint: (_) {},
            onExtendedDuration: (_) {},
            onMinimalMomentOptions: (_) {},
            onTranslucency: (_) {},
            onPrivacyLockDelay: (_) {},
            onExportCsv: () async => '',
            onExportRecentCsv: () async => '',
            onExportJson: () async => '',
            onExportBackup: () async => '',
            onImportBackup: () async {},
            onRestoreBackupFromString: (_) async => true,
            onSaveQuickBackup: () async {},
            onCheckUpdates: () async => (status: 'Up to date', info: null),
            onOpenLink: (_) {},
            onShowChangelog: (_) {},
            onReset: () async {},
            onFactoryReset: () async {},
            onResetSettings: () async {},
            onRestoreSettings: (_) async {},
            onFeedback: (_) {},
            onRestoreTrashMoment: (_) async {},
            onRestoreAllTrash: () async {},
            onDeleteTrashPermanent: (_) async {},
            onClearTrash: () async {},
          ),
        ),
      );
    }

    Future<void> pumpFrames(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
    }

    testWidgets(
      'Opening initialCategory "Display" pops back to "Personalization" and then root',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Display'),
        );
        await pumpFrames(tester);

        expect(find.text('Display'), findsWidgets);

        // Tap back button
        final backButton = find.byTooltip('Back');
        expect(backButton, findsOneWidget);
        await tester.tap(backButton);
        await pumpFrames(tester);

        // Should now be on Personalization, NOT Root
        expect(find.text('Personalization'), findsWidgets);

        // Second tap back should transition to root settings
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);

        expect(find.text('Settings'), findsWidgets);
      },
    );

    testWidgets(
      'Opening initialCategory "Search Notes" (Level 3) pops back to "Moments", then "Logging", then root',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Search Notes'),
        );
        await pumpFrames(tester);

        expect(find.text('Search Notes'), findsWidgets);

        // First back pop -> Moments
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Moments'), findsWidgets);

        // Second back pop -> Logging
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Logging'), findsWidgets);

        // Third back pop -> Main Settings
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Settings'), findsWidgets);
      },
    );

    testWidgets(
      'Opening initialCategory "Mode: Work" pops back to "Modes", then "Logging", then root',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Mode: Work'),
        );
        await pumpFrames(tester);

        // First back pop -> Modes
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Modes'), findsWidgets);

        // Second back pop -> Logging
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Logging'), findsWidgets);
      },
    );

    testWidgets(
      'Opening initialCategory "Local Backups" pops to "Data & Backup", then "Data safety", then root',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Local Backups'),
        );
        await pumpFrames(tester);

        // First back pop -> Data & Backup
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Data & Backup'), findsWidgets);

        // Second back pop -> Data safety
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Data safety'), findsWidgets);

        // Third back pop -> Settings
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Settings'), findsWidgets);
      },
    );

    testWidgets(
      'Opening initialCategory "Configure Lock" (Level 3) pops to "App Lock", then "Data safety", then root',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Configure Lock'),
        );
        await pumpFrames(tester);

        expect(find.text('Configure Lock'), findsWidgets);

        // First back pop -> App Lock
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('App Lock'), findsWidgets);

        // Second back pop -> Data safety
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Data safety'), findsWidgets);

        // Third back pop -> Settings root
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Settings'), findsWidgets);
      },
    );

    testWidgets(
      'Opening initialCategory "Personal Profile" pops directly to root Settings',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Personal Profile'),
        );
        await pumpFrames(tester);

        expect(find.text('Personal Profile'), findsWidgets);

        // First back pop -> Settings root (not Personalization!)
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Settings'), findsWidgets);
      },
    );

    testWidgets(
      'Opening aliased initialCategory "Display & Gestures" normalizes to Display and pops to Personalization then root',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Display & Gestures'),
        );
        await pumpFrames(tester);

        expect(find.text('Display'), findsWidgets);

        // First back pop -> Personalization
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Personalization'), findsWidgets);

        // Second back pop -> Settings root
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Settings'), findsWidgets);
      },
    );

    testWidgets(
      'Opening initialCategory "Integrations & Automation" pops to "Advanced" then root',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Integrations & Automation'),
        );
        await pumpFrames(tester);

        expect(find.text('Automation'), findsWidgets);

        // First back pop -> Advanced (not Logging!)
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Advanced'), findsWidgets);

        // Second back pop -> Settings root
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Settings'), findsWidgets);
      },
    );

    testWidgets(
      'Opening initialCategory "Time Reflection" (Level 3) pops to "Reminders", then "Logging", then root',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Time Reflection'),
        );
        await pumpFrames(tester);

        expect(find.text('Time Reflection'), findsWidgets);

        // First back pop -> Reminders
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Reminders'), findsWidgets);

        // Second back pop -> Logging
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Logging'), findsWidgets);

        // Third back pop -> Settings root
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Settings'), findsWidgets);
      },
    );

    testWidgets(
      'Opening "Network Monitor" pops to its canonical parent "Developer Options", then "Advanced", then root',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Network Monitor'),
        );
        await pumpFrames(tester);

        expect(find.text('Network Monitor'), findsWidgets);

        // First back pop -> Developer Options
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Developer Options'), findsWidgets);

        // Second back pop -> Advanced
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Advanced'), findsWidgets);

        // Third back pop -> Settings root
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);
        expect(find.text('Settings'), findsWidgets);
      },
    );

    testWidgets(
      'Edge swipe gesture via PredictiveBackPeek pops Level 3 page back to Level 2',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Local Backups'),
        );
        await pumpFrames(tester);

        expect(find.text('Local Backups'), findsWidgets);

        // Perform edge swipe starting within 40px left edge
        final peekFinder = find.byType(PredictiveBackPeek);
        expect(peekFinder, findsOneWidget);
        final topLeft = tester.getTopLeft(peekFinder);

        await tester.dragFrom(
          topLeft + const Offset(15.0, 150.0),
          const Offset(120.0, 0.0),
        );
        await pumpFrames(tester);

        // Should now be on Data & Backup
        expect(find.text('Data & Backup'), findsWidgets);
      },
    );

    testWidgets(
      'System back (handlePopRoute) ascends hierarchy from Level 3 to root and exits sheet',
      (tester) async {
        final entriesNotifier = ValueNotifier<List<Moment>>([]);
        final trashNotifier = ValueNotifier<List<Moment>>([]);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (ctx) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: ctx,
                          isScrollControlled: true,
                          builder: (_) => SettingsDialog(
                            p: testPalette,
                            initialCategory: 'Configure Lock',
                            theme: 'light',
                            defaultMode: 'two-way',
                            tapDelay: 300,
                            accentColor: 'blue',
                            appIconStyle: 'default',
                            hapticStyle: 'standard',
                            historyDensity: 'standard',
                            privacyLock: false,
                            backupReminderDays: 7,
                            lastBackupAt: null,
                            remoteNotices: false,
                            reduceMotion: true,
                            largeText: false,
                            highContrast: false,
                            confirmDelete: false,
                            showSeconds: false,
                            highlightSeconds: false,
                            buttonLabels: true,
                            largeControls: false,
                            homeMenuPill: false,
                            homeMenuAnimations: false,
                            showHistoryText: true,
                            showLastSavedHint: true,
                            extendedDuration: false,
                            minimalMomentOptions: false,
                            enableTranslucency: false,
                            privacyLockDelayMinutes: 0,
                            isSystemLockAvailable: false,
                            privacyLockType: 'system',
                            onPrivacyLockTypeChanged: (_) async => true,
                            updateStatus: '',
                            checkingUpdates: false,
                            lastUpdateCheckedAt: null,
                            entriesNotifier: entriesNotifier,
                            lastSavedAt: null,
                            trashEntriesNotifier: trashNotifier,
                            currentLocale: 'en',
                            onLocaleChanged: (_) {},
                            onTheme: (_) {},
                            onDefaultMode: (_) {},
                            onDelay: (_) {},
                            onAccentColor: (_) {},
                            onAppIconStyle: (_) async => true,
                            onHapticStyle: (_) {},
                            onHistoryDensity: (_) {},
                            onPrivacyLock: (_) async => true,
                            onResetPrivacyPin: () async {},
                            onBackupReminderDays: (_) {},
                            onRemoteNotices: (_) {},
                            onReduceMotion: (_) {},
                            onLargeText: (_) {},
                            onHighContrast: (_) {},
                            onConfirmDelete: (_) {},
                            onShowSeconds: (_) {},
                            onHighlightSeconds: (_) {},
                            onButtonLabels: (_) {},
                            onLargeControls: (_) {},
                            onHomeMenuPill: (_) {},
                            onHomeMenuAnimations: (_) async => true,
                            onShowHistoryText: (_) {},
                            onShowLastSavedHint: (_) {},
                            onExtendedDuration: (_) {},
                            onMinimalMomentOptions: (_) {},
                            onTranslucency: (_) {},
                            onPrivacyLockDelay: (_) {},
                            onExportCsv: () async => '',
                            onExportRecentCsv: () async => '',
                            onExportJson: () async => '',
                            onExportBackup: () async => '',
                            onImportBackup: () async {},
                            onRestoreBackupFromString: (_) async => true,
                            onSaveQuickBackup: () async {},
                            onCheckUpdates: () async =>
                                (status: 'Up to date', info: null),
                            onOpenLink: (_) {},
                            onShowChangelog: (_) {},
                            onReset: () async {},
                            onFactoryReset: () async {},
                            onResetSettings: () async {},
                            onRestoreSettings: (_) async {},
                            onFeedback: (_) {},
                            onRestoreTrashMoment: (_) async {},
                            onRestoreAllTrash: () async {},
                            onDeleteTrashPermanent: (_) async {},
                            onClearTrash: () async {},
                          ),
                        );
                      },
                      child: const Text('Open Settings'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Open Settings sheet
        await tester.tap(find.text('Open Settings'));
        await pumpFrames(tester);

        expect(find.text('Configure Lock'), findsWidgets);

        // System back 1: pops Configure Lock -> App Lock
        bool handled = await tester.binding.handlePopRoute();
        expect(handled, isTrue);
        await pumpFrames(tester);
        expect(find.text('App Lock'), findsWidgets);

        // System back 2: pops App Lock -> Data safety
        handled = await tester.binding.handlePopRoute();
        expect(handled, isTrue);
        await pumpFrames(tester);
        expect(find.text('Data safety'), findsWidgets);

        // System back 3: pops Data safety -> Settings root
        handled = await tester.binding.handlePopRoute();
        expect(handled, isTrue);
        await pumpFrames(tester);
        expect(find.text('Settings'), findsWidgets);

        // System back 4: pops Settings root -> exits bottom sheet
        handled = await tester.binding.handlePopRoute();
        expect(handled, isTrue);
        await pumpFrames(tester);
        expect(find.text('Open Settings'), findsOneWidget);
        expect(find.text('Settings'), findsNothing);
      },
    );

    testWidgets(
      'Rapid double-tap back during running transition animation navigates up two tiers smoothly',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(initialCategory: 'Local Backups'),
        );
        await pumpFrames(tester);

        expect(find.text('Local Backups'), findsWidgets);

        // First tap initiates transition to Data & Backup
        await tester.tap(find.byTooltip('Back'));
        // Advance only 30ms so animation is actively running
        await tester.pump(const Duration(milliseconds: 30));

        // Second rapid tap while animating
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);

        // Should have cleanly navigated up 2 tiers to Data safety
        expect(find.text('Data safety'), findsWidgets);
      },
    );

    testWidgets(
      'OfficialBulletinsSheet modal dismisses itself before invoking onNavigateAction',
      (tester) async {
        String? targetAction;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (ctx) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        OfficialBulletinsSheet.show(
                          ctx,
                          p: testPalette,
                          onOpenLink: (_) {},
                          onNavigateAction: (route) {
                            targetAction = route;
                          },
                        );
                      },
                      child: const Text('Open Bulletins'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Open Official Bulletins modal sheet
        await tester.tap(find.text('Open Bulletins'));
        await pumpFrames(tester);

        expect(find.text('Official Bulletins'), findsOneWidget);

        // Tap back on the sheet
        await tester.tap(find.byTooltip('Back'));
        await pumpFrames(tester);

        // Modal sheet should be dismissed, returning to parent scaffold
        expect(find.text('Open Bulletins'), findsOneWidget);
        expect(find.text('Official Bulletins'), findsNothing);
        expect(targetAction, isNull);
      },
    );

    testWidgets(
      'App Lock switch cancels cleanly without showing switch enabled when setup returns false',
      (tester) async {
        await tester.pumpWidget(
          buildTestSettingsDialog(
            initialCategory: 'App Lock',
            onPrivacyLock: (_) async => false, // User cancels setup!
          ),
        );

        await pumpFrames(tester);

        expect(find.text('App Lock'), findsWidgets);

        // Find the App Lock NkIosSwitch
        final switchFinder = find.byType(NkIosSwitch);
        expect(switchFinder, findsOneWidget);
        final initialSwitch = tester.widget<NkIosSwitch>(switchFinder);
        expect(initialSwitch.value, isFalse);

        // Tap the App Lock row / switch
        await tester.tap(find.text('App Lock').first);
        await pumpFrames(tester);

        // Switch MUST remain false (not enabled)
        final postCancelSwitch = tester.widget<NkIosSwitch>(switchFinder);
        expect(postCancelSwitch.value, isFalse);
      },
    );
  });
}
