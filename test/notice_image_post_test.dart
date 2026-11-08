import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/app_notice.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/media_storage_service.dart';
import 'package:notekar/utils/notice_service.dart';
import 'package:notekar/widgets/notice_image_post_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Minimal 1x1 valid PNG image bytes
final Uint8List kTestPngBytes = Uint8List.fromList([
  137,
  80,
  78,
  71,
  13,
  10,
  26,
  10,
  0,
  0,
  0,
  13,
  73,
  72,
  68,
  82,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  1,
  8,
  6,
  0,
  0,
  0,
  31,
  21,
  196,
  137,
  0,
  0,
  0,
  10,
  73,
  68,
  65,
  84,
  120,
  156,
  99,
  0,
  1,
  0,
  0,
  5,
  0,
  1,
  13,
  10,
  45,
  180,
  0,
  0,
  0,
  0,
  73,
  69,
  78,
  68,
  174,
  66,
  96,
  130,
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppNotice Image Post Model & Aspect Ratio Tests', () {
    test('AppNotice correctly parses imageUrl, aspectRatio, and caption', () {
      final json = {
        'id': 'notice-img-1',
        'enabled': true,
        'title': 'Release Poster',
        'body': 'Check out the new visual release poster.',
        'image_url': 'https://github.com/dheeraz101/notekar/poster.png',
        'aspect_ratio': '16:9',
        'image_caption': 'High-definition preview',
      };

      final notice = AppNotice.fromJson(json);
      expect(notice.isImagePost, isTrue);
      expect(
        notice.imageUrl,
        'https://github.com/dheeraz101/notekar/poster.png',
      );
      expect(notice.aspectRatio, '16:9');
      expect(notice.imageCaption, 'High-definition preview');
      expect(notice.numericAspectRatio, closeTo(16.0 / 9.0, 0.001));

      final serialized = notice.toJson();
      expect(
        serialized['image_url'],
        'https://github.com/dheeraz101/notekar/poster.png',
      );
      expect(serialized['aspect_ratio'], '16:9');
      expect(serialized['image_caption'], 'High-definition preview');
    });

    test(
      'numericAspectRatio correctly parses 9:16 portrait and 16:9 landscape',
      () {
        final portraitNotice = AppNotice.fromJson({
          'id': 'p1',
          'title': 'Portrait Story',
          'body': 'Portrait notice',
          'imageUrl': 'https://github.com/img.jpg',
          'aspectRatio': '9:16',
        });
        expect(portraitNotice.numericAspectRatio, closeTo(9.0 / 16.0, 0.001));

        final landscapeNotice = AppNotice.fromJson({
          'id': 'l1',
          'title': 'Landscape Banner',
          'body': 'Landscape notice',
          'img': 'https://github.com/banner.jpg',
          'aspect_ratio': '16:9',
        });
        expect(landscapeNotice.numericAspectRatio, closeTo(16.0 / 9.0, 0.001));

        final squareNotice = AppNotice.fromJson({
          'id': 's1',
          'title': 'Square',
          'body': 'Square notice',
          'image': 'https://github.com/sq.png',
          'aspectRatio': '1:1',
        });
        expect(squareNotice.numericAspectRatio, closeTo(1.0, 0.001));

        final customRatioNotice = AppNotice.fromJson({
          'id': 'c1',
          'title': 'Custom',
          'body': 'Custom ratio',
          'imageUrl': 'https://github.com/custom.png',
          'aspectRatio': '4/3',
        });
        expect(customRatioNotice.numericAspectRatio, closeTo(4.0 / 3.0, 0.001));

        final noImageNotice = AppNotice.fromJson({
          'id': 'n1',
          'title': 'Text Only',
          'body': 'No image attached',
        });
        expect(noImageNotice.isImagePost, isFalse);
        expect(noImageNotice.numericAspectRatio, isNull);
      },
    );
  });

  group('NoticeService Image Notice Query Tests', () {
    test('NoticeService defaultNotices includes visual bulletin notice', () {
      final visualBulletin = NoticeService.defaultNotices.firstWhere(
        (n) => n['id'] == 'notekar-visual-bulletin-notice',
      );
      expect(visualBulletin, isNotNull);
      expect(visualBulletin['image_url'], isNotEmpty);
      expect(visualBulletin['aspect_ratio'], '16:9');
      expect(visualBulletin['title'], contains('Visual Bulletin'));
    });

    test(
      'getImageNotices and getLatestImageNotice filter image posts correctly',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final data = [
          {
            'enabled': true,
            'id': 'text-only',
            'title': 'Text Only Notice',
            'body': 'Just some text',
            'channels': ['stable', 'beta'],
            'platforms': ['android'],
          },
          {
            'enabled': true,
            'id': 'img-announcement-1',
            'title': 'Feature Poster',
            'body': 'Visual poster body',
            'image_url': 'https://github.com/poster.png',
            'aspect_ratio': '9:16',
            'channels': ['stable', 'beta'],
            'platforms': ['android'],
          },
        ];
        await prefs.setString('cached_app_notices', jsonEncode(data));

        final imageNotices = await NoticeService.instance.getImageNotices();
        expect(imageNotices.any((n) => n.id == 'img-announcement-1'), isTrue);
        expect(
          imageNotices.any((n) => n.id == 'notekar-visual-bulletin-notice'),
          isTrue,
        );
        expect(imageNotices.first.isImagePost, isTrue);

        final latest = await NoticeService.instance.getLatestImageNotice();
        expect(latest, isNotNull);
        expect(latest!.isImagePost, isTrue);
      },
    );

    test('notice_image/notice.json file exists and is valid', () {
      final file = File('notice_image/notice.json');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      final dynamic parsed = jsonDecode(content);
      expect(parsed, isA<List<dynamic>>());
      final list = parsed as List<dynamic>;
      expect(list.isNotEmpty, isTrue);
      final diwaliNoticeMap = list.firstWhere(
        (e) => e['id'] == 'diwali_2026',
        orElse: () => null,
      );
      expect(diwaliNoticeMap, isNotNull);
      final notice = AppNotice.fromJson(
        Map<String, dynamic>.from(diwaliNoticeMap as Map),
      );
      expect(notice.id, 'diwali_2026');
      expect(notice.title, 'Notice');
      expect(notice.aspectRatio, '16:9');
      expect(notice.numericAspectRatio, closeTo(16.0 / 9.0, 0.001));
      expect(
        notice.imageUrl,
        'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/main/notice_image/happy_diwali.jpg',
      );
      expect(notice.isImagePost, isTrue);
    });

    test('NoticeService defaultNotices includes diwali_2026 notice', () {
      final diwaliNotice = NoticeService.defaultNotices.firstWhere(
        (n) => n['id'] == 'diwali_2026',
        orElse: () => {},
      );
      expect(diwaliNotice, isNotEmpty);
      expect(diwaliNotice['aspect_ratio'], '16:9');
      expect(
        diwaliNotice['image_url'],
        'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/main/notice_image/happy_diwali.jpg',
      );
    });
  });

  group('MediaStorageService Gallery Save Tests', () {
    test(
      'saveImageToGallery saves bytes to persistent storage with fallback',
      () async {
        final tempDir = Directory.systemTemp.createTempSync('gallery_test_');
        MediaStorageService.instance.testRootPath = tempDir.path;

        final savedPath = await MediaStorageService.instance.saveImageToGallery(
          bytes: kTestPngBytes,
          fileName: 'test_notice_poster.png',
          mimeType: 'image/png',
        );

        expect(savedPath, isNotNull);
        final file = File(savedPath!);
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), kTestPngBytes.length);

        // Clean up
        tempDir.deleteSync(recursive: true);
        MediaStorageService.instance.testRootPath = null;
      },
    );
  });

  group('NoticeImagePostDialog Full-Screen Apple HIG UI Tests', () {
    testWidgets(
      'Renders full-screen Notice viewer with Notice title, Cupertino close button, and Save button',
      (tester) async {
        final notice = AppNotice.fromJson({
          'id': 'visual-test-1',
          'title': 'Apple HIG Visual Notice',
          'body': 'A full-screen preview experience with smooth fit.',
          'image_url': 'https://github.com/notice.png',
          'aspect_ratio': '16:9',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoticeImagePostDialog(
                p: p,
                notice: notice,
                initialBytes: kTestPngBytes,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Top bar title "Notice"
        expect(find.text('Notice'), findsOneWidget);
        // Top Cupertino close ('X') button
        expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);
        // Caption card with title and body
        expect(find.text('Apple HIG Visual Notice'), findsOneWidget);
        expect(
          find.text('A full-screen preview experience with smooth fit.'),
          findsOneWidget,
        );
        // Bottom "Save to Gallery" action button
        expect(find.text('Save to Gallery'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.arrow_down_to_line), findsOneWidget);
      },
    );

    testWidgets('Renders 9:16 portrait aspect ratio properly', (tester) async {
      final notice = AppNotice.fromJson({
        'id': 'portrait-test',
        'title': 'Portrait 9:16 Notice',
        'body': 'Portrait aspect ratio notice',
        'image_url': 'https://github.com/portrait.png',
        'aspect_ratio': '9:16',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoticeImagePostDialog(
              p: p,
              notice: notice,
              initialBytes: kTestPngBytes,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final aspectRatioWidget = tester.widget<AspectRatio>(
        find.byType(AspectRatio),
      );
      expect(aspectRatioWidget.aspectRatio, closeTo(9.0 / 16.0, 0.001));
    });

    testWidgets(
      'Tapping Save to Gallery saves image and displays Saved to Gallery confirmation',
      (tester) async {
        const channel = MethodChannel('notekar/files');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'saveImageToGallery') {
                return 'content://media/external/images/media/1234';
              }
              return null;
            });

        final notice = AppNotice.fromJson({
          'id': 'save-tap-test',
          'title': 'Savable Notice',
          'body': 'Tap save to store into gallery',
          'image_url': 'https://github.com/save.png',
          'aspect_ratio': '16:9',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoticeImagePostDialog(
                p: p,
                notice: notice,
                initialBytes: kTestPngBytes,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap "Save to Gallery"
        final saveBtn = find.text('Save to Gallery');
        expect(saveBtn, findsOneWidget);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        // Verify "Saved to Gallery" confirmation pill appears with checkmark
        expect(find.text('Saved to Gallery'), findsWidgets);
        expect(
          find.byIcon(CupertinoIcons.checkmark_circle_fill),
          findsOneWidget,
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      },
    );

    testWidgets(
      'Renders friendly error card with retry button when image fails to load',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoticeImagePostDialog(
                p: p,
                imageUrl: '', // empty url triggers error
                title: 'Notice',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Unable to load notice image'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(
          find.byIcon(CupertinoIcons.wifi_exclamationmark),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cupertino close button dismisses dialog when presented via show()',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => NoticeImagePostDialog.show(
                      ctx,
                      p: p,
                      initialBytes: kTestPngBytes,
                      title: 'Notice',
                    ),
                    child: const Text('Open Notice'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Tap to open dialog
        await tester.tap(find.text('Open Notice'));
        await tester.pumpAndSettle();

        expect(find.text('Notice'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);

        // Tap close button
        await tester.tap(find.byIcon(CupertinoIcons.xmark));
        await tester.pumpAndSettle();

        // Dialog is dismissed
        expect(find.byIcon(CupertinoIcons.xmark), findsNothing);
        expect(find.text('Open Notice'), findsOneWidget);
      },
    );

    testWidgets(
      'Loads notice image from local bundled/workspace file when network URL is used',
      (tester) async {
        final notice = AppNotice.fromJson({
          'id': 'diwali_2026',
          'title': 'Notice',
          'body': 'Wishing you and your loved ones a Happy Diwali!',
          'image_url':
              'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/main/notice_image/happy_diwali.jpg',
          'aspect_ratio': '16:9',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoticeImagePostDialog(p: p, notice: notice),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Title and caption card
        expect(find.text('Notice'), findsWidgets);
        expect(
          find.text('Wishing you and your loved ones a Happy Diwali!'),
          findsOneWidget,
        );
        // Image widget is rendered
        expect(find.byType(Image), findsOneWidget);
        expect(find.text('Save to Gallery'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Save to Gallery saves image loaded via local fallback and displays Saved confirmation',
      (tester) async {
        const channel = MethodChannel('notekar/files');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'saveImageToGallery') {
                return 'content://media/external/images/media/9999';
              }
              return null;
            });

        final notice = AppNotice.fromJson({
          'id': 'diwali_2026',
          'title': 'Notice',
          'body': 'Wishing you and your loved ones a Happy Diwali!',
          'image_url':
              'https://raw.githubusercontent.com/dheeraz101/Notekar-Android/main/notice_image/happy_diwali.jpg',
          'aspect_ratio': '16:9',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NoticeImagePostDialog(p: p, notice: notice),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap Save to Gallery
        final saveBtn = find.text('Save to Gallery');
        expect(saveBtn, findsOneWidget);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        // Verify Saved to Gallery confirmation pill appears
        expect(find.text('Saved to Gallery'), findsWidgets);
        expect(
          find.byIcon(CupertinoIcons.checkmark_circle_fill),
          findsOneWidget,
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      },
    );
  });
}
