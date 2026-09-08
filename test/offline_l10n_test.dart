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

    testWidgets('localizes Life Audit and void metrics in Hindi', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              expect('Life Audit'.localized(context), 'लाइफ ऑडिट');
              expect(
                'The Cost of the Void'.localized(context),
                'व्यर्थ समय की लागत',
              );
              expect('Waking Days Lost'.localized(context), 'जागृत दिन नष्ट');
              expect('5h 30m lost'.localized(context), '5h 30m नष्ट');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('localizes Life Audit and void metrics in German', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              expect('Life Audit'.localized(context), 'Lebens-Audit');
              expect(
                'The Cost of the Void'.localized(context),
                'Die Kosten der Leere',
              );
              expect(
                'Waking Days Lost'.localized(context),
                'Wachtage verloren',
              );
              expect('Earth (24h) Days'.localized(context), '24h-Erden-Tage');
              expect('4h lost'.localized(context), '4h verloren');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
