import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/big_note_dialog.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/markdown_text_editing_controller.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark');

  group('Custom Hashtags and Big Note Canvas Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'custom_note_tags': ['#focus', '#writing', '#journal'],
      });
      TagService.instance.resetForTesting();
    });

    testWidgets(
      'NoteDialog displays Note action button and renders quick note',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteDialog(p: p, initialNote: 'Short quick note'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Note'), findsOneWidget);
        expect(find.text('Short quick note'), findsOneWidget);
      },
    );

    testWidgets(
      'BigNoteDialog renders word/char counters and allows long content',
      (tester) async {
        final longNote =
            'This is an extensive journal reflection about my productivity and deep work sessions today.';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BigNoteDialog(p: p, initialNote: longNote),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Plus Note'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
        expect(find.text('14 words'), findsOneWidget);
        expect(find.text('${longNote.length} chars'), findsOneWidget);
        expect(find.text('#focus'), findsOneWidget);
        expect(find.text('Time'), findsOneWidget);
        expect(find.text('Bullet'), findsOneWidget);
        expect(find.text('Checklist'), findsOneWidget);
        expect(find.text('Clear'), findsOneWidget);
      },
    );

    testWidgets(
      'NoteDialog preserves long initial note without character lock',
      (tester) async {
        final longNote = 'A' * 600;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteDialog(p: p, initialNote: longNote),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Note'), findsOneWidget);
        expect(find.text(longNote), findsOneWidget);
      },
    );

    test(
      'Tag normalization and extractor accurately strip and parse hashtags',
      () {
        final tagService = TagService.instance;
        expect(tagService.normalize('#Walking'), '#walking');
        expect(tagService.normalize('  Gym  '), '#gym');
        expect(TagService.stripHash('#DeepWork'), 'DeepWork');

        final extracted = NoteTagExtractor.extractHashtags(
          'Completed session #gym with great energy #focus',
        );
        expect(extracted, contains('#gym'));
        expect(extracted, contains('#focus'));
        expect(
          NoteTagExtractor.cleanBodyText(
            'Completed session #gym with great energy #focus',
          ),
          'Completed session with great energy',
        );
      },
    );

    testWidgets('MarkdownTextEditingController formats live spans', (
      tester,
    ) async {
      late MarkdownTextEditingController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              controller = MarkdownTextEditingController(
                text: 'Hello **bold world** and *italic* with #gym goal',
                palette: p,
              );
              final span = controller.buildTextSpan(
                context: context,
                withComposing: false,
              );
              return Scaffold(body: RichText(text: span));
            },
          ),
        ),
      );

      // Verify rich text spans
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('bold world'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('#gym'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'IosEmojiText strips raw markdown tokens and renders preview formatting',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: IosEmojiText(
                'Completed **Gym Workout** with *John* and `squats`! ~~canceled~~',
                accentColor: Colors.blue,
              ),
            ),
          ),
        );

        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);
        final Text textWidget = tester.widget(textFinder);
        final plain = textWidget.textSpan!.toPlainText();

        expect(plain, contains('Gym Workout'));
        expect(plain.contains('**'), isFalse);
        expect(plain.contains('`'), isFalse);
        expect(plain.contains('~~'), isFalse);
        expect(plain, 'Completed Gym Workout with John and squats! canceled');
      },
    );
  });
}
