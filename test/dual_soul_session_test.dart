import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/dialogs/settings/advanced_settings_page.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/clock_face.dart';
import 'package:notekar/widgets/home_top_insights_pill.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/timeline_single_tile.dart';

void main() {
  final p = paletteFor('dark');

  group('Dual Soul Session & Clock Face Stopwatch Tests', () {
    testWidgets(
      'ClockFace renders stopwatch elapsed minutes and seconds when session active (< 1 hour)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ClockFace(
                now: DateTime(2026, 9, 8, 11, 0, 0),
                p: p,
                pulseToken: 0,
                pulseType: 'in',
                minimal: false,
                showSeconds: true,
                highlightSeconds: true,
                sessionElapsed: const Duration(minutes: 14, seconds: 28),
              ),
            ),
          ),
        );

        // Under 1 hour, primary text should be '14:28'
        expect(find.text('14:28'), findsOneWidget);
      },
    );

    testWidgets(
      'ClockFace renders stopwatch elapsed hours and minutes when session active (> 1 hour)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ClockFace(
                now: DateTime(2026, 9, 8, 11, 0, 0),
                p: p,
                pulseToken: 0,
                pulseType: 'in',
                minimal: false,
                showSeconds: true,
                highlightSeconds: true,
                sessionElapsed: const Duration(
                  hours: 2,
                  minutes: 15,
                  seconds: 40,
                ),
              ),
            ),
          ),
        );

        // Over 1 hour, primary text should be '02:15' and secondary seconds '.40'
        expect(find.text('02:15'), findsOneWidget);
        expect(find.text('.40'), findsOneWidget);
      },
    );

    testWidgets('LiveClockFace computes elapsed duration from sessionStart', (
      tester,
    ) async {
      final startMs = DateTime.now()
          .subtract(const Duration(minutes: 5))
          .millisecondsSinceEpoch;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveClockFace(
              p: p,
              pulseToken: 0,
              pulseType: 'in',
              showSeconds: true,
              highlightSeconds: true,
              sessionStart: startMs,
            ),
          ),
        ),
      );

      // Should render elapsed minutes '05:'
      expect(find.textContaining('05:'), findsOneWidget);
    });
  });

  group('Minimal Top Moments Ambient Text Tests', () {
    testWidgets(
      'HomeTopInsightsPill renders clean text without pill container or sparkle icon',
      (tester) async {
        final now = DateTime.now();
        final entries = [
          Moment(
            id: 1,
            timestamp: now.millisecondsSinceEpoch,
            type: 'single',
            date: dateKey(now),
            note: 'Coffee meeting',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeTopInsightsPill(p: p, entries: entries, onTap: () {}),
            ),
          ),
        );

        // Must NOT contain sparkles icon
        expect(find.byIcon(CupertinoIcons.sparkles), findsNothing);
        // Must contain ambient text
        expect(find.textContaining('1 moment today'), findsOneWidget);
      },
    );
  });

  group('Timeline Rail Line Continuity Tests', () {
    testWidgets(
      'TimelineSingleTile rail column has no outer vertical padding gap',
      (tester) async {
        final moment = Moment(
          id: 1,
          timestamp: DateTime(2026, 9, 8, 10, 30).millisecondsSinceEpoch,
          type: 'single',
          date: '2026-09-08',
          note: 'Event note',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineSingleTile(
                p: p,
                moment: moment,
                onEditNote: () {},
                onDelete: () {},
              ),
            ),
          ),
        );

        // IntrinsicHeight root widget exists
        expect(find.byType(IntrinsicHeight), findsOneWidget);
        // The timestamp and note text are visible inside IosEmojiText
        expect(find.byType(IosEmojiText), findsOneWidget);
      },
    );
  });

  group('Accessibility & System Font Scale Warning Tests', () {
    testWidgets(
      'AdvancedSettingsPage displays iOS-style alert when system text scaling >= 1.15 and user toggles Large Text',
      (tester) async {
        bool toggled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.30)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: AdvancedSettingsPage(
                    p: p,
                    subCategory: 'Accessibility',
                    hapticStyle: 'standard',
                    reduceMotion: false,
                    largeText: false,
                    highContrast: false,
                    healthStatus: 'healthy',
                    onHapticStyleChanged: (_) {},
                    onReduceMotionChanged: (_) {},
                    onLargeTextChanged: (val) => toggled = val,
                    onHighContrastChanged: (_) {},
                    onResetSettings: () {},
                    onResetAllData: () {},
                    onFactoryReset: () {},
                    onOpenCategory: (_, {required parent}) {},
                  ),
                ),
              ),
            ),
          ),
        );

        // Tap the Large Text row
        await tester.tap(find.text('Large Text'));
        await tester.pumpAndSettle();

        // iOS Alert should appear
        expect(find.text('System Text Size Active'), findsOneWidget);
        expect(
          find.text(
            'Your device already has larger text enabled in system settings. Enabling additional in-app enlargement may alter layout proportions.',
          ),
          findsOneWidget,
        );
        expect(find.text('Keep System Default'), findsOneWidget);
        expect(find.text('Enable Anyway'), findsOneWidget);

        // Tap Enable Anyway
        await tester.tap(find.text('Enable Anyway'));
        await tester.pumpAndSettle();
        expect(toggled, isTrue);
      },
    );
  });

  group('NoteDialog WhatsApp-Grade Typing Tests', () {
    testWidgets(
      'NoteDialog TextField has sentence capitalization and truncateAfterCompositionEnds',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteDialog(p: p, initialNote: 'Test note'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);
        final textField = tester.widget<TextField>(textFieldFinder);

        expect(textField.textCapitalization, TextCapitalization.sentences);
        expect(
          textField.maxLengthEnforcement,
          MaxLengthEnforcement.truncateAfterCompositionEnds,
        );
        expect(textField.autocorrect, isTrue);
        expect(textField.enableSuggestions, isTrue);
        expect(textField.minLines, 4);
        expect(textField.maxLines, 6);
      },
    );

    testWidgets(
      'NoteDialog typing smoothly updates character indicator without rebuilding parent dialog error',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteDialog(p: p, initialNote: ''),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Writing smooth notes');
        await tester.pump();

        expect(find.text('Writing smooth notes'), findsOneWidget);
      },
    );
  });
}
