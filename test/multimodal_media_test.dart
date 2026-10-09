import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/widgets/timeline_media_attachment_card.dart';
import 'package:notekar/widgets/timeline_voice_player_pill.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Multimodal Moment Model Tests', () {
    test('Moment initializes with media fields and serializes to JSON', () {
      final moment = Moment(
        id: 101,
        timestamp: 1775000000000,
        type: 'single',
        date: '2026-04-01',
        note: 'Exploring multimodal logging #art',
        tags: const ['art'],
        imagePath: 'images/img_test_123.jpg',
        voicePath: 'voice/voice_test_123.m4a',
        voiceDurationMs: 45000,
      );

      expect(moment.imagePath, 'images/img_test_123.jpg');
      expect(moment.voicePath, 'voice/voice_test_123.m4a');
      expect(moment.voiceDurationMs, 45000);

      final json = moment.toJson();
      expect(json['imagePath'], 'images/img_test_123.jpg');
      expect(json['voicePath'], 'voice/voice_test_123.m4a');
      expect(json['voiceDurationMs'], 45000);

      final restored = Moment.fromJson(json);
      expect(restored.id, 101);
      expect(restored.imagePath, 'images/img_test_123.jpg');
      expect(restored.voicePath, 'voice/voice_test_123.m4a');
      expect(restored.voiceDurationMs, 45000);
    });

    test('Moment.copyWith handles explicit clearing of attachments', () {
      final moment = Moment(
        id: 102,
        timestamp: 1775000000000,
        type: 'single',
        date: '2026-04-01',
        note: 'Note with media',
        imagePath: 'images/img_1.jpg',
        voicePath: 'voice/voice_1.m4a',
        voiceDurationMs: 12000,
      );

      final updatedWithCleared = moment.copyWith(
        clearImagePath: true,
        clearVoicePath: true,
      );

      expect(updatedWithCleared.imagePath, isNull);
      expect(updatedWithCleared.voicePath, isNull);

      final updatedWithNewImage = moment.copyWith(
        imagePath: 'images/img_2.jpg',
      );
      expect(updatedWithNewImage.imagePath, 'images/img_2.jpg');
      expect(updatedWithNewImage.voicePath, 'voice/voice_1.m4a');
    });

    test('NoteResult carries multimodal properties', () {
      const result = NoteResult(
        'Multimodal capture',
        ['note'],
        imagePath: 'images/preview.jpg',
        voicePath: 'voice/audio.m4a',
        voiceDurationMs: 30000,
      );

      expect(result.note, 'Multimodal capture');
      expect(result.imagePath, 'images/preview.jpg');
      expect(result.voicePath, 'voice/audio.m4a');
      expect(result.voiceDurationMs, 30000);
    });
  });

  group('MediaStorageService Tests', () {
    test('resolveFileSync correctly constructs sandboxed target path', () {
      final service = MediaStorageService.instance;
      service.testRootPath = '/mock/app/data';
      final file = service.resolveFileSync('images/img_test.jpg');
      expect(
        file.path.replaceAll('\\', '/'),
        '/mock/app/data/notekar_media/images/img_test.jpg',
      );
    });

    test('formatBytes produces readable metrics', () {
      final service = MediaStorageService.instance;
      expect(service.formatBytes(512), '512 B');
      expect(service.formatBytes(2048), '2.0 KB');
      expect(service.formatBytes(1048576 * 3), '3.0 MB');
    });
  });

  group('TimelineMediaAttachmentCard Widget Tests', () {
    testWidgets(
      'Renders collapsed 34dp preview strip and triggers onToggleCollapse',
      (tester) async {
        bool toggleCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimelineMediaAttachmentCard(
                p: p,
                imagePath: 'images/test_image.jpg',
                isCollapsed: true,
                onToggleCollapse: () {
                  toggleCalled = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Photo attached'), findsOneWidget);
        expect(find.text('Tap to expand'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.chevron_down), findsOneWidget);

        await tester.tap(find.text('Photo attached'));
        await tester.pump();

        expect(toggleCalled, isTrue);
      },
    );

    testWidgets('Renders expanded photo card with collapse action', (
      tester,
    ) async {
      final tempDir = Directory.systemTemp.createTempSync();
      final imagesDir = Directory('${tempDir.path}/notekar_media/images')
        ..createSync(recursive: true);
      File('${imagesDir.path}/img_test.jpg').writeAsBytesSync([0, 1, 2]);
      MediaStorageService.instance.testRootPath = tempDir.path;

      bool collapseCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineMediaAttachmentCard(
              p: p,
              imagePath: 'images/img_test.jpg',
              isCollapsed: false,
              onToggleCollapse: () {
                collapseCalled = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Collapse'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chevron_up), findsOneWidget);

      await tester.tap(find.text('Collapse'));
      await tester.pump();

      expect(collapseCalled, isTrue);
    });
  });

  group('TimelineVoicePlayerPill Widget Tests', () {
    testWidgets('Renders voice player pill with ticker and controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimelineVoicePlayerPill(
              p: p,
              voicePath: 'voice/sample_test.m4a',
              durationMs: 75000, // 1m 15s
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(CupertinoIcons.play_fill), findsOneWidget);
      expect(find.text('0:00 / 1:15'), findsOneWidget);
      expect(find.text('1.0x'), findsOneWidget);

      // Tap speed control cycle
      await tester.tap(find.text('1.0x'));
      await tester.pump();

      expect(find.text('1.5x'), findsOneWidget);
    });
  });
}
