import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/app_sheet.dart';
import 'package:notekar/models/palette.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Phase 4: Predictive Back & Android 14/15 Parity', () {
    testWidgets('AppSheet defaults canPop to false when onBack is provided', (
      tester,
    ) async {
      bool backCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSheet(
              p: p,
              title: 'Settings Subpage',
              onBack: () => backCalled = true,
              child: const Text('Subpage Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsOneWidget);

      final popScope = tester.widget<PopScope>(popScopeFinder);
      expect(popScope.canPop, isFalse);

      // Trigger pop invocation (predictive back gesture completed or back key)
      popScope.onPopInvokedWithResult?.call(false, null);
      expect(backCalled, isTrue);
    });

    testWidgets('AppSheet defaults canPop to true when onBack is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSheet(
              p: p,
              title: 'Root Sheet',
              child: const Text('Root Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsOneWidget);

      final popScope = tester.widget<PopScope>(popScopeFinder);
      expect(popScope.canPop, isTrue);
    });

    testWidgets('AppSheet respects explicit canPop override', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSheet(
              p: p,
              title: 'Custom Pop Sheet',
              canPop: false,
              child: const Text('Cannot pop'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsOneWidget);

      final popScope = tester.widget<PopScope>(popScopeFinder);
      expect(popScope.canPop, isFalse);
    });

    test('Android 14+ themed monochrome icon assets exist and are valid', () {
      final resDir = Directory('android/app/src/main/res');
      expect(resDir.existsSync(), isTrue);

      final launcherXml = File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
      );
      expect(launcherXml.existsSync(), isTrue);
      final launcherContent = launcherXml.readAsStringSync();
      expect(launcherContent.contains('<adaptive-icon'), isTrue);
      expect(launcherContent.contains('<monochrome'), isTrue);

      final launcherRoundXml = File(
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml',
      );
      expect(launcherRoundXml.existsSync(), isTrue);
      final launcherRoundContent = launcherRoundXml.readAsStringSync();
      expect(launcherRoundContent.contains('<adaptive-icon'), isTrue);
      expect(launcherRoundContent.contains('<monochrome'), isTrue);

      final foregroundXml = File(
        'android/app/src/main/res/drawable/ic_launcher_foreground.xml',
      );
      expect(foregroundXml.existsSync(), isTrue);
    });
  });
}
