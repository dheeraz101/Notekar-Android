import 'package:flutter/material.dart';
import 'package:notekar/l10n/app_localizations.dart';
import 'package:notekar/l10n/l10n_data.dart';

const Map<String, Map<String, String>> _productCopyTranslations = {
  'fr': {
    'review the time you logged and the time you have not tracked yet. estimates are based on your selected waking hours.':
        'Consultez le temps enregistré et celui qui ne l’est pas encore. Les estimations reposent sur vos heures d’éveil choisies.',
    'your time overview': 'Aperçu de votre temps',
    'more filters': 'Plus de filtres',
    'a note on tracking': 'À propos du suivi',
    'tracking is a tool for reflection. a missing entry is simply information you have not recorded.':
        'Le suivi est un outil de réflexion. Une entrée manquante indique simplement une information non enregistrée.',
    'untracked': 'non suivi',
    'days with untracked time': 'Jours avec du temps non suivi',
    'strong tracking coverage': 'Couverture de suivi élevée',
    'more time is untracked': 'Davantage de temps reste non suivi',
    'some time is untracked': 'Une partie du temps reste non suivie',
    'most of your estimated waking time is represented in your logs.':
        'La majeure partie de votre temps d’éveil estimé figure dans vos journaux.',
    'some of your estimated waking time is not represented in your logs.':
        'Une partie de votre temps d’éveil estimé ne figure pas dans vos journaux.',
    'equivalent waking days': 'Équivalent en jours d’éveil',
    'time outside tracked activities': 'Temps hors activités suivies',
    'estimated tracked time': 'Temps estimé enregistré',
    'estimated untracked time': 'Temps estimé non suivi',
    'estimated time projection': 'Projection temporelle estimée',
    'optional life horizon': 'Horizon de vie facultatif',
    'tap to log · hold to add a note':
        'Touchez pour enregistrer · maintenez pour ajouter une note',
    'tap to start · hold to add a note':
        'Touchez pour démarrer · maintenez pour ajouter une note',
    'tap to end · hold to add a note':
        'Touchez pour terminer · maintenez pour ajouter une note',
    'add your birth date to see an optional life horizon estimate based on the profile details you provide.':
        'Ajoutez votre date de naissance pour afficher une estimation facultative de votre horizon de vie, fondée sur les informations fournies.',
  },
  'es': {
    'review the time you logged and the time you have not tracked yet. estimates are based on your selected waking hours.':
        'Consulta el tiempo que registraste y el que aún no has seguido. Las estimaciones se basan en las horas de vigilia que seleccionaste.',
    'your time overview': 'Resumen de tu tiempo',
    'more filters': 'Más filtros',
    'a note on tracking': 'Sobre el seguimiento',
    'tracking is a tool for reflection. a missing entry is simply information you have not recorded.':
        'El seguimiento es una herramienta de reflexión. Una entrada ausente solo indica información que no registraste.',
    'untracked': 'sin registrar',
    'days with untracked time': 'Días con tiempo sin registrar',
    'strong tracking coverage': 'Buen nivel de seguimiento',
    'more time is untracked': 'Hay más tiempo sin registrar',
    'some time is untracked': 'Hay parte del tiempo sin registrar',
    'most of your estimated waking time is represented in your logs.':
        'La mayor parte de tus horas de vigilia estimadas aparece en tus registros.',
    'some of your estimated waking time is not represented in your logs.':
        'Parte de tus horas de vigilia estimadas no aparece en tus registros.',
    'equivalent waking days': 'Equivalente en días de vigilia',
    'time outside tracked activities':
        'Tiempo fuera de las actividades registradas',
    'estimated tracked time': 'Tiempo registrado estimado',
    'estimated untracked time': 'Tiempo estimado sin registrar',
    'estimated time projection': 'Proyección de tiempo estimada',
    'optional life horizon': 'Horizonte de vida opcional',
    'tap to log · hold to add a note':
        'Toca para registrar · mantén pulsado para añadir una nota',
    'tap to start · hold to add a note':
        'Toca para iniciar · mantén pulsado para añadir una nota',
    'tap to end · hold to add a note':
        'Toca para terminar · mantén pulsado para añadir una nota',
    'add your birth date to see an optional life horizon estimate based on the profile details you provide.':
        'Añade tu fecha de nacimiento para ver una estimación opcional del horizonte de vida según los datos que proporciones.',
  },
  'hi': {
    'review the time you logged and the time you have not tracked yet. estimates are based on your selected waking hours.':
        'अपने दर्ज किए गए और अभी तक दर्ज न किए गए समय की समीक्षा करें। अनुमान आपके चुने हुए जागने के घंटों पर आधारित हैं।',
    'your time overview': 'आपके समय का सारांश',
    'more filters': 'अधिक फ़िल्टर',
    'a note on tracking': 'समय दर्ज करने के बारे में',
    'tracking is a tool for reflection. a missing entry is simply information you have not recorded.':
        'समय दर्ज करना आत्मचिंतन का एक साधन है। कोई प्रविष्टि न होना बस यह बताता है कि आपने वह जानकारी दर्ज नहीं की।',
    'untracked': 'दर्ज नहीं',
    'days with untracked time': 'बिना दर्ज समय वाले दिन',
    'strong tracking coverage': 'अच्छा ट्रैकिंग कवरेज',
    'more time is untracked': 'अधिक समय दर्ज नहीं है',
    'some time is untracked': 'कुछ समय दर्ज नहीं है',
    'most of your estimated waking time is represented in your logs.':
        'आपके अनुमानित जागने के समय का अधिकांश हिस्सा लॉग में दर्ज है।',
    'some of your estimated waking time is not represented in your logs.':
        'आपके अनुमानित जागने के समय का कुछ हिस्सा लॉग में दर्ज नहीं है।',
    'equivalent waking days': 'जागने के दिनों के बराबर',
    'time outside tracked activities': 'दर्ज गतिविधियों के बाहर का समय',
    'estimated tracked time': 'अनुमानित दर्ज समय',
    'estimated untracked time': 'अनुमानित बिना दर्ज समय',
    'estimated time projection': 'समय का अनुमानित प्रक्षेपण',
    'optional life horizon': 'वैकल्पिक जीवन-अवधि अनुमान',
    'tap to log · hold to add a note':
        'दर्ज करने के लिए टैप करें · नोट जोड़ने के लिए दबाकर रखें',
    'tap to start · hold to add a note':
        'शुरू करने के लिए टैप करें · नोट जोड़ने के लिए दबाकर रखें',
    'tap to end · hold to add a note':
        'समाप्त करने के लिए टैप करें · नोट जोड़ने के लिए दबाकर रखें',
    'add your birth date to see an optional life horizon estimate based on the profile details you provide.':
        'आपकी दी गई प्रोफ़ाइल जानकारी के आधार पर जीवन-अवधि का वैकल्पिक अनुमान देखने के लिए जन्मतिथि जोड़ें।',
  },
  'de': {
    'review the time you logged and the time you have not tracked yet. estimates are based on your selected waking hours.':
        'Sieh dir erfasste und noch nicht erfasste Zeit an. Die Schätzungen richten sich nach deinen festgelegten Wachstunden.',
    'your time overview': 'Dein Zeitüberblick',
    'more filters': 'Weitere Filter',
    'a note on tracking': 'Hinweis zur Erfassung',
    'tracking is a tool for reflection. a missing entry is simply information you have not recorded.':
        'Die Erfassung dient der Reflexion. Ein fehlender Eintrag bedeutet lediglich, dass diese Information nicht erfasst wurde.',
    'untracked': 'nicht erfasst',
    'days with untracked time': 'Tage mit nicht erfasster Zeit',
    'strong tracking coverage': 'Gute Erfassungsabdeckung',
    'more time is untracked': 'Mehr Zeit ist nicht erfasst',
    'some time is untracked': 'Ein Teil der Zeit ist nicht erfasst',
    'most of your estimated waking time is represented in your logs.':
        'Der größte Teil deiner geschätzten Wachzeit ist in deinen Einträgen enthalten.',
    'some of your estimated waking time is not represented in your logs.':
        'Ein Teil deiner geschätzten Wachzeit ist nicht in deinen Einträgen enthalten.',
    'equivalent waking days': 'Entsprechende Wach-Tage',
    'time outside tracked activities': 'Zeit außerhalb erfasster Aktivitäten',
    'estimated tracked time': 'Geschätzte erfasste Zeit',
    'estimated untracked time': 'Geschätzte nicht erfasste Zeit',
    'estimated time projection': 'Geschätzte Zeitprojektion',
    'optional life horizon': 'Optionale Lebenszeitschätzung',
    'tap to log · hold to add a note':
        'Tippen zum Erfassen · halten für eine Notiz',
    'tap to start · hold to add a note':
        'Tippen zum Starten · halten für eine Notiz',
    'tap to end · hold to add a note':
        'Tippen zum Beenden · halten für eine Notiz',
    'add your birth date to see an optional life horizon estimate based on the profile details you provide.':
        'Füge dein Geburtsdatum hinzu, um eine optionale Lebenszeit-Schätzung anhand deiner Profilangaben zu sehen.',
  },
  'ja': {
    'review the time you logged and the time you have not tracked yet. estimates are based on your selected waking hours.':
        '記録した時間と、まだ記録していない時間を確認できます。推定値は設定した起床時間に基づきます。',
    'your time overview': '時間の概要',
    'more filters': 'その他のフィルター',
    'a note on tracking': '記録について',
    'tracking is a tool for reflection. a missing entry is simply information you have not recorded.':
        '記録は振り返りのためのものです。入力がない場合は、その情報が記録されていないことを示します。',
    'untracked': '未記録',
    'days with untracked time': '未記録時間がある日',
    'strong tracking coverage': '記録率が高い状態',
    'more time is untracked': '未記録の時間が多い状態',
    'some time is untracked': '一部の時間が未記録です',
    'most of your estimated waking time is represented in your logs.':
        '推定される起床時間の大部分がログに記録されています。',
    'some of your estimated waking time is not represented in your logs.':
        '推定される起床時間の一部がログに記録されていません。',
    'equivalent waking days': '起床日換算',
    'time outside tracked activities': '記録した活動以外の時間',
    'estimated tracked time': '記録済み時間の推定',
    'estimated untracked time': '未記録時間の推定',
    'estimated time projection': '時間の推定',
    'optional life horizon': '任意の人生時間の推定',
    'tap to log · hold to add a note': 'タップして記録 · 長押ししてメモを追加',
    'tap to start · hold to add a note': 'タップして開始 · 長押ししてメモを追加',
    'tap to end · hold to add a note': 'タップして終了 · 長押ししてメモを追加',
    'add your birth date to see an optional life horizon estimate based on the profile details you provide.':
        '生年月日を登録すると、入力したプロフィール情報に基づく任意の人生時間の推定を表示できます。',
  },
  'ru': {
    'review the time you logged and the time you have not tracked yet. estimates are based on your selected waking hours.':
        'Просмотрите учтенное и еще не учтенное время. Оценка основана на выбранной продолжительности бодрствования.',
    'your time overview': 'Обзор времени',
    'more filters': 'Другие фильтры',
    'a note on tracking': 'Об учете времени',
    'tracking is a tool for reflection. a missing entry is simply information you have not recorded.':
        'Учет помогает анализировать время. Отсутствие записи означает лишь, что эта информация не была внесена.',
    'untracked': 'не учтено',
    'days with untracked time': 'Дни с неучтенным временем',
    'strong tracking coverage': 'Хороший охват учета',
    'more time is untracked': 'Больше времени не учтено',
    'some time is untracked': 'Часть времени не учтена',
    'most of your estimated waking time is represented in your logs.':
        'Большая часть расчетного времени бодрствования отражена в записях.',
    'some of your estimated waking time is not represented in your logs.':
        'Часть расчетного времени бодрствования не отражена в записях.',
    'equivalent waking days': 'Эквивалент дней бодрствования',
    'time outside tracked activities': 'Время вне учтенных занятий',
    'estimated tracked time': 'Расчетное учтенное время',
    'estimated untracked time': 'Расчетное неучтенное время',
    'estimated time projection': 'Оценка распределения времени',
    'optional life horizon': 'Необязательная оценка жизненного горизонта',
    'tap to log · hold to add a note':
        'Нажмите, чтобы записать · удерживайте, чтобы добавить заметку',
    'tap to start · hold to add a note':
        'Нажмите, чтобы начать · удерживайте, чтобы добавить заметку',
    'tap to end · hold to add a note':
        'Нажмите, чтобы завершить · удерживайте, чтобы добавить заметку',
    'add your birth date to see an optional life horizon estimate based on the profile details you provide.':
        'Добавьте дату рождения, чтобы увидеть необязательную оценку жизненного горизонта на основе указанных данных профиля.',
  },
};

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
          'Plus de $pct% de votre temps d’éveil estimé n’est pas enregistré.',
        'es' =>
          'Más del $pct% de tus horas de vigilia estimadas no está registrado.',
        'hi' => 'आपके अनुमानित जागने के समय का $pct% से अधिक दर्ज नहीं है।',
        'de' => 'Über $pct% deiner geschätzten Wachzeit sind nicht erfasst.',
        'ja' => '推定される覚醒時間の $pct% 以上が記録されていません。',
        'ru' => 'Более $pct% расчетного времени бодрствования не учтено.',
        _ =>
          '$pct% or more of your estimated waking time is not represented in your logs.',
      };
    }
    if (normKey.startsWith('based on your daily conscious window (') &&
        normKey.contains(' unaccounted for)')) {
      final startIndex = 'based on your daily conscious window ('.length;
      final endIndex = normKey.indexOf(' unaccounted for)');
      final wastedPart = key.substring(startIndex, endIndex).trim();
      return switch (l10n.localeName) {
        'fr' =>
          'Basé sur votre période d’éveil estimée ($wastedPart non suivi). Touchez pour ajuster les paramètres.',
        'es' =>
          'Según tu periodo estimado de vigilia ($wastedPart sin registrar). Toca para ajustar los parámetros.',
        'hi' =>
          'यह आपके अनुमानित जागने के समय पर आधारित है ($wastedPart दर्ज नहीं)। सेटिंग बदलने के लिए टैप करें।',
        'de' =>
          'Basierend auf deiner geschätzten Wachzeit ($wastedPart nicht erfasst). Tippe, um die Einstellungen anzupassen.',
        'ja' => '推定される覚醒時間に基づきます（$wastedPart 未記録）。設定を調整するにはタップしてください。',
        'ru' =>
          'На основе расчетного времени бодрствования ($wastedPart не учтено). Нажмите, чтобы изменить настройки.',
        _ =>
          'Based on your estimated waking window ($wastedPart untracked). Tap to adjust your settings.',
      };
    }

    final friendlyTranslation =
        _productCopyTranslations[l10n.localeName]?[normKey];
    if (friendlyTranslation != null) return friendlyTranslation;

    final horizonMatch = RegExp(
      r'^not enough logged data for the full (.+) period yet\. (\d+) of (\d+) days currently have data\.$',
    ).firstMatch(key);
    if (horizonMatch != null) {
      final horizon = horizonMatch.group(1)!;
      final recorded = horizonMatch.group(2)!;
      final required = horizonMatch.group(3)!;
      return switch (l10n.localeName) {
        'fr' =>
          'Les données sont insuffisantes pour toute la période $horizon. Elles couvrent actuellement $recorded jours sur $required.',
        'es' =>
          'Aún no hay suficientes datos para todo el periodo $horizon. Actualmente hay datos de $recorded de $required días.',
        'hi' =>
          'पूरी $horizon अवधि के लिए अभी पर्याप्त लॉग नहीं हैं। फिलहाल $required में से $recorded दिनों का डेटा है।',
        'de' =>
          'Für den gesamten Zeitraum $horizon liegen noch nicht genügend Daten vor. Aktuell gibt es Daten für $recorded von $required Tagen.',
        'ja' =>
          '$horizon の全期間を推定するには、まだ記録が不足しています。現在は $required 日中 $recorded 日分のデータがあります。',
        'ru' =>
          'Для всего периода $horizon пока недостаточно записей. Сейчас есть данные за $recorded из $required дней.',
        _ => key,
      };
    }

    final percentMatch = RegExp(
      r'^about (\d+)% of your estimated waking time is not represented in your logs\.$',
      caseSensitive: false,
    ).firstMatch(key);
    if (percentMatch != null) {
      final percent = percentMatch.group(1)!;
      return switch (l10n.localeName) {
        'fr' =>
          'Environ $percent % de votre temps d’éveil estimé ne figure pas dans vos journaux.',
        'es' =>
          'Aproximadamente el $percent % de tus horas de vigilia estimadas no aparece en tus registros.',
        'hi' =>
          'आपके अनुमानित जागने के समय का लगभग $percent% लॉग में दर्ज नहीं है।',
        'de' =>
          'Etwa $percent % deiner geschätzten Wachzeit ist nicht in deinen Einträgen enthalten.',
        'ja' => '推定される起床時間の約 $percent% がログに記録されていません。',
        'ru' =>
          'Около $percent% расчетного времени бодрствования не отражено в записях.',
        _ => key,
      };
    }

    final translation = kL10nTranslations[l10n.localeName]?[normKey];
    return translation ?? this;
  }
}
