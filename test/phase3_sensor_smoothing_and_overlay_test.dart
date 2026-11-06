import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/dialogs/settings/targets_projects_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Phase 3: Sensor Smoothing & Motion Tests', () {
    const channel = MethodChannel('notekar/files');
    final log = <MethodCall>[];
    bool mockCanDrawOverlays = false;

    setUp(() {
      SharedPreferences.setMockInitialValues({'floating_timer_enabled': true});
      log.clear();
      mockCanDrawOverlays = false;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            log.add(call);
            if (call.method == 'canDrawOverlays') {
              return mockCanDrawOverlays;
            }
            if (call.method == 'startFloatingTimer') {
              return null;
            }
            if (call.method == 'stopFloatingTimer') {
              return null;
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    testWidgets(
      'TargetsProjectsSettingsPage re-checks overlay permission on app resume',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TargetsProjectsSettingsPage(p: p),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate returning from system settings with permission now granted
        mockCanDrawOverlays = true;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        final canDrawCalls = log.where((c) => c.method == 'canDrawOverlays');
        expect(canDrawCalls, isNotEmpty);

        final startTimerCalls = log.where(
          (c) => c.method == 'startFloatingTimer',
        );
        expect(startTimerCalls, isNotEmpty);
      },
    );

    testWidgets(
      'TargetsProjectsSettingsPage auto-disables timer when overlay permission revoked',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: TargetsProjectsSettingsPage(p: p),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate permission revoked while in background
        mockCanDrawOverlays = false;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('floating_timer_enabled'), false);
      },
    );
  });
}
