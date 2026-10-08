import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/pioneer_badge_dialog.dart';
import 'package:notekar/dialogs/settings/advanced_settings_page.dart';
import 'package:notekar/dialogs/settings/app_icons_settings_page.dart';
import 'package:notekar/dialogs/settings/god_mode_settings_page.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/moment_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('God Mode & Sovereign Easter Egg Tests', () {
    test('Matrix and E-Ink themes generate correct colors', () {
      final matrix = paletteFor('matrix');
      expect(matrix.name, 'matrix');
      expect(matrix.bg, const Color(0xFF000000));
      expect(matrix.text, const Color(0xFF00FF41));

      final eink = paletteFor('eink');
      expect(eink.name, 'eink');
      expect(eink.bg, const Color(0xFFFFFFFF));
      expect(eink.text, const Color(0xFF000000));
      expect(eink.border, const Color(0xFF000000));
    });

    test('Search notes page isolates and excludes God Mode moments', () {
      final entries = [
        Moment(
          id: 1,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          type: 'single',
          date: '2026-08-30',
          note: '⚡ Reward Unlocked: #godmode • Sovereign Access Granted',
        ),
        Moment(
          id: 2,
          timestamp: DateTime.now().millisecondsSinceEpoch - 1000,
          type: 'single',
          date: '2026-08-30',
          note: 'Routine coffee log',
        ),
      ];

      final filteredNotes = entries
          .where(
            (e) =>
                e.note.trim().isNotEmpty &&
                !e.note.contains('God Mode Unlocked') &&
                !e.note.contains('#godmode'),
          )
          .toList();

      expect(filteredNotes.length, 1);
      expect(filteredNotes.first.note, 'Routine coffee log');
    });

    testWidgets(
      'MomentTile renders rainbow card with @ icon, God Mode title, and Unlocked subtitle without timestamp',
      (tester) async {
        final p = paletteFor('dark');
        final godMoment = Moment(
          id: 99,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          type: 'single',
          date: '2026-08-30',
          note: '⚡ Reward Unlocked: #godmode • Sovereign Access Granted',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MomentTile(
                p: p,
                entry: godMoment,
                selected: false,
                compact: false,
                onTap: () {},
                onLongPress: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        expect(find.text('God Mode'), findsOneWidget);
        expect(find.text('Unlocked'), findsOneWidget);
        expect(find.byIcon(Icons.alternate_email_rounded), findsOneWidget);
        expect(find.byIcon(Icons.close_rounded), findsNothing);
        expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'AppIconsSettingsPage shows VIP Sovereign badge when unlocked',
      (tester) async {
        final p = paletteFor('dark');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppIconsSettingsPage(
                  p: p,
                  appIconStyle: 'gold',
                  godModeUnlocked: true,
                  onAppIconStyleChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('⚡ VIP Sovereign Icon'), findsOneWidget);
        expect(find.text('Sovereign • Champagne VIP'), findsOneWidget);
      },
    );

    testWidgets('VIP Pioneer Badge renders and verifies signature', (
      tester,
    ) async {
      final p = paletteFor('dark');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PioneerBadgeDialog(p: p, totalMoments: 42, streakDays: 14),
          ),
        ),
      );

      expect(find.text('VIP Pioneer Badge'), findsOneWidget);
      expect(find.text('NOTEKAR SOVEREIGN'), findsOneWidget);
      expect(find.text('Verify Database Signature'), findsOneWidget);

      await tester.tap(find.text('Verify Database Signature'));
      await tester.pump();

      expect(find.text('Signature Verified'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'GodModeSettingsPage renders secret developer themes, VIP badge, and revocation action',
      (tester) async {
        final p = paletteFor('dark');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: GodModeSettingsPage(
                  p: p,
                  currentTheme: 'dark',
                  onThemeChanged: (_) {},
                  totalMoments: 50,
                  streakDays: 10,
                  onRelockGodMode: () {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Matrix Phosphor Terminal'), findsOneWidget);
        expect(find.text('Kindle E-Ink Paperwhite'), findsOneWidget);
        expect(find.text('VIP Pioneer Badge'), findsOneWidget);
        expect(find.text('Revoke God Mode'), findsOneWidget);
      },
    );

    testWidgets(
      'AdvancedSettingsPage keeps God Mode secret and completely hidden when locked',
      (tester) async {
        final p = paletteFor('dark');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AdvancedSettingsPage(
                  p: p,
                  subCategory: 'Advanced',
                  currentLocale: 'en',
                  hapticStyle: 'medium',
                  reduceMotion: false,
                  largeText: false,
                  highContrast: false,
                  healthStatus: 'Good',
                  soundEffects: false,
                  isGodModeUnlocked: false,
                  onHapticStyleChanged: (_) {},
                  onSoundEffectsChanged: (_) {},
                  onReduceMotionChanged: (_) {},
                  onLargeTextChanged: (_) {},
                  onHighContrastChanged: (_) {},
                  onLocaleChanged: (_) {},
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

        // Section title must be 'ADVANCED SYSTEMS', NOT 'GOD MODE / ADVANCED SYSTEMS'
        expect(find.text('ADVANCED SYSTEMS'), findsOneWidget);
        expect(find.text('GOD MODE / ADVANCED SYSTEMS'), findsNothing);

        // God Mode row must NOT be visible at all
        expect(find.text('God Mode'), findsNothing);
      },
    );

    testWidgets(
      'AdvancedSettingsPage reveals God Mode row only when unlocked',
      (tester) async {
        final p = paletteFor('dark');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AdvancedSettingsPage(
                  p: p,
                  subCategory: 'Advanced',
                  currentLocale: 'en',
                  hapticStyle: 'medium',
                  reduceMotion: false,
                  largeText: false,
                  highContrast: false,
                  healthStatus: 'Good',
                  soundEffects: false,
                  isGodModeUnlocked: true,
                  onHapticStyleChanged: (_) {},
                  onSoundEffectsChanged: (_) {},
                  onReduceMotionChanged: (_) {},
                  onLargeTextChanged: (_) {},
                  onHighContrastChanged: (_) {},
                  onLocaleChanged: (_) {},
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

        expect(find.text('ADVANCED SYSTEMS'), findsOneWidget);
        expect(find.text('God Mode'), findsOneWidget);
        expect(find.text('Unlocked'), findsOneWidget);
      },
    );
  });
}
