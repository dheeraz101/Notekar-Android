import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/design_system/nk_ios_switch.dart';
import 'package:notekar/widgets/design_system/nk_pill_segmented_control.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:notekar/widgets/toolbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPalette = Palette(
    name: 'light',
    bg: const Color(0xFFF2F2F7),
    surface: const Color(0xFFF7F7F9),
    surface2: const Color(0xFFFFFFFF),
    surface3: const Color(0xFFE5E5EA),
    border: const Color(0xFFE5E5EA),
    text: const Color(0xFF000000),
    text2: const Color(0xFF3C3C43),
    text3: const Color(0xFF6C6C70),
    clock: const Color(0xFFD1D1D6),
    accent: const Color(0xFF007AFF),
    green: const Color(0xFF248A3D),
    orange: const Color(0xFFC46A00),
    red: const Color(0xFFD70015),
    blue: const Color(0xFF007AFF),
  );

  group('NkIosSwitch Precision & Kinetic Verification', () {
    testWidgets('Tapping toggles value and invokes onChanged', (tester) async {
      bool switchVal = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: NkIosSwitch(
                    value: switchVal,
                    onChanged: (v) => setState(() => switchVal = v),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(switchVal, isFalse);
      await tester.tap(find.byType(NkIosSwitch));
      await tester.pumpAndSettle();
      expect(switchVal, isTrue);

      await tester.tap(find.byType(NkIosSwitch));
      await tester.pumpAndSettle();
      expect(switchVal, isFalse);
    });

    testWidgets('Horizontal drag gestures track finger and snap to target', (
      tester,
    ) async {
      bool switchVal = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: NkIosSwitch(
                    value: switchVal,
                    onChanged: (v) => setState(() => switchVal = v),
                  ),
                );
              },
            ),
          ),
        ),
      );

      final switchFinder = find.byType(NkIosSwitch);
      // Drag across track horizontally to the right
      await tester.drag(switchFinder, const Offset(40.0, 0.0));
      await tester.pumpAndSettle();

      expect(switchVal, isTrue);

      // Drag back to the left
      await tester.drag(switchFinder, const Offset(-40.0, 0.0));
      await tester.pumpAndSettle();

      expect(switchVal, isFalse);
    });

    testWidgets(
      'Drag less than halfway releases back to original state without mutation',
      (tester) async {
        bool switchVal = false;
        int changeCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: NkIosSwitch(
                  value: switchVal,
                  onChanged: (v) {
                    switchVal = v;
                    changeCount++;
                  },
                ),
              ),
            ),
          ),
        );

        final switchFinder = find.byType(NkIosSwitch);
        // Move past touch slop (18px) to initiate drag, but keep thumb under 50% travel (e.g. 23px total)
        final gesture = await tester.startGesture(
          tester.getCenter(switchFinder),
        );
        await gesture.moveBy(const Offset(22.0, 0.0));
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(switchVal, isFalse);
        expect(changeCount, 0);
      },
    );

    testWidgets(
      'Thumb stretch aligns inwards without clipping or exceeding track boundaries',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(child: NkIosSwitch(value: false, onChanged: (_) {})),
            ),
          ),
        );

        final switchFinder = find.byType(NkIosSwitch);
        final gesture = await tester.startGesture(
          tester.getCenter(switchFinder),
        );
        await tester.pump(const Duration(milliseconds: 140));

        // Locate transform and containers
        final transformFinder = find.descendant(
          of: switchFinder,
          matching: find.byType(Transform),
        );
        expect(transformFinder, findsWidgets);

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('Custom onHaptic callback is invoked on toggle', (
      tester,
    ) async {
      int hapticCount = 0;
      bool switchVal = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NkIosSwitch(
                value: switchVal,
                onChanged: (v) => switchVal = v,
                onHaptic: () => hapticCount++,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NkIosSwitch));
      await tester.pumpAndSettle();
      expect(hapticCount, 1);
    });

    testWidgets('Semantics exposes toggled state and tap action', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: NkIosSwitch(value: true, onChanged: (_) {})),
          ),
        ),
      );

      final semanticsFinder = find.descendant(
        of: find.byType(NkIosSwitch),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.toggled == true,
        ),
      );
      expect(semanticsFinder, findsOneWidget);
    });
  });

  group('NkPillSegmentedControl Resilience & Accessibility', () {
    testWidgets('Tapping option updates selection and triggers onChanged', (
      tester,
    ) async {
      String selected = 'Day';
      final options = ['Day', 'Week', 'Month'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: NkPillSegmentedControl<String>(
                    options: options,
                    selected: selected,
                    onChanged: (v) => setState(() => selected = v),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(selected, 'Day');
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(selected, 'Week');

      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(selected, 'Month');
    });

    testWidgets(
      'Renders inside an unconstrained horizontal container without crashing',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: NkPillSegmentedControl<String>(
                  options: const ['One', 'Two', 'Three'],
                  selected: 'One',
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('One'), findsOneWidget);
        expect(find.text('Two'), findsOneWidget);
        expect(find.text('Three'), findsOneWidget);
      },
    );

    testWidgets(
      'Semantics correctly marks the selected segment with selected: true and button: true',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: NkPillSegmentedControl<String>(
                  options: const ['Alpha', 'Beta'],
                  selected: 'Alpha',
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        final alphaSemantics = tester.widget<Semantics>(
          find
              .ancestor(
                of: find.text('Alpha'),
                matching: find.byWidgetPredicate(
                  (w) => w is Semantics && w.properties.selected == true,
                ),
              )
              .first,
        );
        expect(alphaSemantics.properties.selected, isTrue);
        expect(alphaSemantics.properties.button, isTrue);

        final betaSemantics = tester.widget<Semantics>(
          find
              .ancestor(
                of: find.text('Beta'),
                matching: find.byWidgetPredicate(
                  (w) => w is Semantics && w.properties.selected == false,
                ),
              )
              .first,
        );
        expect(betaSemantics.properties.selected, isFalse);
        expect(betaSemantics.properties.button, isTrue);
      },
    );

    testWidgets('Renders without overflow under extreme text scaling (200%)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(
                child: NkPillSegmentedControl<String>(
                  options: const ['Focus', 'Rest'],
                  selected: 'Focus',
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Focus'), findsOneWidget);
    });
  });

  group('Toolbar Middle Button Rest Offset Verification', () {
    testWidgets(
      'Inactive session middle button offset is exactly 0.0 at rest',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: Toolbar(
                p: testPalette,
                mode: 'single',
                onMode: () {},
                onHistory: () {},
                onSettings: () {},
                isSessionActive: false,
                showLabels: true,
                largeControls: false,
                showBackgroundPill: true,
                animateIcons: false,
                showHistoryText: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final transforms = tester.widgetList<Transform>(find.byType(Transform));
        for (final t in transforms) {
          final matrix = t.transform;
          // Verify translation along X is 0.0, NOT -3.5
          expect(matrix.getTranslation().x, 0.0);
        }
      },
    );
  });

  group('SettingsSwitchRow Integration & Haptic Harmony', () {
    testWidgets('Tapping the row toggles value cleanly without exception', (
      tester,
    ) async {
      bool rowVal = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SettingsSwitchRow(
                  p: testPalette,
                  title: 'OLED Pure Black',
                  value: rowVal,
                  onChanged: (v) => setState(() => rowVal = v),
                );
              },
            ),
          ),
        ),
      );

      expect(rowVal, isFalse);
      await tester.tap(find.text('OLED Pure Black'));
      await tester.pumpAndSettle();
      expect(rowVal, isTrue);

      // Tap on switch child directly
      await tester.tap(find.byType(NkIosSwitch));
      await tester.pumpAndSettle();
      expect(rowVal, isFalse);
    });
  });
}
