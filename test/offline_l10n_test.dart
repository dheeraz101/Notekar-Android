import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notekar/l10n/app_localizations.dart';
import 'package:notekar/l10n/l10n_data.dart';
import 'package:notekar/utils/l10n_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Multilingual Localization Tests', () {
    test(
      'contains full offline translation dictionaries for all 6 languages',
      () {
        final supportedCodes = ['fr', 'es', 'hi', 'de', 'ja', 'ru'];
        for (final code in supportedCodes) {
          expect(kL10nTranslations.containsKey(code), true);
          expect(kL10nTranslations[code]!.isNotEmpty, true);
          expect(kL10nTranslations[code]!.length, greaterThan(500));
        }
      },
    );

    testWidgets('localizes Devanagari numerals for Hindi locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final digits = '1234567890'.localizedDigits(context);
              expect(digits, '१२३४५६७८९०');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('localizes dynamic template patterns accurately in French', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              expect('Every 5 Days'.localized(context), 'Tous les 5 jours');
              expect('Settings'.localized(context), 'Paramètres');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
