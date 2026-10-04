import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/search_index_service.dart';
import 'package:notekar/utils/dashboard_metrics_service.dart';
import 'package:notekar/utils/life_audit_service.dart';
import 'package:notekar/utils/moment_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const palette = Palette(
    name: 'dark',
    bg: Colors.black,
    surface: Colors.black,
    surface2: Colors.black,
    surface3: Colors.black,
    border: Colors.white,
    text: Colors.white,
    text2: Colors.grey,
    text3: Colors.grey,
    clock: Colors.white,
    accent: Colors.blue,
    green: Colors.green,
    orange: Colors.orange,
    red: Colors.red,
    blue: Colors.blue,
  );

  group('Under-The-Hood Upgrades: SearchIndexService Tests', () {
    setUp(() {
      SearchIndexService.instance.clear();
    });

    test('Indexes moments and matches tokens accurately', () {
      final m1 = Moment(
        id: 1,
        timestamp: 1000,
        type: 'single',
        date: '2026-10-04',
        note: 'Completed deep work on flutter architecture #deepwork',
        category: 'Work',
      );
      final m2 = Moment(
        id: 2,
        timestamp: 2000,
        type: 'single',
        date: '2026-10-04',
        note: 'Running in the park with friends #health #fitness',
        category: 'Health',
      );

      SearchIndexService.instance.buildIndex([m1, m2]);
      expect(SearchIndexService.instance.isIndexed, isTrue);

      // Search token 'flutter'
      final matches = SearchIndexService.instance.search(
        allMoments: [m1, m2],
        query: 'flutter',
      );
      expect(matches.length, 1);
      expect(matches.first.id, 1);

      // Search token 'running'
      final matches2 = SearchIndexService.instance.search(
        allMoments: [m1, m2],
        query: 'running',
      );
      expect(matches2.length, 1);
      expect(matches2.first.id, 2);

      // Search token matching both
      final matchesAll = SearchIndexService.instance.search(
        allMoments: [m1, m2],
        query: '',
      );
      expect(matchesAll.length, 2);
    });

    test('Hashtag index and autocomplete work in O(1)/O(K)', () {
      final m1 = Moment(
        id: 1,
        timestamp: 1000,
        type: 'single',
        date: '2026-10-04',
        note: 'Sprint planning #deepwork #planning',
      );
      final m2 = Moment(
        id: 2,
        timestamp: 2000,
        type: 'single',
        date: '2026-10-04',
        note: 'Evening cardio #fitness #deeprest',
      );

      SearchIndexService.instance.buildIndex([m1, m2]);

      final allTags = SearchIndexService.instance.getAllKnownTags();
      expect(allTags, containsAll(['#deepwork', '#planning', '#fitness', '#deeprest']));

      // Tag suggestions with prefix 'deep'
      final deepSuggestions = SearchIndexService.instance.suggestTags('deep');
      expect(deepSuggestions, containsAll(['#deeprest', '#deepwork']));
      expect(deepSuggestions, isNot(contains('#fitness')));

      // Filter search by hashtag
      final filtered = SearchIndexService.instance.search(
        allMoments: [m1, m2],
        query: '',
        hashtag: '#planning',
      );
      expect(filtered.length, 1);
      expect(filtered.first.id, 1);
    });

    test('Incremental index and unindex on CRUD operations', () {
      final m1 = Moment(
        id: 1,
        timestamp: 1000,
        type: 'single',
        date: '2026-10-04',
        note: 'Initial note #meeting',
      );

      SearchIndexService.instance.buildIndex([m1]);
      expect(SearchIndexService.instance.getAllKnownTags(), contains('#meeting'));

      // Update moment
      final updatedM1 = m1.copyWith(note: 'Updated note #conference');
      SearchIndexService.instance.indexMoment(updatedM1);

      final searchConference = SearchIndexService.instance.search(
        allMoments: [updatedM1],
        query: 'conference',
      );
      expect(searchConference.length, 1);

      // Unindex
      SearchIndexService.instance.unindexMoment(1);
      final searchAfterDelete = SearchIndexService.instance.search(
        allMoments: [],
        query: 'conference',
      );
      expect(searchAfterDelete, isEmpty);
    });
  });

  group('Under-The-Hood Upgrades: Concurrency Engine (Isolate Offloading)', () {
    test('LifeAuditService.calculateAsync returns consistent summary', () async {
      final now = DateTime(2026, 10, 4, 12, 0);
      final entries = List.generate(
        120,
        (i) => Moment(
          id: i + 1,
          timestamp: now.subtract(Duration(hours: i * 2)).millisecondsSinceEpoch,
          type: 'single',
          date: '2026-10-04',
          note: 'Log $i',
        ),
      );

      final syncSummary = LifeAuditService.calculate(
        entries: entries,
        timeframe: LifeAuditTimeframe.week,
        referenceNow: now,
      );

      final asyncSummary = await LifeAuditService.calculateAsync(
        entries: entries,
        timeframe: LifeAuditTimeframe.week,
        referenceNow: now,
      );

      expect(asyncSummary.daysCount, syncSummary.daysCount);
      expect(asyncSummary.consciousHoursPerDay, syncSummary.consciousHoursPerDay);
      expect(asyncSummary.totalTrackedDuration, syncSummary.totalTrackedDuration);
      expect(asyncSummary.dailyRecords.length, syncSummary.dailyRecords.length);
    });

    test('DashboardMetricsService.calculateAsync returns consistent data', () async {
      final now = DateTime(2026, 10, 4, 12, 0);
      final entries = List.generate(
        100,
        (i) => Moment(
          id: i + 1,
          timestamp: now.subtract(Duration(hours: i * 3)).millisecondsSinceEpoch,
          type: i % 2 == 0 ? 'in' : 'out',
          date: '2026-10-04',
          note: 'Session $i #focus',
          category: 'Work',
        ),
      );

      final syncData = DashboardMetricsService.calculate(
        entries: entries,
        timeframe: DashboardTimeframe.week,
        p: palette,
      );

      final asyncData = await DashboardMetricsService.calculateAsync(
        entries: entries,
        timeframe: DashboardTimeframe.week,
        p: palette,
      );

      expect(asyncData.timeframe, syncData.timeframe);
      expect(asyncData.totalMoments, syncData.totalMoments);
      expect(asyncData.dailyRhythm.days.length, syncData.dailyRhythm.days.length);
    });
  });

  group('Under-The-Hood Upgrades: MomentRepository Indexed Queries', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('notekar_test_repo_');
      Hive.init(tempDir.path);
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('getMomentsBetween performs binary range slicing on sorted moments', () async {
      final repo = MomentRepository();
      await repo.ensureInitialized();

      // Save moments at different timestamps
      final m1 = Moment(id: 1, timestamp: 1000, type: 'single', date: '2026-10-04', note: 'One');
      final m2 = Moment(id: 2, timestamp: 2000, type: 'single', date: '2026-10-04', note: 'Two');
      final m3 = Moment(id: 3, timestamp: 3000, type: 'single', date: '2026-10-04', note: 'Three');
      final m4 = Moment(id: 4, timestamp: 4000, type: 'single', date: '2026-10-04', note: 'Four');

      await repo.saveMoment(m1);
      await repo.saveMoment(m2);
      await repo.saveMoment(m3);
      await repo.saveMoment(m4);

      // Query range [2000, 3000]
      final range = repo.getMomentsBetween(2000, 3000);
      expect(range.length, 2);
      expect(range.map((m) => m.id), containsAll([2, 3]));

      // Direct O(1) ID lookup
      expect(repo.getMomentById(3)?.note, 'Three');
      expect(repo.getMomentById(99), isNull);

      // Perform maintenance
      await repo.performDailyMaintenance();
    });
  });
}
