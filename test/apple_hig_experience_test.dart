import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/targets_projects_settings_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/theme/app_tokens.dart';
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

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'floating_timer_enabled': true,
      'floating_single_tap_action': 'toggle_expand',
      'floating_double_tap_action': 'quick_menu',
    });
  });

  group('Apple HIG Typography & Design System Tokens', () {
    test(
      'NkTypography conforms to Apple SF Pro font size and negative tracking specs',
      () {
        const typo = NkTokens.typography;
        const color = Colors.white;

        final largeTitle = typo.largeTitle(color);
        expect(largeTitle.fontSize, 34);
        expect(largeTitle.fontWeight, FontWeight.w800);
        expect(largeTitle.letterSpacing, -1.3);

        final title1 = typo.title1(color);
        expect(title1.fontSize, 28);
        expect(title1.fontWeight, FontWeight.w700);
        expect(title1.letterSpacing, -0.8);

        final title2 = typo.title2(color);
        expect(title2.fontSize, 22);
        expect(title2.fontWeight, FontWeight.w700);
        expect(title2.letterSpacing, -0.6);

        final title3 = typo.title3(color);
        expect(title3.fontSize, 20);
        expect(title3.fontWeight, FontWeight.w600);
        expect(title3.letterSpacing, -0.5);

        final headline = typo.headline(color);
        expect(headline.fontSize, 17);
        expect(headline.fontWeight, FontWeight.w600);
        expect(headline.letterSpacing, -0.4);

        final body = typo.body(color);
        expect(body.fontSize, 17);
        expect(body.fontWeight, FontWeight.w400);
        expect(body.letterSpacing, -0.3);

        final callout = typo.callout(color);
        expect(callout.fontSize, 16);
        expect(callout.fontWeight, FontWeight.w400);
        expect(callout.letterSpacing, -0.3);

        final subheadline = typo.subheadline(color);
        expect(subheadline.fontSize, 15);
        expect(subheadline.fontWeight, FontWeight.w400);
        expect(subheadline.letterSpacing, -0.2);

        final footnote = typo.footnote(color);
        expect(footnote.fontSize, 13);
        expect(footnote.fontWeight, FontWeight.w400);
        expect(footnote.letterSpacing, -0.1);

        final caption = typo.caption(color);
        expect(caption.fontSize, 12);
        expect(caption.fontWeight, FontWeight.w500);
        expect(caption.letterSpacing, 0.0);

        final caption2 = typo.caption2(color);
        expect(caption2.fontSize, 11);
        expect(caption2.fontWeight, FontWeight.w500);
        expect(caption2.letterSpacing, 0.0);
      },
    );

    test('NkRadii provides squircle continuous curvature tokens', () {
      const radii = NkTokens.radii;

      expect(radii.squircleCardVal, 24.0);
      expect(radii.squircleSheetVal, 28.0);

      expect(radii.squircleCard, BorderRadius.circular(24.0));
      expect(radii.squircleSheet, BorderRadius.circular(28.0));

      final cardBorder = radii.squircleCardBorder();
      expect(cardBorder, isA<RoundedRectangleBorder>());
      expect(
        (cardBorder as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(24.0),
      );

      final sheetBorder = radii.squircleSheetBorder();
      expect(sheetBorder, isA<RoundedRectangleBorder>());
      expect(
        (sheetBorder as RoundedRectangleBorder).borderRadius,
        const BorderRadius.vertical(top: Radius.circular(28.0)),
      );
    });
  });

  group('Always-On Floating Control Pill UI Integration', () {
    testWidgets(
      'TargetsProjectsSettingsPage displays updated Floating Control Pill title and assistive subtitle',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TargetsProjectsSettingsPage(p: testPalette)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Floating Control Pill'), findsOneWidget);
        expect(
          find.textContaining(
            'Always-on floating control pill like iOS AssistiveTouch',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
