import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/dialogs/goals_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/theme/app_tokens.dart';
import 'package:notekar/widgets/activity_heatmap_widget.dart';
import 'package:notekar/widgets/design_system/nk_empty_state.dart';
import 'package:notekar/widgets/photo_lightbox_dialog.dart';
import 'package:notekar/widgets/timeline_media_attachment_card.dart';
import 'package:notekar/widgets/zen_day_gauge.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NoteKar 112 Micro-Improvements Targeted Verification', () {
    testWidgets(
      'ActivityHeatmapWidget renders with CustomPainter inside RepaintBoundary',
      (tester) async {
        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: now.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-09-21',
            note: 'Deep work',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ActivityHeatmapWidget(p: p, entries: entries),
            ),
          ),
        );

        // Verify RepaintBoundary and CustomPaint exist
        expect(find.byType(ActivityHeatmapWidget), findsOneWidget);
        expect(find.byType(RepaintBoundary), findsWidgets);
        expect(find.byType(CustomPaint), findsWidgets);
        expect(find.text('16-Week Habit Activity Grid'), findsOneWidget);
      },
    );

    testWidgets(
      'AppSheet header buttons differentiate Back vs Close semantics',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppSheet(
                p: p,
                title: 'Test Sheet',
                onBack: () {},
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        );

        // Expect Back button tooltip and semantics
        expect(find.byTooltip('Back'), findsOneWidget);
        expect(find.byTooltip('Close'), findsOneWidget);

        final backSemantics = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Back',
        );
        expect(backSemantics, findsOneWidget);

        final closeSemantics = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Close sheet',
        );
        expect(closeSemantics, findsOneWidget);
      },
    );

    testWidgets(
      'ZenDayRing wraps CustomPaint in TweenAnimationBuilder for smooth sweep',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(child: ZenDayRing(p: p, progress: 0.75, size: 24)),
            ),
          ),
        );

        final tweenBuilderFinder = find.descendant(
          of: find.byType(ZenDayRing),
          matching: find.byType(TweenAnimationBuilder<double>),
        );
        expect(tweenBuilderFinder, findsOneWidget);
      },
    );

    testWidgets(
      'GoalsContentView renders NkEmptyState when goals list is empty',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GoalsContentView(
                p: p,
                moments: const [],
                activeCategory: 'All',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NkEmptyState), findsOneWidget);
        expect(find.text('No Targets Defined'), findsOneWidget);
        expect(find.text('Create First Goal'), findsOneWidget);
      },
    );

    test(
      'ContinuousSquircleBorder satisfies continuous geometry and RoundedRectangleBorder',
      () {
        const border = ContinuousSquircleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
        );
        expect(border, isA<ContinuousRectangleBorder>());
        expect(border, isA<RoundedRectangleBorder>());
        expect(border.borderRadius, BorderRadius.circular(24.0));
      },
    );

    testWidgets(
      'TimelineMediaAttachmentCard renders safely without sync existsSync',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineMediaAttachmentCard(
                p: p,
                imagePath: 'test_photo.jpg',
                isCollapsed: false,
                momentId: 42,
              ),
            ),
          ),
        );

        expect(find.byType(TimelineMediaAttachmentCard), findsOneWidget);
      },
    );

    testWidgets(
      'PhotoLightboxDialog responds to double tap and handles InteractiveViewer',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhotoLightboxDialog(p: p, assetPath: 'test.png'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PhotoLightboxDialog), findsOneWidget);
        expect(find.byType(InteractiveViewer), findsOneWidget);
        expect(find.byType(GestureDetector), findsWidgets);
      },
    );
  });
}
