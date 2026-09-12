import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  final p = paletteFor('dark');
  const channel = MethodChannel('notekar/files');

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notekar_cache_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'appCacheDir') {
            return tempDir.path;
          }
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('UpdateService Cache Calculations', () {
    test(
      'getTotalCacheSizeMb accurately sums all past installer packages',
      () async {
        final service = UpdateService();

        // Empty directory initially
        expect(await service.getTotalCacheSizeMb(), 0.0);

        // Create multiple past version APKs
        final apk1 = File('${tempDir.path}/notekar-7.4.9-arm64-v8a.apk');
        await apk1.writeAsBytes(List.filled(1024 * 1024 * 10, 1)); // 10 MB

        final apk2 = File('${tempDir.path}/notekar-7.5.0-arm64-v8a.apk');
        await apk2.writeAsBytes(List.filled(1024 * 1024 * 15, 2)); // 15 MB

        final partFile = File(
          '${tempDir.path}/notekar-7.5.1-universal.apk.part0',
        );
        await partFile.writeAsBytes(List.filled(1024 * 1024 * 5, 3)); // 5 MB

        final tmpFile = File('${tempDir.path}/notekar-7.5.1-arm64-v8a.apk.tmp');
        await tmpFile.writeAsBytes(List.filled(1024 * 1024 * 2, 4)); // 2 MB

        // Create an unrelated file that should not be counted
        final otherFile = File('${tempDir.path}/image_cache.png');
        await otherFile.writeAsBytes(List.filled(1024 * 1024 * 8, 5)); // 8 MB

        // Total expected = 10 + 15 + 5 + 2 = 32 MB
        final totalMb = await service.getTotalCacheSizeMb();
        expect(totalMb, closeTo(32.0, 0.05));
      },
    );

    test(
      'clearCachedBuilds purges all installer files and leaves other files intact',
      () async {
        final service = UpdateService();

        final apk1 = File('${tempDir.path}/notekar-7.5.0-arm64-v8a.apk');
        await apk1.writeAsBytes(List.filled(1024 * 100, 1));

        final partFile = File(
          '${tempDir.path}/notekar-7.5.1-universal.apk.part1',
        );
        await partFile.writeAsBytes(List.filled(1024 * 100, 2));

        final keepFile = File('${tempDir.path}/user_preferences.json');
        await keepFile.writeAsBytes(List.filled(1024 * 50, 3));

        final deletedCount = await service.clearCachedBuilds();
        expect(deletedCount, 2);

        expect(await apk1.exists(), isFalse);
        expect(await partFile.exists(), isFalse);
        expect(await keepFile.exists(), isTrue);

        expect(await service.getTotalCacheSizeMb(), 0.0);
      },
    );
  });

  group('UpdatesNoticesSettingsPage Auto Delete Switch', () {
    testWidgets(
      'renders Auto Delete Update Cache switch row and handles toggle',
      (tester) async {
        bool switchVal = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UpdatesNoticesSettingsPage(
                  p: p,
                  checkingUpdates: false,
                  updateInfo: null,
                  betaTrack: false,
                  remoteNotices: true,
                  onRemoteNoticesChanged: (_) {},
                  onOpenCategory: (_, {required parent}) {},
                  onLearnMoreBeta: () {},
                  autoDeleteUpdateCache: switchVal,
                  onAutoDeleteUpdateCacheChanged: (val) {
                    switchVal = val;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Auto Delete Update Cache'), findsOneWidget);
        expect(
          find.text(
            'Automatically deletes update packages upon installation to prevent installer cache build-up.',
          ),
          findsOneWidget,
        );

        // Tap switch row to toggle
        await tester.tap(find.text('Auto Delete Update Cache'));
        await tester.pumpAndSettle();

        expect(switchVal, isTrue);
      },
    );
  });

  group('UpdateCenterView Persistent Cache Card', () {
    testWidgets(
      'displays cache card with 0.00 MB when app is up to date and cache is empty',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UpdateCenterView(
                  p: p,
                  appVersion: '7.5.1',
                  enableTranslucency: true,
                  reduceMotion: false,
                  onOpenLink: (_) {},
                  onCheckUpdates: () {},
                  updateInfo: null,
                  // Up to date!
                  checkingUpdates: false,
                  updateStatus: 'idle',
                  currentBuildChannel: 'stable',
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Confirms cache card is ALWAYS visible even when updateInfo is null
        expect(find.text('Build Cache Size'), findsOneWidget);
        expect(find.text('0.00 MB (No cached installers)'), findsOneWidget);
        expect(find.text('Cache Clean'), findsOneWidget);
      },
    );

    testWidgets(
      'displays cumulative cache size and enables Delete Cache when cache exists',
      (tester) async {
        // Seed two APK files totaling 25 MB
        final apk1 = File('${tempDir.path}/notekar-7.5.0-arm64-v8a.apk');
        await apk1.writeAsBytes(List.filled(1024 * 1024 * 12, 1));
        final apk2 = File('${tempDir.path}/notekar-7.5.1-arm64-v8a.apk');
        await apk2.writeAsBytes(List.filled(1024 * 1024 * 13, 2));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: UpdateCenterView(
                  p: p,
                  appVersion: '7.5.1',
                  enableTranslucency: true,
                  reduceMotion: false,
                  onOpenLink: (_) {},
                  onCheckUpdates: () {},
                  updateInfo: null,
                  // Even when up to date!
                  checkingUpdates: false,
                  updateStatus: 'idle',
                  currentBuildChannel: 'stable',
                  onLearnMoreBeta: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Build Cache Size'), findsOneWidget);
        expect(find.text('25.00 MB of temporary installers'), findsOneWidget);
        expect(find.text('Delete Cache'), findsOneWidget);
      },
    );
  });
}
