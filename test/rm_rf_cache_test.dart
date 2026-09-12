import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/dialogs/settings_dialog.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  Widget buildSettingsDialog({Key? key, required String initialCategory}) {
    return MaterialApp(
      home: Scaffold(
        body: SettingsDialog(
          key: key,
          p: p,
          initialCategory: initialCategory,
          theme: 'dark',
          defaultMode: 'instant',
          tapDelay: 350,
          accentColor: 'orange',
          appIconStyle: 'classic',
          hapticStyle: 'medium',
          historyDensity: 'comfortable',
          privacyLock: false,
          backupReminderDays: 7,
          lastBackupAt: null,
          remoteNotices: true,
          reduceMotion: false,
          largeText: false,
          highContrast: false,
          compactHistory: false,
          confirmDelete: true,
          showSeconds: false,
          highlightSeconds: false,
          buttonLabels: false,
          largeControls: false,
          homeMenuPill: true,
          homeMenuAnimations: true,
          showHistoryText: true,
          showLastSavedHint: true,
          requireLongPressNote: false,
          extendedDuration: false,
          enableTranslucency: false,
          minimalMomentOptions: false,
          privacyLockDelayMinutes: 0,
          isSystemLockAvailable: false,
          privacyLockType: 'pin',
          onPrivacyLockTypeChanged: (_) async => true,
          updateStatus: 'idle',
          checkingUpdates: false,
          lastUpdateCheckedAt: null,
          entriesNotifier: ValueNotifier<List<Moment>>([]),
          lastSavedAt: null,
          onTheme: (_) {},
          onDefaultMode: (_) {},
          onDelay: (_) {},
          onAccentColor: (_) {},
          onAppIconStyle: (_) async {},
          onHapticStyle: (_) {},
          onHistoryDensity: (_) {},
          onPrivacyLock: (_) async => true,
          onResetPrivacyPin: () async {},
          onBackupReminderDays: (_) {},
          onRemoteNotices: (_) {},
          onReduceMotion: (_) {},
          onLargeText: (_) {},
          onHighContrast: (_) {},
          onCompactHistory: (_) {},
          onConfirmDelete: (_) {},
          onShowSeconds: (_) {},
          onHighlightSeconds: (_) {},
          onButtonLabels: (_) {},
          onLargeControls: (_) {},
          onHomeMenuPill: (_) {},
          onHomeMenuAnimations: (_) async => true,
          onShowHistoryText: (_) {},
          onShowLastSavedHint: (_) {},
          onRequireLongPressNote: (_) {},
          onExtendedDuration: (_) {},
          onMinimalMomentOptions: (_) {},
          onTranslucency: (_) {},
          onPrivacyLockDelay: (_) {},
          onExportCsv: () async {},
          onExportRecentCsv: () async {},
          onExportJson: () async {},
          onExportBackup: () async {},
          onImportBackup: () async {},
          onRestoreBackupFromString: (_) async => true,
          onSaveQuickBackup: () async {},
          onCheckUpdates: () async => (status: 'idle', info: null),
          onOpenLink: (_) {},
          onShowChangelog: (_) {},
          onReset: () async {},
          onFactoryReset: () async {},
          onResetSettings: () async {},
          onRestoreSettings: (_) async {},
          onFeedback: (_) {},
          trashEntriesNotifier: ValueNotifier<List<Moment>>([]),
          onRestoreTrashMoment: (_) async {},
          onRestoreAllTrash: () async {},
          onDeleteTrashPermanent: (_) async {},
          onClearTrash: () async {},
          currentLocale: 'en',
          onLocaleChanged: (_) {},
        ),
      ),
    );
  }

  group('Rm -rf Cache Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'UpdatesNoticesSettingsPage displays Rm -rf Cache row and toggles',
      (tester) async {
        bool value = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UpdatesNoticesSettingsPage(
                  p: p,
                  checkingUpdates: false,
                  updateInfo: null,
                  betaTrack: false,
                  remoteNotices: true,
                  onRemoteNoticesChanged: (_) {},
                  onOpenCategory: (_, {required parent}) {},
                  onLearnMoreBeta: () {},
                  autoDeleteUpdateCache: value,
                  onAutoDeleteUpdateCacheChanged: (val) => value = val,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Rm -rf Cache'), findsOneWidget);
        await tester.tap(find.text('Rm -rf Cache'));
        await tester.pumpAndSettle();
        expect(value, isTrue);
      },
    );

    testWidgets('SettingsDialog renders Rm -rf Cache in Guides', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSettingsDialog(initialCategory: 'Guides'));
      await tester.pumpAndSettle();

      // Verify Guide row exists
      expect(find.text('Rm -rf Cache (Update Clean)'), findsOneWidget);
    });

    testWidgets('SettingsDialog renders Rm -rf Cache in Help', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSettingsDialog(initialCategory: 'Help'));
      await tester.pumpAndSettle();

      // Verify Help question exists
      expect(
        find.text('What is "Rm -rf Cache" and how does it work?'),
        findsOneWidget,
      );
    });

    testWidgets(
      'SettingsDialog search finds Rm -rf Cache when searching rm or cache',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildSettingsDialog(initialCategory: 'Search'));
        await tester.pumpAndSettle();

        // Enter search text "rm -rf"
        await tester.enterText(find.byType(TextField), 'rm -rf');
        await tester.pumpAndSettle();

        expect(find.text('Rm -rf Cache'), findsOneWidget);

        // Enter search text "update cache"
        await tester.enterText(find.byType(TextField), 'update cache');
        await tester.pumpAndSettle();

        expect(find.text('Rm -rf Cache'), findsOneWidget);
      },
    );
  });
}
