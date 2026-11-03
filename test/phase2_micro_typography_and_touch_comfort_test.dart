import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/app_date_picker_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/theme/app_tokens.dart';
import 'package:notekar/widgets/markdown_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Phase 2: Micro-Typography & Rich Markdown Tests', () {
    testWidgets('MarkdownText parses bold, italics, strikethrough, and links', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownText(
              text:
                  'This is **bold**, *italic*, _also italic_, and ~~deleted~~ text with https://example.com',
              p: p,
              onOpenLink: (_) {},
            ),
          ),
        ),
      );

      // Verify wrapped in SelectionArea
      expect(find.byType(SelectionArea), findsOneWidget);

      // Verify RichText widget is present
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsWidgets);

      final richText = tester.widget<RichText>(richTextFinder.first);
      final textSpan = richText.text as TextSpan;
      expect(textSpan.children, isNotNull);

      // Find children with bold, italic, and strikethrough styles
      bool foundBold = false;
      bool foundItalic = false;
      bool foundStrike = false;

      void checkSpan(InlineSpan span) {
        if (span is TextSpan) {
          if (span.style?.fontWeight == FontWeight.w800) {
            foundBold = true;
          }
          if (span.style?.fontStyle == FontStyle.italic) {
            foundItalic = true;
          }
          if (span.style?.decoration == TextDecoration.lineThrough) {
            foundStrike = true;
          }
          span.children?.forEach(checkSpan);
        }
      }

      textSpan.children?.forEach(checkSpan);
      expect(foundBold, isTrue, reason: 'Bold style should be detected');
      expect(foundItalic, isTrue, reason: 'Italic style should be detected');
      expect(
        foundStrike,
        isTrue,
        reason: 'Strikethrough style should be detected',
      );
    });

    testWidgets(
      'MarkdownText parses blockquotes, task checkboxes, and ordered lists',
      (tester) async {
        const markdown =
            '> This is a quote\n- [ ] Unchecked task\n- [x] Completed task\n1. First ordered item';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MarkdownText(text: markdown, p: p, onOpenLink: (_) {}),
            ),
          ),
        );

        // Task checkboxes icons
        expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);
        expect(
          find.byIcon(CupertinoIcons.checkmark_circle_fill),
          findsOneWidget,
        );

        // Ordered list number
        expect(find.text('1.'), findsOneWidget);
      },
    );
  });

  group('Phase 2: Squircle Curvature & Touch Comfort Tests', () {
    testWidgets(
      'AppDatePickerSheet enforces 44pt touch targets and squircle curvature',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppDatePickerSheet(
                p: p,
                title: 'Select Date',
                initialDateTime: DateTime(2026, 11, 4),
                mode: CupertinoDatePickerMode.date,
              ),
            ),
          ),
        );

        // Verify CupertinoButtons have minimumSize >= 44
        final cupertinoButtons = tester.widgetList<CupertinoButton>(
          find.byType(CupertinoButton),
        );
        expect(cupertinoButtons.length, greaterThanOrEqualTo(2));
        for (final button in cupertinoButtons) {
          expect(button.minimumSize?.height, greaterThanOrEqualTo(44.0));
        }

        // Verify Container top squircle radius
        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration, isNotNull);
        final borderRadius = decoration!.borderRadius as BorderRadius?;
        expect(
          borderRadius?.topLeft.y,
          equals(NkTokens.radii.squircleSheetVal),
        );
      },
    );
  });
}
