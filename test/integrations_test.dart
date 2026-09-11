import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/data_backup_settings_page.dart';
import 'package:notekar/dialogs/settings/integrations_settings_page.dart';
import 'package:notekar/models/moment.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/calendar_sync_service.dart';
import 'package:notekar/utils/markdown_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('System Bridges & App Integrations Tests', () {
    test(
      'MarkdownSyncService formats daily moments into structured Markdown table',
      () {
        const service = MarkdownSyncService();
        final now = DateTime(2026, 8, 30, 10, 30);
        final moments = [
          Moment(
            id: 1,
            timestamp: now.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-08-30',
            note: 'Deep Work: Backend API',
          ),
          Moment(
            id: 2,
            timestamp: now.add(const Duration(hours: 2)).millisecondsSinceEpoch,
            type: 'out',
            date: '2026-08-30',
            note: 'Completed API integration',
          ),
          Moment(
            id: 3,
            timestamp: now.add(const Duration(hours: 3)).millisecondsSinceEpoch,
            type: 'single',
            date: '2026-08-30',
            note: 'Quick coffee chat',
          ),
        ];

        final markdown = service.generateMarkdown(moments);

        expect(markdown.contains('# NoteKar Journal'), isTrue);
        expect(markdown.contains('📅 Sunday, August 30, 2026'), isTrue);
        expect(markdown.contains('| Time | Type | Details / Note |'), isTrue);
        expect(markdown.contains('🟢 **IN**'), isTrue);
        expect(markdown.contains('🔴 **OUT**'), isTrue);
        expect(markdown.contains('⚡ **SINGLE**'), isTrue);
        expect(markdown.contains('Deep Work: Backend API'), isTrue);
        expect(markdown.contains('Total Moments**: 3'), isTrue);
      },
    );

    test(
      'CalendarSyncService pairs Two-Way intervals into RFC 5545 VEVENTs',
      () {
        const service = CalendarSyncService();
        final now = DateTime.utc(2026, 8, 30, 9, 0);
        final moments = [
          Moment(
            id: 10,
            timestamp: now.millisecondsSinceEpoch,
            type: 'in',
            date: '2026-08-30',
            note: 'Design Review',
          ),
          Moment(
            id: 11,
            timestamp: now
                .add(const Duration(hours: 1, minutes: 30))
                .millisecondsSinceEpoch,
            type: 'out',
            date: '2026-08-30',
            note: 'Approved PRs',
          ),
        ];

        final ics = service.generateICalendar(moments);

        expect(ics.startsWith('BEGIN:VCALENDAR'), isTrue);
        expect(ics.contains('VERSION:2.0'), isTrue);
        expect(ics.contains('BEGIN:VEVENT'), isTrue);
        expect(ics.contains('SUMMARY:⏳ Design Review'), isTrue);
        expect(ics.contains('Two-Way Tracked Interval: 1h 30m'), isTrue);
        expect(ics.contains('DTSTART:20260830T090000Z'), isTrue);
        expect(ics.contains('DTEND:20260830T103000Z'), isTrue);
        expect(ics.trimRight().endsWith('END:VCALENDAR'), isTrue);
      },
    );

    testWidgets(
      'IntegrationsSettingsPage renders all bridge categories and handles URL scheme tap',
      (tester) async {
        final p = paletteFor('dark');
        final entriesNotifier = ValueNotifier<List<Moment>>([
          Moment(
            id: 1,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            type: 'single',
            date: '2026-08-30',
            note: 'Test moment',
          ),
        ]);

        String? triggeredScheme;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: IntegrationsSettingsPage(
                  p: p,
                  entriesNotifier: entriesNotifier,
                  onTriggerUrlScheme: (url) {
                    triggeredScheme = url;
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('URL SCHEMES'), findsOneWidget);
        expect(find.text('Quick Log'), findsOneWidget);
        expect(
          find.text(
            'notekar://log?type=single&note=Coffee',
            findRichText: true,
          ),
          findsOneWidget,
        );
        expect(find.text('Check-In & Out'), findsOneWidget);
        expect(
          find.text('notekar://in?note=Focus%20Session', findRichText: true),
          findsOneWidget,
        );
        expect(find.text('SYSTEM BRIDGES'), findsOneWidget);
        expect(find.text('Text Selection Menu'), findsOneWidget);
        expect(find.text('Share Target'), findsOneWidget);
        expect(find.text('AUTOMATION BROADCAST API'), findsOneWidget);
        expect(find.text('Log Moment Intent'), findsOneWidget);
        expect(
          find.text(
            'app.notekar.notekar.ACTION_LOG_MOMENT',
            findRichText: true,
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Quick Log'));
        await tester.pump();

        expect(triggeredScheme, 'notekar://log?type=single&note=Quick%20Log');
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'DataBackupSettingsPage renders Markdown Journal and Calendar export sections under Backup & Export',
      (tester) async {
        final p = paletteFor('dark');
        bool exportedMarkdown = false;
        bool exportedCalendar = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: DataBackupSettingsPage(
                  p: p,
                  subCategory: 'Backup & Export',
                  entriesCount: 10,
                  dataHealthStatus: '100% Healthy',
                  backupReminderDays: 7,
                  onBackupReminderDaysChanged: (_) {},
                  onExportCsv: () {},
                  onExportRecentCsv: () {},
                  onExportJson: () {},
                  onExportMarkdown: () => exportedMarkdown = true,
                  onExportCalendar: () => exportedCalendar = true,
                  onExportBackup: () {},
                  onImportBackup: () {},
                  onRestoreBackupFromString: (_) async => true,
                  onSaveQuickBackup: () {},
                  onOpenCategory: (_, {required parent}) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('MARKDOWN JOURNAL'), findsOneWidget);
        expect(find.text('Export Journal (.md)'), findsOneWidget);
        expect(find.text('CALENDAR SESSIONS'), findsOneWidget);
        expect(find.text('Export Calendar (.ics)'), findsOneWidget);

        final journalBtn = find.text('Export Journal (.md)');
        await tester.ensureVisible(journalBtn);
        await tester.pumpAndSettle();
        await tester.tap(journalBtn);
        await tester.pump();
        expect(exportedMarkdown, isTrue);

        final calendarBtn = find.text('Export Calendar (.ics)');
        await tester.ensureVisible(calendarBtn);
        await tester.pumpAndSettle();
        await tester.tap(calendarBtn);
        await tester.pump();
        expect(exportedCalendar, isTrue);
      },
    );
  });
}
