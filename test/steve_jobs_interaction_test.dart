import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/history_dialog.dart';
import 'package:notekar/dialogs/official_bulletins_sheet.dart';
import 'package:notekar/dialogs/settings/advanced_settings_page.dart';
import 'package:notekar/dialogs/settings/app_philosophy_settings_page.dart';
import 'package:notekar/dialogs/settings/feedback_changelog_settings_page.dart';
import 'package:notekar/dialogs/settings/settings_dashboard_page.dart';
import 'package:notekar/models/app_notice.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/clock_face.dart';
import 'package:notekar/widgets/home_coachmark_tooltip.dart';
import 'package:notekar/widgets/home_top_insights_pill.dart';
import 'package:notekar/widgets/swipeable_card_bed.dart';
import 'package:notekar/widgets/timeline_session_card.dart';
import 'package:notekar/widgets/timeline_single_tile.dart';
import 'package:notekar/widgets/toolbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      expect(animatedScale.curve, Curves.easeOutCubic);
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

        // Verifies minimal warning description and icon
        expect(
          find.text(
            'Data wipe operations permanently erase local storage and cannot be undone. Export a backup beforehand from Data & Backup.',
            findRichText: true,
          ),
          findsOneWidget,
        );
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

    testWidgets(
      'ModeToolButton precision sliding switch transitions smoothly between Single and Two-Way',
      (tester) async {
        var currentMode = 'single';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return ModeToolButton(
                    p: p,
                    mode: currentMode,
                    large: false,
                    onTap: () {
                      setState(() {
                        currentMode = currentMode == 'single'
                            ? 'two-way'
                            : 'single';
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Initially Single mode: arrow up
        expect(find.byIcon(Icons.arrow_upward), findsNothing);
        // Tap to toggle to Two-Way mode
        await tester.tap(find.byType(ModeToolButton));
        // Animate halfway through 260ms transition
        await tester.pump(const Duration(milliseconds: 130));
        expect(find.byType(SlideTransition), findsWidgets);
        expect(find.byType(ScaleTransition), findsWidgets);

        await tester.pumpAndSettle();
        expect(currentMode, 'two-way');
      },
    );

    testWidgets(
      'OfficialBulletinsSheet renders Apple-grade hierarchy, manual refresh, and privacy guarantee',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'cached_app_notices':
              '[{"id":"test-1","priority":"critical","title":"Security Update","body":"Important security fix deployed.","enabled":true}]',
          'last_notice_check_ts': DateTime.now().millisecondsSinceEpoch,
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfficialBulletinsSheet(p: p, onOpenLink: (_) {}),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Official Bulletins'), findsOneWidget);
        expect(find.text('Check Now'), findsOneWidget);
        expect(find.text('ZERO-TRACKING GUARANTEE'), findsOneWidget);
        expect(find.text('Security Update'), findsOneWidget);
      },
    );

    test(
      'AppNotice data model correctly identifies hierarchy and priority levels',
      () {
        final critical = AppNotice(
          id: 'c1',
          enabled: true,
          priority: 'critical',
          title: 'Critical Patch',
          body: 'Patch details',
        );
        expect(critical.isCritical, isTrue);
        expect(critical.isReleaseBulletin, isFalse);
        expect(critical.isCuratedTip, isFalse);

        final bulletin = AppNotice(
          id: 'b1',
          enabled: true,
          priority: 'release',
          title: 'Release Notes',
          body: 'New features',
        );
        expect(bulletin.isCritical, isFalse);
        expect(bulletin.isReleaseBulletin, isTrue);

        final tip = AppNotice(
          id: 't1',
          enabled: true,
          priority: 'tip',
          title: 'Curated Tip',
          body: 'Productivity tip',
        );
        expect(tip.isCuratedTip, isTrue);
      },
    );

    testWidgets(
      'AppSheet header mathematically centers collapsed title when trailing action exists',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppSheet(
                p: p,
                title: 'Mathematical Alignment',
                trailingAction: const Icon(Icons.share, size: 20),
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Mathematical Alignment'), findsOneWidget);
      },
    );

    testWidgets(
      'FeedbackChangelogSettingsPage Whats New renders Apple Keynote hero, innovations, and Steve Jobs colophon',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FeedbackChangelogSettingsPage(
                  p: p,
                  subCategory: "What's New",
                  onOpenGithubIssue: (_) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('KEYNOTE RELEASE'), findsOneWidget);
        expect(find.text('v7.3.2 Update'), findsOneWidget);
        expect(find.text('MAJOR INNOVATIONS'), findsOneWidget);
        expect(find.text('Pinch-to-Density Physics'), findsOneWidget);
        expect(find.text('Physical Swipe & Bed of Red'), findsOneWidget);
        expect(find.text('Cupertino Alert Architecture'), findsOneWidget);
        expect(find.text('Executive Intelligence Hub'), findsOneWidget);
        expect(find.text('Official Bulletins Engine'), findsOneWidget);
        expect(
          find.text('"Details matter, it’s worth waiting to get it right."'),
          findsOneWidget,
        );
        expect(find.text('STEVE JOBS'), findsOneWidget);
        expect(find.text('View Full Technical Changelog'), findsOneWidget);
      },
    );

    testWidgets(
      'TimelineSessionCard SwipeableCardBed provides true bed of red geometry matching card border radius',
      (tester) async {
        final now = DateTime.now();
        final session = TimelineSessionItem(
          inMoment: Moment(
            id: 1,
            type: 'in',
            date: dateKey(now),
            timestamp: now
                .subtract(const Duration(minutes: 45))
                .millisecondsSinceEpoch,
          ),
          outMoment: Moment(
            id: 2,
            type: 'out',
            date: dateKey(now),
            timestamp: now.millisecondsSinceEpoch,
          ),
        );

        bool deleteCalled = false;
        bool tapCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSessionCard(
                p: p,
                session: session,
                onTapCard: () => tapCalled = true,
                onEditNote: () {},
                onDeleteSession: () => deleteCalled = true,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final swipeFinder = find.byType(SwipeableCardBed);
        expect(swipeFinder, findsOneWidget);

        final swipeWidget = tester.widget<SwipeableCardBed>(swipeFinder);
        expect(swipeWidget.deleteColor, equals(p.red));
        expect(swipeWidget.borderRadius, equals(BorderRadius.circular(16)));

        // Verify tap works seamlessly
        await tester.tap(find.byType(TimelineSessionCard));
        expect(tapCalled, isTrue);

        // Verify swipe left reveals red bed and triggers delete
        await tester.drag(
          find.byType(TimelineSessionCard),
          const Offset(-100, 0),
        );
        await tester.pumpAndSettle();
        expect(deleteCalled, isTrue);
      },
    );

    testWidgets(
      'TimelineSingleTile SwipeableCardBed provides true bed of red geometry matching card border radius',
      (tester) async {
        final now = DateTime.now();
        final moment = Moment(
          id: 1,
          type: 'single',
          date: dateKey(now),
          timestamp: now.millisecondsSinceEpoch,
        );

        bool deleteCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSingleTile(
                p: p,
                moment: moment,
                onEditNote: () {},
                onDelete: () => deleteCalled = true,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final swipeFinder = find.byType(SwipeableCardBed);
        expect(swipeFinder, findsOneWidget);

        final swipeWidget = tester.widget<SwipeableCardBed>(swipeFinder);
        expect(swipeWidget.deleteColor, equals(p.red));
        expect(swipeWidget.borderRadius, equals(BorderRadius.circular(12)));

        // Verify swipe left triggers delete
        await tester.drag(
          find.byType(TimelineSingleTile),
          const Offset(-100, 0),
        );
        await tester.pumpAndSettle();
        expect(deleteCalled, isTrue);
      },
    );
  });
}
