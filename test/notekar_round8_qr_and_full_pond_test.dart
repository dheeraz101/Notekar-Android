import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/peer_comparison_sheet.dart';
import 'package:notekar/dialogs/peer_profile_detail_sheet.dart';
import 'package:notekar/dialogs/settings/app_icons_settings_page.dart';
import 'package:notekar/dialogs/settings/personalization_settings_page.dart';
import 'package:notekar/dialogs/settings/update_center_page.dart';
import 'package:notekar/dialogs/shareable_profile_card_sheet.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/models/peer_profile.dart';
import 'package:notekar/services/peer_profile_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPalette = Palette(
    name: 'dark',
    bg: const Color(0xFF000000),
    surface: const Color(0xFF1C1C1E),
    surface2: const Color(0xFF2C2C2E),
    surface3: const Color(0xFF3A3A3C),
    border: const Color(0xFF38383A),
    text: const Color(0xFFFFFFFF),
    text2: const Color(0xFFEBEBF5),
    text3: const Color(0xFF8E8E93),
    clock: const Color(0xFFFFFFFF),
    accent: const Color(0xFF007AFF),
    green: const Color(0xFF34C759),
    orange: const Color(0xFFFF9500),
    red: const Color(0xFFFF3B30),
    blue: const Color(0xFF007AFF),
  );

  group('Round 8: Peer Profile Model & Single-Peer Service', () {
    test('PeerProfile encodes and decodes QR payload cleanly', () {
      const samplePeer = PeerProfile(
        name: 'Aria Stark',
        dob: '1998-04-15',
        targetYears: 85,
        ageYears: 26.5,
        lifeClockFormatted: '07:22 AM',
        lifeClockTimeOfDay: 'Morning Awakening',
        remainingWeeks: 3068,
        livedPercentage: 0.305,
        timestamp: 1761379200000,
      );

      final qrPayload = samplePeer.toQrPayload();
      expect(qrPayload, startsWith('notekar://peer?'));

      final parsed = PeerProfile.fromQrPayload(qrPayload);
      expect(parsed, isNotNull);
      expect(parsed!.name, equals('Aria Stark'));
      expect(parsed.targetYears, equals(85));
      expect(parsed.ageYears, closeTo(26.5, 0.1));
      expect(parsed.lifeClockFormatted, equals('07:22 AM'));
      expect(parsed.lifeClockTimeOfDay, equals('Morning Awakening'));
      expect(parsed.remainingWeeks, equals(3068));
      expect(parsed.livedPercentage, closeTo(0.305, 0.001));
    });

    test('PeerProfile parses JSON payload fallback', () {
      final jsonMap = {
        'name': 'Bran',
        'dob': '2000-01-01',
        'target': 90,
        'age': 26.0,
        'clock': '06:55 AM',
        'phase': 'Dawn',
        'weeks': 3328,
        'lived': 0.288,
        'ts': 1761379200000,
      };

      final parsed = PeerProfile.fromQrPayload(jsonEncode(jsonMap));
      expect(parsed, isNotNull);
      expect(parsed!.name, equals('Bran'));
      expect(parsed.ageYears, closeTo(26.0, 0.1));
    });

    test('PeerProfile handles corrupt payload gracefully', () {
      expect(PeerProfile.fromQrPayload('notekar://unknown?foo=bar'), isNull);
      expect(PeerProfile.fromQrPayload('gibberish text'), isNull);
      expect(PeerProfile.fromQrPayload(''), isNull);
    });

    test(
      'PeerProfileService enforces single-peer persistence and replacement',
      () async {
        SharedPreferences.setMockInitialValues({});
        final service = PeerProfileService.instance;

        final peerA = const PeerProfile(
          name: 'User Alpha',
          dob: '1995-01-01',
          targetYears: 80,
          ageYears: 31.0,
          lifeClockFormatted: '09:18 AM',
          lifeClockTimeOfDay: 'Morning Momentum',
          remainingWeeks: 2548,
          livedPercentage: 0.387,
          timestamp: 1000,
        );

        await service.savePeerProfile(peerA);
        final loadedA = await service.getSavedPeerProfile();
        expect(loadedA, isNotNull);
        expect(loadedA?.name, equals('User Alpha'));

        // Replacing with User Beta
        final peerB = const PeerProfile(
          name: 'User Beta',
          dob: '2002-06-20',
          targetYears: 95,
          ageYears: 24.0,
          lifeClockFormatted: '06:05 AM',
          lifeClockTimeOfDay: 'Dawn Rising',
          remainingWeeks: 3692,
          livedPercentage: 0.252,
          timestamp: 2000,
        );

        await service.savePeerProfile(peerB);
        final loadedB = await service.getSavedPeerProfile();
        expect(loadedB, isNotNull);
        expect(loadedB?.name, equals('User Beta'));

        // Clear peer
        await service.clearPeerProfile();
        final loadedCleared = await service.getSavedPeerProfile();
        expect(loadedCleared, isNull);
      },
    );
  });

  group('Round 8: Shareable Profile Card Sheet QR Pass', () {
    testWidgets('Renders QR pass and eliminates morning pill overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ShareableProfileCardSheet(p: testPalette)),
        ),
      );

      await tester.pumpAndSettle();

      // Verify QR Code is present
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('TEMPORAL HORIZON PASS'), findsOneWidget);
      expect(find.text('OFFLINE PASS'), findsOneWidget);
    });
  });

  group('Round 8: Accent Color Full-Width Pond Sanctuary & Royal Crown', () {
    testWidgets('PersonalizationSettingsPage renders full pond and top texts', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonalizationSettingsPage(
              p: testPalette,
              subCategory: 'Accent Color',
              theme: 'dark',
              accentColor: 'blue',
              appIconStyle: 'default',
              currentLocale: 'en',
              reduceMotion: false,
              enableTranslucency: true,
              onLocaleChanged: (_) {},
              onAccentColorChanged: (_) {},
              onOpenCategory: (_, {String? parent}) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 400));

      // Verify top header & refined texts
      expect(find.text('Liquid Accent Sanctuary'), findsOneWidget);
      expect(find.text('TAP ANY FISH TO HARMONIZE ACCENT'), findsOneWidget);
      expect(find.text('20 Living Species'), findsOneWidget);
      expect(
        find.textContaining('Riverbed stones retain their fixed hues'),
        findsOneWidget,
      );
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('Round 8: App Icon Page Instruction Header', () {
    testWidgets(
      'AppIconsSettingsPage shows instructions and available icon count',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppIconsSettingsPage(
                p: testPalette,
                appIconStyle: 'default',
                onAppIconStyleChanged: (_) async => true,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('CHOOSE APP ICON'), findsOneWidget);
        expect(find.textContaining('Icons Available'), findsOneWidget);
      },
    );
  });

  group('Round 8: Update Center Bottom Description', () {
    testWidgets('UpdateCenterView places formal description at bottom', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UpdateCenterView(
                p: testPalette,
                appVersion: '7.5.7',
                enableTranslucency: true,
                reduceMotion: false,
                onOpenLink: (_) {},
                onCheckUpdates: () {},
                checkingUpdates: false,
                updateStatus: 'Up to date',
                currentBuildChannel: 'stable',
                onLearnMoreBeta: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'Update Center provides verified, sovereign software releases',
        ),
        findsOneWidget,
      );
    });
  });

  group('Round 8: Peer Profile Detail Sheet', () {
    testWidgets('Renders scanned peer temporal profile details', (
      tester,
    ) async {
      const peer = PeerProfile(
        name: 'Rowan',
        dob: '1997-05-12',
        targetYears: 85,
        ageYears: 29.0,
        lifeClockFormatted: '08:12 AM',
        lifeClockTimeOfDay: 'Morning Momentum',
        remainingWeeks: 2912,
        livedPercentage: 0.341,
        timestamp: 123456,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PeerProfileDetailSheet(p: testPalette, peer: peer),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Peer Horizon Pass'), findsOneWidget);
      expect(find.text('VERIFIED HORIZON PASS'), findsOneWidget);
      expect(find.text('Rowan'), findsOneWidget);
      expect(find.text('Compare'), findsOneWidget);
    });
  });

  group('Round 8: Peer Comparison Sheet', () {
    testWidgets('Renders comparison between self and peer', (tester) async {
      SharedPreferences.setMockInitialValues({});
      const peer = PeerProfile(
        name: 'Jordan',
        dob: '1996-03-10',
        targetYears: 85,
        ageYears: 30.0,
        lifeClockFormatted: '08:28 AM',
        lifeClockTimeOfDay: 'Morning Momentum',
        remainingWeeks: 2860,
        livedPercentage: 0.352,
        timestamp: 123456,
      );

      await PeerProfileService.instance.savePeerProfile(peer);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PeerComparisonSheet(p: testPalette, peer: peer),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Horizon Comparison'), findsOneWidget);
      expect(find.text('Jordan'), findsWidgets);
      expect(find.text('Remove Peer'), findsOneWidget);
    });
  });
}
