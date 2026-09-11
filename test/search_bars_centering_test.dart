import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/search_dialogs.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/settings_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Search Bar Centering Tests', () {
    testWidgets(
      'SettingsSearchBox text and icons remain vertically centered in loose and constrained layouts',
      (tester) async {
        final emptyCtrl = TextEditingController(text: '');
        final typedCtrl = TextEditingController(text: 'Appearance');

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Inter'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Loose / unconstrained container
                    SettingsSearchBox(
                      key: const ValueKey('settings_loose'),
                      p: p,
                      controller: emptyCtrl,
                      onChanged: (_) {},
                      onClear: () {},
                    ),
                    const SizedBox(height: 24),
                    // Constrained to 56px (exact available height in SettingsDialog)
                    SizedBox(
                      height: 56,
                      child: SettingsSearchBox(
                        key: const ValueKey('settings_tight_56'),
                        p: p,
                        controller: typedCtrl,
                        onChanged: (_) {},
                        onClear: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Check loose empty state (hint text + icon)
        final looseBox = tester.firstRenderObject<RenderBox>(
          find.byKey(const ValueKey('settings_loose')),
        );
        final looseCenterY =
            looseBox.localToGlobal(Offset.zero).dy + looseBox.size.height / 2;
        final looseIcon = tester.firstRenderObject<RenderBox>(
          find.descendant(
            of: find.byKey(const ValueKey('settings_loose')),
            matching: find.byIcon(Icons.search_rounded),
          ),
        );
        final looseIconCenterY =
            looseIcon.localToGlobal(Offset.zero).dy + looseIcon.size.height / 2;
        final looseHint = tester.firstRenderObject<RenderBox>(
          find.text('Search settings'),
        );
        final looseHintCenterY =
            looseHint.localToGlobal(Offset.zero).dy + looseHint.size.height / 2;

        expect((looseCenterY - looseIconCenterY).abs(), lessThan(0.001));
        expect((looseCenterY - looseHintCenterY).abs(), lessThan(0.001));

        // Check constrained typed state (editable text + icon + close button)
        final tightBox = tester.firstRenderObject<RenderBox>(
          find.byKey(const ValueKey('settings_tight_56')),
        );
        final tightCenterY =
            tightBox.localToGlobal(Offset.zero).dy + tightBox.size.height / 2;
        final tightIcon = tester.firstRenderObject<RenderBox>(
          find.descendant(
            of: find.byKey(const ValueKey('settings_tight_56')),
            matching: find.byIcon(Icons.search_rounded),
          ),
        );
        final tightIconCenterY =
            tightIcon.localToGlobal(Offset.zero).dy + tightIcon.size.height / 2;
        final tightEdit = tester.firstRenderObject<RenderBox>(
          find.descendant(
            of: find.byKey(const ValueKey('settings_tight_56')),
            matching: find.byType(EditableText),
          ),
        );
        final tightEditCenterY =
            tightEdit.localToGlobal(Offset.zero).dy + tightEdit.size.height / 2;
        final tightClose = tester.firstRenderObject<RenderBox>(
          find.descendant(
            of: find.byKey(const ValueKey('settings_tight_56')),
            matching: find.byIcon(Icons.close_rounded),
          ),
        );
        final tightCloseCenterY =
            tightClose.localToGlobal(Offset.zero).dy +
            tightClose.size.height / 2;

        expect((tightCenterY - tightIconCenterY).abs(), lessThan(0.001));
        expect((tightCenterY - tightEditCenterY).abs(), lessThan(0.001));
        expect((tightCenterY - tightCloseCenterY).abs(), lessThan(0.001));
      },
    );

    testWidgets(
      'SearchNotesBox text and icons remain vertically centered in loose and constrained layouts',
      (tester) async {
        final emptyCtrl = TextEditingController(text: '');
        final typedCtrl = TextEditingController(text: 'Meeting note');

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Inter'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Loose / unconstrained container (NoteSearchDialog layout)
                    SearchNotesBox(
                      key: const ValueKey('notes_loose'),
                      p: p,
                      controller: emptyCtrl,
                      onChanged: (_) {},
                      onClear: () {},
                    ),
                    const SizedBox(height: 24),
                    // Constrained to 60px (exact available height in search_notes_settings_page)
                    SizedBox(
                      height: 60,
                      child: SearchNotesBox(
                        key: const ValueKey('notes_tight_60'),
                        p: p,
                        controller: typedCtrl,
                        onChanged: (_) {},
                        onClear: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Check loose empty state (hint text + icon)
        final looseBox = tester.firstRenderObject<RenderBox>(
          find.byKey(const ValueKey('notes_loose')),
        );
        final looseCenterY =
            looseBox.localToGlobal(Offset.zero).dy + looseBox.size.height / 2;
        final looseIcon = tester.firstRenderObject<RenderBox>(
          find.descendant(
            of: find.byKey(const ValueKey('notes_loose')),
            matching: find.byIcon(Icons.search_rounded),
          ),
        );
        final looseIconCenterY =
            looseIcon.localToGlobal(Offset.zero).dy + looseIcon.size.height / 2;
        final looseHint = tester.firstRenderObject<RenderBox>(
          find.text('Search notes'),
        );
        final looseHintCenterY =
            looseHint.localToGlobal(Offset.zero).dy + looseHint.size.height / 2;

        expect((looseCenterY - looseIconCenterY).abs(), lessThan(0.001));
        expect((looseCenterY - looseHintCenterY).abs(), lessThan(0.001));

        // Check constrained typed state (editable text + icon + close button)
        final tightBox = tester.firstRenderObject<RenderBox>(
          find.byKey(const ValueKey('notes_tight_60')),
        );
        final tightCenterY =
            tightBox.localToGlobal(Offset.zero).dy + tightBox.size.height / 2;
        final tightIcon = tester.firstRenderObject<RenderBox>(
          find.descendant(
            of: find.byKey(const ValueKey('notes_tight_60')),
            matching: find.byIcon(Icons.search_rounded),
          ),
        );
        final tightIconCenterY =
            tightIcon.localToGlobal(Offset.zero).dy + tightIcon.size.height / 2;
        final tightEdit = tester.firstRenderObject<RenderBox>(
          find.descendant(
            of: find.byKey(const ValueKey('notes_tight_60')),
            matching: find.byType(EditableText),
          ),
        );
        final tightEditCenterY =
            tightEdit.localToGlobal(Offset.zero).dy + tightEdit.size.height / 2;
        final tightClose = tester.firstRenderObject<RenderBox>(
          find.descendant(
            of: find.byKey(const ValueKey('notes_tight_60')),
            matching: find.byIcon(Icons.close_rounded),
          ),
        );
        final tightCloseCenterY =
            tightClose.localToGlobal(Offset.zero).dy +
            tightClose.size.height / 2;

        expect((tightCenterY - tightIconCenterY).abs(), lessThan(0.001));
        expect((tightCenterY - tightEditCenterY).abs(), lessThan(0.001));
        expect((tightCenterY - tightCloseCenterY).abs(), lessThan(0.001));
      },
    );
  });
}
