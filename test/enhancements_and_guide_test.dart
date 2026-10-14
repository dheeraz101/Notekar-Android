import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/note_preview_sheet.dart';
import 'package:notekar/dialogs/official_bulletins_sheet.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/models/help_guide_data.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/app_utils.dart';
import 'package:notekar/widgets/common_elements.dart';
import 'package:notekar/widgets/feedback_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final darkPalette = paletteFor('dark');
  final lightPalette = paletteFor('light');

  group('Experiment Channel User Copy Tests', () {
    testWidgets(
      'BuildTrackSelectPage displays user-centric subtitle and copy',
      (tester) async {
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
          find.text('Preview new features first. May be unstable.'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Experiment channel gives you immediate access'),
          findsOneWidget,
        );
        expect(
          find.textContaining('cutting-edge features and new design updates'),
          findsOneWidget,
        );
      },
    );

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
}
