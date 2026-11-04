import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/app_permissions_settings_page.dart';
import 'package:notekar/dialogs/settings/content_rating_settings_page.dart';
import 'package:notekar/dialogs/settings/help_guides_settings_page.dart';
import 'package:notekar/dialogs/settings/privacy_security_settings_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/settings_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final p = paletteFor('dark');

  group('1. Data Safety & Disclosures Page Tests', () {
    testWidgets(
      'DataSafetySettingsPage renders Google Play safety breakdown and rows',
      (tester) async {
        String? openedCat;
        String? openedParent;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: DataSafetySettingsPage(
                  p: p,
                  vtRatio: '0/72',
                  vtStatus: 'Clean',
                  vtScanDate: '2026-10-30',
                  vtUrl: 'https://virustotal.com',
                  privacyLock: true,
                  obfuscateInRecents: false,
                  onObfuscateInRecentsChanged: (_) {},
                  onOpenCategory: (cat, {required parent}) {
                    openedCat = cat;
                    openedParent = parent;
                  },
                ),
              ),
            ),
          ),
        );

        // Verify Google Play breakdown
        expect(find.text('DATA SAFETY SOVEREIGNTY'), findsOneWidget);
        expect(find.text('Google Play & Store Disclosures'), findsOneWidget);
        expect(find.text('100% On-Device'), findsOneWidget);
        expect(find.text('0 KB (None)'), findsOneWidget);
        expect(find.text('Local Isar Encrypted'), findsOneWidget);

        // Verify Sub-routes: App Permissions and Content Rating
        expect(find.text('App Permissions'), findsOneWidget);
        expect(find.text('Content Rating'), findsOneWidget);

        // Tap App Permissions
        await tester.tap(find.text('App Permissions'));
        await tester.pump();
        expect(openedCat, 'App Permissions');
        expect(openedParent, 'Data safety');

        // Tap Content Rating
        await tester.tap(find.text('Content Rating'));
        await tester.pump();
        expect(openedCat, 'Content Rating');
        expect(openedParent, 'Data safety');

        // Verify alias
        expect(PrivacySecuritySettingsPage, equals(DataSafetySettingsPage));
      },
    );
  });

  group('2. Content Rating Page Tests', () {
    testWidgets(
      'ContentRatingSettingsPage displays official 3+ badge, authority grid, and 0/5 scorecard',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ContentRatingSettingsPage(p: p),
              ),
            ),
          ),
        );

        // Header
        expect(find.text('GLOBAL CONTENT RATING'), findsOneWidget);
        expect(find.text('Rated for Everyone / Age 3+'), findsOneWidget);
        expect(find.text('3+'), findsOneWidget);

        // Global Authorities
        expect(find.text('IARC'), findsOneWidget);
        expect(find.text('ESRB'), findsOneWidget);
        expect(find.text('PEGI'), findsOneWidget);
        expect(find.text('USK'), findsOneWidget);

        // Scorecard
        expect(find.text('Violence & Gore'), findsOneWidget);
        expect(find.text('Sexual Content & Nudity'), findsOneWidget);
        expect(find.text('Profanity & Crude Humor'), findsOneWidget);
        expect(find.text('Drugs, Alcohol & Tobacco'), findsOneWidget);
        expect(find.text('Gambling & Simulated Betting'), findsOneWidget);
        expect(find.text('None'), findsNWidgets(8));

        // Interactive Elements
        expect(find.text('User-Generated Content'), findsOneWidget);
        expect(find.text('100% Offline'), findsOneWidget);
        expect(find.text('In-App Purchases'), findsOneWidget);
        expect(find.text('Third-Party Ad SDKs'), findsOneWidget);
      },
    );
  });

  group('3. App Permissions Dashboard Tests', () {
    testWidgets(
      'AppPermissionsSettingsPage renders all 7 permission rows and system action button',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppPermissionsSettingsPage(p: p),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Header
        expect(find.text('DEVICE CAPABILITIES'), findsOneWidget);
        expect(find.text('App Permissions'), findsOneWidget);

        // Permissions Rows
        expect(find.text('Microphone'), findsOneWidget);
        expect(find.text('RECORD_AUDIO'), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('CAMERA'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('POST_NOTIFICATIONS'), findsOneWidget);
        expect(find.text('Display Over Other Apps'), findsOneWidget);
        expect(find.text('SYSTEM_ALERT_WINDOW'), findsOneWidget);
        expect(find.text('Alarms & Reminders'), findsOneWidget);
        expect(find.text('SCHEDULE_EXACT_ALARM'), findsOneWidget);
        expect(find.text('Battery Optimization Exemption'), findsOneWidget);
        expect(
          find.text('REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'),
          findsOneWidget,
        );
        expect(find.text('Usage Access'), findsOneWidget);
        expect(find.text('PACKAGE_USAGE_STATS'), findsOneWidget);

        // System Settings Button
        expect(find.text('Open System App Settings'), findsOneWidget);

        // Verify Status Pill Styling: Not Granted uses red and xmark_circle_fill
        expect(find.text('Not Granted'), findsNWidgets(7));
        expect(find.byIcon(CupertinoIcons.xmark_circle_fill), findsNWidgets(7));

        // Verify Semantics coverage for permission tag accessibility
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == 'REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
          ),
          findsOneWidget,
        );

        // Verify Title Typography (fontSize 15, weight w700)
        final micText = tester.widget<Text>(find.text('Microphone'));
        expect(micText.style?.fontSize, 15);
        expect(micText.style?.fontWeight, FontWeight.w700);
      },
    );

    testWidgets(
      'AppPermissionsSettingsPage renders cleanly on ultra-narrow 320dp screen without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AppPermissionsSettingsPage(p: p),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('REQUEST_IGNORE_BATTERY_OPTIMIZATIONS'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ContentRatingSettingsPage and DataSafetySettingsPage render cleanly on 320dp screen',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ContentRatingSettingsPage(p: p),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        FlutterErrorDetails? caughtDetails;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          caughtDetails = details;
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: DataSafetySettingsPage(
                  p: p,
                  vtRatio: '0/72',
                  vtStatus: 'Clean',
                  vtScanDate: '2026-10-30',
                  vtUrl: 'https://virustotal.com',
                  privacyLock: true,
                  obfuscateInRecents: false,
                  onObfuscateInRecentsChanged: (_) {},
                  onOpenCategory: (_, {required parent}) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        FlutterError.onError = originalOnError;
        expect(caughtDetails, isNull);
      },
    );
  });

  group('4. Layout Alignment and About Page Deduplication Tests', () {
    testWidgets(
      'DataSafetySettingsPage hero card matches width of SettingsGroup cards',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: DataSafetySettingsPage(
                    p: p,
                    vtRatio: '0/72',
                    vtStatus: 'Clean',
                    vtScanDate: '2026-10-30',
                    vtUrl: 'https://virustotal.com',
                    privacyLock: true,
                    obfuscateInRecents: false,
                    onObfuscateInRecentsChanged: (_) {},
                    onOpenCategory: (_, {required parent}) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The hero container containing 'DATA SAFETY SOVEREIGNTY'
        final heroFinder = find
            .ancestor(
              of: find.text('DATA SAFETY SOVEREIGNTY'),
              matching: find.byType(Container),
            )
            .first;
        final heroSize = tester.getSize(heroFinder);

        // The SettingsGroup container
        final settingsGroupFinder = find.byType(SettingsGroup).first;
        final settingsGroupSize = tester.getSize(settingsGroupFinder);

        // Hero card width should equal SettingsGroup width (no 16px horizontal inset)
        expect(heroSize.width, equals(400.0));
        expect(settingsGroupSize.width, equals(400.0));
        expect(heroSize.width, equals(settingsGroupSize.width));
      },
    );

    testWidgets(
      'HelpGuidesSettingsPage has no duplicate Data Safety, Content Rating, App Permissions rows',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HelpGuidesSettingsPage(
                  p: p,
                  onOpenCategory: (_, {required parent}) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Legal rows that SHOULD exist
        expect(find.text('Licenses'), findsOneWidget);
        expect(find.text('Terms of Use'), findsOneWidget);
        expect(find.text('Privacy Policy'), findsOneWidget);

        // Duplicate rows that SHOULD NOT exist in About / Help & Guides
        expect(find.text('Data safety'), findsNothing);
        expect(find.text('Content Rating'), findsNothing);
        expect(find.text('App Permissions'), findsNothing);
      },
    );
  });
}
