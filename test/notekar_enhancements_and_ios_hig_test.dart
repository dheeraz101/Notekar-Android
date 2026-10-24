import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/settings/life_audit_page.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/update_service.dart';
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

  group(
    'History Sheet Refinements (Filter Icon-Only & Title Tap-to-Scroll)',
    () {
      testWidgets(
        'HistoryDialog does NOT render keyboard_double_arrow_up_rounded button',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: HistoryDialog(
                  p: testPalette,
                  entries: const [],
                  compactRows: false,
                  largeText: false,
                  minimalMomentOptions: false,
                  confirmDelete: false,
                  onDelete: (_) async {},
                  onRestore: (_) async {},
                  onUpdateNote: (_, _) async {},
                  onDuration: (_, _) {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Move to top icon button has been removed
          expect(
            find.byIcon(Icons.keyboard_double_arrow_up_rounded),
            findsNothing,
          );
          expect(find.text('Scroll to top'), findsNothing);
        },
      );

      testWidgets(
        'HistoryDialog filter button is icon-only and contains tune/filter icon',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: HistoryDialog(
                  p: testPalette,
                  entries: const [],
                  compactRows: false,
                  largeText: false,
                  minimalMomentOptions: false,
                  confirmDelete: false,
                  onDelete: (_) async {},
                  onRestore: (_) async {},
                  onUpdateNote: (_, _) async {},
                  onDuration: (_, _) {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Tune or filter icon exists in the filter row
          final tuneIconFinder = find.byIcon(Icons.tune_rounded);
          expect(tuneIconFinder, findsOneWidget);

          // ChipButton wrapping tune icon does not render text
          final chipButtons = tester.widgetList<ChipButton>(
            find.byType(ChipButton),
          );
          final filterChip = chipButtons.firstWhere(
            (c) =>
                c.icon == Icons.tune_rounded ||
                c.icon == Icons.filter_alt_rounded,
          );
          expect(filterChip.label, isNull);
        },
      );

      testWidgets('AppSheetLargeTitle and AppSheet support onTap/onTitleTap', (
        tester,
      ) async {
        bool titleTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppSheetLargeTitle(
                p: testPalette,
                title: 'History',
                onTap: () => titleTapped = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('History'));
        await tester.pump();
        expect(titleTapped, isTrue);
      });
    },
  );

  group('Life Audit Single-Row Horizontal Scrollable Selector', () {
    testWidgets(
      'LifeAuditPage timeframe selector uses horizontal SingleChildScrollView',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LifeAuditPage(
                  p: testPalette,
                  entries: const [],
                  sleepHours: 8.0,
                  essentialsHours: 4.0,
                  onSleepHoursChanged: (_) {},
                  onEssentialsHoursChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Horizontal scrollable exists for timeframe filter pills
        final horizontalScrollFinder = find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        );
        expect(horizontalScrollFinder, findsOneWidget);

        // Timeframe pills are rendered inside
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Week'), findsOneWidget);
        expect(find.text('Month'), findsOneWidget);
      },
    );
  });

  group('Apple Software Update & Legal Notices', () {
    testWidgets(
      'UpdateCenterView renders Apple-style agreement in update card and allows cancelling update',
      (tester) async {
        String? openedLink;
        bool checkCalled = false;
        final updateInfo = AppUpdateInfo(
          version: '1.3.0',
          tagName: 'v1.3.0',
          body: 'Security improvements',
          isSecurity: true,
          isImportant: false,
          type: 'Security Update',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UpdateCenterView(
                  p: testPalette,
                  appVersion: '1.2.0',
                  enableTranslucency: true,
                  reduceMotion: false,
                  onOpenLink: (url) => openedLink = url,
                  onCheckUpdates: () => checkCalled = true,
                  updateInfo: updateInfo,
                  checkingUpdates: false,
                  updateStatus: 'idle',
                  currentBuildChannel: 'stable',
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Bottom duplicate agreement notice is removed
        expect(
          find.textContaining(
            'NoteKar keeps all records local on your device.',
          ),
          findsNothing,
        );

        // 2. Terms of service in the update card is present
        final termsLink = find.text('Terms of Service').first;
        await tester.scrollUntilVisible(
          termsLink,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(termsLink, findsOneWidget);
        await tester.tap(termsLink);
        await tester.pump();
        expect(openedLink, termsUrl);

        // 3. Cancel update button is present
        final cancelBtn = find.text('Cancel Update').first;
        expect(cancelBtn, findsOneWidget);
        await tester.tap(cancelBtn);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));

        // 4. Update card is now cancelled/postponed
        expect(find.text('Update postponed'), findsOneWidget);

        // 5. Explicitly tapping check for updates resets cancellation
        final checkBtn = find.text('Check for updates').first;
        await tester.tap(checkBtn);
        await tester.pumpAndSettle();
        expect(checkCalled, isTrue);
      },
    );
  });
}
