import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/expandable_timeline_note.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/timeline_single_tile.dart';
import 'package:notekar/widgets/timeline_voice_player_pill.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Phase 2: Markdown & Timeline Note Tests', () {
    testWidgets('IosEmojiText parses bold, italic, and code correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IosEmojiText(
              'Here is **bold** and *italic* and `code` and ~~strike~~ with __alt_bold__ and _alt_italic_',
              accentColor: p.accent,
            ),
          ),
        ),
      );

      final parsedSpan = IosEmojiText.parseMarkdown(
        'Here is **bold** and *italic* and `code` and ~~strike~~ with __alt_bold__ and _alt_italic_',
        const TextStyle(),
        p.accent,
      );

      final spans = parsedSpan.children ?? [];
      expect(spans, isNotEmpty);

      // Check for bold span
      final boldSpan =
          spans.firstWhere((s) => s is TextSpan && s.text == 'bold')
              as TextSpan;
      expect(boldSpan.style?.fontWeight, FontWeight.w700);

      // Check for alt bold span
      final altBoldSpan =
          spans.firstWhere((s) => s is TextSpan && s.text == 'alt_bold')
              as TextSpan;
      expect(altBoldSpan.style?.fontWeight, FontWeight.w700);

      // Check for italic span
      final italicSpan =
          spans.firstWhere((s) => s is TextSpan && s.text == 'italic')
              as TextSpan;
      expect(italicSpan.style?.fontStyle, FontStyle.italic);

      // Check for alt italic span
      final altItalicSpan =
          spans.firstWhere((s) => s is TextSpan && s.text == 'alt_italic')
              as TextSpan;
      expect(altItalicSpan.style?.fontStyle, FontStyle.italic);

      // Check for code span
      final codeSpan =
          spans.firstWhere((s) => s is TextSpan && s.text == 'code')
              as TextSpan;
      expect(codeSpan.style?.fontFamily, 'monospace');

      // Check for strike span
      final strikeSpan =
          spans.firstWhere((s) => s is TextSpan && s.text == 'strike')
              as TextSpan;
      expect(strikeSpan.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets(
      'ExpandableTimelineNote toggles show more and show less for long notes',
      (tester) async {
        final longNote =
            'This is line 1 of a very long note.\n'
            'This is line 2 containing important details.\n'
            'This is line 3 with **bold** updates.\n'
            'This is line 4 with `code` references.\n'
            'This is line 5 which should push it beyond collapsedMaxLines.';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: ExpandableTimelineNote(
                  text: longNote,
                  p: p,
                  collapsedMaxLines: 2,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should find "show more" toggle
        expect(find.text('show more'), findsOneWidget);
        expect(find.text('show less'), findsNothing);

        // Tap "show more"
        await tester.tap(find.text('show more'));
        await tester.pumpAndSettle();

        // Should now find "show less" toggle
        expect(find.text('show less'), findsOneWidget);
        expect(find.text('show more'), findsNothing);

        // Tap "show less"
        await tester.tap(find.text('show less'));
        await tester.pumpAndSettle();

        expect(find.text('show more'), findsOneWidget);
        expect(find.text('show less'), findsNothing);
      },
    );

    testWidgets('TimelineSingleTile integrates ExpandableTimelineNote', (
      tester,
    ) async {
      final moment = Moment(
        id: 1,
        type: 'single',
        date: '2026-11-06',
        timestamp: DateTime(2026, 11, 6, 12, 0).millisecondsSinceEpoch,
        note: 'Sprint retrospective **success** #retro',
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
      await tester.pumpAndSettle();

      expect(find.byType(ExpandableTimelineNote), findsOneWidget);
    });

    testWidgets(
      'TimelineVoicePlayerPill renders smoothly with debounced waveform scrubber',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineVoicePlayerPill(
                p: p,
                voicePath: 'test_voice.m4a',
                durationMs: 42000,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TimelineVoicePlayerPill), findsOneWidget);
        expect(find.text('0:00 / 0:42'), findsOneWidget);

        // Perform drag gesture on the scrubber
        final scrubber = find.byType(GestureDetector).last;
        await tester.drag(scrubber, const Offset(50, 0));
        await tester.pump(const Duration(milliseconds: 20));

        // Let debounce timer settle
        await tester.pumpAndSettle();
      },
    );
  });
}
