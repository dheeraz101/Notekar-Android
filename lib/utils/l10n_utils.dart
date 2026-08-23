import 'package:flutter/material.dart';
import 'package:notekar/l10n/app_localizations.dart';
import 'package:notekar/l10n/l10n_data.dart';

extension LocalizedDigitsExtension on String {
  String localizedDigits(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n?.localeName ?? 'en';
    if (locale == 'hi') {
      const devanagariDigits = [
        '०',
        '१',
        '२',
        '३',
        '४',
        '५',
        '६',
        '७',
        '८',
        '९',
      ];
      final buffer = StringBuffer();
      for (int i = 0; i < length; i++) {
        final codeUnit = codeUnitAt(i);
        if (codeUnit >= 48 && codeUnit <= 57) {
          buffer.write(devanagariDigits[codeUnit - 48]);
        } else {
          buffer.writeCharCode(codeUnit);
        }
      }
      return buffer.toString();
    }
    return this;
  }
}

extension LocalizedIntDigits on int {
  String localizedDigits(BuildContext context) {
    return toString().localizedDigits(context);
  }
}

extension LocalizedString on String {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || l10n.localeName == 'en') return this;

    final key = trim().replaceAll('’', "'");
    final normKey = key.toLowerCase();

    // Dynamic patterns with variables
    if (normKey.startsWith('every ') && normKey.endsWith(' days')) {
      final numStr = normKey.substring(6, normKey.length - 5).trim();
      return switch (l10n.localeName) {
        'fr' => 'Tous les $numStr jours',
        'es' => 'Cada $numStr días',
        'hi' => 'हर $numStr दिन',
        'de' => 'Alle $numStr Tage',
        'ja' => '$numStr日ごと',
        'ru' => 'Каждые $numStr дн.',
        _ => 'Every $numStr Days',
      };
    }
    if (normKey.startsWith('selected: ')) {
      final sub = key.substring(10).trim();
      final subLoc = sub.localized(context);
      return switch (l10n.localeName) {
        'fr' => 'Sélectionné : $subLoc',
        'es' => 'Seleccionado: $subLoc',
        'hi' => 'चयनित: $subLoc',
        'de' => 'Ausgewählt: $subLoc',
        'ja' => '選択中: $subLoc',
        'ru' => 'Выбрано: $subLoc',
        _ => 'Selected: $subLoc',
      };
    }
    if (normKey.startsWith('target: ')) {
      final sub = key.substring(8).trim();
      final subLoc = sub.localized(context);
      return switch (l10n.localeName) {
        'fr' => 'Objectif : $subLoc',
        'es' => 'Objetivo: $subLoc',
        'hi' => 'लक्ष्य: $subLoc',
        'de' => 'Ziel: $subLoc',
        'ja' => '目標: $subLoc',
        'ru' => 'Цель: $subLoc',
        _ => 'Target: $subLoc',
      };
    }
    if (normKey.startsWith('try again in ') && normKey.endsWith(' seconds')) {
      final numStr = normKey.substring(13, normKey.length - 8).trim();
      return switch (l10n.localeName) {
        'fr' => 'Réessayez dans $numStr secondes',
        'es' => 'Inténtalo de nuevo en $numStr segundos',
        'hi' => '$numStr सेकंड में पुन: प्रयास करें',
        'de' => 'In $numStr Sekunden erneut versuchen',
        'ja' => '$numStr秒後に再試行してください',
        'ru' => 'Повторите попытку через $numStr сек.',
        _ => 'Try again in $numStr seconds',
      };
    }
    if (normKey.startsWith('showing ') &&
        normKey.endsWith(' commits') &&
        normKey.contains(' of ')) {
      final parts = normKey.substring(8, normKey.length - 8).split(' of ');
      if (parts.length == 2) {
        final shown = parts[0].trim();
        final total = parts[1].trim();
        return switch (l10n.localeName) {
          'es' => 'Mostrando $shown de $total commits',
          'hi' => '$total में से $shown कमिट्स दिखाए जा रहे हैं',
          'fr' => 'Affichage de $shown sur $total commits',
          'de' => 'Zeige $shown von $total Commits',
          'ja' => '$total 件中 $shown 件のコミットを表示',
          'ru' => 'Отображение $shown из $total коммитов',
          _ => 'Showing $shown of $total commits',
        };
      }
    }
    if (normKey.startsWith('deleted ') && normKey.endsWith(' moment')) {
      final typeStr = key.substring(8, key.length - 7).trim();
      final typeLoc = typeStr.localized(context);
      return switch (l10n.localeName) {
        'es' => 'Momento $typeLoc eliminado',
        'hi' => '$typeLoc क्षण हटाया गया',
        'fr' => 'Moment $typeLoc supprimé',
        'de' => '$typeLoc-Moment gelöscht',
        'ja' => '$typeLoc モーメントを削除しました',
        'ru' => 'Момент «$typeLoc» удален',
        _ => 'Deleted $typeLoc moment',
      };
    }

    final translation = kL10nTranslations[l10n.localeName]?[normKey];
    return translation ?? this;
  }
}
