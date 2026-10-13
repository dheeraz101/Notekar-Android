import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/big_note_dialog.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/markdown_text_editing_controller.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/ios_emoji_text.dart';
import 'package:notekar/widgets/timeline_single_tile.dart';
import 'package:notekar/widgets/timeline_voice_player_pill.dart';
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

    testWidgets('NoteDialog displays action buttons and renders quick note', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteDialog(p: p, initialNote: 'Short quick note'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Short quick note'), findsOneWidget);
    });

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

        expect(find.text('Camera'), findsOneWidget);
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

    test(
      'Moment and NoteResult support up to 5 multi-image paths seamlessly',
      () {
        final images = [
          'images/img_1.jpg',
          'images/img_2.jpg',
          'images/img_3.jpg',
        ];
        final pipe = images.join('|');

        final moment = Moment(
          id: 1,
          type: 'note',
          date: '2026-10-13',
          timestamp: 1776000000000,
          note: 'Multi photo moment test #memories',
          imagePath: pipe,
        );

        expect(moment.imagePaths.isNotEmpty, isTrue);
        expect(moment.imagePaths.length, 3);
        expect(moment.imagePaths, equals(images));

        final noteResult = NoteResult(
          'Testing result with 3 photos',
          ['#memories'],
          imagePath: pipe,
          imagePaths: images,
        );

        expect(noteResult.imagePath, isNotNull);
        expect(noteResult.effectiveImagePaths, equals(images));
        expect(noteResult.imagePath, equals(pipe));
      },
    );

    testWidgets(
      'BigNoteDialog mounts with multi-image previews and reflects photo counter',
      (tester) async {
        final multiImages = 'images/1.jpg|images/2.jpg|images/3.jpg';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BigNoteDialog(
                p: p,
                initialNote: 'Note with multiple images',
                initialImagePath: multiImages,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Photo (3)'), findsOneWidget);
      },
    );

    testWidgets(
      'NoteSearchContent collapses voice memos and photos by default',
      (tester) async {
        final sampleMoments = [
          Moment(
            id: 101,
            type: 'single',
            date: '2026-10-13',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            note: 'Search test moment with media',
            imagePath: 'img_test.jpg',
            voicePath: 'voice_1.m4a|voice_2.m4a',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteSearchContent(
                p: p,
                entries: sampleMoments,
                compactRows: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Expect collapsed voice memo pill
        expect(find.text('2 Voice Memos'), findsOneWidget);
        // Expect search note text
        expect(find.text('Search test moment with media'), findsOneWidget);
      },
    );

    testWidgets(
      'TimelineSingleTile supports bi-directional individual voice memo collapse',
      (tester) async {
        final momentWithVoice = Moment(
          id: 501,
          type: 'single',
          date: '2026-10-13',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          note: 'Moment with voice memo',
          voicePath: 'test_voice.m4a',
          voiceDurationMs: 12000,
        );

        bool isCollapsed = false;
        int toggleCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return TimelineSingleTile(
                    p: p,
                    moment: momentWithVoice,
                    onEditNote: () {},
                    onDelete: () {},
                    isVoiceCollapsed: isCollapsed,
                    onToggleVoiceCollapse: () {
                      setState(() {
                        isCollapsed = !isCollapsed;
                        toggleCount++;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // When expanded, the voice player pill and the collapse button (chevron_up) are visible
        expect(find.byType(TimelineVoicePlayerPill), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.chevron_up), findsWidgets);

        // Tap the collapse chevron header chip
        await tester.tap(find.byIcon(CupertinoIcons.chevron_up).first);
        await tester.pumpAndSettle();

        expect(toggleCount, equals(1));
        expect(isCollapsed, isTrue);

        // Now collapsed: voice player pill is hidden, and collapsed chip with chevron_down is visible
        expect(find.byType(TimelineVoicePlayerPill), findsNothing);
        expect(find.text('1 Voice Memo'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.chevron_down), findsOneWidget);

        // Tap the collapsed chip to expand again
        await tester.tap(find.text('1 Voice Memo'));
        await tester.pumpAndSettle();

        expect(toggleCount, equals(2));
        expect(isCollapsed, isFalse);
        expect(find.byType(TimelineVoicePlayerPill), findsOneWidget);
      },
    );

    testWidgets(
      'TimelineVoicePlayerPill trailing collapse chevron triggers onToggleCollapse',
      (tester) async {
        bool collapsedToggled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineVoicePlayerPill(
                p: p,
                voicePath: 'test_memo.m4a',
                durationMs: 8000,
                onToggleCollapse: () {
                  collapsedToggled = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(CupertinoIcons.chevron_up), findsOneWidget);
        await tester.tap(find.byIcon(CupertinoIcons.chevron_up));
        await tester.pumpAndSettle();

        expect(collapsedToggled, isTrue);
      },
    );

    testWidgets('Individual voice memo collapse toggles only target moment', (
      tester,
    ) async {
      final momentA = Moment(
        id: 601,
        type: 'single',
        date: '2026-10-13',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        note: 'Moment A with voice',
        voicePath: 'voice_a.m4a',
      );
      final momentB = Moment(
        id: 602,
        type: 'single',
        date: '2026-10-13',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        note: 'Moment B with voice',
        voicePath: 'voice_b.m4a',
      );

      final collapsedSet = <int>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TimelineSingleTile(
                      p: p,
                      moment: momentA,
                      onEditNote: () {},
                      onDelete: () {},
                      isVoiceCollapsed: collapsedSet.contains(momentA.id),
                      onToggleVoiceCollapse: () {
                        setState(() {
                          if (collapsedSet.contains(momentA.id)) {
                            collapsedSet.remove(momentA.id);
                          } else {
                            collapsedSet.add(momentA.id);
                          }
                        });
                      },
                    ),
                    TimelineSingleTile(
                      p: p,
                      moment: momentB,
                      onEditNote: () {},
                      onDelete: () {},
                      isVoiceCollapsed: collapsedSet.contains(momentB.id),
                      onToggleVoiceCollapse: () {
                        setState(() {
                          if (collapsedSet.contains(momentB.id)) {
                            collapsedSet.remove(momentB.id);
                          } else {
                            collapsedSet.add(momentB.id);
                          }
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both start expanded
      expect(find.byType(TimelineVoicePlayerPill), findsNWidgets(2));

      // Collapse only Moment A via its chevron_up
      await tester.tap(find.byIcon(CupertinoIcons.chevron_up).first);
      await tester.pumpAndSettle();

      // Moment A is collapsed, Moment B remains expanded
      expect(collapsedSet.contains(momentA.id), isTrue);
      expect(collapsedSet.contains(momentB.id), isFalse);
      expect(find.byType(TimelineVoicePlayerPill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chevron_down), findsOneWidget);
    });
  });
}
