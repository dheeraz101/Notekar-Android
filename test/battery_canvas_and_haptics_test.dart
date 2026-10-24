import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/vault_password_dialog.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/device_health_manager.dart';
import 'package:notekar/widgets/predictive_back_peek.dart';

void main() {
  group('DeviceHealthManager Intelligent Adaptation', () {
    test(
      'Correctly adapts throttling and target FPS based on battery state',
      () {
        final manager = DeviceHealthManager.instance;

        // Normal state: 80% unplugged, power save off
        manager.setSimulatedState(
          isPowerSaveMode: false,
          batteryLevel: 80,
          isPluggedIn: false,
        );
        expect(manager.shouldThrottle, isFalse);
        expect(manager.targetFps, anyOf(equals(60), equals(120)));

        // Battery Saver enabled -> Throttles to 0 FPS static vector
        manager.setSimulatedState(
          isPowerSaveMode: true,
          batteryLevel: 80,
          isPluggedIn: false,
        );
        expect(manager.shouldThrottle, isTrue);
        expect(manager.targetFps, equals(0));
        expect(manager.enableGlowShader, isFalse);

        // Low Battery (< 20%) while unplugged -> Throttles
        manager.setSimulatedState(
          isPowerSaveMode: false,
          batteryLevel: 15,
          isPluggedIn: false,
        );
        expect(manager.shouldThrottle, isTrue);
        expect(manager.targetFps, equals(0));
        expect(manager.enableGlowShader, isFalse);

        // Low Battery (< 20%) but PLUGGED IN -> Does NOT throttle
        manager.setSimulatedState(
          isPowerSaveMode: false,
          batteryLevel: 15,
          isPluggedIn: true,
        );
        expect(manager.shouldThrottle, isFalse);
        expect(manager.targetFps, equals(120));

        // Reset
        manager.setForceThrottled(null);
      },
    );

    test('refresh() executes safely and marks isInitialized', () async {
      final manager = DeviceHealthManager.instance;
      await manager.refresh();
      expect(manager.isInitialized, isTrue);
    });
  });

  group('PredictiveBackPeek Widget', () {
    testWidgets('Non-edge swipes do not trigger peek scaling', (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PredictiveBackPeek(
              onPop: () => popped = true,
              edgeWidth: 40.0,
              popThreshold: 80.0,
              child: Container(
                key: const ValueKey('card'),
                width: 300,
                height: 400,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // Swipe starting from dx = 100 (well past edgeWidth 40)
      final center = tester.getCenter(find.byKey(const ValueKey('card')));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(120, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(popped, isFalse);
    });

    testWidgets('Left edge swipe past threshold triggers onPop', (
      tester,
    ) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: PredictiveBackPeek(
                onPop: () => popped = true,
                edgeWidth: 40.0,
                popThreshold: 80.0,
                child: Container(
                  key: const ValueKey('peek_content'),
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ),
      );

      // Drag starting from left edge (dx = 15 <= 40)
      final gesture = await tester.startGesture(const Offset(15, 200));
      await gesture.moveBy(const Offset(95, 0)); // > 80 pop threshold
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets(
      'Left edge swipe below threshold cancels without pop and springs back',
      (tester) async {
        bool popped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 600,
                child: PredictiveBackPeek(
                  onPop: () => popped = true,
                  edgeWidth: 40.0,
                  popThreshold: 80.0,
                  child: Container(
                    key: const ValueKey('peek_content'),
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ),
        );

        // Drag starting from left edge (dx = 10) but only moving 30px (< 80)
        final gesture = await tester.startGesture(const Offset(10, 200));
        await gesture.moveBy(const Offset(30, 0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(popped, isFalse);
      },
    );

    testWidgets(
      'Non-edge horizontal drags pass through unhindered to child scrollable',
      (tester) async {
        bool popped = false;
        double childScrolledDistance = 0.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 600,
                child: PredictiveBackPeek(
                  onPop: () => popped = true,
                  edgeWidth: 40.0,
                  popThreshold: 80.0,
                  child: GestureDetector(
                    key: const ValueKey('child_drag_target'),
                    onHorizontalDragUpdate: (details) {
                      childScrolledDistance += details.delta.dx;
                    },
                    child: Container(color: Colors.blueGrey),
                  ),
                ),
              ),
            ),
          ),
        );

        // Start drag at dx = 120 (well beyond edgeWidth 40)
        final gesture = await tester.startGesture(const Offset(120, 200));
        await gesture.moveBy(const Offset(60, 0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(popped, isFalse);
        expect(childScrolledDistance, greaterThan(0.0));
      },
    );
  });

  group('VaultPasswordDialog Modal', () {
    testWidgets('Import mode prompts for single password', (tester) async {
      String? enteredPassword;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  enteredPassword = await VaultPasswordDialog.show(
                    context: context,
                    p: paletteFor('dark'),
                    isExport: false,
                  );
                },
                child: const Text('Open Vault Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Vault Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Unlock Sovereign Vault'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('vault_password_input')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('vault_password_input')),
        'SecretPass123',
      );
      await tester.pump();

      await tester.tap(find.text('Unlock & Restore'));
      await tester.pumpAndSettle();

      expect(enteredPassword, equals('SecretPass123'));
    });

    testWidgets('Export mode validates password confirmation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => VaultPasswordDialog.show(
                  context: context,
                  p: paletteFor('dark'),
                  isExport: true,
                ),
                child: const Text('Open Export Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Export Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Encrypt Sovereign Vault'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));

      // Enter mismatched passwords
      await tester.enterText(
        find.byKey(const ValueKey('vault_password_input')),
        'MyVaultPass123',
      );
      await tester.enterText(
        find.byKey(const ValueKey('vault_password_confirm_input')),
        'DifferentPass456',
      );
      await tester.pump();

      await tester.tap(find.text('Encrypt & Export'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });
  });
}
