import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/dialogs/settings/app_icons_settings_page.dart';
import 'package:notekar/models/palette.dart';
import 'package:notekar/widgets/settings_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('accent picker previews the selected color on a narrow screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var selectedAccent = 'blue';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (context, setState) => ColorChoiceSetting(
                p: paletteFor('dark', accentName: selectedAccent),
                value: selectedAccent,
                onChanged: (value) => setState(() => selectedAccent = value),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live preview'), findsOneWidget);
    await tester.tap(find.byTooltip('coral'));
    await tester.pumpAndSettle();

    expect(selectedAccent, 'coral');
    expect(tester.takeException(), isNull);
  });

  testWidgets('app icon choices are labeled, adaptive, and selectable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var selectedStyle = 'default';

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) => AppIconsSettingsPage(
                  p: paletteFor('dark'),
                  appIconStyle: selectedStyle,
                  onAppIconStyleChanged: (value) async {
                    if (value == 'red') return false;
                    setState(() => selectedStyle = value);
                    return true;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Midnight'), findsOneWidget);
    await tester.tap(find.text('Midnight'));
    await tester.pumpAndSettle();

    expect(selectedStyle, 'black');
    await tester.tap(find.text('Crimson'));
    await tester.pumpAndSettle();
    expect(selectedStyle, 'black');
    expect(tester.takeException(), isNull);
  });
}
