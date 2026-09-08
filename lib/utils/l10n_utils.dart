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
    if (normKey != 'waking days lost' &&
        normKey != 'earth (24h) days lost' &&
        normKey.endsWith(' lost')) {
      final lead = key.substring(0, key.length - 5).trim();
      return switch (l10n.localeName) {
        'fr' => '$lead perdu',
        'es' => '$lead perdido',
        'hi' => '$lead नष्ट',
        'de' => '$lead verloren',
        'ja' => '$lead 喪失',
        'ru' => '$lead потеряно',
        _ => '$lead lost',
      };
    }
    if (normKey.endsWith(' waking days void')) {
      final lead = key.substring(0, key.length - 17).trim();
      return switch (l10n.localeName) {
        'fr' => '$lead j. éveillés vides',
        'es' => '$lead d. activos perdidos',
        'hi' => '$lead जागृत दिन नष्ट',
        'de' => '$lead Wachtage leer',
        'ja' => '$lead 活動日消失',
        'ru' => '$lead бодр. дней впустую',
        _ => '$lead waking days void',
      };
    }
    if (normKey.endsWith(' wasted this week')) {
      final lead = key.substring(0, key.length - 17).trim();
      return switch (l10n.localeName) {
        'fr' => '$lead perdus cette semaine',
        'es' => '$lead perdidas esta semana',
        'hi' => 'इस सप्ताह $lead नष्ट',
        'de' => '$lead diese Woche verloren',
        'ja' => '今週 $lead 消失',
        'ru' => '$lead потрачено за неделю',
        _ => '$lead wasted this week',
      };
    }
    if (normKey != 'waking days lost' &&
        normKey != 'earth (24h) days lost' &&
        normKey.endsWith(' days lost')) {
      final lead = key.substring(0, key.length - 10).trim();
      return switch (l10n.localeName) {
        'fr' => '$lead jours perdus',
        'es' => '$lead días perdidos',
        'hi' => '$lead दिन नष्ट',
        'de' => '$lead Tage verloren',
        'ja' => '$lead 日消失',
        'ru' => '$lead дней потеряно',
        _ => '$lead days lost',
      };
    }
    if (normKey.startsWith('over ') &&
        normKey.endsWith(
          '% of your waking existence dissolved into unaccounted void.',
        )) {
      final pct = normKey.substring(5, normKey.indexOf('%')).trim();
      return switch (l10n.localeName) {
        'fr' =>
          'Plus de $pct% de votre existence éveillée a été perdue dans le vide.',
        'es' => 'Más del $pct% de tu tiempo despierto se perdió en el vacío.',
        'hi' => 'आपके जागृत जीवन का $pct% से अधिक समय व्यर्थ चला गया।',
        'de' => 'Über $pct% Ihres Wachlebens gingen spurlos verloren.',
        'ja' => '覚醒時間の $pct% 以上が未記録のまま失われました。',
        'ru' => 'Более $pct% времени бодрствования потрачено впустую.',
        _ =>
          'Over $pct% of your waking existence dissolved into unaccounted void.',
      };
    }
    if (normKey.startsWith('based on your daily conscious window (') &&
        normKey.contains(' unaccounted for)')) {
      final startIndex = 'based on your daily conscious window ('.length;
      final endIndex = normKey.indexOf(' unaccounted for)');
      final wastedPart = key.substring(startIndex, endIndex).trim();
      return switch (l10n.localeName) {
        'fr' =>
          'Basé sur votre fenêtre de conscience ($wastedPart non comptabilisées). Touchez pour explorer.',
        'es' =>
          'Basado en tu ventana consciente ($wastedPart no registradas). Toca para explorar.',
        'hi' =>
          'आपकी दैनिक जागृत सीमा पर आधारित ($wastedPart का हिसाब नहीं)। अधिक देखने के लिए स्पर्श करें।',
        'de' =>
          'Basierend auf Ihrem bewussten Zeitfenster ($wastedPart ungenutzt). Tippen für Details.',
        'ja' => '日々の意識時間に基づきます（$wastedPart 未記録）。タップして統計を確認。',
        'ru' =>
          'На основе времени бодрствования ($wastedPart не учтено). Нажмите для настроек.',
        _ =>
          'Based on your daily conscious window ($wastedPart unaccounted for). Tap to customize sleep, logistics, and explore multi-horizon mortality statistics.',
      };
    }

    final translation = kL10nTranslations[l10n.localeName]?[normKey];
    return translation ?? this;
  }
}
