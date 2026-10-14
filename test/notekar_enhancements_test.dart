import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/daily_wrapup_sheet.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/search_index_service.dart';
import 'package:notekar/utils/tag_service.dart';
import 'package:notekar/widgets/feedback_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TagService.instance.resetForTesting();
  });

  group('Hashtags Synchronization & Search Filter Fix (User Item 9)', () {
    test('getUsedTags strictly returns tags present in active moments', () {
      final moments = [
        Moment(
          id: 1,
          type: 'single',
          date: '2026-10-14',
          timestamp: 1000,
          note: 'Working on project #vod and #deepfocus',
          tags: ['vod', 'deepfocus'],
        ),
        Moment(
          id: 2,
          type: 'single',
          date: '2026-10-14',
          timestamp: 2000,
          note: 'Evening #reading session',
          tags: ['reading'],
        ),
      ];

      final usedTags = TagService.instance.getUsedTags(moments);
      expect(usedTags, contains('#vod'));
      expect(usedTags, contains('#deepfocus'));
      expect(usedTags, contains('#reading'));
      // #victory is not in any moment, so it MUST NOT be returned
      expect(usedTags.contains('#victory'), isFalse);
    });

    test(
      'pruneUnusedTags removes orphaned custom tags and recent tags when edited from #victory to #vod',
      () async {
        // 1. Simulate initial creation where #victory was added as custom tag and #vod as recent
        await TagService.instance.addCustomTag('#victory');
        await TagService.instance.recordUsage('#temp_tag');

        expect(TagService.instance.customTags, contains('#victory'));
        expect(TagService.instance.recentTags, contains('#temp_tag'));

        // 2. User edits the note: #victory is replaced with #vod
        final activeMoments = [
          Moment(
            id: 1,
            type: 'single',
            date: '2026-10-14',
            timestamp: 1000,
            note: 'Updated note with #vod',
            tags: ['vod'],
          ),
        ];

        // 3. Prune unused tags
        final removedCount = await TagService.instance.pruneUnusedTags(
          activeMoments,
        );
        expect(removedCount, greaterThan(0));

        // 4. Verify #victory and #temp_tag are completely removed from cache and search filter
        expect(TagService.instance.customTags.contains('#victory'), isFalse);
        expect(TagService.instance.recentTags.contains('#temp_tag'), isFalse);

        // Filter pills for search only return active tags
        final searchPills = TagService.instance.getUsedTags(activeMoments);
        expect(searchPills, contains('#vod'));
        expect(searchPills.contains('#victory'), isFalse);
      },
    );

    test('SearchIndexService unindexes old hashtags upon moment update', () {
      final indexService = SearchIndexService.instance;
      indexService.clear();

      final initialMoment = Moment(
        id: 101,
        type: 'single',
        date: '2026-10-14',
        timestamp: 1000,
        note: 'First draft with #victory',
        tags: ['victory'],
      );

      indexService.buildIndex([initialMoment]);
      expect(indexService.getAllKnownTags(), contains('#victory'));

      // Now edit: unindex old moment and index updated moment with #vod
      indexService.unindexMoment(101);
      final updatedMoment = Moment(
        id: 101,
        type: 'single',
        date: '2026-10-14',
        timestamp: 1000,
        note: 'Updated draft with #vod',
        tags: ['vod'],
      );
      indexService.indexMoment(updatedMoment);

      final currentTags = indexService.getAllKnownTags();
      expect(currentTags, contains('#vod'));
      expect(currentTags.contains('#victory'), isFalse);
    });
  });

  group('Live Session Persistent Undo (User Item 8)', () {
    testWidgets(
      'UndoToast does not auto-dismiss when persistent is true in active live session',
      (tester) async {
        bool dismissed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UndoToast(
                p: paletteFor('dark'),
                onUndo: () {},
                token: 42,
                message: 'Live session active',
                persistent: true,
                onDismiss: () {
                  dismissed = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Live session active'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        // Advance simulated time past standard 4.5s
        await tester.pump(const Duration(seconds: 10));
        expect(dismissed, isFalse);
      },
    );

    testWidgets(
      'UndoToast auto-dismisses after 4.5s countdown when persistent is false',
      (tester) async {
        bool dismissed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UndoToast(
                p: paletteFor('dark'),
                onUndo: () {},
                token: 43,
                message: 'Standard moment',
                persistent: false,
                onDismiss: () {
                  dismissed = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Standard moment'), findsOneWidget);
        // Advance time past 4.5s countdown
        await tester.pump(const Duration(milliseconds: 4600));
        expect(dismissed, isTrue);
      },
    );
  });

  group('Dedicated Daily Wrap-up Page & Seal Day (User Item 7)', () {
    testWidgets(
      'DailyWrapupPage renders with Apple HIG header and seal button',
      (tester) async {
        final moments = [
          Moment(
            id: 1,
            type: 'single',
            date: '2026-10-14',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            note: 'Completed deep work',
            category: 'Deep Work',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: DailyWrapupPage(
              p: paletteFor('dark'),
              moments: moments,
              isSessionOngoing: false,
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Daily Wrap-up'), findsOneWidget);
        expect(find.text('Wrap Up & Seal Day'), findsOneWidget);
      },
    );
  });
}
