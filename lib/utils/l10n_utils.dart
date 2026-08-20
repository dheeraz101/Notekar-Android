import 'package:flutter/material.dart';
import 'package:notekar/l10n/app_localizations.dart';

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
    if (l10n == null) return this;

    // Normalize string key mapping
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
      final middle = normKey.substring(8, normKey.length - 8);
      final parts = middle.split(' of ');
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

    if (l10n.localeName == 'en') return this;

    // Check language maps for German, Japanese, and Russian
    if (l10n.localeName == 'fr') {
      final fr = _frTranslations[normKey];
      if (fr != null) return fr;
    } else if (l10n.localeName == 'de') {
      final de = _deTranslations[normKey];
      if (de != null) return de;
    } else if (l10n.localeName == 'ja') {
      final ja = _jaTranslations[normKey];
      if (ja != null) return ja;
    } else if (l10n.localeName == 'ru') {
      final ru = _ruTranslations[normKey];
      if (ru != null) return ru;
    }

    return switch (normKey) {
      'whatsnewtitle' => switch (l10n.localeName) {
        'es' => 'Novedades',
        'hi' => 'नया क्या है',
        _ => this,
      },

      'okay' => switch (l10n.localeName) {
        'es' => 'De acuerdo',
        'hi' => 'ठीक है',
        _ => this,
      },

      'deleted in moment' => switch (l10n.localeName) {
        'es' => 'Momento IN eliminado',
        'hi' => 'हटाया गया IN क्षण',
        _ => this,
      },

      'deleted out moment' => switch (l10n.localeName) {
        'es' => 'Momento OUT eliminado',
        'hi' => 'हटाया गया OUT क्षण',
        _ => this,
      },

      'deleted single moment' => switch (l10n.localeName) {
        'es' => 'Momento SINGLE eliminado',
        'hi' => 'हटाया गया SINGLE क्षण',
        _ => this,
      },

      'sobriety companion' => switch (l10n.localeName) {
        'es' => 'Compañero de Sobriedad',
        'hi' => 'संयम साथी',
        _ => this,
      },

      'trigger analysis' => switch (l10n.localeName) {
        'es' => 'Análisis de Disparadores',
        'hi' => 'उकसाने वाले कारणों का विश्लेषण',
        _ => this,
      },

      'milestones' => switch (l10n.localeName) {
        'es' => 'Hitos',
        'hi' => 'मील के पत्थर',
        _ => this,
      },

      'milestone theme' => switch (l10n.localeName) {
        'es' => 'Tema de Hitos',
        'hi' => 'मील का पत्थर थीम',
        _ => this,
      },

      'theme style' => switch (l10n.localeName) {
        'es' => 'Estilo de Tema',
        'hi' => 'थीम शैली',
        _ => this,
      },

      'view all milestones' => switch (l10n.localeName) {
        'es' => 'Ver todos los hitos',
        'hi' => 'सभी मील के पत्थर देखें',
        _ => this,
      },

      'custom start date' => switch (l10n.localeName) {
        'es' => 'Fecha de Inicio Personalizada',
        'hi' => 'कस्टम प्रारंभ तिथि',
        _ => this,
      },

      'set sobriety start date' => switch (l10n.localeName) {
        'es' => 'Establecer Fecha de Inicio',
        'hi' => 'संयम की प्रारंभ तिथि सेट करें',
        _ => this,
      },

      'enable sobriety mode' => switch (l10n.localeName) {
        'es' => 'Activar Modo de Sobriedad',
        'hi' => 'संयम मोड सक्षम करें',
        _ => this,
      },

      'select date and time' => switch (l10n.localeName) {
        'es' => 'Seleccionar Fecha y Hora',
        'hi' => 'दिनांक और समय चुनें',
        _ => this,
      },

      'choose milestone theme' => switch (l10n.localeName) {
        'es' => 'Elegir Tema de Hito',
        'hi' => 'मील का पत्थर थीम चुनें',
        _ => this,
      },

      'not set: using last log or relapse tag' => switch (l10n.localeName) {
        'es' => 'No establecido: usando último registro o etiqueta de recaída',
        'hi' => 'सेट नहीं है: अंतिम लॉग या रिलैप्स टैग का उपयोग करना',
        _ => this,
      },

      'were you already clean before installing? set your actual start date here. this overrides automatic detection from your logs.' =>
        switch (l10n.localeName) {
          'es' =>
            '¿Ya estabas limpio antes de instalar? Establece tu fecha de inicio real aquí. Esto anula la detección automática de tus registros.',
          'hi' =>
            'क्या आप इंस्टॉल करने से पहले ही संयम में थे? अपनी वास्तविक प्रारंभ तिथि यहाँ सेट करें। यह आपके लॉग से स्वचालित पहचान को अधिलेखित कर देता है।',
          _ => this,
        },

      'reset on relapse tag only' => switch (l10n.localeName) {
        'es' => 'Restablecer solo con etiqueta de recaída',
        'hi' => 'केवल रिलैप्स टैग पर रीसेट करें',
        _ => this,
      },

      'only moments tagged #relapse reset the streak. turn off to reset on any new log.' =>
        switch (l10n.localeName) {
          'es' =>
            'Solo los momentos etiquetados como #recaida restablecen la racha. Apáguelo para restablecer con cualquier nuevo registro.',
          'hi' =>
            'केवल #relapse टैग किए गए क्षण ही संयम को रीसेट करते हैं। किसी भी नए लॉग पर रीसेट करने के लिए इसे बंद करें।',
          _ => this,
        },

      'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.' =>
        switch (l10n.localeName) {
          'es' =>
            'Elige el estilo de narrativa para tus hitos. Cada tema está seleccionado psicológicamente para coincidir con una autoimagen y estilo de motivación diferentes.',
          'hi' =>
            'अपने मील के पत्थर के नामों के लिए कथा शैली चुनें। प्रत्येक थीम को एक अलग आत्म-छवि और प्रेरणा शैली से मेल खाने के लिए मनोवैज्ञानिक रूप से तैयार किया गया है।',
          _ => this,
        },

      'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.' =>
        switch (l10n.localeName) {
          'es' =>
            'Los 21 hitos desde 1 día hasta 10 años, en la neurociencia y psicología del comportamiento. Nombres mostrados en tu tema actual.',
          'hi' =>
            'तंत्रिका विज्ञान, लत सुधार अनुसंधान और व्यवहार मनोविज्ञान में निहित 1 दिन से 10 वर्ष तक के सभी 21 मील के पत्थर। आपकी वर्तमान थीम में नाम दिखाए गए हैं।',
          _ => this,
        },

      'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.' =>
        switch (l10n.localeName) {
          'es' =>
            'Seguimiento de racha y diario de recaídas privado. Todos los datos permanecen en tu dispositivo. Los registros existentes nunca se alteran.',
          'hi' =>
            'गोपनीयता-प्रथम संयम ट्रैकिंग और रिलैप्स डायरी। सारा डेटा आपके डिवाइस पर रहता है। मौजूदा लॉग कभी भी नहीं बदले जाते।',
          _ => this,
        },

      'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.' =>
        switch (l10n.localeName) {
          'es' =>
            'Tu pantalla de inicio mostrará una tarjeta de racha en vivo con insignias de hitos. El widget de inicio se adaptará para mostrar botones de reinicio y diario.',
          'hi' =>
            'आपकी होम स्क्रीन मील के पत्थर के बैज के साथ एक लाइव संयम कार्ड दिखाएगी। होम विजेट रीसेट और डायरी बटन दिखाने के लिए अनुकूलित हो जाएगा।',
          _ => this,
        },

      'trigger diary' => switch (l10n.localeName) {
        'es' => 'Diario de Disparadores',
        'hi' => 'ट्रिगर डायरी',
        _ => this,
      },

      'streak reset logic' => switch (l10n.localeName) {
        'es' => 'Lógica de Reinicio de Racha',
        'hi' => 'संयम रीसेट तर्क',
        _ => this,
      },

      'streak mode' => switch (l10n.localeName) {
        'es' => 'Modo de Racha',
        'hi' => 'संयम मोड',
        _ => this,
      },

      'adds a clean streak card to your home screen and adapts home screen widgets.' =>
        switch (l10n.localeName) {
          'es' =>
            'Añade una tarjeta de racha limpia a tu pantalla de inicio y adapta los widgets.',
          'hi' =>
            'आपकी होम स्क्रीन पर एक संयम कार्ड जोड़ता है और होम स्क्रीन विजेट को अनुकूलित करता है।',
          _ => this,
        },

      'view your relapse pattern insights, top moods, and peak vulnerability windows.' =>
        switch (l10n.localeName) {
          'es' =>
            'Ver información de patrones de recaída, estados de ánimo principales y ventanas de vulnerabilidad máxima.',
          'hi' =>
            'अपने रिलैप्स पैटर्न अंतर्दृष्टि, शीर्ष मूड और चरम संवेदनशीलता विंडो देखें।',
          _ => this,
        },

      'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.' =>
        switch (l10n.localeName) {
          'es' =>
            'Al registrar un momento con el Modo de Sobriedad activado, puedes etiquetar el estado de ánimo (Aburrido, Ansioso, Solitario...) y el disparador (Redes Sociales, Tarde en la Noche...). Se guardan como hashtags en la nota para compatibilidad total.',
          'hi' =>
            'संयम मोड चालू होने पर क्षण लॉग करते समय, आप मूड (बोर, चिंतित, अकेला...) और ट्रिगर (सोशल मीडिया, देर रात...) को टैग कर सकते हैं। ये पूर्ण संगतता के लिए नोट में हैशटैग के रूप में सहेजे जाते हैं।',
          _ => this,
        },

      'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.' =>
        switch (l10n.localeName) {
          'es' =>
            'Un rastreador de racha y diario de recaídas privado y sin conexión creado para potenciar tu viaje de recuperación.',
          'hi' =>
            'आपकी सुधार यात्रा को सशक्त बनाने के लिए बनाया गया एक गोपनीयता-प्रथम, ऑफ़लाइन संयम ट्रैकिंग और रिलैप्स डायरी।',
          _ => this,
        },

      'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.' =>
        switch (l10n.localeName) {
          'es' =>
            'Tus datos son 100% privados y permanecen sin conexión en este dispositivo. Activar esto no altera los registros existentes.',
          'hi' =>
            'आपका डेटा 100% निजी है और इस डिवाइस पर ऑफ़लाइन रहता है। इसे सक्षम करने से कोई भी मौजूदा लॉग नहीं बदलता है।',
          _ => this,
        },

      'sobriety trigger analysis' => switch (l10n.localeName) {
        'es' => 'Análisis de Disparadores de Sobriedad',
        'hi' => 'संयम ट्रिगर विश्लेषण',
        _ => this,
      },

      'total relapses' => switch (l10n.localeName) {
        'es' => 'Total de Recaídas',
        'hi' => 'कुल रिलैप्स',
        _ => this,
      },

      'top trigger' => switch (l10n.localeName) {
        'es' => 'Disparador Principal',
        'hi' => 'मुख्य ट्रिगर',
        _ => this,
      },

      'top mood' => switch (l10n.localeName) {
        'es' => 'Estado de Ánimo Principal',
        'hi' => 'मुख्य मूड',
        _ => this,
      },

      'peak risk window' => switch (l10n.localeName) {
        'es' => 'Ventana de Mayor Riesgo',
        'hi' => 'चरम जोखिम समय',
        _ => this,
      },

      'no relapses recorded yet!' => switch (l10n.localeName) {
        'es' => '¡Aún no hay recaídas registradas!',
        'hi' => 'अभी तक कोई रिलैप्स दर्ज नहीं किया गया है!',
        _ => this,
      },

      'your clean streak is active and running.' => switch (l10n.localeName) {
        'es' => 'Tu racha limpia está activa y en marcha.',
        'hi' => 'आपकी संयम यात्रा सक्रिय रूप से चल रही है।',
        _ => this,
      },

      'offline analysis of your logged relapse moments. no data leaves your device.' =>
        switch (l10n.localeName) {
          'es' =>
            'Análisis local de tus momentos de recaída registrados. Ningún dato sale de tu dispositivo.',
          'hi' =>
            'आपके दर्ज किए गए रिलैप्स क्षणों का ऑफ़लाइन विश्लेषण। कोई भी डेटा आपके डिवाइस से बाहर नहीं जाता है।',
          _ => this,
        },

      'bored' => switch (l10n.localeName) {
        'es' => 'Aburrido',
        'hi' => 'ऊबा हुआ',
        _ => this,
      },

      'anxious' => switch (l10n.localeName) {
        'es' => 'Ansioso',
        'hi' => 'चिंतित',
        _ => this,
      },

      'lonely' => switch (l10n.localeName) {
        'es' => 'Solitario',
        'hi' => 'अकेला',
        _ => this,
      },

      'tired' => switch (l10n.localeName) {
        'es' => 'Cansado',
        'hi' => 'थका हुआ',
        _ => this,
      },

      'stressed' => switch (l10n.localeName) {
        'es' => 'Estresado',
        'hi' => 'तनावग्रस्त',
        _ => this,
      },

      'angry' => switch (l10n.localeName) {
        'es' => 'Enojado',
        'hi' => 'क्रोधित',
        _ => this,
      },

      'sad' => switch (l10n.localeName) {
        'es' => 'Triste',
        'hi' => 'उदास',
        _ => this,
      },

      'happy' => switch (l10n.localeName) {
        'es' => 'Feliz',
        'hi' => 'खुश',
        _ => this,
      },
      'social media' => switch (l10n.localeName) {
        'es' => 'Redes Sociales',
        'hi' => 'सोशल मीडिया',
        _ => this,
      },
      'late night' => switch (l10n.localeName) {
        'es' => 'Tarde en la Noche',
        'hi' => 'देर रात',
        _ => this,
      },

      'stress' => switch (l10n.localeName) {
        'es' => 'Estrés',
        'hi' => 'तनाव',
        _ => this,
      },

      'boredom' => switch (l10n.localeName) {
        'es' => 'Aburrimiento',
        'hi' => 'ऊब',
        _ => this,
      },

      'loneliness' => switch (l10n.localeName) {
        'es' => 'Soledad',
        'hi' => 'अकेलापन',
        _ => this,
      },

      'fatigue' => switch (l10n.localeName) {
        'es' => 'Fatiga',
        'hi' => 'थकान',
        _ => this,
      },

      'friends' => switch (l10n.localeName) {
        'es' => 'Amigos',
        'hi' => 'मित्र',
        _ => this,
      },

      'location' => switch (l10n.localeName) {
        'es' => 'Ubicación',
        'hi' => 'स्थान',
        _ => this,
      },

      'none' => switch (l10n.localeName) {
        'es' => 'Ninguno',
        'hi' => 'कोई नहीं',
        _ => this,
      },

      'morning' => switch (l10n.localeName) {
        'es' => 'Mañana',
        'hi' => 'सुबह',
        _ => this,
      },

      'afternoon' => switch (l10n.localeName) {
        'es' => 'Tarde',
        'hi' => 'दोपहर',
        _ => this,
      },

      'evening' => switch (l10n.localeName) {
        'es' => 'Tarde/Noche',
        'hi' => 'शाम',
        _ => this,
      },

      'night' => switch (l10n.localeName) {
        'es' => 'Noche',
        'hi' => 'रात',
        _ => this,
      },

      'from' => switch (l10n.localeName) {
        'es' => 'Desde',
        'hi' => 'से',
        _ => this,
      },

      'at' => switch (l10n.localeName) {
        'es' => 'a las',
        'hi' => 'बजे',
        _ => this,
      },

      'science' => switch (l10n.localeName) {
        'es' => 'Ciencia',
        'hi' => 'विज्ञान',
        _ => this,
      },

      'warrior' => switch (l10n.localeName) {
        'es' => 'Guerrero',
        'hi' => 'योद्धा',
        _ => this,
      },

      'navy' => switch (l10n.localeName) {
        'es' => 'Armada',
        'hi' => 'नौसेना',
        _ => this,
      },

      'clan' => switch (l10n.localeName) {
        'es' => 'Clan',
        'hi' => 'कबीला',
        _ => this,
      },

      'ancient' => switch (l10n.localeName) {
        'es' => 'Antiguo',
        'hi' => 'प्राचीन',
        _ => this,
      },

      'samurai' => switch (l10n.localeName) {
        'es' => 'Samurái',
        'hi' => 'समुराई',
        _ => this,
      },

      'space' => switch (l10n.localeName) {
        'es' => 'Espacio',
        'hi' => 'अंतरिक्ष',
        _ => this,
      },

      'kingdom' => switch (l10n.localeName) {
        'es' => 'Reino',
        'hi' => 'साम्राज्य',
        _ => this,
      },

      'monk' => switch (l10n.localeName) {
        'es' => 'Monje',
        'hi' => 'साधु',
        _ => this,
      },

      'phoenix' => switch (l10n.localeName) {
        'es' => 'Fénix',
        'hi' => 'फ़ीनिक्स',
        _ => this,
      },

      'animal kingdom' => switch (l10n.localeName) {
        'es' => 'Reino Animal',
        'hi' => 'पशु साम्राज्य',
        _ => this,
      },

      'pokemon' => switch (l10n.localeName) {
        'es' => 'Pokémon',
        'hi' => 'पोकेमॉन',
        _ => this,
      },

      'jujutsu kaisen' => switch (l10n.localeName) {
        'es' => 'Jujutsu Kaisen',
        'hi' => 'जुजुत्सु कैसेन',
        _ => this,
      },

      'one piece' => switch (l10n.localeName) {
        'es' => 'One Piece',
        'hi' => 'वन पीस',
        _ => this,
      },

      'naruto' => switch (l10n.localeName) {
        'es' => 'Naruto',
        'hi' => 'नारुतो',
        _ => this,
      },

      'ben 10' => switch (l10n.localeName) {
        'es' => 'Ben 10',
        'hi' => 'बेन 10',
        _ => this,
      },

      'attack on titan' => switch (l10n.localeName) {
        'es' => 'Ataque a los Titanes',
        'hi' => 'अटैक ऑन टाइटन',
        _ => this,
      },

      'bleach' => switch (l10n.localeName) {
        'es' => 'Bleach',
        'hi' => 'ब्लीच',
        _ => this,
      },

      'my hero academia' => switch (l10n.localeName) {
        'es' => 'My Hero Academia',
        'hi' => 'माय हीरो एकेडेमिया',
        _ => this,
      },

      'vinland saga' => switch (l10n.localeName) {
        'es' => 'Vinland Saga',
        'hi' => 'विनलैंड सागा',
        _ => this,
      },

      'demon slayer' => switch (l10n.localeName) {
        'es' => 'Guardianes de la Noche (Demon Slayer)',
        'hi' => 'डिमोन स्लेयर',
        _ => this,
      },

      'fullmetal alchemist' => switch (l10n.localeName) {
        'es' => 'Fullmetal Alchemist',
        'hi' => 'फुलमेटल अल्केमिस्ट',
        _ => this,
      },

      'dragon ball' => switch (l10n.localeName) {
        'es' => 'Dragon Ball',
        'hi' => 'ड्रैगन बॉल',
        _ => this,
      },

      'code geass' => switch (l10n.localeName) {
        'es' => 'Code Geass',
        'hi' => 'कोड गियास',
        _ => this,
      },

      'death note' => switch (l10n.localeName) {
        'es' => 'Death Note',
        'hi' => 'डेथ नोट',
        _ => this,
      },

      'gintama' => switch (l10n.localeName) {
        'es' => 'Gintama',
        'hi' => 'गिंटामा',
        _ => this,
      },

      'hunter x hunter' => switch (l10n.localeName) {
        'es' => 'Hunter x Hunter',
        'hi' => 'हंटर एक्स हंटर',
        _ => this,
      },

      'solo leveling' => switch (l10n.localeName) {
        'es' => 'Solo Leveling',
        'hi' => 'सोलो लेवलिंग',
        _ => this,
      },

      'rpg / minecraft' => switch (l10n.localeName) {
        'es' => 'RPG / Minecraft',
        'hi' => 'आरपीजी / माइनक्राफ्ट',
        _ => this,
      },

      'tech career' => switch (l10n.localeName) {
        'es' => 'Carrera Tecnológica',
        'hi' => 'टेक करियर',
        _ => this,
      },

      'chess mastery' => switch (l10n.localeName) {
        'es' => 'Maestría en Ajedrez',
        'hi' => 'शतरंज महारत',
        _ => this,
      },

      'star wars' => switch (l10n.localeName) {
        'es' => 'Star Wars',
        'hi' => 'स्टार वॉर्स',
        _ => this,
      },

      'harry potter' => switch (l10n.localeName) {
        'es' => 'Harry Potter',
        'hi' => 'हैरी पॉटर',
        _ => this,
      },

      'marvel universe' => switch (l10n.localeName) {
        'es' => 'Universo Marvel',
        'hi' => 'मार्वल यूनिवर्स',
        _ => this,
      },

      'army elite. every clean day is a battle fought and won.' =>
        switch (l10n.localeName) {
          'es' => 'Élite militar. Cada día limpio es una batalla ganada.',
          'hi' => 'सेना के जवान। हर एक संयमित दिन जीती हुई जंग है।',
          _ => this,
        },

      'seafaring odyssey. chart new waters and never look back.' =>
        switch (l10n.localeName) {
          'es' => 'Odisea marítima. Explora nuevas aguas y nunca mires atrás.',
          'hi' =>
            'समुद्री यात्रा। नए रास्तों पर चलें और कभी पीछे मुड़कर न देखें।',
          _ => this,
        },

      'bushido code. master of the self.' => switch (l10n.localeName) {
        'es' => 'Código Bushido. Dueño de uno mismo.',
        'hi' => 'बुशीडो कोड। स्वयं पर नियंत्रण।',
        _ => this,
      },

      'cosmic exploration. every clean day is light-years gained.' =>
        switch (l10n.localeName) {
          'es' => 'Exploración cósmica. Cada día limpio son años luz ganados.',
          'hi' => 'अंतरिक्ष अन्वेषण। हर एक संयमित दिन प्रकाश वर्ष के समान है।',
          _ => this,
        },

      'medieval royalty. rise from serf to sovereign.' =>
        switch (l10n.localeName) {
          'es' => 'Realeza medieval. Asciende de siervo a soberano.',
          'hi' => 'मध्यकालीन राजघराना। दास से शासक बनें।',
          _ => this,
        },

      'monastic journey. silence, stillness, and vows.' =>
        switch (l10n.localeName) {
          'es' => 'Viaje monástico. Silencio, quietud y votos.',
          'hi' => 'मठवासी यात्रा। मौन, स्थिरता और प्रतिज्ञाएं।',
          _ => this,
        },

      'magikarp to the creator god arceus.' => switch (l10n.localeName) {
        'es' => 'De Magikarp al dios creador Arceus.',
        'hi' => 'मैजिकारप से निर्माता भगवान आर्सियस तक।',
        _ => this,
      },

      'cursed spirit to satoru gojo.' => switch (l10n.localeName) {
        'es' => 'De espíritu maldito a Satoru Gojo.',
        'hi' => 'शापित आत्मा से सटोरू गोजो तक।',
        _ => this,
      },

      'east blue coby to the pirate king gol d. roger.' =>
        switch (l10n.localeName) {
          'es' => 'De Coby del East Blue al Rey de los Piratas Gol D. Roger.',
          'hi' => 'ईस्ट ब्लू कोबी से समुद्री डाकू राजा गोल डी. रोजर तक।',
          _ => this,
        },

      'konohamaru to the sage of six paths.' => switch (l10n.localeName) {
        'es' => 'De Konohamaru al Sabio de los Seis Caminos.',
        'hi' => 'कोनोहामारू से छह पथों के ऋषि तक।',
        _ => this,
      },

      'grey matter to alien x.' => switch (l10n.localeName) {
        'es' => 'De Materia Gris a Alien X.',
        'hi' => 'ग्रे मैटर से एलियन एक्स तक।',
        _ => this,
      },

      'pure titan to the founder ymir fritz.' => switch (l10n.localeName) {
        'es' => 'De Titán puro a la Fundadora Ymir Fritz.',
        'hi' => 'शुद्ध टाइटन से संस्थापक यमिर फ्रिट्ज तक।',
        _ => this,
      },

      'teddy bear kon to yhwach the almighty.' => switch (l10n.localeName) {
        'es' => 'Del peluche Kon a Yhwach el Todopoderoso.',
        'hi' => 'टेडी बियर कॉन से सर्वशक्तिमान इहवाच तक।',
        _ => this,
      },

      'mineta to all might prime.' => switch (l10n.localeName) {
        'es' => 'De Mineta a All Might Prime.',
        'hi' => 'मिनेटा से ऑल माइट प्राइम तक।',
        _ => this,
      },

      'priest willibald to thors the troll of jom.' =>
        switch (l10n.localeName) {
          'es' => 'Del sacerdote Willibald a Thors el Trol de Jom.',
          'hi' => 'पुजारी विलीबाल्ड से थोरस द ट्रोल ऑफ जोम तक।',
          _ => this,
        },

      'murata to yoriichi tsugikuni.' => switch (l10n.localeName) {
        'es' => 'De Murata a Yoriichi Tsugikuni.',
        'hi' => 'मुराता से योरीइची सुगिकुनी तक।',
        _ => this,
      },

      'yoki to the ultimate truth.' => switch (l10n.localeName) {
        'es' => 'De Yoki a la Verdad última.',
        'hi' => 'योकी से परम सत्य तक।',
        _ => this,
      },

      'yamcha to the omni-king zeno.' => switch (l10n.localeName) {
        'es' => 'De Yamcha al Rey de Todo Zeno.',
        'hi' => 'यामचा से ओम्नी-किंग ज़ेनो तक।',
        _ => this,
      },

      'shirley to emperor lelouch vi britannia.' => switch (l10n.localeName) {
        'es' => 'De Shirley al Emperador Lelouch vi Britannia.',
        'hi' => 'शर्ली से सम्राट लेलौच वी ब्रिटानिया तक।',
        _ => this,
      },

      'matsuda to the shinigami king.' => switch (l10n.localeName) {
        'es' => 'De Matsuda al Rey Shinigami.',
        'hi' => 'मात्सुदा से शिनिगामी किंग तक।',
        _ => this,
      },

      'shinpachi to utsuro.' => switch (l10n.localeName) {
        'es' => 'De Shinpachi a Utsuro.',
        'hi' => 'शिनपाची से उत्सुरो तक।',
        _ => this,
      },

      'tonpa to adult gon.' => switch (l10n.localeName) {
        'es' => 'De Tonpa a Gon adulto.',
        'hi' => 'टोंपा से वयस्क गॉन तक।',
        _ => this,
      },

      'e-rank sung jinwoo to shadow monarch.' => switch (l10n.localeName) {
        'es' => 'De Sung Jinwoo de rango E al Monarca de las Sombras.',
        'hi' => 'ई-रैंक सुंग जिनवू से शैडो मोनार्क तक।',
        _ => this,
      },

      'wooden shovel to creative mode god.' => switch (l10n.localeName) {
        'es' => 'De pala de madera a dios del modo creativo.',
        'hi' => 'लकड़ी के बेलचे से क्रिएटिव मोड गॉड तक।',
        _ => this,
      },

      'html editor to turing award winner.' => switch (l10n.localeName) {
        'es' => 'De editor HTML a ganador del Premio Turing.',
        'hi' => 'HTML संपादक से ट्यूरिंग पुरस्कार विजेता तक।',
        _ => this,
      },
      's mate victim to magnus carlsen.' => switch (l10n.localeName) {
        'es' => 'De víctima del mate del pastor a Magnus Carlsen.',
        'hi' => 'स्कॉलर्स मेट पीड़ित से मैग्नस कार्लसन तक।',
        _ => 'Scholar\'s Mate victim to Magnus Carlsen.',
      },

      'moisture farmer to the chosen one.' => switch (l10n.localeName) {
        'es' => 'De granjero de humedad al Elegido.',
        'hi' => 'नमी किसान से चुने गए व्यक्ति (द चूज़न वन) तक।',
        _ => this,
      },

      'muggle to merlin.' => switch (l10n.localeName) {
        'es' => 'De Muggle a Merlín.',
        'hi' => 'मगल से मर्लिन तक।',
        _ => this,
      },

      'civilian to the one above all.' => switch (l10n.localeName) {
        'es' => 'De civil a El que está por encima de todo.',
        'hi' => 'नागरिक से द वन एबोव ऑल (परमेश्वर) तक।',
        _ => this,
      },

      'welcome' => switch (l10n.localeName) {
        'es' => 'Bienvenido',
        'hi' => 'स्वागत',
        _ => this,
      },

      'welcome to notekar' => switch (l10n.localeName) {
        'es' => 'Bienvenido a NoteKar',
        'hi' => 'NoteKar में आपका स्वागत है',
        _ => this,
      },

      'a quiet, offline-first way to mark moments the second they happen.' =>
        switch (l10n.localeName) {
          'es' =>
            'Una forma silenciosa y local de registrar momentos al instante.',
          'hi' =>
            'क्षणों को तुरंत रिकॉर्ड करने का एक शांत, ऑफ़लाइन-पहला तरीका।',
          _ => this,
        },

      'app theme' => switch (l10n.localeName) {
        'es' => 'Tema de la aplicación',
        'hi' => 'ऐप थीम',
        _ => this,
      },

      'theme mode' => switch (l10n.localeName) {
        'es' => 'Modo de tema',
        'hi' => 'थीम मोड',
        _ => this,
      },

      'get started' => switch (l10n.localeName) {
        'es' => 'Comenzar',
        'hi' => 'शुरू करें',
        _ => this,
      },

      'start logging' => switch (l10n.localeName) {
        'es' => 'Comenzar',
        'hi' => 'लॉगिंग शुरू करें',
        _ => this,
      },

      'save a moment' => switch (l10n.localeName) {
        'es' => 'Guardar un momento',
        'hi' => 'एक पल सहेजें',
        _ => this,
      },

      'two-way mode' => switch (l10n.localeName) {
        'es' => 'Modo de dos vías',
        'hi' => 'टू-वे मोड',
        _ => this,
      },

      'single mode' => switch (l10n.localeName) {
        'es' => 'Modo único',
        'hi' => 'सिंगल मोड',
        _ => this,
      },

      'add a note' => switch (l10n.localeName) {
        'es' => 'Añadir una nota',
        'hi' => 'एक नोट जोड़ें',
        _ => this,
      },

      'review history' => switch (l10n.localeName) {
        'es' => 'Revisar historial',
        'hi' => 'इतिहास की समीक्षा करें',
        _ => this,
      },

      'search notes' => switch (l10n.localeName) {
        'es' => 'Buscar notas',
        'hi' => 'नोट्स खोजें',
        _ => this,
      },

      'time between moments' => switch (l10n.localeName) {
        'es' => 'Tiempo entre momentos',
        'hi' => 'क्षणों के बीच का समय',
        _ => this,
      },

      'manage moment notes' => switch (l10n.localeName) {
        'es' => 'Gestionar notas de momentos',
        'hi' => 'क्षण नोट्स प्रबंधित करें',
        _ => this,
      },

      'app lock timing' => switch (l10n.localeName) {
        'es' => 'Tiempo de bloqueo de app',
        'hi' => 'ऐप लॉक समय',
        _ => this,
      },

      'minimal moment options' => switch (l10n.localeName) {
        'es' => 'Opciones mínimas de momentos',
        'hi' => 'न्यूनतम क्षण विकल्प',
        _ => this,
      },

      'adaptive engine' => switch (l10n.localeName) {
        'es' => 'Motor adaptativo',
        'hi' => 'अनुकूलन योग्य इंजन',
        _ => this,
      },

      'restore deleted moments' => switch (l10n.localeName) {
        'es' => 'Restaurar momentos eliminados',
        'hi' => 'हटाए गए मोमेंट्स पुनर्स्थापित करें',
        _ => this,
      },

      'back up data' => switch (l10n.localeName) {
        'es' => 'Copia de seguridad de datos',
        'hi' => 'डेटा का बैकअप लें',
        _ => this,
      },

      'can i restore deleted moments?' => switch (l10n.localeName) {
        'es' => '¿Puedo restaurar momentos eliminados?',
        'hi' => 'क्या मैं हटाए गए क्षणों को पुनर्स्थापित कर सकता हूँ?',
        _ => this,
      },

      'update check failed' => switch (l10n.localeName) {
        'es' => 'Fallo al comprobar actualizaciones',
        'hi' => 'अपडेट जांच विफल रही',
        _ => this,
      },

      'app notices are not appearing' => switch (l10n.localeName) {
        'es' => 'Los avisos de la app no aparecen',
        'hi' => 'ऐप सूचनाएं नहीं आ रही हैं',
        _ => this,
      },

      'notekar is offline' => switch (l10n.localeName) {
        'es' => 'NoteKar está sin conexión',
        'hi' => 'NoteKar ऑफ़लाइन है',
        _ => this,
      },

      'backup import found no new moments' => switch (l10n.localeName) {
        'es' =>
          'La importación de copia de seguridad no encontró nuevos momentos',
        'hi' => 'बैकअप आयात में कोई नया क्षण नहीं मिला',
        _ => this,
      },

      'backup import failed' => switch (l10n.localeName) {
        'es' => 'Fallo al importar copia de seguridad',
        'hi' => 'बैकअप आयात विफल रहा',
        _ => this,
      },

      'live icon motion will not turn on' => switch (l10n.localeName) {
        'es' => 'El movimiento de icono en vivo no se activa',
        'hi' => 'लाइव आइकन मोशन चालू नहीं होगा',
        _ => this,
      },

      'live icon motion looks slow or delayed' => switch (l10n.localeName) {
        'es' => 'El movimiento de icono en vivo parece lento o retrasado',
        'hi' => 'लाइव आइकन मोशन धीमा या विलंबित दिखता है',
        _ => this,
      },

      'app lock will not turn on' => switch (l10n.localeName) {
        'es' => 'El bloqueo de app no se activa',
        'hi' => 'ऐप लॉक चालू नहीं होगा',
        _ => this,
      },

      'notekar stores moments privately on this device. backups are files you control.' =>
        switch (l10n.localeName) {
          'es' =>
            'NoteKar guarda momentos de forma privada en este dispositivo. Las copias de seguridad son archivos que tú controlas.',
          'hi' =>
            'NoteKar इस डिवाइस पर क्षणों को निजी रूप से संग्रहीत करता है। बैकअप वे फाइलें हैं जिन्हें आप नियंत्रित करते हैं।',
          _ => this,
        },

      'select your preferred language for the application.' =>
        switch (l10n.localeName) {
          'es' => 'Selecciona tu idioma preferido para la aplicación.',
          'hi' => 'एप्लिकेशन के लिए अपनी पसंदीदा भाषा चुनें।',
          _ => this,
        },

      'the current features on this page are under beta stage.' =>
        switch (l10n.localeName) {
          'es' => 'Las funciones actuales de esta página están en fase Beta.',
          'hi' => 'इस पृष्ठ की वर्तमान विशेषताएं बीटा चरण में हैं।',
          _ => this,
        },

      'reminders' => switch (l10n.localeName) {
        'es' => 'Recordatorios',
        'hi' => 'अनुस्मारक',
        _ => this,
      },

      'logging reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio de registro',
        'hi' => 'लॉगिंग अनुस्मारक',
        _ => this,
      },

      'time to log a moment!' => switch (l10n.localeName) {
        'es' => '¡Hora de registrar un momento!',
        'hi' => 'क्षण लॉग करने का समय!',
        _ => this,
      },

      'daily reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio diario',
        'hi' => 'दैनिक अनुस्मारक',
        _ => this,
      },

      'inactivity reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio de inactividad',
        'hi' => 'निष्क्रियता अनुस्मारक',
        _ => this,
      },

      'weekly reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio semanal',
        'hi' => 'साप्ताहिक अनुस्मारक',
        _ => this,
      },

      'monthly reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio mensual',
        'hi' => 'मासिक अनुस्मारक',
        _ => this,
      },

      'remind if inactive for' => switch (l10n.localeName) {
        'es' => 'Recordar si está inactivo por',
        'hi' => 'निष्क्रिय होने पर याद दिलाएं',
        _ => this,
      },

      'days of week' => switch (l10n.localeName) {
        'es' => 'Días de la semana',
        'hi' => 'सप्ताह के दिन',
        _ => this,
      },

      'day of month' => switch (l10n.localeName) {
        'es' => 'Día del mes',
        'hi' => 'महीने का दिन',
        _ => this,
      },

      'trash bin' => switch (l10n.localeName) {
        'es' => 'Papelera',
        'hi' => 'कचरा पात्र',
        _ => this,
      },

      'current message' => switch (l10n.localeName) {
        'es' => 'Mensaje actual',
        'hi' => 'वर्तमान संदेश',
        _ => this,
      },

      'recent messages' => switch (l10n.localeName) {
        'es' => 'Mensajes recientes',
        'hi' => 'हाल के संदेश',
        _ => this,
      },

      'edit message' => switch (l10n.localeName) {
        'es' => 'Editar mensaje',
        'hi' => 'संदेश संपादित करें',
        _ => this,
      },

      'daily reminder message' => switch (l10n.localeName) {
        'es' => 'Mensaje de recordatorio diario',
        'hi' => 'दैनिक अनुस्मारक संदेश',
        _ => this,
      },

      'weekly reminder message' => switch (l10n.localeName) {
        'es' => 'Mensaje de recordatorio semanal',
        'hi' => 'साप्ताहिक अनुस्मारक संदेश',
        _ => this,
      },

      'monthly reminder message' => switch (l10n.localeName) {
        'es' => 'Mensaje de recordatorio mensual',
        'hi' => 'मासिक अनुस्मारक संदेश',
        _ => this,
      },

      'restore all moments?' => switch (l10n.localeName) {
        'es' => '¿Restaurar todos los momentos?',
        'hi' => 'सभी क्षण पुनर्स्थापित करें?',
        _ => this,
      },

      'this will return all items currently in the trash to your history.' =>
        switch (l10n.localeName) {
          'es' =>
            'Esto devolverá todos los elementos actualmente en la papelera a su historial.',
          'hi' =>
            'यह वर्तमान में कचरा पात्र में मौजूद सभी वस्तुओं को आपके इतिहास में वापस कर देगा।',
          _ => this,
        },

      'restore all' => switch (l10n.localeName) {
        'es' => 'Restaurar todo',
        'hi' => 'सभी को पुनर्स्थापित करें',
        _ => this,
      },

      'empty trash?' => switch (l10n.localeName) {
        'es' => '¿Vaciar papelera?',
        'hi' => 'कचरा पात्र खाली करें?',
        _ => this,
      },

      'this will permanently delete all moments in the trash. this action cannot be undone.' =>
        switch (l10n.localeName) {
          'es' =>
            'Esto eliminará permanentemente todos los momentos de la papelera. Esta acción no se puede deshacer.',
          'hi' =>
            'यह कचरा पात्र के सभी क्षणों को स्थायी रूप से हटा देगा। यह क्रिया पूर्ववत नहीं की जा सकती।',
          _ => this,
        },

      'delete permanently?' => switch (l10n.localeName) {
        'es' => '¿Eliminar permanentemente?',
        'hi' => 'स्थायी रूप से हटाएं?',
        _ => this,
      },

      'this moment will be erased forever.' => switch (l10n.localeName) {
        'es' => 'Este momento se borrará para siempre.',
        'hi' => 'यह क्षण हमेशा के लिए मिटा दिया जाएगा।',
        _ => this,
      },

      'item' => switch (l10n.localeName) {
        'es' => 'elemento',
        'hi' => 'वस्तु',
        _ => this,
      },

      'items' => switch (l10n.localeName) {
        'es' => 'elementos',
        'hi' => 'वस्तुओं',
        _ => this,
      },

      'no note' => switch (l10n.localeName) {
        'es' => 'Sin nota',
        'hi' => 'कोई नोट नहीं',
        _ => this,
      },

      'recently deleted' => switch (l10n.localeName) {
        'es' => 'ELIMINADO RECIENTEMENTE',
        'hi' => 'हाल ही में हटाया गया',
        _ => this,
      },

      'logs' => switch (l10n.localeName) {
        'es' => 'Registros',
        'hi' => 'लॉग्स',
        _ => this,
      },

      'notes' => switch (l10n.localeName) {
        'es' => 'Notas',
        'hi' => 'नोट्स',
        _ => this,
      },

      'alarms permission required' => switch (l10n.localeName) {
        'es' => 'Permiso de alarmas requerido',
        'hi' => 'अलार्म अनुमति आवश्यक है',
        _ => this,
      },

      'to trigger reminders precisely when the app is closed, notekar requires the "alarms & reminders" permission.' =>
        switch (l10n.localeName) {
          'es' =>
            'Para activar recordatorios con precisión cuando la aplicación está cerrada, NoteKar requiere el permiso de "Alarmas y recordatorios".',
          'hi' =>
            'ऐप बंद होने पर सटीक रूप से अनुस्मारक ट्रिगर करने के लिए, NoteKar को "अलार्म और अनुस्मारक" अनुमति की आवश्यकता होती है।',
          _ => this,
        },

      'grant permission' => switch (l10n.localeName) {
        'es' => 'Conceder permiso',
        'hi' => 'अनुमति दें',
        _ => this,
      },

      'battery optimization active' => switch (l10n.localeName) {
        'es' => 'Optimización de batería activa',
        'hi' => 'बैटरी ऑप्टिमाइज़ेशन सक्रिय',
        _ => this,
      },

      'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.' =>
        switch (l10n.localeName) {
          'es' =>
            'Los limpiadores de batería agresivos en dispositivos de gama baja pueden cerrar NoteKar en segundo plano. Desactiva la optimización de batería para garantizar que los recordatorios se activen siempre.',
          'hi' =>
            'कम-एंड डिवाइस पर आक्रामक बैटरी क्लीनर बैकग्राउंड में NoteKar को बंद कर सकते हैं। यह सुनिश्चित करने के लिए कि अनुस्मारक हमेशा समय पर मिलें, बैटरी ऑप्टिमाइज़ेशन को अक्षम करें।',
          _ => this,
        },

      'disable battery optimization' => switch (l10n.localeName) {
        'es' => 'Desactivar optimización de batería',
        'hi' => 'बैटरी ऑप्टिमाइज़ेशन अक्षम करें',
        _ => this,
      },

      'sun' => switch (l10n.localeName) {
        'es' => 'Dom',
        'hi' => 'रवि',
        _ => this,
      },

      'mon' => switch (l10n.localeName) {
        'es' => 'Lun',
        'hi' => 'सोम',
        _ => this,
      },

      'tue' => switch (l10n.localeName) {
        'es' => 'Mar',
        'hi' => 'मंगल',
        _ => this,
      },

      'wed' => switch (l10n.localeName) {
        'es' => 'Mié',
        'hi' => 'बुध',
        _ => this,
      },

      'thu' => switch (l10n.localeName) {
        'es' => 'Jue',
        'hi' => 'गुरु',
        _ => this,
      },

      'fri' => switch (l10n.localeName) {
        'es' => 'Vie',
        'hi' => 'शुक्र',
        _ => this,
      },

      'sat' => switch (l10n.localeName) {
        'es' => 'Sáb',
        'hi' => 'शनि',
        _ => this,
      },

      'sunday' => switch (l10n.localeName) {
        'es' => 'Domingo',
        'hi' => 'रविवार',
        _ => this,
      },

      'monday' => switch (l10n.localeName) {
        'es' => 'Lunes',
        'hi' => 'सोमवार',
        _ => this,
      },

      'tuesday' => switch (l10n.localeName) {
        'es' => 'Martes',
        'hi' => 'मंगलवार',
        _ => this,
      },

      'wednesday' => switch (l10n.localeName) {
        'es' => 'Miércoles',
        'hi' => 'बुधवार',
        _ => this,
      },

      'thursday' => switch (l10n.localeName) {
        'es' => 'Jueves',
        'hi' => 'गुरुवार',
        _ => this,
      },

      'friday' => switch (l10n.localeName) {
        'es' => 'Viernes',
        'hi' => 'शुक्रवार',
        _ => this,
      },

      'saturday' => switch (l10n.localeName) {
        'es' => 'Sábado',
        'hi' => 'शनिवार',
        _ => this,
      },

      'time' => switch (l10n.localeName) {
        'es' => 'Hora',
        'hi' => 'समय',
        _ => this,
      },

      'message' => switch (l10n.localeName) {
        'es' => 'Mensaje',
        'hi' => 'संदेश',
        _ => this,
      },

      'empty' => switch (l10n.localeName) {
        'es' => 'Vacío',
        'hi' => 'खाली',
        _ => this,
      },

      'set' => switch (l10n.localeName) {
        'es' => 'Establecido',
        'hi' => 'सेट',
        _ => this,
      },

      'hour' => switch (l10n.localeName) {
        'es' => 'hora',
        'hi' => 'घंटा',
        _ => this,
      },

      'hours' => switch (l10n.localeName) {
        'es' => 'horas',
        'hi' => 'घंटे',
        _ => this,
      },

      'enter reminder message...' => switch (l10n.localeName) {
        'es' => 'Ingresar mensaje de recordatorio...',
        'hi' => 'अनुस्मारक संदेश दर्ज करें...',
        _ => this,
      },

      'official repository moved' => switch (l10n.localeName) {
        'es' => 'Repositorio oficial movido',
        'hi' => 'आधिकारिक रिपॉजिटरी बदली',
        _ => this,
      },

      'we have officially migrated our codebase to a new home. all future releases, updates, and issues will be managed here:' =>
        switch (l10n.localeName) {
          'es' =>
            'Hemos migrado oficialmente nuestro código base a un nuevo hogar. Todos los lanzamientos, actualizaciones y problemas futuros se gestionarán aquí:',
          'hi' =>
            'हमने आधिकारिक तौर पर अपने कोडबेस को एक नए घर में स्थानांतरित कर दिया है। सभी भविष्य के रिलीज, अपडेट और मुद्दे यहां प्रबंधित किए जाएंगे:',
          _ => this,
        },

      'smaller, optimized apks' => switch (l10n.localeName) {
        'es' => 'APKs más pequeñas y optimizadas',
        'hi' => 'छोटे, अनुकूलित एपीके',
        _ => this,
      },

      'access split-per-abi optimized binaries and google play appbundles directly from the release page.' =>
        switch (l10n.localeName) {
          'es' =>
            'Acceda a binarios optimizados por ABI y Google Play AppBundles directamente desde la página de lanzamiento.',
          'hi' =>
            'रिलीज़ पेज से सीधे स्प्लिट-प्रति-एबीआई अनुकूलित बायनेरिज़ और गूगल प्ले ऐपबंडल प्राप्त करें।',
          _ => this,
        },

      'active issue tracking' => switch (l10n.localeName) {
        'es' => 'Seguimiento de problemas activo',
        'hi' => 'सक्रिय समस्या ट्रैकिंग',
        _ => this,
      },

      'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.' =>
        switch (l10n.localeName) {
          'es' =>
            'Envíe informes de errores, solicitudes de funciones y siga los cambios de código directamente en el nuevo rastreador de problemas.',
          'hi' =>
            'सीधे नए रिपॉजिटरी इशू ट्रैकर में बग रिपोर्ट, फीचर अनुरोध सबमिट करें और कोड परिवर्तनों का पालन करें।',
          _ => this,
        },

      'automated security scans' => switch (l10n.localeName) {
        'es' => 'Escaneos de seguridad automáticos',
        'hi' => 'स्वचालित सुरक्षा स्कैन',
        _ => this,
      },

      'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.' =>
        switch (l10n.localeName) {
          'es' =>
            'Todas las compilaciones ahora se someten a escaneos automáticos de CodeQL y comprobaciones de VirusTotal para garantizar la verificación y la seguridad.',
          'hi' =>
            'सत्यापन और सुरक्षा सुनिश्चित करने के लिए सभी निर्माण अब स्वचालित CodeQL स्कैन और VirusTotal जांच से गुजरते हैं।',
          _ => this,
        },

      'virustotal safety scan' => switch (l10n.localeName) {
        'es' => 'Escaneo de seguridad de VirusTotal',
        'hi' => 'VirusTotal सुरक्षा स्कैन',
        _ => this,
      },

      'verified clean of malicious activity' => switch (l10n.localeName) {
        'es' => 'Verificado limpio de actividad maliciosa',
        'hi' => 'दुर्भावनापूर्ण गतिविधि से मुक्त सत्यापित',
        _ => this,
      },

      'ratio' => switch (l10n.localeName) {
        'es' => 'Proporción',
        'hi' => 'अनुपात',
        _ => this,
      },

      '0 / 68 clean' => switch (l10n.localeName) {
        'es' => '0 / 68 limpio',
        'hi' => '0 / 68 स्वच्छ',
        _ => this,
      },

      'status' => switch (l10n.localeName) {
        'es' => 'Estado',
        'hi' => 'स्थिति',
        _ => this,
      },

      'undetected' => switch (l10n.localeName) {
        'es' => 'No detectado',
        'hi' => 'अपरिचित (सुरक्षित)',
        _ => this,
      },

      'last scan' => switch (l10n.localeName) {
        'es' => 'Último escaneo',
        'hi' => 'अंतिम स्कैन',
        _ => this,
      },

      'july 2026' => switch (l10n.localeName) {
        'es' => 'Julio de 2026',
        'hi' => 'जुलाई २०२६',
        _ => this,
      },

      'signature' => switch (l10n.localeName) {
        'es' => 'Firma',
        'hi' => 'हस्ताक्षर',
        _ => this,
      },

      'developer key' => switch (l10n.localeName) {
        'es' => 'Clave del desarrollador',
        'hi' => 'डेवलपर कुंजी',
        _ => this,
      },

      'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.' =>
        switch (l10n.localeName) {
          'es' =>
            'Las compilaciones de NoteKar se someten a compilación automatizada del escáner CodeQL y escaneos locales de VirusTotal. Los binarios están firmados con nuestro certificado oficial para garantizar una integridad absoluta.',
          'hi' =>
            'NoteKar का प्रत्येक संकलन स्वचालित CodeQL स्कैनर संकलन और स्थानीय VirusTotal स्कैन से गुजरता है। पूर्ण अखंडता सुनिश्चित करने के लिए बाइनरी को हमारे आधिकारिक प्रमाणपत्र के साथ हस्ताक्षरित किया गया है।',
          _ => this,
        },

      'vt report' => switch (l10n.localeName) {
        'es' => 'Informe de VT',
        'hi' => 'VT रिपोर्ट',
        _ => this,
      },

      'sha-256 hashes' => switch (l10n.localeName) {
        'es' => 'Hashes SHA-256',
        'hi' => 'SHA-256 हैश',
        _ => this,
      },

      'is notekar safe to use?' => switch (l10n.localeName) {
        'es' => '¿Es seguro usar NoteKar?',
        'hi' => 'क्या NoteKar उपयोग करने के लिए सुरक्षित है?',
        _ => this,
      },

      'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.' =>
        switch (l10n.localeName) {
          'es' =>
            'Absolutamente. NoteKar es de código abierto y local primero. Para garantizar la máxima confianza y seguridad, cada versión compilada se carga automáticamente y se verifica limpia por más de 60 motores de seguridad a través de VirusTotal. Puede inspeccionar el informe de escaneo en vivo en Privacidad y seguridad.',
          'hi' =>
            'बिल्कुल। NoteKar ओपन-सोर्स और ऑफलाइन-फर्स्ट है। अधिकतम विश्वास और सुरक्षा की गारंटी के लिए, प्रत्येक संकलित रिलीज़ को स्वचालित रूप से अपलोड किया जाता है और VirusTotal के माध्यम से 60+ सुरक्षा इंजनों द्वारा स्वच्छ सत्यापित किया जाता है। आप गोपनीयता और सुरक्षा के तहत लाइव स्कैन रिपोर्ट का निरीक्षण कर सकते हैं।',
          _ => this,
        },

      'open link' => switch (l10n.localeName) {
        'es' => 'Abrir enlace',
        'hi' => 'लिंक खोलें',
        _ => this,
      },

      'copy' => switch (l10n.localeName) {
        'es' => 'Copiar',
        'hi' => 'कॉपी',
        _ => this,
      },

      'repository link copied to clipboard' => switch (l10n.localeName) {
        'es' => 'Enlace del repositorio copiado al portapapeles',
        'hi' => 'रिपॉजिटरी लिंक क्लिपबोर्ड पर कॉपी किया गया',
        _ => this,
      },

      'disable compact history?' => switch (l10n.localeName) {
        'es' => '¿Desactivar historial compacto?',
        'hi' => 'कॉम्पैक्ट इतिहास अक्षम करें?',
        _ => this,
      },

      'turn off single numbers?' => switch (l10n.localeName) {
        'es' => '¿Desactivar números individuales?',
        'hi' => 'सिंगल नंबर बंद करें?',
        _ => this,
      },

      'turn off & enable' => switch (l10n.localeName) {
        'es' => 'Desactivar y activar',
        'hi' => 'अक्षम करें और सक्रिय करें',
        _ => this,
      },

      'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.' =>
        switch (l10n.localeName) {
          'es' =>
            'La numeración secuencial (00–99) requiere espaciado estándar para mostrar insignias de 2 dígitos. Desactive el historial compacto para habilitar números.',
          'hi' =>
            'अनुक्रमिक एकल क्रमांकन (00–99) को 2-अंकीय बैज प्रदर्शित करने के लिए मानक पंक्ति रिक्ति की आवश्यकता होती है। सिंगल मोड में संख्याओं को सक्षम करने के लिए कॉम्पैक्ट इतिहास को बंद करें।',
          _ => this,
        },

      'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.' =>
        switch (l10n.localeName) {
          'es' =>
            'El historial compacto no se puede activar mientras la numeración de momentos individuales esté activa. Desactive los números para usar filas compactas.',
          'hi' =>
            'सिंगल मोमेंट नंबरिंग सक्रिय होने पर कॉम्पैक्ट इतिहास को सक्षम नहीं किया जा सकता है। कॉम्पैक्ट पंक्तियों का उपयोग करने के लिए सिंगल नंबर को बंद करें।',
          _ => this,
        },

      'numbered single moments' => switch (l10n.localeName) {
        'es' => 'Momentos individuales numerados',
        'hi' => 'क्रमांकित एकल क्षण',
        _ => this,
      },

      'use numbers in single' => switch (l10n.localeName) {
        'es' => 'Usar números en individual',
        'hi' => 'सिंगल में नंबर का उपयोग करें',
        _ => this,
      },

      'reset daily' => switch (l10n.localeName) {
        'es' => 'Restablecer diariamente',
        'hi' => 'प्रतिदिन रीसेट करें',
        _ => this,
      },

      'enable count on save' => switch (l10n.localeName) {
        'es' => 'Activar conteo al guardar',
        'hi' => 'सहेजने पर गिनती सक्षम करें',
        _ => this,
      },

      'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.' =>
        switch (l10n.localeName) {
          'es' =>
            'Transforma tu historial con contadores secuenciales de 2 dígitos (00–99), reinicios diarios y un calendario estilo iOS.',
          'hi' =>
            'अनुक्रमिक 2-अंकीय काउंटरों (00–99), दैनिक मध्यरात्रि रीसेट और iOS शैली कैलेंडर के साथ अपने इतिहास को बदलें।',
          _ => this,
        },

      'restarts count at 00 every midnight while keeping past history intact.' =>
        switch (l10n.localeName) {
          'es' =>
            'Reinicia el conteo en 00 cada medianoche manteniendo el historial anterior.',
          'hi' =>
            'पिछले इतिहास को बरकरार रखते हुए हर मध्यरात्रि को 00 पर गिनती फिर से शुरू करता है।',
          _ => this,
        },

      'shows sequential numbers (00, 01...) on the tap pulse animation.' =>
        switch (l10n.localeName) {
          'es' =>
            'Muestra números secuenciales (00, 01...) en la animación de pulsación.',
          'hi' =>
            'टैप पल्स एनिमेशन पर अनुक्रमिक संख्याएं (00, 01...) दिखाता है।',
          _ => this,
        },

      'moment saved' => switch (l10n.localeName) {
        'es' => 'Momento guardado',
        'hi' => 'क्षण सहेजा गया',
        _ => this,
      },

      'undo' => switch (l10n.localeName) {
        'es' => 'Deshacer',
        'hi' => 'पूर्ववत करें',
        _ => this,
      },

      'settings restored' => switch (l10n.localeName) {
        'es' => 'Ajustes restaurados',
        'hi' => 'सेटिंग्स बहाल की गईं',
        _ => this,
      },

      'loading database...' => switch (l10n.localeName) {
        'es' => 'Cargando base de datos...',
        'hi' => 'डेटाबेस लोड हो रहा है...',
        _ => this,
      },

      'add a note to save' => switch (l10n.localeName) {
        'es' => 'Agrega una nota para guardar',
        'hi' => 'सहेजने के लिए एक नोट जोड़ें',
        _ => this,
      },

      'enable show seconds first' => switch (l10n.localeName) {
        'es' => 'Activa Mostrar segundos primero',
        'hi' => 'पहले सेकंड दिखाना सक्षम करें',
        _ => this,
      },

      'link copied' => switch (l10n.localeName) {
        'es' => 'Enlace copiado',
        'hi' => 'लिंक कॉपी किया गया',
        _ => this,
      },

      'notification permission needed' => switch (l10n.localeName) {
        'es' => 'Permiso de notificación requerido',
        'hi' => 'सूचना अनुमति आवश्यक है',
        _ => this,
      },

      'export saved to downloads' => switch (l10n.localeName) {
        'es' => 'Exportación guardada en Descargas',
        'hi' => 'निर्यात डाउनलोड में सहेजा गया',
        _ => this,
      },

      'export failed. try again.' => switch (l10n.localeName) {
        'es' => 'Error al exportar. Inténtalo de nuevo.',
        'hi' => 'निर्यात विफल रहा। पुन: प्रयास करें।',
        _ => this,
      },

      'quick local backup created' => switch (l10n.localeName) {
        'es' => 'Copia de seguridad local creada',
        'hi' => 'त्वरित स्थानीय बैकअप बनाया गया',
        _ => this,
      },

      'failed to create local backup' => switch (l10n.localeName) {
        'es' => 'Error al crear copia local',
        'hi' => 'स्थानीय बैकअप बनाने में विफल',
        _ => this,
      },

      'in-app pin set successfully.' => switch (l10n.localeName) {
        'es' => 'PIN en la aplicación configurado con éxito.',
        'hi' => 'इन-ऐप पिन सफलतापूर्वक सेट किया गया।',
        _ => this,
      },

      'system lock enabled' => switch (l10n.localeName) {
        'es' => 'Bloqueo del sistema activado',
        'hi' => 'सिस्टम लॉक सक्षम किया गया',
        _ => this,
      },

      'app icon could not be changed' => switch (l10n.localeName) {
        'es' => 'No se pudo cambiar el icono de la aplicación',
        'hi' => 'ऐप आइकन बदला नहीं जा सका',
        _ => this,
      },

      'could not open backup file' => switch (l10n.localeName) {
        'es' => 'No se pudo abrir el archivo de respaldo',
        'hi' => 'बैकअप फ़ाइल नहीं खोली जा सकी',
        _ => this,
      },

      'import cancelled' => switch (l10n.localeName) {
        'es' => 'Importación cancelada',
        'hi' => 'आयात रद्द किया गया',
        _ => this,
      },

      'invalid backup file' => switch (l10n.localeName) {
        'es' => 'Archivo de respaldo no válido',
        'hi' => 'अमान्य बैकअप फ़ाइल',
        _ => this,
      },

      'backup has no new moments' => switch (l10n.localeName) {
        'es' => 'El respaldo no tiene nuevos momentos',
        'hi' => 'बैकअप में कोई नया क्षण नहीं है',
        _ => this,
      },

      'this backup contains no moments' => switch (l10n.localeName) {
        'es' => 'Este respaldo no contiene momentos',
        'hi' => 'इस बैकअप में कोई क्षण नहीं है',
        _ => this,
      },

      'turn off reduced motion first' => switch (l10n.localeName) {
        'es' => 'Desactiva Reducir movimiento primero',
        'hi' => 'पहले कम गति बंद करें',
        _ => this,
      },

      'motion sensor unavailable' => switch (l10n.localeName) {
        'es' => 'Sensor de movimiento no disponible',
        'hi' => 'गति संवेदक अनुपलब्ध',
        _ => this,
      },

      'backup reminder: export a fresh backup soon' =>
        switch (l10n.localeName) {
          'es' => 'Recordatorio de respaldo: exporta una copia pronto',
          'hi' => 'बैकअप अनुस्मारक: जल्द ही एक नया बैकअप निर्यात करें',
          _ => this,
        },

      'streak shield deployed! clean streak protected.' =>
        switch (l10n.localeName) {
          'es' => '¡Escudo de racha desplegado! Racha protegida.',
          'hi' => 'संयम ढाल तैनात! संयम सुरक्षित।',
          _ => this,
        },

      'storage error: moment not saved' => switch (l10n.localeName) {
        'es' => 'Error de almacenamiento: momento no guardado',
        'hi' => 'स्टोरेज त्रुटि: क्षण सहेजा नहीं गया',
        _ => this,
      },

      'beta feature' => switch (l10n.localeName) {
        'es' => 'Función Beta',
        'hi' => 'बीटा सुविधा',
        _ => this,
      },

      'this feature is currently in active development. while fully functional and secure, you may notice minor adjustments to the layout or performance as we refine the experience. all calculations, data, and security policies remain entirely local to your device.' =>
        switch (l10n.localeName) {
          'es' =>
            'Esta función se encuentra en desarrollo activo. Aunque es totalmente funcional y segura, es posible que note ajustes menores en el diseño. Todos los cálculos y datos permanecen en su dispositivo.',
          'hi' =>
            'यह सुविधा वर्तमान में सक्रिय विकास में है। हालांकि यह पूरी तरह कार्यात्मक और सुरक्षित है। सभी गणना और डेटा आपके डिवाइस पर स्थानीय रहते हैं।',
          _ => this,
        },

      'have suggestions or found a bug?' => switch (l10n.localeName) {
        'es' => '¿Tienes sugerencias o encontraste un error?',
        'hi' => 'क्या आपके पास सुझाव हैं या कोई बग मिला?',
        _ => this,
      },

      '* have suggestions or found a bug? ' => switch (l10n.localeName) {
        'es' => '* ¿Tienes sugerencias o encontraste un error? ',
        'hi' => '* क्या आपके पास सुझाव हैं या कोई बग मिला? ',
        _ => this,
      },

      'give feedback' => switch (l10n.localeName) {
        'es' => 'Dar opinión',
        'hi' => 'प्रतिक्रिया दें',
        _ => this,
      },

      'got it' => switch (l10n.localeName) {
        'es' => 'Entendido',
        'hi' => 'समझ गया',
        _ => this,
      },

      'learn more' => switch (l10n.localeName) {
        'es' => 'Más información',
        'hi' => 'और जानें',
        _ => this,
      },

      'tools' => switch (l10n.localeName) {
        'es' => 'Herramientas',
        'hi' => 'उपकरण',
        _ => this,
      },

      'wipe' => switch (l10n.localeName) {
        'es' => 'Borrar',
        'hi' => 'मिटाएं',
        _ => this,
      },

      'active' => switch (l10n.localeName) {
        'es' => 'Activo',
        'hi' => 'सक्रिय',
        _ => this,
      },

      'inactive' => switch (l10n.localeName) {
        'es' => 'Inactivo',
        'hi' => 'निष्क्रिय',
        _ => this,
      },

      'startup mode' => switch (l10n.localeName) {
        'es' => 'Modo de inicio',
        'hi' => 'स्टार्टअप मोड',
        _ => this,
      },

      'choose how notekar starts when you open it' => switch (l10n.localeName) {
        'es' => 'Elige cómo inicia NoteKar al abrirlo',
        'hi' => 'चुनें कि NoteKar खोलने पर कैसे शुरू हो',
        _ => this,
      },

      'choose language' => switch (l10n.localeName) {
        'es' => 'Elegir idioma',
        'hi' => 'भाषा चुनें',
        _ => this,
      },

      'select your preferred interface language. you can change this anytime in settings.' =>
        switch (l10n.localeName) {
          'es' =>
            'Selecciona tu idioma preferido. Puedes cambiarlo en cualquier momento en Ajustes.',
          'hi' =>
            'अपनी पसंदीदा भाषा चुनें। आप इसे सेटिंग्स में कभी भी बदल सकते हैं।',
          _ => this,
        },

      'no moments logged yet' => switch (l10n.localeName) {
        'es' => 'Aún no hay momentos registrados',
        'hi' => 'अभी तक कोई क्षण दर्ज नहीं किया गया है',
        _ => this,
      },

      'no moments' => switch (l10n.localeName) {
        'es' => 'Sin momentos',
        'hi' => 'कोई क्षण नहीं',
        _ => this,
      },

      'no notes found' => switch (l10n.localeName) {
        'es' => 'No se encontraron notas',
        'hi' => 'कोई नोट नहीं मिला',
        _ => this,
      },

      'no search results found' => switch (l10n.localeName) {
        'es' => 'No se encontraron resultados',
        'hi' => 'कोई खोज परिणाम नहीं मिला',
        _ => this,
      },

      'try another keyword' => switch (l10n.localeName) {
        'es' => 'Prueba con otra palabra clave',
        'hi' => 'कोई अन्य कीवर्ड आज़माएं',
        _ => this,
      },

      'trash is empty' => switch (l10n.localeName) {
        'es' => 'La papelera está vacía',
        'hi' => 'कचरा खाली है',
        _ => this,
      },

      'moment options' => switch (l10n.localeName) {
        'es' => 'Opciones del momento',
        'hi' => 'क्षण विकल्प',
        _ => this,
      },

      'copy moment' => switch (l10n.localeName) {
        'es' => 'Copiar momento',
        'hi' => 'क्षण कॉपी करें',
        _ => this,
      },

      'edit note' => switch (l10n.localeName) {
        'es' => 'Editar nota',
        'hi' => 'नोट संपादित करें',
        _ => this,
      },

      'delete moment' => switch (l10n.localeName) {
        'es' => 'Eliminar momento',
        'hi' => 'क्षण हटाएं',
        _ => this,
      },

      'select for duration' => switch (l10n.localeName) {
        'es' => 'Seleccionar para duración',
        'hi' => 'अवधि के लिए चुनें',
        _ => this,
      },

      'view note' => switch (l10n.localeName) {
        'es' => 'Ver nota',
        'hi' => 'नोट देखें',
        _ => this,
      },

      'delete all moments?' => switch (l10n.localeName) {
        'es' => '¿Eliminar todos los momentos?',
        'hi' => 'क्या सभी क्षण हटाएं?',
        _ => this,
      },

      'this will permanently delete all moments. this action cannot be undone.' =>
        switch (l10n.localeName) {
          'es' =>
            'Esto eliminará permanentemente todos los momentos. Esta acción no se puede deshacer.',
          'hi' =>
            'यह सभी क्षणों को स्थायी रूप से हटा देगा। इस क्रिया को पूर्ववत नहीं किया जा सकता है।',
          _ => this,
        },

      'type to search your notes...' => switch (l10n.localeName) {
        'es' => 'Escribe para buscar tus notas...',
        'hi' => 'अपने नोट्स खोजने के लिए टाइप करें...',
        _ => this,
      },

      'no matching notes' => switch (l10n.localeName) {
        'es' => 'No hay notas coincidentes',
        'hi' => 'कोई मेल खाते नोट नहीं मिले',
        _ => this,
      },

      'enter passcode' => switch (l10n.localeName) {
        'es' => 'Ingresar código de acceso',
        'hi' => 'पासकोड दर्ज करें',
        _ => this,
      },

      'set passcode' => switch (l10n.localeName) {
        'es' => 'Establecer código de acceso',
        'hi' => 'पासकोड सेट करें',
        _ => this,
      },

      'confirm passcode' => switch (l10n.localeName) {
        'es' => 'Confirmar código de acceso',
        'hi' => 'पासकोड की पुष्टि करें',
        _ => this,
      },

      'passcodes do not match' => switch (l10n.localeName) {
        'es' => 'Los códigos de acceso no coinciden',
        'hi' => 'पासकोड मेल नहीं खाते',
        _ => this,
      },

      'incorrect passcode' => switch (l10n.localeName) {
        'es' => 'Código de acceso incorrecto',
        'hi' => 'गलत पासकोड',
        _ => this,
      },

      'try again in seconds' => switch (l10n.localeName) {
        'es' => 'Inténtalo de nuevo en unos segundos',
        'hi' => 'कुछ सेकंड में पुन: प्रयास करें',
        _ => this,
      },

      'biometrics not available' => switch (l10n.localeName) {
        'es' => 'Biometría no disponible',
        'hi' => 'बायोमेट्रिक्स उपलब्ध नहीं है',
        _ => this,
      },

      'these settings refine the interface aesthetic and do not modify your saved data.' =>
        switch (l10n.localeName) {
          'es' =>
            'Estos ajustes refinan la estética de la interfaz y no modifican tus datos guardados.',
          'hi' =>
            'ये सेटिंग्स इंटरफ़ेस सौंदर्य को परिष्कृत करती हैं और आपके सहेजे गए डेटा को संशोधित नहीं करती हैं।',
          _ => this,
        },

      'export, import, and manage your data backups.' =>
        switch (l10n.localeName) {
          'es' =>
            'Exporta, importa y administra tus copias de seguridad de datos.',
          'hi' => 'अपना डेटा बैकअप निर्यात, आयात और प्रबंधित करें।',
          _ => this,
        },

      'diagnostics and internal engine settings for developers.' =>
        switch (l10n.localeName) {
          'es' =>
            'Diagnósticos y ajustes del motor interno para desarrolladores.',
          'hi' => 'डेवलपर्स के लिए निदान और आंतरिक इंजन सेटिंग्स।',
          _ => this,
        },

      '100% offline integrity' => switch (l10n.localeName) {
        'es' => 'Integridad 100% sin conexión',
        'hi' => '100% ऑफलाइन अखंडता',
        _ => this,
      },

      '16-week habit activity grid' => switch (l10n.localeName) {
        'es' => 'Cuadrícula de actividad de hábitos de 16 semanas',
        'hi' => '16-सप्ताह की आदत गतिविधि ग्रिड',
        _ => this,
      },

      '5-4-3-2-1 grounding' => switch (l10n.localeName) {
        'es' => 'Técnica de anclaje 5-4-3-2-1',
        'hi' => '5-4-3-2-1 ग्राउंडिंग तकनीक',
        _ => this,
      },

      'accept' => switch (l10n.localeName) {
        'es' => 'Aceptar',
        'hi' => 'स्वीकार करें',
        _ => this,
      },

      'active launcher icon' => switch (l10n.localeName) {
        'es' => 'Icono de inicio activo',
        'hi' => 'सक्रिय लॉन्चर आइकन',
        _ => this,
      },

      'activity' => switch (l10n.localeName) {
        'es' => 'Actividad',
        'hi' => 'गतिविधि',
        _ => this,
      },

      'allow app installation' => switch (l10n.localeName) {
        'es' => 'Permitir instalación de apps',
        'hi' => 'ऐप स्थापना की अनुमति दें',
        _ => this,
      },

      'allow auto-start settings' => switch (l10n.localeName) {
        'es' => 'Permitir inicio automático',
        'hi' => 'ऑटो-स्टार्ट सेटिंग्स की अनुमति दें',
        _ => this,
      },

      'android backup' => switch (l10n.localeName) {
        'es' => 'Copia de seguridad de Android',
        'hi' => 'एंड्रॉइड बैकअप',
        _ => this,
      },

      'app lock needs a device screen lock' => switch (l10n.localeName) {
        'es' => 'El bloqueo de app necesita un bloqueo de pantalla',
        'hi' => 'ऐप लॉक के लिए डिवाइस स्क्रीन लॉक आवश्यक है',
        _ => this,
      },

      'app switcher obfuscation' => switch (l10n.localeName) {
        'es' => 'Ocultación en cambio de app',
        'hi' => 'ऐप स्विचर में छुपाना',
        _ => this,
      },

      'app usage' => switch (l10n.localeName) {
        'es' => 'Uso de la aplicación',
        'hi' => 'ऐप का उपयोग',
        _ => this,
      },

      'applying app icon' => switch (l10n.localeName) {
        'es' => 'Aplicando icono de app',
        'hi' => 'ऐप आइकन लागू हो रहा है',
        _ => this,
      },

      'auto-start & background activity' => switch (l10n.localeName) {
        'es' => 'Inicio automático y actividad en segundo plano',
        'hi' => 'ऑटो-स्टार्ट और बैकग्राउंड गतिविधि',
        _ => this,
      },

      'back' => switch (l10n.localeName) {
        'es' => 'Atrás',
        'hi' => 'पीछे',
        _ => this,
      },

      'backup status' => switch (l10n.localeName) {
        'es' => 'Estado de la copia',
        'hi' => 'बैकअप स्थिति',
        _ => this,
      },

      'beta' => switch (l10n.localeName) {
        'es' => 'Beta',
        'hi' => 'बीटा',
        _ => this,
      },

      'box breathing' => switch (l10n.localeName) {
        'es' => 'Respiración cuadrada',
        'hi' => 'बॉक्स ब्रीदिंग',
        _ => this,
      },

      'build cache cleared' => switch (l10n.localeName) {
        'es' => 'Caché de compilación borrada',
        'hi' => 'बिल्ड कैश साफ़ किया गया',
        _ => this,
      },

      'build cache size' => switch (l10n.localeName) {
        'es' => 'Tamaño de caché de compilación',
        'hi' => 'बिल्ड कैश आकार',
        _ => this,
      },

      'check again' => switch (l10n.localeName) {
        'es' => 'Comprobar de nuevo',
        'hi' => 'पुनः जांचें',
        _ => this,
      },

      'check for updates' => switch (l10n.localeName) {
        'es' => 'Buscar actualizaciones',
        'hi' => 'अपडेट के लिए जांचें',
        _ => this,
      },

      'checking for updates...' => switch (l10n.localeName) {
        'es' => 'Buscando actualizaciones...',
        'hi' => 'अपडेट की जांच हो रही है...',
        _ => this,
      },

      'clear' => switch (l10n.localeName) {
        'es' => 'Borrar',
        'hi' => 'साफ़ करें',
        _ => this,
      },

      'commits' => switch (l10n.localeName) {
        'es' => 'Commits',
        'hi' => 'कमिट्स',
        _ => this,
      },

      'continue' => switch (l10n.localeName) {
        'es' => 'Continuar',
        'hi' => 'जारी रखें',
        _ => this,
      },

      'create quick local backup' => switch (l10n.localeName) {
        'es' => 'Crear copia de seguridad local rápida',
        'hi' => 'त्वरित स्थानीय बैकअप बनाएं',
        _ => this,
      },

      'daily neuroscience insight' => switch (l10n.localeName) {
        'es' => 'Información diaria de neurociencia',
        'hi' => 'दैनिक न्यूरोसाइंस अंतर्दृष्टि',
        _ => this,
      },

      'data' => switch (l10n.localeName) {
        'es' => 'Datos',
        'hi' => 'डेटा',
        _ => this,
      },

      'data consumed' => switch (l10n.localeName) {
        'es' => 'Datos consumidos',
        'hi' => 'डेटा खपत',
        _ => this,
      },

      'data health' => switch (l10n.localeName) {
        'es' => 'Salud de datos',
        'hi' => 'डेटा स्वास्थ्य',
        _ => this,
      },

      'delete backup?' => switch (l10n.localeName) {
        'es' => '¿Eliminar copia de seguridad?',
        'hi' => 'क्या बैकअप हटाएं?',
        _ => this,
      },

      'delete cache' => switch (l10n.localeName) {
        'es' => 'Eliminar caché',
        'hi' => 'कैश हटाएं',
        _ => this,
      },

      'delete permanently' => switch (l10n.localeName) {
        'es' => 'Eliminar permanentemente',
        'hi' => 'स्थायी रूप से हटाएं',
        _ => this,
      },

      'deleting cache...' => switch (l10n.localeName) {
        'es' => 'Eliminando caché...',
        'hi' => 'कैश हटाया जा रहा है...',
        _ => this,
      },

      'dev' => switch (l10n.localeName) {
        'es' => 'Desarrollo',
        'hi' => 'डेव',
        _ => this,
      },

      'device health' => switch (l10n.localeName) {
        'es' => 'Salud del dispositivo',
        'hi' => 'डिवाइस स्वास्थ्य',
        _ => this,
      },

      'disabled' => switch (l10n.localeName) {
        'es' => 'Desactivado',
        'hi' => 'अक्षम',
        _ => this,
      },

      'dismiss' => switch (l10n.localeName) {
        'es' => 'Descartar',
        'hi' => 'खारिज करें',
        _ => this,
      },

      'download' => switch (l10n.localeName) {
        'es' => 'Descargar',
        'hi' => 'डाउनलोड',
        _ => this,
      },

      'download & install' => switch (l10n.localeName) {
        'es' => 'Descargar e instalar',
        'hi' => 'डाउनलोड और इंस्टॉल करें',
        _ => this,
      },

      'download failed' => switch (l10n.localeName) {
        'es' => 'Descarga fallida',
        'hi' => 'डाउनलोड विफल',
        _ => this,
      },

      'download from github' => switch (l10n.localeName) {
        'es' => 'Descargar desde GitHub',
        'hi' => 'GitHub से डाउनलोड करें',
        _ => this,
      },

      'download size:' => switch (l10n.localeName) {
        'es' => 'Tamaño de descarga:',
        'hi' => 'डाउनलोड आकार:',
        _ => this,
      },

      'downloading update...' => switch (l10n.localeName) {
        'es' => 'Descargando actualización...',
        'hi' => 'अपडेट डाउनलोड हो रहा है...',
        _ => this,
      },

      'empty trash' => switch (l10n.localeName) {
        'es' => 'Vaciar papelera',
        'hi' => 'कचरा खाली करें',
        _ => this,
      },

      'encrypted backup' => switch (l10n.localeName) {
        'es' => 'Copia cifrada',
        'hi' => 'एन्क्रिप्टेड बैकअप',
        _ => this,
      },

      'endpoint url' => switch (l10n.localeName) {
        'es' => 'URL del endpoint',
        'hi' => 'एंडपॉइंट URL',
        _ => this,
      },

      'essential features' => switch (l10n.localeName) {
        'es' => 'Funciones esenciales',
        'hi' => 'आवश्यक सुविधाएं',
        _ => this,
      },

      'export backup' => switch (l10n.localeName) {
        'es' => 'Exportar copia',
        'hi' => 'बैकअप निर्यात करें',
        _ => this,
      },

      'export csv' => switch (l10n.localeName) {
        'es' => 'Exportar CSV',
        'hi' => 'CSV निर्यात करें',
        _ => this,
      },

      'export json' => switch (l10n.localeName) {
        'es' => 'Exportar JSON',
        'hi' => 'JSON निर्यात करें',
        _ => this,
      },

      'export last 7 days' => switch (l10n.localeName) {
        'es' => 'Exportar últimos 7 días',
        'hi' => 'पिछले 7 दिनों का निर्यात करें',
        _ => this,
      },

      'export milestone card' => switch (l10n.localeName) {
        'es' => 'Exportar tarjeta de hito',
        'hi' => 'मील का पत्थर कार्ड निर्यात करें',
        _ => this,
      },

      'external navigation' => switch (l10n.localeName) {
        'es' => 'Navegación externa',
        'hi' => 'बाहरी नेविगेशन',
        _ => this,
      },

      'factory reset' => switch (l10n.localeName) {
        'es' => 'Restablecimiento de fábrica',
        'hi' => 'फ़ैक्टरी रीसेट',
        _ => this,
      },

      'failed to read local backup file' => switch (l10n.localeName) {
        'es' => 'Error al leer archivo de respaldo local',
        'hi' => 'स्थानीय बैकअप फ़ाइल पढ़ने में विफल',
        _ => this,
      },

      'faq' => switch (l10n.localeName) {
        'es' => 'Preguntas frecuentes',
        'hi' => 'अक्सर पूछे जाने वाले प्रश्न',
        _ => this,
      },

      'full' => switch (l10n.localeName) {
        'es' => 'Completo',
        'hi' => 'पूर्ण',
        _ => this,
      },

      'full online policy' => switch (l10n.localeName) {
        'es' => 'Política online completa',
        'hi' => 'पूर्ण ऑनलाइन नीति',
        _ => this,
      },

      'full online terms' => switch (l10n.localeName) {
        'es' => 'Términos online completos',
        'hi' => 'पूर्ण ऑनलाइन शर्तें',
        _ => this,
      },

      'full title & purpose' => switch (l10n.localeName) {
        'es' => 'Título completo y propósito',
        'hi' => 'पूरा शीर्षक और उद्देश्य',
        _ => this,
      },

      'google drive backup' => switch (l10n.localeName) {
        'es' => 'Copia de Google Drive',
        'hi' => 'गूगल ड्राइव बैकअप',
        _ => this,
      },

      'guides' => switch (l10n.localeName) {
        'es' => 'Guías',
        'hi' => 'गाइड',
        _ => this,
      },

      'hardware-backed encryption' => switch (l10n.localeName) {
        'es' => 'Cifrado por hardware',
        'hi' => 'हार्डवेयर-समर्थित एन्क्रिप्शन',
        _ => this,
      },

      'help' => switch (l10n.localeName) {
        'es' => 'Ayuda',
        'hi' => 'सहायता',
        _ => this,
      },

      'hold for notes' => switch (l10n.localeName) {
        'es' => 'Mantener para notas',
        'hi' => 'नोट्स के लिए दबाए रखें',
        _ => this,
      },

      'import backup' => switch (l10n.localeName) {
        'es' => 'Importar copia',
        'hi' => 'बैकअप आयात करें',
        _ => this,
      },

      'important notice' => switch (l10n.localeName) {
        'es' => 'Aviso importante',
        'hi' => 'महत्वपूर्ण सूचना',
        _ => this,
      },

      'in-app ota updates' => switch (l10n.localeName) {
        'es' => 'Actualizaciones OTA integradas',
        'hi' => 'इन-ऐप ओटीए अपडेट',
        _ => this,
      },

      'in-app pin' => switch (l10n.localeName) {
        'es' => 'PIN de la aplicación',
        'hi' => 'इन-ऐप पिन',
        _ => this,
      },

      'in-app update setup' => switch (l10n.localeName) {
        'es' => 'Configuración de actualizaciones',
        'hi' => 'इन-ऐप अपडेट सेटअप',
        _ => this,
      },

      'install now' => switch (l10n.localeName) {
        'es' => 'Instalar ahora',
        'hi' => 'अभी स्थापित करें',
        _ => this,
      },

      'installation failed to start' => switch (l10n.localeName) {
        'es' => 'No se pudo iniciar la instalación',
        'hi' => 'स्थापना शुरू करने में विफल',
        _ => this,
      },

      'integrity check failed: checksum mismatch' => switch (l10n.localeName) {
        'es' => 'Fallo de integridad: suma de verificación no coincide',
        'hi' => 'अखंडता जांच विफल: चेकसम बेमेल',
        _ => this,
      },

      'intelligent risk radar' => switch (l10n.localeName) {
        'es' => 'Radar de riesgo inteligente',
        'hi' => 'इंटेलिजेंट रिस्क रडार',
        _ => this,
      },

      'is notekar private?' => switch (l10n.localeName) {
        'es' => '¿Es NoteKar privado?',
        'hi' => 'क्या NoteKar निजी है?',
        _ => this,
      },

      'less' => switch (l10n.localeName) {
        'es' => 'Menos',
        'hi' => 'कम',
        _ => this,
      },

      'licenses' => switch (l10n.localeName) {
        'es' => 'Licencias',
        'hi' => 'लाइसेंस',
        _ => this,
      },

      'limited connectivity' => switch (l10n.localeName) {
        'es' => 'Conectividad limitada',
        'hi' => 'सीमित कनेक्टिविटी',
        _ => this,
      },

      'local backups' => switch (l10n.localeName) {
        'es' => 'Copias locales',
        'hi' => 'स्थानीय बैकअप',
        _ => this,
      },

      'local storage' => switch (l10n.localeName) {
        'es' => 'Almacenamiento local',
        'hi' => 'स्थानीय भंडारण',
        _ => this,
      },

      'manage' => switch (l10n.localeName) {
        'es' => 'Administrar',
        'hi' => 'प्रबंधित करें',
        _ => this,
      },

      'milestone achieved' => switch (l10n.localeName) {
        'es' => 'Hito alcanzado',
        'hi' => 'मील का पत्थर हासिल किया',
        _ => this,
      },

      'milestone peak' => switch (l10n.localeName) {
        'es' => 'Cúspide de hito',
        'hi' => 'मील का पत्थर शिखर',
        _ => this,
      },

      'milestone unlocked!' => switch (l10n.localeName) {
        'es' => '¡Hito desbloqueado!',
        'hi' => 'मील का पत्थर अनलॉक हुआ!',
        _ => this,
      },

      'mit' => switch (l10n.localeName) {
        'es' => 'MIT',
        'hi' => 'एमआईटी',
        _ => this,
      },

      'more' => switch (l10n.localeName) {
        'es' => 'Más',
        'hi' => 'अधिक',
        _ => this,
      },

      'network & data transparency' => switch (l10n.localeName) {
        'es' => 'Transparencia de red y datos',
        'hi' => 'नेटवर्क और डेटा पारदर्शिता',
        _ => this,
      },

      'network warning' => switch (l10n.localeName) {
        'es' => 'Aviso de red',
        'hi' => 'नेटवर्क चेतावनी',
        _ => this,
      },

      'neuroscience & growth' => switch (l10n.localeName) {
        'es' => 'Neurociencia y crecimiento',
        'hi' => 'न्यूरोसाइंस और विकास',
        _ => this,
      },

      'next' => switch (l10n.localeName) {
        'es' => 'Siguiente',
        'hi' => 'अगला',
        _ => this,
      },

      'no local backups found' => switch (l10n.localeName) {
        'es' => 'No se encontraron copias locales',
        'hi' => 'कोई स्थानीय बैकअप नहीं मिला',
        _ => this,
      },

      'no repository activity' => switch (l10n.localeName) {
        'es' => 'Sin actividad en el repositorio',
        'hi' => 'कोई रिपॉजिटरी गतिविधि नहीं',
        _ => this,
      },

      'no tracking' => switch (l10n.localeName) {
        'es' => 'Sin rastreo',
        'hi' => 'कोई ट्रैकिंग नहीं',
        _ => this,
      },

      'note copied to clipboard' => switch (l10n.localeName) {
        'es' => 'Nota copiada al portapapeles',
        'hi' => 'नोट क्लिपबोर्ड पर कॉपी किया गया',
        _ => this,
      },

      'offline privacy log' => switch (l10n.localeName) {
        'es' => 'Registro de privacidad sin conexión',
        'hi' => 'ऑफलाइन गोपनीयता लॉग',
        _ => this,
      },

      'offline-first' => switch (l10n.localeName) {
        'es' => 'Sin conexión primero',
        'hi' => 'ऑफलाइन-प्रथम',
        _ => this,
      },

      'open source' => switch (l10n.localeName) {
        'es' => 'Código abierto',
        'hi' => 'ओपन सोर्स',
        _ => this,
      },

      'package verified & ready' => switch (l10n.localeName) {
        'es' => 'Paquete verificado y listo',
        'hi' => 'पैकेज सत्यापित और तैयार',
        _ => this,
      },

      'personalized app icons' => switch (l10n.localeName) {
        'es' => 'Iconos de app personalizados',
        'hi' => 'व्यक्तिगत ऐप आइकन',
        _ => this,
      },

      'planned' => switch (l10n.localeName) {
        'es' => 'Planeado',
        'hi' => 'नियोजित',
        _ => this,
      },

      'privacy & offline model' => switch (l10n.localeName) {
        'es' => 'Modelo de privacidad sin conexión',
        'hi' => 'गोपनीयता और ऑफ़लाइन मॉडल',
        _ => this,
      },

      'privacy policy' => switch (l10n.localeName) {
        'es' => 'Política de privacidad',
        'hi' => 'गोपनीयता नीति',
        _ => this,
      },

      'push alerts & notices' => switch (l10n.localeName) {
        'es' => 'Alertas y avisos push',
        'hi' => 'पुश अलर्ट और नोटिस',
        _ => this,
      },

      'real-time traffic audit' => switch (l10n.localeName) {
        'es' => 'Auditoría de tráfico en tiempo real',
        'hi' => 'रीयल-टाइम ट्रैफ़िक ऑडिट',
        _ => this,
      },

      'recent' => switch (l10n.localeName) {
        'es' => 'Reciente',
        'hi' => 'हाल ही का',
        _ => this,
      },

      'recommended for standard users.' => switch (l10n.localeName) {
        'es' => 'Recomendado para usuarios estándar.',
        'hi' => 'मानक उपयोगकर्ताओं के लिए अनुशंसित।',
        _ => this,
      },

      'refresh activity' => switch (l10n.localeName) {
        'es' => 'Actualizar actividad',
        'hi' => 'गतिविधि ताज़ा करें',
        _ => this,
      },

      'reminder message' => switch (l10n.localeName) {
        'es' => 'Mensaje de recordatorio',
        'hi' => 'अनुस्मारक संदेश',
        _ => this,
      },

      'report a bug' => switch (l10n.localeName) {
        'es' => 'Reportar un error',
        'hi' => 'एक बग की रिपोर्ट करें',
        _ => this,
      },

      'request a feature' => switch (l10n.localeName) {
        'es' => 'Solicitar una función',
        'hi' => 'एक सुविधा का अनुरोध करें',
        _ => this,
      },

      'required to show the logging alerts.' => switch (l10n.localeName) {
        'es' => 'Requerido para mostrar alertas de registro.',
        'hi' => 'लॉगिंग अलर्ट दिखाने के लिए आवश्यक।',
        _ => this,
      },

      'reset all data' => switch (l10n.localeName) {
        'es' => 'Restablecer todos los datos',
        'hi' => 'सभी डेटा रीसेट करें',
        _ => this,
      },

      'reset pin lock' => switch (l10n.localeName) {
        'es' => 'Restablecer bloqueo por PIN',
        'hi' => 'पिन लॉक रीसेट करें',
        _ => this,
      },

      'reset settings only' => switch (l10n.localeName) {
        'es' => 'Solo restablecer ajustes',
        'hi' => 'केवल सेटिंग्स रीसेट करें',
        _ => this,
      },

      'restore' => switch (l10n.localeName) {
        'es' => 'Restaurar',
        'hi' => 'पुनर्स्थापित करें',
        _ => this,
      },

      'retry download' => switch (l10n.localeName) {
        'es' => 'Reintentar descarga',
        'hi' => 'डाउनलोड पुनः प्रयास करें',
        _ => this,
      },

      'review and export' => switch (l10n.localeName) {
        'es' => 'Revisar y exportar',
        'hi' => 'समीक्षा और निर्यात',
        _ => this,
      },

      'secure passcode protection' => switch (l10n.localeName) {
        'es' => 'Protección segura con código',
        'hi' => 'सुरक्षित पासकोड सुरक्षा',
        _ => this,
      },

      'security & cryptographic upgrade' => switch (l10n.localeName) {
        'es' => 'Mejora de seguridad y criptografía',
        'hi' => 'सुरक्षा और क्रिप्टोग्राफ़िक अपग्रेड',
        _ => this,
      },

      'security & integrity' => switch (l10n.localeName) {
        'es' => 'Seguridad e integridad',
        'hi' => 'सुरक्षा और अखंडता',
        _ => this,
      },

      'select time' => switch (l10n.localeName) {
        'es' => 'Seleccionar hora',
        'hi' => 'समय चुनें',
        _ => this,
      },

      'set unrestricted' => switch (l10n.localeName) {
        'es' => 'Establecer sin restricciones',
        'hi' => 'अप्रतिबंधित सेट करें',
        _ => this,
      },

      'share' => switch (l10n.localeName) {
        'es' => 'Compartir',
        'hi' => 'साझा करें',
        _ => this,
      },

      'share card' => switch (l10n.localeName) {
        'es' => 'Compartir tarjeta',
        'hi' => 'कार्ड साझा करें',
        _ => this,
      },

      'share milestone peak' => switch (l10n.localeName) {
        'es' => 'Compartir cúspide de hito',
        'hi' => 'मील का पत्थर शिखर साझा करें',
        _ => this,
      },

      'show more' => switch (l10n.localeName) {
        'es' => 'Mostrar más',
        'hi' => 'अधिक दिखाएं',
        _ => this,
      },

      'single' => switch (l10n.localeName) {
        'es' => 'Individual',
        'hi' => 'सिंगल',
        _ => this,
      },

      'smart bandwidth saver' => switch (l10n.localeName) {
        'es' => 'Ahorro inteligente de datos',
        'hi' => 'स्मार्ट बैंडविड्थ सेवर',
        _ => this,
      },

      'software licenses' => switch (l10n.localeName) {
        'es' => 'Licencias de software',
        'hi' => 'सॉफ़्टवेयर लाइसेंस',
        _ => this,
      },

      'stable' => switch (l10n.localeName) {
        'es' => 'Estable',
        'hi' => 'स्थिर',
        _ => this,
      },

      'suggest a new idea or improvement.' => switch (l10n.localeName) {
        'es' => 'Sugiere una nueva idea o mejora.',
        'hi' => 'एक नया विचार या सुधार सुझाएं।',
        _ => this,
      },

      'switching to beta build...' => switch (l10n.localeName) {
        'es' => 'Cambiando a versión Beta...',
        'hi' => 'बीटा बिल्ड पर स्विच हो रहा है...',
        _ => this,
      },

      'switching to stable build...' => switch (l10n.localeName) {
        'es' => 'Cambiando a versión Estable...',
        'hi' => 'स्थिर बिल्ड पर स्विच हो रहा है...',
        _ => this,
      },

      'system lock' => switch (l10n.localeName) {
        'es' => 'Bloqueo del sistema',
        'hi' => 'सिस्टम लॉक',
        _ => this,
      },

      'table' => switch (l10n.localeName) {
        'es' => 'Tabla',
        'hi' => 'तालिका',
        _ => this,
      },

      'tap any icon below to switch style' => switch (l10n.localeName) {
        'es' => 'Toca cualquier icono para cambiar el estilo',
        'hi' => 'शैली बदलने के लिए नीचे किसी भी आइकन पर टैप करें',
        _ => this,
      },

      'tap delay' => switch (l10n.localeName) {
        'es' => 'Demora de toque',
        'hi' => 'टैप विलंब',
        _ => this,
      },

      'tap to save' => switch (l10n.localeName) {
        'es' => 'Toca para guardar',
        'hi' => 'सहेजने के लिए टैप करें',
        _ => this,
      },

      'terms of use' => switch (l10n.localeName) {
        'es' => 'Términos de uso',
        'hi' => 'उपयोग की शर्तें',
        _ => this,
      },

      'theme description' => switch (l10n.localeName) {
        'es' => 'Descripción del tema',
        'hi' => 'थीम विवरण',
        _ => this,
      },

      'total requests' => switch (l10n.localeName) {
        'es' => 'Solicitudes totales',
        'hi' => 'कुल अनुरोध',
        _ => this,
      },

      'track starts and stops' => switch (l10n.localeName) {
        'es' => 'Registra inicios y paradas',
        'hi' => 'शुरुआत और ठहराव ट्रैक करें',
        _ => this,
      },

      'tutorials' => switch (l10n.localeName) {
        'es' => 'Tutoriales',
        'hi' => 'ट्यूटोरियल',
        _ => this,
      },

      'two-way' => switch (l10n.localeName) {
        'es' => 'Dos vías',
        'hi' => 'दो-तरफा',
        _ => this,
      },

      'update available' => switch (l10n.localeName) {
        'es' => 'Actualización disponible',
        'hi' => 'अपडेट उपलब्ध है',
        _ => this,
      },

      'urge surfing & grounding' => switch (l10n.localeName) {
        'es' => 'Surfear el impulso y anclaje',
        'hi' => 'उर्ज सर्फिंग और ग्राउंडिंग',
        _ => this,
      },

      'verifying integrity checksum...' => switch (l10n.localeName) {
        'es' => 'Verificando suma de comprobación...',
        'hi' => 'अखंडता चेकसम का सत्यापन हो रहा है...',
        _ => this,
      },

      'view full licenses' => switch (l10n.localeName) {
        'es' => 'Ver licencias completas',
        'hi' => 'पूर्ण लाइसेंस देखें',
        _ => this,
      },

      'you are up to date' => switch (l10n.localeName) {
        'es' => 'Estás al día',
        'hi' => 'आप अप टू डेट हैं',
        _ => this,
      },

      'your privacy matters' => switch (l10n.localeName) {
        'es' => 'Tu privacidad importa',
        'hi' => 'आपकी गोपनीयता मायने रखती है',
        _ => this,
      },

      'built by' => switch (l10n.localeName) {
        'es' => 'Creado por',
        'hi' => 'द्वारा निर्मित',
        _ => this,
      },

      'version' => switch (l10n.localeName) {
        'es' => 'Versión',
        'hi' => 'संस्करण',
        _ => this,
      },

      'as a small, offline-first timestamp logger for real work: quick taps, focused notes, and exports developers can inspect.' =>
        switch (l10n.localeName) {
          'es' =>
            'como un registrador de marcas de tiempo pequeño y sin conexión para el trabajo real: toques rápidos, notas enfocadas y exportaciones auditables.',
          'hi' =>
            'वास्तविक कार्य के लिए एक छोटे, ऑफलाइन-प्रथम टाइमस्टैम्प लॉगर के रूप में: त्वरित टैप, केंद्रित नोट्स और निर्यात जिन्हें डेवलपर्स जांच सकते हैं।',
          _ => this,
        },

      '100% offline' => switch (l10n.localeName) {
        'es' => '100% Sin conexión',
        'hi' => '100% ऑफ़लाइन',
        _ => this,
      },

      '100% offline database' => switch (l10n.localeName) {
        'es' => 'Base de datos 100% local y sin conexión',
        'hi' => '100% ऑफ़लाइन डेटाबेस',
        _ => this,
      },

      '8 luxury app icon editions' => switch (l10n.localeName) {
        'es' => '8 ediciones de iconos de lujo',
        'hi' => '8 लक्जरी ऐप आइकन संस्करण',
        _ => this,
      },

      'amoled' => switch (l10n.localeName) {
        'es' => 'AMOLED',
        'hi' => 'AMOLED',
        _ => this,
      },

      'about' => switch (l10n.localeName) {
        'es' => 'Acerca de',
        'hi' => 'के बारे में',
        _ => this,
      },

      'active protection' => switch (l10n.localeName) {
        'es' => 'Protección activa',
        'hi' => 'सक्रिय सुरक्षा',
        _ => this,
      },

      'adaptive engine overview' => switch (l10n.localeName) {
        'es' => 'Resumen del Motor Adaptativo',
        'hi' => 'एडेप्टिव इंजन अवलोकन',
        _ => this,
      },

      'adaptive engine and performance status' => switch (l10n.localeName) {
        'es' => 'Motor adaptativo y estado de rendimiento',
        'hi' => 'एडेप्टिव इंजन और प्रदर्शन स्थिति',
        _ => this,
      },

      'adds a subtle glass-like container behind the home toolbar.' =>
        switch (l10n.localeName) {
          'es' =>
            'Añade un contenedor sutil de efecto cristal detrás de la barra de inicio.',
          'hi' => 'होम टूलबार के पीछे एक सूक्ष्म ग्लास-समान कंटेनर जोड़ता है।',
          _ => this,
        },

      'all moments in the database will be permanently removed. this cannot be undone.' =>
        switch (l10n.localeName) {
          'es' =>
            'Todos los momentos de la base de datos se eliminarán permanentemente. Esto no se puede deshacer.',
          'hi' =>
            'डेटाबेस के सभी क्षण स्थायी रूप से हटा दिए जाएंगे। इसे पूर्ववत नहीं किया जा सकता।',
          _ => this,
        },

      'all settings will be restored to their initial factory defaults. your saved moments and notes will remain untouched.' =>
        switch (l10n.localeName) {
          'es' =>
            'Todos los ajustes se restablecerán a los valores predeterminados de fábrica. Tus momentos y notas guardados permanecerán intactos.',
          'hi' =>
            'सभी सेटिंग्स को फ़ैक्टरी डिफ़ॉल्ट पर रीसेट कर दिया जाएगा। आपके सहेजे गए क्षण और नोट्स सुरक्षित रहेंगे।',
          _ => this,
        },

      'all time' => switch (l10n.localeName) {
        'es' => 'Todo el tiempo',
        'hi' => 'सभी समय',
        _ => this,
      },

      'allows notekar to send logging reminders and update notifications.' =>
        switch (l10n.localeName) {
          'es' =>
            'Permite que NoteKar envíe recordatorios de registro y avisos de actualización.',
          'hi' =>
            'NoteKar को लॉगिंग अनुस्मारक और अपडेट सूचनाएं भेजने की अनुमति देता है।',
          _ => this,
        },

      'amethyst nebula' => switch (l10n.localeName) {
        'es' => 'Nebulosa Amatista',
        'hi' => 'एमेथिस्ट नेबुला',
        _ => this,
      },

      'app icon' => switch (l10n.localeName) {
        'es' => 'Icono de la app',
        'hi' => 'ऐप आइकन',
        _ => this,
      },

      'app lock' => switch (l10n.localeName) {
        'es' => 'Bloqueo de la app',
        'hi' => 'ऐप लॉक',
        _ => this,
      },

      'app lock & security' => switch (l10n.localeName) {
        'es' => 'Bloqueo de app y seguridad',
        'hi' => 'ऐप लॉक और सुरक्षा',
        _ => this,
      },

      'app lock & biometrics' => switch (l10n.localeName) {
        'es' => 'Bloqueo de app y biometría',
        'hi' => 'ऐप लॉक और बायोमेट्रिक्स',
        _ => this,
      },

      'app notices' => switch (l10n.localeName) {
        'es' => 'Avisos de la app',
        'hi' => 'ऐप सूचनाएं',
        _ => this,
      },

      'app preferences and theme' => switch (l10n.localeName) {
        'es' => 'Preferencias de la app y tema',
        'hi' => 'ऐप प्राथमिकताएं और थीम',
        _ => this,
      },

      'app version' => switch (l10n.localeName) {
        'es' => 'Versión de la app',
        'hi' => 'ऐप संस्करण',
        _ => this,
      },

      'appearance' => switch (l10n.localeName) {
        'es' => 'Apariencia',
        'hi' => 'दिखावट',
        _ => this,
      },

      'application build identifier' => switch (l10n.localeName) {
        'es' => 'Identificador de compilación de la aplicación',
        'hi' => 'एप्लिकेशन बिल्ड पहचानकर्ता',
        _ => this,
      },

      'apply a custom accent color across all fluid interface elements.' =>
        switch (l10n.localeName) {
          'es' =>
            'Aplica un color de acento personalizado en todos los elementos de la interfaz fluida.',
          'hi' => 'सभी इंटरफ़ेस तत्वों पर एक कस्टम रंग लागू करें।',
          _ => this,
        },

      'aurora borealis' => switch (l10n.localeName) {
        'es' => 'Aurora Boreal',
        'hi' => 'ऑरोरा बोरियालिस',
        _ => this,
      },

      'automatic' => switch (l10n.localeName) {
        'es' => 'Automático',
        'hi' => 'स्वचालित',
        _ => this,
      },

      'backup & export' => switch (l10n.localeName) {
        'es' => 'Copia de seguridad y exportación',
        'hi' => 'बैकअप और निर्यात',
        _ => this,
      },

      'backup filename preview' => switch (l10n.localeName) {
        'es' => 'Vista previa del nombre de archivo de respaldo',
        'hi' => 'बैकअप फ़ाइल नाम पूर्वावलोकन',
        _ => this,
      },

      'battery and performance status' => switch (l10n.localeName) {
        'es' => 'Estado de la batería y rendimiento',
        'hi' => 'बैटरी और प्रदर्शन स्थिति',
        _ => this,
      },

      'beta track' => switch (l10n.localeName) {
        'es' => 'Canal Beta',
        'hi' => 'बीटा ट्रैक',
        _ => this,
      },

      'biometric lock' => switch (l10n.localeName) {
        'es' => 'Bloqueo biométrico',
        'hi' => 'बायोमेट्रिक लॉक',
        _ => this,
      },

      'biometrics or system credentials' => switch (l10n.localeName) {
        'es' => 'Biometría o credenciales del sistema',
        'hi' => 'बायोमेट्रिक्स या सिस्टम क्रेडेंशियल',
        _ => this,
      },

      'blur & translucency' => switch (l10n.localeName) {
        'es' => 'Desenfoque y translucidez',
        'hi' => 'धुंधलापन और पारदर्शिता',
        _ => this,
      },

      'build date' => switch (l10n.localeName) {
        'es' => 'Fecha de compilación',
        'hi' => 'बिल्ड तिथि',
        _ => this,
      },

      'build number' => switch (l10n.localeName) {
        'es' => 'Número de compilación',
        'hi' => 'बिल्ड संख्या',
        _ => this,
      },

      'buy me a coffee' => switch (l10n.localeName) {
        'es' => 'Invítame a un café',
        'hi' => 'एक कॉफ़ी प्रायोजित करें',
        _ => this,
      },

      'capture cooldown' => switch (l10n.localeName) {
        'es' => 'Tiempo de enfriamiento de captura',
        'hi' => 'कैप्चर कूलडाउन',
        _ => this,
      },

      'capture delay & cooldown' => switch (l10n.localeName) {
        'es' => 'Retardo de captura y enfriamiento',
        'hi' => 'कैप्चर विलंब और कूलडाउन',
        _ => this,
      },

      'changelog' => switch (l10n.localeName) {
        'es' => 'Registro de cambios',
        'hi' => 'परिवर्तन सूची (Changelog)',
        _ => this,
      },

      'clear all moments' => switch (l10n.localeName) {
        'es' => 'Borrar todos los momentos',
        'hi' => 'सभी क्षण साफ़ करें',
        _ => this,
      },

      'clear cache' => switch (l10n.localeName) {
        'es' => 'Limpiar caché',
        'hi' => 'कैश साफ़ करें',
        _ => this,
      },

      'clear trash' => switch (l10n.localeName) {
        'es' => 'Vaciar papelera',
        'hi' => 'ट्रैश खाली करें',
        _ => this,
      },

      'color accent' => switch (l10n.localeName) {
        'es' => 'Color de acento',
        'hi' => 'रंग उच्चारण',
        _ => this,
      },

      'compact history' => switch (l10n.localeName) {
        'es' => 'Historial compacto',
        'hi' => 'कॉम्पैक्ट इतिहास',
        _ => this,
      },

      'compact history mode' => switch (l10n.localeName) {
        'es' => 'Modo de historial compacto',
        'hi' => 'कॉम्पैक्ट इतिहास मोड',
        _ => this,
      },

      'continuous' => switch (l10n.localeName) {
        'es' => 'Continuo',
        'hi' => 'निरंतर',
        _ => this,
      },

      'cooldown period' => switch (l10n.localeName) {
        'es' => 'Período de enfriamiento',
        'hi' => 'कूलडाउन अवधि',
        _ => this,
      },

      'correlation intelligence' => switch (l10n.localeName) {
        'es' => 'Inteligencia de correlación',
        'hi' => 'सहसंबंध बुद्धिमत्ता',
        _ => this,
      },

      'count on save' => switch (l10n.localeName) {
        'es' => 'Contador al guardar',
        'hi' => 'सहेजने पर गिनती',
        _ => this,
      },

      'daily logging reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio de registro diario',
        'hi' => 'दैनिक लॉगिंग अनुस्मारक',
        _ => this,
      },

      'daily reminders' => switch (l10n.localeName) {
        'es' => 'Recordatorios diarios',
        'hi' => 'दैनिक अनुस्मारक',
        _ => this,
      },

      'dark mode' => switch (l10n.localeName) {
        'es' => 'Modo oscuro',
        'hi' => 'डार्क मोड',
        _ => this,
      },

      'data & backup' => switch (l10n.localeName) {
        'es' => 'Datos y copia de seguridad',
        'hi' => 'डेटा और बैकअप',
        _ => this,
      },

      'database export' => switch (l10n.localeName) {
        'es' => 'Exportación de base de datos',
        'hi' => 'डेटाबेस निर्यात',
        _ => this,
      },

      'database integrity' => switch (l10n.localeName) {
        'es' => 'Integridad de la base de datos',
        'hi' => 'डेटाबेस अखंडता',
        _ => this,
      },

      'developer diagnostics' => switch (l10n.localeName) {
        'es' => 'Diagnósticos para desarrolladores',
        'hi' => 'डेवलपर डायग्नोस्टिक्स',
        _ => this,
      },

      'diagnostics' => switch (l10n.localeName) {
        'es' => 'Diagnósticos',
        'hi' => 'निदान',
        _ => this,
      },

      'disable use numbers in single?' => switch (l10n.localeName) {
        'es' => '¿Desactivar numeración en modo individual?',
        'hi' => 'क्या सिंगल में नंबर का उपयोग अक्षम करें?',
        _ => this,
      },

      'display & typography' => switch (l10n.localeName) {
        'es' => 'Pantalla y tipografía',
        'hi' => 'प्रदर्शन और टाइपोग्राफी',
        _ => this,
      },

      'docs' => switch (l10n.localeName) {
        'es' => 'Documentación',
        'hi' => 'दस्तावेज़',
        _ => this,
      },

      'email support' => switch (l10n.localeName) {
        'es' => 'Soporte por correo',
        'hi' => 'ईमेल समर्थन',
        _ => this,
      },

      'emerald forest' => switch (l10n.localeName) {
        'es' => 'Bosque Esmeralda',
        'hi' => 'एमराल्ड वन',
        _ => this,
      },

      'every 7 days' => switch (l10n.localeName) {
        'es' => 'Cada 7 días',
        'hi' => 'हर 7 दिन',
        _ => this,
      },

      'every 14 days' => switch (l10n.localeName) {
        'es' => 'Cada 14 días',
        'hi' => 'हर 14 दिन',
        _ => this,
      },

      'every 30 days' => switch (l10n.localeName) {
        'es' => 'Cada 30 días',
        'hi' => 'हर 30 दिन',
        _ => this,
      },

      'feedback' => switch (l10n.localeName) {
        'es' => 'Comentarios',
        'hi' => 'प्रतिक्रिया',
        _ => this,
      },

      'feedback & bug report' => switch (l10n.localeName) {
        'es' => 'Comentarios y reporte de errores',
        'hi' => 'प्रतिक्रिया और बग रिपोर्ट',
        _ => this,
      },

      'github' => switch (l10n.localeName) {
        'es' => 'GitHub',
        'hi' => 'GitHub',
        _ => this,
      },

      'hardware security' => switch (l10n.localeName) {
        'es' => 'Seguridad de hardware',
        'hi' => 'हार्डवेयर सुरक्षा',
        _ => this,
      },

      'help & user guides' => switch (l10n.localeName) {
        'es' => 'Ayuda y guías de usuario',
        'hi' => 'सहायता और उपयोगकर्ता मार्गदर्शिका',
        _ => this,
      },

      'hide app content in recents' => switch (l10n.localeName) {
        'es' => 'Ocultar contenido de la app en recientes',
        'hi' => 'हाल के ऐप्स में सामग्री छिपाएं',
        _ => this,
      },

      'imperial gold' => switch (l10n.localeName) {
        'es' => 'Oro Imperial',
        'hi' => 'इंपीरियल गोल्ड',
        _ => this,
      },

      'inactivity alerts' => switch (l10n.localeName) {
        'es' => 'Alertas de inactividad',
        'hi' => 'निष्क्रियता अलर्ट',
        _ => this,
      },

      'legal & open source notices' => switch (l10n.localeName) {
        'es' => 'Avisos legales y de código abierto',
        'hi' => 'कानूनी और ओपन सोर्स नोटिस',
        _ => this,
      },

      'live activity tracking dashboard featuring real-time metric analysis, habit tracking grids, activity trends, and correlation intelligence calculated from your moments.' =>
        switch (l10n.localeName) {
          'es' =>
            'Panel de seguimiento de actividad en tiempo real con análisis de métricas, cuadrículas de hábitos, tendencias y correlación calculadas a partir de tus momentos.',
          'hi' =>
            'वास्तविक समय मीट्रिक विश्लेषण, आदत ट्रैकिंग ग्रिड, गतिविधि रुझान और सहसंबंध बुद्धिमत्ता की विशेषता वाला लाइव गतिविधि डैशबोर्ड।',
          _ => this,
        },

      'logging' => switch (l10n.localeName) {
        'es' => 'Registro',
        'hi' => 'लॉगिंग',
        _ => this,
      },

      'logging reminders' => switch (l10n.localeName) {
        'es' => 'Recordatorios de registro',
        'hi' => 'लॉगिंग अनुस्मारक',
        _ => this,
      },

      'midnight obsidian' => switch (l10n.localeName) {
        'es' => 'Obsidiana Medianoche',
        'hi' => 'मिडनाइट ओब्सीडियन',
        _ => this,
      },

      'milestone badges' => switch (l10n.localeName) {
        'es' => 'Insignias de hitos',
        'hi' => 'मील के पत्थर के बैज',
        _ => this,
      },

      'moments' => switch (l10n.localeName) {
        'es' => 'Momentos',
        'hi' => 'क्षण',
        _ => this,
      },

      'personalization' => switch (l10n.localeName) {
        'es' => 'Personalización',
        'hi' => 'निजीकरण',
        _ => this,
      },

      'personalize and configure notekar to fit your specific workflow.' =>
        switch (l10n.localeName) {
          'es' =>
            'Personaliza y configura NoteKar para que se adapte a tu flujo de trabajo específico.',
          'hi' =>
            'अपने विशिष्ट वर्कफ़्लो के अनुसार NoteKar को अनुकूलित और कॉन्फ़िगर करें।',
          _ => this,
        },

      'privacy & security' => switch (l10n.localeName) {
        'es' => 'Privacidad y seguridad',
        'hi' => 'गोपनीयता और सुरक्षा',
        _ => this,
      },

      'real-time metrics' => switch (l10n.localeName) {
        'es' => 'Métricas en tiempo real',
        'hi' => 'रीयल-टाइम मेट्रिक्स',
        _ => this,
      },

      'reset data' => switch (l10n.localeName) {
        'es' => 'Restablecer datos',
        'hi' => 'डेटा रीसेट करें',
        _ => this,
      },

      'reset settings' => switch (l10n.localeName) {
        'es' => 'Restablecer ajustes',
        'hi' => 'सेटिंग्स रीसेट करें',
        _ => this,
      },

      'search settings' => switch (l10n.localeName) {
        'es' => 'Buscar ajustes',
        'hi' => 'सेटिंग्स खोजें',
        _ => this,
      },

      'search settings...' => switch (l10n.localeName) {
        'es' => 'Buscar en ajustes...',
        'hi' => 'सेटिंग्स खोजें...',
        _ => this,
      },

      'show seconds' => switch (l10n.localeName) {
        'es' => 'Mostrar segundos',
        'hi' => 'सेकंड दिखाएं',
        _ => this,
      },

      'single moment numbering' => switch (l10n.localeName) {
        'es' => 'Numeración de momentos individuales',
        'hi' => 'सिंगल मोमेंट नंबरिंग',
        _ => this,
      },

      'sobriety tracker' => switch (l10n.localeName) {
        'es' => 'Seguimiento de sobriedad',
        'hi' => 'संयम ट्रैकर',
        _ => this,
      },

      'sobriety tracker & milestone cards' => switch (l10n.localeName) {
        'es' => 'Seguimiento de sobriedad y tarjetas de hitos',
        'hi' => 'संयम ट्रैकर और मील के पत्थर के कार्ड',
        _ => this,
      },

      'software credits and open source legal notices' =>
        switch (l10n.localeName) {
          'es' => 'Créditos del software y avisos legales de código abierto',
          'hi' => 'सॉफ़्टवेयर क्रेडिट और ओपन सोर्स कानूनी नोटिस',
          _ => this,
        },

      'software update' => switch (l10n.localeName) {
        'es' => 'Actualización de software',
        'hi' => 'सॉफ़्टवेयर अपडेट',
        _ => this,
      },

      'software update, app notices, changelog' => switch (l10n.localeName) {
        'es' => 'Actualización de software, avisos y registro de cambios',
        'hi' => 'सॉफ़्टवेयर अपडेट, ऐप नोटिस, चेंजलॉग',
        _ => this,
      },

      'stable build' => switch (l10n.localeName) {
        'es' => 'Versión estable',
        'hi' => 'स्थिर संस्करण',
        _ => this,
      },

      'support & community' => switch (l10n.localeName) {
        'es' => 'Soporte y comunidad',
        'hi' => 'समर्थन और समुदाय',
        _ => this,
      },

      'system default' => switch (l10n.localeName) {
        'es' => 'Predeterminado del sistema',
        'hi' => 'सिस्टम डिफ़ॉल्ट',
        _ => this,
      },

      'technical stats about your device and the adaptive engine.' =>
        switch (l10n.localeName) {
          'es' =>
            'Estadísticas técnicas de tu dispositivo y el Motor Adaptativo.',
          'hi' => 'आपके डिवाइस और एडेप्टिव इंजन के बारे में तकनीकी आँकड़े।',
          _ => this,
        },

      'theme' => switch (l10n.localeName) {
        'es' => 'Tema',
        'hi' => 'थीम',
        _ => this,
      },

      'these settings define how moments are recorded and prepared for export.' =>
        switch (l10n.localeName) {
          'es' =>
            'Estos ajustes definen cómo se registran los momentos y se preparan para exportar.',
          'hi' =>
            'ये सेटिंग्स परिभाषित करती हैं कि क्षणों को कैसे रिकॉर्ड किया जाता है और निर्यात के लिए तैयार किया जाता है।',
          _ => this,
        },

      'these tools are intended for system maintenance and troubleshooting.' =>
        switch (l10n.localeName) {
          'es' =>
            'Estas herramientas están destinadas al mantenimiento y la solución de problemas del sistema.',
          'hi' => 'ये उपकरण सिस्टम रखरखाव और समस्या निवारण के लिए हैं।',
          _ => this,
        },

      'update track' => switch (l10n.localeName) {
        'es' => 'Canal de actualización',
        'hi' => 'अपडेट ट्रैक',
        _ => this,
      },

      'updates & notices' => switch (l10n.localeName) {
        'es' => 'Actualizaciones y avisos',
        'hi' => 'अपडेट और सूचनाएं',
        _ => this,
      },

      'verified safe' => switch (l10n.localeName) {
        'es' => 'Verificado Seguro',
        'hi' => 'सुरक्षित सत्यापित',
        _ => this,
      },

      'virustotal scan' => switch (l10n.localeName) {
        'es' => 'Análisis de VirusTotal',
        'hi' => 'VirusTotal स्कैन',
        _ => this,
      },

      'zero telemetry & offline integrity' => switch (l10n.localeName) {
        'es' => 'Cero telemetría e integridad sin conexión',
        'hi' => 'शून्य टेलीमेट्री और ऑफ़लाइन अखंडता',
        _ => this,
      },

      'attach context without slowing the app down.' =>
        switch (l10n.localeName) {
          'es' => 'Añade contexto sin ralentizar la aplicación.',
          'hi' => 'ऐप को धीमा किए बिना संदर्भ जोड़ें।',
          _ => this,
        },

      'change your secure in-app passcode.' => switch (l10n.localeName) {
        'es' => 'Cambia tu código de acceso seguro en la app.',
        'hi' => 'अपना सुरक्षित इन-ऐप पासकोड बदलें।',
        _ => this,
      },

      'configure a dedicated 4-digit passcode.' => switch (l10n.localeName) {
        'es' => 'Configura un código de acceso dedicado de 4 dígitos.',
        'hi' => 'एक समर्पित 4-अंकीय पासकोड कॉन्फ़िगर करें।',
        _ => this,
      },

      'disable reduce motion first' => switch (l10n.localeName) {
        'es' => 'Desactiva Reducir movimiento primero',
        'hi' => 'पहले रिड्यूस मोशन अक्षम करें',
        _ => this,
      },

      'network monitor' => switch (l10n.localeName) {
        'es' => 'Monitor de red',
        'hi' => 'नेटवर्क मॉनिटर',
        _ => this,
      },

      'no internet connection. showing cached preview.' =>
        switch (l10n.localeName) {
          'es' => 'Sin conexión a internet. Mostrando vista previa en caché.',
          'hi' =>
            'कोई इंटरनेट कनेक्शन नहीं है। कैश्ड पूर्वावलोकन दिखाया जा रहा है।',
          _ => this,
        },

      'ok' => switch (l10n.localeName) {
        'es' => 'Aceptar',
        'hi' => 'ठीक है',
        _ => this,
      },

      'please wait while android refreshes notekar.' =>
        switch (l10n.localeName) {
          'es' => 'Por favor espera mientras Android actualiza NoteKar.',
          'hi' =>
            'कृपया प्रतीक्षा करें जब तक Android NoteKar को रीफ्रेश करता है।',
          _ => this,
        },

      'select a theme that best suits your environment.' =>
        switch (l10n.localeName) {
          'es' => 'Selecciona el tema que mejor se adapte a tu entorno.',
          'hi' => 'वह थीम चुनें जो आपके परिवेश के लिए सबसे उपयुक्त हो।',
          _ => this,
        },

      'sessions are recorded as in and out pairs.' => switch (l10n.localeName) {
        'es' => 'Las sesiones se registran como pares de ENTRADA y SALIDA.',
        'hi' => 'सत्र IN और OUT जोड़े के रूप में रिकॉर्ड किए जाते हैं।',
        _ => this,
      },

      'this local backup file will be erased permanently.' =>
        switch (l10n.localeName) {
          'es' => 'Este archivo de respaldo local se borrará permanentemente.',
          'hi' => 'यह स्थानीय बैकअप फ़ाइल स्थायी रूप से मिटा दी जाएगी।',
          _ => this,
        },

      'triggers reminders on specific days of the week.' =>
        switch (l10n.localeName) {
          'es' => 'Activa recordatorios en días específicos de la semana.',
          'hi' => 'सप्ताह के विशिष्ट दिनों पर अनुस्मारक ट्रिगर करता है।',
          _ => this,
        },

      'use fingerprint, face, or system pin.' => switch (l10n.localeName) {
        'es' => 'Usa huella digital, rostro o PIN del sistema.',
        'hi' => 'फ़िंगरप्रिंट, चेहरा या सिस्टम पिन का उपयोग करें।',
        _ => this,
      },

      '* have suggestions or found a bug?' => switch (l10n.localeName) {
        'es' => '* ¿Tienes sugerencias o encontraste un error?',
        'hi' => '* क्या आपके पास सुझाव हैं या कोई बग मिला?',
        _ => this,
      },

      'every tap records a standalone moment.' => switch (l10n.localeName) {
        'es' => 'Cada toque registra un momento independiente.',
        'hi' => 'प्रत्येक टैप एक स्वतंत्र क्षण रिकॉर्ड करता है।',
        _ => this,
      },
      'available languages' => switch (l10n.localeName) {
        'es' => 'Idiomas disponibles',
        'hi' => 'उपलब्ध भाषाएँ',
        _ => this,
      },
      'upcoming languages' => switch (l10n.localeName) {
        'es' => 'Próximos idiomas',
        'hi' => 'आगामी भाषाएँ',
        _ => this,
      },
      'upcoming' => switch (l10n.localeName) {
        'es' => 'Próximamente',
        'hi' => 'आगामी',
        _ => this,
      },
      'these languages are planned for future releases. help translate notekar on github.' =>
        switch (l10n.localeName) {
          'es' =>
            'Estos idiomas están planificados para futuras versiones. Ayuda a traducir NoteKar en GitHub.',
          'hi' =>
            'ये भाषाएँ भविष्य के संस्करणों के लिए नियोजित हैं। GitHub पर NoteKar का अनुवाद करने में मदद करें।',
          _ => this,
        },
      'this language is currently under development. you can help translate notekar into your native language by contributing on github.' =>
        switch (l10n.localeName) {
          'es' =>
            'Este idioma está actualmente en desarrollo. Puedes ayudar a traducir NoteKar a tu idioma nativo colaborando en GitHub.',
          'hi' =>
            'यह भाषा वर्तमान में विकास में है। आप GitHub पर योगदान देकर NoteKar को अपनी मूल भाषा में अनुवाद करने में मदद कर सकते हैं।',
          _ => this,
        },
      'contribute on github' => switch (l10n.localeName) {
        'es' => 'Contribuir en GitHub',
        'hi' => 'GitHub पर योगदान करें',
        _ => this,
      },
      _ => this,
    };
  }
}

// Complete _deTranslations Translation Map
const Map<String, String> _frTranslations = {
  '* have suggestions or found a bug?':
      '* Vous avez des suggestions ou trouvé un bug ?',
  '* have suggestions or found a bug? ':
      '* Haben Sie Vorschläge oder einen Fehler gefunden? ',
  '0 / 68 clean': '0 / 68 sauber',
  '100% offline': '100% Hors ligne',
  '100% offline database': 'Base de données 100% hors ligne',
  '100% offline integrity': '100% Offline-Integrität',
  '100% offline-first. zero trackers. zero data collection':
      '100% hors ligne. Zéro traqueur. Zéro collecte de données',
  '16-week habit activity grid': '16-Wochen-Gewohnheitsaktivitätsraster',
  '5-4-3-2-1 grounding': '5-4-3-2-1 Erdungstechnik',
  'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.':
      'Ein datenschutzorientiertes Offline-Serientracking und Tagebuch zur Unterstützung Ihrer Genesung.',
  'a quiet, offline-first way to mark moments the second they happen.':
      'Eine ruhige, lokale Möglichkeit, Momente im Augenblick festzuhalten.',
  'a quiet, offline-first way to mark moments, track time, and inspect logs on your terms.':
      'Un moyen discret et hors ligne pour marquer vos moments, suivre votre temps et inspecter vos journaux selon vos conditions.',
  'about': 'Über',
  'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.':
      'Absolut. NoteKar ist Open Source und offline-first. Jede Version wird von 60+ Sicherheits-Engines über VirusTotal verifiziert.',
  'accent color': 'Akzentfarbe',
  'accentcolorcategory': 'Akzentfarbe',
  'accept': 'Akzeptieren',
  'access split-per-abi optimized binaries and google play appbundles directly from the release page.':
      'Laden Sie ABI-optimierte Binärdateien direkt von der Release-Seite herunter.',
  'accessibility': 'Accessibilité',
  'accessibilitycategory': 'Accessibilité',
  'active': 'Actif',
  'active issue tracking': 'Aktives Issue-Tracking',
  'active launcher icon': 'Aktives App-Symbol',
  'active protection': 'Protection active',
  'activity': 'Aktivität',
  'adaptive engine': 'Adaptive Engine',
  'adaptive engine and performance status':
      'Moteur adaptatif et état des performances',
  'adaptive engine overview': 'Aperçu du moteur adaptatif',
  'add a note': 'Notiz hinzufügen',
  'add a note to save': 'Notiz zum Speichern hinzufügen',
  'add note': 'Ajouter une note',
  'adds a clean streak card to your home screen and adapts home screen widgets.':
      'Fügt Ihrem Startbildschirm eine übersichtliche Serienkarte hinzu und passt Widgets an.',
  'adds a subtle glass-like container behind the home toolbar.':
      'Fügt einen dezenten Glas-Container hinter der Symbolleiste ein.',
  'afternoon': 'Nachmittag',
  'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.':
      'Deaktivieren Sie die Akku-Optimierung, um sicherzustellen, dass Erinnerungen immer zuverlässig ausgelöst werden.',
  'alarms permission required': 'Alarm-Berechtigung erforderlich',
  'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.':
      'Alle 21 Meilensteine von 1 Tag bis 10 Jahren, fundiert in Neurowissenschaft und Verhaltenspsychologie.',
  'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.':
      'Alle Builds durchlaufen automatisierte CodeQL- und VirusTotal-Prüfungen zur Gewährleistung der Sicherheit.',
  'all moments in the database will be permanently removed. this cannot be undone.':
      'Tous les moments de la base de données seront définitivement supprimés. Cette action est irréversible.',
  'all settings will be restored to their initial factory defaults. your saved moments and notes will remain untouched.':
      'Alle Einstellungen werden auf die Werkseinstellungen zurückgesetzt. Ihre gespeicherten Momente und Notizen bleiben erhalten.',
  'all time': 'Tout le temps',
  'allow auto-start settings': 'Autostart-Einstellungen erlauben',
  'allow notifications': 'Benachrichtigungen zulassen',
  'allows notekar to send logging reminders and update notifications.':
      'Erlaubt NoteKar, Protokoll-Erinnerungen und Update-Benachrichtigungen zu senden.',
  'amethyst': 'Amethyst',
  'amoled': 'AMOLED',
  'ancient': 'Antike',
  'android backup': 'Android-Sicherung',
  'angry': 'Wütend',
  'animal kingdom': 'Tierreich',
  'anxious': 'Ängstlich / Besorgt',
  'app icon': 'App-Icon',
  'app icon could not be changed': 'App-Symbol konnte nicht geändert werden',
  'app icons': 'App-Symbole',
  'app language': 'App-Sprache',
  'app lock & biometrics': 'Verrouillage et biométrie',
  'app lock & security': 'Verrouillage et sécurité',
  'app lock appears after the notification panel':
      'App-Sperre erscheint nach dem Benachrichtigungsfeld',
  'app lock needs a device screen lock':
      'App-Sperre erfordert eine Bildschirmsperre',
  'app lock timing': 'App-Sperrzeit',
  'app lock will not turn on': 'App-Sperre lässt sich nicht aktivieren',
  'app notices': 'App-Hinweise',
  'app notices are not appearing': 'App-Benachrichtigungen erscheinen nicht',
  'app preferences and theme': 'App-Einstellungen & Theme',
  'app switcher obfuscation': 'Verschleierung im App-Umschalter',
  'app theme': 'App-Farbschema',
  'app usage': 'App-Nutzung',
  'app version': 'App-Version',
  'appearance': 'Erscheinungsbild',
  'appiconscategory': 'App-Symbole',
  'application build identifier': 'Anwendungs-Build-Kennung',
  'apply a custom accent color across all fluid interface elements.':
      'Wendet eine benutzerdefinierte Akzentfarbe auf alle fließenden UI-Elemente an.',
  'applying app icon': 'App-Symbol wird angewendet',
  'army elite. every clean day is a battle fought and won.':
      'Armee-Elite. Jeder saubere Tag ist eine gewonnene Schlacht.',
  'at': 'um',
  'attack on titan': 'Attack on Titan',
  'aurora': 'Aurora',
  'aurora borealis': 'Aurore boréale',
  'auto-start & background activity':
      'Démarrage automatique et activité en arrière-plan',
  'automated security scans': 'Automatisierte Sicherheits-Scans',
  'automatic': 'Automatique',
  'available languages': 'Langues disponibles',
  'back': 'Zurück',
  'back up data': 'Daten sichern',
  'backup & export': 'Sauvegarde et exportation',
  'backup & restore': 'Sauvegarde et restauration',
  'backup filename preview': 'Aperçu du nom de fichier de sauvegarde',
  'backup has no new moments': 'Sicherung enthält keine neuen Momente',
  'backup import failed': 'Sicherungsimport fehlgeschlagen',
  'backup import found no new moments':
      'Sicherungsimport ergab keine neuen Momente',
  'backup reminder: export a fresh backup soon':
      'Sicherungs-Erinnerung: Bald neue Sicherung exportieren',
  'backup status': 'Sicherungsstatus',
  'backupexportcategory': 'Sauvegarde et exportation',
  'battery and performance status': 'État de la batterie et des performances',
  'battery optimization active': 'Akku-Optimierung aktiv',
  'ben 10': 'Ben 10',
  'beta': 'Bêta',
  'beta feature': 'Beta-Funktion',
  'beta track': 'Beta-Kanal',
  'biometric lock': 'Verrouillage biométrique',
  'biometrics not available': 'Biometrie nicht verfügbar',
  'biometrics or system credentials': 'Biométrie ou identifiants système',
  'bleach': 'Bleach',
  'blur & translucency': 'Flou et translucidité',
  'bored': 'Gelangweilt',
  'boredom': 'Langeweile',
  'box breathing': 'Box-Atmung',
  'build cache cleared': 'Build-Cache geleert',
  'build cache size': 'Build-Cache-Größe',
  'build date': 'Date de compilation',
  'build number': 'Numéro de compilation',
  'built by': 'Développé par',
  'bushido code. master of the self.': 'Bushido-Kodex. Meister des Selbst.',
  'buy me a coffee': 'Offrez-moi un café',
  'can i restore deleted moments?':
      'Kann ich gelöschte Momente wiederherstellen?',
  'cancel': 'Annuler',
  'capture': 'Capture',
  'capture cooldown': 'Temps de recharge de capture',
  'capture delay & cooldown': 'Délai de capture et temps de recharge',
  'capturecategory': 'Capture',
  'celtic highland clan. earn your place, carry the banner.':
      'Clan des Highlands celtiques. Gagnez votre place, portez la bannière.',
  'change your secure in-app passcode.':
      'Ändern Sie Ihren sicheren In-App-Passcode.',
  'changelog': 'Journal des modifications',
  'changelogtitle': 'Journal des modifications',
  'check again': 'Erneut prüfen',
  'check for updates': 'Nach Updates suchen',
  'checking for updates...': 'Suche nach Updates...',
  'checks github releases only when needed. zero telemetry.':
      'Vérifie les versions GitHub uniquement lorsque nécessaire. Zéro télémétrie.',
  'chess mastery': 'Schach-Meisterschaft',
  'choose language': 'Choisir la langue',
  'choose milestone theme': 'Meilenstein-Design wählen',
  'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.':
      'Wählen Sie den narrativen Stil für Ihre Meilensteine. Jedes Thema ist psychologisch kuratiert.',
  'choose your preferred interface language':
      'Wählen Sie Ihre bevorzugte Oberflächensprache',
  'civilian to the one above all.': 'Zivilist bis zum Einen über Allen.',
  'clan': 'Klan',
  'clear': 'Löschen',
  'clear all moments': 'Effacer tous les moments',
  'clear cache': 'Cache leeren',
  'clear search': 'Effacer la recherche',
  'clear trash': 'Vider la corbeille',
  'clinical neuroscience terms. cold, precise, honest.':
      'Termes cliniques de neurosciences. Froids, précis, honnêtes.',
  'close': 'Fermer',
  'code geass': 'Code Geass',
  'color accent': 'Akzentfarbe',
  'commits': 'Commits',
  'compact history': 'Historique compact',
  'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.':
      'Der kompakte Verlauf kann nicht aktiviert werden, solange die Einzelzählung aktiv ist. Deaktivieren Sie die Einzelziffern, um kompakte Zeilen zu verwenden.',
  'compact history mode': 'Mode historique compact',
  'configure a dedicated 4-digit passcode.':
      'Richten Sie einen 4-stelligen Passcode ein.',
  'configure settings': 'Einstellungen anpassen',
  'confirm': 'Confirmer',
  'confirm delete': 'Löschen bestätigen',
  'confirm passcode': 'Code bestätigen',
  'continue': 'Weiter',
  'continuous': 'Continu',
  'contribute on github': 'Contribuer sur GitHub',
  'cooldown period': 'Période de temps de recharge',
  'copy': 'Kopieren',
  'copy moment': 'Moment kopieren',
  'correlation intelligence': 'Intelligence de corrélation',
  'cosmic exploration. every clean day is light-years gained.':
      'Kosmische Erkundung. Jeder saubere Tag bringt Lichtjahre ein.',
  'could not open backup file': 'Sicherungsdatei konnte nicht geöffnet werden',
  'create quick local backup': 'Schnelle lokale Sicherung erstellen',
  'crimson': 'Karminrot',
  'current message': 'Aktuelle Nachricht',
  'cursed spirit to satoru gojo.': 'Fluchgeist bis Satoru Gojo.',
  'custom start date': 'Benutzerdefiniertes Startdatum',
  'daily neuroscience insight': 'Aperçu quotidien en neurosciences',
  'daily reminder': 'Tägliche Erinnerung',
  'daily reminder message': 'Tägliche Erinnerungsnachricht',
  'daily reminders': 'Rappels quotidiens',
  'dark': 'Sombre',
  'dark mode': 'Dunkelmodus',
  'data': 'Daten',
  'data & backup': 'Données et sauvegarde',
  'data consumed': 'Verbrauchte Daten',
  'data health': 'Daten-Zustand',
  'database export': 'Exportation de la base de données',
  'database integrity': 'Intégrité de la base de données',
  'day of month': 'Tag des Monats',
  'days of week': 'Wochentage',
  'death note': 'Death Note',
  'delete': 'Supprimer',
  'delete all moments?': 'Alle Momente löschen?',
  'delete backup?': 'Sicherung löschen?',
  'delete cache': 'Cache löschen',
  'delete moment': 'Moment löschen',
  'delete permanently': 'Dauerhaft löschen',
  'delete permanently?': 'Endgültig löschen?',
  'deleted in moment': 'IN-Moment gelöscht',
  'deleted out moment': 'OUT-Moment gelöscht',
  'deleted single moment': 'SINGLE-Moment gelöscht',
  'deleting cache...': 'Cache wird gelöscht...',
  'demon slayer': 'Demon Slayer',
  'dev': 'Entwicklung',
  'developer diagnostics': 'Diagnostics développeur',
  'developer key': 'Entwickler-Schlüssel',
  'developer options': 'Entwickleroptionen',
  'diagnostics': 'Diagnostics',
  'diagnostics and internal engine settings for developers.':
      'Diagnose und interne Engine-Einstellungen für Entwickler.',
  'diagnosticscategory': 'Diagnostics',
  'disable battery optimization': 'Akku-Optimierung deaktivieren',
  'disable compact history?': 'Désactiver l\'historique compact ?',
  'disable count on save?': 'Désactiver le comptage à l\'enregistrement ?',
  'disable reduce motion first': '最初に「視覚効果を減らす」を無効にしてください',
  'disable use numbers in single?': 'Désactiver la numérotation unique ?',
  'disabled': 'Désactivé',
  'dismiss': 'Ignorer',
  'display': 'Affichage',
  'display & typography': 'Affichage et typographie',
  'displaycategory': 'Affichage',
  'docs': 'Documentation',
  'done': 'Terminé',
  'download': 'Herunterladen',
  'download & install': 'Herunterladen & Installieren',
  'download failed': 'Download fehlgeschlagen',
  'download from github': 'Von GitHub herunterladen',
  'download size:': 'Download-Größe:',
  'downloading update...': 'Update wird heruntergeladen...',
  'dragon ball': 'Dragon Ball',
  'e-rank sung jinwoo to shadow monarch.':
      'E-Rang Sung Jinwoo bis zum Schattenmonarchen.',
  'east blue coby to the pirate king gol d. roger.':
      'East Blue Corby bis zum Piratenkönig Gol D. Roger.',
  'edit': 'Bearbeiten',
  'edit message': 'Nachricht bearbeiten',
  'edit note': 'Modifier la note',
  'email support': 'Assistance par e-mail',
  'emerald': 'Smaragd',
  'empty': 'Leer',
  'empty trash': 'Papierkorb leeren',
  'empty trash?': 'Papierkorb leeren?',
  'enable count on save': 'Zähler beim Speichern anzeigen',
  'enable show seconds first': 'Zuerst Sekunden anzeigen aktivieren',
  'enable sobriety mode': 'Nüchternheitsmodus aktivieren',
  'enabled': 'Activé',
  'encrypted backup': 'Verschlüsselte Sicherung',
  'endpoint url': 'Endpunkt-URL',
  'english': 'Anglais',
  'enter passcode': 'Code eingeben',
  'enter reminder message...': 'Erinnerungstext eingeben...',
  'essential features': 'Fonctionnalités essentielles',
  'evening': 'Abend',
  'every 14 days': 'Alle 14 Tage',
  'every 30 days': 'Alle 30 Tage',
  'every 7 days': 'Alle 7 Tage',
  'every tap records a standalone moment.':
      'Chaque appui enregistre un moment autonome.',
  'export backup': 'Sicherung exportieren',
  'export csv': 'CSV exportieren',
  'export failed. try again.': 'Export fehlgeschlagen. Erneut versuchen.',
  'export json': 'JSON exportieren',
  'export last 7 days': 'Letzte 7 Tage exportieren',
  'export milestone card': 'Meilenstein-Karte exportieren',
  'export saved to downloads': 'Export in Downloads gespeichert',
  'export, import, and manage your data backups.':
      'Exportieren, importieren und verwalten Sie Ihre Datensicherungen.',
  'extended duration': 'Erweiterte Dauer',
  'external navigation': 'Externe Weiterleitung',
  'failed to create local backup': 'Fehler beim Erstellen der Sicherung',
  'failed to read local backup file':
      'Lokale Sicherungsdatei konnte nicht gelesen werden',
  'faq': 'Häufige Fragen',
  'fatigue': 'Ermüdung',
  'feedback': 'Commentaires',
  'feedback & bug report': 'Commentaires et rapport de bug',
  'french': 'Français',
  'fri': 'Fr',
  'friday': 'Freitag',
  'friends': 'Freunde',
  'from': 'Von',
  'full': 'Vollständig',
  'full online policy': 'Vollständige Online-Richtlinie',
  'full online terms': 'Vollständige Online-Bedingungen',
  'full title & purpose': 'Vollständiger Titel & Zweck',
  'fullmetal alchemist': 'Fullmetal Alchemist',
  'german': 'Allemand',
  'get started': 'Loslegen',
  'gintama': 'Gintama',
  'github': 'GitHub',
  'give feedback': 'Feedback geben',
  'google drive backup': 'Google Drive Sicherung',
  'got it': 'Verstanden',
  'grant permission': 'Accorder la permission',
  'greek and roman glory. rise from mortal to olympian.':
      'Gloire grecque et romaine. Élevez-vous de mortel à olympien.',
  'grey matter to alien x.': 'Graue Eminenz bis Alien X.',
  'guides': 'Anleitungen',
  'happy': 'Glücklich',
  'hardware security': 'Sécurité matérielle',
  'hardware-backed encryption': 'Hardware-gestützte Verschlüsselung',
  'harry potter': 'Harry Potter',
  'have suggestions or found a bug?':
      'Haben Sie Vorschläge oder einen Fehler gefunden?',
  'help': 'Hilfe',
  'help & user guides': 'Hilfe & Benutzerhandbuch',
  'hide app content in recents':
      'Masquer le contenu dans les applications récentes',
  'hindi': 'Hindi',
  'history': 'Historique',
  'hold for notes': 'Maintenir pour les notes',
  'hour': 'Stunde',
  'hours': 'Stunden',
  'html editor to turing award winner.':
      'HTML-Editor bis zum Turing-Preisträger.',
  'hunter x hunter': 'Hunter x Hunter',
  'imperial': 'Kaiserlich',
  'imperial gold': 'Or impérial',
  'import backup': 'Sicherung importieren',
  'import cancelled': 'Import abgebrochen',
  'important notice': 'Avis important',
  'in-app ota updates': 'In-App OTA-Updates',
  'in-app pin': 'In-App-PIN',
  'in-app pin set successfully.': 'In-App-PIN erfolgreich festgelegt.',
  'in-app update setup': 'Configuration des mises à jour intégrées',
  'inactive': 'Inactif',
  'inactivity reminder': 'Inaktivitäts-Erinnerung',
  'incorrect passcode': 'Falscher Code',
  'install now': 'Jetzt installieren',
  'installation failed to start': 'Installation konnte nicht gestartet werden',
  'integrity check failed: checksum mismatch':
      'Integritätsprüfung fehlgeschlagen: Prüfsummenfehler',
  'intelligent risk radar': 'Radar intelligent des risques',
  'invalid backup file': 'Ungültige Sicherungsdatei',
  'is notekar private?': 'Ist NoteKar privat?',
  'is notekar safe to use?': 'Ist NoteKar sicher zu verwenden?',
  'item': 'Element',
  'items': 'Elemente',
  'japanese': 'Japonais',
  'jujutsu kaisen': 'Jujutsu Kaisen',
  'july 2026': 'Juli 2026',
  'kingdom': 'Königreich',
  'konohamaru to the sage of six paths.':
      'Konohamaru bis zum Weisen der Sechs Pfade.',
  'language': 'Langue',
  'last scan': 'Letzter Scan',
  'late night': 'Fin de soirée',
  'late_night': 'Späte Nacht',
  'learn more': 'En savoir plus',
  'legal & open source notices': 'Avis légaux et open source',
  'less': 'Moins',
  'licenses': 'Lizenzen',
  'light': 'Clair',
  'limited connectivity': 'Begrenzte Verbindung',
  'link copied': 'Link kopiert',
  'live activity tracking dashboard featuring real-time metric analysis, habit tracking grids, activity trends, and correlation intelligence calculated from your moments.':
      'Live-Aktivitäts-Dashboard mit Echtzeit-Metriken, Gewohnheitsrastern, Trends und Korrelations-Intelligenz aus Ihren Momenten.',
  'live icon motion looks slow or delayed':
      'Live-Icon-Bewegung wirkt verzögert',
  'live icon motion will not turn on':
      'Live-Icon-Bewegung lässt sich nicht aktivieren',
  'load older moments': 'Charger les moments plus anciens',
  'loading database...': 'Datenbank wird geladen...',
  'local backups': 'Lokale Sicherungen',
  'local storage': 'Lokaler Speicher',
  'location': 'Ort',
  'logging': 'Enregistrement',
  'logging reminders': 'Protokoll-Erinnerungen',
  'logs': 'Protokolle',
  'loneliness': 'Einsamkeit',
  'lonely': 'Einsam',
  'magikarp to the creator god arceus.':
      'Karpador bis zum Schöpfergott Arceus.',
  'manage': 'Verwalten',
  'manage moment notes': 'Moment-Notizen verwalten',
  'manage security, passcode lock, and app privacy.':
      'Sicherheit, Codesperre und App-Datenschutz verwalten.',
  'marvel universe': 'Marvel-Universum',
  'matsuda to the shinigami king.': 'Matsuda bis zum König der Todesgötter.',
  'medieval royalty. rise from serf to sovereign.':
      'Mittelalterlicher Adel. Vom Knecht zum Herrscher.',
  'message': 'Nachricht',
  'midnight': 'Mitternacht',
  'midnight obsidian': 'Obsidienne de minuit',
  'milestone achieved': 'Meilenstein erreicht',
  'milestone peak': 'Meilenstein-Höhepunkt',
  'milestone theme': 'Meilenstein-Design',
  'milestone unlocked!': 'Meilenstein freigeschaltet!',
  'milestones': 'Meilensteine',
  'mineta to all might prime.': 'Mineta bis All Might in Bestform.',
  'minimal moment options': 'Minimale Moment-Optionen',
  'mit': 'MIT',
  'moisture farmer to the chosen one.':
      'Feuchtigkeitsfarmer bis zum Auserwählten.',
  'moment options': 'Moment-Optionen',
  'moment saved': 'Moment gespeichert',
  'moments': 'Moments',
  'momentscategory': 'Moments',
  'mon': 'Mo',
  'monastic journey. silence, stillness, and vows.':
      'Mönchische Reise. Stille, Ruhe und Gelübde.',
  'monday': 'Montag',
  'monk': 'Mönch',
  'monthly reminder': 'Rappel mensuel',
  'monthly reminder message': 'Monatliche Erinnerungsnachricht',
  'more': 'Plus',
  'morning': 'Morgen',
  'motion sensor unavailable': 'Bewegungssensor nicht verfügbar',
  'muggle to merlin.': 'Muggel bis Merlin.',
  'murata to yoriichi tsugikuni.': 'Murata bis Yoriichi Tsugikuni.',
  'my hero academia': 'My Hero Academia',
  'naruto': 'Naruto',
  'navy': 'Marine',
  'network & data transparency': 'Transparence réseau et données',
  'network monitor': 'Moniteur réseau',
  'network warning': 'Netzwerkwarnung',
  'neuroscience & growth': 'Neurowissenschaft & Wachstum',
  'next': 'Weiter',
  'night': 'Nacht',
  'no internet connection. showing cached preview.':
      'Keine Internetverbindung. Gecachte Vorschau wird angezeigt.',
  'no local backups found': 'Keine lokalen Sicherungen gefunden',
  'no matching notes': 'Keine passenden Notizen',
  'no message set (will show default reminder)':
      'Aucun message défini (le rappel par défaut sera affiché)',
  'no moments': 'Keine Momente',
  'no moments logged yet': 'Noch keine Momente protokolliert',
  'no note': 'Keine Notiz',
  'no notes found': 'Keine Notizen gefunden',
  'no relapses recorded yet!': 'Noch keine Rückfälle erfasst!',
  'no repository activity': 'Keine Repository-Aktivität',
  'no results': 'Aucun résultat',
  'no results found': 'Aucun résultat trouvé',
  'no search results found': 'Keine Suchergebnisse gefunden',
  'no tracking': 'Kein Tracking',
  'none': 'Keine',
  'not set: using last log or relapse tag':
      'Nicht festgelegt: Letzter Eintrag oder Rückfall-Tag wird verwendet',
  'note copied to clipboard': 'Notiz in Zwischenablage kopiert',
  'note on click': 'Notiz beim Tippen',
  'notekar': 'NoteKar',
  'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.':
      'NoteKar-Builds durchlaufen automatisierte CodeQL- und lokale VirusTotal-Scans.',
  'notekar is offline': 'NoteKar ist offline',
  'notekar stores moments privately on this device. backups are files you control.':
      'NoteKar speichert Momente privat auf diesem Gerät. Sicherungen kontrollieren Sie selbst.',
  'notes': 'Notes',
  'notification permission needed':
      'Benachrichtigungsberechtigung erforderlich',
  'numbered single moments': 'Nummerierte Einzelmomente',
  'obsidian onyx': 'Onyx obsidienne',
  'off': 'Désactivé',
  'official repository moved': 'Offizielles Repository umgezogen',
  'offline analysis of your logged relapse moments. no data leaves your device.':
      'Offline-Analyse Ihrer protokollierten Momente. Keine Daten verlassen Ihr Gerät.',
  'offline privacy log': 'Offline-Datenschutzprotokoll',
  'offline-first': 'Offline-First',
  'ok': 'OK',
  'okay': 'OK',
  'on': 'Activé',
  'one piece': 'One Piece',
  'only moments tagged #relapse reset the streak. turn off to reset on any new log.':
      'Nur Momente mit dem Tag #relapse setzen die Serie zurück. Deaktivieren, um bei jedem neuen Eintrag zurückzusetzen.',
  'open link': 'Link öffnen',
  'open settings': 'Ouvrir les paramètres',
  'open source': 'Open Source',
  'package verified & ready': 'Paket verifiziert & bereit',
  'passcodes do not match': 'Codes stimmen nicht überein',
  'peak risk window': 'Höchstes Risikofenster',
  'personalization': 'Personalisierung',
  'personalize and configure notekar to fit your specific workflow.':
      'Personnalisez et configurez NoteKar selon votre flux de travail.',
  'phoenix': 'Phönix',
  'planned': 'Geplant',
  'please wait while android refreshes notekar.':
      'Bitte warten, während Android NoteKar aktualisiert.',
  'pokemon': 'Pokémon',
  'priest willibald to thors the troll of jom.':
      'Priester Willibald bis Thors der Troll von Jom.',
  'privacy & offline model': 'Datenschutz & Offline-Modell',
  'privacy & security': 'Confidentialité et sécurité',
  'privacy policy': 'Datenschutzrichtlinie',
  'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.':
      'Datenschutzorientiertes Serientracking und Tagebuch. Alle Daten bleiben auf Ihrem Gerät.',
  'privacysecuritycategory': 'Confidentialité et sécurité',
  'pure titan to the founder ymir fritz.':
      'Reiner Titan bis zur Ur-Gründerin Ymir Fritz.',
  'push alerts & notices': 'Alertes push et notifications',
  'quick local backup created': 'Lokale Sicherung erstellt',
  'ratio': 'Verhältnis',
  'real-time metrics': 'Métriques en temps réel',
  'real-time traffic audit': 'Echtzeit-Datenverkehr-Audit',
  'rebirth through fire. the old is ash; you are the flame.':
      'Wiedergeburt durch Feuer. Das Alte ist Asche; du bist die Flamme.',
  'recent': 'Kürzlich',
  'recent messages': 'Letzte Nachrichten',
  'recently deleted': 'KÜRZLICH GELÖSCHT',
  'recommended for standard users.': 'Empfohlen für Standardbenutzer.',
  'refresh activity': 'Aktivität aktualisieren',
  'remind if inactive for': 'Erinnern bei Inaktivität seit',
  'reminder message': 'Erinnerungsnachricht',
  'reminders': 'Erinnerungen',
  'reminders & notifications': 'Erinnerungen & Benachrichtigungen',
  'report a bug': 'Fehler melden',
  'repository link copied to clipboard':
      'Repository-Link in Zwischenablage kopiert',
  'repository moved': 'Dépôt déplacé',
  'request a feature': 'Funktion vorschlagen',
  'required for notekar to install downloaded apk updates automatically.':
      'Requis pour que NoteKar installe automatiquement les mises à jour APK téléchargées.',
  'required to show the logging alerts.':
      'Erforderlich für Protokollierungs-Benachrichtigungen.',
  'reset': 'Réinitialiser',
  'reset all data': 'Alle Daten zurücksetzen',
  'reset daily': 'Réinitialiser quotidiennement',
  'reset data': 'Réinitialiser les données',
  'reset numbering daily': 'Réinitialiser la numérotation chaque jour',
  'reset on relapse tag only': 'Nur bei Rückfall-Tag zurücksetzen',
  'reset pin lock': 'PIN-Sperre zurücksetzen',
  'reset settings': 'Réinitialiser les paramètres',
  'reset settings only': 'Nur Einstellungen zurücksetzen',
  'resetcategory': 'Réinitialisation',
  'restarts count at 00 every midnight while keeping past history intact.':
      'Startet die Zählung jeden Tag um Mitternacht bei 00 neu, während vergangene Einträge erhalten bleiben.',
  'restore': 'Wiederherstellen',
  'restore all': 'Alle wiederherstellen',
  'restore all moments?': 'Alle Momente wiederherstellen?',
  'restore deleted moments': 'Gelöschte Momente wiederherstellen',
  'restore or permanently remove deleted moments':
      'Restaurer ou supprimer définitivement les moments effacés',
  'retry download': 'Download wiederholen',
  'review and export': 'Consulter et exporter',
  'review backup': 'Sicherung überprüfen',
  'review history': 'Verlauf überprüfen',
  'royal ocean': 'Océan royal',
  'rpg / minecraft': 'RPG / Minecraft',
  'russian': 'Russe',
  's mate victim to magnus carlsen.': 'Vom Anfänger zum Großmeister.',
  's new': 'Neuigkeiten',
  's new in notekar': 'Neuigkeiten in NoteKar',
  'sad': 'Traurig',
  'samurai': 'Samurai',
  'sapphire': 'Saphir',
  'sat': 'Sa',
  'saturday': 'Samstag',
  'save': 'Enregistrer',
  'save a moment': 'Moment speichern',
  'science': 'Wissenschaft',
  'seafaring odyssey. chart new waters and never look back.':
      'Seefahrt-Odyssee. Erkunden Sie neue Gewässer und blicken Sie nicht zurück.',
  'search notes': 'Rechercher des notes',
  'search settings': 'Rechercher dans les paramètres',
  'search settings...': 'Rechercher dans les paramètres...',
  'secure passcode protection': 'Sicherer Passcode-Schutz',
  'security & cryptographic upgrade':
      'Mise à niveau de sécurité et cryptographie',
  'security & integrity': 'Sicherheit & Integrität',
  'select a theme that best suits your environment.':
      'Sélectionnez le thème le mieux adapté à votre environnement.',
  'select date': 'Sélectionner une date',
  'select date and time': 'Datum und Uhrzeit auswählen',
  'select for duration': 'Für Dauer auswählen',
  'select time': 'Uhrzeit auswählen',
  'select your preferred language for the application.':
      'Wählen Sie Ihre bevorzugte Sprache für die Anwendung.',
  'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.':
      'Die fortlaufende Einzelnummerierung (00–99) erfordert Standard-Zeilenabstand zur Anzeige der 2-stelligen Abzeichen. Deaktivieren Sie den kompakten Verlauf, um Ziffern zu aktivieren.',
  'sessions are recorded as in and out pairs.':
      'Sitzungen werden als IN- und OUT-Paare aufgezeichnet.',
  'set': 'Festgelegt',
  'set passcode': 'Code festlegen',
  'set sobriety start date': 'Nüchternheitsstartdatum festlegen',
  'set unrestricted': 'Uneingeschränkt festlegen',
  'settings': 'Paramètres',
  'settings restored': 'Einstellungen wiederhergestellt',
  'sha-256 hashes': 'SHA-256-Hashes',
  'share': 'Teilen',
  'share card': 'Karte teilen',
  'share milestone peak': 'Meilenstein-Höhepunkt teilen',
  'shinpachi to utsuro.': 'Shinpachi bis Utsuro.',
  'shirley to emperor lelouch vi britannia.':
      'Shirley bis Kaiser Lelouch vi Britannia.',
  'show more': 'Mehr anzeigen',
  'show seconds': 'Afficher les secondes',
  'shows 00–99 counters instead of static icons in history.':
      'Zeigt 00–99 Zähler anstelle von statischen Symbolen im Verlauf an.',
  'shows sequential numbers (00, 01...) on the tap pulse animation.':
      'Zeigt fortlaufende Nummern (00, 01...) auf der Tap-Puls-Animation an.',
  'signature': 'Signatur',
  'single': 'Unique',
  'single mode': 'Einzel-Modus',
  'single moment numbering': 'Numérotation des moments uniques',
  'skip': 'Überspringen',
  'smaller, optimized apks': 'Kleinere, optimierte APKs',
  'smart bandwidth saver': 'Économiseur intelligent de bande passante',
  'sobriety companion': 'Compagnon de sobriété',
  'sobriety tracker': 'Suivi de sobriété',
  'sobriety tracker & milestone cards': 'Abstinenz-Tracker & Meilensteinkarten',
  'sobriety trigger analysis': 'Nüchternheits-Auslöser-Analyse',
  'social media': 'Réseaux sociaux',
  'social_media': 'Soziale Medien',
  'software credits and open source legal notices':
      'Crédits logiciels et avis légaux open source',
  'software licenses': 'Softwarelizenzen',
  'software update': 'Mise à jour logicielle',
  'software update, app notices, changelog':
      'Mise à jour logicielle, avis, journal des modifications',
  'solo leveling': 'Solo Leveling',
  'space': 'Weltraum',
  'spanish': 'Espagnol',
  'stable': 'Stable',
  'stable build': 'Version stable',
  'star wars': 'Star Wars',
  'start logging': 'Protokollieren starten',
  'startup mode': 'Mode de démarrage',
  'status': 'Status',
  'storage error: moment not saved': 'Speicherfehler: Moment nicht gespeichert',
  'streak mode': 'Serien-Modus',
  'streak reset logic': 'Serien-Rücksetzlogik',
  'streak shield deployed! clean streak protected.':
      'Serienschild aktiviert! Serie geschützt.',
  'stress': 'Stress',
  'stressed': 'Gestresst',
  'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.':
      'Reichen Sie Fehlerberichte und Feature-Wünsche direkt im neuen Issue-Tracker ein.',
  'suggest a new idea or improvement.':
      'Schlagen Sie eine neue Idee oder Verbesserung vor.',
  'sun': 'So',
  'sunday': 'Sonntag',
  'sunset': 'Sonnenuntergang',
  'support & community': 'Support et communauté',
  'survival of the fittest. tardigrade to mythical dragon.':
      'Survie du plus apte. Du tardigrade au dragon mythique.',
  'switching to beta build...': 'Wechsel zur Beta-Version...',
  'switching to stable build...': 'Wechsel zur stabilen Version...',
  'system': 'Système',
  'system default': 'Par défaut du système',
  'system lock': 'Systemsperre',
  'system lock enabled': 'Systemsperre aktiviert',
  'table': 'Tabelle',
  'tangerine coral': 'Corail mandarine',
  'tap any icon below to switch style':
      'Appuyez sur une icône ci-dessous pour changer de style',
  'tap any icon below to switch style. you can change this anytime in settings.':
      'Appuyez sur une icône ci-dessous pour changer de style. Vous pouvez la modifier à tout moment dans les Paramètres.',
  'tap delay': 'Tipp-Verzögerung',
  'tap to record a moment. hold to add a note.':
      'Appuyez pour enregistrer un moment. Maintenez pour ajouter une note.',
  'tap to save': 'Appuyer pour enregistrer',
  'tech career': 'Technik-Karriere',
  'technical stats about your device and the adaptive engine.':
      'Statistiques techniques sur votre appareil et le moteur adaptatif.',
  'teddy bear kon to yhwach the almighty.':
      'Plüschbär Kon bis Yhwach der Allmächtige.',
  'terms of use': 'Nutzungsbedingungen',
  'the current features on this page are under beta stage.':
      'Les fonctionnalités actuelles de cette page sont en phase bêta.',
  'theme': 'Thème',
  'theme description': 'Themenbeschreibung',
  'theme mode': 'Design-Modus',
  'theme style': 'Design-Stil',
  'these languages are planned for future releases. help translate notekar on github.':
      'Ces langues sont prévues pour de prochaines versions. Aidez à traduire NoteKar sur GitHub.',
  'these settings refine the interface aesthetic and do not modify your saved data.':
      'Diese Einstellungen verfeinern die Benutzeroberfläche und ändern keine gespeicherten Daten.',
  'these tools are intended for system maintenance and troubleshooting.':
      'Ces outils sont destinés à la maintenance du système et au dépannage.',
  'this backup contains no moments': 'Diese Sicherung enthält keine Momente',
  'this feature is currently in active development. while fully functional and secure, you may notice minor adjustments to the layout or performance as we refine the experience. all calculations, data, and security policies remain entirely local to your device.':
      'Diese Funktion befindet sich in aktiver Entwicklung. Sie ist voll funktionsfähig und sicher. Alle Berechnungen und Daten bleiben lokal auf Ihrem Gerät.',
  'this language is currently under development. you can help translate notekar into your native language by contributing on github.':
      'Cette langue est actuellement en cours de développement. Vous pouvez aider à traduire NoteKar dans votre langue maternelle en contribuant sur GitHub.',
  'this local backup file will be erased permanently.':
      'Ce fichier de sauvegarde locale sera définitivement effacé.',
  'this moment will be erased forever.':
      'Dieser Moment wird unwiderruflich gelöscht.',
  'this week': 'Cette semaine',
  'this will permanently delete all moments in the trash. this action cannot be undone.':
      'Dadurch werden alle Momente im Papierkorb endgültig gelöscht. Dieser Vorgang kann nicht rückgängig gemacht werden.',
  'this will permanently delete all moments. this action cannot be undone.':
      'Dadurch werden alle Momente unwiderruflich gelöscht.',
  'this will return all items currently in the trash to your history.':
      'Dadurch werden alle Elemente aus dem Papierkorb wiederhergestellt.',
  'thu': 'Do',
  'thursday': 'Donnerstag',
  'time': 'Uhrzeit',
  'time between moments': 'Zeit zwischen Momenten',
  'tired': 'Müde',
  'to download and install software updates directly within notekar, please configure the following security settings:':
      'Pour télécharger et installer les mises à jour logicielles directement dans NoteKar, veuillez configurer les paramètres de sécurité suivants :',
  'to trigger reminders precisely when the app is closed, notekar requires the "alarms & reminders" permission.':
      'Um Erinnerungen präzise auszulösen, benötigt NoteKar die Berechtigung „Alarme & Erinnerungen“.',
  'today': 'Aujourd\'hui',
  'tonpa to adult gon.': 'Tonpa bis zum erwachsenen Gon.',
  'tools': 'Outils',
  'top mood': 'Häufigste Stimmung',
  'top trigger': 'Häufigster Auslöser',
  'total relapses': 'Rückfälle insgesamt',
  'total requests': 'Gesamtanfragen',
  'track starts and stops': 'Suivre les débuts et fins',
  'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.':
      'Verwandeln Sie Ihren Verlauf mit 2-stelligen Zählern (00–99), täglichen Mitternachtsrücksetzungen und einem Kalender im iOS-Stil.',
  'trash bin': 'Corbeille',
  'trash is empty': 'Papierkorb ist leer',
  'trigger analysis': 'Auslöser-Analyse',
  'trigger diary': 'Auslöser-Tagebuch',
  'triggers reminders on specific days of the week.':
      'Déclenche des rappels certains jours spécifiques de la semaine.',
  'try again in seconds': 'In wenigen Sekunden erneut versuchen',
  'try another keyword': 'Anderes Suchwort versuchen',
  'tue': 'Di',
  'tuesday': 'Dienstag',
  'turn off & enable': 'Deaktivieren & Aktivieren',
  'turn off reduced motion first': 'Zuerst Bewegungsreduktion deaktivieren',
  'turn off single numbers?': 'Einzelne Ziffern deaktivieren?',
  'tutorials': 'Tutorials',
  'two-way': 'Deux sens',
  'two-way mode': 'Zwei-Wege-Modus',
  'type to search your notes...': 'Tippen, um Notizen zu durchsuchen...',
  'undetected': 'Nicht erkannt (Sauber)',
  'undo': 'Rückgängig',
  'upcoming': 'À venir',
  'upcoming languages': 'Langues à venir',
  'update available': 'Update verfügbar',
  'update check failed': 'Update-Prüfung fehlgeschlagen',
  'update track': 'Canal de mise à jour',
  'updates & notices': 'Mises à jour et avis',
  'use fingerprint, face, or system pin.':
      'Verwenden Sie Fingerabdruck, Gesicht oder System-PIN.',
  'use numbers in single': 'Numérotation en mode unique',
  'use single or two-way mode based on your flow.':
      'Utilisez le mode Unique ou Deux sens selon votre rythme.',
  'velvet ruby': 'Rubis velours',
  'verified clean of malicious activity':
      'Nachweislich frei von schädlicher Software',
  'verified safe': 'Vérifié et sûr',
  'verifying integrity checksum...': 'Integritätsprüfsumme wird überprüft...',
  'version': 'Version',
  'view': 'Anzeigen',
  'view all milestones': 'Alle Meilensteine anzeigen',
  'view full licenses': 'Vollständige Lizenzen anzeigen',
  'view note': 'Notiz anzeigen',
  'view your relapse pattern insights, top moods, and peak vulnerability windows.':
      'Sehen Sie Einblicke in Rückfallmuster, Top-Stimmungen und Phasen höchster Anfälligkeit.',
  'vinland saga': 'Vinland Saga',
  'virustotal safety scan': 'VirusTotal-Sicherheitsüberprüfung',
  'virustotal scan': 'Analyse VirusTotal',
  'vt report': 'VirusTotal-Bericht',
  'warrior': 'Krieger',
  'we have officially migrated our codebase to a new home. all future releases, updates, and issues will be managed here:':
      'Wir haben unsere Codebasis offiziell verlegt. Alle zukünftigen Releases werden hier verwaltet:',
  'wed': 'Mi',
  'wednesday': 'Mittwoch',
  'weekly reminder': 'Rappel hebdomadaire',
  'weekly reminder message': 'Wöchentliche Erinnerungsnachricht',
  'welcome': 'Willkommen',
  'welcome to notekar': 'Bienvenue sur NoteKar',
  'were you already clean before installing? set your actual start date here. this overrides automatic detection from your logs.':
      'Waren Sie vor der Installation bereits abstinent? Legen Sie hier Ihr tatsächliches Startdatum fest.',
  'whatsnewtitle': 'Nouveautés',
  'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.':
      'Beim Protokollieren mit aktiviertem Nüchternheitsmodus können Sie Stimmung und Auslöser markieren.',
  'wipe': 'Löschen',
  'wooden shovel to creative mode god.':
      'Holzschaufel bis zum Gott des Kreativmodus.',
  'yamcha to the omni-king zeno.': 'Yamchu bis zum Allkönig Zeno.',
  'yoki to the ultimate truth.': 'Yoki bis zur ultimativen Wahrheit.',
  'you are up to date': 'Sie sind auf dem neuesten Stand',
  'your clean streak is active and running.': 'Ihre Serie ist aktiv und läuft.',
  'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.':
      'Ihre Daten sind zu 100 % privat und bleiben offline auf diesem Gerät.',
  'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.':
      'Ihr Startbildschirm zeigt eine Live-Serienkarte mit Meilensteinabzeichen.',
  'your privacy matters': 'Ihre Privatsphäre ist wichtig',
  'zero telemetry & offline integrity':
      'Zéro télémétrie et intégrité hors ligne',
};

const Map<String, String> _deTranslations = {
  '* have suggestions or found a bug?':
      '* Haben Sie Vorschläge oder einen Fehler gefunden?',
  '* have suggestions or found a bug? ':
      '* Haben Sie Vorschläge oder einen Fehler gefunden? ',
  '0 / 68 clean': '0 / 68 sauber',
  '100% offline': '100% Offline',
  '100% offline database': '100% Offline-Datenbank',
  '100% offline integrity': '100% Offline-Integrität',
  '100% offline-first. zero trackers. zero data collection':
      '100% Offline-First. Keine Tracker. Keine Datenerfassung',
  '16-week habit activity grid': '16-Wochen-Gewohnheitsaktivitätsraster',
  '5-4-3-2-1 grounding': '5-4-3-2-1 Erdungstechnik',
  '8 luxury app icon editions': '8 Luxus-App-Icon-Editionen',
  'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.':
      'Ein datenschutzorientiertes Offline-Serientracking und Tagebuch zur Unterstützung Ihrer Genesung.',
  'a quiet, offline-first way to mark moments the second they happen.':
      'Eine ruhige, lokale Möglichkeit, Momente im Augenblick festzuhalten.',
  'about': 'Über',
  'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.':
      'Absolut. NoteKar ist Open Source und offline-first. Jede Version wird von 60+ Sicherheits-Engines über VirusTotal verifiziert.',
  'accent color': 'Akzentfarbe',
  'accentcolorcategory': 'Akzentfarbe',
  'accept': 'Akzeptieren',
  'access split-per-abi optimized binaries and google play appbundles directly from the release page.':
      'Laden Sie ABI-optimierte Binärdateien direkt von der Release-Seite herunter.',
  'accessibility': 'Bedienungshilfen',
  'accessibilitycategory': 'Bedienungshilfen',
  'active': 'Aktiv',
  'active issue tracking': 'Aktives Issue-Tracking',
  'active launcher icon': 'Aktives App-Symbol',
  'active protection': 'Aktiver Schutz',
  'activity': 'Aktivität',
  'adaptive engine': 'Adaptive Engine',
  'adaptive engine and performance status': 'Adaptive Engine & Leistungsstatus',
  'adaptive engine overview': 'Übersicht der Adaptive Engine',
  'add a note': 'Notiz hinzufügen',
  'add a note to save': 'Notiz zum Speichern hinzufügen',
  'adds a clean streak card to your home screen and adapts home screen widgets.':
      'Fügt Ihrem Startbildschirm eine übersichtliche Serienkarte hinzu und passt Widgets an.',
  'adds a subtle glass-like container behind the home toolbar.':
      'Fügt einen dezenten Glas-Container hinter der Symbolleiste ein.',
  'afternoon': 'Nachmittag',
  'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.':
      'Deaktivieren Sie die Akku-Optimierung, um sicherzustellen, dass Erinnerungen immer zuverlässig ausgelöst werden.',
  'alarms permission required': 'Alarm-Berechtigung erforderlich',
  'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.':
      'Alle 21 Meilensteine von 1 Tag bis 10 Jahren, fundiert in Neurowissenschaft und Verhaltenspsychologie.',
  'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.':
      'Alle Builds durchlaufen automatisierte CodeQL- und VirusTotal-Prüfungen zur Gewährleistung der Sicherheit.',
  'all moments in the database will be permanently removed. this cannot be undone.':
      'Alle Momente in der Datenbank werden dauerhaft gelöscht. Dies kann nicht rückgängig gemacht werden.',
  'all settings will be restored to their initial factory defaults. your saved moments and notes will remain untouched.':
      'Alle Einstellungen werden auf die Werkseinstellungen zurückgesetzt. Ihre gespeicherten Momente und Notizen bleiben erhalten.',
  'all time': 'Gesamte Zeit',
  'allow app installation': 'App-Installation erlauben',
  'allow auto-start settings': 'Autostart-Einstellungen erlauben',
  'allow notifications': 'Benachrichtigungen zulassen',
  'allows notekar to send logging reminders and update notifications.':
      'Erlaubt NoteKar, Protokoll-Erinnerungen und Update-Benachrichtigungen zu senden.',
  'amethyst': 'Amethyst',
  'amethyst nebula': 'Amethyst-Nebel',
  'amoled': 'AMOLED',
  'ancient': 'Antike',
  'android backup': 'Android-Sicherung',
  'angry': 'Wütend',
  'animal kingdom': 'Tierreich',
  'anxious': 'Ängstlich / Besorgt',
  'app icon': 'App-Icon',
  'app icon could not be changed': 'App-Symbol konnte nicht geändert werden',
  'app icons': 'App-Symbole',
  'app language': 'App-Sprache',
  'app lock': 'App-Sperre',
  'app lock & biometrics': 'App-Sperre & Biometrie',
  'app lock & security': 'App-Sperre & Sicherheit',
  'app lock appears after the notification panel':
      'App-Sperre erscheint nach dem Benachrichtigungsfeld',
  'app lock needs a device screen lock':
      'App-Sperre erfordert eine Bildschirmsperre',
  'app lock timing': 'App-Sperrzeit',
  'app lock will not turn on': 'App-Sperre lässt sich nicht aktivieren',
  'app notices': 'App-Hinweise',
  'app notices are not appearing': 'App-Benachrichtigungen erscheinen nicht',
  'app preferences and theme': 'App-Einstellungen & Theme',
  'app switcher obfuscation': 'Verschleierung im App-Umschalter',
  'app theme': 'App-Farbschema',
  'app usage': 'App-Nutzung',
  'app version': 'App-Version',
  'appearance': 'Erscheinungsbild',
  'appiconscategory': 'App-Symbole',
  'application build identifier': 'Anwendungs-Build-Kennung',
  'apply a custom accent color across all fluid interface elements.':
      'Wendet eine benutzerdefinierte Akzentfarbe auf alle fließenden UI-Elemente an.',
  'applying app icon': 'App-Symbol wird angewendet',
  'army elite. every clean day is a battle fought and won.':
      'Armee-Elite. Jeder saubere Tag ist eine gewonnene Schlacht.',
  'as a small, offline-first timestamp logger for real work: quick taps, focused notes, and exports developers can inspect.':
      'als schlanker, offline-fähiger Zeitstempel-Logger für die Praxis: schnelle Taps, fokussierte Notizen und einsehbare Exporte.',
  'at': 'um',
  'attach context without slowing the app down.':
      'Fügen Sie Kontext hinzu, ohne die App zu verlangsamen.',
  'attack on titan': 'Attack on Titan',
  'aurora': 'Aurora',
  'aurora borealis': 'Nordlicht (Aurora)',
  'auto-start & background activity': 'Autostart & Hintergrundaktivität',
  'automated security scans': 'Automatisierte Sicherheits-Scans',
  'automatic': 'Automatisch',
  'available languages': 'Verfügbare Sprachen',
  'back': 'Zurück',
  'back up data': 'Daten sichern',
  'backup & export': 'Sicherung & Export',
  'backup & restore': 'Sicherung & Wiederherstellung',
  'backup filename preview': 'Vorschau des Backup-Dateinamens',
  'backup has no new moments': 'Sicherung enthält keine neuen Momente',
  'backup import failed': 'Sicherungsimport fehlgeschlagen',
  'backup import found no new moments':
      'Sicherungsimport ergab keine neuen Momente',
  'backup reminder: export a fresh backup soon':
      'Sicherungs-Erinnerung: Bald neue Sicherung exportieren',
  'backup status': 'Sicherungsstatus',
  'backupexportcategory': 'Sicherung & Export',
  'battery and performance status': 'Akku- & Leistungsstatus',
  'battery optimization active': 'Akku-Optimierung aktiv',
  'ben 10': 'Ben 10',
  'beta': 'Beta',
  'beta feature': 'Beta-Funktion',
  'beta track': 'Beta-Kanal',
  'biometric lock': 'Biometrische Sperre',
  'biometrics not available': 'Biometrie nicht verfügbar',
  'biometrics or system credentials': 'Biometrie oder System-Anmeldedaten',
  'bleach': 'Bleach',
  'blur & translucency': 'Unschärfe & Transparenz',
  'bored': 'Gelangweilt',
  'boredom': 'Langeweile',
  'box breathing': 'Box-Atmung',
  'build cache cleared': 'Build-Cache geleert',
  'build cache size': 'Build-Cache-Größe',
  'build date': 'Build-Datum',
  'build number': 'Build-Nummer',
  'built by': 'Entwickelt von',
  'bushido code. master of the self.': 'Bushido-Kodex. Meister des Selbst.',
  'buy me a coffee': 'Kauf mir einen Kaffee',
  'can i restore deleted moments?':
      'Kann ich gelöschte Momente wiederherstellen?',
  'cancel': 'Abbrechen',
  'capture': 'Erfassung',
  'capture cooldown': 'Erfassungs-Abklingzeit',
  'capture delay & cooldown': 'Erfassungsverzögerung & Cooldown',
  'capturecategory': 'Erfassung',
  'celtic highland clan. earn your place, carry the banner.':
      'Keltischer Hochland-Clan. Verdiene deinen Platz, trage das Banner.',
  'change your secure in-app passcode.':
      'Ändern Sie Ihren sicheren In-App-Passcode.',
  'changelog': 'Änderungsprotokoll',
  'changelogtitle': 'Änderungsprotokoll',
  'check again': 'Erneut prüfen',
  'check for updates': 'Nach Updates suchen',
  'checking for updates...': 'Suche nach Updates...',
  'chess mastery': 'Schach-Meisterschaft',
  'choose how notekar starts when you open it':
      'Wählen Sie, wie NoteKar beim Öffnen startet',
  'choose language': 'Sprache wählen',
  'choose milestone theme': 'Meilenstein-Design wählen',
  'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.':
      'Wählen Sie den narrativen Stil für Ihre Meilensteine. Jedes Thema ist psychologisch kuratiert.',
  'choose your preferred interface language':
      'Wählen Sie Ihre bevorzugte Oberflächensprache',
  'civilian to the one above all.': 'Zivilist bis zum Einen über Allen.',
  'clan': 'Klan',
  'clear': 'Löschen',
  'clear all moments': 'Alle Momente löschen',
  'clear cache': 'Cache leeren',
  'clear search': 'Suche löschen',
  'clear trash': 'Papierkorb leeren',
  'clinical neuroscience terms. cold, precise, honest.':
      'Klinische neurowissenschaftliche Begriffe. Kühl, präzise, ehrlich.',
  'close': 'Schließen',
  'code geass': 'Code Geass',
  'color accent': 'Akzentfarbe',
  'commits': 'Commits',
  'compact history': 'Kompakter Verlauf',
  'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.':
      'Der kompakte Verlauf kann nicht aktiviert werden, solange die Einzelzählung aktiv ist. Deaktivieren Sie die Einzelziffern, um kompakte Zeilen zu verwenden.',
  'compact history mode': 'Kompakter Verlaufsmodus',
  'configure a dedicated 4-digit passcode.':
      'Richten Sie einen 4-stelligen Passcode ein.',
  'configure settings': 'Einstellungen anpassen',
  'confirm': 'Bestätigen',
  'confirm delete': 'Löschen bestätigen',
  'confirm passcode': 'Code bestätigen',
  'continue': 'Weiter',
  'continuous': 'Fortlaufend',
  'contribute on github': 'Auf GitHub beitragen',
  'cooldown period': 'Abklingzeit',
  'copy': 'Kopieren',
  'copy moment': 'Moment kopieren',
  'correlation intelligence': 'Korrelations-Intelligenz',
  'cosmic exploration. every clean day is light-years gained.':
      'Kosmische Erkundung. Jeder saubere Tag bringt Lichtjahre ein.',
  'could not open backup file': 'Sicherungsdatei konnte nicht geöffnet werden',
  'count on save': 'Zähler beim Speichern',
  'create quick local backup': 'Schnelle lokale Sicherung erstellen',
  'crimson': 'Karminrot',
  'current message': 'Aktuelle Nachricht',
  'cursed spirit to satoru gojo.': 'Fluchgeist bis Satoru Gojo.',
  'custom start date': 'Benutzerdefiniertes Startdatum',
  'daily logging reminder': 'Tägliche Protokoll-Erinnerung',
  'daily neuroscience insight': 'Täglicher Neurowissenschafts-Einblick',
  'daily reminder': 'Tägliche Erinnerung',
  'daily reminder message': 'Tägliche Erinnerungsnachricht',
  'daily reminders': 'Tägliche Erinnerungen',
  'dark mode': 'Dunkelmodus',
  'data': 'Daten',
  'data & backup': 'Daten & Sicherung',
  'data consumed': 'Verbrauchte Daten',
  'data health': 'Daten-Zustand',
  'database export': 'Datenbank-Export',
  'database integrity': 'Datenbank-Integrität',
  'day of month': 'Tag des Monats',
  'days of week': 'Wochentage',
  'death note': 'Death Note',
  'delete': 'Löschen',
  'delete all moments?': 'Alle Momente löschen?',
  'delete backup?': 'Sicherung löschen?',
  'delete cache': 'Cache löschen',
  'delete moment': 'Moment löschen',
  'delete permanently': 'Dauerhaft löschen',
  'delete permanently?': 'Endgültig löschen?',
  'deleted in moment': 'IN-Moment gelöscht',
  'deleted out moment': 'OUT-Moment gelöscht',
  'deleted single moment': 'SINGLE-Moment gelöscht',
  'deleting cache...': 'Cache wird gelöscht...',
  'demon slayer': 'Demon Slayer',
  'dev': 'Entwicklung',
  'developer diagnostics': 'Entwickler-Diagnose',
  'developer key': 'Entwickler-Schlüssel',
  'developer options': 'Entwickleroptionen',
  'device health': 'Gerätezustand',
  'diagnostics': 'Diagnose',
  'diagnostics and internal engine settings for developers.':
      'Diagnose und interne Engine-Einstellungen für Entwickler.',
  'diagnosticscategory': 'Diagnose',
  'disable battery optimization': 'Akku-Optimierung deaktivieren',
  'disable compact history?': 'Kompakten Verlauf deaktivieren?',
  'disable reduce motion first': '最初に「視覚効果を減らす」を無効にしてください',
  'disable use numbers in single?': 'Nummerierung im Einzelmodus deaktivieren?',
  'disabled': 'Deaktiviert',
  'dismiss': 'Schließen',
  'display': 'Anzeige',
  'display & typography': 'Anzeige & Typografie',
  'displaycategory': 'Anzeige',
  'docs': 'Dokumentation',
  'done': 'Fertig',
  'download': 'Herunterladen',
  'download & install': 'Herunterladen & Installieren',
  'download failed': 'Download fehlgeschlagen',
  'download from github': 'Von GitHub herunterladen',
  'download size:': 'Download-Größe:',
  'downloading update...': 'Update wird heruntergeladen...',
  'dragon ball': 'Dragon Ball',
  'e-rank sung jinwoo to shadow monarch.':
      'E-Rang Sung Jinwoo bis zum Schattenmonarchen.',
  'east blue coby to the pirate king gol d. roger.':
      'East Blue Corby bis zum Piratenkönig Gol D. Roger.',
  'edit': 'Bearbeiten',
  'edit message': 'Nachricht bearbeiten',
  'edit note': 'Notiz bearbeiten',
  'email support': 'E-Mail-Support',
  'emerald': 'Smaragd',
  'emerald forest': 'Smaragdwald',
  'empty': 'Leer',
  'empty trash': 'Papierkorb leeren',
  'empty trash?': 'Papierkorb leeren?',
  'enable count on save': 'Zähler beim Speichern anzeigen',
  'enable show seconds first': 'Zuerst Sekunden anzeigen aktivieren',
  'enable sobriety mode': 'Nüchternheitsmodus aktivieren',
  'encrypted backup': 'Verschlüsselte Sicherung',
  'endpoint url': 'Endpunkt-URL',
  'english': 'Englisch',
  'enter passcode': 'Code eingeben',
  'enter reminder message...': 'Erinnerungstext eingeben...',
  'essential features': 'Wesentliche Funktionen',
  'evening': 'Abend',
  'every 14 days': 'Alle 14 Tage',
  'every 30 days': 'Alle 30 Tage',
  'every 7 days': 'Alle 7 Tage',
  'every tap records a standalone moment.':
      'Jedes Antippen zeichnet einen eigenständigen Moment auf.',
  'export backup': 'Sicherung exportieren',
  'export csv': 'CSV exportieren',
  'export failed. try again.': 'Export fehlgeschlagen. Erneut versuchen.',
  'export json': 'JSON exportieren',
  'export last 7 days': 'Letzte 7 Tage exportieren',
  'export milestone card': 'Meilenstein-Karte exportieren',
  'export saved to downloads': 'Export in Downloads gespeichert',
  'export, import, and manage your data backups.':
      'Exportieren, importieren und verwalten Sie Ihre Datensicherungen.',
  'extended duration': 'Erweiterte Dauer',
  'external navigation': 'Externe Weiterleitung',
  'factory reset': 'Werksreset',
  'failed to create local backup': 'Fehler beim Erstellen der Sicherung',
  'failed to read local backup file':
      'Lokale Sicherungsdatei konnte nicht gelesen werden',
  'faq': 'Häufige Fragen',
  'fatigue': 'Ermüdung',
  'feedback': 'Feedback',
  'feedback & bug report': 'Feedback & Fehlerbericht',
  'fri': 'Fr',
  'friday': 'Freitag',
  'friends': 'Freunde',
  'from': 'Von',
  'full': 'Vollständig',
  'full online policy': 'Vollständige Online-Richtlinie',
  'full online terms': 'Vollständige Online-Bedingungen',
  'full title & purpose': 'Vollständiger Titel & Zweck',
  'fullmetal alchemist': 'Fullmetal Alchemist',
  'german': 'Deutsch',
  'get started': 'Loslegen',
  'gintama': 'Gintama',
  'github': 'GitHub',
  'give feedback': 'Feedback geben',
  'google drive backup': 'Google Drive Sicherung',
  'got it': 'Verstanden',
  'grant permission': 'Berechtigung erteilen',
  'greek and roman glory. rise from mortal to olympian.':
      'Griechischer und römischer Ruhm. Steige vom Sterblichen zum Olympier auf.',
  'grey matter to alien x.': 'Graue Eminenz bis Alien X.',
  'guides': 'Anleitungen',
  'happy': 'Glücklich',
  'hardware security': 'Hardware-Sicherheit',
  'hardware-backed encryption': 'Hardware-gestützte Verschlüsselung',
  'harry potter': 'Harry Potter',
  'have suggestions or found a bug?':
      'Haben Sie Vorschläge oder einen Fehler gefunden?',
  'help': 'Hilfe',
  'help & user guides': 'Hilfe & Benutzerhandbuch',
  'hide app content in recents': 'App-Inhalt im Task-Manager verbergen',
  'hindi': 'Hindi',
  'history': 'Verlauf',
  'hold for notes': 'Gedrückt halten für Notizen',
  'hour': 'Stunde',
  'hours': 'Stunden',
  'html editor to turing award winner.':
      'HTML-Editor bis zum Turing-Preisträger.',
  'hunter x hunter': 'Hunter x Hunter',
  'imperial': 'Kaiserlich',
  'imperial gold': 'Kaiserliches Gold',
  'import backup': 'Sicherung importieren',
  'import cancelled': 'Import abgebrochen',
  'important notice': 'Wichtiger Hinweis',
  'in-app ota updates': 'In-App OTA-Updates',
  'in-app pin': 'In-App-PIN',
  'in-app pin set successfully.': 'In-App-PIN erfolgreich festgelegt.',
  'in-app update setup': 'In-App-Update-Einrichtung',
  'inactive': 'Inaktiv',
  'inactivity alerts': 'Inaktivitäts-Warnungen',
  'inactivity reminder': 'Inaktivitäts-Erinnerung',
  'incorrect passcode': 'Falscher Code',
  'install now': 'Jetzt installieren',
  'installation failed to start': 'Installation konnte nicht gestartet werden',
  'integrity check failed: checksum mismatch':
      'Integritätsprüfung fehlgeschlagen: Prüfsummenfehler',
  'intelligent risk radar': 'Intelligenter Risiko-Radar',
  'invalid backup file': 'Ungültige Sicherungsdatei',
  'is notekar private?': 'Ist NoteKar privat?',
  'is notekar safe to use?': 'Ist NoteKar sicher zu verwenden?',
  'item': 'Element',
  'items': 'Elemente',
  'japanese': 'Japanisch',
  'jujutsu kaisen': 'Jujutsu Kaisen',
  'july 2026': 'Juli 2026',
  'kingdom': 'Königreich',
  'konohamaru to the sage of six paths.':
      'Konohamaru bis zum Weisen der Sechs Pfade.',
  'language': 'Sprache',
  'last scan': 'Letzter Scan',
  'late night': 'Späte Nacht',
  'late_night': 'Späte Nacht',
  'learn more': 'Mehr erfahren',
  'legal & open source notices': 'Rechtliche & Open-Source-Hinweise',
  'less': 'Weniger',
  'licenses': 'Lizenzen',
  'limited connectivity': 'Begrenzte Verbindung',
  'link copied': 'Link kopiert',
  'live activity tracking dashboard featuring real-time metric analysis, habit tracking grids, activity trends, and correlation intelligence calculated from your moments.':
      'Live-Aktivitäts-Dashboard mit Echtzeit-Metriken, Gewohnheitsrastern, Trends und Korrelations-Intelligenz aus Ihren Momenten.',
  'live icon motion looks slow or delayed':
      'Live-Icon-Bewegung wirkt verzögert',
  'live icon motion will not turn on':
      'Live-Icon-Bewegung lässt sich nicht aktivieren',
  'load older moments': 'Ältere Momente laden',
  'loading database...': 'Datenbank wird geladen...',
  'local backups': 'Lokale Sicherungen',
  'local storage': 'Lokaler Speicher',
  'location': 'Ort',
  'log a moment instantly from the main screen.':
      'Erfassen Sie einen Moment sofort vom Hauptbildschirm aus.',
  'logging': 'Protokollierung',
  'logging reminder': 'Protokoll-Erinnerung',
  'logging reminders': 'Protokoll-Erinnerungen',
  'logs': 'Protokolle',
  'loneliness': 'Einsamkeit',
  'lonely': 'Einsam',
  'magikarp to the creator god arceus.':
      'Karpador bis zum Schöpfergott Arceus.',
  'manage': 'Verwalten',
  'manage moment notes': 'Moment-Notizen verwalten',
  'manage security, passcode lock, and app privacy.':
      'Sicherheit, Codesperre und App-Datenschutz verwalten.',
  'marvel universe': 'Marvel-Universum',
  'matsuda to the shinigami king.': 'Matsuda bis zum König der Todesgötter.',
  'medieval royalty. rise from serf to sovereign.':
      'Mittelalterlicher Adel. Vom Knecht zum Herrscher.',
  'message': 'Nachricht',
  'midnight': 'Mitternacht',
  'midnight obsidian': 'Mitternachts-Obsidian',
  'milestone achieved': 'Meilenstein erreicht',
  'milestone badges': 'Meilenstein-Abzeichen',
  'milestone peak': 'Meilenstein-Höhepunkt',
  'milestone theme': 'Meilenstein-Design',
  'milestone unlocked!': 'Meilenstein freigeschaltet!',
  'milestones': 'Meilensteine',
  'mineta to all might prime.': 'Mineta bis All Might in Bestform.',
  'minimal moment options': 'Minimale Moment-Optionen',
  'mit': 'MIT',
  'moisture farmer to the chosen one.':
      'Feuchtigkeitsfarmer bis zum Auserwählten.',
  'moment options': 'Moment-Optionen',
  'moment saved': 'Moment gespeichert',
  'moments': 'Momente',
  'momentscategory': 'Momente',
  'mon': 'Mo',
  'monastic journey. silence, stillness, and vows.':
      'Mönchische Reise. Stille, Ruhe und Gelübde.',
  'monday': 'Montag',
  'monk': 'Mönch',
  'monthly reminder': 'Monatliche Erinnerung',
  'monthly reminder message': 'Monatliche Erinnerungsnachricht',
  'more': 'Mehr',
  'morning': 'Morgen',
  'motion sensor unavailable': 'Bewegungssensor nicht verfügbar',
  'muggle to merlin.': 'Muggel bis Merlin.',
  'murata to yoriichi tsugikuni.': 'Murata bis Yoriichi Tsugikuni.',
  'my hero academia': 'My Hero Academia',
  'naruto': 'Naruto',
  'navy': 'Marine',
  'network & data transparency': 'Netzwerk- & Datentransparenz',
  'network monitor': 'Netzwerk-Monitor',
  'network warning': 'Netzwerkwarnung',
  'neuroscience & growth': 'Neurowissenschaft & Wachstum',
  'next': 'Weiter',
  'night': 'Nacht',
  'no internet connection. showing cached preview.':
      'Keine Internetverbindung. Gecachte Vorschau wird angezeigt.',
  'no local backups found': 'Keine lokalen Sicherungen gefunden',
  'no matching notes': 'Keine passenden Notizen',
  'no message set (will show default reminder)':
      'Keine Nachricht festgelegt (zeigt Standard-Erinnerung)',
  'no moments': 'Keine Momente',
  'no moments logged yet': 'Noch keine Momente protokolliert',
  'no note': 'Keine Notiz',
  'no notes found': 'Keine Notizen gefunden',
  'no relapses recorded yet!': 'Noch keine Rückfälle erfasst!',
  'no repository activity': 'Keine Repository-Aktivität',
  'no results': 'Keine Ergebnisse',
  'no results found': 'Keine Ergebnisse gefunden',
  'no search results found': 'Keine Suchergebnisse gefunden',
  'no tracking': 'Kein Tracking',
  'none': 'Keine',
  'not set: using last log or relapse tag':
      'Nicht festgelegt: Letzter Eintrag oder Rückfall-Tag wird verwendet',
  'note copied to clipboard': 'Notiz in Zwischenablage kopiert',
  'note on click': 'Notiz beim Tippen',
  'notekar': 'NoteKar',
  'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.':
      'NoteKar-Builds durchlaufen automatisierte CodeQL- und lokale VirusTotal-Scans.',
  'notekar is offline': 'NoteKar ist offline',
  'notekar stores moments privately on this device. backups are files you control.':
      'NoteKar speichert Momente privat auf diesem Gerät. Sicherungen kontrollieren Sie selbst.',
  'notes': 'Notizen',
  'notification permission needed':
      'Benachrichtigungsberechtigung erforderlich',
  'numbered single moments': 'Nummerierte Einzelmomente',
  'official repository moved': 'Offizielles Repository umgezogen',
  'offline analysis of your logged relapse moments. no data leaves your device.':
      'Offline-Analyse Ihrer protokollierten Momente. Keine Daten verlassen Ihr Gerät.',
  'offline privacy log': 'Offline-Datenschutzprotokoll',
  'offline-first': 'Offline-First',
  'ok': 'OK',
  'okay': 'OK',
  'one piece': 'One Piece',
  'only moments tagged #relapse reset the streak. turn off to reset on any new log.':
      'Nur Momente mit dem Tag #relapse setzen die Serie zurück. Deaktivieren, um bei jedem neuen Eintrag zurückzusetzen.',
  'open link': 'Link öffnen',
  'open source': 'Open Source',
  'package verified & ready': 'Paket verifiziert & bereit',
  'passcodes do not match': 'Codes stimmen nicht überein',
  'peak risk window': 'Höchstes Risikofenster',
  'personalization': 'Personalisierung',
  'personalize and configure notekar to fit your specific workflow.':
      'Passen Sie NoteKar individuell an Ihren Workflow an.',
  'personalized app icons': 'Personalisierte App-Symbole',
  'phoenix': 'Phönix',
  'planned': 'Geplant',
  'please wait while android refreshes notekar.':
      'Bitte warten, während Android NoteKar aktualisiert.',
  'pokemon': 'Pokémon',
  'priest willibald to thors the troll of jom.':
      'Priester Willibald bis Thors der Troll von Jom.',
  'privacy & offline model': 'Datenschutz & Offline-Modell',
  'privacy & security': 'Datenschutz & Sicherheit',
  'privacy policy': 'Datenschutzrichtlinie',
  'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.':
      'Datenschutzorientiertes Serientracking und Tagebuch. Alle Daten bleiben auf Ihrem Gerät.',
  'privacysecuritycategory': 'Datenschutz & Sicherheit',
  'pure titan to the founder ymir fritz.':
      'Reiner Titan bis zur Ur-Gründerin Ymir Fritz.',
  'push alerts & notices': 'Push-Benachrichtigungen & Hinweise',
  'quick local backup created': 'Lokale Sicherung erstellt',
  'ratio': 'Verhältnis',
  'real-time metrics': 'Echtzeit-Metriken',
  'real-time traffic audit': 'Echtzeit-Datenverkehr-Audit',
  'rebirth through fire. the old is ash; you are the flame.':
      'Wiedergeburt durch Feuer. Das Alte ist Asche; du bist die Flamme.',
  'recent': 'Kürzlich',
  'recent messages': 'Letzte Nachrichten',
  'recently deleted': 'KÜRZLICH GELÖSCHT',
  'recommended for standard users.': 'Empfohlen für Standardbenutzer.',
  'refresh activity': 'Aktivität aktualisieren',
  'remind if inactive for': 'Erinnern bei Inaktivität seit',
  'reminder message': 'Erinnerungsnachricht',
  'reminders': 'Erinnerungen',
  'reminders & notifications': 'Erinnerungen & Benachrichtigungen',
  'report a bug': 'Fehler melden',
  'repository link copied to clipboard':
      'Repository-Link in Zwischenablage kopiert',
  'request a feature': 'Funktion vorschlagen',
  'required to show the logging alerts.':
      'Erforderlich für Protokollierungs-Benachrichtigungen.',
  'reset': 'Zurücksetzen',
  'reset all data': 'Alle Daten zurücksetzen',
  'reset daily': 'Täglich zurücksetzen',
  'reset data': 'Daten zurücksetzen',
  'reset on relapse tag only': 'Nur bei Rückfall-Tag zurücksetzen',
  'reset pin lock': 'PIN-Sperre zurücksetzen',
  'reset settings': 'Einstellungen zurücksetzen',
  'reset settings only': 'Nur Einstellungen zurücksetzen',
  'resetcategory': 'Zurücksetzen',
  'restarts count at 00 every midnight while keeping past history intact.':
      'Startet die Zählung jeden Tag um Mitternacht bei 00 neu, während vergangene Einträge erhalten bleiben.',
  'restore': 'Wiederherstellen',
  'restore all': 'Alle wiederherstellen',
  'restore all moments?': 'Alle Momente wiederherstellen?',
  'restore deleted moments': 'Gelöschte Momente wiederherstellen',
  'restore or permanently remove deleted moments':
      'Gelöschte Momente wiederherstellen oder dauerhaft entfernen',
  'retry download': 'Download wiederholen',
  'review and export': 'Überprüfen und exportieren',
  'review backup': 'Sicherung überprüfen',
  'review history': 'Verlauf überprüfen',
  'rpg / minecraft': 'RPG / Minecraft',
  'russian': 'Russisch',
  's mate victim to magnus carlsen.': 'Vom Anfänger zum Großmeister.',
  's new': 'Neuigkeiten',
  's new in notekar': 'Neuigkeiten in NoteKar',
  'sad': 'Traurig',
  'samurai': 'Samurai',
  'sapphire': 'Saphir',
  'sat': 'Sa',
  'saturday': 'Samstag',
  'save': 'Speichern',
  'save a moment': 'Moment speichern',
  'science': 'Wissenschaft',
  'seafaring odyssey. chart new waters and never look back.':
      'Seefahrt-Odyssee. Erkunden Sie neue Gewässer und blicken Sie nicht zurück.',
  'search notes': 'Notizen durchsuchen',
  'search settings': 'Einstellungen suchen',
  'search settings...': 'Einstellungen durchsuchen...',
  'secure passcode protection': 'Sicherer Passcode-Schutz',
  'security & cryptographic upgrade': 'Sicherheits- & Kryptographie-Upgrade',
  'security & integrity': 'Sicherheit & Integrität',
  'select a theme that best suits your environment.':
      'Wählen Sie ein Design, das am besten zu Ihrer Umgebung passt.',
  'select date': 'Datum wählen',
  'select date and time': 'Datum und Uhrzeit auswählen',
  'select for duration': 'Für Dauer auswählen',
  'select time': 'Uhrzeit auswählen',
  'select your preferred interface language. you can change this anytime in settings.':
      'Wählen Sie Ihre bevorzugte Sprache. Sie können dies jederzeit in den Einstellungen ändern.',
  'select your preferred language for the application.':
      'Wählen Sie Ihre bevorzugte Sprache für die Anwendung.',
  'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.':
      'Die fortlaufende Einzelnummerierung (00–99) erfordert Standard-Zeilenabstand zur Anzeige der 2-stelligen Abzeichen. Deaktivieren Sie den kompakten Verlauf, um Ziffern zu aktivieren.',
  'sessions are recorded as in and out pairs.':
      'Sitzungen werden als IN- und OUT-Paare aufgezeichnet.',
  'set': 'Festgelegt',
  'set passcode': 'Code festlegen',
  'set sobriety start date': 'Nüchternheitsstartdatum festlegen',
  'set unrestricted': 'Uneingeschränkt festlegen',
  'settings': 'Einstellungen',
  'settings restored': 'Einstellungen wiederhergestellt',
  'sha-256 hashes': 'SHA-256-Hashes',
  'share': 'Teilen',
  'share card': 'Karte teilen',
  'share milestone peak': 'Meilenstein-Höhepunkt teilen',
  'shinpachi to utsuro.': 'Shinpachi bis Utsuro.',
  'shirley to emperor lelouch vi britannia.':
      'Shirley bis Kaiser Lelouch vi Britannia.',
  'show more': 'Mehr anzeigen',
  'show seconds': 'Sekunden anzeigen',
  'shows 00–99 counters instead of static icons in history.':
      'Zeigt 00–99 Zähler anstelle von statischen Symbolen im Verlauf an.',
  'shows sequential numbers (00, 01...) on the tap pulse animation.':
      'Zeigt fortlaufende Nummern (00, 01...) auf der Tap-Puls-Animation an.',
  'signature': 'Signatur',
  'single': 'Einzeln',
  'single mode': 'Einzel-Modus',
  'single moment numbering': 'Einzelmoment-Nummerierung',
  'skip': 'Überspringen',
  'smaller, optimized apks': 'Kleinere, optimierte APKs',
  'smart bandwidth saver': 'Smarter Datensparmodus',
  'sobriety companion': 'Nüchternheitsbegleiter',
  'sobriety tracker': 'Abstinenz-Tracker',
  'sobriety tracker & milestone cards': 'Abstinenz-Tracker & Meilensteinkarten',
  'sobriety trigger analysis': 'Nüchternheits-Auslöser-Analyse',
  'social media': 'Soziale Medien',
  'social_media': 'Soziale Medien',
  'software credits and open source legal notices':
      'Software-Credits & Open-Source-Hinweise',
  'software licenses': 'Softwarelizenzen',
  'software update': 'Software-Update',
  'software update, app notices, changelog':
      'Software-Update, App-Hinweise, Changelog',
  'solo leveling': 'Solo Leveling',
  'space': 'Weltraum',
  'spanish': 'Spanisch',
  'stable': 'Stabil',
  'stable build': 'Stabile Version',
  'star wars': 'Star Wars',
  'start logging': 'Protokollieren starten',
  'startup mode': 'Start-Modus',
  'status': 'Status',
  'storage error: moment not saved': 'Speicherfehler: Moment nicht gespeichert',
  'streak mode': 'Serien-Modus',
  'streak reset logic': 'Serien-Rücksetzlogik',
  'streak shield deployed! clean streak protected.':
      'Serienschild aktiviert! Serie geschützt.',
  'stress': 'Stress',
  'stressed': 'Gestresst',
  'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.':
      'Reichen Sie Fehlerberichte und Feature-Wünsche direkt im neuen Issue-Tracker ein.',
  'suggest a new idea or improvement.':
      'Schlagen Sie eine neue Idee oder Verbesserung vor.',
  'sun': 'So',
  'sunday': 'Sonntag',
  'sunset': 'Sonnenuntergang',
  'support & community': 'Support & Community',
  'survival of the fittest. tardigrade to mythical dragon.':
      'Überleben des Stärkeren. Vom Bärtierchen zum mythischen Drachen.',
  'switching to beta build...': 'Wechsel zur Beta-Version...',
  'switching to stable build...': 'Wechsel zur stabilen Version...',
  'system default': 'Systemstandard',
  'system lock': 'Systemsperre',
  'system lock enabled': 'Systemsperre aktiviert',
  'table': 'Tabelle',
  'tap any icon below to switch style':
      'Tippen Sie auf ein Symbol, um den Stil zu ändern',
  'tap delay': 'Tipp-Verzögerung',
  'tap to record a moment. hold to add a note.':
      'Tippen, um einen Moment aufzuzeichnen. Halten, um Notiz hinzuzufügen.',
  'tap to save': 'Tippen zum Speichern',
  'tech career': 'Technik-Karriere',
  'technical stats about your device and the adaptive engine.':
      'Technische Daten über Ihr Gerät und die Adaptive Engine.',
  'teddy bear kon to yhwach the almighty.':
      'Plüschbär Kon bis Yhwach der Allmächtige.',
  'terms of use': 'Nutzungsbedingungen',
  'the current features on this page are under beta stage.':
      'Die Funktionen auf dieser Seite befinden sich im Beta-Stadium.',
  'theme': 'Design',
  'theme description': 'Themenbeschreibung',
  'theme mode': 'Design-Modus',
  'theme style': 'Design-Stil',
  'these languages are planned for future releases. help translate notekar on github.':
      'Diese Sprachen sind für zukünftige Versionen geplant. Helfen Sie mit bei der Übersetzung auf GitHub.',
  'these settings define how moments are recorded and prepared for export.':
      'Diese Einstellungen bestimmen, wie Momente erfasst und exportiert werden.',
  'these settings refine the interface aesthetic and do not modify your saved data.':
      'Diese Einstellungen verfeinern die Benutzeroberfläche und ändern keine gespeicherten Daten.',
  'these tools are intended for system maintenance and troubleshooting.':
      'Diese Werkzeuge dienen der Systemwartung und Fehlerbehebung.',
  'this backup contains no moments': 'Diese Sicherung enthält keine Momente',
  'this feature is currently in active development. while fully functional and secure, you may notice minor adjustments to the layout or performance as we refine the experience. all calculations, data, and security policies remain entirely local to your device.':
      'Diese Funktion befindet sich in aktiver Entwicklung. Sie ist voll funktionsfähig und sicher. Alle Berechnungen und Daten bleiben lokal auf Ihrem Gerät.',
  'this language is currently under development. you can help translate notekar into your native language by contributing on github.':
      'Diese Sprache befindet sich derzeit in Entwicklung. Sie können helfen, NoteKar in Ihre Muttersprache zu übersetzen, indem Sie auf GitHub beitragen.',
  'this local backup file will be erased permanently.':
      'Diese lokale Sicherungsdatei wird dauerhaft gelöscht.',
  'this moment will be erased forever.':
      'Dieser Moment wird unwiderruflich gelöscht.',
  'this week': 'Diese Woche',
  'this will permanently delete all moments in the trash. this action cannot be undone.':
      'Dadurch werden alle Momente im Papierkorb endgültig gelöscht. Dieser Vorgang kann nicht rückgängig gemacht werden.',
  'this will permanently delete all moments. this action cannot be undone.':
      'Dadurch werden alle Momente unwiderruflich gelöscht.',
  'this will return all items currently in the trash to your history.':
      'Dadurch werden alle Elemente aus dem Papierkorb wiederhergestellt.',
  'thu': 'Do',
  'thursday': 'Donnerstag',
  'time': 'Uhrzeit',
  'time between moments': 'Zeit zwischen Momenten',
  'time to log a moment!': 'Zeit, einen Moment zu erfassen!',
  'tired': 'Müde',
  'to trigger reminders precisely when the app is closed, notekar requires the "alarms & reminders" permission.':
      'Um Erinnerungen präzise auszulösen, benötigt NoteKar die Berechtigung „Alarme & Erinnerungen“.',
  'today': 'Heute',
  'tonpa to adult gon.': 'Tonpa bis zum erwachsenen Gon.',
  'tools': 'Werkzeuge',
  'top mood': 'Häufigste Stimmung',
  'top trigger': 'Häufigster Auslöser',
  'total relapses': 'Rückfälle insgesamt',
  'total requests': 'Gesamtanfragen',
  'track starts and stops': 'Starts und Stopps erfassen',
  'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.':
      'Verwandeln Sie Ihren Verlauf mit 2-stelligen Zählern (00–99), täglichen Mitternachtsrücksetzungen und einem Kalender im iOS-Stil.',
  'trash bin': 'Papierkorb',
  'trash is empty': 'Papierkorb ist leer',
  'trigger analysis': 'Auslöser-Analyse',
  'trigger diary': 'Auslöser-Tagebuch',
  'triggers reminders on specific days of the week.':
      'Löst Erinnerungen an bestimmten Wochentagen aus.',
  'try again in seconds': 'In wenigen Sekunden erneut versuchen',
  'try another keyword': 'Anderes Suchwort versuchen',
  'tue': 'Di',
  'tuesday': 'Dienstag',
  'turn off & enable': 'Deaktivieren & Aktivieren',
  'turn off reduced motion first': 'Zuerst Bewegungsreduktion deaktivieren',
  'turn off single numbers?': 'Einzelne Ziffern deaktivieren?',
  'tutorials': 'Tutorials',
  'two-way': 'Zwei-Wege',
  'two-way mode': 'Zwei-Wege-Modus',
  'type to search your notes...': 'Tippen, um Notizen zu durchsuchen...',
  'undetected': 'Nicht erkannt (Sauber)',
  'undo': 'Rückgängig',
  'upcoming': 'Demnächst',
  'upcoming languages': 'Kommende Sprachen',
  'update available': 'Update verfügbar',
  'update check failed': 'Update-Prüfung fehlgeschlagen',
  'update track': 'Update-Kanal',
  'updates & notices': 'Updates & Hinweise',
  'urge surfing & grounding': 'Urge Surfing & Erdung',
  'use fingerprint, face, or system pin.':
      'Verwenden Sie Fingerabdruck, Gesicht oder System-PIN.',
  'use numbers in single': 'Nummern in Einzelmomenten',
  'verified clean of malicious activity':
      'Nachweislich frei von schädlicher Software',
  'verified safe': 'Als sicher verifiziert',
  'verifying integrity checksum...': 'Integritätsprüfsumme wird überprüft...',
  'version': 'Version',
  'view': 'Anzeigen',
  'view all milestones': 'Alle Meilensteine anzeigen',
  'view full licenses': 'Vollständige Lizenzen anzeigen',
  'view note': 'Notiz anzeigen',
  'view your relapse pattern insights, top moods, and peak vulnerability windows.':
      'Sehen Sie Einblicke in Rückfallmuster, Top-Stimmungen und Phasen höchster Anfälligkeit.',
  'vinland saga': 'Vinland Saga',
  'virustotal safety scan': 'VirusTotal-Sicherheitsüberprüfung',
  'virustotal scan': 'VirusTotal-Scan',
  'vt report': 'VirusTotal-Bericht',
  'warrior': 'Krieger',
  'we have officially migrated our codebase to a new home. all future releases, updates, and issues will be managed here:':
      'Wir haben unsere Codebasis offiziell verlegt. Alle zukünftigen Releases werden hier verwaltet:',
  'wed': 'Mi',
  'wednesday': 'Mittwoch',
  'weekly reminder': 'Wöchentliche Erinnerung',
  'weekly reminder message': 'Wöchentliche Erinnerungsnachricht',
  'welcome': 'Willkommen',
  'welcome to notekar': 'Willkommen bei NoteKar',
  'were you already clean before installing? set your actual start date here. this overrides automatic detection from your logs.':
      'Waren Sie vor der Installation bereits abstinent? Legen Sie hier Ihr tatsächliches Startdatum fest.',
  'whatsnewtitle': 'Neuigkeiten',
  'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.':
      'Beim Protokollieren mit aktiviertem Nüchternheitsmodus können Sie Stimmung und Auslöser markieren.',
  'wipe': 'Löschen',
  'wooden shovel to creative mode god.':
      'Holzschaufel bis zum Gott des Kreativmodus.',
  'yamcha to the omni-king zeno.': 'Yamchu bis zum Allkönig Zeno.',
  'yoki to the ultimate truth.': 'Yoki bis zur ultimativen Wahrheit.',
  'you are up to date': 'Sie sind auf dem neuesten Stand',
  'your clean streak is active and running.': 'Ihre Serie ist aktiv und läuft.',
  'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.':
      'Ihre Daten sind zu 100 % privat und bleiben offline auf diesem Gerät.',
  'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.':
      'Ihr Startbildschirm zeigt eine Live-Serienkarte mit Meilensteinabzeichen.',
  'your privacy matters': 'Ihre Privatsphäre ist wichtig',
  'zero telemetry & offline integrity': 'Keine Telemetrie & Offline-Integrität',
};

const Map<String, String> _jaTranslations = {
  '* have suggestions or found a bug?': '* ご提案や不具合の報告はこちら：',
  '* have suggestions or found a bug? ': '* ご意見やバグの報告がありますか？ ',
  '0 / 68 clean': '0 / 68 安全',
  '100% offline': '100% オフライン',
  '100% offline database': '100% オフラインデータベース',
  '100% offline integrity': '100% オフライン整合性',
  '100% offline-first. zero trackers. zero data collection':
      '100% 完全オフライン設計。トラッカーゼロ。データ収集ゼロ',
  '16-week habit activity grid': '16週間の習慣アクティビティグリッド',
  '5-4-3-2-1 grounding': '5-4-3-2-1 グラウンディング法',
  '8 luxury app icon editions': '8つの高級アプリアイコン',
  'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.':
      '回復の歩みを支援するために構築された、完全オフラインの日数追跡・記録日記。',
  'a quiet, offline-first way to mark moments the second they happen.':
      '起きたその瞬間に素早く記録できる、静かな完全オフラインアプリ。',
  'about': '情報',
  'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.':
      'もちろんです。NoteKarはオープンソースかつ完全オフライン動作です。60以上のセキュリティエンジンで安全性が確認されています。',
  'accent color': 'アクセントカラー',
  'accentcolorcategory': 'アクセントカラー',
  'accept': '同意する',
  'access split-per-abi optimized binaries and google play appbundles directly from the release page.':
      '最適化されたバイナリをリリース画面から直接入手できます。',
  'accessibility': 'アクセシビリティ',
  'accessibilitycategory': 'アクセシビリティ',
  'active': '有効',
  'active issue tracking': 'アクティブな課題管理',
  'active launcher icon': '使用中のアプリアイコン',
  'active protection': 'アクティブ保護',
  'activity': 'アクティビティ',
  'adaptive engine': 'アダプティブエンジン',
  'adaptive engine and performance status': 'アダプティブエンジンとパフォーマンス状態',
  'adaptive engine overview': 'アダプティブエンジンの概要',
  'add a note': 'メモを追加',
  'add a note to save': '保存するメモを入力してください',
  'adds a clean streak card to your home screen and adapts home screen widgets.':
      'ホーム画面にクリーンな日数カードを追加し、ウィジェットを最適化します。',
  'adds a subtle glass-like container behind the home toolbar.':
      'ホームツールバーの背面に控えめなガラス風の背景を追加します。',
  'afternoon': '昼・午後',
  'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.':
      'リマインダーを確実に届けるため、バッテリー最適化をオフに設定してください。',
  'alarms permission required': 'アラーム権限が必要です',
  'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.':
      '神経科学と行動心理学に基づく、1日から10年までの全21のマイルストーン。',
  'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.':
      'すべてのビルドでCodeQLおよびVirusTotalによる自動安全検証を実施しています。',
  'all moments in the database will be permanently removed. this cannot be undone.':
      'データベース内のすべてのモーメントが完全に消去されます。この操作は元に戻せません。',
  'all settings will be restored to their initial factory defaults. your saved moments and notes will remain untouched.':
      'すべての設定が初期状態にリセットされます。保存されたモーメントとメモは保持されます。',
  'all time': '全期間',
  'allow app installation': 'アプリのインストールを許可',
  'allow auto-start settings': '自動起動設定を許可',
  'allow notifications': '通知を許可',
  'allows notekar to send logging reminders and update notifications.':
      'NoteKarが記録リマインダーや更新通知を送信することを許可します。',
  'amethyst': 'アメジスト',
  'amethyst nebula': 'アメジスト・ネビュラ',
  'amoled': 'AMOLED',
  'ancient': 'エンシェント',
  'android backup': 'Android バックアップ',
  'angry': '怒り',
  'animal kingdom': 'アニマルキングダム',
  'anxious': '不安・焦り',
  'app icon': 'アプリアイコン',
  'app icon could not be changed': 'アプリアイコンを変更できませんでした',
  'app icons': 'アプリアイコン',
  'app language': 'アプリの言語',
  'app lock': 'アプリロック',
  'app lock & biometrics': 'アプリロックと生体認証',
  'app lock & security': 'アプリロックとセキュリティ',
  'app lock appears after the notification panel': '通知パネルの後にアプリロックを表示',
  'app lock needs a device screen lock': 'アプリロックには画面ロックの設定が必要です',
  'app lock timing': 'アプリロックのタイミング',
  'app lock will not turn on': 'アプリロックが有効になりません',
  'app notices': 'アプリからのお知らせ',
  'app notices are not appearing': 'アプリの通知が表示されません',
  'app preferences and theme': 'アプリ環境設定とテーマ',
  'app switcher obfuscation': 'アプリスイッチャーでの画面ぼかし',
  'app theme': 'アプリのテーマ',
  'app usage': 'アプリの利用規約',
  'app version': 'アプリバージョン',
  'appearance': '外観',
  'appiconscategory': 'アプリアイコン',
  'application build identifier': 'ビルド識別子',
  'apply a custom accent color across all fluid interface elements.':
      'UI全体のアクセントカラーを好みの色にカスタマイズします。',
  'applying app icon': 'アプリアイコンを適用中',
  'army elite. every clean day is a battle fought and won.':
      '精鋭部隊。日々の継続が勝利への前進。',
  'as a small, offline-first timestamp logger for real work: quick taps, focused notes, and exports developers can inspect.':
      '実務のための軽量・完全オフライン対応のタイムスタンプ記録ツール。高速タップ、集中メモ、開発者が検証可能なエクスポートを提供。',
  'at': '',
  'attach context without slowing the app down.': 'アプリの動作を重くすることなくコンテキストを追加。',
  'attack on titan': '進撃の巨人',
  'aurora': 'オーロラ',
  'aurora borealis': 'オーロラ・ボレアリス',
  'auto-start & background activity': '自動起動とバックグラウンド動作',
  'automated security scans': '自動セキュリティスキャン',
  'automatic': '自動',
  'available languages': '利用可能な言語',
  'back': '戻る',
  'back up data': 'データをバックアップ',
  'backup & export': 'バックアップとエクスポート',
  'backup & restore': 'バックアップと復元',
  'backup filename preview': 'バックアップファイル名のプレビュー',
  'backup has no new moments': 'バックアップに新しいモーメントはありません',
  'backup import failed': 'バックアップのインポートに失敗しました',
  'backup import found no new moments': 'バックアップに取り込む新しいモーメントは見つかりませんでした',
  'backup reminder: export a fresh backup soon': 'リマインダー: 新しいバックアップを作成してください',
  'backup status': 'バックアップ状態',
  'backupexportcategory': 'バックアップとエクスポート',
  'battery and performance status': 'バッテリーとパフォーマンス状態',
  'battery optimization active': 'バッテリー最適化が有効です',
  'ben 10': 'ベン10',
  'beta': 'ベータ',
  'beta feature': 'ベータ版機能',
  'beta track': 'ベータチャンネル',
  'biometric lock': '生体認証ロック',
  'biometrics not available': '生体認証が利用できません',
  'biometrics or system credentials': '生体認証またはシステムPIN',
  'bleach': 'BLEACH',
  'blur & translucency': 'ブラーと半透明効果',
  'bored': '退屈',
  'boredom': '退屈',
  'box breathing': 'ボックス呼吸法',
  'build cache cleared': 'ビルドキャッシュを消去しました',
  'build cache size': 'ビルドキャッシュ容量',
  'build date': 'ビルド日時',
  'build number': 'ビルド番号',
  'built by': '開発:',
  'bushido code. master of the self.': '武士道。自己の修練。',
  'buy me a coffee': '開発者をサポート (Buy Me a Coffee)',
  'can i restore deleted moments?': '削除したモーメントは復元できますか？',
  'cancel': 'キャンセル',
  'capture': '記録モード',
  'capture cooldown': 'キャプチャクールダウン',
  'capture delay & cooldown': 'キャプチャ遅延とクールダウン',
  'capturecategory': '記録モード',
  'celtic highland clan. earn your place, carry the banner.':
      'ケルトのハイランド部族。己の居場所を勝ち取り、旗を掲げよ。',
  'change your secure in-app passcode.': 'アプリ内の安全なパスコードを変更します。',
  'changelog': '変更履歴',
  'changelogtitle': '変更履歴',
  'check again': '再確認',
  'check for updates': 'アップデートを確認',
  'checking for updates...': 'アップデートを確認中...',
  'chess mastery': 'チェスマスター',
  'choose how notekar starts when you open it': 'アプリを開いたときの初期モードを選択',
  'choose language': '言語を選択',
  'choose milestone theme': 'マイルストーンテーマを選択',
  'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.':
      'マイルストーン名の物語スタイルを選択してください。',
  'choose your preferred interface language': '希望の表示言語を選択してください',
  'civilian to the one above all.': '一般市民からワン・アバブ・オールへ。',
  'clan': 'クラン',
  'clear': 'クリア',
  'clear all moments': 'すべてのモーメントを消去',
  'clear cache': 'キャッシュをクリア',
  'clear search': '検索をクリア',
  'clear trash': 'ゴミ箱を空にする',
  'clinical neuroscience terms. cold, precise, honest.': '神経科学の臨床用語。冷静、正確、実直。',
  'close': '閉じる',
  'code geass': 'コードギアス',
  'color accent': 'アクセントカラー',
  'commits': 'コミット',
  'compact history': 'コンパクト履歴',
  'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.':
      'シングルモーメント番号が有効な間はコンパクト履歴を有効にできません。コンパクト行を使用するにはシングル番号を無効にしてください。',
  'compact history mode': 'コンパクト履歴モード',
  'configure a dedicated 4-digit passcode.': '専用の4桁パスコードを設定します。',
  'configure settings': '設定を開く',
  'confirm': '確認',
  'confirm delete': '削除前に確認',
  'confirm passcode': 'パスコードを再入力',
  'continue': '続ける',
  'continuous': '連続',
  'contribute on github': 'GitHubで貢献する',
  'cooldown period': 'クールダウン期間',
  'copy': 'コピー',
  'copy moment': 'モーメントをコピー',
  'correlation intelligence': '相関インテリジェンス',
  'cosmic exploration. every clean day is light-years gained.':
      '宇宙探査。日々の積み重ねが光年単位の進歩。',
  'could not open backup file': 'バックアップファイルを開けませんでした',
  'count on save': '保存時カウント表示',
  'create quick local backup': 'クイックローカルバックアップを作成',
  'crimson': 'クリムゾン',
  'current message': '現在のメッセージ',
  'cursed spirit to satoru gojo.': '呪霊から五条悟へ。',
  'custom start date': 'カスタム開始日',
  'daily logging reminder': '毎日の記録リマインダー',
  'daily neuroscience insight': '今日の神経科学インサイト',
  'daily reminder': 'デイリーリマインダー',
  'daily reminder message': '毎日のリマインダー文',
  'daily reminders': '毎日のリマインダー',
  'dark mode': 'ダークモード',
  'data': 'データ',
  'data & backup': 'データとバックアップ',
  'data consumed': '通信量',
  'data health': 'データの健全性',
  'database export': 'データベースのエクスポート',
  'database integrity': 'データベースの整合性',
  'day of month': '日付（毎月）',
  'days of week': '曜日',
  'death note': 'デスノート',
  'delete': '削除',
  'delete all moments?': 'すべてのモーメントを削除しますか？',
  'delete backup?': 'バックアップを削除しますか？',
  'delete cache': 'キャッシュを削除',
  'delete moment': 'モーメントを削除',
  'delete permanently': '完全に削除',
  'delete permanently?': '完全に削除しますか？',
  'deleted in moment': 'INモーメントを削除しました',
  'deleted out moment': 'OUTモーメントを削除しました',
  'deleted single moment': 'SINGLEモーメントを削除しました',
  'deleting cache...': 'キャッシュを消去中...',
  'demon slayer': '鬼滅の刃',
  'dev': '開発版',
  'developer diagnostics': '開発者診断',
  'developer key': '開発者キー',
  'developer options': '開発者向けオプション',
  'device health': 'デバイス健全性',
  'diagnostics': '診断情報',
  'diagnostics and internal engine settings for developers.':
      '開発者向けの診断情報と内部エンジン設定。',
  'diagnosticscategory': '診断情報',
  'disable battery optimization': 'バッテリー最適化を無効化',
  'disable compact history?': 'コンパクト履歴を無効にしますか？',
  'disable reduce motion first': '最初に「視覚効果を減らす」を無効にしてください',
  'disable use numbers in single?': 'シングル番号付けを無効にしますか？',
  'disabled': '無効',
  'dismiss': '閉じる',
  'display': '画面表示',
  'display & typography': '表示とタイポグラフィ',
  'displaycategory': '画面表示',
  'docs': 'ドキュメント',
  'done': '完了',
  'download': 'ダウンロード',
  'download & install': 'ダウンロードしてインストール',
  'download failed': 'ダウンロードに失敗しました',
  'download from github': 'GitHubからダウンロード',
  'download size:': 'ダウンロードサイズ:',
  'downloading update...': 'アップデートをダウンロード中...',
  'dragon ball': 'ドラゴンボール',
  'e-rank sung jinwoo to shadow monarch.': 'E級ハンター水篠旬から影の君主へ。',
  'east blue coby to the pirate king gol d. roger.':
      'イーストブルーのコビーから海賊王ゴール・D・ロジャーへ。',
  'edit': '編集',
  'edit message': 'メッセージを編集',
  'edit note': 'メモを編集',
  'email support': 'メールサポート',
  'emerald': 'エメラルド',
  'emerald forest': 'エメラルド・フォレスト',
  'empty': '未設定',
  'empty trash': 'ゴミ箱を空にする',
  'empty trash?': 'ゴミ箱を空にしますか？',
  'enable count on save': '保存時のカウント表示を有効化',
  'enable show seconds first': '先に秒表示を有効にしてください',
  'enable sobriety mode': 'ソブリエティモードを有効化',
  'encrypted backup': '暗号化バックアップ',
  'endpoint url': 'エンドポイントURL',
  'english': '英語',
  'enter passcode': 'パスコードを入力',
  'enter reminder message...': '通知メッセージを入力...',
  'essential features': '基本機能',
  'evening': '夕方',
  'every 14 days': '14日ごと',
  'every 30 days': '30日ごと',
  'every 7 days': '7日ごと',
  'every tap records a standalone moment.': 'タップするごとに独立したモーメントを記録します。',
  'export backup': 'バックアップをエクスポート',
  'export csv': 'CSVエクスポート',
  'export failed. try again.': 'エクスポートに失敗しました。再試行してください。',
  'export json': 'JSONエクスポート',
  'export last 7 days': '過去7日分をエクスポート',
  'export milestone card': 'マイルストーンカードを書き出し',
  'export saved to downloads': 'ダウンロードフォルダに保存しました',
  'export, import, and manage your data backups.': 'データのバックアップ、復元、管理を行います。',
  'extended duration': '詳細な経過時間',
  'external navigation': '外部リンクを開く',
  'factory reset': '出荷時リセット',
  'failed to create local backup': 'バックアップの作成に失敗しました',
  'failed to read local backup file': 'ローカルバックアップの読み込みに失敗しました',
  'faq': 'よくある質問',
  'fatigue': '倦怠感',
  'feedback': 'フィードバック',
  'feedback & bug report': 'フィードバックと不具合報告',
  'fri': '金',
  'friday': '金曜日',
  'friends': '交友関係',
  'from': '開始:',
  'full': '完全',
  'full online policy': 'プライバシーポリシー（オンライン）',
  'full online terms': '利用規約（オンライン）',
  'full title & purpose': '正式名称と目的',
  'fullmetal alchemist': '鋼の錬金術師',
  'german': 'ドイツ語',
  'get started': '始める',
  'gintama': '銀魂',
  'github': 'GitHub',
  'give feedback': 'フィードバックを送信',
  'google drive backup': 'Google ドライブ バックアップ',
  'got it': '了解',
  'grant permission': '権限を許可',
  'greek and roman glory. rise from mortal to olympian.':
      'ギリシャとローマの栄光。定命の者からオリュンポスの神へ。',
  'grey matter to alien x.': 'グレイマターからエイリアンXへ。',
  'guides': '使い方ガイド',
  'happy': '喜び',
  'hardware security': 'ハードウェアセキュリティ',
  'hardware-backed encryption': 'ハードウェア保護暗号化',
  'harry potter': 'ハリー・ポッター',
  'have suggestions or found a bug?': 'ご意見やバグの報告がありますか？',
  'help': 'ヘルプ',
  'help & user guides': 'ヘルプとユーザーガイド',
  'hide app content in recents': '履歴画面でアプリ内容を隠す',
  'hindi': 'ヒンディー語',
  'history': '履歴',
  'hold for notes': '長押しでメモを入力',
  'hour': '時間',
  'hours': '時間',
  'html editor to turing award winner.': 'HTMLエディタからチューリング賞受賞者へ。',
  'hunter x hunter': 'HUNTER×HUNTER',
  'imperial': 'インペリアル',
  'imperial gold': 'インペリアル・ゴールド',
  'import backup': 'バックアップを復元',
  'import cancelled': 'インポートがキャンセルされました',
  'important notice': '重要なお知らせ',
  'in-app ota updates': 'アプリ内OTAアップデート',
  'in-app pin': 'アプリ内PIN',
  'in-app pin set successfully.': 'アプリ内PINを設定しました。',
  'in-app update setup': 'アップデート設定',
  'inactive': '無効',
  'inactivity alerts': '非アクティブアラート',
  'inactivity reminder': '未記録リマインダー',
  'incorrect passcode': 'パスコードが違います',
  'install now': '今すぐインストール',
  'installation failed to start': 'インストールの開始に失敗しました',
  'integrity check failed: checksum mismatch': '整合性チェック失敗: チェックサムが一致しません',
  'intelligent risk radar': 'リスクレーダー',
  'invalid backup file': '無効なバックアップファイルです',
  'is notekar private?': 'NoteKarはプライベートですか？',
  'is notekar safe to use?': 'NoteKarは安全に使用できますか？',
  'item': '件',
  'items': '件',
  'japanese': '日本語',
  'jujutsu kaisen': '呪術廻戦',
  'july 2026': '2026年7月',
  'kingdom': '王国',
  'konohamaru to the sage of six paths.': '木ノ葉丸から六道仙人へ。',
  'language': '言語',
  'last scan': '最終スキャン',
  'late night': '深夜',
  'late_night': '深夜',
  'learn more': '詳細を見る',
  'legal & open source notices': '法的通知とオープンソースライセンス',
  'less': '少なく',
  'licenses': 'ライセンス',
  'limited connectivity': '限定的な通信',
  'link copied': 'リンクをコピーしました',
  'live activity tracking dashboard featuring real-time metric analysis, habit tracking grids, activity trends, and correlation intelligence calculated from your moments.':
      'リアルタイム分析、習慣グリッド、アクティビティ推移、相関インテリジェンスを備えたライブダッシュボード。',
  'live icon motion looks slow or delayed': 'ライブアイコンの動作が遅く感じられます',
  'live icon motion will not turn on': 'ライブアイコンのアニメーションが有効になりません',
  'load older moments': '過去のモーメントを読み込む',
  'loading database...': 'データベースを読み込み中...',
  'local backups': 'ローカルバックアップ',
  'local storage': 'ローカル保存',
  'location': '特定の場所',
  'log a moment instantly from the main screen.': 'メイン画面から瞬時にモーメントを記録。',
  'logging': '記録',
  'logging reminder': '記録リマインダー',
  'logging reminders': '記録リマインダー',
  'logs': 'ログ',
  'loneliness': '孤独感',
  'lonely': '孤独',
  'magikarp to the creator god arceus.': 'コイキングから創造神アルセウスへ。',
  'manage': '管理',
  'manage moment notes': 'モーメントのメモ管理',
  'manage security, passcode lock, and app privacy.':
      'セキュリティ、パスコードロック、プライバシー設定を管理。',
  'marvel universe': 'マーベル・ユニバース',
  'matsuda to the shinigami king.': '松田から死神大王へ。',
  'medieval royalty. rise from serf to sovereign.': '中世の王権。平民から君主への道。',
  'message': 'メッセージ',
  'midnight': 'ミッドナイト',
  'midnight obsidian': 'ミッドナイト・オブシディアン',
  'milestone achieved': 'マイルストーン達成',
  'milestone badges': 'マイルストーンバッジ',
  'milestone peak': 'マイルストーンハイライト',
  'milestone theme': 'マイルストーンのテーマ',
  'milestone unlocked!': 'マイルストーン達成！',
  'milestones': 'マイルストーン',
  'mineta to all might prime.': '峰田から全盛期のオールマイトへ。',
  'minimal moment options': 'シンプルなモーメント操作',
  'mit': 'MIT',
  'moisture farmer to the chosen one.': '水分農夫から選ばれし者へ。',
  'moment options': 'モーメント操作',
  'moment saved': 'モーメントを保存しました',
  'moments': 'モーメント',
  'momentscategory': 'モーメント',
  'mon': '月',
  'monastic journey. silence, stillness, and vows.': '修道者の旅路。静寂と誓い。',
  'monday': '月曜日',
  'monk': '僧侶',
  'monthly reminder': 'マンスリーリマインダー',
  'monthly reminder message': '毎月のリマインダー文',
  'more': '多く',
  'morning': '朝',
  'motion sensor unavailable': 'モーションセンサーが利用できません',
  'muggle to merlin.': 'マグルからマーリンへ。',
  'murata to yoriichi tsugikuni.': '村田から継国縁壱へ。',
  'my hero academia': '僕のヒーローアカデミア',
  'naruto': 'NARUTO',
  'navy': 'ネイビー',
  'network & data transparency': '通信とデータの透明性',
  'network monitor': 'ネットワークモニター',
  'network warning': 'ネットワーク警告',
  'neuroscience & growth': '神経科学と自己成長',
  'next': '次へ',
  'night': '夜',
  'no internet connection. showing cached preview.':
      'インターネット接続がありません。キャッシュされたプレビューを表示中。',
  'no local backups found': 'ローカルバックアップが見つかりません',
  'no matching notes': '一致するメモはありません',
  'no message set (will show default reminder)': 'メッセージ未設定（デフォルトのリマインダーを表示します）',
  'no moments': 'モーメントなし',
  'no moments logged yet': 'モーメントがまだ記録されていません',
  'no note': 'メモなし',
  'no notes found': 'メモが見つかりません',
  'no relapses recorded yet!': 'まだ再発の記録はありません！',
  'no repository activity': 'リポジトリのアクティビティはありません',
  'no results': '結果なし',
  'no results found': '結果が見つかりません',
  'no search results found': '検索結果が見つかりません',
  'no tracking': 'トラッキング一切なし',
  'none': 'なし',
  'not set: using last log or relapse tag': '未設定: 最後の記録または再発タグを使用',
  'note copied to clipboard': 'メモをクリップボードにコピーしました',
  'note on click': 'タップでメモを表示',
  'notekar': 'NoteKar',
  'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.':
      'NoteKarのビルドはCodeQLおよびVirusTotalで検査され、公式証明書で署名されています。',
  'notekar is offline': 'NoteKarはオフラインです',
  'notekar stores moments privately on this device. backups are files you control.':
      'NoteKarはお使いの端末内にのみ安全にデータを保存します。バックアップファイルはお客様自身で管理できます。',
  'notes': 'メモ',
  'notification permission needed': '通知の権限が必要です',
  'numbered single moments': '番号付きシングルモーメント',
  'official repository moved': '公式リポジトリ移転のお知らせ',
  'offline analysis of your logged relapse moments. no data leaves your device.':
      '記録されたモーメントのオフライン分析。データが端末外へ送信されることはありません。',
  'offline privacy log': 'オフラインプライバシーログ',
  'offline-first': '完全オフライン設計',
  'ok': 'OK',
  'okay': 'OK',
  'one piece': 'ワンピース',
  'only moments tagged #relapse reset the streak. turn off to reset on any new log.':
      '#relapse タグが付いた記録のみが日数をリセットします。新しい記録すべてでリセットする場合はオフにしてください。',
  'open link': 'リンクを開く',
  'open source': 'オープンソース',
  'package verified & ready': 'パッケージ検証完了・準備完了',
  'passcodes do not match': 'パスコードが一致しません',
  'peak risk window': '最も注意が必要な時間帯',
  'personalization': 'パーソナライズ',
  'personalize and configure notekar to fit your specific workflow.':
      'ワークフローに合わせてNoteKarを柔軟にカスタマイズおよび設定。',
  'personalized app icons': 'カスタマイズアプリアイコン',
  'phoenix': 'フェニックス',
  'planned': '予定',
  'please wait while android refreshes notekar.':
      'AndroidがNoteKarを更新するまでお待ちください。',
  'pokemon': 'ポケモン',
  'priest willibald to thors the troll of jom.': 'ヴィリバルドからヨームの戦鬼トールズへ。',
  'privacy & offline model': 'プライバシーとオフライン構造',
  'privacy & security': 'プライバシーとセキュリティ',
  'privacy policy': 'プライバシーポリシー',
  'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.':
      'プライバシー重視の日数追跡と記録日記。すべてのデータはお使いの端末内に保存されます。',
  'privacysecuritycategory': 'プライバシーとセキュリティ',
  'pure titan to the founder ymir fritz.': '無垢の巨人から始祖ユミルへ。',
  'push alerts & notices': 'プッシュ通知とお知らせ',
  'quick local backup created': 'ローカルバックアップを作成しました',
  'ratio': '検証スコア',
  'real-time metrics': 'リアルタイムメトリクス',
  'real-time traffic audit': 'リアルタイム通信監査',
  'rebirth through fire. the old is ash; you are the flame.':
      '炎による再生。過去は灰となり、汝こそが炎となる。',
  'recent': '最近',
  'recent messages': '最近のメッセージ',
  'recently deleted': '最近削除したアイテム',
  'recommended for standard users.': '一般のユーザーに推奨されます。',
  'refresh activity': 'アクティビティを更新',
  'remind if inactive for': '指定時間記録がない場合に通知:',
  'reminder message': 'リマインダー通知メッセージ',
  'reminders': 'リマインダー',
  'reminders & notifications': 'リマインダーと通知',
  'report a bug': '不具合を報告',
  'repository link copied to clipboard': 'リポジトリのリンクをクリップボードにコピーしました',
  'request a feature': '機能リクエスト',
  'required to show the logging alerts.': '記録リマインダーを表示するために必要です。',
  'reset': 'リセット',
  'reset all data': '全データを初期化',
  'reset daily': '毎日リセット',
  'reset data': 'データをリセット',
  'reset on relapse tag only': '再発タグ時のみリセット',
  'reset pin lock': 'PINロックをリセット',
  'reset settings': '設定をリセット',
  'reset settings only': '設定のみリセット',
  'resetcategory': 'リセット',
  'restarts count at 00 every midnight while keeping past history intact.':
      '過去の履歴を保持したまま、毎晩午前0時にカウントを00に再設定します。',
  'restore': '復元',
  'restore all': 'すべて復元',
  'restore all moments?': 'すべてのモーメントを復元しますか？',
  'restore deleted moments': '削除したモーメントの復元',
  'restore or permanently remove deleted moments': '削除されたモーメントを復元または完全消去',
  'retry download': '再ダウンロード',
  'review and export': '確認してエクスポート',
  'review backup': 'バックアップを確認',
  'review history': '履歴を確認',
  'rpg / minecraft': 'RPG / マイクラ',
  'russian': 'ロシア語',
  's mate victim to magnus carlsen.': '初心者の駒落ちからマグヌス・カールセンへ。',
  's new': '新機能',
  's new in notekar': 'NoteKarの新機能',
  'sad': '悲しみ',
  'samurai': '侍',
  'sapphire': 'サファイア',
  'sat': '土',
  'saturday': '土曜日',
  'save': '保存',
  'save a moment': 'モーメントを保存',
  'science': 'サイエンス',
  'seafaring odyssey. chart new waters and never look back.':
      '航海の叙事詩。未知の海原へ舵を取り前へ。',
  'search notes': 'メモを検索',
  'search settings': '設定を検索',
  'search settings...': '設定を検索...',
  'secure passcode protection': 'パスコード保護',
  'security & cryptographic upgrade': 'セキュリティと暗号化のアップグレード',
  'security & integrity': 'セキュリティと整合性',
  'select a theme that best suits your environment.': '環境に最適なテーマを選択してください。',
  'select date': '日付を選択',
  'select date and time': '日付と時刻を選択',
  'select for duration': '経過時間を計算するために選択',
  'select time': '時間を選択',
  'select your preferred interface language. you can change this anytime in settings.':
      '希望の表示言語を選択してください。設定からいつでも変更できます。',
  'select your preferred language for the application.':
      'アプリケーションの言語を選択してください。',
  'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.':
      '連続シングル番号（00〜99）は2桁バッジを表示するために標準の行間隔が必要です。シングルモードで番号を使用するにはコンパクト履歴を無効にしてください。',
  'sessions are recorded as in and out pairs.': 'セッションはINとOUTのペアとして記録されます。',
  'set': '設定済み',
  'set passcode': 'パスコードを設定',
  'set sobriety start date': '開始日時を設定',
  'set unrestricted': '無制限に設定',
  'settings': '設定',
  'settings restored': '設定を復元しました',
  'sha-256 hashes': 'SHA-256 ハッシュ',
  'share': '共有',
  'share card': 'カードを共有',
  'share milestone peak': 'マイルストーンを共有',
  'shinpachi to utsuro.': '新八から虚へ。',
  'shirley to emperor lelouch vi britannia.': 'シャーリーから皇帝ルルーシュ・ヴィ・ブリタニアへ。',
  'show more': 'さらに表示',
  'show seconds': '秒を表示',
  'shows 00–99 counters instead of static icons in history.':
      '履歴内で固定アイコンの代わりに00〜99のカウンターを表示します。',
  'shows sequential numbers (00, 01...) on the tap pulse animation.':
      'タップ時のアニメーションに連続番号（00, 01...）を表示します。',
  'signature': '電子署名',
  'single': 'シングル',
  'single mode': 'シングル記録モード',
  'single moment numbering': 'シングルモーメント番号付け',
  'skip': 'スキップ',
  'smaller, optimized apks': '軽量・最適化されたパッケージ',
  'smart bandwidth saver': '通信量節約モード',
  'sobriety companion': 'ソブリエティ・コンパニオン',
  'sobriety tracker': '継続トラッカー',
  'sobriety tracker & milestone cards': '継続トラッカーとマイルストーンカード',
  'sobriety trigger analysis': 'トリガー傾向分析',
  'social media': 'SNS',
  'social_media': 'ソーシャルメディア',
  'software credits and open source legal notices': 'クレジット表記およびオープンソースライセンス',
  'software licenses': 'ソフトウェアライセンス',
  'software update': 'ソフトウェアアップデート',
  'software update, app notices, changelog': 'ソフトウェア更新、お知らせ、更新履歴',
  'solo leveling': '俺だけレベルアップな件',
  'space': '宇宙',
  'spanish': 'スペイン語',
  'stable': '安定版',
  'stable build': '安定版ビルド',
  'star wars': 'スター・ウォーズ',
  'start logging': '記録を始める',
  'startup mode': '起動時のモード',
  'status': '状態',
  'storage error: moment not saved': 'ストレージエラー: モーメントが保存されませんでした',
  'streak mode': '日数記録モード',
  'streak reset logic': '日数リセット設定',
  'streak shield deployed! clean streak protected.': 'シールド展開！継続日数が保護されました。',
  'stress': 'ストレス',
  'stressed': 'ストレス',
  'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.':
      'バグ報告や機能要望を直接投稿できます。',
  'suggest a new idea or improvement.': '新しいアイデアや改善案を提案してください。',
  'sun': '日',
  'sunday': '日曜日',
  'sunset': 'サンセット',
  'support & community': 'サポートとコミュニティ',
  'survival of the fittest. tardigrade to mythical dragon.':
      '適者生存。クマムシから伝説のドラゴンへ。',
  'switching to beta build...': 'ベータ版に切り替え中...',
  'switching to stable build...': '安定版に切り替え中...',
  'system default': 'システム標準',
  'system lock': 'システムロック',
  'system lock enabled': 'システムロックを有効にしました',
  'table': 'テーブル',
  'tap any icon below to switch style': 'アイコンをタップしてスタイルを変更できます',
  'tap delay': '連打防止ディレイ',
  'tap to record a moment. hold to add a note.': 'タップして記録。長押しでメモを追加。',
  'tap to save': 'タップして記録',
  'tech career': 'テックキャリア',
  'technical stats about your device and the adaptive engine.':
      'デバイスとアダプティブエンジンの詳細な統計情報。',
  'teddy bear kon to yhwach the almighty.': 'コンから全知全能のユーハバッハへ。',
  'terms of use': '利用規約',
  'the current features on this page are under beta stage.':
      'このページの機能は現在ベータ版です。',
  'theme': 'テーマ',
  'theme description': 'テーマの説明',
  'theme mode': 'テーマモード',
  'theme style': 'テーマのスタイル',
  'these languages are planned for future releases. help translate notekar on github.':
      'これらの言語は今後のリリースで予定されています。GitHubでの翻訳にご協力ください。',
  'these settings define how moments are recorded and prepared for export.':
      'モーメントの記録方法およびエクスポート形式を設定します。',
  'these settings refine the interface aesthetic and do not modify your saved data.':
      'これらの設定は表示を調整するもので、保存されたデータには影響しません。',
  'these tools are intended for system maintenance and troubleshooting.':
      'システムのメンテナンスおよびトラブルシューティング用ツールです。',
  'this backup contains no moments': 'このバックアップにはモーメントが含まれていません',
  'this feature is currently in active development. while fully functional and secure, you may notice minor adjustments to the layout or performance as we refine the experience. all calculations, data, and security policies remain entirely local to your device.':
      'この機能は現在開発中です。完全に機能し安全ですが、今後レイアウト等の微調整が行われる場合があります。すべてのデータは端末内に留まります。',
  'this language is currently under development. you can help translate notekar into your native language by contributing on github.':
      'この言語は現在開発中です。GitHubでNoteKarをあなたの母国語に翻訳する協力ができます。',
  'this local backup file will be erased permanently.':
      'このローカルバックアップファイルは完全に削除されます。',
  'this moment will be erased forever.': 'このモーメントは完全に消去されます。',
  'this week': '今週',
  'this will permanently delete all moments in the trash. this action cannot be undone.':
      'ゴミ箱内のすべてのモーメントが完全に削除されます。この操作は取り消せません。',
  'this will permanently delete all moments. this action cannot be undone.':
      'すべてのモーメントが完全に消去されます。この操作は取り消せません。',
  'this will return all items currently in the trash to your history.':
      'ゴミ箱内のすべてのアイテムが履歴に戻ります。',
  'thu': '木',
  'thursday': '木曜日',
  'time': '時刻',
  'time between moments': 'モーメント間の経過時間',
  'time to log a moment!': 'モーメントを記録する時間です！',
  'tired': '疲労',
  'to trigger reminders precisely when the app is closed, notekar requires the "alarms & reminders" permission.':
      'アプリが閉じている時でも正確にリマインダーを通知するため、「アラームとリマインダー」権限が必要です。',
  'today': '今日',
  'tonpa to adult gon.': 'トンパからゴン（成長期）へ。',
  'tools': 'ツール',
  'top mood': '主な気分',
  'top trigger': '主なトリガー',
  'total relapses': '記録した再発回数',
  'total requests': '総リクエスト数',
  'track starts and stops': '開始と終了を追跡',
  'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.':
      '2桁の連続カウンター（00〜99）、毎日の自動リセット、iOSスタイルのカレンダーで履歴をすっきり整理できます。',
  'trash bin': 'ゴミ箱',
  'trash is empty': 'ゴミ箱は空です',
  'trigger analysis': 'トリガー分析',
  'trigger diary': 'トリガー日記',
  'triggers reminders on specific days of the week.': '特定の曜日にリマインダーを通知します。',
  'try again in seconds': '数秒後に再試行してください',
  'try another keyword': '別のキーワードをお試しください',
  'tue': '火',
  'tuesday': '火曜日',
  'turn off & enable': '無効化して有効にする',
  'turn off reduced motion first': '先に視覚効果の削減をオフにしてください',
  'turn off single numbers?': 'シングル番号を無効にしますか？',
  'tutorials': 'チュートリアル',
  'two-way': '2方向',
  'two-way mode': 'IN/OUT 2方向モード',
  'type to search your notes...': '検索するキーワードを入力...',
  'undetected': '脅威なし (安全)',
  'undo': '元に戻す',
  'upcoming': '準備中',
  'upcoming languages': '今後追加予定の言語',
  'update available': 'アップデート利用可能',
  'update check failed': 'アップデート確認に失敗しました',
  'update track': '更新チャンネル',
  'updates & notices': 'アップデートとお知らせ',
  'urge surfing & grounding': '衝動の波乗りとグラウンディング',
  'use fingerprint, face, or system pin.': '指紋、顔認証、またはシステムPINを使用します。',
  'use numbers in single': 'シングルで番号を使用',
  'verified clean of malicious activity': '悪意ある動作のない安全性を検証済み',
  'verified safe': '安全性検証済み',
  'verifying integrity checksum...': '整合性チェックサムを検証中...',
  'version': 'バージョン',
  'view': '表示',
  'view all milestones': 'すべてのマイルストーンを見る',
  'view full licenses': 'ライセンス一覧を表示',
  'view note': 'メモを表示',
  'view your relapse pattern insights, top moods, and peak vulnerability windows.':
      '再発パターンの傾向、主な気分、注意すべき時間帯を確認できます。',
  'vinland saga': 'ヴィンランド・サガ',
  'virustotal safety scan': 'VirusTotal セキュリティ検証',
  'virustotal scan': 'VirusTotal スキャン',
  'vt report': 'VirusTotal レポート',
  'warrior': 'ウォリアー',
  'we have officially migrated our codebase to a new home. all future releases, updates, and issues will be managed here:':
      'コードベースを新しいリポジトリへ移転しました。今後のリリースや更新はすべてこちらで管理されます:',
  'wed': '水',
  'wednesday': '水曜日',
  'weekly reminder': 'ウィークリーリマインダー',
  'weekly reminder message': '毎週のリマインダー文',
  'welcome': 'ようこそ',
  'welcome to notekar': 'NoteKarへようこそ',
  'were you already clean before installing? set your actual start date here. this overrides automatic detection from your logs.':
      'インストール前から継続していましたか？実際の開始日をここで設定してください。',
  'whatsnewtitle': '新機能',
  'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.':
      'ソブリエティモード有効時に記録する際、気分やトリガーをタグ付けできます。',
  'wipe': '消去',
  'wooden shovel to creative mode god.': '木のシャベルからクリエイティブモードの神へ。',
  'yamcha to the omni-king zeno.': 'ヤムチャから全王様へ。',
  'yoki to the ultimate truth.': 'ヨキから真理へ。',
  'you are up to date': '最新バージョンです',
  'your clean streak is active and running.': '継続日数が進行中です。',
  'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.':
      'データは100%プライベートで端末内に留まります。',
  'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.':
      'ホーム画面にマイルストーンバッジ付きの日数カードが表示されます。',
  'your privacy matters': 'プライバシーの尊重',
  'zero telemetry & offline integrity': 'テレメトリゼロと完全オフライン保護',
};

const Map<String, String> _ruTranslations = {
  '* have suggestions or found a bug?': '* Есть предложения или нашли ошибку?',
  '* have suggestions or found a bug? ':
      '* Есть предложения или нашли ошибку? ',
  '0 / 68 clean': '0 / 68 безопасно',
  '100% offline': '100% Автономно',
  '100% offline database': '100% автономная база данных',
  '100% offline integrity': '100% автономная целостность',
  '100% offline-first. zero trackers. zero data collection':
      '100% автономность. Ноль трекеров. Ноль сбора данных',
  '16-week habit activity grid': 'Сетка активности привычек за 16 недель',
  '5-4-3-2-1 grounding': 'Заземление 5-4-3-2-1',
  '8 luxury app icon editions': '8 эксклюзивных иконок приложения',
  'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.':
      'Конфиденциальный офлайн-трекер трезвости и дневник для поддержки вашего пути.',
  'a quiet, offline-first way to mark moments the second they happen.':
      'Простой локальный способ фиксировать моменты в секунду их свершения.',
  'about': 'О программе',
  'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.':
      'Абсолютно. NoteKar имеет открытый исходный код и работает полностью офлайн. Надежность подтверждена 60+ антивирусными системами.',
  'accent color': 'Цвет акцента',
  'accentcolorcategory': 'Цвет акцента',
  'accept': 'Принять',
  'access split-per-abi optimized binaries and google play appbundles directly from the release page.':
      'Загружайте оптимизированные сборки прямо со страницы релизов.',
  'accessibility': 'Специальные возможности',
  'accessibilitycategory': 'Специальные возможности',
  'active': 'Активно',
  'active issue tracking': 'Отслеживание задач и багов',
  'active launcher icon': 'Активный значок запуска',
  'active protection': 'Активная защита',
  'activity': 'Активность',
  'adaptive engine': 'Адаптивный движок',
  'adaptive engine and performance status':
      'Адаптивный движок и состояние производительности',
  'adaptive engine overview': 'Обзор адаптивного движка',
  'add a note': 'Добавить заметку',
  'add a note to save': 'Добавьте заметку для сохранения',
  'adds a clean streak card to your home screen and adapts home screen widgets.':
      'Добавляет карточку серии на главный экран и оптимизирует виджеты.',
  'adds a subtle glass-like container behind the home toolbar.':
      'Добавляет стеклянную подложку позади панели инструментов.',
  'afternoon': 'День',
  'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.':
      'Отключите оптимизацию батареи, чтобы гарантировать надежную доставку напоминаний.',
  'alarms permission required': 'Требуется разрешение на будильники',
  'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.':
      'Все 21 достижение от 1 дня до 10 лет, основанные на исследованиях нейробиологии.',
  'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.':
      'Все сборки проходят автоматические проверки CodeQL и VirusTotal для гарантии чистоты кода.',
  'all moments in the database will be permanently removed. this cannot be undone.':
      'Все моменты в базе данных будут удалены безвозвратно. Это действие нельзя отменить.',
  'all settings will be restored to their initial factory defaults. your saved moments and notes will remain untouched.':
      'Все настройки будут сброшены до заводских значений по умолчанию. Ваши сохраненные моменты и заметки останутся нетронутыми.',
  'all time': 'За все время',
  'allow app installation': 'Разрешить установку приложений',
  'allow auto-start settings': 'Разрешить автозапуск',
  'allow notifications': 'Разрешить уведомления',
  'allows notekar to send logging reminders and update notifications.':
      'Разрешает NoteKar отправлять напоминания о записи и уведомления об обновлениях.',
  'amethyst': 'Аметист',
  'amethyst nebula': 'Аметистовая туманность',
  'amoled': 'AMOLED',
  'ancient': 'Древность',
  'android backup': 'Резервное копирование Android',
  'angry': 'Гнев',
  'animal kingdom': 'Царство животных',
  'anxious': 'Тревога',
  'app icon': 'Иконка приложения',
  'app icon could not be changed': 'Не удалось изменить иконку приложения',
  'app icons': 'Иконки приложения',
  'app language': 'Язык приложения',
  'app lock': 'Блокировка приложения',
  'app lock & biometrics': 'Блокировка и биометрия',
  'app lock & security': 'Блокировка и безопасность',
  'app lock appears after the notification panel':
      'Блокировка приложения отображается после панели уведомлений',
  'app lock needs a device screen lock':
      'Блокировка приложения требует блокировки экрана устройства',
  'app lock timing': 'Время блокировки приложения',
  'app lock will not turn on': 'Блокировка приложения не включается',
  'app notices': 'Уведомления приложения',
  'app notices are not appearing': 'Уведомления приложения не отображаются',
  'app preferences and theme': 'Настройки приложения и тема',
  'app switcher obfuscation': 'Скрытие в переключателе приложений',
  'app theme': 'Цветовая тема',
  'app usage': 'Использование приложения',
  'app version': 'Версия приложения',
  'appearance': 'Внешний вид',
  'appiconscategory': 'Иконки приложения',
  'application build identifier': 'Идентификатор сборки приложения',
  'apply a custom accent color across all fluid interface elements.':
      'Применяет пользовательский акцентный цвет ко всем элементам интерфейса.',
  'applying app icon': 'Применение значка приложения',
  'army elite. every clean day is a battle fought and won.':
      'Армейская элита. Каждый день — выигранная битва.',
  'as a small, offline-first timestamp logger for real work: quick taps, focused notes, and exports developers can inspect.':
      'как компактный автономный инструмент фиксации времени для реальной работы: быстрые нажатия, заметки и проверяемый экспорт.',
  'at': 'в',
  'attach context without slowing the app down.':
      'Добавляйте контекст без замедления работы приложения.',
  'attack on titan': 'Атака титанов',
  'aurora': 'Аврора',
  'aurora borealis': 'Северное сияние',
  'auto-start & background activity': 'Автозапуск и фоновая активность',
  'automated security scans': 'Автоматические проверки безопасности',
  'automatic': 'Автоматически',
  'available languages': 'Доступные языки',
  'back': 'Назад',
  'back up data': 'Резервное копирование',
  'backup & export': 'Резервное копирование и экспорт',
  'backup & restore': 'Резервное копирование и восстановление',
  'backup filename preview': 'Предпросмотр имени файла бэкапа',
  'backup has no new moments': 'В резервной копии нет новых моментов',
  'backup import failed': 'Ошибка импорта резервной копии',
  'backup import found no new moments':
      'В резервной копии не найдено новых моментов',
  'backup reminder: export a fresh backup soon':
      'Напоминание: экспортируйте свежую резервную копию',
  'backup status': 'Статус резервной копии',
  'backupexportcategory': 'Резервное копирование и экспорт',
  'battery and performance status': 'Состояние батареи и производительность',
  'battery optimization active': 'Включена оптимизация батареи',
  'ben 10': 'Бен 10',
  'beta': 'Бета',
  'beta feature': 'Бета-функция',
  'beta track': 'Бета-канал',
  'biometric lock': 'Биометрическая блокировка',
  'biometrics not available': 'Биометрия недоступна',
  'biometrics or system credentials': 'Биометрия или системный PIN',
  'bleach': 'Блич',
  'blur & translucency': 'Размытие и полупрозрачность',
  'bored': 'Скука',
  'boredom': 'Скука',
  'box breathing': 'Квадратное дыхание',
  'build cache cleared': 'Кэш сборки очищен',
  'build cache size': 'Размер кэша сборки',
  'build date': 'Дата сборки',
  'build number': 'Номер сборки',
  'built by': 'Разработано',
  'bushido code. master of the self.': 'Кодекс бусидо. Власть над собой.',
  'buy me a coffee': 'Поддержать чашкой кофе',
  'can i restore deleted moments?': 'Можно ли восстановить удаленные моменты?',
  'cancel': 'Отмена',
  'capture': 'Запись',
  'capture cooldown': 'Интервал между нажатиями',
  'capture delay & cooldown': 'Задержка захвата и интервал',
  'capturecategory': 'Запись',
  'celtic highland clan. earn your place, carry the banner.':
      'Кельтский клан горцев. Заслужи свое место, неси знамя.',
  'change your secure in-app passcode.':
      'Измените ваш надежный пароль в приложении.',
  'changelog': 'Список изменений',
  'changelogtitle': 'Список изменений',
  'check again': 'Проверить снова',
  'check for updates': 'Проверить обновления',
  'checking for updates...': 'Проверка обновлений...',
  'chess mastery': 'Мастерство в шахматах',
  'choose how notekar starts when you open it':
      'Выберите, как NoteKar запускается при открытии',
  'choose language': 'Выбор языка',
  'choose milestone theme': 'Выбрать тему достижений',
  'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.':
      'Выберите стиль названий для ваших достижений.',
  'choose your preferred interface language':
      'Выберите предпочтительный язык интерфейса',
  'civilian to the one above all.': 'От обывателя до Всевышнего.',
  'clan': 'Клан',
  'clear': 'Очистить',
  'clear all moments': 'Очистить все моменты',
  'clear cache': 'Очистить кэш',
  'clear search': 'Очистить поиск',
  'clear trash': 'Очистить корзину',
  'clinical neuroscience terms. cold, precise, honest.':
      'Термины клинической нейробиологии. Строгие, точные, честные.',
  'close': 'Закрыть',
  'code geass': 'Код Гиас',
  'color accent': 'Акцентный цвет',
  'commits': 'Коммиты',
  'compact history': 'Компактная история',
  'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.':
      'Компактная история не может быть включена при активной нумерации одиночных моментов. Отключите одиночные номера для компактных строк.',
  'compact history mode': 'Компактный режим истории',
  'configure a dedicated 4-digit passcode.':
      'Настройте отдельный 4-значный пароль.',
  'configure settings': 'Настроить параметры',
  'confirm': 'Подтвердить',
  'confirm delete': 'Подтверждение удаления',
  'confirm passcode': 'Подтвердите код доступа',
  'continue': 'Продолжить',
  'continuous': 'Непрерывно',
  'contribute on github': 'Внести вклад на GitHub',
  'cooldown period': 'Период задержки',
  'copy': 'Копировать',
  'copy moment': 'Копировать момент',
  'correlation intelligence': 'Анализ корреляций',
  'cosmic exploration. every clean day is light-years gained.':
      'Космические исследования. Каждый чистый день — световые годы вперед.',
  'could not open backup file': 'Не удалось открыть файл резервной копии',
  'count on save': 'Счетчик при сохранении',
  'create quick local backup': 'Создать быструю локальную копию',
  'crimson': 'Багровый',
  'current message': 'Текущее сообщение',
  'cursed spirit to satoru gojo.': 'От проклятого духа до Сатору Годжо.',
  'custom start date': 'Своя дата начала',
  'daily logging reminder': 'Ежедневное напоминание о записи',
  'daily neuroscience insight': 'Ежедневный факт из нейробиологии',
  'daily reminder': 'Ежедневное напоминание',
  'daily reminder message': 'Текст ежедневного напоминания',
  'daily reminders': 'Ежедневные напоминания',
  'dark mode': 'Темный режим',
  'data': 'Данные',
  'data & backup': 'Данные и резервные копии',
  'data consumed': 'Потреблено данных',
  'data health': 'Состояние данных',
  'database export': 'Экспорт базы данных',
  'database integrity': 'Целостность базы данных',
  'day of month': 'Число месяца',
  'days of week': 'Дни недели',
  'death note': 'Тетрадь смерти',
  'delete': 'Удалить',
  'delete all moments?': 'Удалить все моменты?',
  'delete backup?': 'Удалить резервную копию?',
  'delete cache': 'Удалить кэш',
  'delete moment': 'Удалить момент',
  'delete permanently': 'Удалить навсегда',
  'delete permanently?': 'Удалить навсегда?',
  'deleted in moment': 'Момент IN удален',
  'deleted out moment': 'Момент OUT удален',
  'deleted single moment': 'Момент SINGLE удален',
  'deleting cache...': 'Удаление кэша...',
  'demon slayer': 'Клинок, рассекающий демонов',
  'dev': 'Разработка',
  'developer diagnostics': 'Диагностика разработчика',
  'developer key': 'Ключ разработчика',
  'developer options': 'Параметры разработчика',
  'device health': 'Состояние устройства',
  'diagnostics': 'Диагностика',
  'diagnostics and internal engine settings for developers.':
      'Диагностика и параметры внутреннего движка для разработчиков.',
  'diagnosticscategory': 'Диагностика',
  'disable battery optimization': 'Отключить оптимизацию батареи',
  'disable compact history?': 'Отключить компактную историю?',
  'disable reduce motion first': 'Сначала отключите «Уменьшение движения»',
  'disable use numbers in single?': 'Отключить нумерацию в одиночном режиме?',
  'disabled': 'Отключено',
  'dismiss': 'Закрыть',
  'display': 'Отображение',
  'display & typography': 'Отображение и типографика',
  'displaycategory': 'Отображение',
  'docs': 'Документация',
  'done': 'Готово',
  'download': 'Скачать',
  'download & install': 'Скачать и установить',
  'download failed': 'Ошибка загрузки',
  'download from github': 'Скачать с GitHub',
  'download size:': 'Размер загрузки:',
  'downloading update...': 'Загрузка обновления...',
  'dragon ball': 'Драконий жемчуг',
  'e-rank sung jinwoo to shadow monarch.':
      'От Сон Джинву E-ранга до Владыки Теней.',
  'east blue coby to the pirate king gol d. roger.':
      'От Коби из Ист Блю до Короля пиратов Гол Д. Роджера.',
  'edit': 'Редактировать',
  'edit message': 'Редактировать сообщение',
  'edit note': 'Редактировать заметку',
  'email support': 'Поддержка по почте',
  'emerald': 'Изумруд',
  'emerald forest': 'Изумрудный лес',
  'empty': 'Пусто',
  'empty trash': 'Очистить корзину',
  'empty trash?': 'Очистить корзину?',
  'enable count on save': 'Показывать счетчик при сохранении',
  'enable show seconds first': 'Сначала включите отображение секунд',
  'enable sobriety mode': 'Включить режим трезвости',
  'encrypted backup': 'Зашифрованная копия',
  'endpoint url': 'URL-адрес конечной точки',
  'english': 'Английский',
  'enter passcode': 'Введите код доступа',
  'enter reminder message...': 'Введите текст напоминания...',
  'essential features': 'Основные функции',
  'evening': 'Вечер',
  'every 14 days': 'Каждые 14 дн.',
  'every 30 days': 'Каждые 30 дн.',
  'every 7 days': 'Каждые 7 дн.',
  'every tap records a standalone moment.':
      'Каждое нажатие фиксирует отдельный момент.',
  'export backup': 'Экспорт копии',
  'export csv': 'Экспорт CSV',
  'export failed. try again.': 'Ошибка экспорта. Повторите попытку.',
  'export json': 'Экспорт JSON',
  'export last 7 days': 'Экспорт за последние 7 дней',
  'export milestone card': 'Экспорт карточки рубежа',
  'export saved to downloads': 'Экспорт сохранен в Загрузки',
  'export, import, and manage your data backups.':
      'Экспорт, импорт и управление резервными копиями данных.',
  'extended duration': 'Расширенная длительность',
  'external navigation': 'Внешний переход',
  'factory reset': 'Сброс к заводским настройкам',
  'failed to create local backup': 'Не удалось создать резервную копию',
  'failed to read local backup file':
      'Не удалось прочитать локальный файл резервной копии',
  'faq': 'Частые вопросы',
  'fatigue': 'Утомление',
  'feedback': 'Обратная связь',
  'feedback & bug report': 'Отзывы и отчеты об ошибках',
  'fri': 'Пт',
  'friday': 'Пятница',
  'friends': 'Друзья',
  'from': 'С',
  'full': 'Полный',
  'full online policy': 'Полная политика конфиденциальности онлайн',
  'full online terms': 'Полные условия использования онлайн',
  'full title & purpose': 'Полное название и назначение',
  'fullmetal alchemist': 'Стальной алхимик',
  'german': 'Немецкий',
  'get started': 'Начать',
  'gintama': 'Гинтама',
  'github': 'GitHub',
  'give feedback': 'Оставить отзыв',
  'google drive backup': 'Резервное копирование Google Диск',
  'got it': 'Понятно',
  'grant permission': 'Предоставить разрешение',
  'greek and roman glory. rise from mortal to olympian.':
      'Греческая и римская слава. Восстань из смертного в олимпийца.',
  'grey matter to alien x.': 'От Гуманоида до Пришельца Икс.',
  'guides': 'Руководства',
  'happy': 'Радость',
  'hardware security': 'Аппаратная безопасность',
  'hardware-backed encryption': 'Аппаратное шифрование',
  'harry potter': 'Гарри Поттер',
  'have suggestions or found a bug?': 'Есть предложения или нашли ошибку?',
  'help': 'Помощь',
  'help & user guides': 'Справка и руководства',
  'hide app content in recents': 'Скрывать содержимое в недавних',
  'hindi': 'Хинди',
  'history': 'История',
  'hold for notes': 'Удерживайте для заметок',
  'hour': 'час',
  'hours': 'часов',
  'html editor to turing award winner.':
      'От HTML-редактора до лауреата премии Тьюринга.',
  'hunter x hunter': 'Хантер х Хантер',
  'imperial': 'Империал',
  'imperial gold': 'Имперское золото',
  'import backup': 'Импорт копии',
  'import cancelled': 'Импорт отменен',
  'important notice': 'Важное уведомление',
  'in-app ota updates': 'Встроенные OTA-обновления',
  'in-app pin': 'PIN-код приложения',
  'in-app pin set successfully.': 'PIN-код приложения успешно установлен.',
  'in-app update setup': 'Настройка обновлений приложения',
  'inactive': 'Неактивно',
  'inactivity alerts': 'Оповещения о неактивности',
  'inactivity reminder': 'Напоминание при неактивности',
  'incorrect passcode': 'Неверный код доступа',
  'install now': 'Установить сейчас',
  'installation failed to start': 'Не удалось начать установку',
  'integrity check failed: checksum mismatch':
      'Ошибка проверки целостности: несовпадение контрольной суммы',
  'intelligent risk radar': 'Интеллектуальный радар рисков',
  'invalid backup file': 'Недопустимый файл резервной копии',
  'is notekar private?': 'NoteKar конфиденциален?',
  'is notekar safe to use?': 'Безопасно ли использовать NoteKar?',
  'item': 'элемент',
  'items': 'элементов',
  'japanese': 'Японский',
  'jujutsu kaisen': 'Магическая битва',
  'july 2026': 'Июль 2026',
  'kingdom': 'Королевство',
  'konohamaru to the sage of six paths.':
      'От Конохамару до Мудреца Шести Путей.',
  'language': 'Язык',
  'last scan': 'Последнее сканирование',
  'late night': 'Поздняя ночь',
  'late_night': 'Поздняя ночь',
  'learn more': 'Подробнее',
  'legal & open source notices': 'Правовые уведомления и открытый код',
  'less': 'Меньше',
  'licenses': 'Лицензии',
  'limited connectivity': 'Ограниченное сетевое подключение',
  'link copied': 'Ссылка скопирована',
  'live activity tracking dashboard featuring real-time metric analysis, habit tracking grids, activity trends, and correlation intelligence calculated from your moments.':
      'Панель мониторинга активности с аналитикой в реальном времени, сеткой привычек, трендами и корреляцией моментов.',
  'live icon motion looks slow or delayed':
      'Анимация иконки работает с задержкой',
  'live icon motion will not turn on': 'Анимация иконки не включается',
  'load older moments': 'Загрузить более старые моменты',
  'loading database...': 'Загрузка базы данных...',
  'local backups': 'Локальные резервные копии',
  'local storage': 'Локальное хранилище',
  'location': 'Место',
  'log a moment instantly from the main screen.':
      'Мгновенно фиксируйте момент с главного экрана.',
  'logging': 'Запись',
  'logging reminder': 'Напоминание о записи',
  'logging reminders': 'Напоминания о записи',
  'logs': 'Записи',
  'loneliness': 'Одиночество',
  'lonely': 'Одиночество',
  'magikarp to the creator god arceus.': 'От Мэджикарпа до создателя Аркеуса.',
  'manage': 'Управление',
  'manage moment notes': 'Управление заметками',
  'manage security, passcode lock, and app privacy.':
      'Управление безопасностью, блокировкой и конфиденциальностью.',
  'marvel universe': 'Вселенная Marvel',
  'matsuda to the shinigami king.': 'От Мацуды до Короля синигами.',
  'medieval royalty. rise from serf to sovereign.':
      'Средневековая знать. От простолюдина до государя.',
  'message': 'Сообщение',
  'midnight': 'Полночь',
  'midnight obsidian': 'Полуночный обсидиан',
  'milestone achieved': 'Рубеж достигнут',
  'milestone badges': 'Значки достижений',
  'milestone peak': 'Пик рубежа',
  'milestone theme': 'Тема достижений',
  'milestone unlocked!': 'Рубеж разблокирован!',
  'milestones': 'Достижения',
  'mineta to all might prime.': 'От Минеты до Всемогущего на пике сил.',
  'minimal moment options': 'Минимальные действия',
  'mit': 'MIT',
  'moisture farmer to the chosen one.':
      'От фермера-влагодобытчика до Избранного.',
  'moment options': 'Параметры момента',
  'moment saved': 'Момент сохранен',
  'moments': 'Моменты',
  'momentscategory': 'Моменты',
  'mon': 'Пн',
  'monastic journey. silence, stillness, and vows.':
      'Монашеский путь. Безмолвие и стойкость.',
  'monday': 'Понедельник',
  'monk': 'Монах',
  'monthly reminder': 'Ежемесячное напоминание',
  'monthly reminder message': 'Текст ежемесячного напоминания',
  'more': 'Больше',
  'morning': 'Утро',
  'motion sensor unavailable': 'Датчик движения недоступен',
  'muggle to merlin.': 'От магла до Мерлина.',
  'murata to yoriichi tsugikuni.': 'От Мураты до Ёриити Цугикуни.',
  'my hero academia': 'Моя геройская академия',
  'naruto': 'Наруто',
  'navy': 'Флот',
  'network & data transparency': 'Прозрачность сети и данных',
  'network monitor': 'Сетевой монитор',
  'network warning': 'Предупреждение о сети',
  'neuroscience & growth': 'Нейробиология и развитие',
  'next': 'Далее',
  'night': 'Ночь',
  'no internet connection. showing cached preview.':
      'Нет подключения к интернету. Отображается кэшированная копия.',
  'no local backups found': 'Локальных резервных копий не найдено',
  'no matching notes': 'Нет подходящих заметок',
  'no message set (will show default reminder)':
      'Сообщение не задано (будет показано стандартное напоминание)',
  'no moments': 'Нет моментов',
  'no moments logged yet': 'Моментов пока не записано',
  'no note': 'Нет заметки',
  'no notes found': 'Заметок не найдено',
  'no relapses recorded yet!': 'Срывов пока не зафиксировано!',
  'no repository activity': 'Нет активности в репозитории',
  'no results': 'Нет результатов',
  'no results found': 'Ничего не найдено',
  'no search results found': 'Результаты поиска не найдены',
  'no tracking': 'Без отслеживания',
  'none': 'Нет',
  'not set: using last log or relapse tag':
      'Не задано: используется последняя запись или тег срыва',
  'note copied to clipboard': 'Заметка скопирована в буфер обмена',
  'note on click': 'Заметка по нажатию',
  'notekar': 'NoteKar',
  'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.':
      'Сборки NoteKar компилируются со сканированием CodeQL и проверяются в VirusTotal.',
  'notekar is offline': 'NoteKar работает офлайн',
  'notekar stores moments privately on this device. backups are files you control.':
      'NoteKar хранит моменты конфиденциально на этом устройстве. Резервные копии находятся под вашим полным контролем.',
  'notes': 'Заметки',
  'notification permission needed': 'Требуется разрешение на уведомления',
  'numbered single moments': 'Нумерованные одиночные моменты',
  'official repository moved': 'Официальный репозиторий перемещен',
  'offline analysis of your logged relapse moments. no data leaves your device.':
      'Офлайн-анализ ваших записей. Никакие данные не покидают устройство.',
  'offline privacy log': 'Автономный журнал конфиденциальности',
  'offline-first': 'Сначала автономно',
  'ok': 'ОК',
  'okay': 'ОК',
  'one piece': 'Ван Пис',
  'only moments tagged #relapse reset the streak. turn off to reset on any new log.':
      'Только записи с тегом #relapse сбрасывают серию. Отключите, чтобы сбрасывать при любой новой записи.',
  'open link': 'Открыть ссылку',
  'open source': 'Открытый исходный код',
  'package verified & ready': 'Пакет проверен и готов',
  'passcodes do not match': 'Коды доступа не совпадают',
  'peak risk window': 'Пиковое время риска',
  'personalization': 'Персонализация',
  'personalize and configure notekar to fit your specific workflow.':
      'Настройте и персонализируйте NoteKar под ваш рабочий процесс.',
  'personalized app icons': 'Персонализированные иконки',
  'phoenix': 'Феникс',
  'planned': 'Запланировано',
  'please wait while android refreshes notekar.':
      'Пожалуйста, подождите, пока Android обновляет NoteKar.',
  'pokemon': 'Покемон',
  'priest willibald to thors the troll of jom.':
      'От священника Виллибальда до Торса Йомского тролля.',
  'privacy & offline model': 'Модель конфиденциальности и офлайн',
  'privacy & security': 'Конфиденциальность и безопасность',
  'privacy policy': 'Политика конфиденциальности',
  'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.':
      'Конфиденциальное отслеживание серии и дневник. Все данные остаются на вашем устройстве.',
  'privacysecuritycategory': 'Конфиденциальность и безопасность',
  'pure titan to the founder ymir fritz.':
      'От обычного титана до прародительницы Имир Фриц.',
  'push alerts & notices': 'Push-уведомления и оповещения',
  'quick local backup created': 'Локальная копия создана',
  'ratio': 'Результат',
  'real-time metrics': 'Метрики в реальном времени',
  'real-time traffic audit': 'Аудит трафика в реальном времени',
  'rebirth through fire. the old is ash; you are the flame.':
      'Перерождение сквозь огонь. Прошлое — пепел; ты — пламя.',
  'recent': 'Недавнее',
  'recent messages': 'Недавние сообщения',
  'recently deleted': 'НЕДАВНО УДАЛЕННЫЕ',
  'recommended for standard users.': 'Рекомендуется для обычных пользователей.',
  'refresh activity': 'Обновить активность',
  'remind if inactive for': 'Напомнить при отсутствии записей:',
  'reminder message': 'Текст напоминания',
  'reminders': 'Напоминания',
  'reminders & notifications': 'Напоминания и уведомления',
  'report a bug': 'Сообщить об ошибке',
  'repository link copied to clipboard':
      'Ссылка на репозиторий скопирована в буфер обмена',
  'request a feature': 'Предложить функцию',
  'required to show the logging alerts.':
      'Требуется для отображения напоминаний о записи.',
  'reset': 'Сброс',
  'reset all data': 'Сбросить все данные',
  'reset daily': 'Сбрасывать ежедневно',
  'reset data': 'Сбросить данные',
  'reset on relapse tag only': 'Сброс только по тегу срыва',
  'reset pin lock': 'Сбросить блокировку PIN-кодом',
  'reset settings': 'Сбросить настройки',
  'reset settings only': 'Сбросить только настройки',
  'resetcategory': 'Сброс',
  'restarts count at 00 every midnight while keeping past history intact.':
      'Перезапускает счет с 00 каждую полночь, сохраняя предыдущую историю.',
  'restore': 'Восстановить',
  'restore all': 'Восстановить все',
  'restore all moments?': 'Восстановить все моменты?',
  'restore deleted moments': 'Восстановить удаленные моменты',
  'restore or permanently remove deleted moments':
      'Восстановить или навсегда удалить удаленные моменты',
  'retry download': 'Повторить загрузку',
  'review and export': 'Просмотр и экспорт',
  'review backup': 'Проверить резервную копию',
  'review history': 'Просмотреть историю',
  'rpg / minecraft': 'RPG / Майнкрафт',
  'russian': 'Русский',
  's mate victim to magnus carlsen.':
      'От жертвы детского мата до Магнуса Карлсена.',
  's new': 'Что нового',
  's new in notekar': 'Что нового в NoteKar',
  'sad': 'Грусть',
  'samurai': 'Самурай',
  'sapphire': 'Сапфир',
  'sat': 'Сб',
  'saturday': 'Суббота',
  'save': 'Сохранить',
  'save a moment': 'Сохранить момент',
  'science': 'Наука',
  'seafaring odyssey. chart new waters and never look back.':
      'Морская одиссея. Открывайте новые горизонты.',
  'search notes': 'Поиск заметок',
  'search settings': 'Поиск по настройкам',
  'search settings...': 'Поиск настроек...',
  'secure passcode protection': 'Защита паролем',
  'security & cryptographic upgrade': 'Обновление безопасности и шифрования',
  'security & integrity': 'Безопасность и целостность',
  'select a theme that best suits your environment.':
      'Выберите тему, которая лучше всего подходит для ваших условий.',
  'select date': 'Выбрать дату',
  'select date and time': 'Выбрать дату и время',
  'select for duration': 'Выбрать для расчета длительности',
  'select time': 'Выбрать время',
  'select your preferred interface language. you can change this anytime in settings.':
      'Выберите предпочтительный язык. Вы можете изменить его в любой момент в настройках.',
  'select your preferred language for the application.':
      'Выберите язык для приложения.',
  'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.':
      'Последовательная нумерация (00–99) требует стандартных отступов строк для отображения 2-значных значков. Отключите компактную историю, чтобы включить нумерацию.',
  'sessions are recorded as in and out pairs.':
      'Сессии записываются парами «ВХОД» и «ВЫХОД».',
  'set': 'Установлено',
  'set passcode': 'Установить код доступа',
  'set sobriety start date': 'Установить дату начала',
  'set unrestricted': 'Установить без ограничений',
  'settings': 'Настройки',
  'settings restored': 'Настройки восстановлены',
  'sha-256 hashes': 'Хэши SHA-256',
  'share': 'Поделиться',
  'share card': 'Поделиться карточкой',
  'share milestone peak': 'Поделиться рубежом',
  'shinpachi to utsuro.': 'От Синпати до Уцуро.',
  'shirley to emperor lelouch vi britannia.':
      'От Ширли до императора Лелуша ви Британия.',
  'show more': 'Показать больше',
  'show seconds': 'Показывать секунды',
  'shows 00–99 counters instead of static icons in history.':
      'Отображает счетчики 00–99 вместо статических иконок в истории.',
  'shows sequential numbers (00, 01...) on the tap pulse animation.':
      'Показывает порядковые номера (00, 01...) на анимации нажатия.',
  'signature': 'Подпись',
  'single': 'Одиночный',
  'single mode': 'Одиночный режим',
  'single moment numbering': 'Нумерация одиночных моментов',
  'skip': 'Пропустить',
  'smaller, optimized apks': 'Оптимизированные пакеты APK',
  'smart bandwidth saver': 'Умная экономия трафика',
  'sobriety companion': 'Трекер трезвости',
  'sobriety tracker': 'Трекер трезвости',
  'sobriety tracker & milestone cards':
      'Трекер трезвости и карточки достижений',
  'sobriety trigger analysis': 'Анализ триггеров',
  'social media': 'Соцсети',
  'social_media': 'Социальные сети',
  'software credits and open source legal notices':
      'Авторы ПО и лицензии открытого исходного кода',
  'software licenses': 'Лицензии ПО',
  'software update': 'Обновление ПО',
  'software update, app notices, changelog':
      'Обновление ПО, уведомления, список изменений',
  'solo leveling': 'Поднятие уровня в одиночку',
  'space': 'Космос',
  'spanish': 'Испанский',
  'stable': 'Стабильная',
  'stable build': 'Стабильная сборка',
  'star wars': 'Звездные войны',
  'start logging': 'Начать запись',
  'startup mode': 'Режим запуска',
  'status': 'Статус',
  'storage error: moment not saved': 'Ошибка хранилища: момент не сохранен',
  'streak mode': 'Режим серии',
  'streak reset logic': 'Логика сброса серии',
  'streak shield deployed! clean streak protected.':
      'Щит серии активирован! Серия защищена.',
  'stress': 'Стресс',
  'stressed': 'Стресс',
  'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.':
      'Отправляйте отчеты об ошибках и предложения в трекер нового репозитория.',
  'suggest a new idea or improvement.': 'Предложите новую идею или улучшение.',
  'sun': 'Вс',
  'sunday': 'Воскресенье',
  'sunset': 'Закат',
  'support & community': 'Поддержка и сообщество',
  'survival of the fittest. tardigrade to mythical dragon.':
      'Выживание сильнейшего. От тихоходки до мифического дракона.',
  'switching to beta build...': 'Переключение на бета-сборку...',
  'switching to stable build...': 'Переключение на стабильную сборку...',
  'system default': 'Системный',
  'system lock': 'Системная блокировка',
  'system lock enabled': 'Системная блокировка включена',
  'table': 'Таблица',
  'tap any icon below to switch style':
      'Нажмите на любой значок ниже для смены стиля',
  'tap delay': 'Задержка нажатия',
  'tap to record a moment. hold to add a note.':
      'Нажмите для фиксации момента. Удерживайте для заметки.',
  'tap to save': 'Нажмите для сохранения',
  'tech career': 'Карьера в IT',
  'technical stats about your device and the adaptive engine.':
      'Технические показатели устройства и адаптивного движка.',
  'teddy bear kon to yhwach the almighty.':
      'От плюшевого Кона до Всемогущего Яхве.',
  'terms of use': 'Условия использования',
  'the current features on this page are under beta stage.':
      'Функции на этой странице находятся на стадии бета-тестирования.',
  'theme': 'Тема',
  'theme description': 'Описание темы',
  'theme mode': 'Режим оформления',
  'theme style': 'Стиль темы',
  'these languages are planned for future releases. help translate notekar on github.':
      'Эти языки запланированы для будущих версий. Помогите перевести NoteKar на GitHub.',
  'these settings define how moments are recorded and prepared for export.':
      'Эти параметры определяют правила записи моментов и их экспорт.',
  'these settings refine the interface aesthetic and do not modify your saved data.':
      'Эти настройки изменяют интерфейс и не затрагивают сохраненные данные.',
  'these tools are intended for system maintenance and troubleshooting.':
      'Инструменты для обслуживания системы и устранения неполадок.',
  'this backup contains no moments': 'В этой резервной копии нет моментов',
  'this feature is currently in active development. while fully functional and secure, you may notice minor adjustments to the layout or performance as we refine the experience. all calculations, data, and security policies remain entirely local to your device.':
      'Эта функция находится в активной разработке. Она полностью функциональна и безопасна. Все вычисления и данные остаются на вашем устройстве.',
  'this language is currently under development. you can help translate notekar into your native language by contributing on github.':
      'Этот язык находится в разработке. Вы можете помочь перевести NoteKar на ваш родной язык, внеся свой вклад на GitHub.',
  'this local backup file will be erased permanently.':
      'Этот локальный файл резервной копии будет удален навсегда.',
  'this moment will be erased forever.': 'Этот момент будет удален навсегда.',
  'this week': 'На этой неделе',
  'this will permanently delete all moments in the trash. this action cannot be undone.':
      'Все моменты в корзине будут удалены навсегда. Это действие нельзя отменить.',
  'this will permanently delete all moments. this action cannot be undone.':
      'Все моменты будут удалены навсегда. Это действие нельзя отменить.',
  'this will return all items currently in the trash to your history.':
      'Все элементы из корзины вернутся в историю.',
  'thu': 'Чт',
  'thursday': 'Четверг',
  'time': 'Время',
  'time between moments': 'Время между моментами',
  'time to log a moment!': 'Время записать момент!',
  'tired': 'Усталость',
  'to trigger reminders precisely when the app is closed, notekar requires the "alarms & reminders" permission.':
      'Для точного срабатывания напоминаний при закрытом приложении требуется разрешение на «Будильники и напоминания».',
  'today': 'Сегодня',
  'tonpa to adult gon.': 'От Тонпы до взрослого Гона.',
  'tools': 'Инструменты',
  'top mood': 'Главное настроение',
  'top trigger': 'Главный триггер',
  'total relapses': 'Всего срывов',
  'total requests': 'Всего запросов',
  'track starts and stops': 'Отслеживание начала и завершения',
  'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.':
      'Организуйте историю с помощью 2-значных счетчиков (00–99), ежедневного сброса в полночь и календаря в стиле iOS.',
  'trash bin': 'Корзина',
  'trash is empty': 'Корзина пуста',
  'trigger analysis': 'Анализ триггеров',
  'trigger diary': 'Дневник триггеров',
  'triggers reminders on specific days of the week.':
      'Запускает напоминания в выбранные дни недели.',
  'try again in seconds': 'Повторите попытку через несколько секунд',
  'try another keyword': 'Попробуйте другое ключевое слово',
  'tue': 'Вт',
  'tuesday': 'Вторник',
  'turn off & enable': 'Отключить и включить',
  'turn off reduced motion first': 'Сначала отключите уменьшение движения',
  'turn off single numbers?': 'Отключить одиночные номера?',
  'tutorials': 'Обучение',
  'two-way': 'Двусторонний',
  'two-way mode': 'Двусторонний режим',
  'type to search your notes...': 'Введите текст для поиска...',
  'undetected': 'Угроз не обнаружено (Чисто)',
  'undo': 'Отменить',
  'upcoming': 'Скоро',
  'upcoming languages': 'Скоро доступные языки',
  'update available': 'Доступно обновление',
  'update check failed': 'Не удалось проверить обновления',
  'update track': 'Канал обновлений',
  'updates & notices': 'Обновления и оповещения',
  'urge surfing & grounding': 'Серфинг побуждений и заземление',
  'use fingerprint, face, or system pin.':
      'Используйте отпечаток пальца, лицо или системный PIN.',
  'use numbers in single': 'Номера в одиночных',
  'verified clean of malicious activity':
      'Проверено на отсутствие вредоносного ПО',
  'verified safe': 'Проверено и безопасно',
  'verifying integrity checksum...': 'Проверка контрольной суммы...',
  'version': 'Версия',
  'view': 'Просмотреть',
  'view all milestones': 'Все достижения',
  'view full licenses': 'Просмотреть все лицензии',
  'view note': 'Просмотреть заметку',
  'view your relapse pattern insights, top moods, and peak vulnerability windows.':
      'Просматривайте статистику триггеров, преобладающие настроения и уязвимые часы.',
  'vinland saga': 'Сага о Винланде',
  'virustotal safety scan': 'Проверка безопасности VirusTotal',
  'virustotal scan': 'Проверка VirusTotal',
  'vt report': 'Отчет VirusTotal',
  'warrior': 'Воин',
  'we have officially migrated our codebase to a new home. all future releases, updates, and issues will be managed here:':
      'Мы перенесли кодовую базу. Все будущие релизы и обновления будут публиковаться здесь:',
  'wed': 'Ср',
  'wednesday': 'Среда',
  'weekly reminder': 'Еженедельное напоминание',
  'weekly reminder message': 'Текст еженедельного напоминания',
  'welcome': 'Добро пожаловать',
  'welcome to notekar': 'Добро пожаловать в NoteKar',
  'were you already clean before installing? set your actual start date here. this overrides automatic detection from your logs.':
      'Вы уже были в процессе до установки? Укажите реальную дату начала здесь.',
  'whatsnewtitle': 'Что нового',
  'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.':
      'При создании записи можно указать настроение и триггер.',
  'wipe': 'Очистить',
  'wooden shovel to creative mode god.':
      'От деревянной лопаты до бога Творческого режима.',
  'yamcha to the omni-king zeno.': 'От Ямчи до Короля Всего Зено.',
  'yoki to the ultimate truth.': 'От Йоки до абсолютной Истины.',
  'you are up to date': 'У вас актуальная версия',
  'your clean streak is active and running.': 'Ваша непрерывная серия активна.',
  'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.':
      'Ваши данные на 100% конфиденциальны и остаются на устройстве.',
  'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.':
      'На главном экране появится карточка с серией и значками достижений.',
  'your privacy matters': 'Ваша конфиденциальность важна',
  'zero telemetry & offline integrity': 'Ноль телеметрии и полная автономность',
};
