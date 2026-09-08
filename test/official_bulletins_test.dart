import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/official_bulletins_sheet.dart';
import 'package:notekar/models/app_notice.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/utils/notice_service.dart';
import 'package:notekar/widgets/settings_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final p = paletteFor('dark');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NoticeService Bulletins & Advisories', () {
    test(
      'defaultNotices contains life-ledger-calibration-advisory in all 7 languages',
      () {
        final notice = NoticeService.defaultNotices.firstWhere(
          (n) => n['id'] == 'life-ledger-calibration-advisory',
        );
        expect(notice, isNotNull);
        expect(notice['title'], contains('Life Ledger'));
        expect(notice['title_es'], isNotEmpty);
        expect(notice['title_hi'], isNotEmpty);
        expect(notice['title_de'], isNotEmpty);
        expect(notice['title_fr'], isNotEmpty);
        expect(notice['title_ja'], isNotEmpty);
        expect(notice['title_ru'], isNotEmpty);
        expect(notice['body'], contains('uncalibrated void hours'));
        expect(notice['body_es'], isNotEmpty);
        expect(notice['body_hi'], isNotEmpty);
        expect(notice['body_de'], isNotEmpty);
        expect(notice['body_fr'], isNotEmpty);
        expect(notice['body_ja'], isNotEmpty);
        expect(notice['body_ru'], isNotEmpty);
        expect(notice['minVersion'], '7.0.0');
        expect(notice['maxVersion'], '7.5.0');
        expect(notice['priority'], 'normal');
      },
    );

    test(
      'getCachedNotices falls back to defaultNotices when cache is empty',
      () async {
        final notices = await NoticeService.instance.getCachedNotices();
        expect(notices, isNotEmpty);
        final hasAdvisory = notices.any(
          (n) => n.id == 'life-ledger-calibration-advisory',
        );
        expect(hasAdvisory, isTrue);
      },
    );

    test(
      'recovers gracefully from corrupted SharedPreferences cache',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'cached_app_notices',
          '{invalid json or not a list',
        );

        final notices = await NoticeService.instance.getCachedNotices();
        expect(notices, isNotEmpty);
        expect(
          notices.any((n) => n.id == 'life-ledger-calibration-advisory'),
          isTrue,
        );
      },
    );

    test('AppNotice correctly parses and categorizes all priority types', () {
      final critical = AppNotice.fromJson({
        'id': '1',
        'title': 'Crit',
        'body': 'b',
        'priority': 'critical',
      });
      expect(critical.isCritical, isTrue);
      expect(critical.badgeLabel, 'CRITICAL');

      final urgent = AppNotice.fromJson({
        'id': '2',
        'title': 'Urg',
        'body': 'b',
        'priority': 'urgent',
      });
      expect(urgent.isCritical, isTrue);
      expect(urgent.badgeLabel, 'CRITICAL');

      final security = AppNotice.fromJson({
        'id': '3',
        'title': 'Sec',
        'body': 'b',
        'priority': 'security',
      });
      expect(security.isSecurity, isTrue);
      expect(security.badgeLabel, 'SECURITY');

      final cve = AppNotice.fromJson({
        'id': '4',
        'title': 'CVE',
        'body': 'b',
        'priority': 'cve',
      });
      expect(cve.isSecurity, isTrue);
      expect(cve.badgeLabel, 'SECURITY');

      final release = AppNotice.fromJson({
        'id': '5',
        'title': 'Rel',
        'body': 'b',
        'priority': 'release',
      });
      expect(release.isReleaseBulletin, isTrue);
      expect(release.badgeLabel, 'BULLETIN');

      final tip = AppNotice.fromJson({
        'id': '6',
        'title': 'Tip',
        'body': 'b',
        'priority': 'tip',
      });
      expect(tip.isCuratedTip, isTrue);
      expect(tip.badgeLabel, 'TIP');

      final unknown = AppNotice.fromJson({
        'id': '7',
        'title': 'Unk',
        'body': 'b',
        'priority': 'something_else',
      });
      expect(unknown.isReleaseBulletin, isTrue);
      expect(unknown.badgeLabel, 'BULLETIN');
    });

    test('AppNotice correctly checks expiry and schedule dates', () {
      final expired = AppNotice.fromJson({
        'id': 'exp',
        'title': 'Expired',
        'body': 'b',
        'expiresAt': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      });
      expect(expired.isExpired, isTrue);

      final futureNotice = AppNotice.fromJson({
        'id': 'fut',
        'title': 'Future',
        'body': 'b',
        'startsAt': DateTime.now()
            .add(const Duration(days: 2))
            .toIso8601String(),
      });
      expect(futureNotice.isScheduledToStart, isFalse);
    });
  });

  group('OfficialBulletins UI Tests', () {
    testWidgets(
      'Renders Life Ledger advisory and has no green or yellow dot when notice engine active',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: OfficialBulletinsContent(p: p, onOpenLink: (_) {}),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Verify "Notice Engine Active" text is displayed
        expect(find.text('Notice Engine Active'), findsOneWidget);

        // 2. Verify NO green or orange/yellow circle dot is rendered in the status pill
        final decoratedContainers = tester.widgetList<Container>(
          find.byType(Container),
        );
        final hasStatusDot = decoratedContainers.any((c) {
          final dec = c.decoration;
          if (dec is BoxDecoration && dec.shape == BoxShape.circle) {
            return dec.color == p.green || dec.color == p.orange;
          }
          return false;
        });
        expect(hasStatusDot, isFalse);

        // 3. Verify Life Ledger advisory card is rendered
        expect(
          find.text('Advisory: Life Ledger History Calibration'),
          findsOneWidget,
        );
        expect(find.textContaining('uncalibrated void hours'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders Security Advisories section when security notices are present',
      (tester) async {
        final prefs = await SharedPreferences.getInstance();
        final securityData = [
          {
            'enabled': true,
            'id': 'sec-notice-test',
            'title': 'Test Security Patch',
            'body': 'Fixed a local cryptographic salt issue.',
            'priority': 'security',
            'channels': ['stable', 'beta'],
            'platforms': ['android'],
          },
        ];
        await prefs.setString('cached_app_notices', jsonEncode(securityData));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: OfficialBulletinsContent(p: p, onOpenLink: (_) {}),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('SECURITY ADVISORIES'), findsOneWidget);
        expect(find.text('Test Security Patch'), findsOneWidget);
        expect(find.text('SECURITY'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders standard SettingsBetaNote on OfficialBulletinsContent and triggers callback',
      (tester) async {
        bool betaClicked = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: OfficialBulletinsContent(
                  p: p,
                  onOpenLink: (_) {},
                  onLearnMoreBeta: () => betaClicked = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final betaFinder = find.byType(SettingsBetaNote);
        await tester.scrollUntilVisible(
          betaFinder,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        expect(betaFinder, findsOneWidget);
        expect(
          find.textContaining('active development and continuous refinement'),
          findsOneWidget,
        );
        expect(find.textContaining('Learn More'), findsOneWidget);

        final betaWidget = tester.widget<SettingsBetaNote>(betaFinder);
        betaWidget.onLearnMore?.call();
        await tester.pumpAndSettle();
        expect(betaClicked, isTrue);
      },
    );
  });
}
