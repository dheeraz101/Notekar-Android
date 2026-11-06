import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/services/universal_interval_ledger.dart';
import 'package:notekar/utils/dashboard_metrics_service.dart';
import 'package:notekar/widgets/history_analytics_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  group('Phase 5: Functional Intelligence & Analytics Tests', () {
    test(
      'UniversalIntervalLedger.computeTimeSlotBias handles empty intervals',
      () {
        final dist = UniversalIntervalLedger.computeTimeSlotBias([]);
        expect(dist.totalMs, 0);
        expect(dist.peakSlot, 'None');
        expect(dist.morningPct, 0);
        expect(dist.afternoonPct, 0);
        expect(dist.eveningPct, 0);
        expect(dist.nightPct, 0);
      },
    );

    test(
      'UniversalIntervalLedger.computeTimeSlotBias correctly splits multi-hour session across Morning and Afternoon',
      () {
        // May 10, 2026: 10:00 to 14:00 (2h Morning: 10-12, 2h Afternoon: 12-14)
        final start = DateTime(2026, 5, 10, 10, 0).millisecondsSinceEpoch;
        final end = DateTime(2026, 5, 10, 14, 0).millisecondsSinceEpoch;

        final intervals = [
          CanonicalInterval(
            id: 'sess_1',
            startMs: start,
            endMs: end,
            dateKey: '2026-05-10',
            category: 'DeepWork',
            isSession: true,
          ),
        ];

        final dist = UniversalIntervalLedger.computeTimeSlotBias(intervals);
        expect(dist.totalMs, 4 * 3600 * 1000);
        expect(dist.morningMs, 2 * 3600 * 1000);
        expect(dist.afternoonMs, 2 * 3600 * 1000);
        expect(dist.eveningMs, 0);
        expect(dist.nightMs, 0);
        expect(dist.morningPct, 50);
        expect(dist.afternoonPct, 50);
      },
    );

    test(
      'DashboardMetricsService computes duration-weighted time-slot bias from sessions',
      () {
        // 3-hour evening session: 18:00 to 21:00
        final inTs = DateTime(2026, 5, 10, 18, 0).millisecondsSinceEpoch;
        final outTs = DateTime(2026, 5, 10, 21, 0).millisecondsSinceEpoch;

        final entries = [
          Moment(
            id: 1,
            type: 'in',
            timestamp: inTs,
            date: '2026-05-10',
            category: 'Study',
            tags: const [],
          ),
          Moment(
            id: 2,
            type: 'out',
            timestamp: outTs,
            date: '2026-05-10',
            category: 'Study',
            tags: const [],
          ),
        ];

        final data = DashboardMetricsService.calculate(
          entries: entries,
          timeframe: DashboardTimeframe.all,
          p: p,
        );

        expect(data.timeSlotBias.peakSlotName, 'Evening');
        final eveningSlot = data.timeSlotBias.slots.firstWhere(
          (s) => s.name == 'Evening',
        );
        expect(eveningSlot.isPeak, isTrue);
        expect(eveningSlot.percentage, 100);
      },
    );

    testWidgets(
      'ActivityHeatmapCard renders with CustomPaint RepaintBoundary without exploding widget tree',
      (tester) async {
        final now = DateTime.now();
        final entries = List.generate(
          15,
          (i) => Moment(
            id: i + 1,
            type: 'single',
            timestamp: now
                .subtract(Duration(days: i * 3))
                .millisecondsSinceEpoch,
            date: '2026-05-01',
            category: 'General',
            tags: const [],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ActivityHeatmapCard(p: p, entries: entries),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Activity Heatmap'), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
        expect(find.byType(RepaintBoundary), findsWidgets);
      },
    );
  });
}
