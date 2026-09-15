import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/big_note_dialog.dart';
import 'package:notekar/dialogs/note_dialog.dart';
import 'package:notekar/models/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark');

  group('Custom Hashtags and Big Note Canvas Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'custom_note_tags': ['#focus', '#writing', '#journal'],
      });
    });

    testWidgets(
      'NoteDialog displays custom hashtags from preferences and Expand button',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoteDialog(p: p, initialNote: 'Short quick note'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('#focus'), findsOneWidget);
        expect(find.text('#writing'), findsOneWidget);
        expect(find.text('#journal'), findsOneWidget);
        expect(find.text('Tag'), findsOneWidget);
        expect(find.text('Big Note'), findsOneWidget);
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

        expect(find.text('Big Note'), findsOneWidget);
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
  });
}
