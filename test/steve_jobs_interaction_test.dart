import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/settings/advanced_settings_page.dart';
import 'package:notekar/dialogs/settings/app_philosophy_settings_page.dart';
import 'package:notekar/dialogs/settings/settings_dashboard_page.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/clock_face.dart';
import 'package:notekar/widgets/home_coachmark_tooltip.dart';
import 'package:notekar/widgets/home_top_insights_pill.dart';
import 'package:notekar/widgets/timeline_session_card.dart';
import 'package:notekar/widgets/timeline_single_tile.dart';

void main() {
  final p = paletteFor('dark');

  group('Steve Jobs Interaction & Sensory Tests', () {
    testWidgets(
      'HomeTopInsightsPill generates natural-language narrative for active session',
      (tester) async {
        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: now.millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(now),
            note: 'Focus block',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeTopInsightsPill(p: p, entries: entries, onTap: () {}),
            ),
          ),
        );

        expect(
          find.text('Active session in flow • Tap to inspect'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'SettingsDashboardPage displays "THE STORY OF YOUR TIME" editorial synthesis card',
      (tester) async {
        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: now
                .subtract(const Duration(hours: 2))
                .millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(now),
            note: '#code Deep architecture session',
          ),
          Moment(
            id: 2,
            timestamp: now
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch,
            type: 'out',
            date: dateKey(now),
            note: '',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SettingsDashboardPage(
                  p: p,
                  entries: entries,
                  enableSobrietyMode: false,
                  onLogNow: () {},
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check for "THE STORY OF YOUR TIME" editorial headline
        expect(find.text('THE STORY OF YOUR TIME'), findsOneWidget);
        // Narrative should mention 1h of focused attention and entries
        expect(
          find.textContaining('dedicated 1h of focused attention'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'HistoryDialog supports inline lens density toggle button in sticky header',
      (tester) async {
        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: now.millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(now),
            note: 'First moment',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HistoryDialog(
                p: p,
                entries: entries,
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

        // Density toggle button with tooltip 'Compact view'
        final toggleFinder = find.byTooltip('Compact view');
        expect(toggleFinder, findsOneWidget);

        // Tap inline density toggle to switch to compact
        await tester.tap(toggleFinder);
        await tester.pumpAndSettle();

        // Now tooltip should update to 'Comfortable view'
        expect(find.byTooltip('Comfortable view'), findsOneWidget);
      },
    );

    testWidgets(
      'TimelineSingleTile triggers swipe-to-delete with tactile feedback',
      (tester) async {
        final now = DateTime.now();
        final moment = Moment(
          id: 42,
          timestamp: now.millisecondsSinceEpoch,
          type: 'single',
          date: dateKey(now),
          note: 'Moment to dismiss',
        );

        bool deleteCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSingleTile(
                p: p,
                moment: moment,
                onEditNote: () {},
                onDelete: () {
                  deleteCalled = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Delete'), findsNothing);

        // Drag left to reveal secondary delete background and trigger callback
        await tester.drag(
          find.byType(TimelineSingleTile),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(deleteCalled, isTrue);
      },
    );

    testWidgets(
      'TimelineSessionCard triggers swipe-to-delete for connected sessions',
      (tester) async {
        final now = DateTime.now();
        final session = TimelineSessionItem(
          inMoment: Moment(
            id: 1,
            timestamp: now
                .subtract(const Duration(minutes: 45))
                .millisecondsSinceEpoch,
            type: 'in',
            date: dateKey(now),
            note: 'Design review',
          ),
          outMoment: Moment(
            id: 2,
            timestamp: now.millisecondsSinceEpoch,
            type: 'out',
            date: dateKey(now),
            note: '',
          ),
        );

        bool deleteSessionCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSessionCard(
                p: p,
                session: session,
                onEditNote: () {},
                onDeleteSession: () {
                  deleteSessionCalled = true;
                },
              ),
            ),
          ),
        );

        // Drag left to trigger onDeleteSession
        await tester.drag(
          find.byType(TimelineSessionCard),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(deleteSessionCalled, isTrue);
      },
    );

    testWidgets('ClockFace renders with spring bounce scale elasticity', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClockFace(
              now: DateTime.now(),
              p: p,
              pulseToken: 0,
              pulseType: 'save',
              minimal: false,
              showSeconds: true,
              highlightSeconds: true,
            ),
          ),
        ),
      );

      // Finds AnimatedScale with spring physics
      expect(find.byType(AnimatedScale), findsOneWidget);
      final animatedScale = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );
      expect(animatedScale.curve, Curves.easeOutBack);
      expect(animatedScale.scale, 1.0);
    });

    testWidgets(
      'HomeCoachmarkTooltip renders serene epiphany prompt on first install',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CoachmarkTooltip(p: p)),
          ),
        );

        expect(
          find.text('Tap anywhere to begin. Hold to add a note.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AdvancedSettingsPage Language view renders localized greetings without flags',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AdvancedSettingsPage(
                  p: p,
                  subCategory: 'Language',
                  hapticStyle: 'standard',
                  reduceMotion: false,
                  largeText: false,
                  highContrast: false,
                  healthStatus: 'Healthy',
                  onHapticStyleChanged: (_) {},
                  onReduceMotionChanged: (_) {},
                  onLargeTextChanged: (_) {},
                  onHighContrastChanged: (_) {},
                  onResetSettings: () {},
                  onResetAllData: () {},
                  onFactoryReset: () {},
                  onOpenCategory: (_, {required String parent}) {},
                ),
              ),
            ),
          ),
        );

        // Verifies clean native names without flag emojis
        expect(find.text('Français'), findsOneWidget);
        expect(find.text('हिन्दी'), findsOneWidget);
        expect(find.text('Español'), findsOneWidget);
        expect(find.text('Deutsch'), findsOneWidget);
        expect(find.text('日本語'), findsOneWidget);
        expect(find.text('Русский'), findsOneWidget);

        // Verifies native greeting subtitles
        expect(
          find.text('Comment allez-vous ?', findRichText: true),
          findsOneWidget,
        );
        expect(find.text('आप कैसे हैं?', findRichText: true), findsOneWidget);
        expect(find.text('¿Cómo estás?', findRichText: true), findsOneWidget);
        expect(
          find.text('Wie geht es dir?', findRichText: true),
          findsOneWidget,
        );
        expect(find.text('お元気ですか？', findRichText: true), findsOneWidget);
        expect(find.text('Как ваши дела?', findRichText: true), findsOneWidget);
      },
    );

    testWidgets(
      'AdvancedSettingsPage Reset view renders concise subtitles and bottom warning card',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AdvancedSettingsPage(
                  p: p,
                  subCategory: 'Reset',
                  hapticStyle: 'standard',
                  reduceMotion: false,
                  largeText: false,
                  highContrast: false,
                  healthStatus: 'Healthy',
                  onHapticStyleChanged: (_) {},
                  onReduceMotionChanged: (_) {},
                  onLargeTextChanged: (_) {},
                  onHighContrastChanged: (_) {},
                  onResetSettings: () {},
                  onResetAllData: () {},
                  onFactoryReset: () {},
                  onOpenCategory: (_, {required String parent}) {},
                ),
              ),
            ),
          ),
        );

        // Verifies concise Apple-style subtitles
        expect(
          find.text(
            'Restore default preferences and layout',
            findRichText: true,
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'Delete all recorded moments and sessions',
            findRichText: true,
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'Erase all data and restore factory settings',
            findRichText: true,
          ),
          findsOneWidget,
        );

        // Verifies prominent warning box and icon
        expect(find.text('Irreversible Actions'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'AppPhilosophySettingsPage renders Apple-style manifesto, Steve Jobs conviction quote, 5 pillars, and spec sheet',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppPhilosophySettingsPage(p: p, appVersion: '2.4.0'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Hero Header
        expect(find.text('THE NOTEKAR MANIFESTO'), findsOneWidget);
        expect(
          find.text('Simplicity is the Ultimate Sophistication'),
          findsOneWidget,
        );

        // 2. Steve Jobs Conviction Callout
        expect(find.text('THE COURAGE TO SAY NO'), findsOneWidget);
        expect(find.text('— Steve Jobs'), findsOneWidget);

        // 3. Five Core Pillars
        expect(find.text('FIVE PILLARS OF CRAFT'), findsOneWidget);
        expect(find.text('Simplicity is Sacred'), findsOneWidget);
        expect(find.text('Sanctuary of Radical Privacy'), findsOneWidget);
        expect(find.text('Reverence for Human Attention'), findsOneWidget);
        expect(find.text('The Back of the Mahogany Cabinet'), findsOneWidget);
        expect(find.text('Built Like an Heirloom'), findsOneWidget);

        // 4. Architectural Spec Grid
        expect(find.text('THE ARCHITECTURAL CODE'), findsOneWidget);
        expect(find.text('100% Offline Core'), findsOneWidget);
        expect(find.text('Zero Analytics or Trackers'), findsOneWidget);
        expect(find.text('Local Hive Engine'), findsOneWidget);
        expect(find.text('Tactile Mechanical Haptics'), findsOneWidget);
        expect(find.text('Open Source Transparency'), findsOneWidget);
        expect(find.text('Zero Subscriptions or Ads'), findsOneWidget);

        // 5. Colophon
        expect(
          find.text('Version v2.4.0 • Designed with Conviction'),
          findsOneWidget,
        );
      },
    );
  });
}
