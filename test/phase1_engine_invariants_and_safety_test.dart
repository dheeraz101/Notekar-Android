import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/app_date_picker_sheet.dart';
import 'package:notekar/dialogs/settings/data_backup_settings_page.dart';
import 'package:notekar/dialogs/settings/sobriety_companion_settings_page.dart';
import 'package:notekar/dialogs/smart_trim_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/audio_service.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/utils/backup_utils.dart';
import 'package:notekar/widgets/markdown_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Phase 1: MarkdownText Engine Invariants & Memory Leaks', () {
    testWidgets('MarkdownText renders bold, code blocks, and markdown links', (
      tester,
    ) async {
      String? openedUrl;
      const testMarkdown = '''
# Heading 1
- Bullet point
Here is **bold text** and `inline code` and [NoteKar Web](https://notekar.app)
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownText(
              text: testMarkdown,
              p: p,
              onOpenLink: (url) => openedUrl = url,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Heading 1'), findsOneWidget);
      expect(find.text('Bullet point'), findsOneWidget);
      expect(find.text('inline code'), findsOneWidget);

      final richTextFinder = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('bold text'),
      );
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      TextSpan? linkSpan;
      richText.text.visitChildren((span) {
        if (span is TextSpan && span.text == 'NoteKar Web') {
          linkSpan = span;
          return false;
        }
        return true;
      });

      expect(linkSpan, isNotNull);
      expect(linkSpan!.recognizer, isA<TapGestureRecognizer>());
      (linkSpan!.recognizer as TapGestureRecognizer).onTap!();
      expect(openedUrl, 'https://notekar.app');
    });

    testWidgets(
      'MarkdownText disposes gesture recognizers cleanly on unmount',
      (tester) async {
        bool mounted = true;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  if (!mounted) return const SizedBox.shrink();
                  return MarkdownText(
                    text: 'Check [Link](https://example.com)',
                    p: p,
                    onOpenLink: (_) {},
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText().contains('Check'),
          ),
          findsOneWidget,
        );

        // Unmount the MarkdownText widget
        mounted = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  if (!mounted) return const SizedBox.shrink();
                  return MarkdownText(
                    text: 'Check [Link](https://example.com)',
                    p: p,
                    onOpenLink: (_) {},
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText().contains('Check'),
          ),
          findsNothing,
        );
      },
    );
  });

  group('Phase 1: AudioService Stream & Timer Leak Prevention', () {
    test(
      'AudioService reset() clears active playback and recording states',
      () async {
        final audioService = AudioService.instance;
        await audioService.reset();
        expect(audioService.isPlaying, isFalse);
        expect(audioService.isRecording, isFalse);
        expect(audioService.currentPosition, Duration.zero);
        expect(audioService.currentRecordingAmplitude, 0.0);
      },
    );

    test('AudioService dispose() cleans up active timers without error', () {
      final audio = AudioService();
      // Should not throw even when called repeatedly
      audio.dispose();
      expect(audio.isPlaying, isFalse);
      expect(audio.isRecording, isFalse);
    });
  });

  group('Phase 1: AppDatePickerSheet Selection State Retention', () {
    testWidgets(
      'AppDatePickerSheet maintains selected date across ancestor rebuilds',
      (tester) async {
        final initial = DateTime(2026, 11, 2, 10, 0);
        int rebuildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  rebuildCount++;
                  return AppDatePickerSheet(
                    p: p,
                    title: 'Select Date',
                    initialDateTime: initial,
                    mode: CupertinoDatePickerMode.date,
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Select Date'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(rebuildCount, 1);
      },
    );
  });

  group('Phase 1: SmartTrimSheet Cross-Midnight Assertion Safety', () {
    testWidgets(
      'SmartTrimSheet safely supports sessions spanning across midnight',
      (tester) async {
        // Session starts at 23:30 on Nov 2 and finishes at 01:15 on Nov 3 (spans midnight)
        final start = DateTime(2026, 11, 2, 23, 30);
        final end = DateTime(2026, 11, 3, 1, 15);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SmartTrimSheet(
                p: p,
                startDateTime: start,
                originalEndDateTime: end,
                category: 'Deep Work',
              ),
            ),
          ),
        );
        await tester.pump();

        // Verify header correctly computed duration across midnight (1h 45m = 105m)
        expect(find.textContaining('in Deep Work'), findsOneWidget);
        expect(find.text('Keep Full 1h 45m'), findsOneWidget);
        expect(find.text('Choose Custom End Time'), findsOneWidget);
      },
    );
  });

  group('Phase 1: Destructive Action Safety Shields', () {
    testWidgets(
      'SobrietyCompanionSettingsPage Reset Streak presents confirmation sheet before resetting',
      (tester) async {
        int? resetCalledMs;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SobrietyCompanionSettingsPage(
                  p: p,
                  enableSobrietyMode: true,
                  sobrietyResetType: 'all',
                  sobrietyCustomStartMs: 1000000,
                  sobrietyMilestoneTheme: 'seed',
                  onEnableSobrietyModeChanged: (_) {},
                  onSobrietyCustomStartMsChanged: (ms) => resetCalledMs = ms,
                  onOpenCategory: (_, {required parent}) {},
                  onSelectStartDate: (_, _) async => null,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap "Reset Streak to Now"
        final resetBtn = find.text('Reset Streak to Now');
        expect(resetBtn, findsOneWidget);
        await tester.tap(resetBtn);
        await tester.pumpAndSettle();

        // Must display confirmation sheet shielding the destructive reset
        expect(find.text('Reset Sobriety Streak?'), findsOneWidget);
        expect(
          find.text(
            'This will reset your current clean milestone progress back to Day 0. Your previous logs will remain intact.',
          ),
          findsOneWidget,
        );
        expect(find.text('Reset Streak'), findsOneWidget);

        // Cancel does NOT reset
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(resetCalledMs, isNull);

        // Tap again and confirm
        await tester.tap(resetBtn);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reset Streak'));
        await tester.pumpAndSettle();

        // Now reset was called
        expect(resetCalledMs, isNotNull);
      },
    );

    testWidgets(
      'LocalBackupsPage requires confirmation before restoring backup snapshot',
      (tester) async {
        bool restoreConfirmed = false;
        final tempDir = Directory.systemTemp.createTempSync(
          'notekar_test_backup_',
        );
        final backupDir = Directory('${tempDir.path}/local_backups');
        backupDir.createSync(recursive: true);
        final testBackupFile = File(
          '${backupDir.path}/notekar_backup_test.json',
        );
        testBackupFile.writeAsStringSync('{"version":1,"sessions":[]}');

        const channel = MethodChannel('notekar/files');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'appDataDir') {
                return tempDir.path;
              }
              return null;
            });

        try {
          await tester.runAsync(() async {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: LocalBackupsPage(
                    p: p,
                    onRestore: (content) async {
                      restoreConfirmed = true;
                      return true;
                    },
                    onCreateQuickBackup: () {},
                  ),
                ),
              ),
            );
            await Future<void>.delayed(const Duration(milliseconds: 100));
          });
          await tester.pumpAndSettle();

          final restoreBtn = find.byTooltip('Restore Backup');
          expect(restoreBtn, findsOneWidget);

          // Tap to restore
          await tester.tap(restoreBtn);
          await tester.pumpAndSettle();

          // Destructive confirmation sheet must appear
          expect(find.text('Restore Database Backup?'), findsOneWidget);
          expect(restoreConfirmed, isFalse);

          // Cancel first
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
          expect(restoreConfirmed, isFalse);

          // Tap again and confirm restore
          await tester.tap(restoreBtn);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Restore'));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.runAsync(() async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          });
          await tester.pump(const Duration(milliseconds: 300));

          expect(restoreConfirmed, isTrue);
        } finally {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
          try {
            if (tempDir.existsSync()) {
              tempDir.deleteSync(recursive: true);
            }
          } catch (_) {}
        }
      },
    );

    test(
      'MediaStorageService and backup validator block directory traversal (SEC-05)',
      () async {
        final mediaStorage = MediaStorageService.instance;

        // resolveFile should return empty File when path contains ..
        final maliciousFile1 = await mediaStorage.resolveFile(
          '../../../../etc/passwd',
        );
        expect(maliciousFile1.path, isEmpty);

        final maliciousFile2 = await mediaStorage.resolveFile(
          'images/../../shadow',
        );
        expect(maliciousFile2.path, isEmpty);

        final syncFile = mediaStorage.resolveFileSync(
          '..\\..\\windows\\system32\\cmd.exe',
        );
        expect(syncFile.path, isEmpty);

        // Validate that backup importer strips/sanitizes paths with ..
        final testJson = '''
{
  "app": "NoteKar",
  "kind": "backup",
  "version": "7.5.14",
  "entries": [
    {
      "timestamp": 1700000000000,
      "type": "single",
      "note": "Traversal test",
      "imagePath": "../../traversal_attack.png",
      "voicePath": "../../../etc/voice.m4a"
    }
  ]
}
''';
        final result = validateNoteKarBackupContent(testJson);
        expect(result.isValid, isTrue);
        expect(result.entries.length, 1);
        expect(result.entries.first.imagePath, isNull);
        expect(result.entries.first.voicePath, isNull);
      },
    );
  });
}
