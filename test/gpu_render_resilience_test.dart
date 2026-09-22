import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/main.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/top_fade_blur.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GPU Rendering Resilience & Anti-Green-Screen Safeguards', () {
    testWidgets(
      'TopFadeBlur uses safe bounded ClipRect without unclipped buffer bleed',
      (tester) async {
        final p = paletteFor('dark');
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(children: [TopFadeBlur(p: p, enabled: true)]),
            ),
          ),
        );

        // Verify ClipRect directly wraps BackdropFilter
        final clipFinder = find.descendant(
          of: find.byType(TopFadeBlur),
          matching: find.byType(ClipRect),
        );
        expect(clipFinder, findsOneWidget);

        final backdropFinder = find.descendant(
          of: clipFinder,
          matching: find.byType(BackdropFilter),
        );
        expect(backdropFinder, findsOneWidget);

        // Verify NO ShaderMask is used inside TopFadeBlur (ShaderMask + BackdropFilter caused GPU crashes)
        final shaderMaskFinder = find.descendant(
          of: find.byType(TopFadeBlur),
          matching: find.byType(ShaderMask),
        );
        expect(shaderMaskFinder, findsNothing);
      },
    );

    testWidgets(
      'NoteKarApp launches cleanly in Dark OLED mode without exceptions',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'm-theme': 'dark',
          'm-translucency': true,
          'm-clock-font': 'Inter',
        });
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(NoteKarApp(prefs: prefs));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(tester.takeException(), isNull);
        expect(find.byType(NoteKarApp), findsOneWidget);
      },
    );

    testWidgets('NoteKarApp launches cleanly across all 5 themes', (
      tester,
    ) async {
      const themes = ['dark', 'light', 'amoled', 'matrix', 'eink'];

      for (final theme in themes) {
        SharedPreferences.setMockInitialValues({
          'm-theme': theme,
          'm-translucency': true,
        });
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(NoteKarApp(prefs: prefs));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          tester.takeException(),
          isNull,
          reason: 'Failed on theme: $theme',
        );
      }
    });

    testWidgets(
      'ErrorWidget.builder displays Apple recovery screen gracefully on widget error',
      (tester) async {
        setupErrorHandling();
        final details = FlutterErrorDetails(
          exception: Exception('Simulated GPU or Shader Failure'),
          stack: StackTrace.current,
        );

        final widget = ErrorWidget.builder(details);

        await tester.pumpWidget(MaterialApp(home: widget));

        expect(find.text('Rendering Error Recovered'), findsOneWidget);
        expect(
          find.textContaining('Simulated GPU or Shader Failure'),
          findsOneWidget,
        );
      },
    );
  });
}
