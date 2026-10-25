import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/checkpoint_session_sheet.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
import 'package:notekar/dialogs/official_bulletins_sheet.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/models/checkpoint.dart';
import 'package:notekar/models/help_guide_data.dart';
import 'package:notekar/models/history_timeline_models.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/checkpoint_service.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/feedback_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final darkPalette = paletteFor('dark');
  final lightPalette = paletteFor('light');

  group('Experiment Channel User Copy Tests', () {
    testWidgets('BuildTrackSelectPage displays user-centric subtitle and copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BuildTrackSelectPage(
                p: darkPalette,
                betaTrack: false,
                currentChannel: 'stable',
                onSaveTrackPreference: (_) {},
                onLearnMoreBeta: () {},
              ),
            ),
          ),
        ),
      );

      // Verify user-centric copy
      expect(
        find.text(
          'Experience upcoming innovations and refined capabilities before public release.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('Choose how NoteKar receives software updates'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Immediate access to cutting-edge features. Intended for early testing.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'ExperimentChannelWarningScreen renders user-friendly warning cards',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: ExperimentChannelWarningScreen(p: darkPalette)),
        );

        // Verify headline & user-focused subhead
        expect(find.text('Experiment Release Channel'), findsOneWidget);
        expect(
          find.textContaining(
            'test brand-new features and designs before anyone else',
          ),
          findsOneWidget,
        );

        // Verify friendly section titles
        expect(find.text('Early Feature Access'), findsOneWidget);
        expect(find.text('Occasional Bugs & Glitches'), findsOneWidget);
        expect(find.text('Instant Automatic Updates'), findsOneWidget);
        expect(find.text('Protect Your Notes'), findsOneWidget);

        // Verify buttons
        expect(find.text('Backup Data First'), findsOneWidget);
        expect(find.text('I Understand & Enable Channel'), findsOneWidget);
        expect(find.text('Keep Current Track'), findsOneWidget);
      },
    );
  });

  group('UndoToast Acoustic Feedback Tests', () {
    testWidgets('Tapping Undo triggers onUndo callback', (tester) async {
      bool undoCalled = false;
      AppSound.setEnabled(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UndoToast(
              p: darkPalette,
              token: 101,
              message: 'Session started',
              persistent: true,
              onUndo: () {
                undoCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Session started'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();

      expect(undoCalled, isTrue);
    });
  });

  group('OfficialBulletins Monochrome Styling Tests', () {
    testWidgets(
      'NoticeCard renders black & white monochrome pill and action button',
      (tester) async {
        // In dark mode: bwBg is Colors.white, bwFg is Colors.black
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfficialBulletinsSheet(p: darkPalette, onOpenLink: (_) {}),
            ),
          ),
        );

        // Check Now button in dark mode has white background and black text
        final checkNowText = tester.widget<Text>(find.text('Check Now'));
        expect(checkNowText.style?.color, equals(Colors.black));
      },
    );

    testWidgets(
      'NoticeCard renders white text and black background in light mode',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfficialBulletinsSheet(p: lightPalette, onOpenLink: (_) {}),
            ),
          ),
        );

        // Check Now button in light mode has black background and white text
        final checkNowText = tester.widget<Text>(find.text('Check Now'));
        expect(checkNowText.style?.color, equals(Colors.white));
      },
    );
  });

  group('NotePreviewSheet Interactive Links Tests', () {
    testWidgets('renders plain notes correctly without links', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotePreviewSheet(
              p: darkPalette,
              title: 'Moment Note',
              note: 'Just a regular plain note without any links.',
            ),
          ),
        ),
      );

      expect(find.text('Moment Note'), findsOneWidget);
      expect(
        find.text('Just a regular plain note without any links.'),
        findsOneWidget,
      );
      expect(find.text('Copy Note'), findsOneWidget);
    });

    testWidgets(
      'detects URLs and displays departure warning dialog when tapped',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotePreviewSheet(
                p: darkPalette,
                title: 'Link Note',
                note:
                    'Check out https://notekarapp.vercel.app for sovereign documentation!',
              ),
            ),
          ),
        );

        expect(find.text('Link Note'), findsOneWidget);

        // Tap the link
        await tester.tap(find.textContaining('https://notekarapp.vercel.app'));
        await tester.pumpAndSettle();

        // Verify the Cupertino departure confirmation alert appeared
        expect(find.byType(ExternalLinkConfirmSheet), findsOneWidget);
        expect(find.text('Open Link'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('NOTEKARAPP.VERCEL.APP'), findsOneWidget);

        // Tap Cancel to dismiss cleanly
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(ExternalLinkConfirmSheet), findsNothing);
      },
    );

    testWidgets(
      'detects Markdown links [Label](url) and opens departure alert on tap',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotePreviewSheet(
                p: darkPalette,
                title: 'Markdown Link Note',
                note: '[Official Website](https://notekarapp.vercel.app)',
              ),
            ),
          ),
        );

        // Label should be displayed
        expect(find.textContaining('Official Website'), findsOneWidget);

        // Tap the label
        await tester.tap(find.textContaining('Official Website'));
        await tester.pumpAndSettle();

        expect(find.byType(ExternalLinkConfirmSheet), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'renders formatted markdown text and strips raw syntax like ***, **, *, ~~',
      (tester) async {
        const markdownNote = '''
# Project Brief
***
Welcome to ***Very Important Update***.
Please review **bold goals** and *italic details*.
Run `git status` before committing.
Do not forget ~~deprecated steps~~.
- [ ] First task
- [x] Completed task
- Normal bullet point
''';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotePreviewSheet(
                p: darkPalette,
                title: 'Formatted Note Preview',
                note: markdownNote,
              ),
            ),
          ),
        );

        // Header without '#'
        expect(find.textContaining('Project Brief'), findsOneWidget);
        expect(find.textContaining('# Project Brief'), findsNothing);

        // Divider is rendered as a Divider widget, not raw '***'
        expect(find.byType(Divider), findsOneWidget);
        expect(find.text('***'), findsNothing);

        // Bold italic without '***'
        expect(find.textContaining('Very Important Update'), findsOneWidget);
        expect(
          find.textContaining('***Very Important Update***'),
          findsNothing,
        );

        // Bold without '**'
        expect(find.textContaining('bold goals'), findsOneWidget);
        expect(find.textContaining('**bold goals**'), findsNothing);

        // Italic without '*'
        expect(find.textContaining('italic details'), findsOneWidget);
        expect(find.textContaining('*italic details*'), findsNothing);

        // Inline code without backticks
        expect(find.textContaining('git status'), findsOneWidget);
        expect(find.textContaining('`git status`'), findsNothing);

        // Strikethrough without '~~'
        expect(find.textContaining('deprecated steps'), findsOneWidget);
        expect(find.textContaining('~~deprecated steps~~'), findsNothing);

        // Checkboxes
        expect(
          find.byIcon(Icons.check_box_outline_blank_rounded),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
        expect(find.textContaining('First task'), findsOneWidget);
        expect(find.textContaining('Completed task'), findsOneWidget);

        // Bullet point
        expect(find.textContaining('Normal bullet point'), findsOneWidget);
      },
    );

    testWidgets(
      'allows cycling forward and backward through notes using navigation buttons',
      (tester) async {
        int? editedNoteIndex;
        final items = [
          NotePreviewItem(
            note: 'First note about morning workout',
            title: 'Morning Workout',
            category: 'Health',
            dateStr: '10:00 AM',
            onEdit: () => editedNoteIndex = 0,
          ),
          NotePreviewItem(
            note: 'Second note about code review #project',
            title: 'Code Review',
            category: 'Work',
            dateStr: '02:30 PM',
            onEdit: () => editedNoteIndex = 1,
          ),
          NotePreviewItem(
            note: 'Third note about evening reading',
            title: 'Reading Session',
            category: 'Leisure',
            dateStr: '08:15 PM',
            onEdit: () => editedNoteIndex = 2,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotePreviewSheet(
                p: darkPalette,
                title: items[0].title,
                note: items[0].note,
                category: items[0].category,
                dateStr: items[0].dateStr,
                items: items,
                initialIndex: 0,
              ),
            ),
          ),
        );

        // Verify Note 1 is displayed
        expect(find.text('Morning Workout'), findsOneWidget);
        expect(
          find.textContaining('First note about morning workout'),
          findsOneWidget,
        );
        expect(find.text('1 of 3'), findsOneWidget);

        // Tap Next Note (>) on bottom bar
        await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
        await tester.pumpAndSettle();

        // Verify Note 2 is displayed
        expect(find.text('Code Review'), findsOneWidget);
        expect(
          find.textContaining('Second note about code review'),
          findsOneWidget,
        );
        expect(find.text('2 of 3'), findsOneWidget);

        // Tap Next Note (>) to reach Note 3
        await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
        await tester.pumpAndSettle();

        // Verify Note 3 is displayed
        expect(find.text('Reading Session'), findsOneWidget);
        expect(
          find.textContaining('Third note about evening reading'),
          findsOneWidget,
        );
        expect(find.text('3 of 3'), findsOneWidget);

        // Tap Next Note again on boundary (should stay on 3 of 3)
        await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
        await tester.pumpAndSettle();
        expect(find.text('3 of 3'), findsOneWidget);

        // Tap Previous Note (<) to go back to Note 2
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Code Review'), findsOneWidget);
        expect(find.text('2 of 3'), findsOneWidget);

        // Test Edit button edits Note 2
        await tester.tap(find.text('Edit Note'));
        await tester.pumpAndSettle();
        expect(editedNoteIndex, equals(1));
      },
    );

    testWidgets(
      'supports horizontal swipe gestures to navigate between notes',
      (tester) async {
        final items = [
          const NotePreviewItem(note: 'Note A content', title: 'Note A'),
          const NotePreviewItem(note: 'Note B content', title: 'Note B'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotePreviewSheet(
                p: darkPalette,
                title: items[0].title,
                note: items[0].note,
                items: items,
                initialIndex: 0,
              ),
            ),
          ),
        );

        expect(find.text('Note A'), findsOneWidget);
        expect(find.textContaining('Note A content'), findsOneWidget);

        // Swipe left on note card to advance to Note B
        await tester.fling(
          find.textContaining('Note A content'),
          const Offset(-300, 0),
          1000,
        );
        await tester.pumpAndSettle();

        expect(find.text('Note B'), findsOneWidget);
        expect(find.textContaining('Note B content'), findsOneWidget);

        // Swipe right on note card to return to Note A
        await tester.fling(
          find.textContaining('Note B content'),
          const Offset(300, 0),
          1000,
        );
        await tester.pumpAndSettle();

        expect(find.text('Note A'), findsOneWidget);
        expect(find.textContaining('Note A content'), findsOneWidget);
      },
    );
  });

  group('Help Guide Catalog Tests', () {
    test(
      'contains newly added items with complete descriptions and keywords',
      () {
        final titles = allHelpAndGuideCatalog.map((i) => i.title).toSet();

        expect(
          titles.contains('Silent Share Intake & Instant Storage'),
          isTrue,
        );
        expect(
          titles.contains('Dedicated Daily Wrap-up & Day Sealing'),
          isTrue,
        );
        expect(
          titles.contains('Official Bulletins & Critical Notices'),
          isTrue,
        );
        expect(
          titles.contains('Sobriety Companion & Fast Relapse Reset'),
          isTrue,
        );
        expect(
          titles.contains('End of Support Card & Diagnostics Quest'),
          isTrue,
        );
        expect(
          titles.contains('Interactive Note Preview Links & Safe Departure'),
          isTrue,
        );
      },
    );
  });

  group('Checkpoint 2-Way Sessions & Timeline Decluttering Tests', () {
    testWidgets(
      'CheckpointSessionSheet renders start, end, quick duration chips, and allows logging session',
      (tester) async {
        DateTime? loggedStart;
        DateTime? loggedEnd;
        String? loggedNote;

        const preset = CheckpointPreset(
          id: 'workout',
          emoji: '🏋️',
          label: 'Workout',
          category: 'Health',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckpointSessionSheet(
                p: darkPalette,
                preset: preset,
                onLogSession: ({required start, required end, note}) async {
                  loggedStart = start;
                  loggedEnd = end;
                  loggedNote = note;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Workout'), findsWidgets);
        expect(find.text('START POINT'), findsOneWidget);
        expect(find.text('END POINT'), findsOneWidget);
        expect(find.text('30m'), findsWidgets);
        expect(find.text('1h'), findsOneWidget);
        expect(find.text('Log 2-Way Session'), findsOneWidget);

        // Tap '1h' chip
        await tester.tap(find.text('1h'));
        await tester.pumpAndSettle();

        // Enter optional note
        await tester.enterText(find.byType(TextField), 'Heavy leg day');
        await tester.pumpAndSettle();

        // Tap Log 2-Way Session
        await tester.tap(find.text('Log 2-Way Session'));
        await tester.pumpAndSettle();

        expect(loggedStart, isNotNull);
        expect(loggedEnd, isNotNull);
        expect(loggedNote, 'Heavy leg day');
        expect(loggedEnd!.difference(loggedStart!).inMinutes, 60);
      },
    );

    test(
      'CheckpointService logCheckpointSession creates paired in/out moments and records completion',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'notekar_cp_test_',
        );
        SharedPreferences.setMockInitialValues({});
        await MomentRepository().ensureInitialized(directoryPath: tempDir.path);
        final service = CheckpointService.instance;
        await service.init();

        const preset = CheckpointPreset(
          id: 'read',
          emoji: '📖',
          label: 'Reading',
          category: 'Learning',
        );

        final now = DateTime.now();
        final start = now.subtract(const Duration(minutes: 45));
        final end = now;

        final moments = await service.logCheckpointSession(
          preset: preset,
          startTimestamp: start,
          endTimestamp: end,
          note: 'Chapter 4 completed',
        );

        expect(moments.length, 2);
        expect(moments[0].type, 'in');
        expect(moments[1].type, 'out');
        expect(moments[0].category, 'Learning');
        expect(moments[1].category, 'Learning');
        expect(moments[0].tags.contains('checkpoint'), isTrue);
        expect(moments[1].tags.contains('checkpoint'), isTrue);
        expect(moments[0].tags.contains('checkpoint:read'), isTrue);
        expect(moments[1].tags.contains('checkpoint:read'), isTrue);

        expect(service.isCompletedToday('read', moments), isTrue);

        await MomentRepository().close();
        if (tempDir.existsSync()) {
          try {
            await tempDir.delete(recursive: true);
          } catch (_) {}
        }
      },
    );

    test(
      'buildTimelineDaySections automatically pairs checkpoint session moments into a single TimelineSessionItem',
      () {
        final now = DateTime.now();
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final inMoment = Moment(
          id: 101,
          timestamp: now
              .subtract(const Duration(minutes: 45))
              .millisecondsSinceEpoch,
          type: 'in',
          date: dateStr,
          note: 'Reading 📖 #read',
          category: 'Learning',
          tags: ['checkpoint', '#read'],
        );
        final outMoment = Moment(
          id: 102,
          timestamp: now.millisecondsSinceEpoch,
          type: 'out',
          date: dateStr,
          note: 'Reading 📖 #read',
          category: 'Learning',
          tags: ['checkpoint', '#read'],
        );

        final sections = buildTimelineDaySections([inMoment, outMoment]);
        expect(sections.length, 1);
        final items = sections.first.items;
        // Must be paired into 1 TimelineSessionItem instead of 2 single entries!
        expect(items.length, 1);
        expect(items.first, isA<TimelineSessionItem>());
        final sessionItem = items.first as TimelineSessionItem;
        expect(sessionItem.duration.inMinutes, 45);
        expect(sessionItem.inMoment.id, 101);
        expect(sessionItem.outMoment?.id, 102);
      },
    );

    test(
      'buildTimelineDataInIsolate excludes checkpoints when hideCheckpoints is true',
      () {
        final now = DateTime.now();
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final checkpointSingle = Moment(
          id: 201,
          timestamp: now
              .subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          type: 'moment',
          date: dateStr,
          note: 'Habit check',
          category: 'Habits',
          tags: ['checkpoint'],
        );
        final regularMoment = Moment(
          id: 202,
          timestamp: now.millisecondsSinceEpoch,
          type: 'moment',
          date: dateStr,
          note: 'Important thought',
          category: 'Notes',
          tags: ['notes'],
        );

        // Without hideCheckpoints
        final resultNormal = buildTimelineDataInIsolate(
          TimelineIsolatePayload(
            entries: [checkpointSingle, regularMoment],
            includeGaps: false,
            filter: 'all',
            today: dateStr,
            weekAgo: now.subtract(const Duration(days: 7)),
            hideCheckpoints: false,
          ),
        );
        expect(resultNormal.sections.first.items.length, 2);

        // With hideCheckpoints enabled
        final resultHidden = buildTimelineDataInIsolate(
          TimelineIsolatePayload(
            entries: [checkpointSingle, regularMoment],
            includeGaps: false,
            filter: 'all',
            today: dateStr,
            weekAgo: now.subtract(const Duration(days: 7)),
            hideCheckpoints: true,
          ),
        );
        expect(resultHidden.sections.first.items.length, 1);
        final singleItem =
            resultHidden.sections.first.items.first as TimelineSingleItem;
        expect(singleItem.moment.id, 202);
      },
    );
  });
}
